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
class CustomButton : UIButton {
    override func drawRect(rect: CGRect)  {
        customDraw(rect)
        super.drawRect(rect)
    }

    func customDraw(rect: CGRect) {
    }

    override var selected : Bool {
    get {
        return super.selected
    }
    set {
        super.selected = newValue
        setNeedsDisplay()
    }
    }

    override var highlighted : Bool {
    get {
        return super.highlighted
    }
    set {
        super.highlighted = newValue
        setNeedsDisplay()
    }
    }
}

// A square-bordered button used for the Split and Request/Pay feature
class SquareBorderButton : CustomButton {
    var borderInsetDeltaX : CGFloat = 1.0
    var borderInsetDeltaY : CGFloat = 1.0
    var lineWidth : CGFloat = 1.0

    override func customDraw(rect: CGRect)  {
        var path = UIBezierPath(rect: CGRectInset(self.bounds, borderInsetDeltaX, borderInsetDeltaY))

        if highlighted {
            titleColorForState(.Highlighted)!.setStroke()
        } else if enabled {
            titleColorForState(.Normal)!.setStroke()
        } else {
            titleColorForState(.Disabled)!.setStroke()
        }

        path.lineWidth = lineWidth
        path.stroke()
    }
}

// A round button used to draw the Info button
class RoundedButton : CustomButton {
    var normalFillColor = UIColor.darkTextColor()
    var highlightedFillColor = UIColor.blueColor()
    var disabledFillColor = UIColor.lightGrayColor()
    var offsetX : CGFloat = -1
    var offsetY : CGFloat = -1

    override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTitleColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColors()
    }

    private func setTitleColors() {
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        setTitleColor(UIColor.whiteColor(), forState: .Disabled)
    }

    override func customDraw(rect: CGRect)  {
        var insetDeltaX : CGFloat = 6.0
        var insetDeltaY : CGFloat = 6.0

        var roundRect = CGRectInset(self.bounds, insetDeltaX, insetDeltaY)
        roundRect.origin.x += offsetX
        roundRect.origin.y += offsetY
        var path = UIBezierPath(ovalInRect: roundRect)

        if highlighted {
            highlightedFillColor.setFill()
        } else if enabled {
            normalFillColor.setFill()
        } else {
            disabledFillColor.setFill()
        }

        path.fill()
    }
}
