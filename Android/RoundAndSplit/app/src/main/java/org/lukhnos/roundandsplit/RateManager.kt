package org.lukhnos.roundandsplit

import android.content.SharedPreferences
import java.math.BigDecimal
import java.text.NumberFormat
import java.util.*

class RateManager(val prefs: SharedPreferences) {

    /** Value for ListPreference. */
    data class ListPreferenceValues(val titles: Array<String>, val values: Array<String>)

    data class ButtonTitles(val titles: List<String>, val rateIndex: Int)

    fun getListPreferenceValues(index: Int): ListPreferenceValues {
        val ratesCopy = rates.toMutableList()
        check(index >= 0 && index < ratesCopy.size)

        ratesCopy.removeAt(index)

        val actualRates = SUPPORTED_RATES.filter { !ratesCopy.contains(it) }

        val formatter = buttonTitleFormatter
        val titles = actualRates.map { formatter.format(BigDecimal(it)) }.toTypedArray()
        val values = actualRates.toTypedArray()
        return ListPreferenceValues(titles, values)
    }

    // Used by SettingsActivity to maintain the stability of currently-selected rate.
    fun overwriteCurrentRate(newRate: String) {
        val editor = prefs.edit()
        editor.putString(PREF_KEY_TIPPING_RATE, newRate)
        editor.apply()
    }

    val buttonTitles: ButtonTitles
        get() {
            val formatter = buttonTitleFormatter
            val titles = rates.map { formatter.format(BigDecimal(it)) }
            return ButtonTitles(titles, currentRateIndex)
        }

    val currentRateIndex: Int
        get() {
            val cr = internalCurrentRate
            for (i in rates.indices) {
                if (cr == rates[i]) {
                    return i
                }
            }
            return 1
        }

    fun chooseRate(index: Int): BigDecimal {
        val r = rates
        check(index >= 0 && index < r.size)
        val editor = prefs.edit()
        var rateString = r[index]
        editor.putString(PREF_KEY_TIPPING_RATE, rateString)
        editor.apply()
        return BigDecimal(rateString)
    }

    val currentRate: BigDecimal
        get() {
            return BigDecimal(internalCurrentRate)
        }

    private val buttonTitleFormatter: NumberFormat
        get() {
            val useUSLocale = prefs.getBoolean(PREF_KEY_USE_PERIOD_DECIMAL_POINT, true)
            val formatter =
                if (useUSLocale) NumberFormat.getPercentInstance(Locale.US) else NumberFormat.getPercentInstance()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 1
            return formatter
        }

    private val rates: List<String>
        get() {
            val rate0 = prefs.getString(PREF_KEY_RATE0, DEFAULT_RATES[0])!!
            val rate1 = prefs.getString(PREF_KEY_RATE1, DEFAULT_RATES[1])!!
            val rate2 = prefs.getString(PREF_KEY_RATE2, DEFAULT_RATES[2])!!

            // Validate rates.
            if (!SUPPORTED_RATES.contains(rate0) || !SUPPORTED_RATES.contains(rate1) || !SUPPORTED_RATES.contains(
                    rate2
                )
            ) {
                val editor = prefs.edit()
                editor.putString(PREF_KEY_RATE0, DEFAULT_RATES[0])
                editor.putString(PREF_KEY_RATE1, DEFAULT_RATES[1])
                editor.putString(PREF_KEY_RATE2, DEFAULT_RATES[2])
                editor.apply()
                return DEFAULT_RATES;
            }

            return listOf(rate0, rate1, rate2)
        }

    private val internalCurrentRate: String
        get() {
            val rate = prefs.getString(PREF_KEY_TIPPING_RATE, DEFAULT_TIPPING_RATE)!!
            val currentRates = this.rates
            if (!currentRates.contains(rate)) {
                return currentRates[1]
            }
            return rate
        }

    companion object {
        private const val DEFAULT_TIPPING_RATE = "0.18"

        private const val PREF_KEY_TIPPING_RATE = "TippingRate"
        private const val PREF_KEY_RATE0 = "TippingRate0"
        private const val PREF_KEY_RATE1 = "TippingRate1"
        private const val PREF_KEY_RATE2 = "TippingRate2"

        val PREF_KEY_RATES: List<String> = listOf(PREF_KEY_RATE0, PREF_KEY_RATE1, PREF_KEY_RATE2)

        private const val PREF_KEY_USE_PERIOD_DECIMAL_POINT = "UsePeriodDecimalPoint"
        private val DEFAULT_RATES = listOf("0.15", "0.18", "0.20")

        private val SUPPORTED_RATES = listOf(
            "0.05",
            "0.10",
            "0.125",
            "0.15",
            "0.175",
            "0.18",
            "0.19",
            "0.20",
            "0.21",
            "0.225",
            "0.25",
            "0.30",
            "0.35",
            "0.40",
            "0.45",
            "0.50",
            "0.55",
            "0.60",
            "0.65",
            "0.70",
            "0.75",
        )
    }
}