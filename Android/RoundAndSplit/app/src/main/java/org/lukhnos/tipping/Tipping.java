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

package org.lukhnos.tipping;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Tipping {
    public static class Payment {
        public BigDecimal amount;
        public BigDecimal total;
        public BigDecimal tip;
        public BigDecimal effectiveRate;

        static Payment fromTotal(BigDecimal amount, BigDecimal total) {
            Payment payment = new Payment();
            payment.amount = amount;
            payment.total = total;
            payment.tip = total.subtract(amount);
            payment.effectiveRate = payment.tip.divide(amount, 4, BigDecimal.ROUND_HALF_UP);
            return payment;
        }
    }

    public static Payment getBestTipPayment(BigDecimal amount, BigDecimal rate) {
        BigDecimal two = new BigDecimal("2");
        if (amount.compareTo(BigDecimal.ZERO) == 0) {
            Payment payment = new Payment();
            payment.amount = BigDecimal.ZERO;
            payment.tip = BigDecimal.ZERO;
            payment.total = BigDecimal.ZERO;
            payment.effectiveRate = BigDecimal.ZERO;
            return payment;
        } else if (amount.compareTo(two) < 0) {
            Payment payment = new Payment();

            BigDecimal tip;
            if (amount.compareTo(BigDecimal.ONE) <= 0) {
                tip = BigDecimal.ONE.subtract(amount);
            } else {
                tip = two.subtract(amount);
            }

            payment.amount = amount;
            payment.tip = tip;
            payment.total = amount.add(tip);
            payment.effectiveRate = BigDecimal.ZERO;
            return payment;
        }

        BigDecimal total = amount.add(amount.multiply(rate));
        List<Payment> payments = new ArrayList<Payment>();

        // Add choices
        BigDecimal roundedUpTotal = total.setScale(0, BigDecimal.ROUND_UP);
        payments.add(Payment.fromTotal(amount, roundedUpTotal));

        BigDecimal roundedDownTotal = total.setScale(0, BigDecimal.ROUND_DOWN);
        if (roundedDownTotal.compareTo(amount) > 0) {
            payments.add(Payment.fromTotal(amount, roundedDownTotal));
        }

        Payment payment = payments.get(0);
        BigDecimal delta = payment.effectiveRate.subtract(rate).abs();

        for (Payment newPayment : payments) {
            BigDecimal newDelta = newPayment.effectiveRate.subtract(rate).abs();
            if (newDelta.compareTo(delta) < 0) {
                delta = newDelta;
                payment = newPayment;
            }
        }

        return payment;
    }
}
