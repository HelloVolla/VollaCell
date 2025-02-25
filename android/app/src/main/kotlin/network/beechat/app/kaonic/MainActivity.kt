package network.beechat.app.kaonic

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import network.beechat.app.kaonic.Kaonic

class MainActivity : FlutterActivity() {
    private lateinit var kaonic: Kaonic
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        kaonic = Kaonic(this)
    }
}

