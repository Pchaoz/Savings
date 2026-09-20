package com.pchaozz.savings

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Unico puente nativo de la app: recibe de Flutter el importe ya
 * formateado de la bolsa de caprichos (ver `TreatWidgetBridge` en
 * lib/core/treat_widget_bridge.dart) y lo guarda para que
 * `TreatBagWidgetProvider` lo pinte en el widget de pantalla de inicio.
 * No hace ningun calculo aqui -- Flutter siempre manda el texto ya listo
 * ("21,85 €"), este canal solo lo traslada.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.pchaozz.savings/treat_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "updateAmount") {
                    val amount = call.argument<String>("amount")
                    val overspent = call.argument<Boolean>("overspent") ?: false
                    val ratio = call.argument<Double>("ratio")?.toFloat() ?: 0f
                    if (amount != null) {
                        getSharedPreferences(TreatBagWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putString(TreatBagWidgetProvider.PREF_AMOUNT, amount)
                            .putBoolean(TreatBagWidgetProvider.PREF_OVERSPENT, overspent)
                            .putFloat(TreatBagWidgetProvider.PREF_RATIO, ratio)
                            .apply()
                        TreatBagWidgetProvider.updateAllWidgets(applicationContext)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
