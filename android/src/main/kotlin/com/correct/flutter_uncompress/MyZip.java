package com.correct.flutter_uncompress;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Debug;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
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

//    //复制文件
//    public static void copyFile(byte[] bytes, String copyPath, Context context) throws IOException {
////        File file = new File(copyPath + "TestZip.zip");
////        FileOutputStream fos = new FileOutputStream(file);
////        while (file.length() < bytes.length){
////            fos.write(bytes,0,bytes.length);
////            Log.d("测试","当前文件大小是" + file.length());
////        }
////
////        fos.close();
//        AssetManager assetManager = context.getAssets();
//        String[] fileNames=assetManager.list("");// 获取assets目录下的所有文件及有文件的目录名
//        for (String fileName : fileNames) {
//            Log.d("测试",fileName);
//        }
//        InputStream is = assetManager.open("TestZip.zip");
//        FileOutputStream fos = new FileOutputStream(new File(copyPath + "TestZip.zip"));
//        byte[] buffer = new byte[1024];
//        int byteCount=0;
//        while((byteCount=is.read(buffer))!=-1) {//循环从输入流读取 buffer字节
//            fos.write(buffer, 0, byteCount);//将读取的输入流写入到输出流
//        }
//        fos.flush();//刷新缓冲区
//        is.close();
//        fos.close();
//
//    }
}