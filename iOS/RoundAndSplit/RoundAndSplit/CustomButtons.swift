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

// A button base class with custom highlighting/selecting behavior.
class CustomButton : ExtendedHitAreaButton {
    override func draw(_ rect: CGRect)  {
        customDraw(rect)
        super.draw(rect)
    }

    func customDraw(_ rect: CGRect) {
    }

    override var isSelected : Bool {
    get {
        return super.isSelected
    }
    set {
        super.isSelected = newValue
        setNeedsDisplay()
    }
    }

    override var isHighlighted : Bool {
    get {
        return super.isHighlighted
    }
    set {
        super.isHighlighted = newValue
        setNeedsDisplay()
    }
    }
}

// A square-bordered button used for the Split and Email Reminder feature
class SquareBorderButton : CustomButton {
    var borderInsetDeltaX : CGFloat = 1.0
    var borderInsetDeltaY : CGFloat = 1.0
    var lineWidth : CGFloat = 1.0

    override func customDraw(_ rect: CGRect)  {
        let path = UIBezierPath(rect: self.bounds.insetBy(dx: borderInsetDeltaX, dy: borderInsetDeltaY))

        if isHighlighted {
            titleColor(for: .highlighted)!.setStroke()
        } else if isEnabled {
            titleColor(for: UIControl.State())!.setStroke()
        } else {
            titleColor(for: .disabled)!.setStroke()
        }

        path.lineWidth = lineWidth
        path.stroke()
    }
}

// A round button used to draw the Info button
class RoundedButton : CustomButton {
    var normalFillColor = UIColor.darkText
    var highlightedFillColor = UIColor.blue
    var disabledFillColor = UIColor.lightGray
    var offsetX : CGFloat = 0
    var offsetY : CGFloat = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTitleColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColors()
    }

    fileprivate func setTitleColors() {
        setTitleColor(UIColor.white, for: UIControl.State())
        setTitleColor(UIColor.white, for: .highlighted)
        setTitleColor(UIColor.white, for: .disabled)
    }

    override func customDraw(_ rect: CGRect)  {
        let insetDeltaX : CGFloat = 6.0
        let insetDeltaY : CGFloat = 6.0

        var roundRect = self.bounds.insetBy(dx: insetDeltaX, dy: insetDeltaY)
        roundRect.origin.x += offsetX
        roundRect.origin.y += offsetY
        let path = UIBezierPath(ovalIn: roundRect)

        if isHighlighted {
            highlightedFillColor.setFill()
        } else if isEnabled {
            normalFillColor.setFill()
        } else {
            disabledFillColor.setFill()
        }

        path.fill()
    }
}
