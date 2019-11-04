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

import XCTest

class RoundAndSplitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        self.measure() {
        }
    }
    
    func testRate() {
        XCTAssertEqual(Settings.Rate("0.18").percentageString, "18%")
    }

    func testRatesConversion() {
        XCTAssertEqual(Settings.Rate.fromStrings(["0.15", "0.18"]), [Settings.Rate("0.15"), Settings.Rate("0.18")])
    }

    func testValidatedRates() {
        let p = Settings.Rate.fromStrings([])
        let q = Settings.Rate.fromStrings(["0.05", "0.10", "0.35"])
        let r = Settings.Rate.fromStrings(["0.05", "0.10"])
        let s = Settings.Rate.fromStrings(["0.05"])
        let t = Settings.Rate.fromStrings(["0.20", "0.18", "0.10"])
        let u = Settings.Rate.fromStrings(["0.20", "0.03", "0.10"])

        XCTAssertEqual(Settings.validatedTippingRates(p), Settings.DefaultTippingRates)
        XCTAssertEqual(Settings.validatedTippingRates(q), [Settings.Rate("0.05"), Settings.Rate("0.10"), Settings.Rate("0.35")])
        XCTAssertEqual(Settings.validatedTippingRates(r), Settings.DefaultTippingRates)
        XCTAssertEqual(Settings.validatedTippingRates(s), Settings.DefaultTippingRates)
        XCTAssertEqual(Settings.validatedTippingRates(t), [Settings.Rate("0.20"), Settings.Rate("0.18"), Settings.Rate("0.10")])
        XCTAssertEqual(Settings.validatedTippingRates(u), Settings.DefaultTippingRates)
    }
}
