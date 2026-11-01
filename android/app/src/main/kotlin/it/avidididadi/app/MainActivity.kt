package it.avidididadi.app

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.os.Build
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.contracts.ExerciseRouteRequestContract
import androidx.health.connect.client.records.ExerciseRoute
import androidx.health.connect.client.records.ExerciseRouteResult
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import java.util.Locale

// FlutterFragmentActivity: il pacchetto health chiede i permessi di Health Connect
// con registerForActivityResult, che richiede una ComponentActivity.
class MainActivity : FlutterFragmentActivity() {
    private var canale: MethodChannel? = null

    /** Generatore dei bip della modalità allenamento, creato al primo uso. */
    private var tono: ToneGenerator? = null

    /** Sintesi vocale dell'allenamento, creata alla prima frase. */
    private var tts: TextToSpeech? = null
    private var ttsPronta = false
    private val inAttesa = mutableListOf<String>()

    // La musica si abbassa mentre la voce parla, poi torna com'era.
    private val voceAudio = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()
    private val fuocoVoce by lazy {
        AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
            .setAudioAttributes(voceAudio)
            .build()
    }

    private fun inChiamata(): Boolean {
        val am = getSystemService(AUDIO_SERVICE) as AudioManager
        return am.mode == AudioManager.MODE_IN_CALL ||
            am.mode == AudioManager.MODE_IN_COMMUNICATION ||
            am.mode == AudioManager.MODE_RINGTONE
    }

    private fun parla(testo: String) {
        val t = tts
        if (t == null) {
            inAttesa.add(testo)
            tts = TextToSpeech(this) { stato ->
                ttsPronta = stato == TextToSpeech.SUCCESS
                val pronta = tts ?: return@TextToSpeech
                if (!ttsPronta) {
                    Log.w("Avidididadi", "sintesi vocale non disponibile")
                    inAttesa.clear()
                    return@TextToSpeech
                }
                pronta.language = Locale.ITALIAN
                pronta.setAudioAttributes(voceAudio)
                pronta.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(id: String?) {}
                    override fun onDone(id: String?) = rilascia(pronta)
                    @Deprecated("Deprecated in Java")
                    override fun onError(id: String?) = rilascia(pronta)
                })
                inAttesa.forEach { di(pronta, it) }
                inAttesa.clear()
            }
        } else if (ttsPronta) {
            di(t, testo)
        } else {
            inAttesa.add(testo)
        }
    }

    private fun di(t: TextToSpeech, testo: String) {
        (getSystemService(AUDIO_SERVICE) as AudioManager).requestAudioFocus(fuocoVoce)
        t.speak(testo, TextToSpeech.QUEUE_ADD, null, "voce-${System.nanoTime()}")
    }

    /** Finita l'ultima frase in coda, la musica torna al suo volume. */
    private fun rilascia(t: TextToSpeech) {
        if (!t.isSpeaking) {
            (getSystemService(AUDIO_SERVICE) as AudioManager).abandonAudioFocusRequest(fuocoVoce)
        }
    }

    override fun onDestroy() {
        tono?.release()
        tono = null
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }

    // Azione con cui è stata aperta l'app (es. Health Connect che chiede la privacy).
    private var azioneAvvio: String? = null

    // Testo condiviso dall'app dell'assistente con cui è stata aperta l'app.
    private var testoAvvio: String? = null

    // Consenso di Health Connect per il percorso di una sessione di un'altra app.
    private var attesaPercorso: MethodChannel.Result? = null
    private val richiestaPercorso = registerForActivityResult(ExerciseRouteRequestContract()) { route ->
        attesaPercorso?.success(route?.let { piatto(it) })
        attesaPercorso = null
    }

    // Permessi per il battito via Bluetooth (fascia o orologio che trasmette).
    private var attesaBluetooth: MethodChannel.Result? = null
    private val richiestaBluetooth =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { esiti ->
            attesaBluetooth?.success(esiti.values.all { it })
            attesaBluetooth = null
        }

    /** Da Android 12 bastano quelli del Bluetooth; prima serviva la posizione. */
    private fun permessiBluetooth() = if (Build.VERSION.SDK_INT >= 31) {
        arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
    } else {
        arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        azioneAvvio = azioneDi(intent)
        testoAvvio = testoDi(intent)
        canale = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "avidididadi/avvio").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "azioneAvvio" -> {
                        result.success(azioneAvvio)
                        azioneAvvio = null
                    }
                    "apriPermessiHc" -> {
                        apriPermessiHealthConnect()
                        result.success(null)
                    }
                    "titoliSessioni" -> leggiTitoli(call.argument<List<String>>("uuid").orEmpty(), result)
                    "testoCondiviso" -> {
                        result.success(testoAvvio)
                        testoAvvio = null
                    }
                    "condividi" -> {
                        val invio = Intent(Intent.ACTION_SEND)
                            .setType("text/plain")
                            .putExtra(Intent.EXTRA_TEXT, call.argument<String>("testo"))
                        startActivity(Intent.createChooser(invio, call.argument<String>("titolo")))
                        result.success(null)
                    }
                    "ricezioneAgente" -> {
                        packageManager.setComponentEnabledSetting(
                            ComponentName(this@MainActivity, ingressoAgente()),
                            if (call.arguments == true) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                            PackageManager.DONT_KILL_APP,
                        )
                        result.success(null)
                    }
                    "dettagliSessione" -> leggiDettagli(call.arguments as String, result)
                    "percorsoSessione" -> leggiPercorso(call.arguments as String, result)
                    "chiediPercorso" -> {
                        attesaPercorso?.success(null)
                        attesaPercorso = result
                        try {
                            richiestaPercorso.launch(call.arguments as String)
                        } catch (e: Exception) {
                            Log.w("Avidididadi", "Health Connect: consenso percorso non disponibile: $e")
                            attesaPercorso = null
                            result.success(null)
                        }
                    }
                    "permessoBluetooth" -> {
                        val servono = permessiBluetooth()
                        if (servono.all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }) {
                            result.success(true)
                        } else {
                            attesaBluetooth?.success(false)
                            attesaBluetooth = result
                            richiestaBluetooth.launch(servono)
                        }
                    }
                    // Il widget della schermata home: dati preparati dall'app.
                    "aggiornaWidget" -> {
                        WidgetOggi.salva(this@MainActivity, call.arguments as String)
                        result.success(null)
                    }
                    // Durante la modalità allenamento lo schermo non si spegne.
                    "schermoAcceso" -> {
                        if (call.arguments == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    // Bip degli ultimi secondi: sul volume dei media, così si
                    // sente anche con la suoneria silenziosa e sopra la musica.
                    "bip" -> {
                        try {
                            val t = tono ?: ToneGenerator(AudioManager.STREAM_MUSIC, 90)
                                .also { tono = it }
                            if (call.arguments == true) {
                                t.startTone(ToneGenerator.TONE_PROP_BEEP2, 450)
                            } else {
                                t.startTone(ToneGenerator.TONE_PROP_BEEP, 150)
                            }
                        } catch (e: RuntimeException) {
                            Log.w("Avidididadi", "bip non riuscito", e)
                        }
                        result.success(null)
                    }
                    // Voce dell'allenamento. Durante una chiamata non parla e
                    // lo dice, così l'app ritenta a chiamata finita.
                    "parla" -> {
                        if (inChiamata()) {
                            result.success("chiamata")
                        } else {
                            parla(call.arguments as String)
                            result.success("parlato")
                        }
                    }
                    // Vibrazione degli ultimi secondi: diretta, così funziona
                    // anche con la vibrazione al tocco spenta nel telefono.
                    "vibra" -> {
                        val v = if (Build.VERSION.SDK_INT >= 31) {
                            (getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                                .defaultVibrator
                        } else {
                            @Suppress("DEPRECATION")
                            getSystemService(VIBRATOR_SERVICE) as Vibrator
                        }
                        val ms = if (call.arguments == true) 400L else 80L
                        v.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    // App già aperta (launchMode singleTop): Health Connect che chiede la privacy arriva qui.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action in AZIONI_PRIVACY) canale?.invokeMethod("apriPrivacy", null)
        // Pulsante ▶ del widget con l'app già aperta: parte l'allenamento di oggi.
        if (azioneDi(intent) == WidgetOggi.AZIONE_AVVIA) canale?.invokeMethod("avviaDaWidget", null)
        testoDi(intent)?.let { canale?.invokeMethod("testoCondiviso", it) }
    }

    private fun ingressoAgente() = "$packageName.RiceviDaAgente"

    /** Testo condiviso, solo se arriva dall'ingresso dell'assistente collegato. */
    private fun testoDi(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND) return null
        if (intent.component?.className != ingressoAgente()) return null
        return intent.getStringExtra(Intent.EXTRA_TEXT)?.take(200_000)
    }

    /**
     * Azione dell'intent, ma "avvia l'allenamento" vale solo se arriva dal
     * widget, cioè dall'ingresso non esportato: le altre app non possono usarlo.
     */
    private fun azioneDi(intent: Intent?): String? {
        val azione = intent?.action
        if (azione == WidgetOggi.AZIONE_AVVIA &&
            intent?.component?.className != WidgetOggi.ingressoAvvia(this)
        ) {
            Log.w("Avidididadi", "Avvio dell'allenamento ignorato: non arriva dal widget")
            return null
        }
        return azione
    }

    /**
     * Titoli delle sessioni (es. "Pistoia - Fartlek FC" scritto da Garmin), che il
     * pacchetto health non restituisce. Risponde con uuid -> titolo, solo per quelle
     * che ne hanno uno.
     */
    private fun leggiTitoli(uuid: List<String>, result: MethodChannel.Result) {
        lifecycleScope.launch {
            val titoli = mutableMapOf<String, String>()
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                for (id in uuid) {
                    try {
                        val titolo = client.readRecord(ExerciseSessionRecord::class, id).record.title
                        if (!titolo.isNullOrBlank()) titoli[id] = titolo
                    } catch (e: Exception) {
                        // sessione non più presente o non leggibile: niente titolo
                        Log.w("Avidididadi", "Health Connect: titolo di $id non leggibile: $e")
                    }
                }
            } catch (e: Exception) {
                // Health Connect non disponibile: nessun titolo
                Log.w("Avidididadi", "Health Connect: titoli non leggibili: $e")
            }
            result.success(titoli)
        }
    }

    /**
     * Percorso GPS di una sessione: "dati" con i punti, "consenso" se Health
     * Connect vuole il permesso per quella sessione, "nessuno" se non c'è.
     */
    private fun leggiPercorso(uuid: String, result: MethodChannel.Result) {
        lifecycleScope.launch {
            val risposta: Map<String, Any?> = try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                val sessione = client.readRecord(ExerciseSessionRecord::class, uuid).record
                when (val r = sessione.exerciseRouteResult) {
                    is ExerciseRouteResult.Data -> mapOf("stato" to "dati", "punti" to piatto(r.exerciseRoute))
                    is ExerciseRouteResult.ConsentRequired -> mapOf("stato" to "consenso")
                    else -> mapOf("stato" to "nessuno")
                }
            } catch (e: Exception) {
                Log.w("Avidididadi", "Health Connect: percorso non leggibile: $e")
                mapOf("stato" to "errore")
            }
            result.success(risposta)
        }
    }

    /**
     * Dettagli di una sessione che il pacchetto health non dà: segmenti
     * (esercizio, ripetizioni), lap (con la lunghezza) e distanze parziali
     * scritte dalla stessa app. Liste piatte: inizio e fine in millisecondi,
     * poi i valori.
     */
    private fun leggiDettagli(uuid: String, result: MethodChannel.Result) {
        lifecycleScope.launch {
            val risposta: Map<String, Any?> = try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                val r = client.readRecord(ExerciseSessionRecord::class, uuid).record
                val segmenti = r.segments.flatMap {
                    listOf(
                        it.startTime.toEpochMilli().toDouble(),
                        it.endTime.toEpochMilli().toDouble(),
                        it.segmentType.toDouble(),
                        it.repetitions.toDouble(),
                    )
                }
                val lap = r.laps.flatMap {
                    listOf(
                        it.startTime.toEpochMilli().toDouble(),
                        it.endTime.toEpochMilli().toDouble(),
                        it.length?.inMeters ?: -1.0,
                    )
                }
                val distanze = client.readRecords(
                    ReadRecordsRequest(
                        DistanceRecord::class,
                        TimeRangeFilter.between(r.startTime, r.endTime),
                        dataOriginFilter = setOf(DataOrigin(r.metadata.dataOrigin.packageName)),
                    ),
                ).records.flatMap {
                    listOf(
                        it.startTime.toEpochMilli().toDouble(),
                        it.endTime.toEpochMilli().toDouble(),
                        it.distance.inMeters,
                    )
                }
                mapOf(
                    "titolo" to r.title,
                    "note" to r.notes,
                    "segmenti" to segmenti.toDoubleArray(),
                    "lap" to lap.toDoubleArray(),
                    "distanze" to distanze.toDoubleArray(),
                )
            } catch (e: Exception) {
                Log.w("Avidididadi", "Health Connect: dettagli non leggibili: $e")
                mapOf("errore" to e.javaClass.simpleName)
            }
            result.success(risposta)
        }
    }

    /** Punti del percorso in fila: lat, lon, millisecondi, ripetuti. */
    private fun piatto(route: ExerciseRoute): DoubleArray {
        val v = DoubleArray(route.route.size * 3)
        route.route.forEachIndexed { i, p ->
            v[i * 3] = p.latitude
            v[i * 3 + 1] = p.longitude
            v[i * 3 + 2] = p.time.toEpochMilli().toDouble()
        }
        return v
    }

    /** Pagina di Health Connect con i permessi di questa app. */
    private fun apriPermessiHealthConnect() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Intent("android.health.connect.action.MANAGE_HEALTH_PERMISSIONS")
                .putExtra(Intent.EXTRA_PACKAGE_NAME, packageName)
        } else {
            Intent("androidx.health.ACTION_HEALTH_CONNECT_SETTINGS")
        }
        try {
            startActivity(intent)
        } catch (e: Exception) {
            startActivity(Intent("androidx.health.ACTION_HEALTH_CONNECT_SETTINGS"))
        }
    }

    companion object {
        private val AZIONI_PRIVACY = setOf(
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE",
            "android.intent.action.VIEW_PERMISSION_USAGE",
        )
    }
}
