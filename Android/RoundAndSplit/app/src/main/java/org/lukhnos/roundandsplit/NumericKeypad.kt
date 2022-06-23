package org.lukhnos.roundandsplit

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.widget.Button

class NumericKeypad : ViewGroup {
    interface Observer {
        fun backspace()
        fun clear()
        fun number(n: Int)
    }

    private val mButtons: MutableList<Button> = ArrayList()
    private var mObserver: Observer? = null
    private val mButtonRect = Rect()
    private val mButtonLayoutParams =
        LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
    private val mClickListener = OnClickListener { view ->
        if (mObserver == null) {
            return@OnClickListener
        }
        val index = mButtons.indexOf(view)
        when (index) {
            9 -> mObserver!!.clear()
            10 -> mObserver!!.number(0)
            11 -> mObserver!!.backspace()
            else -> mObserver!!.number(index + 1)
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
        val typeface = resources.getFont(R.font.firasans_light)
        for (i in 0..11) {
            var title: String
            title = when (i) {
                9 -> "C"
                10 -> "0"
                11 -> "DEL"
                else -> (i + 1).toString()
            }
            val button = Button(context)
            button.text = title
            button.setTypeface(typeface)
            button.setPadding(0, 0, 0, 0)
            button.gravity = Gravity.CENTER_HORIZONTAL or Gravity.CENTER_VERTICAL
            button.setBackgroundResource(R.drawable.keypad_button_background)
            button.setOnClickListener(mClickListener)
            button.setTextColor(resources.getColorStateList(R.color.keypad_button_text_color))
            mButtons.add(button)
            addView(button)
        }
    }

    fun setObserver(o: Observer?) {
        mObserver = o
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val ws = MeasureSpec.makeMeasureSpec(measuredWidth / 3, MeasureSpec.EXACTLY)
        val hs = MeasureSpec.makeMeasureSpec(measuredHeight / 4, MeasureSpec.EXACTLY)
        val ts = Math.ceil((measuredHeight / 4 * 0.3f).toDouble()).toFloat()
        mButtonLayoutParams.width = measuredWidth / 3
        mButtonLayoutParams.height = measuredHeight / 4
        for (button in mButtons) {
            button.setTextSize(TypedValue.COMPLEX_UNIT_PX, ts)
            button.layoutParams = mButtonLayoutParams
            measureChild(button, ws, hs)
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val parentLeft = paddingLeft
        val parentRight = right - left - paddingRight
        val parentTop = paddingTop
        val parentBottom = bottom - top - paddingBottom
        val buttonWidth = (parentRight - parentLeft) / 3
        val buttonHeight = (parentBottom - parentTop) / 4
        for (i in 0..11) {
            val button = mButtons[i]
            val r = i / 3
            val c = i % 3
            mButtonRect.left = c * buttonWidth
            mButtonRect.top = r * buttonHeight
            mButtonRect.right = mButtonRect.left + buttonWidth
            mButtonRect.bottom = mButtonRect.top + buttonHeight + 1
            button.layout(mButtonRect.left, mButtonRect.top, mButtonRect.right, mButtonRect.bottom)
        }
    }
}