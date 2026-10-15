package com.miel1144.notethink

import android.app.Activity
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "note_think/save_file"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads" -> {
                        val filename = call.argument<String>("filename")
                        val mimeType = call.argument<String>("mimeType")
                        val bytes = call.argument<ByteArray>("bytes")
                        if (filename == null || bytes == null) {
                            result.error("INVALID_ARGS", "filename and bytes are required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val saved = saveToDownloads(
                                filename,
                                mimeType ?: "application/octet-stream",
                                bytes,
                            )
                            result.success(saved)
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message ?: "unknown", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveToDownloads(
        filename: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        val resolver = applicationContext.contentResolver
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveViaMediaStore(resolver, filename, mimeType, bytes)
        } else {
            saveLegacy(filename, bytes)
        }
    }

    private fun saveViaMediaStore(
        resolver: android.content.ContentResolver,
        filename: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        val safeName = ensureExtension(filename, mimeType)
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, safeName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/NoteThink")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri: Uri = resolver.insert(collection, values)
            ?: throw IllegalStateException("MediaStore.insert devolvió null")
        resolver.openOutputStream(uri)?.use { it.write(bytes) }
            ?: throw IllegalStateException("No se pudo abrir OutputStream")
        values.clear()
        values.put(MediaStore.MediaColumns.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return uri.toString()
    }

    @Suppress("DEPRECATION")
    private fun saveLegacy(filename: String, bytes: ByteArray): String {
        val dir = java.io.File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "NoteThink",
        )
        if (!dir.exists()) dir.mkdirs()
        val file = java.io.File(dir, filename)
        file.outputStream().use { it.write(bytes) }
        return Uri.fromFile(file).toString()
    }

    private fun ensureExtension(filename: String, mimeType: String): String {
        if (filename.contains('.')) return filename
        val ext = when (mimeType) {
            "text/markdown" -> "md"
            "text/plain" -> "txt"
            "application/pdf" -> "pdf"
            "image/png" -> "png"
            "image/jpeg" -> "jpg"
            else -> "bin"
        }
        return "$filename.$ext"
    }
}
