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
import kotlin.math.ceil

class ButtonStrip : ViewGroup {
    interface Observer {
        fun onButtonClicked(index: Int)
    }

    private var mUnderline: View? = null
    private val mButtons: MutableList<Button> = ArrayList()
    private var mSelectedIndex = -1
    private var mObserver: Observer? = null
    private val mMetrics = DisplayMetrics()
    private val mButtonRect = Rect()
    private val mButtonLayoutParams =
        LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)

    @SuppressLint("ObjectAnimatorBinding")
    private val mButtonListener = OnClickListener { view ->
        val toButton = view as Button
        mSelectedIndex = mButtons.indexOf(toButton)
        val objectAnimator = ObjectAnimator.ofFloat(mUnderline, "x", toButton.left.toFloat())
        objectAnimator.interpolator = AccelerateDecelerateInterpolator()
        objectAnimator.duration = 250
        objectAnimator.start()
        if (mObserver != null) {
            mObserver!!.onButtonClicked(mSelectedIndex)
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
        (getContext().getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.getMetrics(
            mMetrics
        )
        mUnderline = View(context)
        mUnderline!!.setBackgroundColor(resources.getColor(R.color.normal_green))
        addView(mUnderline)
    }

    fun setObserver(o: Observer?) {
        mObserver = o
    }

    fun addButtons(titles: List<String?>, activeIndex: Int) {
        for (button in mButtons) {
            removeView(button)
        }
        mButtons.clear()
        val padding = ceil((mMetrics.density * BUTTON_PADDING).toDouble()).toInt()
        val layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        val typeface = resources.getFont(R.font.firasans_light)
        for (title in titles) {
            val button = Button(context)
            button.setBackgroundColor(0)
            button.layoutParams = layoutParams
            button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20.0f)
            button.text = title
            button.setTypeface(typeface)
            button.setPadding(padding, 0, padding, 0)
            button.setTextColor(resources.getColorStateList(R.color.button_strip_button_text_color))
            button.setOnClickListener(mButtonListener)
            mButtons.add(button)
            addView(button)
        }
        mSelectedIndex = if (activeIndex >= 0 && activeIndex < titles.size) {
            activeIndex
        } else {
            -1
        }
        requestLayout()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (mButtons.size > 0) {
            for (button in mButtons) {
                button.layoutParams = mButtonLayoutParams
                measureChild(button, widthMeasureSpec, heightMeasureSpec)
            }
        }
        measureChild(mUnderline, widthMeasureSpec, heightMeasureSpec)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val count = mButtons.size
        val parentLeft = paddingLeft
        val parentRight = right - left - paddingRight
        val parentTop = paddingTop
        val parentBottom = bottom - top - paddingBottom
        (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.getMetrics(
            mMetrics
        )
        val underlineHeight = ceil((mMetrics.density * UNDERLINE_HEIGHT).toDouble()).toInt()
        var totalWidth = 0
        for (button in mButtons) {
            totalWidth += button.measuredWidth
        }
        var space = 0
        if (count > 1) {
            space = (parentRight - parentLeft - totalWidth) / (count - 1)
        }
        mButtonRect.top = parentTop
        mButtonRect.bottom = parentBottom - underlineHeight
        mButtonRect.left = parentLeft
        for (i in 0 until count) {
            val button = mButtons[i]
            mButtonRect.right = mButtonRect.left + button.measuredWidth
            button.layout(mButtonRect.left, mButtonRect.top, mButtonRect.right, mButtonRect.bottom)
            if (mSelectedIndex == i) {
                mUnderline!!.layout(
                    mButtonRect.left,
                    mButtonRect.bottom,
                    mButtonRect.right,
                    mButtonRect.bottom + underlineHeight
                )
            }
            mButtonRect.left = mButtonRect.right + space
        }
    }

    companion object {
        private const val BUTTON_PADDING = 20
        private const val UNDERLINE_HEIGHT = 3
    }
}