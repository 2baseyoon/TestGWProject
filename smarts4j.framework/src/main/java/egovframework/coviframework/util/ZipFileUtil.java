package egovframework.coviframework.util;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Stack;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveInputStream;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class ZipFileUtil {
	private static final Logger LOGGER = LogManager.getLogger(ZipFileUtil.class);
	private static boolean debug = false;

	/**
	 * 압축파일이 존재하는 디렉토리에 압축 해제
	 * 
	 * @param zippedFile
	 * @throws IOException
	 */
	public void unzip(File zippedFile) throws IOException {
		unzip(zippedFile, Charset.defaultCharset().name());
	}

	public void unzip(File zippedFile, String encoding ) throws IOException {
		unzip(zippedFile, zippedFile.getParentFile(), encoding);
	}

	public void unzip(File zippedFile, File destDir) throws IOException {
		FileInputStream in = null;
		try{
			in = new FileInputStream(zippedFile);
			unzip(in, destDir, Charset.defaultCharset().name());
		}finally{
			if(in != null){
				in.close();
			}
		}
	}

	public void unzip(File zippedFile, File destDir, String encoding) throws IOException {
		FileInputStream in = null;
		try{
			in = new FileInputStream(zippedFile);
			unzip(in, destDir, encoding);
		}finally{
			if(in != null){
				in.close();
			}
		}
	}

	public void unzip(InputStream is, File destDir) throws IOException{
		unzip(is, destDir, Charset.defaultCharset().name());
	}

	public void unzip( InputStream is, File destDir, String encoding) throws IOException {
		ZipArchiveInputStream zis = null;
		ZipArchiveEntry entry ;
		String name ;
		File target ;
		int nWritten = 0;
		BufferedOutputStream bos = null;
		byte [] buf = new byte[1024 * 8];

		ensureDestDir(destDir);

		try {
			zis = new ZipArchiveInputStream(is, encoding, false);
			while ( (entry = zis.getNextZipEntry()) != null ){
				name = entry.getName();
				target = new File (destDir, name);
				if ( entry.isDirectory() ){
					ensureDestDir(target);
				} else {
					if(target.createNewFile()) {
						bos = new BufferedOutputStream(new FileOutputStream(target));
						while ((nWritten = zis.read(buf)) >= 0 ){
							bos.write(buf, 0, nWritten);
						}
						if (bos != null) bos.close();
						debug ("file : " + name);
					}
				}
			}
		} finally {
			if (bos != null) bos.close();
			if(zis != null) {
				zis.close();
			}
		}
	}

	private void ensureDestDir(File dir) throws IOException {

		if ( ! dir.exists() ) {
			if(dir.mkdirs()) {
				debug ("dir  : " + dir);
			} /*  does it always work? */
		}

	}

	public void zip(File src) throws IOException{
		zip(src, Charset.defaultCharset().name(), true);
	}

	public void zip(File src, boolean includeSrc) throws IOException{
		zip(src, Charset.defaultCharset().name(), includeSrc);
	}

	public void zip(File src, String charSetName, boolean includeSrc) throws IOException {
		zip( src, src.getParentFile(), charSetName, includeSrc);
	}

	public void zip(File src, OutputStream os) throws IOException {
		zip(src, os, Charset.defaultCharset().name(), true);
	}

	public void zip(File src, File destDir, String charSetName, boolean includeSrc) throws IOException {
		String fileName = src.getName();
		FileOutputStream out = null;
		if ( !src.isDirectory() ){
			int pos = fileName.lastIndexOf(".");
			if ( pos >  0){
				fileName = fileName.substring(0, pos);
			}
		}
		fileName += ".zip";
		ensureDestDir(destDir);

		File zippedFile = new File ( destDir, fileName);
		if ( !zippedFile.exists() ) 
			if(zippedFile.createNewFile()) {
				debug ("zippedFile : " + zippedFile);
			}

		try{
			out = new FileOutputStream(zippedFile);
			zip(src, out, charSetName, includeSrc);
		}finally{
			if(out != null){
				out.close();
			}
		}
	}

	public void zip(File src, OutputStream os, String charsetName, boolean includeSrc) throws IOException {

		ZipArchiveOutputStream zos = null;

		try {
			zos = new ZipArchiveOutputStream(os);
			zos.setEncoding(charsetName);
			FileInputStream fis = null;

			int length ;
			ZipArchiveEntry ze ;
			byte [] buf = new byte[8 * 1024];
			String name ;

			Stack<File> stack = new Stack<File>();
			File root ;
			if ( src.isDirectory() ) {
				if( includeSrc ){
					stack.push(src);
					root = src.getParentFile();
				}
				else {
					File [] fs = src.listFiles();
					if(fs != null) {
						for (int i = 0; i < fs.length; i++) {
							stack.push(fs[i]);
						}
					}
					root = src;
				}
			} else {
				stack.push(src);
				root = src.getParentFile();
			}

			while ( !stack.isEmpty() ){
				File f = stack.pop();
				name = toPath(root, f);
				if ( f.isDirectory()){
					debug ("dir  : " + name);
					File [] fs = f.listFiles();
					if(fs != null) {
						for (int i = 0; i < fs.length; i++) {
							if ( fs[i].isDirectory() ) stack.push(fs[i]);
							else stack.add(0, fs[i]);
						}
					}
				} else {
					debug("file : " + name);
					ze = new ZipArchiveEntry(name);
					zos.putArchiveEntry(ze);
					
					try {
						fis = new FileInputStream(f);
						while ( (length = fis.read(buf, 0, buf.length)) >= 0 ){
							zos.write(buf, 0, length);
						}
					} finally {
						if(fis != null) {
							fis.close();
						}
					}
					zos.closeArchiveEntry();
				}
			}
		} finally {
			if(zos != null) {
				zos.close();
			}
		}
	}

	// 리스트로 파일을 받아 zip로 압축
	public void zip(List<File> src, OutputStream os) throws IOException {
		ZipArchiveOutputStream zos = null;
		try {
			zos = new ZipArchiveOutputStream(os);
			zos.setEncoding(Charset.defaultCharset().name());
			FileInputStream fis = null;

			int length;
			ZipArchiveEntry ze;
			byte[] buf = new byte[8 * 1024];

			if (src.size() > 0) {

				for (int i = 0; i < src.size(); i++) {
					//System.out.println("name: " + src.get(i).getName());
					ze = new ZipArchiveEntry(src.get(i).getName());
					zos.putArchiveEntry(ze);
					
					try {
						fis = new FileInputStream(src.get(i));
						while ((length = fis.read(buf, 0, buf.length)) >= 0) {
							zos.write(buf, 0, length);
						}
					}finally {
						if(fis != null) {
							fis.close();
						}
					}
				}
				zos.closeArchiveEntry();
			}
		} finally {
			if(zos != null) {
				zos.close();
			}
		}
	}

	private String toPath(File root, File dir){
		String path = dir.getAbsolutePath();
		path = path.substring(root.getAbsolutePath().length()).replace(File.separatorChar, '/');
		if ( path.startsWith("/")) path = path.substring(1);
		if ( dir.isDirectory() && !path.endsWith("/")) path += "/" ;
		return path ;
	}

	private static void debug(String msg){
		if( debug ) LOGGER.debug(msg);
	}
}
