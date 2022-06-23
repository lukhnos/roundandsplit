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

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.app.DialogFragment
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Button
import android.widget.TextView
import org.lukhnos.tipping.Tipping
import org.lukhnos.tipping.Tipping.Payment
import java.math.BigDecimal
import java.math.RoundingMode
import java.text.NumberFormat
import java.util.*

class MainActivity : Activity(), ButtonStrip.Observer, NumericKeypad.Observer {
    var mButtonStrip: ButtonStrip? = null
    var mAmountLabel: TextView? = null
    var mTipLabel: TextView? = null
    var mTotalLabel: TextView? = null
    var mEffectiveRateLabel: TextView? = null
    var mSplitButton: Button? = null
    var mCurrentAmount: String? = ""
    var mTippingRate = BigDecimal.ZERO
    var mPayment: Payment? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false)
        mAmountLabel = findViewById<View>(R.id.amount_label) as TextView
        mTipLabel = findViewById<View>(R.id.tip_label) as TextView
        mTotalLabel = findViewById<View>(R.id.total_label) as TextView
        mEffectiveRateLabel = findViewById<View>(R.id.effective_rate_label) as TextView
        mSplitButton = findViewById<View>(R.id.split_button) as Button
        mSplitButton!!.setOnClickListener { showSplitDialog() }
        mButtonStrip = findViewById<View>(R.id.rate_button_strip) as ButtonStrip
        mButtonStrip!!.setObserver(this)
        (findViewById<View>(R.id.numeric_keypad) as NumericKeypad).setObserver(this)
        if (savedInstanceState != null) {
            mCurrentAmount = savedInstanceState.getString(CURRENT_AMOUNT)
        }
        setupButtonStrip()
        update()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(CURRENT_AMOUNT, mCurrentAmount)
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
        if (mCurrentAmount!!.length > 0) {
            mCurrentAmount = mCurrentAmount!!.substring(0, mCurrentAmount!!.length - 1)
            update()
        }
    }

    override fun clear() {
        if (mCurrentAmount!!.length > 0) {
            mCurrentAmount = ""
            update()
        }
    }

    override fun number(n: Int) {
        if (n == 0 && mCurrentAmount!!.length == 0) {
            return
        }
        if (mCurrentAmount!!.length >= 6) {
            return
        }
        mCurrentAmount = mCurrentAmount + n.toString()
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
        mTippingRate = BigDecimal(rateString)
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
        val rateString = prefs.getString(TIPPING_RATE_KEY, "")
        if (rateString == "0.15") {
            rateIndex = 0
            mTippingRate = BigDecimal("0.15")
        } else if (rateString == "0.18") {
            rateIndex = 1
            mTippingRate = BigDecimal("0.18")
        } else if (rateString == "0.20") {
            rateIndex = 2
            mTippingRate = BigDecimal("0.20")
        } else {
            rateIndex = 1
            mTippingRate = BigDecimal("0.18")
        }
        mButtonStrip!!.addButtons(titles, rateIndex)
    }

    private fun update() {
        val amount: BigDecimal
        amount = if (mCurrentAmount!!.length == 0) {
            BigDecimal.ZERO
        } else {
            BigDecimal(mCurrentAmount).divide(BigDecimal("100"))
        }
        mPayment = Tipping.getBestTipPayment(amount, mTippingRate)
        if (mPayment!!.total.compareTo(BigDecimal("2")) < 0) {
            mSplitButton!!.isEnabled = false
        } else {
            mSplitButton!!.isEnabled = true
        }
        mAmountLabel!!.text = decimalString(amount)
        mTipLabel!!.text = decimalString(mPayment!!.tip)
        mTotalLabel!!.text = decimalString(mPayment!!.total)
        val roundedRate = mPayment!!.effectiveRate.setScale(3, RoundingMode.HALF_UP)
        mEffectiveRateLabel!!.text = percentageString(roundedRate)
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
        val splitAmount = mPayment!!.total.divide(BigDecimal(2), 2, BigDecimal.ROUND_DOWN)
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
        newFragment.show(fragmentManager, "dialog")
    }

    class SplitDialogFragment : DialogFragment() {
        var mTitle: String? = null
        var mSplitAmount: String? = null
        var mItems: Array<String>? = null
        override fun setArguments(args: Bundle) {
            super.setArguments(args)
            mSplitAmount = args.getString(AMOUNT)
            mItems = args.getStringArray(LOCALIZED_ITEMS)
            mTitle = args.getString(LOCALIZED_TITLE)
        }

        override fun onCreateDialog(savedInstanceState: Bundle): Dialog {
            val builder = AlertDialog.Builder(activity)
            builder.setTitle(mTitle)
                .setItems(mItems, DialogInterface.OnClickListener { dialog, which ->
                    if (which != 0 && which != 1) {
                        return@OnClickListener
                    }
                    val intent = Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "", null))
                    val subjectFormat: String
                    subjectFormat = if (which == 0) {
                        getString(R.string.request_subject_prefix)
                    } else {
                        getString(R.string.send_subject_prefix)
                    }
                    val subject = String.format(Locale.ROOT, subjectFormat, mSplitAmount)
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