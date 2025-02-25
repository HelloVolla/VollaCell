use jni::JNIEnv;
use jni::objects::{GlobalRef, JClass, JObject};
use jni::sys::jlong;
use tokio::runtime::Runtime;
use std::sync::Arc;

use log;
use android_log;

// Struct to hold our custom fields
pub struct KaonicState {
   
    context: GlobalRef,
    runtime: Arc<Runtime>,
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_libraryInit(
    env: JNIEnv,
)  {
    android_log::init("Kaonic").unwrap();
    log::info!("kaonic library initialized");
}

#[no_mangle]
pub extern "system" fn Java_network_beechat_app_kaonic_Kaonic_nativeInit(
    env: JNIEnv,
    _class: JClass,
    context: JObject,
) -> jlong {

  
    let context = env.new_global_ref(context).expect("Failed to create global ref");
    
    let runtime = Arc::new(
        Runtime::new().expect("Failed to create Tokio runtime")
    );

    let state = Box::new(KaonicState {
        context,
        runtime
    });
    
    state.runtime.spawn(async {
    
    loop {
        log::info!("working");
        
        tokio::time::sleep(std::time::Duration::from_secs(1)).await;
    }
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
