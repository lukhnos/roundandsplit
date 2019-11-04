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

import UIKit

struct Settings {
    static let TippingRatesUpdatedNotificationName = Notification.Name("TippingRatesUpdated")

    static let UseDecimalPointKey = "UseDecimalPoint"
    private static let RatesKey = "Rates"

    fileprivate static let defaultBoolValues = [
        UseDecimalPointKey: true
    ]

    struct Rate : Equatable {
        var value : Decimal
        init (_ rateStr: String) {
            value = Decimal(rateStr)
        }

        var decimalString : String {
            return value.rawStringWithPeriodSeparator()
        }

        var percentageString: String {
            get {
                let r = value * Decimal(100)
                return "\(r.rawStringWithPeriodSeparator())%"
            }
        }

        static func fromStrings(_ rates: [String]) -> [Rate] {
            return rates.map { (rate) -> Rate in Rate(rate) }
        }

        static func toStrings(_ rates: [Rate]) -> [String] {
            return rates.map { (rate) -> String in rate.decimalString }
        }
    }

    static let SupportedTippingRates = [
        Rate("0.05"),
        Rate("0.10"),
        Rate("0.15"),
        Rate("0.18"),
        Rate("0.20"),
        Rate("0.25"),
        Rate("0.30"),
        Rate("0.35"),
        Rate("0.40"),
        Rate("0.45"),
        Rate("0.50"),
        Rate("0.55"),
        Rate("0.60"),
        Rate("0.65"),
        Rate("0.70"),
        Rate("0.75")
    ]

    static let DefaultTippingRates = [Rate("0.15"), Rate("0.18"), Rate("0.20")]

    static var tippingRate : Rate {
    get {
        if let rateStr = defaults.string(forKey: TippingRateKey) {
            let rate = Rate(rateStr)
            if tippingRates.contains(rate) {
                return rate
            }
        }
        return tippingRates[1]
    }
    set {
        defaults.setValue(newValue.decimalString, forKey: TippingRateKey)
    }
    }

    static var tippingRates : [Rate] {
        get {
            if let rateStrings = defaults.array(forKey: RatesKey) as? [String] {
                return validatedTippingRates(Rate.fromStrings(rateStrings))
            }
            return DefaultTippingRates
        }
        set {
            assert(newValue.count == 3)

            // Make sure the current rate is adjusted accordingly.
            let currentRateIndex = tippingRates.firstIndex(of: tippingRate)!
            tippingRate = newValue[currentRateIndex]

            defaults.set(Rate.toStrings(newValue), forKey: RatesKey)

            NotificationCenter.default.post(name: TippingRatesUpdatedNotificationName, object: self)
        }
    }

    static func validatedTippingRates(_ rates: [Rate]) -> [Rate] {
        guard rates.count == 3 else {
            return DefaultTippingRates
        }

        for rate in rates {
            if !SupportedTippingRates.contains(rate) {
                return DefaultTippingRates
            }
        }

        return rates
    }

    static func boolForKey(_ key: String) -> Bool {
        if let value: Bool = defaults.value(forKey: key) as? Bool {
            return value
        }

        if let value: Bool = defaultBoolValues[key] {
            return value
        }

        return false
    }

    static func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey:key)
    }

    fileprivate static let TippingRateKey = "TippingRate"

    fileprivate static var defaults : UserDefaults {
        get {
            return UserDefaults.standard
    }
    }
}
