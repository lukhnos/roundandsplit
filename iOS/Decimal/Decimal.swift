//
// A NSDecimalNumber wrapper modeled after number classes written in C++.
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

struct Decimal : Equatable, Comparable {

    var number: NSDecimalNumber;

    init(_ n: NSDecimalNumber) {
        number = n
    }

    init(_ n: Int) {
        number = NSDecimalNumber(integer: n)
    }

    init(_ n: String) {
        number = NSDecimalNumber(string: n)
    }

    init(mantissa: Int, exponent: Int) {
        let n = mantissa < 0
        let m = CUnsignedLongLong(n ? -mantissa : mantissa)
        let e = CShort(exponent)
        number = NSDecimalNumber(mantissa: m, exponent: e, isNegative: n)
    }

    func rounded(mode: NSRoundingMode, _ scale: Int) -> Decimal {
        let r = Rounder(mode: mode, scale: scale)
        let n = number.decimalNumberByRoundingAccordingToBehavior(r)
        return Decimal(n)
    }

    func rawString() -> String {
        return number.stringValue
    }

    func string(formatter: NSNumberFormatter) -> String {
        return formatter.stringFromNumber(number)
    }

    class Rounder : NSDecimalNumberBehaviors {
        var mode: NSRoundingMode;
        var roundingScale : Int16

        init(mode m: NSRoundingMode, scale s: Int) {
            mode = m
            roundingScale = Int16(s)
        }

        func roundingMode() -> NSRoundingMode {
            return mode
        }

        func scale() -> Int16 {
            return roundingScale
        }

        func exceptionDuringOperation(operation: Selector, error: NSCalculationError, leftOperand: NSDecimalNumber, rightOperand: NSDecimalNumber) -> NSDecimalNumber?
        {
            return NSDecimalNumber.notANumber()
        }
    }
}

func==(lhs: Decimal, rhs: Decimal) -> Bool {
    return lhs.number == rhs.number
}

func <(lhs: Decimal, rhs: Decimal) -> Bool {
    return lhs.number.compare(rhs.number) == NSComparisonResult.OrderedAscending
}

func + (left: Decimal, right: Decimal) -> Decimal {
    return Decimal(left.number.decimalNumberByAdding(right.number))
}

func - (left: Decimal, right: Decimal) -> Decimal {
    return Decimal(left.number.decimalNumberBySubtracting(right.number))
}

func * (left: Decimal, right: Decimal) -> Decimal {
    return Decimal(left.number.decimalNumberByMultiplyingBy(right.number))
}

func / (left: Decimal, right: Decimal) -> Decimal {
    return Decimal(left.number.decimalNumberByDividingBy(right.number))
}

func roundUp(number: Decimal, _ scale: Int = 0) -> Decimal {
    return number.rounded(.RoundUp, scale)
}

func roundDown(number: Decimal, _ scale: Int = 0) -> Decimal {
    return number.rounded(.RoundDown, scale)
}

func round(number: Decimal, _ scale: Int = 0) -> Decimal {
    return number.rounded(.RoundPlain, scale)
}

func abs(number: Decimal) -> Decimal {
    if number < Decimal(0) {
        return number * Decimal(-1)
    } else {
        return number
    }
}
