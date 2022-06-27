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
package org.lukhnos.tipping

import java.math.BigDecimal
import java.util.ArrayList

object Tipping {
    fun getBestTipPayment(amount: BigDecimal, rate: BigDecimal?): Payment {
        val two = BigDecimal("2")
        if (amount.compareTo(BigDecimal.ZERO) == 0) {
            val payment = Payment()
            payment.amount = BigDecimal.ZERO
            payment.tip = BigDecimal.ZERO
            payment.total = BigDecimal.ZERO
            payment.effectiveRate = BigDecimal.ZERO
            return payment
        } else if (amount < two) {
            val payment = Payment()
            val tip: BigDecimal = if (amount <= BigDecimal.ONE) {
                BigDecimal.ONE.subtract(amount)
            } else {
                two.subtract(amount)
            }
            payment.amount = amount
            payment.tip = tip
            payment.total = amount.add(tip)
            payment.effectiveRate = BigDecimal.ZERO
            return payment
        }
        val total = amount.add(amount.multiply(rate))
        val payments: MutableList<Payment> = ArrayList()

        // Add choices
        val roundedUpTotal = total.setScale(0, BigDecimal.ROUND_UP)
        payments.add(Payment.fromTotal(amount, roundedUpTotal))
        val roundedDownTotal = total.setScale(0, BigDecimal.ROUND_DOWN)
        if (roundedDownTotal > amount) {
            payments.add(Payment.fromTotal(amount, roundedDownTotal))
        }
        var payment = payments[0]
        var delta = payment.effectiveRate.subtract(rate).abs()
        for (newPayment in payments) {
            val newDelta = newPayment.effectiveRate.subtract(rate).abs()
            if (newDelta < delta) {
                delta = newDelta
                payment = newPayment
            }
        }
        return payment
    }

    class Payment {
        var amount: BigDecimal = BigDecimal.ZERO
        var total: BigDecimal = BigDecimal.ZERO
        var tip: BigDecimal = BigDecimal.ZERO
        var effectiveRate: BigDecimal = BigDecimal.ZERO

        companion object {
            fun fromTotal(amount: BigDecimal, total: BigDecimal): Payment {
                val payment = Payment()
                payment.amount = amount
                payment.total = total
                payment.tip = total.subtract(amount)
                payment.effectiveRate = payment.tip.divide(amount, 4, BigDecimal.ROUND_HALF_UP)
                return payment
            }
        }
    }
}