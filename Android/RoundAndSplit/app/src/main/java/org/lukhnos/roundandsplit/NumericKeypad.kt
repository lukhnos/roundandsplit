package org.lukhnos.roundandsplit

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.widget.Button
import androidx.core.content.ContextCompat
import kotlin.math.ceil

class NumericKeypad : ViewGroup {
    interface Observer {
        fun backspace()
        fun clear()
        fun number(n: Int)
    }

    private val buttons: MutableList<Button> = ArrayList()
    private var observer: Observer? = null
    private val buttonRect = Rect()
    private val buttonLayoutParams =
        LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
    private val clickListener = OnClickListener { view ->
        val observer = this.observer ?: return@OnClickListener
        when (val index = buttons.indexOf(view)) {
            9 -> observer.clear()
            10 -> observer.number(0)
            11 -> observer.backspace()
            else -> observer.number(index + 1)
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
            val title: String = when (i) {
                9 -> "CLEAR"
                10 -> "0"
                11 -> "⌫"
                else -> (i + 1).toString()
            }
            val button = Button(context)
            button.text = title
            button.typeface = typeface
            button.setPadding(0, 0, 0, 0)
            button.gravity = Gravity.CENTER_HORIZONTAL or Gravity.CENTER_VERTICAL
            button.setBackgroundResource(R.drawable.keypad_button_background)
            button.setOnClickListener(clickListener)
            button.setTextColor(
                ContextCompat.getColorStateList(context, R.color.keypad_button_text_color)
            )
            buttons.add(button)
            addView(button)
        }
    }

    fun setObserver(o: Observer?) {
        observer = o
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val ws = MeasureSpec.makeMeasureSpec(measuredWidth / 3, MeasureSpec.EXACTLY)
        val hs = MeasureSpec.makeMeasureSpec(measuredHeight / 4, MeasureSpec.EXACTLY)
        val ts = ceil((measuredHeight / 4 * 0.3f).toDouble()).toFloat()
        buttonLayoutParams.width = measuredWidth / 3
        buttonLayoutParams.height = measuredHeight / 4
        for (button in buttons) {
            button.setTextSize(TypedValue.COMPLEX_UNIT_PX, ts)
            button.layoutParams = buttonLayoutParams
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
            val button = buttons[i]
            val r = i / 3
            val c = i % 3
            buttonRect.left = c * buttonWidth
            buttonRect.top = r * buttonHeight
            buttonRect.right = buttonRect.left + buttonWidth
            buttonRect.bottom = buttonRect.top + buttonHeight + 1
            button.layout(buttonRect.left, buttonRect.top, buttonRect.right, buttonRect.bottom)
        }
    }
}