package network.beechat.app.kaonic

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

    @Keep
    fun announce(identity: String, address: String) {
        Log.d("Kaonic", "Found Identity: " + address)

        Handler(Looper.getMainLooper()).post {
            val resultData: HashMap<String, Any> = HashMap()
            resultData["type"] = "ANNOUNCE"
            resultData["address"] = address
            eventSink?.success(resultData)
        }
    }

    private external fun nativeInit(context: Context): Long
    private external fun nativeDestroy(ptr: Long)
    private external fun nativeStart(ptr: Long, identity: String)
    private external fun nativeStop(ptr: Long)
    private external fun nativeGenerateIdentity(ptr: Long): String

    companion object {
        init {
            System.loadLibrary("kaonic")
            libraryInit()
        }

        @JvmStatic external fun libraryInit()
    }
}
