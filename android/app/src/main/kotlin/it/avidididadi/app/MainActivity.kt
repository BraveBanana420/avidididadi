package it.avidididadi.app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.IntentFilter
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
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

    /** [urgente]: interrompe la frase in corso e la coda (le curve). */
    /** Lingua della voce, scelta nell'app ("it" o "en"). */
    private var linguaVoce = "it"

    private fun localeVoce(): Locale = if (linguaVoce == "en") Locale.ENGLISH else Locale.ITALIAN

    private fun parla(testo: String, urgente: Boolean = false, lingua: String? = null) {
        if (lingua != null && lingua != linguaVoce) {
            linguaVoce = lingua
            if (ttsPronta) tts?.language = localeVoce()
        }
        // Sintesi non ancora pronta: anche qui vale solo l'ultima frase urgente.
        if (urgente) inAttesa.clear()
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
                pronta.language = localeVoce()
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
            di(t, testo, urgente)
        } else {
            inAttesa.add(testo)
        }
    }

    private fun di(t: TextToSpeech, testo: String, urgente: Boolean = false) {
        (getSystemService(AUDIO_SERVICE) as AudioManager).requestAudioFocus(fuocoVoce)
        val coda = if (urgente) TextToSpeech.QUEUE_FLUSH else TextToSpeech.QUEUE_ADD
        t.speak(testo, coda, null, "voce-${System.nanoTime()}")
    }

    /** Finita l'ultima frase in coda, la musica torna al suo volume. */
    private fun rilascia(t: TextToSpeech) {
        if (!t.isSpeaking) {
            (getSystemService(AUDIO_SERVICE) as AudioManager).abandonAudioFocusRequest(fuocoVoce)
        }
    }

    // Backup automatico: la cartella si sceglie una volta e il permesso resta.
    private var attesaCartella: MethodChannel.Result? = null
    private val richiestaCartella =
        registerForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
            if (uri != null) {
                contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                )
            }
            attesaCartella?.success(uri?.let { listOf(it.toString(), nomeCartella(it)) })
            attesaCartella = null
        }

    private fun cartellaDi(albero: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(albero, DocumentsContract.getTreeDocumentId(albero))

    private fun nomeCartella(albero: Uri): String = try {
        contentResolver.query(
            cartellaDi(albero),
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null, null, null,
        )?.use { c -> if (c.moveToFirst()) c.getString(0) else "" } ?: ""
    } catch (e: Exception) {
        ""
    }

    /** I file della cartella: id e nome, uno dopo l'altro. */
    private fun fileInCartella(albero: Uri): List<String> {
        val figli = DocumentsContract.buildChildDocumentsUriUsingTree(
            albero, DocumentsContract.getTreeDocumentId(albero),
        )
        val out = mutableListOf<String>()
        contentResolver.query(
            figli,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            ),
            null, null, null,
        )?.use { c ->
            while (c.moveToNext()) {
                out.add(c.getString(0))
                out.add(c.getString(1) ?: "")
            }
        }
        return out
    }

    /** Lavori sui file fuori dal thread dell'interfaccia; errori → null. */
    private fun suiFile(result: MethodChannel.Result, lavoro: () -> Any?) {
        lifecycleScope.launch {
            val esito = withContext(Dispatchers.IO) {
                try {
                    lavoro()
                } catch (e: Exception) {
                    Log.w("Avidididadi", "cartella del backup: $e")
                    null
                }
            }
            result.success(esito)
        }
    }

    // Permesso delle notifiche (Android 13+), chiesto all'inizio dell'allenamento.
    private var attesaNotifiche: MethodChannel.Result? = null
    private val richiestaNotifiche =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { ok ->
            attesaNotifiche?.success(ok)
            attesaNotifiche = null
        }

    // Il tasto Pausa/Riprendi della notifica: arriva qui e passa all'app.
    // Il ricevitore non è esportato: solo la notifica dell'app lo raggiunge.
    private val ricevitorePausa = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) {
            canale?.invokeMethod("pausaDaNotifica", null)
        }
    }

    /** Notifica dell'allenamento: stesso numero di quella del GPS, che sostituisce. */
    private fun notificaAllenamento(dati: Map<*, *>) {
        val gestore = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        gestore.createNotificationChannel(
            NotificationChannel(
                CANALE_ALLENAMENTO,
                dati["canale"] as? String ?: "Allenamento in corso",
                NotificationManager.IMPORTANCE_LOW,
            )
                .apply { setShowBadge(false) },
        )
        val inPausa = dati["pausa"] == true
        val apri = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val pausa = PendingIntent.getBroadcast(
            this, 1,
            Intent(AZIONE_PAUSA).setPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val testo = dati["testo"] as? String ?: ""
        val n = NotificationCompat.Builder(this, CANALE_ALLENAMENTO)
            .setSmallIcon(R.drawable.ic_notifica)
            .setContentTitle(dati["titolo"] as? String ?: dati["allenamento"] as? String ?: "Allenamento")
            .setContentText(testo.ifEmpty { null })
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(apri)
            .addAction(
                0,
                if (inPausa) dati["riprendi"] as? String ?: "Riprendi" else dati["pausa_testo"] as? String ?: "Pausa",
                pausa,
            )
        if (inPausa) {
            n.setShowWhen(false)
        } else {
            // Il tempo lo fa scorrere Android: niente aggiornamenti ogni secondo.
            n.setShowWhen(true)
                .setUsesChronometer(true)
                .setWhen((dati["base"] as Number).toLong())
                .setChronometerCountDown(dati["indietro"] == true)
        }
        try {
            NotificationManagerCompat.from(this).notify(ID_NOTIFICA, n.build())
        } catch (e: SecurityException) {
            Log.w("Avidididadi", "notifiche non permesse", e)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(ricevitorePausa)
        } catch (_: IllegalArgumentException) {
        }
        NotificationManagerCompat.from(this).cancel(ID_NOTIFICA)
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
        ContextCompat.registerReceiver(
            this, ricevitorePausa, IntentFilter(AZIONE_PAUSA), ContextCompat.RECEIVER_NOT_EXPORTED,
        )
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
                    "condividiImmagine" -> {
                        // Solo file della cartella cache/condivisi.
                        val cartella = java.io.File(cacheDir, "condivisi").canonicalFile
                        val file = java.io.File(call.argument<String>("percorso").orEmpty()).canonicalFile
                        if (file.parentFile != cartella || !file.exists()) {
                            result.error("file", "Immagine non trovata", null)
                        } else {
                            val uri = FileProvider.getUriForFile(this@MainActivity, "$packageName.condivisi", file)
                            val invio = Intent(Intent.ACTION_SEND)
                                .setType("image/png")
                                .putExtra(Intent.EXTRA_STREAM, uri)
                                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            call.argument<String>("testo")?.takeIf { it.isNotEmpty() }?.let {
                                invio.putExtra(Intent.EXTRA_TEXT, it)
                            }
                            val scelta = Intent.createChooser(invio, call.argument<String>("titolo"))
                            scelta.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            startActivity(scelta)
                            result.success(null)
                        }
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
                    "scegliCartella" -> {
                        attesaCartella?.success(null)
                        attesaCartella = result
                        richiestaCartella.launch(null)
                    }
                    "scriviInCartella" -> {
                        val albero = Uri.parse(call.argument<String>("cartella"))
                        val nome = call.argument<String>("nome")!!
                        val dati = call.argument<ByteArray>("dati")!!
                        suiFile(result) {
                            val doc = DocumentsContract.createDocument(
                                contentResolver, cartellaDi(albero), "application/gzip", nome,
                            ) ?: return@suiFile false
                            contentResolver.openOutputStream(doc)?.use { it.write(dati) }
                                ?: return@suiFile false
                            true
                        }
                    }
                    "fileInCartella" -> {
                        val albero = Uri.parse(call.arguments as String)
                        suiFile(result) { fileInCartella(albero) }
                    }
                    "cancellaInCartella" -> {
                        val albero = Uri.parse(call.argument<String>("cartella"))
                        val id = call.argument<String>("id")!!
                        suiFile(result) {
                            DocumentsContract.deleteDocument(
                                contentResolver, DocumentsContract.buildDocumentUriUsingTree(albero, id),
                            )
                        }
                    }
                    "permessoNotifiche" -> {
                        if (Build.VERSION.SDK_INT < 33 ||
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                            PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true)
                        } else {
                            attesaNotifiche?.success(false)
                            attesaNotifiche = result
                            richiestaNotifiche.launch(Manifest.permission.POST_NOTIFICATIONS)
                        }
                    }
                    "notificaAllenamento" -> {
                        notificaAllenamento(call.arguments as Map<*, *>)
                        result.success(null)
                    }
                    "togliNotifica" -> {
                        NotificationManagerCompat.from(this@MainActivity).cancel(ID_NOTIFICA)
                        result.success(null)
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
                            // Testo solo, o testo e urgenza.
                            when (val a = call.arguments) {
                                is Map<*, *> ->
                                    parla(a["testo"] as String, a["urgente"] == true, a["lingua"] as? String)
                                else -> parla(a as String)
                            }
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
        // Lo stesso numero della notifica del GPS (geolocator): una notifica sola.
        private const val ID_NOTIFICA = 75415
        private const val CANALE_ALLENAMENTO = "allenamento"
        private const val AZIONE_PAUSA = "it.avidididadi.app.PAUSA"
        private val AZIONI_PRIVACY = setOf(
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE",
            "android.intent.action.VIEW_PERMISSION_USAGE",
        )
    }
}
