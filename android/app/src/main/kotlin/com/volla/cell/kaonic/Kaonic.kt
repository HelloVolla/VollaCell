package com.volla.cell.kaonic

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.Keep
import android.util.Log
import io.flutter.plugin.common.EventChannel

class Kaonic(context: Context) {
    private val nativePtr: Long

    var eventSink: EventChannel.EventSink? = null

    init {
        nativePtr = nativeInit(context)
    }

    protected fun finalize() {
        if (nativePtr != 0L) {
            nativeDestroy(nativePtr)
        }
    }

    public fun generateIdentity(): String {
        return nativeGenerateIdentity(nativePtr)
    }

    public fun start(identity: String) {
        return nativeStart(nativePtr, identity)
    }


    public fun transmit(address: String, data: ByteArray) {
        nativeTransmit(nativePtr, address, data);
    }

    @Keep
    fun announce(identity: String, srcAddress: String) {
        Log.d("Kaonic", "Found Identity: " + srcAddress)

        Handler(Looper.getMainLooper()).post {
            val resultData: HashMap<String, Any> = HashMap()
            resultData["type"] = "ANNOUNCE"
            resultData["srcAddress"] = srcAddress
            resultData["identity"] = identity
            eventSink?.success(resultData)
        }
    }

    @Keep
    fun receive(dstAddress: String, srcAddress: String, data: ByteArray) {
        Handler(Looper.getMainLooper()).post {
            val resultData: HashMap<String, Any> = HashMap()
            resultData["type"] = "PACKET"
            resultData["srcAddress"] = srcAddress
            resultData["dstAddress"] = dstAddress
            resultData["data"] = data
            eventSink?.success(resultData)
        }
    }

    private external fun nativeInit(context: Context): Long
    private external fun nativeDestroy(ptr: Long)
    private external fun nativeStart(ptr: Long, identity: String)
    private external fun nativeStop(ptr: Long)
    private external fun nativeGenerateIdentity(ptr: Long): String
    private external fun nativeTransmit(ptr: Long, address: String, payload: ByteArray)

    companion object {
        init {
            System.loadLibrary("kaonic")
            libraryInit()
        }

        @JvmStatic external fun libraryInit()
    }
}
