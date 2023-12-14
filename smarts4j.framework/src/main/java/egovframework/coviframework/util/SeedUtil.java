package egovframework.coviframework.util;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;
import egovframework.baseframework.sec.SEED;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;


public class SeedUtil {
	private static final Logger LOGGER = LogManager.getLogger(SeedUtil.class);
			
	public static String getSeedEncryptString(String pPlainTxt) {
		String rtn = "";
        try {            
        	rtn = encrypt(pPlainTxt);
		} catch(NullPointerException e){	
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            LOGGER.error(e.getLocalizedMessage(), e);
        }
		return rtn;
	}
	
	public static String getSeedDecryptString(String pEncryptTxt) {
		String rtn = "";
        try {
        	rtn = decrypt(pEncryptTxt);
		} catch(NullPointerException e){	
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            LOGGER.error(e.getLocalizedMessage(), e);
        }
		return rtn;
	}
	
	private static String encrypt(String encryptStr) {
		String _encryStr = "";
		try {
			_encryStr = SEED.getSeedEncrypt(
				  encryptStr, 
				  SEED.getSeedRoundKey(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("sec.tripledes.key"))));
		} catch(NullPointerException e){	
            LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
		  LOGGER.error(e.getLocalizedMessage(), e);
		} 
		return _encryStr;
	}
	
	
	private static String decrypt(String originStr) {
		String _decryStr = "";
		try {
		  _decryStr = SEED.getSeedDecrypt(
				  originStr, 
				  SEED.getSeedRoundKey(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("sec.tripledes.key"))));
		} catch(NullPointerException e){	
            LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
		  LOGGER.error(e.getLocalizedMessage(), e);
		} 
		return _decryStr;
	}
	
}
