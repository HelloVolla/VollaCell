package network.beechat.app.kaonic

import android.content.Context
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.util.Log
import com.hoho.android.usbserial.driver.CdcAcmSerialDriver
import com.hoho.android.usbserial.driver.ProbeTable
import com.hoho.android.usbserial.driver.UsbSerialPort
import com.hoho.android.usbserial.driver.UsbSerialProber
import java.io.IOException

class AndroidSerial(private val context: Context) {

    private var usbSerialPort: UsbSerialPort? = null
    private val usbSerialProber: UsbSerialProber

    init {
        val customTable = ProbeTable()
        customTable.addProduct(0x0011, 0x4EB1, CdcAcmSerialDriver::class.java)

        this.usbSerialProber = UsbSerialProber(customTable)

        Log.d(TAG, "instance created")
    }

    fun open(deviceName: String): Boolean {
        Log.d(TAG, "open device: $deviceName")


        val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        var device: UsbDevice? = null

        for (v in usbManager.deviceList.values) {
            if (deviceName == v.deviceName) {
                device = v
                break
            }
        }

        if (device == null) {
            Log.e(TAG, "device $deviceName not found")
            return false
        }


        val driver = usbSerialProber.probeDevice(device)
        if (driver == null) {
            Log.e(TAG, "device driver not found")
            return false
        }

        if (driver.ports.size == 0) {
            Log.e(TAG, "device missing ports")
            return false
        }

        usbSerialPort = driver.ports[0]

        val usbConnection = usbManager.openDevice(driver.device)
        if (usbConnection == null) {
            Log.e(TAG, "device usb connection error")
            return false
        }

        try {
            usbSerialPort?.open(usbConnection)

            try {
                usbSerialPort?.setParameters(4000000, 8, 1, UsbSerialPort.PARITY_NONE)
            } catch (e: UnsupportedOperationException) {
                Log.e(TAG, "device usb serial error")
            }
        } catch (e: Exception) {
            Log.e(TAG, "device open error")
            return false
        }

        return true
    }

    fun close() {
        try {
            if (usbSerialPort != null) {
                usbSerialPort!!.close()
            }
        } catch (ignored: IOException) {
        }

        usbSerialPort = null
    }

    fun write(data: ByteArray?, len: Int): Int {
        try {
            usbSerialPort!!.write(data, len, WRITE_WAIT_MILLIS)
            return len
        } catch (e: IOException) {
            Log.e(TAG, "write error")
            return -1
        }
    }

    fun read(data: ByteArray?, maxlen: Int): Int {
        try {
            return usbSerialPort!!.read(data, maxlen, READ_WAIT_MILLIS)
        } catch (e: IOException) {
            Log.e(TAG, e.message.toString())
            return -1
        }
    }

    companion object {
        private const val TAG = "AndroidSerial"

        private const val WRITE_WAIT_MILLIS = 500
        private const val READ_WAIT_MILLIS = 500

        fun enumerateDevices(context: Context): Array<String> {
            val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
            val devices: MutableList<String> = ArrayList()

            for (v in usbManager.deviceList.values) {
                val deviceName = v.deviceName
                Log.d(TAG, "device found: $deviceName")
                devices.add(deviceName)
            }

            return devices.toTypedArray<String>()
        }
    }
}