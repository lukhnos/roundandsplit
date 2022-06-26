//
// Copyright (c) 2014 Lukhnos Liu.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
package org.lukhnos.roundandsplit

import android.app.AlertDialog
import android.app.Dialog
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.DialogFragment
import androidx.preference.PreferenceManager
import org.lukhnos.tipping.Tipping
import org.lukhnos.tipping.Tipping.Payment
import java.math.BigDecimal
import java.math.RoundingMode
import java.text.NumberFormat
import java.util.*

class MainActivity : AppCompatActivity(), ButtonStrip.Observer, NumericKeypad.Observer {
    private lateinit var buttonStrip: ButtonStrip
    private lateinit var amountLabel: TextView
    private lateinit var tipLabel: TextView
    private lateinit var totalLabel: TextView
    private lateinit var effectiveRateLabel: TextView
    private lateinit var splitButton: Button
    private var currentAmount = ""
    private var tippingRate = BigDecimal.ZERO
    private var payment = Payment()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(findViewById(R.id.my_toolbar))
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false)
        amountLabel = findViewById<View>(R.id.amount_label) as TextView
        tipLabel = findViewById<View>(R.id.tip_label) as TextView
        totalLabel = findViewById<View>(R.id.total_label) as TextView
        effectiveRateLabel = findViewById<View>(R.id.effective_rate_label) as TextView
        splitButton = findViewById<View>(R.id.split_button) as Button
        splitButton.setOnClickListener { showSplitDialog() }
        buttonStrip = findViewById<View>(R.id.rate_button_strip) as ButtonStrip
        buttonStrip.setObserver(this)
        (findViewById<View>(R.id.numeric_keypad) as NumericKeypad).setObserver(this)
        currentAmount = savedInstanceState?.getString(CURRENT_AMOUNT) ?: currentAmount
        setupButtonStrip()
        update()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(CURRENT_AMOUNT, currentAmount)
    }

    override fun onResume() {
        super.onResume()
        setupButtonStrip()
        update()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        val id = item.itemId
        if (id == R.id.action_settings) {
            val intent = Intent(this, SettingsActivity::class.java)
            startActivity(intent)
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    override fun backspace() {
        if (currentAmount.isNotEmpty()) {
            currentAmount = currentAmount.substring(0, currentAmount.length - 1)
            update()
        }
    }

    override fun clear() {
        if (currentAmount.isNotEmpty()) {
            currentAmount = ""
            update()
        }
    }

    override fun number(n: Int) {
        if (n == 0 && currentAmount.isEmpty()) {
            return
        }
        if (currentAmount.length >= 6) {
            return
        }
        currentAmount += n.toString()
        update()
    }

    override fun onButtonClicked(index: Int) {
        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        val editor = prefs.edit()
        var rateString = "0.18"
        when (index) {
            0 -> rateString = "0.15"
            1 -> rateString = "0.18"
            2 -> rateString = "0.20"
            else -> {}
        }
        tippingRate = BigDecimal(rateString)
        editor.putString(TIPPING_RATE_KEY, rateString)
        editor.apply()
        update()
    }

    private fun setupButtonStrip() {
        val titles: MutableList<String?> = ArrayList()
        val useUSLocale = PreferenceManager.getDefaultSharedPreferences(this)
            .getBoolean(getString(R.string.pref_key_use_us_decimal_point), true)
        val format =
            if (useUSLocale) NumberFormat.getPercentInstance(Locale.US) else NumberFormat.getPercentInstance()
        format.minimumFractionDigits = 0
        titles.add(format.format(0.15))
        titles.add(format.format(0.18))
        titles.add(format.format(0.20))
        val rateIndex: Int
        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        when (prefs.getString(TIPPING_RATE_KEY, "")) {
            "0.15" -> {
                rateIndex = 0
                tippingRate = BigDecimal("0.15")
            }
            "0.18" -> {
                rateIndex = 1
                tippingRate = BigDecimal("0.18")
            }
            "0.20" -> {
                rateIndex = 2
                tippingRate = BigDecimal("0.20")
            }
            else -> {
                rateIndex = 1
                tippingRate = BigDecimal("0.18")
            }
        }
        buttonStrip.addButtons(titles, rateIndex)
    }

    private fun update() {
        val amount = if (currentAmount.isEmpty()) {
            BigDecimal.ZERO
        } else {
            BigDecimal(currentAmount).divide(BigDecimal("100"))
        }
        payment = Tipping.getBestTipPayment(amount, tippingRate)
        splitButton.isEnabled = payment.total >= BigDecimal("2")
        amountLabel.text = decimalString(amount)
        tipLabel.text = decimalString(payment.tip)
        totalLabel.text = decimalString(payment.total)
        val roundedRate = payment.effectiveRate.setScale(3, RoundingMode.HALF_UP)
        effectiveRateLabel.text = percentageString(roundedRate)
    }

    private fun decimalString(n: BigDecimal): String {
        val useUSLocale = PreferenceManager.getDefaultSharedPreferences(this)
            .getBoolean(getString(R.string.pref_key_use_us_decimal_point), true)
        val format =
            if (useUSLocale) NumberFormat.getInstance(Locale.US) else NumberFormat.getInstance()
        format.minimumFractionDigits = 2
        return format.format(n)
    }

    private fun currencyStringUS(n: BigDecimal): String {
        val format = NumberFormat.getCurrencyInstance(Locale.US)
        format.minimumFractionDigits = 2
        return format.format(n)
    }

    private fun percentageString(n: BigDecimal): String {
        if (n == BigDecimal.ZERO) {
            return getString(R.string.info_text_non_percentage)
        }
        val useUSLocale = PreferenceManager.getDefaultSharedPreferences(this)
            .getBoolean(getString(R.string.pref_key_use_us_decimal_point), true)
        val format =
            if (useUSLocale) NumberFormat.getPercentInstance(Locale.US) else NumberFormat.getPercentInstance()
        format.maximumFractionDigits = 1
        format.minimumFractionDigits = 1
        return format.format(n)
    }

    private fun showSplitDialog() {
        val splitAmount = payment.total.divide(BigDecimal(2), 2, BigDecimal.ROUND_DOWN)
        val splitAmountString = currencyStringUS(splitAmount)
        val args = Bundle()
        val items = arrayOf(
            getString(R.string.request_action_prefix) + " " + splitAmountString,
            getString(R.string.send_action_prefix) + " " + splitAmountString,
            getString(R.string.cancel_action)
        )
        args.putString(SplitDialogFragment.LOCALIZED_TITLE, getString(R.string.split_dialog_title))
        args.putString(SplitDialogFragment.AMOUNT, splitAmountString)
        args.putStringArray(SplitDialogFragment.LOCALIZED_ITEMS, items)
        val newFragment: DialogFragment = SplitDialogFragment()
        newFragment.arguments = args
        newFragment.show(supportFragmentManager, "dialog")
    }

    class SplitDialogFragment : DialogFragment() {
        private var title: String = ""
        private var splitAmount: String = ""
        private var items: Array<String> = emptyArray()

        override fun setArguments(args: Bundle?) {
            super.setArguments(args)
            splitAmount = args?.getString(AMOUNT) ?: splitAmount
            items = args?.getStringArray(LOCALIZED_ITEMS) ?: items
            title = args?.getString(LOCALIZED_TITLE) ?: title
        }

        override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
            val builder = AlertDialog.Builder(activity)
            builder.setTitle(title)
                .setItems(items, DialogInterface.OnClickListener { _, which ->
                    if (which != 0 && which != 1) {
                        return@OnClickListener
                    }
                    val intent = Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "", null))
                    val subjectFormat = if (which == 0) {
                        getString(R.string.request_subject_prefix)
                    } else {
                        getString(R.string.send_subject_prefix)
                    }
                    val subject = String.format(Locale.ROOT, subjectFormat, splitAmount)
                    intent.putExtra(Intent.EXTRA_SUBJECT, subject)
                    startActivity(intent)
                })
            return builder.create()
        }

        companion object {
            const val LOCALIZED_TITLE = "Title"
            const val AMOUNT = "Amount"
            const val LOCALIZED_ITEMS = "LocalizedItems"
        }
    }

    companion object {
        private const val TIPPING_RATE_KEY = "TippingRate"
        private const val CURRENT_AMOUNT = "CurrentAmount"
    }
}