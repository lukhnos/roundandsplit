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
import CoreText
import MessageUI
import AssetsLibrary

class MainViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ButtonStripViewDelegate, NumericKeypadDelegate {

    @IBOutlet var infoButton : RoundedButton!
    @IBOutlet var billedAmountLabel : UILabel!
    @IBOutlet var topSeparatorView : UIView!
    @IBOutlet var infoAreaInnerView : ExtendedHitAreaView!
    @IBOutlet var infoDisplayView : UIView!
    @IBOutlet var bottomSeparatorView : UIView!
    @IBOutlet var numericKeypadView : NumericKeypadView!

    @IBOutlet var buttonStripView : ButtonStripView!
    @IBOutlet var tipDescription : UILabel!
    @IBOutlet var tipLabel : UILabel!
    @IBOutlet var totalAmountDescription : UILabel!
    @IBOutlet var totalAmountLabel : UILabel!
    @IBOutlet var effectiveRateDescriptionLabel : UILabel!
    @IBOutlet var effectiveRateLabel : UILabel!
    @IBOutlet var splitAndPayButton : SquareBorderButton!

    @IBOutlet var headerViewHeight : NSLayoutConstraint!
    @IBOutlet var infoAreaInnerViewTopSpacing : NSLayoutConstraint!
    @IBOutlet var infoAreaInnerViewBottomSpacing : NSLayoutConstraint!
    @IBOutlet var infoAreaInnerViewLeadingSpace : NSLayoutConstraint!
    @IBOutlet var infoAreaInnerViewTrailingSpace : NSLayoutConstraint!
    @IBOutlet var buttonStripHeight : NSLayoutConstraint!
    @IBOutlet var splitButtonHeight : NSLayoutConstraint!
    @IBOutlet var splitButtonBottomSpacing : NSLayoutConstraint!
    @IBOutlet var infoButtonWidth : NSLayoutConstraint!
    @IBOutlet var infoButtonHeight : NSLayoutConstraint!
    @IBOutlet var infoAreaHeight : NSLayoutConstraint!
    @IBOutlet var infoTextTopSpacing : NSLayoutConstraint!
    @IBOutlet var infoTextBottomSpacing : NSLayoutConstraint!
    @IBOutlet var effectiveRateLabelTrailingSpace : NSLayoutConstraint!

    var actionSheet : UIActionSheet!

    var keypadString = ""
    var billedAmount : Decimal = Decimal(0)
    var currentRate : Decimal = Settings.tippingRate.toDecimal()
    var currentTip : Tip = Tip()
    var currencyFormatter = NSNumberFormatter()
    var percentageFormatter = NSNumberFormatter()
    var effectiveRateLabelTrailingSpaceConstant : CGFloat = 0.0

    // For requesting/paying money
    var requestCurrencyFormatter = NSNumberFormatter()
    var requestingMoney = false

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let height = UIScreen.mainScreen().bounds.size.height
        var screenSize : Style.ScreenSize = .Normal
        if height > 480 && height < 667 {
            infoAreaHeight.constant += 24
            infoTextTopSpacing.constant += 12
            infoTextBottomSpacing.constant += 10
            splitButtonBottomSpacing.constant += 2
        } else if height >= 667 && height < 736 {
            infoButtonWidth.constant = 40
            infoButtonHeight.constant = 40
            infoButton.offsetX = -0.5
            infoButton.offsetY = -0.5
            headerViewHeight.constant += 10
            buttonStripHeight.constant += 6
            splitButtonHeight.constant += 4
            infoAreaHeight.constant += 64
            infoTextTopSpacing.constant += 12
            infoTextBottomSpacing.constant += 6
            splitButtonBottomSpacing.constant += 6
            screenSize = .Large
        } else if height >= 736 {
            infoButtonWidth.constant = 44
            infoButtonHeight.constant = 44
            infoButton.offsetX = -1
            infoButton.offsetY = -1
            headerViewHeight.constant += 18
            buttonStripHeight.constant += 10
            splitButtonHeight.constant += 8
            infoAreaHeight.constant += 72
            infoTextTopSpacing.constant += 12
            infoTextBottomSpacing.constant += 6
            splitButtonBottomSpacing.constant += 6
            screenSize = .ExtraLarge
        }

        // Expand the hit area of the inner info view so as to expand the button strip's hit area.
        var expandedHitAreaEdgeInset = UIEdgeInsetsMake(-infoAreaInnerViewTopSpacing.constant, -infoAreaInnerViewLeadingSpace.constant, -infoAreaInnerViewBottomSpacing.constant/2, -infoAreaInnerViewTrailingSpace.constant)
        infoAreaInnerView.extendedHitAreaEdgeInset = expandedHitAreaEdgeInset

        // Now expand the button strip view's hit area.
        expandedHitAreaEdgeInset.bottom = -infoTextTopSpacing.constant
        buttonStripView.extendedHitAreaEdgeInset = expandedHitAreaEdgeInset

        // And the Split button's.
        let splitButtonHitAreaPadding = -infoAreaInnerViewBottomSpacing.constant/2
        splitAndPayButton.extendedHitAreaEdgeInset = UIEdgeInsetsMake(splitButtonHitAreaPadding, 0, splitButtonHitAreaPadding, 0)

        infoButton.titleLabel?.font = Style.infoButtonFonts[screenSize]!

        for label in [billedAmountLabel, tipDescription, tipLabel, totalAmountDescription, totalAmountLabel] {
            label.textColor = Style.textColor
        }
        billedAmountLabel.font = Style.billedAmountFonts[screenSize]!
        for label in [tipDescription, totalAmountDescription] {
            label.font = Style.descriptionFonts[screenSize]!
        }
        for label in [tipLabel, totalAmountLabel] {
            label.font = Style.valueFonts[screenSize]!
        }
        effectiveRateDescriptionLabel.font = Style.effectiveRateDescriptionFonts[screenSize]!
        effectiveRateLabel.font = Style.effectiveRateValueFonts[screenSize]!

        effectiveRateLabelTrailingSpaceConstant = effectiveRateLabelTrailingSpace.constant

        infoDisplayView.backgroundColor = Style.infoDisplayBackgroundColor

        topSeparatorView.backgroundColor = Style.dividingLineColor
        bottomSeparatorView.backgroundColor = Style.dividingLineColor

        effectiveRateDescriptionLabel.textColor = Style.effectiveRateLabelColor
        effectiveRateLabel.textColor = Style.effectiveRateLabelColor

        infoButton.normalFillColor = Style.moreInfoButtonNormalColor
        infoButton.highlightedFillColor = Style.moreInfoButtonHighlightedColor
        infoButton.disabledFillColor = Style.moreInfoButtonHighlightedColor

        infoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        infoButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        infoButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)

        splitAndPayButton.titleLabel?.font = Style.splitButtonFonts[screenSize]!
        splitAndPayButton.setTitleColor(Style.buttonTitleColorNormal, forState: .Normal)
        splitAndPayButton.setTitleColor(Style.buttonTitleColorHighlighted, forState: .Highlighted)
        splitAndPayButton.setTitleColor(Style.buttonTitleColorDisabled, forState: .Disabled)

        buttonStripView.buttonTitleFont = Style.buttonStripFonts[screenSize]!
        buttonStripView.buttonTitleColorNormal = Style.buttonTitleColorNormal
        buttonStripView.buttonTitleColorHighlighted = Style.buttonTitleColorHighlighted
        buttonStripView.buttonTitleColorSelected = Style.buttonTitleColorNormal
        buttonStripView.underlineColor = Style.buttonTitleColorNormal
        buttonStripView.delegate = self

        var activeIndex : Int
        switch Settings.tippingRate {
        case .Tip15Percent:
            activeIndex = 0
        case .Tip18Percent:
            activeIndex = 1
        case .Tip20Percent:
            activeIndex = 2
        }

        buttonStripView.addButtonsWithLabels(["15%", "18%", "20%"], activeIndex: activeIndex)

        numericKeypadView.gridView.gridColor = Style.dividingLineColor
        numericKeypadView.keyPadTextColor = Style.textColor
        numericKeypadView.keyPadHighlightColor = Style.keypadHighlightColor
        numericKeypadView.setLabelFonts(Style.keypadLabelFonts[screenSize]!, clearFont: Style.keypadSmallLabelFonts[screenSize]!)
        numericKeypadView.setClearLabelInset(UIEdgeInsetsMake(-1.0, 0, 0.0, 0))
        numericKeypadView.setBackspaceLabelInset(UIEdgeInsetsMake(-1.0, 0, 0.0, 0))
        numericKeypadView.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentLocaleDidChange:"), name: NSCurrentLocaleDidChangeNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Expand the hit area of the More Info button.
        let hitAreaPadding = -((headerViewHeight.constant - infoButton.frame.height) / 2)
        infoButton.extendedHitAreaEdgeInset = UIEdgeInsetsMake(hitAreaPadding, hitAreaPadding, hitAreaPadding * 0.5, hitAreaPadding)
    }

    override func viewWillAppear(animated: Bool) {
        updateFormatters()
        update()
    }

    func didTapButtonInStripView(strip: ButtonStripView, index: Int) {
        var rate : Settings.TippingRate

        switch index {
        case 0:
            rate = .Tip15Percent
        case 1:
            rate = .Tip18Percent
        case 2:
            rate = .Tip20Percent
        default:
            rate = Settings.defaultTippingRate
        }
        Settings.tippingRate = rate
        currentRate = rate.toDecimal()
        update()
    }

    func update() {
        if keypadString.isEmpty {
            billedAmount = Decimal(0)
        } else {
            billedAmount = Decimal(keypadString) / Decimal("100")
        }

        if billedAmount < Decimal("1.00") {
            splitAndPayButton.enabled = false
        } else {
            splitAndPayButton.enabled = true
        }

        billedAmountLabel.text = billedAmount.string(currencyFormatter)
        currentTip = bestTip(billedAmount, rate: currentRate)
        tipLabel.text = currentTip.tip.string(currencyFormatter)
        tipLabel.accessibilityLabel = String(format: Utilities.L("Tips: %@"), tipLabel.text!)
        totalAmountLabel.text = currentTip.total.string(currencyFormatter)
        totalAmountLabel.accessibilityLabel = String(format: Utilities.L("Total: %@"), totalAmountLabel.text!)

        let rate = currentTip.effectiveRate
        if rate == Decimal(0) {
            effectiveRateLabel.text = "–"
            effectiveRateLabel.accessibilityLabel = Utilities.L("No effective rate")
            effectiveRateLabelTrailingSpace.constant = effectiveRateLabelTrailingSpaceConstant + 2.5
        } else {
            effectiveRateLabel.text = currentTip.effectiveRate.string(percentageFormatter)
            effectiveRateLabel.accessibilityLabel = String(format: Utilities.L("Effective rate: %@"), effectiveRateLabel.text!)
            effectiveRateLabelTrailingSpace.constant = effectiveRateLabelTrailingSpaceConstant
        }
    }

    func backspaceTapped() {
        if !keypadString.isEmpty {
            keypadString = keypadString.substringToIndex(keypadString.endIndex.predecessor())
            update()
        }
    }

    func clearTapped() {
        keypadString = ""
        update()
    }

    func numberTapped(number: Int) {
        if number == 0 && keypadString.isEmpty {
            return
        }

        if keypadString.characters.count < 6 {
            keypadString = keypadString + String(format: "%d", number)
            update()
        }
    }

    @IBAction func requestOrPay() {
        let actionSheet = UIActionSheet()
        let amount = (currentTip.total / Decimal("2")).string(requestCurrencyFormatter)
        actionSheet.title = "Split with Square® Cash?\nYou can adjust the amount later."
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("Request \(amount)")
        actionSheet.addButtonWithTitle("Pay \(amount)")
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 2
        actionSheet.showInView(self.view)
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex < 2) {
            if !MFMailComposeViewController.canSendMail() {
                Utilities.showEmailDisabledAlert()
                return
            }

            let splitAmount = (currentTip.total / Decimal("2")).string(requestCurrencyFormatter)

            requestingMoney = (buttonIndex == 0)
            let addr =  requestingMoney ? "request@square.com" : "cash@square.com"
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(splitAmount)
            controller.setCcRecipients([addr])
            presentViewController(controller, animated: true, completion: {})
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: {})

        if result.rawValue == MFMailComposeResultSent.rawValue {
            let alertView = UIAlertView()
            alertView.title = "Check Your Email"
            if requestingMoney {
                alertView.message = "You will receive an email from Square® to confirm your request."
            } else {
                alertView.message = "You will receive an email from Square® to confirm your payment."
            }
            alertView.addButtonWithTitle("Dismiss")
            alertView.cancelButtonIndex = 0
            alertView.show()
        }
    }

    func currentLocaleDidChange(notification: NSNotification!) {
        updateFormatters()
        update()
    }

    func updateFormatters() {
        var locale : NSLocale? = nil
        if Settings.boolForKey(Settings.UseDecimalPointKey) {
            locale = NSLocale(localeIdentifier: "en-us")
        }

        currencyFormatter.numberStyle = .DecimalStyle
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.locale = locale

        percentageFormatter.numberStyle = .PercentStyle
        percentageFormatter.roundingMode = .RoundHalfUp
        percentageFormatter.minimumFractionDigits = 1
        percentageFormatter.locale = locale

        let requestLocale = NSLocale(localeIdentifier: "en-us")
        requestCurrencyFormatter.numberStyle = .CurrencyStyle
        requestCurrencyFormatter.minimumFractionDigits = 2
        requestCurrencyFormatter.locale = requestLocale
    }

    // This saves the default image with the needed UI elements. Not used in
    // the app, but can be dropped it to replace e.g. the Info button
    // to save time creating the default images.
    func saveDefaultImage() {
        let hiddenViews : [UIView] = [
            infoButton,
            billedAmountLabel,
            tipDescription,
            tipLabel,
            totalAmountDescription,
            totalAmountLabel,
            effectiveRateDescriptionLabel,
            effectiveRateLabel,
            numericKeypadView,
            splitAndPayButton
        ]

        for view in hiddenViews {
            view.hidden = true
        }

        buttonStripView.deselect()

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates:true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let library = ALAssetsLibrary()
        library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(image), metadata: nil) { (_, _) -> Void in
            for view in hiddenViews {
                view.hidden = false
            }
        }
    }
}
