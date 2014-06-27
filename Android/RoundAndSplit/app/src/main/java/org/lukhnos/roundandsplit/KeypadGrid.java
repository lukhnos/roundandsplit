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

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.WindowManager;

public class KeypadGrid extends View {
    private Paint mPaint;

    public KeypadGrid(Context context) {
        super(context);
        init(context);
    }

    public KeypadGrid(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public KeypadGrid(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        mPaint = new Paint();
        mPaint.setColor(context.getResources().getColor(R.color.divider_line));

        DisplayMetrics metrics = new DisplayMetrics();
        ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(metrics);
        mPaint.setStrokeWidth((float) Math.ceil(metrics.density * 1.0));
    }

    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        float left = (float)getPaddingLeft();
        float top = (float)getPaddingTop();
        float xpad = left + getPaddingRight();
        float ypad = top + getPaddingBottom();

        float w = getWidth() - xpad;
        float h = getHeight() + ypad;
        float wStep = (float) Math.floor(w / 3.0f);
        float hStep = (float) Math.floor(h / 4.0f);

        for (int x = 1; x < 3; x++) {
            canvas.drawLine(left + wStep * (float) x, top, left + wStep * (float) x, top + h, mPaint);
        }

        for (int y = 1; y < 4; y++) {
            canvas.drawLine(left, top + hStep * (float) y, left + w, top + hStep * (float) y, mPaint);
        }
    }
}
