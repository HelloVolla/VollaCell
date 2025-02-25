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

    private external fun nativeInit(context: Context): Long
    private external fun nativeDestroy(ptr: Long)

    companion object {
        init {
            System.loadLibrary("kaonic")
            libraryInit()
        }

        @JvmStatic external fun libraryInit()
    }
}
