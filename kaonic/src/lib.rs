use jni::objects::{GlobalRef, JClass, JMethodID, JObject, JString};
use jni::sys::{jlong, jmethodID, jstring};
use jni::{signature, JNIEnv, JavaVM};
use rand_core::OsRng;
use reticulum::destination::link::Link;
use reticulum::destination::{DestinationName, SingleInputDestination};
use reticulum::hash::AddressHash;
use reticulum::identity::{Identity, PrivateIdentity};
use reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcInterface;
use reticulum::transport::Transport;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::runtime::Runtime;
use tokio::sync::broadcast;

use android_log;
use log;

struct KaonicDestinationList {
    contact: Arc<Mutex<SingleInputDestination>>,
}

#[derive(Clone)]
struct KaonicJni {
    context: GlobalRef,
}

struct KaonicState {
    jni: KaonicJni,
    cmd_tx: tokio::sync::broadcast::Sender<KaonicCommand>,
    runtime: Arc<Runtime>,
}

#[derive(Copy, Clone)]
struct Message {
    address_hash: AddressHash,
}

#[derive(Copy, Clone)]
enum KaonicCommand {
    Message,
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_libraryInit(env: JNIEnv) {
    android_log::init("Kaonic").unwrap();
    log::info!("kaonic library initialized");
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeInit(
    mut env: JNIEnv,
    _class: JClass,
    context: JObject,
) -> jlong {
    let (cmd_tx, _) = tokio::sync::broadcast::channel::<KaonicCommand>(32);

    let runtime = Arc::new(Runtime::new().expect("Failed to create Tokio runtime"));

    let jni = {
        KaonicJni {
            context: env
                .new_global_ref(context)
                .expect("Failed to create global ref"),
        }
    };

    let state = Box::new(KaonicState {
        jni,
        cmd_tx,
        runtime,
    });

    Box::into_raw(state) as jlong
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeDestroy(
    _env: JNIEnv,
    _class: JClass,
    ptr: jlong,
) {
    // Safety: ptr must be a valid pointer created by nativeInit
    unsafe {
        let _state = Box::from_raw(ptr as *mut KaonicState);
        // Box will be dropped here, cleaning up our state
    }
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeStart(
    mut env: JNIEnv,
    obj: JObject,
    ptr: jlong,
    identity: JString,
) {
    // Safety: ptr must be a valid pointer created by nativeInit
    let state = unsafe { &*(ptr as *const KaonicState) };

    // Convert JString to Rust String
    let identity_hex: String = match env.get_string(&identity) {
        Ok(jstr) => jstr.into(),
        Err(_) => {
            eprintln!("Failed to convert JString to Rust String");
            return;
        }
    };

    // Convert hex string into PrivateIdentity
    match PrivateIdentity::new_from_hex_string(&identity_hex) {
        Ok(identity) => {
            log::debug!("start reticulum for identity {}", identity.address_hash());

            let jvm = env.get_java_vm().expect("Failed to get JavaVM");
            let jvm = Arc::new(jvm); // Wrap in Arc to share across threads

            state.runtime.spawn(reticulum_task(
                identity,
                state.cmd_tx.subscribe(),
                Arc::clone(&jvm),
                env.new_global_ref(obj).unwrap(),
                state.jni.clone(),
            ));
        }
        Err(_) => log::error!("can't create private identity"),
    }
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeGenerateIdentity(
    env: JNIEnv,
    _obj: JObject,
    _ptr: jlong,
) -> jstring {
    // Generate new identity
    let identity = PrivateIdentity::new_from_rand(OsRng);

    env.new_string(identity.to_hex_string()).unwrap().into_raw()
}

async fn reticulum_task(
    identity: PrivateIdentity,
    mut cmd_rx: broadcast::Receiver<KaonicCommand>,
    jvm: Arc<JavaVM>,
    obj: GlobalRef,
    jni: KaonicJni,
) {
    log::info!("start reticulum task");

    let mut transport = Transport::new();

    let destination_list = KaonicDestinationList {
        contact: transport
            .add_destination(identity.clone(), DestinationName::new("kaonic", "contact")),
    };

    let _client = KaonicGrpcInterface::start(
        reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcConfig {
            // TODO: update host
            addr: "http://192.168.1.118:8080".into(),
            module: reticulum::iface::kaonic::RadioModule::RadioA,
        },
        transport.packet_channel(),
    );

    let mut announce_interval = tokio::time::interval(Duration::from_secs(10));

    let mut announces = transport.recv_announces();

    {
        loop {
            tokio::select! {
                Ok(cmd) = cmd_rx.recv() => {
                    match cmd {
                        KaonicCommand::Message => {

                        }
                    }
                }
                Ok(out_destination) = announces.recv() => {
                    let destination = out_destination.lock().unwrap();
                    // TODO: check if destination is compatible
                    // Start link
                    let link = transport.link(destination.desc);

                    let mut env = jvm
                        .attach_current_thread()
                        .expect("Failed to attach thread");

                    let identity = env
                    .new_string(destination.identity.to_hex_string())
                    .expect("Couldn't create java string!");

                    let address = env
                    .new_string(destination.identity.address_hash.to_hex_string())
                    .expect("Couldn't create java string!");


                    env.call_method(&obj, "announce", "(Ljava/lang/String;Ljava/lang/String;)V", &[(&identity).into(),(&address).into()]).unwrap();

                }
                _ = announce_interval.tick() => {
                    transport.announce(&destination_list.contact.lock().unwrap(), None).unwrap();
                }
            };
        }
    }
}
