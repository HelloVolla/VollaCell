package network.beechat.app.kaonic

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.Keep
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import network.beechat.app.kaonic.Kaonic

class MainActivity : FlutterActivity() {
    private lateinit var kaonic: Kaonic

    private var serial: AndroidSerial? = null
    private val CHANNEL = "com.example.kaonic/kaonic"
    private val rxBuffer = ByteArray(2048)

    private val CHANNEL_EVENT = "com.example.kaonic/audioStream"
    private var eventSink: EventChannel.EventSink? = null
    private var androidAudio: AndroidAudio? = null

    external fun initKaonicLib(context: Context)
    external fun openKaonicDevice()
    external fun closeKaonicDevice()

    external fun kaonicTransmit(data: ByteArray): Int
    external fun kaonicReceive(data: ByteArray, timeout: Int): Int

    external fun kaonicConfigure(rfIndex: Int, freq: Int, channel: Int, spacing: Int): Int

    external fun codec2Encode(input: ByteArray): ByteArray
    external fun codec2Decode(input: ByteArray): ByteArray

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        kaonic = Kaonic(this)
        serial = AndroidSerial(this)

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED
        ) {
            // Request permission
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                1
            )
        }


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
                    closeKaonicDevice();
                    closeSerial();

                    result.success(true)
                }

                "codecEncode" -> {
                    result.success(codec2Encode(call.argument<ByteArray>("data")!!))
                }

                "codecDecode" -> {
                    result.success(codec2Decode(call.argument<ByteArray>("data")!!))
                }

                "kaonicTransmit" -> {
                    val data = call.argument<ByteArray>("data")
                    val rc = kaonicTransmit(
                        data!!
                    )
                    result.success(rc)
                }

                "kaonicReceive" -> {
                    val rc = kaonicReceive(
                        this.rxBuffer,
                        call.argument<Int>("timeout")!!
                    )

                    val resultData: HashMap<String, Any> = HashMap()
                    resultData["count"] = rc
                    resultData["data"] = this.rxBuffer
                    result.success(resultData)
                }

                "kaonicConfigure" -> {

                    val rc = kaonicConfigure(
                        call.argument<Int>("rfIndex")!!,
                        call.argument<Int>("freq")!!,
                        call.argument<Int>("channel")!!,
                        call.argument<Int>("spacing")!!
                    )

                    result.success(rc)
                }
                "startAudio"->{
                    androidAudio?.startPlaying()
                    androidAudio?.startRecording()
                    result.success(0)
                }
                "stopAudio"->{
                    androidAudio?.stopRecording()
                    androidAudio?.stopPlaying()
                    result.success(0)
                }
                "feedPlayer"->{
                    val data = call.argument<ByteArray>("data")
                    androidAudio?.play(data,data?.size?:0)
                    result.success(0)
                }
            }
        }

        androidAudio = AndroidAudio(context)
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL_EVENT)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        androidAudio?.eventSink = events

                    }

                    override fun onCancel(arguments: Any?) {
                        androidAudio?.eventSink = null
                    }
                }
            )
        
    }

    private fun enumerateDevices(): ArrayList<String> {
        return ArrayList(AndroidSerial.enumerateDevices(this).asList())
    }

    fun openSerial(deviceName: String): Boolean {
        val opened = serial!!.open(deviceName)
        openKaonicDevice()
        return opened
    }

    fun closeSerial() {
        closeKaonicDevice()
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

