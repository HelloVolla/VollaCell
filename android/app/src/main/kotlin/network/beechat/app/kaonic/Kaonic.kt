package network.beechat.app.kaonic

import android.content.Context

class Kaonic(context: Context) {
    private val nativePtr: Long

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
