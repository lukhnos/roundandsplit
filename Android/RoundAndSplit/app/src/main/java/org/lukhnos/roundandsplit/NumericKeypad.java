package org.lukhnos.roundandsplit;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import java.util.ArrayList;
import java.util.List;

public class NumericKeypad extends ViewGroup {
    interface Observer {
        void backspace();
        void clear();
        void number(int n);
    }

    private List<Button> mButtons = new ArrayList<Button>();
    private Observer mObserver;
    private Rect mButtonRect = new Rect();
    private ViewGroup.LayoutParams mButtonLayoutParams = new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    private OnClickListener mClickListener = new OnClickListener() {
        @Override
        public void onClick(View view) {
            if (mObserver == null) {
                return;
            }

            int index = mButtons.indexOf(view);
            switch (index) {
                case 9:
                    mObserver.clear();
                    break;
                case 10:
                    mObserver.number(0);
                    break;
                case 11:
                    mObserver.backspace();
                    break;
                default:
                    mObserver.number(index + 1);
                    break;
            }
        }
    };

    public NumericKeypad(Context context) {
        super(context);
        init(context);
    }

    public NumericKeypad(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    public NumericKeypad(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        for (int i = 0; i < 12; i++) {
            String title;
            switch (i) {
                case 9:
                    title = "C";
                    break;
                case 10:
                    title = "0";
                    break;
                case 11:
                    title = "DEL";
                    break;
                default:
                    title = String.valueOf(i + 1);
                    break;
            }

            Button button = new Button(context);
            button.setText(title);
            button.setPadding(0, 0, 0, 0);
            button.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL);

            button.setBackgroundResource(R.drawable.keypad_button_background);
            button.setOnClickListener(mClickListener);
            button.setTextColor(getResources().getColorStateList(R.color.keypad_button_text_color));
            mButtons.add(button);
            addView(button);
        }
    }

    public void setObserver(Observer o) {
        mObserver = o;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int ws = MeasureSpec.makeMeasureSpec(getMeasuredWidth() / 3, MeasureSpec.EXACTLY);
        int hs = MeasureSpec.makeMeasureSpec(getMeasuredHeight() / 4, MeasureSpec.EXACTLY);

        float ts = (float) Math.ceil((getMeasuredHeight() / 4) * 0.38f);

        mButtonLayoutParams.width = getMeasuredWidth() / 3;
        mButtonLayoutParams.height = getMeasuredHeight() / 4;

        for (Button button : mButtons) {
            button.setTextSize(TypedValue.COMPLEX_UNIT_PX, ts);
            button.setLayoutParams(mButtonLayoutParams);
            measureChild(button, ws, hs);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        final int parentLeft = getPaddingLeft();
        final int parentRight = right - left - getPaddingRight();
        final int parentTop = getPaddingTop();
        final int parentBottom = bottom - top - getPaddingBottom();

        final int buttonWidth = (parentRight - parentLeft) / 3;
        final int buttonHeight = (parentBottom - parentTop) / 4;


        for (int i = 0; i < 12; i++) {
            Button button = mButtons.get(i);

            int r = i / 3;
            int c = i % 3;

            mButtonRect.left = c * buttonWidth;
            mButtonRect.top = r * buttonHeight;
            mButtonRect.right = mButtonRect.left + buttonWidth;
            mButtonRect.bottom = mButtonRect.top + buttonHeight + 1;
            button.layout(mButtonRect.left, mButtonRect.top, mButtonRect.right, mButtonRect.bottom);
        }
    }
}
