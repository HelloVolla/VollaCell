package network.beechat.app.kaonic

import android.os.Bundle
import androidx.annotation.Keep
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import network.beechat.app.kaonic.Kaonic

class MainActivity : FlutterActivity() {
    private lateinit var kaonic: Kaonic

    private var serial: AndroidSerial? = null
    private val CHANNEL = "com.example.kaonic/kaonic"
    private val rxBuffer = ByteArray(2048)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        kaonic = Kaonic(this)
        serial = AndroidSerial(this)


        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enumerateDevices" -> result.success(enumerateDevices())
                "openDevice" -> {
                    val deviceName = call.argument<String>("deviceName")
                    if (deviceName == null) result.success(false)

                    result.success(openSerial(deviceName!!))
                }

                "closeDevice" -> {
//                    closeKaonicDevice();
//                    closeSerial();

                    result.success(true)
                }

                "kaonicTransmit" -> {
                    val data = call.argument<ByteArray>("data")
//                    val rc = kaonicTransmit(
//                        data!!,
//                        call.argument<Int>("rfIndex")!!,
//                        call.argument<Int>("trxType")!!
//                    )
//                    result.success(rc)
                }

                "kaonicReceive" -> {

//                    val rc = kaonicReceive(
//                        this.rxBuffer,
//                        call.argument<Int>("rfIndex")!!,
//                        call.argument<Int>("trxType")!!,
//                        call.argument<Int>("timeout")!!
//                    )
//
//                    val resultData: HashMap<String, Any> = HashMap()
//                    resultData["count"] = rc
//                    resultData["data"] = this.rxBuffer
//                    result.success(resultData)
                }

                "kaonicConfigure" -> {

//                    val rc = kaonicConfigure(
//                        call.argument<Int>("rfIndex")!!,
//                        call.argument<Int>("freq")!!,
//                        call.argument<Int>("channel")!!,
//                        call.argument<Int>("spacing")!!
//                    )
//
//                    result.success(rc)
                }
            }
        }
        
    }

    private fun enumerateDevices(): ArrayList<String> {
        return ArrayList(AndroidSerial.enumerateDevices(this).asList())
    }

    fun openSerial(deviceName: String): Boolean {
        val opened = serial!!.open(deviceName)
//        openKaonicDevice()
        return opened
    }

    fun closeSerial() {
//        closeKaonicDevice()
        serial!!.close()
    }


    @Keep
    fun write(data: ByteArray?, len: Int): Int {
        return serial!!.write(data, len)
    }
    @Keep
    fun read(data: ByteArray?, maxlen: Int): Int {
        return serial!!.read(data, maxlen)
    }
}

