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


    private val KAONIC_SERVICE_EVENT = "network.beechat.app.kaonic.service/packetStream"



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
                    try {
                        val textMessage = call.argument<String>("message") ?: ""
                        val address = call.argument<String>("address") ?: ""
                        val chatId = call.argument<String>("chatId") ?: ""

                        KaonicService.sendTextMessage(textMessage, address, chatId)

                        result.success(0)
                    }  catch (ex: Exception){
                        Log.d("sendTextMessageError", ex.toString())
                        result.error("sendTextMessageError", ex.message, "")
                    }
                }
                "sendFileMessage" -> {
                    try {
                        val filePath = call.argument<String>("filePath") ?: ""
                        val address = call.argument<String>("address") ?: ""
                        val chatId = call.argument<String>("chatId") ?: ""

                        KaonicService.sendFileMessage(filePath, address, chatId)

                        result.success(0)
                    }  catch (ex: Exception){
                        Log.d("sendFileMessage", ex.toString())
                        result.error("sendFileMessage", ex.message, "")
                    }
                }
                "sendConfigure" -> {
                    try {
                        val mcs = call.argument<Int>("mcs") ?: 0
                        val optionNumber = call.argument<Int>("optionNumber") ?: 0
                        val module = call.argument<Int>("module") ?: 0
                        val frequency = call.argument<Int>("frequency") ?: 0
                        val channel = call.argument<Int>("channel") ?: 0
                        val channelSpacing = call.argument<Int>("channelSpacing") ?: 0
                        val txPower = call.argument<Int>("txPower") ?: 0

                        KaonicService.sendConfig(mcs, optionNumber, module, frequency, channel, channelSpacing, txPower)

                        result.success(true)
                    }  catch (ex: Exception){
                        Log.d("sendConfigure", ex.toString())
                        result.error("sendConfigure", ex.message, "")
                    }
                }
                "createChat" -> {
                    try {
                        val address = call.argument<String>("address") ?: ""
                        val chatId = call.argument<String>("chatId") ?: ""

                        KaonicService.createChat(address, chatId)

                        result.success(0)
                    }  catch (ex: Exception){
                        Log.d("createChat", ex.toString())
                        result.error("createChat", ex.message, "")
                    }
                }


                // Legacy methods
                // Useless method
                "enumerateDevices" -> result.success(enumerateDevices())
                // Useless method
                "openDevice" -> {
                    val deviceName = call.argument<String>("deviceName")
                    if (deviceName == null) result.success(false)

                    result.success(openSerial(deviceName!!))
                }

                // Useless method
                "closeDevice" -> {
                    closeSerial();

                    result.success(true)
                }
                // old method (new sendText/sendFile)
                "kaonicTransmit" -> {
                    val address = call.argument<String>("address")
                    val data = call.argument<ByteArray>("data")
                    kaonic.transmit(address!!, data!!)
                    result.success(0)
                }
                // sendConfigure
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
                // load secret
                "generateKey"->{
                    result.success(kaonic.generateIdentity())
                }
                // useless
                "userStart"->{
                    val key = call.argument<String>("key")
                    key?.let{
                        kaonic.start(key)
                    }
                    result.success(0)
                }
            }
        }

        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, KAONIC_SERVICE_EVENT)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        KaonicService.eventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        KaonicService.eventSink = null
                    }
                }
            )

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

