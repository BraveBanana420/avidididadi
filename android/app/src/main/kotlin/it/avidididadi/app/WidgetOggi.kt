package it.avidididadi.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.time.LocalDate

/** Widget piccolo: la seduta di oggi. */
class WidgetPiccolo : AppWidgetProvider() {
    override fun onUpdate(ctx: Context, m: AppWidgetManager, ids: IntArray) {
        for (id in ids) m.updateAppWidget(id, WidgetOggi.crea(ctx, largo = false))
    }
}

/** Widget largo: la seduta di oggi e la settimana. */
class WidgetLargo : AppWidgetProvider() {
    override fun onUpdate(ctx: Context, m: AppWidgetManager, ids: IntArray) {
        for (id in ids) m.updateAppWidget(id, WidgetOggi.crea(ctx, largo = true))
    }
}

/**
 * Disegna i widget dai dati che prepara l'app (due settimane, da lunedì):
 * il giorno di oggi lo sceglie qui, così il widget resta giusto anche se
 * l'app non viene aperta. I colori seguono il tema scelto nell'app.
 */
object WidgetOggi {
    private const val PREFS = "avidididadi_widget"
    private const val CHIAVE = "dati"
    const val AZIONE_AVVIA = "it.avidididadi.app.AVVIA"

    private val CERCHI = intArrayOf(
        R.id.cerchio0, R.id.cerchio1, R.id.cerchio2, R.id.cerchio3,
        R.id.cerchio4, R.id.cerchio5, R.id.cerchio6,
    )
    private val NUMERI = intArrayOf(
        R.id.numero0, R.id.numero1, R.id.numero2, R.id.numero3,
        R.id.numero4, R.id.numero5, R.id.numero6,
    )
    private val LETTERE = intArrayOf(
        R.id.lettera0, R.id.lettera1, R.id.lettera2, R.id.lettera3,
        R.id.lettera4, R.id.lettera5, R.id.lettera6,
    )

    fun salva(ctx: Context, json: String) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(CHIAVE, json).apply()
        aggiornaTutti(ctx)
    }

    fun aggiornaTutti(ctx: Context) {
        val m = AppWidgetManager.getInstance(ctx)
        for ((cls, largo) in listOf(WidgetPiccolo::class.java to false, WidgetLargo::class.java to true)) {
            for (id in m.getAppWidgetIds(ComponentName(ctx, cls))) m.updateAppWidget(id, crea(ctx, largo))
        }
    }

    /** Ingresso non esportato da cui passa il pulsante ▶ (vedi il manifest). */
    fun ingressoAvvia(ctx: Context) = "${ctx.packageName}.AvviaDaWidget"

    private fun intento(ctx: Context, azione: String?, codice: Int): PendingIntent {
        val i = Intent().addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        if (azione == AZIONE_AVVIA) {
            i.setClassName(ctx, ingressoAvvia(ctx))
        } else {
            i.setClass(ctx, MainActivity::class.java)
        }
        if (azione != null) i.action = azione
        return PendingIntent.getActivity(
            ctx, codice, i, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /** Testo chiaro o scuro sopra un colore pieno. */
    private fun suColore(c: Int): Int {
        val l = 0.299 * Color.red(c) + 0.587 * Color.green(c) + 0.114 * Color.blue(c)
        return if (l < 150) Color.WHITE else Color.parseColor("#FF14141A")
    }

    fun crea(ctx: Context, largo: Boolean): RemoteViews {
        val v = RemoteViews(ctx.packageName, if (largo) R.layout.widget_largo else R.layout.widget_piccolo)
        v.setOnClickPendingIntent(R.id.root, intento(ctx, null, 0))
        val dati = try {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(CHIAVE, null)?.let { JSONObject(it) }
        } catch (e: Exception) {
            Log.w("Avidididadi", "Widget: dati illeggibili: $e")
            null
        }
        val scuro = dati?.optBoolean("scuro", true) ?: true
        // Sfumature dell'accento: rosso (standard) o neon.
        val neon = dati?.optBoolean("neon", false) ?: false
        val colori = dati?.optJSONObject("colori")
        fun colore(nome: String, base: String): Int =
            colori?.optLong(nome)?.takeIf { it != 0L }?.toInt() ?: Color.parseColor(base)
        val testo = colore("testo", "#FFF4F4F5")
        val testo2 = colore("testo2", "#FFA1A1AA")
        val accento = colore("accento", "#FFFF3B47")
        val suHero = colore("suHero", "#FF160304")
        val traccia = colore("traccia", "#FF3F3F46")

        // Fondo e colori del testo secondo il tema dell'app.
        if (largo) {
            v.setInt(R.id.root, "setBackgroundResource",
                if (scuro) R.drawable.widget_sfondo_scuro else R.drawable.widget_sfondo_chiaro)
            val quadro = if (neon) R.drawable.widget_icona_chiaro else R.drawable.widget_icona_scuro
            v.setInt(R.id.icona, "setBackgroundResource", quadro)
            v.setInt(R.id.play, "setBackgroundResource", quadro)
            v.setTextColor(R.id.etichetta, accento)
            v.setTextColor(R.id.titolo, testo)
            v.setTextColor(R.id.sottotitolo, testo2)
            v.setInt(R.id.play, "setColorFilter", suHero)
        } else {
            v.setInt(R.id.root, "setBackgroundResource",
                if (neon) R.drawable.widget_hero_chiaro else R.drawable.widget_hero_scuro)
            v.setTextColor(R.id.etichetta, suHero)
            v.setTextColor(R.id.titolo, suHero)
            v.setTextColor(R.id.sottotitolo, suHero)
        }

        val oggi = LocalDate.now()
        val giorni = dati?.optJSONObject("giorni")
        val g = giorni?.optJSONObject(oggi.toString())
        if (g == null) {
            v.setTextViewText(R.id.titolo, "Avidididadi")
            v.setTextViewText(R.id.sottotitolo, "Apri l'app per vedere il piano")
            v.setViewVisibility(R.id.play, View.GONE)
        } else {
            val altre = g.optInt("altre")
            v.setTextViewText(R.id.etichetta, if (altre > 0) "OGGI · +$altre" else "OGGI")
            v.setTextViewText(R.id.titolo, g.optString("titolo"))
            v.setTextViewText(R.id.sottotitolo, g.optString("sottotitolo"))
            val icona = BitmapFactory.decodeFile(g.optString("icona"))
            if (icona != null) {
                v.setImageViewBitmap(R.id.icona, icona)
                v.setInt(R.id.icona, "setColorFilter", suHero)
            }
            val avvia = g.optString("stato") == "previsto" && g.optBoolean("passi")
            v.setViewVisibility(R.id.play, if (avvia) View.VISIBLE else View.GONE)
            if (avvia) v.setOnClickPendingIntent(R.id.play, intento(ctx, AZIONE_AVVIA, 1))
        }

        if (largo) {
            // La settimana: pieno = fatto, bordo = da fare, colore del tema = oggi.
            val lunedi = oggi.minusDays((oggi.dayOfWeek.value - 1).toLong())
            var fatti = 0
            var totale = 0
            for (i in 0 until 7) {
                val d = lunedi.plusDays(i.toLong())
                val gi = giorni?.optJSONObject(d.toString())
                val cerchio = gi?.optString("cerchio") ?: "vuoto"
                val eOggi = d == oggi
                v.setTextColor(LETTERE[i], if (eOggi) testo else testo2)
                when (cerchio) {
                    "fatto" -> {
                        fatti++
                        totale++
                        val c = gi!!.optLong("coloreCerchio").toInt()
                        v.setImageViewResource(CERCHI[i], R.drawable.widget_cerchio)
                        v.setInt(CERCHI[i], "setColorFilter", c)
                        v.setTextViewText(NUMERI[i], "✓")
                        v.setTextColor(NUMERI[i], suColore(c))
                    }
                    else -> {
                        if (cerchio == "previsto") totale++
                        v.setImageViewResource(CERCHI[i], R.drawable.widget_anello)
                        v.setInt(CERCHI[i], "setColorFilter",
                            when {
                                eOggi -> accento
                                cerchio == "previsto" -> traccia
                                else -> Color.TRANSPARENT
                            })
                        v.setTextViewText(NUMERI[i], d.dayOfMonth.toString())
                        v.setTextColor(NUMERI[i], if (eOggi) accento else testo2)
                    }
                }
            }
            v.setTextColor(R.id.riepilogo, testo2)
            v.setTextViewText(R.id.riepilogo,
                if (totale == 0) "Nessun allenamento questa settimana" else "$fatti di $totale fatti questa settimana")
        }
        return v
    }
}
