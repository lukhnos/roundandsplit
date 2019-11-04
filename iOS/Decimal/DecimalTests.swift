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

class DecimalTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasics() {
        let p = Decimal(0)
        let q = Decimal("0")
        XCTAssertEqual(p, q)
    }

    func testStringConversion() {
        let p = Decimal(1) / Decimal(20)
        let q = Decimal("0.05")
        XCTAssertEqual(p, q)
    }

    func testDoNotParseEuropeanDecimalSeparator() {
        let p = Decimal(1) / Decimal(20)
        let q = Decimal(0)
        let r = Decimal("0,05")
        XCTAssertNotEqual(p, r)
        XCTAssertEqual(q, r)
    }

    func testRawStringWithPeriodSeparator() {
        let p = Decimal(1) / Decimal(20)
        XCTAssertEqual(p.rawStringWithPeriodSeparator(), "0.05")
    }
}
