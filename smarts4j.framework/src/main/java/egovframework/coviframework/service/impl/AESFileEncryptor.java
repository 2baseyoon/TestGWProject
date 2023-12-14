package egovframework.coviframework.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.io.IOUtils;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.service.FileEncryptor;

public class AESFileEncryptor extends FileEncryptor {
	private String ENCRYPT_IV = null;
	private SecretKeySpec secretKey = null;
	private Cipher cipher = null;
	private String transformation = "AES/CBC/PKCS5Padding";
	private static final int IV_LENGTH = 16;
	private static final int BUFFER_SIZE = 8192;
	
	
	public AESFileEncryptor () throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeySpecException, UnsupportedEncodingException {
		this.cipher = Cipher.getInstance(transformation);
		this.ENCRYPT_IV = PropertiesUtil.getSecurityProperties().getProperty("file.encrypt.iv", "");
		String ENCRYPT_KEY = PropertiesUtil.getSecurityProperties().getProperty("file.encrypt.key", "");
		this.secretKey = AESFileEncryptor.getKeyFromPassword(ENCRYPT_KEY);
	}
	
	public byte[] generateIv() {
	    byte[] iv = new byte[IV_LENGTH];
	    iv = ENCRYPT_IV.getBytes(StandardCharsets.UTF_8);
	    return iv;
	}
	
	public static SecretKeySpec getKeyFromPassword(String password) throws NoSuchAlgorithmException, InvalidKeySpecException, UnsupportedEncodingException {
		SecretKeySpec keySpec = new SecretKeySpec(password.getBytes("UTF-8"), "AES");
		return keySpec;
	}
	
	@Override
	public File encrypt(File source, File destination) throws Exception {
		try (InputStream fis = new FileInputStream(source);) {
			return encrypt(fis, destination);
		}
	}

	@Override
	public File encrypt(InputStream fis, File destination) throws Exception {
		byte[] iv = generateIv();
		cipher.init(Cipher.ENCRYPT_MODE, secretKey, new IvParameterSpec(iv));
	    
	    try (FileOutputStream fileOut = new FileOutputStream(destination);
	    	      CipherOutputStream cipherOut = new CipherOutputStream(fileOut, cipher)) {
	    	        IOUtils.copyLarge(fis, cipherOut, new byte[BUFFER_SIZE]);
	    	    }
	    
		return destination;
	}
	
	
	
	/************************************** DECRYPT *************************************************/
	@Override
	public File decrypt(File source, File destination) throws Exception {
		try (InputStream fis = new FileInputStream(source);) {
			return decrypt(fis, destination);
		}
	}
	
	@Override
	public File decrypt(InputStream source, File destination) throws Exception {
        byte[] fileIv = generateIv();
        
        cipher.init(Cipher.DECRYPT_MODE, secretKey, new IvParameterSpec(fileIv));
        try (
                CipherInputStream cipherIn = new CipherInputStream(source, cipher);
        		FileOutputStream fos = new FileOutputStream(destination);
         ) {
        	IOUtils.copyLarge(cipherIn, fos, new byte[BUFFER_SIZE]);
        }
		return destination;
	}
}
