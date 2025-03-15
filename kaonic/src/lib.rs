use jni::objects::{GlobalRef, JClass, JObject, JString};
use jni::sys::{jlong, jstring};
use jni::JNIEnv;
use rand_core::OsRng;
use reticulum::destination::{DestinationName, SingleInputDestination};
use reticulum::identity::PrivateIdentity;
use reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcInterface;
use reticulum::iface::tcp::{TcpClientConfig, TcpClientInterface};
use reticulum::transport::Transport;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::runtime::Runtime;
use tokio::sync::broadcast;
use tokio::sync::mpsc::UnboundedReceiver;

use android_log;
use log;

struct KaonicDestinationList {
    contact: Arc<Mutex<SingleInputDestination>>,
    chat: Arc<Mutex<SingleInputDestination>>,
}

struct KaonicState {
    context: GlobalRef,
    cmd_tx: tokio::sync::broadcast::Sender<KaonicCommand>,
    runtime: Arc<Runtime>,
}

#[derive(Copy, Clone)]
enum KaonicCommand {
    Stop,
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_libraryInit(env: JNIEnv) {
    android_log::init("Kaonic").unwrap();
    log::info!("kaonic library initialized");
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeInit(
    env: JNIEnv,
    _class: JClass,
    context: JObject,
) -> jlong {
    let context = env
        .new_global_ref(context)
        .expect("Failed to create global ref");

    let (cmd_tx, _) = tokio::sync::broadcast::channel::<KaonicCommand>(32);

    let runtime = Arc::new(Runtime::new().expect("Failed to create Tokio runtime"));

    let state = Box::new(KaonicState {
        context,
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
    _class: JClass,
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

    log::debug!("parse id  {}", identity_hex);

    // Convert hex string into PrivateIdentity
    match PrivateIdentity::new_from_hex_string(&identity_hex) {
        Ok(identity) => {
            log::debug!("start reticulum for {}", identity.address_hash());

            state
                .runtime
                .spawn(reticulum_task(identity, state.cmd_tx.subscribe()));
        }
        Err(_) => log::error!("can't create private identity"),
    }
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeGenerateIdentity(
    env: JNIEnv,
    _class: JClass,
    _ptr: jlong,
) -> jstring {
    // Generate new identity
    let identity = PrivateIdentity::new_from_rand(OsRng);

    env.new_string(identity.to_hex_string()).unwrap().into_raw()
}

async fn reticulum_task(identity: PrivateIdentity, mut cmd_rx: broadcast::Receiver<KaonicCommand>) {
    log::info!("start reticulum task");

    let mut transport = Transport::new();

    let destination_list = KaonicDestinationList {
        contact: transport
            .add_destination(identity.clone(), DestinationName::new("kaonic", "contact")),
        chat: transport
            .add_destination(identity.clone(), DestinationName::new("kaonic", "chat")),
    };

    let _client = KaonicGrpcInterface::start(
        reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcConfig {
            addr: "http://192.168.1.118:8080".into(),
            module: reticulum::iface::kaonic::RadioModule::RadioA,
        },
        transport.packet_channel(),
    );

    let mut announce_interval = tokio::time::interval(Duration::from_secs(10));

    loop {
        tokio::select! {
            cmd = cmd_rx.recv() => {
                // TODO:
            }
            _ = announce_interval.tick() => {
                log::trace!("announce");
                transport.announce(&destination_list.contact.lock().unwrap(), None).unwrap();
            }
        };
    }
}
