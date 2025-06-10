package network.beechat.app.kaonic

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.annotation.Keep
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import network.beechat.app.kaonic.Kaonic
import network.beechat.app.kaonic.services.KaonicService
import network.beechat.app.kaonic.services.SecureStorageHelper
import network.beechat.kaonic.communication.KaonicCommunicationManager
import network.beechat.kaonic.impl.KaonicLib

class MainActivity : FlutterActivity() {
    companion object {
        private const val REQUEST_RECORD_AUDIO_PERMISSION = 200
        private const val REQUEST_STORAGE_PERMISSION = 201
    }

    private lateinit var kaonic: Kaonic
    lateinit var secureStorageHelper: SecureStorageHelper



    private var serial: AndroidSerial? = null
    private val CHANNEL = "network.beechat.app.kaonic/kaonic"
    private val rxBuffer = ByteArray(2048)

    private val CHANNEL_EVENT = "network.beechat.app.kaonic/audioStream"
    private val KAONIC_EVENT = "network.beechat.app.kaonic/packetStream"
    private var eventSink: EventChannel.EventSink? = null
    private var androidAudio: AndroidAudio? = null



    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        secureStorageHelper = SecureStorageHelper(applicationContext)
        kaonic = Kaonic(this)
        serial = AndroidSerial(this)


        checkAudioPermission()

//        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
//            != PackageManager.PERMISSION_GRANTED
//        ) {
//            // Request permission
//            ActivityCompat.requestPermissions(
//                this,
//                arrayOf(Manifest.permission.RECORD_AUDIO),
//                1
//            )
//        }else{
//            initAudio()
//        }


        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendTextMessage" -> {
                    val textMessage = call.argument<String>("message") ?: ""
                    val address = call.argument<String>("address") ?: ""
                    val chatId = call.argument<String>("chatId") ?: ""

                    KaonicService.sendTextMessage(textMessage, address, chatId)
                }
                "sendFileMessage" -> {
                    val filePath = call.argument<String>("filePath") ?: ""
                    val address = call.argument<String>("address") ?: ""
                    val chatId = call.argument<String>("chatId") ?: ""

                    KaonicService.sendFileMessage(filePath, address, chatId)
                }
                "enumerateDevices" -> result.success(enumerateDevices())
                "openDevice" -> {
                    val deviceName = call.argument<String>("deviceName")
                    if (deviceName == null) result.success(false)

                    result.success(openSerial(deviceName!!))
                }

                "closeDevice" -> {
                    closeSerial();

                    result.success(true)
                }

                "kaonicTransmit" -> {
                    val address = call.argument<String>("address")
                    val data = call.argument<ByteArray>("data")
                    kaonic.transmit(address!!, data!!)
                    result.success(0)
                }

                "kaonicConfigure" -> {
                    val config = call.argument<String>("config")
                    kaonic.configure(config!!)
                    result.success(0)
                }

                "startAudio"->{
                    Log.d("Main", "start audio");
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
                "generateKey"->{
                    result.success(kaonic.generateIdentity())
                }
                "userStart"->{
                    val key = call.argument<String>("key")
                    key?.let{
                        kaonic.start(key)
                    }
                    result.success(0)
                }
            }
        }


        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, KAONIC_EVENT)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        kaonic.eventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        kaonic.eventSink = null
                    }
                }
            )
    }

    private fun enumerateDevices(): ArrayList<String> {
        return ArrayList(AndroidSerial.enumerateDevices(this).asList())
    }

    fun openSerial(deviceName: String): Boolean {
        val opened = serial!!.open(deviceName)
        return opened
    }

    fun closeSerial() {
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

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if(requestCode==1 && grantResults.isNotEmpty()){
            initAudio()
        }
    }

    private fun initAudio(){
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



    private fun checkAudioPermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                REQUEST_RECORD_AUDIO_PERMISSION
            )
        } else {
            initKaonicService()
        }
    }


    private fun initKaonicService() {
        checkStoragePermission()
        KaonicService.init(
            KaonicCommunicationManager(
                KaonicLib.getInstance(applicationContext),
                contentResolver
            ),
            secureStorageHelper
        )
    }

    private fun checkStoragePermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_STORAGE_PERMISSION
            )
        }
    }
}

