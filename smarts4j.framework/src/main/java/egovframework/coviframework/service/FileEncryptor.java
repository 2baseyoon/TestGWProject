package egovframework.coviframework.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.InvocationTargetException;
import java.util.UUID;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.FileUtil;

/**
 * @author hgsong
 * @since 2022/06/09
 */
public abstract class FileEncryptor  {
	private static final Logger LOGGER = LogManager.getLogger(FileEncryptor.class);
	private volatile static FileEncryptor INSTANCE = null;
	public static FileEncryptor getInstance() throws InstantiationException, IllegalAccessException, NoSuchMethodException, SecurityException, IllegalArgumentException, InvocationTargetException {
		if(INSTANCE == null) {
			synchronized(FileEncryptor.class) {
				if(INSTANCE == null) {
					String packageName = PropertiesUtil.getSecurityProperties().getProperty("file.encryptor.bean.name", "egovframework.coviframework.service.impl.AESFileEncryptor");
					Class<?> T = null;
					try {
						T = Class.forName(packageName);
					} catch (ClassNotFoundException e) {
						return null;
					}
					//INSTANCE = (FileEncryptor)StaticContextAccessor.getBean(T);
					INSTANCE = (FileEncryptor)T.newInstance();
				}
			}
		}
		return INSTANCE;
	}

	/**
	 * Encrypt - Replace with new Encrypted File
	 * @param sourcePath
	 * @param destination
	 * @return
	 * @throws Exception
	 */
	public File encrypt(String sourcePath, String companyCode) throws Exception {
		return encrypt(new File(sourcePath), companyCode);
	}
	
	public File encrypt(File sourceFile, String companyCode) throws Exception {
		if(!sourceFile.exists()) {
			throw new FileNotFoundException(sourceFile.getAbsolutePath());
		}
		
		// Encrypt in Back storage
		String newPath = sourceFile.getParent() + File.separator + "ENC_" + sourceFile.getName();
		File encFile = encrypt(sourceFile, new File(newPath));
		
		// Replace with original file.
		try ( OutputStream output = new FileOutputStream(sourceFile); 
				InputStream fis = new FileInputStream(encFile)){
			
			IOUtils.copyLarge(fis, output, new byte[8192]);
			
			return sourceFile;
		} finally {
			// 암호화처리 임시파일 삭제.
			if(encFile.exists()) {
				if(!encFile.delete()) {
					LOGGER.debug("Fail to delete file");
				}
			}
		}
	}
	
	/**
	 * Encrypt with new destination path from sourceFile
	 * @param source
	 * @param destination
	 * @return
	 * @throws Exception
	 */
	abstract public File encrypt(File source, File destination) throws Exception;
	abstract public File encrypt(InputStream source, File destination) throws Exception;
	
	/**
	 * Decrypt
	 * @param sourcePath
	 * @param destination
	 * @return
	 * @throws Exception
	 */
	public File decrypt(String sourcePath, String companyCode) throws Exception {
		File sourceFile = new File(sourcePath);
		if(!sourceFile.exists()) {
			throw new FileNotFoundException(sourceFile.getAbsolutePath());
		}
		
		try {
			return decrypt(sourceFile, companyCode);
		} catch(NullPointerException e){	
			return new File(sourcePath);
		}catch(Exception e) {
			return new File(sourcePath);
		}
	}
	
	public File decrypt(File sourceFile, String companyCode) throws Exception {
		if(!sourceFile.exists()) {
			throw new FileNotFoundException(sourceFile.getAbsolutePath());
		}
		
		try (InputStream fis = new FileInputStream(sourceFile);) {
			return decrypt(fis, companyCode);
		} catch(NullPointerException e){	
			return sourceFile;
		}catch(Exception e) {
			return sourceFile;
		}
	}
	
	public File decrypt(InputStream source, String companyCode) throws Exception {
		// 복호화는 FrontStorage 에 처리하고 이후 가비지파일 삭제시 삭제되도록 한다.
		String FrontPath = FileUtil.getFrontPath(companyCode);
		if(FrontPath.endsWith("/")){
			FrontPath = FrontPath.substring(0,FrontPath.length()-1);
		}
		String currentDay = DateHelper.getCurrentDay("yyyyMMdd");
		String destDir = FrontPath + File.separator + companyCode + File.separator + currentDay;
		
		File dir = new File(destDir);
		if (!dir.exists()) {
			if (dir.mkdirs()) {
				LOGGER.info("path : " + dir + " mkdirs();");
			}
		}
		
		String destination = destDir + File.separator + UUID.randomUUID(); // no extension ( for security )
		
		long startTime = System.currentTimeMillis();
		File returnFile = decrypt(source, new File(destination));
		
		long elapsedTime = System.currentTimeMillis() - startTime;
		String message = "Complete File["+destination+"] Decryption. Elapsed " +  elapsedTime + "ms";
		LOGGER.debug(message);
		
		return returnFile;
	}
	
	abstract public File decrypt(File source, File destination) throws Exception;
	abstract public File decrypt(InputStream source, File destination) throws Exception;
}
