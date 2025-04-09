package com.volla.cell.kaonic

import android.annotation.SuppressLint
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.audiofx.AcousticEchoCanceler
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel


@RequiresApi(Build.VERSION_CODES.O)
@SuppressLint("MissingPermission")
class AndroidAudio(private val context: Context) {

    private val SAMPLE_RATE: Int = 8000
    private val CHANNEL_IN: Int = AudioFormat.CHANNEL_IN_MONO
    private val CHANNEL_OUT: Int = AudioFormat.CHANNEL_OUT_MONO
    private val AUDIO_ENCODING: Int = AudioFormat.ENCODING_PCM_16BIT

    private val audioRecord: AudioRecord
    private val audioTrack: AudioTrack
    private var echoCanceler: AcousticEchoCanceler? = null
    private val bufferSize: Int
    private var isRecording = false
    private var isPlaying = false
    private var circularBuffer: CircularBuffer

    private var recordingThread: Thread? = null
    private var playingThread: Thread? = null

    var eventSink: EventChannel.EventSink? = null

    init {
        bufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_IN, AUDIO_ENCODING)

        circularBuffer = CircularBuffer(bufferSize * 16);

        // Configure AudioRecord for capturing audio input
        audioRecord = AudioRecord.Builder()
            .setAudioSource(MediaRecorder.AudioSource.MIC)
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(SAMPLE_RATE)
                    .setEncoding(AUDIO_ENCODING)
                    .setChannelMask(CHANNEL_IN)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize * 16)
            .build()


        // Configure AudioTrack for playback
        audioTrack = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(SAMPLE_RATE)
                    .setEncoding(AUDIO_ENCODING)
                    .setChannelMask(CHANNEL_OUT)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize * 32)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
            .build()

        Log.d(TAG, "instance created")
    }

    fun startPlaying() {
        if (audioTrack.state != AudioTrack.STATE_INITIALIZED) {
            Log.e(TAG, "AudioTrack initialization failed")
            return
        }

        audioTrack.play()
        isPlaying = true

        playingThread = Thread({ writeAudioData() }, "AudioPlayer Thread")
        playingThread!!.start()

        Log.d(TAG, "start playing");
    }

    fun stopPlaying() {
        Log.d(TAG, "stop playing");

        if (audioTrack.state == AudioTrack.STATE_INITIALIZED) {
            audioTrack.stop()
        }

        isPlaying = false

        if (playingThread != null) {
            try {
                playingThread!!.join()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
            playingThread = null
        }
    }

    fun play(data: ByteArray?, length: Int) {
        circularBuffer.write(data!!, 0, length);
        // audioTrack.write(data!!, 0, length);
    }

    fun startRecording() {
        Log.d(TAG, "start recording");
        if (audioRecord.state != AudioRecord.STATE_INITIALIZED) {
            Log.e(TAG, "AudioRecord initialization failed")
            return
        }

        audioRecord.startRecording()
        isRecording = true

        recordingThread = Thread({ readAudioData() }, "AudioRecorder Thread")

        recordingThread!!.start()
    }

    private fun writeAudioData() {
        val audioBuffer = ByteArray(bufferSize * 2)

        while (isPlaying) {
            if (circularBuffer.hasSufficientData(audioBuffer.size)) {
                val read = circularBuffer.read(audioBuffer, 0, audioBuffer.size);
                if (read > 0) {
                    audioTrack.write(audioBuffer, 0, read);
                }
            }
        }
    }

    private fun readAudioData() {

        val audioBuffer = ByteArray(bufferSize)

        while (isRecording) {
            val read = audioRecord.read(audioBuffer, 0, audioBuffer.size)

            if (read > 0) {
                Handler(Looper.getMainLooper()).post {
                    val resultData: HashMap<String, Any> = HashMap()
                    resultData["count"] = read
                    resultData["data"] = audioBuffer
                    eventSink?.success(resultData)
                }
            }
        }
    }

    fun stopRecording() {
        Log.d(TAG, "stop recording");

        if (audioRecord.state == AudioRecord.STATE_INITIALIZED) {
            audioRecord.stop()
        }

        isRecording = false

        if (recordingThread != null) {
            try {
                recordingThread!!.join()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
            recordingThread = null
        }
    }

    companion object {
        private const val TAG = "AndroidAudio"
    }
}
