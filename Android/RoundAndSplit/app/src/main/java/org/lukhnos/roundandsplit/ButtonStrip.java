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

package org.lukhnos.roundandsplit;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;

import java.util.ArrayList;
import java.util.List;

public class ButtonStrip extends ViewGroup {
    interface Observer {
        void onButtonClicked(int index);
    }

    private static final int BUTTON_PADDING = 20;
    private static final int UNDERLINE_HEIGHT = 3;
    private static final String TAG = ButtonStrip.class.getSimpleName();
    private View mUnderline;
    private List<Button> mButtons = new ArrayList<Button>();
    private int mSelectedIndex = -1;
    private Observer mObserver;

    private DisplayMetrics mMetrics = new DisplayMetrics();
    private Rect mButtonRect = new Rect();
    private LayoutParams mButtonLayoutParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);

    private OnClickListener mButtonListener = new OnClickListener() {
        @Override
        public void onClick(View view) {
            Button toButton = (Button) view;
            mSelectedIndex = mButtons.indexOf(toButton);
            ObjectAnimator objectAnimator= ObjectAnimator.ofFloat(mUnderline, "x", toButton.getLeft());
            objectAnimator.setInterpolator(new AccelerateDecelerateInterpolator());
            objectAnimator.setDuration(250);
            objectAnimator.start();

            if (mObserver != null) {
                mObserver.onButtonClicked(mSelectedIndex);
            }
        }
    };

    public ButtonStrip(Context context) {
        super(context);
        init(context);
    }

    public ButtonStrip(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    public ButtonStrip(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        ((WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(mMetrics);

        mUnderline = new View(context);
        mUnderline.setBackgroundColor(getResources().getColor(R.color.normal_green));
        addView(mUnderline);
    }

    public void setObserver(Observer o) {
        mObserver = o;
    }

    public void addButtons(List<String> titles, int activeIndex) {
        for (Button button : mButtons) {
            removeView(button);
        }
        mButtons.clear();

        final int padding = (int) Math.ceil(mMetrics.density * BUTTON_PADDING);

        LayoutParams layoutParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        for (String title : titles) {
            Button button = new Button(getContext());
            button.setBackgroundColor(0);
            button.setLayoutParams(layoutParams);
            button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20.0f);
            button.setText(title);
            button.setPadding(padding, 0, padding, 0);
            button.setTextColor(getResources().getColorStateList(R.color.button_strip_button_text_color));
            button.setOnClickListener(mButtonListener);
            mButtons.add(button);
            addView(button);
        }

        if (activeIndex >= 0 && activeIndex < titles.size()) {
            mSelectedIndex = activeIndex;
        } else {
            mSelectedIndex = -1;
        }

        requestLayout();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        if (mButtons.size() > 0) {
            for (Button button : mButtons) {
                button.setLayoutParams(mButtonLayoutParams);
                measureChild(button, widthMeasureSpec, heightMeasureSpec);
            }
        }

        measureChild(mUnderline, widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        final int count = mButtons.size();
        final int parentLeft = getPaddingLeft();
        final int parentRight = right - left - getPaddingRight();
        final int parentTop = getPaddingTop();
        final int parentBottom = bottom - top - getPaddingBottom();

        ((WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(mMetrics);
        final int underlineHeight = (int) Math.ceil(mMetrics.density * UNDERLINE_HEIGHT);

        int totalWidth = 0;
        for (Button button : mButtons) {
            totalWidth += button.getMeasuredWidth();
        }

        int space = 0;
        if (count > 1) {
            space = ((parentRight - parentLeft) - totalWidth) / (count - 1);
        }

        mButtonRect.top = parentTop;
        mButtonRect.bottom = parentBottom - underlineHeight;
        mButtonRect.left = parentLeft;

        for (int i = 0; i < count; i++) {
            Button button = mButtons.get(i);
            mButtonRect.right = mButtonRect.left + button.getMeasuredWidth();

            button.layout(mButtonRect.left, mButtonRect.top, mButtonRect.right, mButtonRect.bottom);

            if (mSelectedIndex == i) {
                mUnderline.layout(mButtonRect.left, mButtonRect.bottom, mButtonRect.right, mButtonRect.bottom + underlineHeight);
            }

            mButtonRect.left = mButtonRect.right + space;
        }
    }
}
