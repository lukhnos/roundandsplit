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

struct Style {
    enum ScreenSize {
        case normal, large, extraLarge
    }
    typealias FontSizes = Dictionary<ScreenSize, UIFont>

    static func hexColor(_ color: UInt) -> UIColor {
        let r = (CGFloat)((color >> 16) & 0xff) / 255.0
        let g = (CGFloat)((color >> 8) & 0xff) / 255.0
        let b = (CGFloat)(color & 0xff) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    static func tabularFigureFont(_ font: UIFont) -> UIFont {
        let attrs = [
            UIFontDescriptor.AttributeName.featureSettings: [[
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector],]]
        let fontDescriptor : UIFontDescriptor = font.fontDescriptor
        let tabularFigureDescriptor = fontDescriptor.addingAttributes(attrs)
        let tabularFigureFont = UIFont(descriptor: tabularFigureDescriptor, size: 0.0)
        return tabularFigureFont
    }

    static func regularFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Light", size: size)!
    }

    static func boldFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Regular", size: size)!
    }

    static func fontSizes(_ base: UIFont, _ largeSize: CGFloat, _ extraLargeSize: CGFloat) -> FontSizes {
        return [
            .normal: base,
            .large: UIFont(descriptor: base.fontDescriptor, size: largeSize),
            .extraLarge: UIFont(descriptor: base.fontDescriptor, size: extraLargeSize)
        ]
    }

    static let infoDisplayBackgroundColor = Style.hexColor(0xf7f7f7)

    static let textColor = Style.hexColor(0x202020)

    static let moreInfoButtonNormalColor = Style.hexColor(0x909090)
    static let moreInfoButtonHighlightedColor = Style.hexColor(0xb0b0b0)

    static let buttonTitleColorNormal = Style.hexColor(0x59ac53)
    static let buttonTitleColorHighlighted = Style.hexColor(0x9dd498)
    static let buttonTitleColorDisabled = Style.hexColor(0xb0b0b0)

    static let dividingLineColor = Style.hexColor(0xeeeeee)
    static let effectiveRateLabelColor = textColor

    static let keypadHighlightColor = Style.hexColor(0x86ca7f)

    static let infoButtonFonts = Style.fontSizes(UIFont(name: "FiraSans-Medium", size: 16)!, 18, 22)
    static let billedAmountFonts = Style.fontSizes(Style.regularFont(40), 46, 52)
    static let buttonStripFonts = Style.fontSizes(Style.regularFont(20), 24, 26)
    static let descriptionFonts = Style.fontSizes(Style.regularFont(22), 26, 28)
    static let valueFonts = Style.fontSizes(Style.tabularFigureFont(Style.boldFont(24)), 28, 31)
    static let effectiveRateDescriptionFonts = Style.fontSizes(Style.regularFont(14), 16, 18)
    static let effectiveRateValueFonts = Style.fontSizes(Style.regularFont(14), 16, 18)
    static let splitButtonFonts = Style.fontSizes(Style.regularFont(14), 16, 18)
    static let keypadLabelFonts = Style.fontSizes(Style.regularFont(24), 28, 31)
    static let keypadSmallLabelFonts = Style.fontSizes(Style.regularFont(19), 22, 25)
}
