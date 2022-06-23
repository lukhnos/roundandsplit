package org.lukhnos.roundandsplit

import android.app.Activity
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.widget.TextView
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.nio.charset.Charset

class TextViewerActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_text_viewer)
        actionBar!!.setDisplayHomeAsUpEnabled(true)
        val title = intent.getStringExtra(TITLE)
        if (title != null) {
            actionBar!!.title = title
        }
        val resId = intent.getIntExtra(TEXT_FILE_ID, -1)
        if (resId != -1) {
            (findViewById<View>(R.id.viewer_text) as TextView).text = readFile(resId)
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> {
                finish()
                return true
            }
        }
        return super.onOptionsItemSelected(item)
    }

    private fun readFile(resourceId: Int): String {
        val `is` = resources.openRawResource(resourceId)
        val baos = ByteArrayOutputStream()
        val buf = ByteArray(4096)
        var read: Int
        try {
            while (`is`.read(buf).also { read = it } != -1) {
                baos.write(buf, 0, read)
            }
        } catch (e: IOException) {
            return "ERROR"
        }
        return String(baos.toByteArray(), Charset.forName("UTF-8"))
    }

    companion object {
        const val TITLE = "title"
        const val TEXT_FILE_ID = "text"
    }
}