use jni::objects::{GlobalRef, JClass, JObject};
use jni::sys::jlong;
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
use tokio::sync::mpsc::UnboundedReceiver;

use android_log;
use log;

struct KaonicDestinationList {
    contact: Arc<Mutex<SingleInputDestination>>,
}

struct KaonicState {
    context: GlobalRef,
    cmd_tx: tokio::sync::mpsc::UnboundedSender<KaonicCommand>,
    runtime: Arc<Runtime>,
}

enum KaonicCommand {}

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

    let (cmd_tx, cmd_rx) = tokio::sync::mpsc::unbounded_channel::<KaonicCommand>();

    let runtime = Arc::new(Runtime::new().expect("Failed to create Tokio runtime"));

    let state = Box::new(KaonicState {
        context,
        cmd_tx,
        runtime,
    });

    state.runtime.spawn(reticulum_task(cmd_rx));

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
    _env: JNIEnv,
    _class: JClass,
    ptr: jlong,
) {
    // Safety: ptr must be a valid pointer created by nativeInit
    let state = unsafe { &*(ptr as *const KaonicState) };
    
}


async fn reticulum_task(mut cmd_rx: UnboundedReceiver<KaonicCommand>) {
    log::info!("start reticulum task");

    let identity = PrivateIdentity::new_from_name("test");

    let mut transport = Transport::new();

    let destination_list = KaonicDestinationList {
        contact: transport
            .add_destination(identity.clone(), DestinationName::new("kaonic", "contact")),
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
                let _ = transport.announce(&destination_list.contact.lock().unwrap(), None);
            }
        };
    }
}
