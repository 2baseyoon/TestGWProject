package egovframework.coviframework.base;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.SimpleTimeZone;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.util.json.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.stereotype.Controller;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;

@Controller
public class TokenParserHelper {

	private Logger LOGGER = LogManager.getLogger(TokenParserHelper.class);
	
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : Token 검증.
	 * </pre>
	 * @Method Name : parserJsonVerification
	 * @date : 2017. 7. 19.
	 * @param value, id
	 * @return boolean
	 */ 	
	
	public boolean parserJsonVerification(String value, String id){
		JSONParser parser = new JSONParser();
		Object obj;
		String strVerification = "";
		boolean variable = true;
		
		try {
			obj = parser.parse( value );
			CoviMap jsonObj = (CoviMap) obj;
			
			//만료일 검증
			strVerification = (String) jsonObj.get("exp");
			if(!"".equals(strVerification) && !tokenDateVerification(strVerification)){
				LOGGER.info("Token verification exp error ", this);
				return false;
			}
			//id검증
			strVerification = (String) jsonObj.get("id");
			if(!"".equals(strVerification) && !strVerification.equals(id)){
				LOGGER.info("Token verification id error ", this);
				return false;
			}
			//발급자 검증.
			strVerification = (String) jsonObj.get("iss");
			if(!"".equals(strVerification) && !strVerification.equals(PropertiesUtil.getSecurityProperties().getProperty("jwt.iss"))){
				LOGGER.info("Token verification exp error ", this);
				return false;
			}
			
		} catch (ParseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
		
		return variable;
	}
	
	public boolean parserJsonLoginVerification(String value){
		JSONParser parser = new JSONParser();
		Object obj;
		String strVerification = "";
		boolean variable = true;
		
		try {
			obj = parser.parse( value );
			CoviMap jsonObj = (CoviMap) obj;
			
			//만료일 검증
			strVerification = (String) jsonObj.get("exp");
			if(!"".equals(strVerification) && !tokenDateVerification(strVerification)){
				LOGGER.info("Token verification exp error ", this);
				return false;
			}
			
			//발급자 검증.
			strVerification = (String) jsonObj.get("iss");
			if(!"".equals(strVerification) && !strVerification.equals(PropertiesUtil.getSecurityProperties().getProperty("jwt.iss"))){
				LOGGER.info("Token verification exp error ", this);
				return false;
			}
			
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
		
		return variable;
	}
	
	
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : Token 만료 시간 검증.
	 * </pre>
	 * @Method Name : tokenDateVerification
	 * @date : 2017. 7. 19.
	 * @param value
	 * @return boolean
	 */ 	
	public boolean tokenDateVerification(String value){
		
		Date date = new Date();
		long startDate = 0;
		long endDate = 0;
		
		// Format Change
		SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMddHHmmss",Locale.ENGLISH); 
		sdformat.setTimeZone(new SimpleTimeZone(0, "GMT"));
		
		Calendar cal = Calendar.getInstance();
		
		cal.setTime(date);
		
		String dateTime = sdformat.format(cal.getTime());  
		
		startDate = Long.parseLong(dateTime);
		endDate = Long.parseLong(value);
		
		if(startDate >= endDate){
			return false;
		}
		
		return true;
	}
	
	/**
	 * <pre>
	 * 1. 개요 : 
	 * 2. 처리내용 : Token 만료 시간  반환.
	 * </pre>
	 * @Method Name : parserJsonMaxAge
	 * @date : 2017. 7. 25.
	 * @param value
	 * @return String
	 */ 
	
	public String parserJsonMaxAge(String value){
		JSONParser parser = new JSONParser();
		Object obj;
		String strVerification = "";
		
		try {
			obj = parser.parse( value );
			CoviMap jsonObj = (CoviMap) obj;
			
			//만료일 검증
			strVerification = (String) jsonObj.get("exp");
			
			
		} catch (ParseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return strVerification;
		}
		
		return strVerification;
	}
	
	
	public Map getSSOToken(String value){
		Map map = new HashMap();
		StringUtil func = new StringUtil();
		
		JSONParser parser = new JSONParser();
		Object obj;
		String strVerification = "";
		String pwMode = PropertiesUtil.getSecurityProperties().getProperty("token.pw.used");
		
		try {
			obj = parser.parse( value );
			CoviMap jsonObj = (CoviMap) obj;
			
			strVerification = (String) jsonObj.get("id");
			
			map.put("id", strVerification);
			
			strVerification = (String) jsonObj.get("lang");
			map.put("lang", strVerification);
			
			strVerification = (String) jsonObj.get("dn");
			map.put("dn", strVerification);
			
			strVerification = (String) jsonObj.get("dncm");
			map.put("dncm", strVerification);
			
			strVerification = (String) jsonObj.get("grcm");
			map.put("grcm", strVerification);
			
			strVerification = (String) jsonObj.get("emnm");
			map.put("emnm", strVerification);
			
			strVerification = (String) jsonObj.get("dnnm");
			
			byte[] decoded = Base64.decodeBase64(strVerification.getBytes(StandardCharsets.UTF_8));
			
			String dnnm = new String(decoded, StandardCharsets.UTF_8);
			
			map.put("dnnm", dnnm);
			
			strVerification = (String) jsonObj.get("grnm");
			
			decoded = Base64.decodeBase64(strVerification.getBytes(StandardCharsets.UTF_8));
			
			String grnm = new String(decoded, StandardCharsets.UTF_8);

			map.put("grnm", grnm);
			
			strVerification = (String) jsonObj.get("name");
			
			decoded = Base64.decodeBase64(strVerification.getBytes(StandardCharsets.UTF_8));
			
			String name = new String(decoded, StandardCharsets.UTF_8);
			
			map.put("name", name);
			
			strVerification = (String) jsonObj.get("mail");
			map.put("mail", strVerification);
			
			strVerification = (String) jsonObj.get("attribute");
			map.put("attribute", strVerification);
			
			strVerification = (String) jsonObj.get("dnId");
			map.put("dnId", strVerification);
			
			if(func.f_NullCheck(pwMode).equals("Y")){
				strVerification = (String) jsonObj.get("pw");
				strVerification = new String(Base64.decodeBase64(strVerification), StandardCharsets.UTF_8);
				map.put("pw", strVerification);
			}else{
				map.put("pw", "");
			}
			
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			return map;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return map;
		}
		
		return map;
	}
	
	
}
