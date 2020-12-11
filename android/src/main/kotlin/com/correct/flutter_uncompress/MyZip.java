package com.correct.flutter_uncompress;

import android.os.Build;

import androidx.annotation.RequiresApi;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class MyZip {

    @RequiresApi(api = Build.VERSION_CODES.N)
    public static  void unzip(String zipFilePath, String targetPath, Callback callback)
            throws IOException {
        OutputStream os = null;
        InputStream is = null;
        ZipFile zipFile = null;
        long size = 0;
        try {
            zipFile = new ZipFile(zipFilePath, Charset.forName("GBK"));
            String directoryPath = "";
            if (null == targetPath || "".equals(targetPath)) {
                directoryPath = zipFilePath.substring(0, zipFilePath
                        .lastIndexOf("."));
            } else {
                directoryPath = targetPath;
            }
            Enumeration<?> entryEnum = zipFile.entries();

            if (null != entryEnum) {
                ZipEntry zipEntry = null;
                while (entryEnum.hasMoreElements()) {
                    zipEntry = (ZipEntry) entryEnum.nextElement();
                    if (zipEntry.getSize() > 0) {
                        // 文件
                        File targetFile = buildFile(directoryPath
                                + File.separator + zipEntry.getName(), false);
                        os = new BufferedOutputStream(new FileOutputStream(targetFile));
                        is = zipFile.getInputStream(zipEntry);
                        byte[] buffer = new byte[4096];
                        int readLen = 0;
                        while ((readLen = is.read(buffer, 0, 4096)) >= 0) {
                            os.write(buffer, 0, readLen);
                            os.flush();
                        }
                        size += zipEntry.getSize();
                        callback.getProgress(size);
                        is.close();
                        os.close();
                    }
                    if (zipEntry.isDirectory()) {
                        String pathTemp =  directoryPath + File.separator
                                + zipEntry.getName();
                        File file = new File(pathTemp);
                        file.mkdirs();
//                        System.out.println(pathTemp);
//                        continue;
                    }
                }
            }
        } catch (IOException ex) {
            throw ex;
        } finally {
            if(null != zipFile){
                zipFile.close();
                zipFile = null;
            }
            if (null != is) {
                is.close();
            }
            if (null != os) {
                os.close();
            }
        }
    }

    //获取压缩文件大小
    @RequiresApi(api = Build.VERSION_CODES.N)
    public static long getSize(String zipFilePath) throws IOException {
        ZipFile zipFile = new ZipFile(zipFilePath, Charset.forName("GBK"));
        Enumeration<?> entryEnum = zipFile.entries();
        long size = 0;
        if (null != entryEnum) {
            ZipEntry zipEntry = null;
            while (entryEnum.hasMoreElements()) {
                zipEntry = (ZipEntry) entryEnum.nextElement();
                if (zipEntry.getSize() > 0) {
                    // 文件
                    size += zipEntry.getSize();
                }
                if (zipEntry.isDirectory()) {
//                        continue;
                }
            }
        }
        return size;
    }

    private static File buildFile(String fileName, boolean isDirectory) {
        File target = new File(fileName);
        if (isDirectory) {
            target.mkdirs();
        } else {
            if (!target.getParentFile().exists()) {
                target.getParentFile().mkdirs();
                target = new File(target.getAbsolutePath());
            }
        }
        return target;
    }
}