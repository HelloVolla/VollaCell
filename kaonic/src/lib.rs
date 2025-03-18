use jni::objects::{GlobalRef, JByteArray, JClass, JMethodID, JObject, JString, JValue};
use jni::signature::{Primitive, ReturnType};
use jni::sys::{jlong, jstring};
use jni::{JNIEnv, JavaVM};
use rand_core::OsRng;
use reticulum::destination::link::{LinkEvent, LinkPayload};
use reticulum::destination::{DestinationName, SingleInputDestination};
use reticulum::hash::AddressHash;
use reticulum::identity::PrivateIdentity;
use reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcInterface;
use reticulum::transport::Transport;
use std::sync::Arc;
use std::time::Duration;
use tokio::runtime::{self, Runtime};
use tokio::sync::{broadcast, mpsc, Mutex};

use android_log;
use log::{self, LevelFilter};

struct KaonicDestinationList {
    contact: Arc<Mutex<SingleInputDestination>>,
}

#[derive(Clone)]
struct KaonicJni {
    _context: GlobalRef,
    announce_method: JMethodID,
    receive_method: JMethodID,
}

struct KaonicState {
    jni: KaonicJni,
    cmd_tx: tokio::sync::mpsc::Sender<KaonicCommand>,
    cmd_rx: Arc<Mutex<tokio::sync::mpsc::Receiver<KaonicCommand>>>,
    runtime: Arc<Runtime>,
}

#[derive(Clone)]
struct KaonicMessage {
    address_hash: AddressHash,
    payload: LinkPayload,
}

#[derive(Clone)]
enum KaonicCommand {
    Message(KaonicMessage),
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_libraryInit(_env: JNIEnv) {
    android_log::init("kaonic").unwrap();
    log::set_max_level(LevelFilter::Debug);
    log::info!("kaonic library initialized");
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeInit(
    mut env: JNIEnv,
    obj: JObject,
    context: JObject,
) -> jlong {
    let (cmd_tx, cmd_rx) = tokio::sync::mpsc::channel::<KaonicCommand>(1);

    let runtime = Arc::new(
        runtime::Builder::new_multi_thread()
            .worker_threads(24)
            .enable_all()
            .build()
            .expect("tokio runtime"),
    );

    let jni = {
        let class = env.get_object_class(obj).expect("object class");

        let announce_method = env
            .get_method_id(
                &class,
                "announce",
                "(Ljava/lang/String;Ljava/lang/String;)V",
            )
            .expect("announce method");

        let receive_method = env
            .get_method_id(
                &class,
                "receive",
                "(Ljava/lang/String;Ljava/lang/String;[B)V",
            )
            .expect("receive method");

        KaonicJni {
            _context: env
                .new_global_ref(context)
                .expect("Failed to create global ref"),
            announce_method,
            receive_method,
        }
    };

    let state = Box::new(KaonicState {
        jni,
        cmd_tx,
        cmd_rx: Arc::new(Mutex::new(cmd_rx)),
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
                state.cmd_rx.clone(),
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

    let destination =
        SingleInputDestination::new(identity.clone(), DestinationName::new("kaonic", "contact"));

    let key = identity.to_hex_string() + &destination.desc.address_hash.to_hex_string();

    env.new_string(&key).unwrap().into_raw()
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeTransmit(
    mut env: JNIEnv,
    _obj: JObject,
    ptr: jlong,
    address: JString,
    payload: JByteArray,
) {
    let state = unsafe { &*(ptr as *const KaonicState) };

    let addr: String = match env.get_string(&address) {
        Ok(jstr) => jstr.into(),
        Err(_) => "".into(),
    };

    let addr = AddressHash::new_from_hex_string(&addr).unwrap();

    let payload_vec: Vec<u8> = match env.convert_byte_array(payload) {
        Ok(bytes) => bytes,
        Err(_) => vec![],
    };

    let _ = state
        .cmd_tx
        .blocking_send(KaonicCommand::Message(KaonicMessage {
            address_hash: addr,
            payload: LinkPayload::new_from_vec(&payload_vec),
        }));
}

async fn reticulum_task(
    identity: PrivateIdentity,
    cmd_rx: Arc<Mutex<mpsc::Receiver<KaonicCommand>>>,
    jvm: Arc<JavaVM>,
    obj: GlobalRef,
    jni: KaonicJni,
) {
    log::info!("start reticulum task");

    let mut transport = Transport::new();

    let destination_list = KaonicDestinationList {
        contact: transport
            .add_destination(identity.clone(), DestinationName::new("kaonic", "contact"))
            .await,
    };

    log::info!("> identity: {}", identity.address_hash());
    log::info!(
        "> contact: {}",
        destination_list.contact.lock().await.desc.address_hash
    );

    let _client = KaonicGrpcInterface::start(
        reticulum::iface::kaonic::kaonic_grpc::KaonicGrpcConfig {
            // TODO: update host
            // addr: "http://192.168.1.66:8080".into(),
            // addr: "http://192.168.0.123:8080".into(),
            addr: "http://192.168.72.1:8080".into(),
            module: reticulum::iface::kaonic::RadioModule::RadioA,
        },
        transport.channel().await,
    );

    let transport = Arc::new(Mutex::new(transport));

    let cmd_task = {
        let transport = transport.clone();
        tokio::spawn(async move {
            let cmd_rx = cmd_rx.clone();
            let mut cmd_rx = cmd_rx.lock().await;
            loop {
                tokio::select! {
                    Some(cmd) = cmd_rx.recv() => {
                        let transport = transport.lock().await;
                        match cmd {
                            KaonicCommand::Message(msg) => {
                                log::debug!("kaonic: send message to {}", msg.address_hash);
                                transport.send_to_out_links(&msg.address_hash, msg.payload.as_slice()).await;
                            }
                        }
                    }
                }
            }
        })
    };

    let contact_address = destination_list
        .contact
        .lock()
        .await
        .desc
        .address_hash
        .to_hex_string();

    let in_link_task = {
        let jvm = jvm.clone();
        let obj = obj.clone();
        let transport = transport.clone();
        tokio::spawn(async move {
            let mut in_link_events = transport.lock().await.in_link_events();
            loop {
                tokio::select! {
                    Ok(event_data) = in_link_events.recv() => {
                        match event_data.event {
                            LinkEvent::Data(data)=> {

                                let mut env = jvm
                                    .attach_current_thread_permanently()
                                    .expect("failed to attach thread");

                                let dst_address = env
                                .new_string(&contact_address)
                                .unwrap();

                                let src_address = env
                                .new_string(event_data.address_hash.to_hex_string())
                                .unwrap();

                                let packet = env
                                .new_byte_array(data.len() as i32)
                                .unwrap();

                                let buffer: &[i8] = unsafe { std::mem::transmute(data.as_slice()) };

                                env.set_byte_array_region(&packet, 0, buffer).expect("byte array with data");

                                let arguments = [JValue::Object(&dst_address).as_jni(),
                                                 JValue::Object(&src_address).as_jni(),
                                                 JValue::Object(&packet).as_jni()];
                                unsafe { env.call_method_unchecked(&obj, jni.receive_method, ReturnType::Primitive(Primitive::Void), &arguments[..]).unwrap() };
                            },
                            LinkEvent::Activated => {
                                log::info!("kaonic: input link {} activated", event_data.address_hash);
                            },
                            LinkEvent::Closed => {
                                log::warn!("kaonic: input link {} closed", event_data.address_hash);
                            },
                        }
                    }
                }
            }
        })
    };

    let destination_task = {
        let transport = transport.clone();
        let jvm = jvm.clone();
        let mut announce_interval = tokio::time::interval(Duration::from_secs(10));
        let mut announces = transport.lock().await.recv_announces().await;

        tokio::spawn(async move {
            loop {
                tokio::select! {
                    Ok(out_destination) = announces.recv() => {
                        let destination = out_destination.lock().await;
                        // TODO: check if destination is compatible

                        let transport = transport.lock().await;

                        log::trace!("kaonic: attach link to {}", destination.desc.address_hash);
                        let _ = transport.link(destination.desc).await;

                        let mut env = jvm
                            .attach_current_thread_permanently()
                            .expect("failed to attach thread");

                        let identity = env
                            .new_string(destination.identity.to_hex_string())
                            .unwrap();

                        let address = env
                            .new_string(destination.desc.address_hash.to_hex_string())
                            .unwrap();

                        let arguments = [JValue::Object(&identity).as_jni(), JValue::Object(&address).as_jni()];

                        unsafe { env.call_method_unchecked(&obj, jni.announce_method, ReturnType::Primitive(Primitive::Void), &arguments[..]).unwrap() };
                    }
                    _ = announce_interval.tick() => {
                    }
                };
            }
        })
    };

    let announce_task = tokio::spawn(async move {
        loop {
            // Send announce
            {
                let announce = destination_list
                    .contact
                    .lock()
                    .await
                    .announce(OsRng, None)
                    .unwrap();

                log::debug!("kaonic: send announce");
                transport.lock().await.send(announce).await;
            }

            tokio::time::sleep(Duration::from_secs(5)).await;
        }
    });

    destination_task.await.unwrap();
    announce_task.await.unwrap();
    cmd_task.await.unwrap();
    in_link_task.await.unwrap();
}
