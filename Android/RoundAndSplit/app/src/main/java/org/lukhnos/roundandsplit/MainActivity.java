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

package org.lukhnos.roundandsplit;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import org.lukhnos.tipping.Tipping;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


public class MainActivity extends Activity implements ButtonStrip.Observer, NumericKeypad.Observer {
    private static final String TAG = MainActivity.class.getSimpleName();
    private static final String TIPPING_RATE_KEY = "TippingRate";
    private static final String CURRENT_AMOUNT = "CurrentAmount";

    ButtonStrip mButtonStrip;
    TextView mAmountLabel;
    TextView mTipLabel;
    TextView mTotalLabel;
    TextView mEffectiveRateLabel;
    Button mSplitButton;
    String mCurrentAmount = "";
    BigDecimal mTippingRate = BigDecimal.ZERO;
    Tipping.Payment mPayment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);

        mAmountLabel = (TextView) findViewById(R.id.amount_label);
        mTipLabel = (TextView) findViewById(R.id.tip_label);
        mTotalLabel = (TextView) findViewById(R.id.total_label);
        mEffectiveRateLabel = (TextView) findViewById(R.id.effective_rate_label);
        mSplitButton = (Button) findViewById(R.id.split_button);

        mSplitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showSplitDialog();
            }
        });

        mButtonStrip = (ButtonStrip) findViewById(R.id.rate_button_strip);
        mButtonStrip.setObserver(this);

        ((NumericKeypad) findViewById(R.id.numeric_keypad)).setObserver(this);

        if (savedInstanceState != null) {
            mCurrentAmount = savedInstanceState.getString(CURRENT_AMOUNT);
        }

        setupButtonStrip();
        update();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString(CURRENT_AMOUNT, mCurrentAmount);
    }

    @Override
    protected void onResume() {
        super.onResume();
        setupButtonStrip();
        update();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void backspace() {
        if (mCurrentAmount.length() > 0) {
            mCurrentAmount = mCurrentAmount.substring(0, mCurrentAmount.length() - 1);
            update();
        }
    }

    @Override
    public void clear() {
        if (mCurrentAmount.length() > 0) {
            mCurrentAmount = "";
            update();
        }
    }

    @Override
    public void number(int n) {
        if (n == 0 && mCurrentAmount.length() == 0) {
            return;
        }

        if (mCurrentAmount.length() >= 6) {
            return;
        }

        mCurrentAmount = mCurrentAmount + String.valueOf(n);
        update();
    }

    @Override
    public void onButtonClicked(int index) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = prefs.edit();
        String rateString = "0.18";
        switch (index) {
            case 0:
                rateString = "0.15";
                break;
            case 1:
                rateString = "0.18";
                break;
            case 2:
                rateString = "0.20";
                break;
            default:
                break;
        }

        mTippingRate = new BigDecimal(rateString);
        editor.putString(TIPPING_RATE_KEY, rateString);
        editor.apply();
        update();
    }

    private void setupButtonStrip() {
        List<String> titles = new ArrayList<String>();

        boolean useUSLocale = PreferenceManager.getDefaultSharedPreferences(this).getBoolean(getString(R.string.pref_key_use_us_decimal_point), true);
        NumberFormat format = useUSLocale ? NumberFormat.getPercentInstance(Locale.US) : NumberFormat.getPercentInstance();
        format.setMinimumFractionDigits(0);
        titles.add(format.format(0.15));
        titles.add(format.format(0.18));
        titles.add(format.format(0.20));

        int rateIndex;
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        String rateString = prefs.getString(TIPPING_RATE_KEY, "");
        if (rateString.equals("0.15")) {
            rateIndex = 0;
            mTippingRate = new BigDecimal("0.15");
        } else if (rateString.equals("0.18")) {
            rateIndex = 1;
            mTippingRate = new BigDecimal("0.18");
        } else if (rateString.equals("0.20")) {
            rateIndex = 2;
            mTippingRate = new BigDecimal("0.20");
        } else {
            rateIndex = 1;
            mTippingRate = new BigDecimal("0.18");
        }

        mButtonStrip.addButtons(titles, rateIndex);
    }

    private void update() {
        BigDecimal amount;
        if (mCurrentAmount.length() == 0) {
            amount = BigDecimal.ZERO;
        } else {
            amount = new BigDecimal(mCurrentAmount).divide(new BigDecimal("100"));
        }

        mPayment = Tipping.getBestTipPayment(amount, mTippingRate);

        if (mPayment.total.compareTo(new BigDecimal("2")) < 0) {
            mSplitButton.setEnabled(false);
        } else {
            mSplitButton.setEnabled(true);
        }

        mAmountLabel.setText(decimalString(amount));
        mTipLabel.setText(decimalString(mPayment.tip));
        mTotalLabel.setText(decimalString(mPayment.total));

        BigDecimal roundedRate = mPayment.effectiveRate.setScale(3, RoundingMode.HALF_UP);
        mEffectiveRateLabel.setText(percentageString(roundedRate));
    }

    private String decimalString(BigDecimal n) {
        boolean useUSLocale = PreferenceManager.getDefaultSharedPreferences(this).getBoolean(getString(R.string.pref_key_use_us_decimal_point), true);
        NumberFormat format = useUSLocale ? NumberFormat.getInstance(Locale.US) : NumberFormat.getInstance();
        format.setMinimumFractionDigits(2);
        return format.format(n);
    }

    private String currencyStringUS(BigDecimal n) {
        NumberFormat format = NumberFormat.getCurrencyInstance(Locale.US);
        format.setMinimumFractionDigits(2);
        return format.format(n);
    }

    private String percentageString(BigDecimal n) {
        if (n.equals(BigDecimal.ZERO)) {
            return getString(R.string.info_text_non_percentage);
        }

        boolean useUSLocale = PreferenceManager.getDefaultSharedPreferences(this).getBoolean(getString(R.string.pref_key_use_us_decimal_point), true);
        NumberFormat format = useUSLocale ? NumberFormat.getPercentInstance(Locale.US) : NumberFormat.getPercentInstance();
        format.setMaximumFractionDigits(1);
        format.setMinimumFractionDigits(1);
        return format.format(n);
    }

    private void showSplitDialog() {
        BigDecimal splitAmount = mPayment.total.divide(new BigDecimal(2), 2, BigDecimal.ROUND_DOWN);
        String splitAmountString = currencyStringUS(splitAmount);
        Bundle args = new Bundle();

        String[] items = {
                getString(R.string.request_action_prefix) + " " + splitAmountString,
                getString(R.string.send_action_prefix) + " " + splitAmountString,
                getString(R.string.cancel_action)
        };

        args.putString(SplitDialogFragment.LOCALIZED_TITLE, getString(R.string.split_dialog_title));
        args.putString(SplitDialogFragment.AMOUNT, splitAmountString);
        args.putStringArray(SplitDialogFragment.LOCALIZED_ITEMS, items);
        DialogFragment newFragment = new SplitDialogFragment();
        newFragment.setArguments(args);
        newFragment.show(getFragmentManager(), "dialog");
    }

    public static class SplitDialogFragment extends DialogFragment {
        public static final String LOCALIZED_TITLE = "Title";
        public static final String AMOUNT = "Amount";
        public static final String LOCALIZED_ITEMS = "LocalizedItems";
        String mTitle;
        String mSplitAmount;
        String mItems[];

        @Override
        public void setArguments(Bundle args) {
            super.setArguments(args);
            mSplitAmount = args.getString(AMOUNT);
            mItems = args.getStringArray(LOCALIZED_ITEMS);
            mTitle = args.getString(LOCALIZED_TITLE);
        }

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

            builder.setTitle(mTitle)
                    .setItems(mItems, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            if (which != 0 && which != 1) {
                                return;
                            }

                            Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "", null));
                            intent.putExtra(Intent.EXTRA_SUBJECT, mSplitAmount);
                            if (which == 0) {
                                intent.putExtra(Intent.EXTRA_CC, new String[]{"request@square.com"});
                            } else {
                                intent.putExtra(Intent.EXTRA_CC, new String[]{"cash@square.com"});
                            }
                            startActivity(intent);
                        }
                    });
            return builder.create();
        }
    }
}
