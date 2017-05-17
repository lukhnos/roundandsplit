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
    func numberTapped(_ number: Int)
    func clearTapped()
    func backspaceTapped()
}

class NumericKeypadView : UIView {
    var delegate : NumericKeypadDelegate?
    var gridView = GridView()

    var keyPadBackgroudColor : UIColor = UIColor.white {
        didSet {
            for label in labels {
                label.layer.backgroundColor = keyPadBackgroudColor.cgColor
            }
        }
    }

    var keyPadHighlightColor = UIColor.lightGray
    var keyPadTextColor : UIColor = UIColor.black {
        didSet {
            for label in labels {
                label.textColor = keyPadTextColor
            }
        }
    }

    var keyPadTextHighlightColor = UIColor.white

    fileprivate var selectedKey = -1
    fileprivate var labels = [OffsetLabel]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        for i in 0..<12 {
            var label : OffsetLabel
            label = OffsetLabel(frame: CGRect.zero)

            // Add zero-width space (U+200B) to work around the problem on
            // iOS 7 that, if there's only one number character, tabular
            // figure won't be used.
            var keyStr : String
            switch i {
            case 9:
                keyStr = "\u{200b}CLEAR\u{200b}"
            case 10:
                keyStr = "\u{200b}0\u{200b}"
            case 11:
                keyStr = "\u{200b}⌫\u{200b}"
            default:
                keyStr = String(format: "\u{200b}%d\u{200b}", i + 1)
            }

            label.text = keyStr
            label.numberOfLines = 1
            label.textColor = keyPadTextColor
            label.accessibilityTraits |= UIAccessibilityTraitButton

            labels.append(label)
            label.layer.backgroundColor = keyPadBackgroudColor.cgColor
            label.textAlignment = NSTextAlignment.center
            label.isOpaque = true
            addSubview(label)
        }

        gridView.backgroundColor = UIColor.clear
        gridView.isOpaque = true
        addSubview(gridView)
    }

    func setLabelFonts(_ numberFont: UIFont, clearFont: UIFont) {
        for i in 0..<12 {
            let label = labels[i]

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

    func setClearLabelInset(_ inset: UIEdgeInsets) {
        labels[9].inset = inset
        setNeedsDisplay()
    }

    func setBackspaceLabelInset(_ inset: UIEdgeInsets) {
        labels[11].inset = inset
        setNeedsDisplay()
    }

    override func layoutSubviews()  {
        for i in 0..<12 {
            let frame = keyRect(i)
            labels[i].frame = frame
        }
        gridView.frame = bounds
    }

    fileprivate func pointToKeyIndex(_ point: CGPoint) -> Int {
        if (!self.bounds.contains(point)) {
            return -1
        }
        let keyW = self.bounds.width / 3.0
        let keyH = self.bounds.height / 4.0
        let xIndex = Int(point.x / keyW)
        let yIndex = Int(point.y / keyH)
        return yIndex * 3 + xIndex
    }

    fileprivate func keyRect(_ index: Int) -> CGRect {
        let keyW = round(self.bounds.width / 3.0)
        let keyH = round(self.bounds.height / 4.0)
        let origin = CGPoint(x: (CGFloat(index % 3) * keyW), y: (CGFloat(index / 3) * keyH))
        let size = CGSize(width: keyW, height: keyH)
        return CGRect(origin: origin, size: size)
    }

    fileprivate func getSelectedLabel(_ index: Int) -> UILabel? {
        if index >= 0 && index < labels.count {
            return labels[index]
        }
        return nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let loc = touch.location(in: self)
        let endSelectedKey = pointToKeyIndex(loc)
        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.cgColor
                oldLabel.textColor = keyPadTextColor
            }

            selectedKey = endSelectedKey
            if let newLabel = getSelectedLabel(selectedKey) {
                newLabel.layer.backgroundColor = keyPadHighlightColor.cgColor
                newLabel.textColor = keyPadTextHighlightColor
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let loc = touch.location(in: self)
        let endSelectedKey = pointToKeyIndex(loc)
        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.cgColor
                oldLabel.textColor = keyPadTextColor
            }

            selectedKey = endSelectedKey
            if let newLabel = getSelectedLabel(selectedKey) {
                newLabel.layer.backgroundColor = keyPadHighlightColor.cgColor
                newLabel.textColor = keyPadTextHighlightColor
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let oldLabel = getSelectedLabel(selectedKey) {
            oldLabel.layer.backgroundColor = keyPadBackgroudColor.cgColor
            oldLabel.textColor = keyPadTextColor
        }

        selectedKey = -1
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let loc = touch.location(in: self)
        let endSelectedKey = pointToKeyIndex(loc)

        if endSelectedKey != selectedKey {
            if let oldLabel = getSelectedLabel(selectedKey) {
                oldLabel.layer.backgroundColor = keyPadBackgroudColor.cgColor
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
                UIView.animate(withDuration: 0.2, animations: {
                    oldLabel.layer.backgroundColor = self.keyPadBackgroudColor.cgColor
                    oldLabel.textColor = self.keyPadTextColor
                })
            }
        }

        selectedKey = -1
    }

    class GridView : UIView {
        var gridColor = UIColor.darkGray

        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()

            let keyW = round(self.bounds.width / 3.0)
            let keyH = round(self.bounds.height / 4.0)

            for x in 1 ..< 3 {
                path.move(to: CGPoint(x: CGFloat(x) * keyW, y: 0))
                path.addLine(to: CGPoint(x: CGFloat(x) * keyW, y: self.bounds.height))
            }

            for y in 1 ..< 4 {
                path.move(to: CGPoint(x: 0, y: CGFloat(y) * keyH))
                path.addLine(to: CGPoint(x: self.bounds.width, y: CGFloat(y) * keyH))
            }
            
            gridColor.setStroke()
            path.stroke()
        }
    }

    class OffsetLabel : UILabel {
        var inset : UIEdgeInsets = UIEdgeInsets.zero
        override func drawText(in rect: CGRect) {
            super.drawText(in: UIEdgeInsetsInsetRect(rect, inset))
        }
    }
}
