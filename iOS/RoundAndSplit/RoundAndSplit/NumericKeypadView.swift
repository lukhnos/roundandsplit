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

protocol NumericKeypadDelegate {
    func numberTapped(number: Int)
    func clearTapped()
    func backspaceTapped()
}

class NumericKeypadView : UIView {
    var delegate : NumericKeypadDelegate?
    var gridView = GridView()

    var keyPadBackgroudColor : UIColor = UIColor.whiteColor() {
        didSet {
            for label in labels {
                label.layer.backgroundColor = keyPadBackgroudColor.CGColor
            }
        }
    }

    var keyPadHighlightColor = UIColor.lightGrayColor()
    var keyPadTextColor : UIColor = UIColor.blackColor() {
        didSet {
            for label in labels {
                label.textColor = keyPadTextColor
            }
        }
    }

    var keyPadTextHighlightColor = UIColor.whiteColor()

    private var selectedKey = -1
    private var labels = [OffsetLabel]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        for i in 0..<12 {
            var label : OffsetLabel
            label = OffsetLabel(frame: CGRectZero)

            // Add zero-width space (U+200B) to work around the problem on
            // iOS 7 that, if there's only one number character, tabular
            // figure won't be used.
            var keyStr : NSString
            switch i {
            case 9:
                keyStr = "\u{200b}CLEAR\u{200b}"
            case 10:
                keyStr = "\u{200b}0\u{200b}"
            case 11:
                keyStr = "\u{200b}⌫\u{200b}"
            default:
                keyStr = NSString(format: "\u{200b}%d\u{200b}", i + 1)
            }

            label.text = keyStr
            label.numberOfLines = 1
            label.textColor = keyPadTextColor
            label.accessibilityTraits |= UIAccessibilityTraitButton

            labels.append(label)
            label.layer.backgroundColor = keyPadBackgroudColor.CGColor
            label.textAlignment = NSTextAlignment.Center
            label.opaque = true
            addSubview(label)
        }

        gridView.backgroundColor = UIColor.clearColor()
        gridView.opaque = true
        addSubview(gridView)
    }

    func setLabelFonts(numberFont: UIFont, clearFont: UIFont) {
        for i in 0..<12 {
            var label = labels[i]

            switch i {
            case 9:
                label.font = clearFont
            case 11:
                label.font = clearFont
            default:
                label.font = numberFont
            }
        }
        setNeedsDisplay()
    }

    func setClearLabelInset(inset: UIEdgeInsets) {
        labels[9].inset = inset
        setNeedsDisplay()
    }

    func setBackspaceLabelInset(inset: UIEdgeInsets) {
        labels[11].inset = inset
        setNeedsDisplay()
    }

    override func layoutSubviews()  {
        for i in 0..<12 {
            var frame = keyRect(i)
            labels[i].frame = frame
        }
        gridView.frame = bounds
    }

    private func pointToKeyIndex(point: CGPoint) -> Int {
        if (!CGRectContainsPoint(self.bounds, point)) {
            return -1
        }
        var keyW = self.bounds.width / 3.0
        var keyH = self.bounds.height / 4.0
        var xIndex = Int(point.x / keyW)
        var yIndex = Int(point.y / keyH)
        return yIndex * 3 + xIndex
    }

    private func keyRect(index: Int) -> CGRect {
        var keyW = round(self.bounds.width / 3.0)
        var keyH = round(self.bounds.height / 4.0)
        var origin = CGPoint(x: (CGFloat(index % 3) * keyW), y: (CGFloat(index / 3) * keyH))
        var size = CGSize(width: keyW, height: keyH)
        return CGRect(origin: origin, size: size)
    }

    private func getSelectedLabel(index: Int) -> UILabel? {
        if index >= 0 && index < labels.count {
            return labels[index]
        }
        return nil
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var loc = touch.locationInView(self)
        var endSelectedKey = pointToKeyIndex(loc)
        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.CGColor
                oldLabel.textColor = keyPadTextColor
            }

            selectedKey = endSelectedKey
            if let newLabel = getSelectedLabel(selectedKey) {
                newLabel.layer.backgroundColor = keyPadHighlightColor.CGColor
                newLabel.textColor = keyPadTextHighlightColor
            }
        }
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var loc = touch.locationInView(self)
        var endSelectedKey = pointToKeyIndex(loc)
        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.CGColor
                oldLabel.textColor = keyPadTextColor
            }

            selectedKey = endSelectedKey
            if let newLabel = getSelectedLabel(selectedKey) {
                newLabel.layer.backgroundColor = keyPadHighlightColor.CGColor
                newLabel.textColor = keyPadTextHighlightColor
            }
        }
    }

    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        if let oldLabel = getSelectedLabel(selectedKey) {
            oldLabel.layer.backgroundColor = keyPadBackgroudColor.CGColor
            oldLabel.textColor = keyPadTextColor
        }

        selectedKey = -1
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var loc = touch.locationInView(self)
        var endSelectedKey = pointToKeyIndex(loc)

        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.CGColor
                oldLabel.textColor = keyPadTextColor
            }
        } else if selectedKey != -1 {
            switch selectedKey {
                // do nothing
            case 9:
                delegate?.clearTapped()
            case 10:
                delegate?.numberTapped(0)
            case 11:
                delegate?.backspaceTapped()
            default:
                delegate?.numberTapped(selectedKey + 1)
            }

            if let oldLabel = getSelectedLabel(selectedKey) {
                UIView.animateWithDuration(0.2, animations: {
                    oldLabel.layer.backgroundColor = self.keyPadBackgroudColor.CGColor
                    oldLabel.textColor = self.keyPadTextColor
                })
            }
        }

        selectedKey = -1
    }

    class GridView : UIView {
        var gridColor = UIColor.darkGrayColor()

        override func drawRect(rect: CGRect) {
            var path = UIBezierPath()

            var keyW = round(self.bounds.width / 3.0)
            var keyH = round(self.bounds.height / 4.0)

            for var x = 1; x < 3; x++ {
                path.moveToPoint(CGPoint(x: CGFloat(x) * keyW, y: 0))
                path.addLineToPoint(CGPoint(x: CGFloat(x) * keyW, y: self.bounds.height))
            }

            for var y = 1; y < 4; y++ {
                path.moveToPoint(CGPoint(x: 0, y: CGFloat(y) * keyH))
                path.addLineToPoint(CGPoint(x: self.bounds.width, y: CGFloat(y) * keyH))
            }
            
            gridColor.setStroke()
            path.stroke()
        }
    }

    class OffsetLabel : UILabel {
        var inset : UIEdgeInsets = UIEdgeInsetsZero
        override func drawTextInRect(rect: CGRect) {
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, inset))
        }
    }
}
