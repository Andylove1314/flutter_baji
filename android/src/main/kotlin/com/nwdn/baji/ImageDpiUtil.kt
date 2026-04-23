package com.nwdn.baji

import android.content.Context
import android.graphics.Bitmap
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

 object ImageDpiUtil {

    fun saveBitmapToJpgWithDpi(
        context: Context, 
        bitmap: Bitmap, 
        dpi: Int, 
        name: String,
        isJpg: Boolean = true
    ): File? {
        try {
            // 创建带白色背景的新位图
            val finalBitmap = if (isJpg) {
                val newBitmap = Bitmap.createBitmap(
                    bitmap.width, 
                    bitmap.height, 
                    Bitmap.Config.ARGB_8888
                )
                val canvas = android.graphics.Canvas(newBitmap)
                canvas.drawColor(android.graphics.Color.WHITE)
                canvas.drawBitmap(bitmap, 0f, 0f, null)
                newBitmap
            } else {
                bitmap
            }

            val imageByteArray = ByteArrayOutputStream()
            val format = if (isJpg) Bitmap.CompressFormat.JPEG else Bitmap.CompressFormat.PNG
            finalBitmap.compress(format, 100, imageByteArray)
            var imageData = imageByteArray.toByteArray()
            
            // 如果是PNG格式，添加DPI信息
            if (!isJpg) {
                imageData = createPngWithDpi(imageData, dpi)
            }

            return if (isJpg) {
                saveByteArrayToJpgWithDpi(context, imageData, name, dpi)
            } else {
                saveByteArrayToJpgCache(context, imageData, name)
            }
        } catch (e: Exception) {
            return null
        }
    }

    private fun saveByteArrayToJpgWithDpi(
        context: Context, 
        imageData: ByteArray, 
        name: String,
        dpi: Int
    ): File {
        val cacheDir = context.cacheDir
        val file = File(cacheDir, name)
        
        // 先保存文件
        FileOutputStream(file).use { it.write(imageData) }
        
        // 然后添加 EXIF 信息
        val exif = androidx.exifinterface.media.ExifInterface(file.absolutePath)
        exif.setAttribute(androidx.exifinterface.media.ExifInterface.TAG_X_RESOLUTION, "$dpi/1")
        exif.setAttribute(androidx.exifinterface.media.ExifInterface.TAG_Y_RESOLUTION, "$dpi/1")
        exif.setAttribute(
            androidx.exifinterface.media.ExifInterface.TAG_RESOLUTION_UNIT, 
            "2"  // 2 表示英寸
        )
        exif.saveAttributes()
        
        return file
    }

    private fun createPngWithDpi(imageData: ByteArray, dpi: Int): ByteArray {
        val output = ByteArrayOutputStream()
        // PNG 签名
        output.write(imageData.slice(0..7).toByteArray())
        
        // IHDR chunk
        val ihdrLength = ByteArray(4)
        System.arraycopy(imageData, 8, ihdrLength, 0, 4)
        val ihdrSize = (ihdrLength[0].toInt() and 0xff shl 24) or
                      (ihdrLength[1].toInt() and 0xff shl 16) or
                      (ihdrLength[2].toInt() and 0xff shl 8) or
                      (ihdrLength[3].toInt() and 0xff)
        output.write(imageData.slice(8..8 + ihdrSize + 11).toByteArray())

        // 插入 pHYs chunk
        val ppm = (dpi * 39.37).toInt()
        val physChunk = ByteArrayOutputStream()
        // Length (always 9 for pHYs)
        physChunk.write(byteArrayOf(0, 0, 0, 9))
        // Chunk type
        physChunk.write("pHYs".toByteArray())
        // X axis pixels per unit
        physChunk.write(byteArrayOf(
            (ppm shr 24).toByte(),
            (ppm shr 16).toByte(),
            (ppm shr 8).toByte(),
            ppm.toByte()
        ))
        // Y axis pixels per unit (same as X)
        physChunk.write(byteArrayOf(
            (ppm shr 24).toByte(),
            (ppm shr 16).toByte(),
            (ppm shr 8).toByte(),
            ppm.toByte()
        ))
        // Unit specifier (1 = meters)
        physChunk.write(1)
        
        // 计算并写入 CRC
        val crc = calculateCRC(physChunk.toByteArray().slice(4..16).toByteArray())
        physChunk.write(byteArrayOf(
            (crc shr 24).toByte(),
            (crc shr 16).toByte(),
            (crc shr 8).toByte(),
            crc.toByte()
        ))
        
        output.write(physChunk.toByteArray())
        
        // 写入剩余数据
        output.write(imageData.slice(8 + ihdrSize + 12 until imageData.size).toByteArray())
        
        return output.toByteArray()
    }

    private fun calculateCRC(data: ByteArray): Int {
        var c: Int = -1
        for (b in data) {
            c = CRC_TABLE[(c xor b.toInt()) and 0xff] xor (c ushr 8)
        }
        return c xor -1
    }

    private val CRC_TABLE = IntArray(256) { i ->
        var c: Int = i
        repeat(8) {
            c = if ((c and 1) == 1) 
                (0xedb88320.toInt() xor (c ushr 1)) 
            else 
                (c ushr 1)
        }
        c
    }

    private fun saveByteArrayToJpgCache(context: Context, imageData: ByteArray, name: String): File {
        val cacheDir = context.cacheDir
        val file = File(cacheDir, name)
        FileOutputStream(file).use { it.write(imageData) }
        return file
    }
}