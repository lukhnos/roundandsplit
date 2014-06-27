package org.lukhnos.roundandsplit;

import android.app.Activity;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;


public class TextViewerActivity extends Activity {
    public static final String TITLE = "title";
    public static final String TEXT_FILE_ID = "text";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_text_viewer);
        getActionBar().setDisplayHomeAsUpEnabled(true);

        String title = getIntent().getStringExtra(TITLE);
        if (title != null) {
            getActionBar().setTitle(title);
        }

        int resId = getIntent().getIntExtra(TEXT_FILE_ID, -1);
        if (resId != -1) {
            ((TextView) findViewById(R.id.viewer_text)).setText(readFile(resId));
        }
    }

    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            // Respond to the action bar's Up/Home button
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private String readFile(int resourceId) {
        InputStream is = getResources().openRawResource(resourceId);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int read;
        try {
            while ((read = is.read(buf)) != -1) {
                baos.write(buf, 0, read);
            }
        } catch (IOException e) {
            return "ERROR";
        }
        return new String(baos.toByteArray(), Charset.forName("UTF-8"));
    }
}
