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
package org.lukhnos.roundandsplit

import android.animation.ObjectAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Button
import androidx.core.content.ContextCompat
import kotlin.math.ceil

class ButtonStrip : ViewGroup {
    interface Observer {
        fun onButtonClicked(index: Int)
    }

    private var underline: View? = null
    private val buttons: MutableList<Button> = ArrayList()
    private var selectedIndex = -1
    private var observer: Observer? = null
    private val metrics = DisplayMetrics()
    private val buttonRect = Rect()
    private val buttonLayoutParams =
        LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)

    @SuppressLint("ObjectAnimatorBinding")
    private val mButtonListener = OnClickListener { view ->
        val toButton = view as Button
        selectedIndex = buttons.indexOf(toButton)
        val objectAnimator = ObjectAnimator.ofFloat(underline, "x", toButton.left.toFloat())
        objectAnimator.interpolator = AccelerateDecelerateInterpolator()
        objectAnimator.duration = 250
        objectAnimator.start()
        if (observer != null) {
            observer!!.onButtonClicked(selectedIndex)
        }
    }

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyle: Int) : super(
        context,
        attrs,
        defStyle
    ) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init(context)
    }

    private fun init(context: Context) {
        (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.getMetrics(
            metrics
        )
    }

    fun setObserver(o: Observer?) {
        observer = o
    }

    fun addButtons(titles: List<String?>, activeIndex: Int) {
        for (button in buttons) {
            removeView(button)
        }
        if (underline != null) {
            removeView(underline)
        }
        buttons.clear()
        val padding = ceil((metrics.density * BUTTON_PADDING).toDouble()).toInt()
        val layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        val typeface = resources.getFont(R.font.firasans_light)
        for (title in titles) {
            val button = Button(context)
            button.setBackgroundColor(0)
            button.layoutParams = layoutParams
            button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20.0f)
            button.text = title
            button.typeface = typeface
            button.setPadding(padding, 0, padding, 0)
            button.setTextColor(
                ContextCompat.getColorStateList(context, R.color.button_strip_button_text_color)
            )
            button.setOnClickListener(mButtonListener)
            buttons.add(button)
            addView(button)
        }
        selectedIndex = if (activeIndex >= 0 && activeIndex < titles.size) {
            activeIndex
        } else {
            -1
        }
        underline = View(context)
        underline?.setBackgroundColor(
            ContextCompat.getColor(context, R.color.normal_green)
        )
        addView(underline)

        requestLayout()
        // underline.requestLayout()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (buttons.size > 0) {
            for (button in buttons) {
                button.layoutParams = buttonLayoutParams
                measureChild(button, widthMeasureSpec, heightMeasureSpec)
            }
        }
        measureChild(underline, widthMeasureSpec, heightMeasureSpec)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val count = buttons.size
        val parentLeft = paddingLeft
        val parentRight = right - left - paddingRight
        val parentTop = paddingTop
        val parentBottom = bottom - top - paddingBottom
        (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.getMetrics(
            metrics
        )
        val underlineHeight = ceil((metrics.density * UNDERLINE_HEIGHT).toDouble()).toInt()
        var totalWidth = 0
        for (button in buttons) {
            totalWidth += button.measuredWidth
        }
        var space = 0
        if (count > 1) {
            space = (parentRight - parentLeft - totalWidth) / (count - 1)
        }
        buttonRect.top = parentTop
        buttonRect.bottom = parentBottom - underlineHeight
        buttonRect.left = parentLeft
        for (i in 0 until count) {
            val button = buttons[i]
            buttonRect.right = buttonRect.left + button.measuredWidth
            button.layout(buttonRect.left, buttonRect.top, buttonRect.right, buttonRect.bottom)
            if (selectedIndex == i) {
                underline?.layout(
                    buttonRect.left,
                    buttonRect.bottom,
                    buttonRect.right,
                    buttonRect.bottom + underlineHeight
                )
            }
            buttonRect.left = buttonRect.right + space
        }
    }

    companion object {
        private const val BUTTON_PADDING = 20
        private const val UNDERLINE_HEIGHT = 3
    }
}