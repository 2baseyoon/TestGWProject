package egovframework.coviframework.util;

import java.util.Arrays;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.RedisShardsUtil;

import org.apache.commons.lang3.StringUtils;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("dicHelperService")
public class DicHelper extends EgovAbstractServiceImpl{
	
	private static final String[] LANGUAGE_CODE = { "ko", "en", "ja", "zh", "e1", "e2", "e3", "e4", "e5", "e6"};	//CommonControl.js의 내용과 동일함.
	
	public static String getLocaleColumn(boolean pDicType, String pLocale){
		String strLocaleDBKey = "Ko";
		
		if (pLocale.contains("ko")) {
			strLocaleDBKey = "Ko";
		} else if (pLocale.contains("en")) {
			strLocaleDBKey = "En";
		} else if (pLocale.contains("ja")) {
			strLocaleDBKey = "Ja";
		} else if (pLocale.contains("zh")) {
			strLocaleDBKey = "Zh";
		} else if (pLocale.contains("e1")) {
			strLocaleDBKey = "Lang1";
		} else if (pLocale.contains("e2")) {
			strLocaleDBKey = "Lang2";
		} else if (pLocale.contains("e3")) {
			strLocaleDBKey = "Lang3";
		} else if (pLocale.contains("e4")) {
			strLocaleDBKey = "Lang4";
		} else if (pLocale.contains("e5")) {
			strLocaleDBKey = "Lang5";
		} else if (pLocale.contains("e6")) {
			strLocaleDBKey = "Lang6";
		} 
		
		if(pDicType) {
			strLocaleDBKey += "Full";
		}else {
			strLocaleDBKey += "Short";
		}
		
		return strLocaleDBKey;
	}
	
	/**
	 * @param pLocale	지역코드 
	 * @add   srjoung	정상록
	 * @return			지역코드 인덱스 값, split할때 배열 주소로 사용
	 */
	public static int getLocaleIndex(String pLocale){
		//세션에서 가져오는 지역정보가 없을시 해당 톰캣이 실행되는 서버의 locale설정 정보를 받아와서 언어 표시
		if(pLocale == null || pLocale.length() == 0){
			pLocale = LocaleContextHolder.getLocale().toLanguageTag();
		}
		//CommonControls.js에 속하는 지역코드값으로 split하기 위해 index값 조회 
		return Arrays.asList(LANGUAGE_CODE).indexOf(pLocale);
	}
		
	public static CoviList getDicAll(String keys){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(false, LocaleContextHolder.getLocale().toLanguageTag());
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(int domainID, String keys){
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(false, LocaleContextHolder.getLocale().toLanguageTag());
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(String keys, String pLocale){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(false, pLocale);
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				newObject.put(key, obj.get(localeColumn).toString());
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(int domainID, String keys, String pLocale){
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(false, pLocale);
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(String keys, boolean pDicType){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(pDicType, LocaleContextHolder.getLocale().toLanguageTag());
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(int domainID, String keys, boolean pDicType){
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(pDicType, LocaleContextHolder.getLocale().toLanguageTag());
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	/**
	 * 다국어데이터(locale 정보 포함)
	 * @param keys(key1;key2;key3;..)
	 * @param locale(ko, en, ja, zh)
	 * @return JSONArray
	 */
	public static CoviList getDicAll(String keys, boolean pDicType, String pLocale){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(pDicType, pLocale);
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	public static CoviList getDicAll(int domainID, String keys, boolean pDicType, String pLocale){
		CoviMap obj = new CoviMap();
		CoviList returnArray = new CoviList();
		String localeColumn = getLocaleColumn(pDicType, pLocale);
		
		String[] arrKey = keys.split("[;]");
		CoviMap newObject = new CoviMap();
		
		for (String key : arrKey) {
			if (key != null && key.length() != 0) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + key));
			}
			
			if(obj.containsKey(localeColumn)){
				String strRet = StringUtil.replaceNull(obj.get(localeColumn));
				
				if(!StringUtils.isNoneBlank(strRet)){
					strRet = key;
				}
				
				newObject.put(key, strRet);
			}else{
				newObject.put(key, key);
			}
		}
		
		returnArray.add(newObject);
		return returnArray;
	}
	
	/**
	 * 다국어데이터
	 * @param key
	 * @return String
	 */
	public static String getDic(String pKey){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		boolean bDicType = false;
		
		String localeColumn = getLocaleColumn(bDicType, LocaleContextHolder.getLocale().toLanguageTag());
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	public static String getDic(int domainID, String pKey){
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		boolean bDicType = false;
		
		String localeColumn = getLocaleColumn(bDicType, LocaleContextHolder.getLocale().toLanguageTag());
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	/**
	 * 다국어데이터
	 * @param key, dictype
	 * @return String
	 */
	public static String getDic(String pKey, boolean pDicType){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(pDicType, LocaleContextHolder.getLocale().toLanguageTag());
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	public static String getDic(int domainID, String pKey, boolean pDicType){
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(pDicType, LocaleContextHolder.getLocale().toLanguageTag());
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	/**
	 * 
	 * @param pKey
	 * @param pLocale
	 * @return
	 */
	public static String getDic(String pKey, String pLocale){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(false, pLocale);
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	public static String getDic(int domainID, String pKey, String pLocale){
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(false, pLocale);
			
		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	/**
	 * 다국어데이터
	 * @param key, dictype, locale
	 * @return String
	 */
	public static String getDic(String pKey, boolean pDicType, String pLocale){
		int domainID = 0; //다국어의 default domain은 0에 주의!
		
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(pDicType, pLocale);

		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	public static String getDic(int domainID, String pKey, boolean pDicType, String pLocale){
		CoviMap obj = new CoviMap();
		String strRet = pKey;
		
		String localeColumn = getLocaleColumn(pDicType, pLocale);

		if (pKey != null && pKey.length() != 0) {	
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			obj = CoviMap.fromObject(instance.get(RedisDataUtil.PRE_DICTIONARY + Integer.toString(domainID) + "_" + pKey));
		}
		
		if(obj.containsKey(localeColumn)){
			strRet = StringUtil.replaceNull(obj.get(localeColumn));
			
			if(!StringUtils.isNoneBlank(strRet)){
				strRet = pKey;
			}
		}
		
		return strRet;
	}
	
	/**
	 * @param pOriginal	다국어 처리된 원본 문자열
	 * @param pLocale	지역코드 
	 * @add  srjoung	정상록
	 * @return
	 */
	public static String getDicInfo(String pOriginal, String pLocale){
		String strTrans = "";
		try{
			String trans[] = pOriginal.split(";");

			// 2019. 06. 11, 기술연구소 지윤성
			// pOriginal 공백이 배열로 생기지 않아 발생하는 오류 수정
			if( trans.length <= getLocaleIndex(pLocale)) {
				strTrans =  trans[0];
			} else {
				strTrans =  trans[getLocaleIndex(pLocale)];

				if(strTrans.equals("")){
					strTrans =  trans[0];		// 0 - ko
				}
				if(strTrans.equals("")){
					strTrans =  pOriginal;
				}
			}

		} catch (NullPointerException e) {
			return pOriginal;		//에러발생시 원본 리턴
		} catch (Exception e) {
			return pOriginal;		//에러발생시 원본 리턴
		}
		return strTrans;
	}
}
