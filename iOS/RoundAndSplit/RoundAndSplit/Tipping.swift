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

import Foundation

struct Tip {
    let amount : Decimal
    let tip : Decimal
    let total : Decimal
    let rate : Decimal
    let effectiveRate : Decimal

    init() {
        amount = Decimal(0)
        tip = Decimal(0)
        total = Decimal(0)
        rate = Decimal(0)
        effectiveRate = Decimal(0)
    }

    init(amount a: Decimal, rate r: Decimal) {
        amount = a
        rate = r
        tip = amount * rate

        if (tip > Decimal(0)) {
            effectiveRate = rate
        } else {
            effectiveRate = Decimal(0)
        }

        total = amount + tip
    }

    init(tip t: Tip, total actualTotal: Decimal) {
        amount = t.amount
        rate = t.rate
        total = actualTotal

        if (actualTotal > amount) {
            tip = actualTotal - amount
            effectiveRate = tip / amount
        } else {
            tip = Decimal(0)
            effectiveRate = Decimal(0)
        }
    }

    init(amount a: Decimal, makeToTotal actualTotal: Decimal) {
        amount = a
        rate = Decimal(0)
        tip = actualTotal - a
        total = actualTotal
        effectiveRate = Decimal(0)
    }

    func shortDescription() -> String {
        return "\(amount.rawString()) + \(tip.rawString()) = \(total.rawString()) @ \(rate.rawString()), actual: \(effectiveRate.rawString())"
    }
}

func roundedTippings(amount: Decimal, rate: Decimal) -> [Tip] {
    let tip = Tip(amount: amount, rate: rate)
    var tippings : [Tip] = []

    let roundedUpTotal = roundUp(tip.total)
    let roundedDownTotal = roundDown(tip.total)

    tippings.append(Tip(tip: tip, total: roundedUpTotal))
    tippings.append(Tip(tip: tip, total: roundedDownTotal))

    return tippings
}

func bestTip(amount: Decimal, rate: Decimal) -> Tip {
    if (rate <= Decimal(0)) {
        return Tip(amount: amount, rate: Decimal(0))
    }

    if (amount <= Decimal(0)) {
        return Tip(amount: Decimal(0), rate: rate)
    }

    if (amount < Decimal(2)) {
        return Tip(amount: amount, makeToTotal: roundUp(amount, 0))
    }

    let tippings = roundedTippings(amount, rate)

    var tip = tippings[0]
    var delta = abs(tip.rate - tip.effectiveRate)
    for t in tippings[1...(tippings.count - 1)] {
        var delta2 = abs(t.rate - t.effectiveRate)
        if delta2 < delta {
            delta = delta2
            tip = t
        }
    }

    if tip.total < amount {
        return Tip(amount: amount, makeToTotal: roundUp(amount, 0))
    }

    return tip
}
