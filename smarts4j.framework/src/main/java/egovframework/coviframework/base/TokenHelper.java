package egovframework.coviframework.base;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.SimpleTimeZone;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;



import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;

import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;

import java.security.SecureRandom;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.*;
import com.nimbusds.jose.util.Base64URL;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.Provider;

import javax.crypto.SecretKey;

import com.nimbusds.jose.JOSEException;

@Controller
public class TokenHelper {

	private Logger LOGGER = LogManager.getLogger(TokenHelper.class);
	
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : String 파라미터를  확인하여 Token 생성.
	 * </pre>
	 * @Method Name : setTokenString
	 * @date : 2017. 7. 19.
	 * @param token
	 */ 	
	public String setTokenString(String id, String date, String pw, String lang, String dn, String dnCode, String empNo, String dnName, String userName, String mail, String groupCode, String groupName, String attribute, String dnId){
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.token.key")); 
		String pwMode = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("token.pw.used")); 
		StringUtil func = new StringUtil();
		String hmacSecret = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("hmac.secret"));
		//HMAC Hash key 
		//pw base64 
		String pwStr = new String(Base64.encodeBase64(pw.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
		
		String token = "";
	    
		AES aes = new AES(key, "N");
		
		try {
			// Create HMAC signer
			JWSSigner signer = new MACSigner(hmacSecret);
			
			net.minidev.json.JSONObject jsonToken = new net.minidev.json.JSONObject();
			
			//사용자 Login id
			jsonToken.put("id",id);
			
			//구인디메일 연동용
			if(func.f_NullCheck(pwMode).equals("Y")){
				jsonToken.put("pw",pwStr);
			}
			
			//언어
			jsonToken.put("lang",lang);
			
			
			//구 인디메일 사용
			if(!func.f_NullCheck(dn).equals("")){
				jsonToken.put("dn",dn.split("@")[1]);
			}else{
				jsonToken.put("dn","");
			}
			
			//도메인코드
			jsonToken.put("dncm", dnCode);
			//그룹코드
			jsonToken.put("grcm", groupCode);
			
			//사번
			jsonToken.put("emnm", empNo);
			
			//회사 명
			jsonToken.put("dnnm", Base64.encodeBase64String(dnName.getBytes(StandardCharsets.UTF_8)));
			
			//그룹 이름
			jsonToken.put("grnm", Base64.encodeBase64String(groupName.getBytes(StandardCharsets.UTF_8)));
			
			//유저 이름
			jsonToken.put("name", Base64.encodeBase64String(userName.getBytes(StandardCharsets.UTF_8)));
			//사용자 메일
			jsonToken.put("mail", mail);
			//기타필드
			jsonToken.put("attribute", attribute);
			//도메인 ID
			jsonToken.put("dnId", dnId);
			
			//Token Access Date
			jsonToken.put("exp",selCookieDate(date,"1"));
			jsonToken.put("iss", PropertiesUtil.getSecurityProperties().getProperty("jwt.iss"));
			
			//Token Access Date
		    byte[] tad  = Base64.encodeBase64(jsonToken.toString().getBytes(StandardCharsets.UTF_8));
		        
		    String  byteToString = new String(tad,0,tad.length, StandardCharsets.UTF_8);
		       
			JWSObject jwsObject = new JWSObject(new JWSHeader(JWSAlgorithm.HS256), new Payload(jsonToken));
			
			// Apply the HMAC
			jwsObject.sign(signer);
	
			String value = jwsObject.serialize();
			
			Base64URL[] parts = JOSEObject.split(value);
				
		    String str =  parts[0] + "." + byteToString;
				
		    String secret = PropertiesUtil.getDecryptedProperty(hmacSecret);	 	
		    Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
		    
		    SecretKeySpec secret_key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
		    sha256_HMAC.init(secret_key);

		    String hash = Base64.encodeBase64String(sha256_HMAC.doFinal(str.getBytes(StandardCharsets.UTF_8)));
				
		    String value1 = parts[0]+"."+byteToString+"."+hash;
		   
		    token = aes.encrypt(value1);
			
			/*JWSObject jwsObject = new JWSObject(new JWSHeader(JWSAlgorithm.HS256), new Payload(jsonToken));
			// Apply the HMAC
			jwsObject.sign(signer);
	
			// To serialize to compact form, produces something like
			token = aes.encrypt(jwsObject.serialize());*/
			
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return token;
		
	}
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : Token HMAC 복호화.
	 * </pre>
	 * @Method Name : getDecryptToken
	 * @date : 2017. 7. 19.
	 * @param value
	 */ 	
	
	public String getDecryptToken(String value){
		String token = "";
		JWSObject jwsObject;
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.token.key")); 
		AES aes = new AES(key,"N");
		
		try {
			
			token = aes.decrypt(value);
			
			jwsObject = JWSObject.parse(token);
			
			JWSVerifier verifier = new MACVerifier(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("hmac.secret")));
			
			if(jwsObject.verify(verifier)){
				token = jwsObject.getPayload().toString();
			}else{
				token = "";
			}
			
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return token;
	}
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : Token 만료일 지정
	 * </pre>
	 * @Method Name : selCookieDate
	 * @date : 2017. 7. 18.
	 * @param date, option
	 * @return day
	 */ 	
	public String selCookieDate(String date, String option){
		String day = "";
		
		if("1".equals(option)){
			Date accessDate = new Date();
		
			// Format Change
			SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMddHHmmss",Locale.ENGLISH); 
			sdformat.setTimeZone(new SimpleTimeZone(0, "GMT"));
			
			Calendar cal = Calendar.getInstance();
			
			cal.setTime(accessDate);
			cal.add(Calendar.DATE, Integer.parseInt(date));
			
			day = sdformat.format(cal.getTime());  
			
		}else{
			day = date;
		}
		
		return day;
	}
	
	
	
	public static byte[] compute(final String alg,
		     final byte[] secret,
		     final byte[] message,
		     final Provider provider)
	throws JOSEException {
	
	return compute(new SecretKeySpec(secret, alg), message, provider);
	}
	
	
	public static byte[] compute(final SecretKey secretKey,
			     final byte[] message,
			     final Provider provider)
	throws JOSEException {
	
	Mac mac = getInitMac(secretKey, provider);
	mac.update(message);
	return mac.doFinal();
	}
	
	
	
	public static Mac getInitMac(final SecretKey secretKey,
			     final Provider provider)
	throws JOSEException {
	
	Mac mac;
	
	try {
		if (provider != null) {
			mac = Mac.getInstance(secretKey.getAlgorithm(), provider);
		} else {
			mac = Mac.getInstance(secretKey.getAlgorithm());
		}
	
		mac.init(secretKey);
	
	} catch (NoSuchAlgorithmException e) {
	
		throw new JOSEException("Unsupported HMAC algorithm: " + e.getMessage(), e);
	
	} catch (InvalidKeyException e) {
	
		throw new JOSEException("Invalid HMAC key: " + e.getMessage(), e);
	}
	
	return mac;
	}
	
	
	public boolean verify(final JWSHeader header,
            final byte[] signedContent, 
            final Base64URL signature)
	throws JOSEException {
	
	
	String jcaAlg = "HMACSHA256";
	byte[] expectedHMAC = compute(jcaAlg, PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("hmac.secret")).getBytes(StandardCharsets.UTF_8), signedContent, null);
	return areEqual(expectedHMAC, signature.decode());
	}
	
	
	public static boolean areEqual(final byte[] a, final byte[] b) {

		// From http://codahale.com/a-lesson-in-timing-attacks/

		if (a.length != b.length) {
			return false;
		}

		int result = 0;
		for (int i = 0; i < a.length; i++) {
			result |= a[i] ^ b[i];
		}

		return result == 0;
	}
	
}
