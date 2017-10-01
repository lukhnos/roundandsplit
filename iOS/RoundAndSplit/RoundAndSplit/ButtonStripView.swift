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

@objc protocol ButtonStripViewDelegate {
    func didTapButtonInStripView(_ strip: ButtonStripView, index: Int)
}

class ButtonStripView : ExtendedHitAreaView {
    weak var delegate : ButtonStripViewDelegate? = nil

    var underlineColor : UIColor = UIColor.black
    var buttonTitleFont : UIFont? = nil
    var buttonTitleColorNormal : UIColor? = nil
    var buttonTitleColorHighlighted : UIColor? = nil
    var buttonTitleColorSelected : UIColor? = nil

    let underlineThickness : CGFloat = 2.0
    let buttonHorizontalPadding : CGFloat = 10.0

    fileprivate var buttons = [AccessibileButton]()
    fileprivate var activeButton : UIButton?
    fileprivate var underlineView : UIView

    required init?(coder aDecoder: NSCoder)  {
        underlineView = UIView(frame: CGRect.zero)
        super.init(coder: aDecoder)

        underlineView.backgroundColor = underlineColor
        underlineView.isHidden = true
        underlineView.isUserInteractionEnabled = false
        addSubview(underlineView)
    }

    override func layoutSubviews()  {
        if buttons.isEmpty {
            return
        }

        let boundsSize = bounds.size
        var totalButtonWidth : CGFloat = 0.0

        var buttonSizes = [CGSize]()
        var maxButtonHeight : CGFloat = 0.0
        for button in buttons {
            var fitSize = button.sizeThatFits(boundsSize)
            fitSize.width += buttonHorizontalPadding
            buttonSizes.append(fitSize)
            totalButtonWidth += fitSize.width
            maxButtonHeight = max(fitSize.height, maxButtonHeight)
        }

        var space : CGFloat
        if (buttons.count < 2) {
            space = 0
        } else {
            space = (bounds.size.width - totalButtonWidth) / (CGFloat)(buttons.count - 1)
        }

        var hitAreaPadding = extendedHitAreaEdgeInset
        let hitAreaInnerPadding = -max(0, space / 2)


        var nextX : CGFloat = 0.0
        let buttonCount = buttons.count
        for i in 0..<buttonCount {
            let button = buttons[i]
            let buttonSize = CGSize(width: buttonSizes[i].width, height: maxButtonHeight)
            let origin = CGPoint(x: nextX, y: (boundsSize.height - (buttonSize.height + underlineThickness)) / 2.0)
            button.frame = CGRect(origin: origin, size: buttonSize)
            nextX += buttonSize.width + space

            hitAreaPadding.left = (i == 0 ? extendedHitAreaEdgeInset.left : hitAreaInnerPadding)
            hitAreaPadding.right = (i + 1 == buttonCount ? extendedHitAreaEdgeInset.right : hitAreaInnerPadding)
            button.extendedHitAreaEdgeInset = hitAreaPadding
        }
        updateButtons()
        updateUnderline()
    }

    func addButtonsWithLabels(_ labels: [String], activeIndex: Int = 0) {
        for button in buttons {
            button.removeFromSuperview()
        }

        buttons.removeAll(keepingCapacity: true)

        for label in labels {
            let button = AccessibileButton(type: UIButtonType.custom)
            button.setTitle(label, for: UIControlState())
            
            if let font = buttonTitleFont {
                button.titleLabel!.font = font
            }

            if let color = buttonTitleColorNormal {
                button.setTitleColor(color, for: UIControlState())
            }

            if let color = buttonTitleColorHighlighted {
                button.setTitleColor(color, for: UIControlState.highlighted)
            }

            if let color = buttonTitleColorSelected {
                button.setTitleColor(color, for: UIControlState.disabled)
            }

            button.addTarget(self, action: #selector(ButtonStripView.buttonAction(_:)), for: UIControlEvents.touchUpInside)
            buttons.append(button)
            addSubview(button)
        }

        underlineView.backgroundColor = underlineColor

        if buttons.count > 0 && activeIndex < buttons.count {
            activeButton = buttons[activeIndex]
            underlineView.isHidden = false
        } else {
            activeButton = nil
            underlineView.isHidden = true
        }

        setNeedsLayout()
    }

    func deselect() {
        activeButton = nil
        updateUnderline()
    }

    @objc func buttonAction(_ button : AccessibileButton) {
        activeButton = button
        let index = buttons.index(of: button)

        updateButtons()
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.updateUnderline()
        }, completion: { (complete: Bool) in
            if complete {
                // Is there a way to put these two in one let?
                // Alternatively, why can't option chaining work here?
                if let delegate = self.delegate {
                    if let buttonIndex = index {
                        delegate.didTapButtonInStripView(self, index: buttonIndex)
                    }
                }
            }
        })
    }

    fileprivate func updateButtons() {
        if let currentButton = activeButton {
            for button in buttons {
                if button == currentButton {
                    button.isEnabled = false
                } else {
                    button.isEnabled = true
                }
            }
        }
    }

    fileprivate func updateUnderline() {
        if let refView = activeButton {
            let origin = CGPoint(x: refView.frame.origin.x, y: refView.frame.maxY - (underlineThickness + 1.0))
            let size = CGSize(width: refView.frame.size.width, height: underlineThickness)
            underlineView.frame = CGRect(origin: origin, size: size)
            underlineView.isHidden = false
        } else {
            underlineView.isHidden = true
        }
    }

    class AccessibileButton : ExtendedHitAreaButton {
        override var accessibilityTraits: UIAccessibilityTraits {
            get {
                var trait = UIAccessibilityTraitButton
                if !self.isEnabled {
                    trait |= UIAccessibilityTraitSelected
                }
                return trait
            }
            set {
                super.accessibilityTraits = newValue
            }
        }
    }
}
