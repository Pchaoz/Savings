package com.pchaozz.savings

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews

/**
 * Widget de pantalla de inicio del telefono: la bolsa de caprichos
 * disponible ahora mismo (el mismo numero que "A CAPRICHOS" en Inicio).
 *
 * Sin ningun paquete de terceros (tipo home_widget) a proposito -- es la
 * primera dependencia nativa Android nueva desde `share_plus` (que ya dio
 * un problema de compilacion en Windows, ver resumen-proyecto.md), asi
 * que se ha preferido escribir las pocas lineas de Kotlin/XML que hacen
 * falta en vez de anadir otra libreria mas con su propio arbol de
 * dependencias. Solo lee un texto ya formateado de SharedPreferences
 * (escrito por MainActivity.kt cuando Flutter se lo pide) y lo pinta --
 * nunca calcula nada de dinero por su cuenta.
 */
class TreatBagWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "TreatBagWidgetPrefs"
        const val PREF_AMOUNT = "amount_text"
        const val PREF_OVERSPENT = "overspent"
        const val PREF_RATIO = "spent_ratio"

        // Mismos dos colores que C.go / C.spend en core/theme/tokens.dart --
        // el widget nunca decide el color por su cuenta, solo repite el
        // flag `overspent` que ya calcula Flutter.
        private const val COLOR_GO = "#4FD48C"
        private const val COLOR_SPEND = "#E8705F"

        /** Llamado desde MainActivity.kt cada vez que Flutter manda un
         *  importe nuevo -- repinta todas las copias del widget que Pol
         *  tenga puestas (normalmente una, pero un AppWidgetProvider
         *  siempre tiene que estar listo para varias). */
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TreatBagWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                TreatBagWidgetProvider().onUpdate(context, manager, ids)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val amountText = prefs.getString(PREF_AMOUNT, null) ?: "—"
        val overspent = prefs.getBoolean(PREF_OVERSPENT, false)
        val amountColor = Color.parseColor(if (overspent) COLOR_SPEND else COLOR_GO)
        val ratio = prefs.getFloat(PREF_RATIO, 0f).coerceIn(0f, 1f)
        val progressPercent = (ratio * 100).toInt()

        // Se construye a mano (en vez de packageManager.getLaunchIntentForPackage,
        // que devuelve un Intent? nullable) para no tener que manejar un
        // caso "no encontrado" que en la practica nunca pasa -- MainActivity
        // siempre existe.
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.treat_bag_widget)
            views.setTextViewText(R.id.widget_amount, amountText)
            views.setTextColor(R.id.widget_amount, amountColor)

            // Dos ProgressBar fijos superpuestos (verde/rojo) en vez de
            // tintar uno solo -- ver el comentario en
            // res/drawable/widget_progress_go.xml para el porque.
            views.setProgressBar(R.id.widget_progress_go, 100, progressPercent, false)
            views.setProgressBar(R.id.widget_progress_spend, 100, progressPercent, false)
            views.setViewVisibility(
                R.id.widget_progress_go,
                if (overspent) View.GONE else View.VISIBLE,
            )
            views.setViewVisibility(
                R.id.widget_progress_spend,
                if (overspent) View.VISIBLE else View.GONE,
            )

            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
