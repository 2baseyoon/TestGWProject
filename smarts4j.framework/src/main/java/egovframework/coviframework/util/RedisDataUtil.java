package egovframework.coviframework.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;

/**
 * @Class Name : RedisDataUtil.java
 * @Description : base config 및 code, 다국어 등 redis에 캐쉬되는 data 관련 메소드 제공
 * @Modification Information 
 * @ 2017.06.28 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.06.28
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
public class RedisDataUtil {
	
	private static final Logger logger = Logger.getLogger(RedisDataUtil.class);
	
	// baseframework에도 동일변수 존재
	public static final String PRE_BASECODE = "CODE_";
	public static final String PRE_BASECONFIG = "CONFIG_";
	public static final String PRE_DICTIONARY = "DIC_";
	public static final String PRE_LICENSE = "LICENSE_";
	
	public static final String PRE_ACL = "ACL_";
	public static final String PRE_MENU = "MENU_";
	public static final String PRE_MENU_E = "MENU_E_";
	//권한 관리할 메뉴
	public static final String PRE_AUTH_MENU = "AUTH_MENU_";
	public static final String PRE_AUDIT_URL = "AUDIT_URL_";
	// 신규 권한
	public static final String PRE_H_ACL = "H_ACL_";
	
	//base config
	public static String getBaseConfig(String pKey, String pDomainID)  {
		String strRet = "";
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		
		String strJson = "";
		try {
			
			if(func.f_NullCheck(pDomainID).equals("")){
				pDomainID = "0";
			}
			
			strJson = instance.get(PRE_BASECONFIG + pDomainID + "_" + pKey);
			
			if(!func.f_NullCheck(strJson).equals("")){
				CoviMap jsonObj = new ObjectMapper().readValue(strJson, CoviMap.class);
				strRet = StringUtil.replaceNull(jsonObj.getString("SettingValue"));
			}else{
				strJson = instance.get(PRE_BASECONFIG + "0" + "_" + pKey);
				if(!func.f_NullCheck(strJson).equals("")){
					CoviMap jsonObj = new ObjectMapper().readValue(strJson, CoviMap.class);
					strRet = StringUtil.replaceNull(jsonObj.getString("SettingValue"));
				}else{
					strRet = "";
				}
			}
			
		}catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		}catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return strRet;
	}
	
	public static String getBaseConfig(String pKey) {
		StringUtil func = new StringUtil();
		String ret = "";
		try {
			String domainID = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(domainID).equals("")){
				domainID = "0";
			}
			
			ret = getBaseConfig(pKey, domainID);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return ret;
	}
	
	public static String getBaseConfig(String pKey, boolean isMobile) {
		StringUtil func = new StringUtil();
		String ret = "";
		try {
			String domainID = SessionHelper.getSession("DN_ID", isMobile);
			
			if(func.f_NullCheck(domainID).equals("")){
				domainID = "0";
			}
			
			ret = getBaseConfig(pKey, domainID);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return ret;
	}
	
	public static String getBaseConfig(String pKey, boolean isMobile, String key) {
		StringUtil func = new StringUtil();
		String ret = "";
		try {
			String domainID = SessionHelper.simpleGetSession("DN_ID", isMobile, key);
			
			if(func.f_NullCheck(domainID).equals("")){
				domainID = "0";
			}
			
			ret = getBaseConfig(pKey, domainID);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return ret;
	}
	
	
	public static String getBaseConfigElement(String pKey, String pDomainID, String pColName) throws Exception {
		String strRet = "";
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		
		String strJson = "";
		
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		strJson = instance.get(PRE_BASECONFIG + pDomainID + "_" + pKey);
		
		if(!func.f_NullCheck(strJson).equals("")){
			CoviMap jsonObj = new ObjectMapper().readValue(strJson, CoviMap.class);
			strRet = StringUtil.replaceNull(jsonObj.get(pColName));
		}else{
			strJson = instance.get(PRE_BASECONFIG + "0" + "_" + pKey);
			if(!func.f_NullCheck(strJson).equals("")){
				CoviMap jsonObj = new ObjectMapper().readValue(strJson, CoviMap.class);
				strRet = StringUtil.replaceNull(jsonObj.get(pColName));
			}else{
				strRet = pKey;
			}
		}

		return strRet;
	}
	
	public static void setBaseConfig(String pKey, String pDomainID, String pValue) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		instance.save(PRE_BASECONFIG + pDomainID + "_" + pKey, pValue);
	}
	
	public static CoviList getBaseCode(String codeGroup) {
		StringUtil func = new StringUtil();
		CoviList sortedJsonArray = new CoviList();
		try {
			String pDomainId = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(pDomainId).equals("")){
				pDomainId = "0";
			}
			
			return getBaseCode(codeGroup, pDomainId);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return sortedJsonArray;
	}
	
	//base code
	public static CoviList getBaseCode(String codeGroup, String pDomainID) throws Exception{
		StringUtil func = new StringUtil();
		CoviList sortedJsonArray = new CoviList();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
		//pattern으로 key를 가져옴
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		Set<String> names = instance.keys(codeGroup, PRE_BASECODE + pDomainID + "_" + codeGroup + "_*");

		if(names == null || names.size() == 0){
			names = instance.keys(codeGroup, PRE_BASECODE + "0" + "_" + codeGroup + "_*");
		}

		Iterator<String> it = names.iterator();
		CoviList codeArray = new CoviList();
		while (it.hasNext()) {
			//key에 해당하는 jsonobject를 array로 
			String baseCodeJsonStr = instance.get(it.next());
			if (StringUtils.isNoneBlank(baseCodeJsonStr)) {
				codeArray.add(new ObjectMapper().readValue(baseCodeJsonStr, CoviMap.class));
			}
		}
		
		//정렬
		List<CoviMap> jsonValues = new ArrayList<CoviMap>();
	    for (int i = 0; i < codeArray.size(); i++) {
	        jsonValues.add(codeArray.getJSONObject(i));
	    }
	    
	    Collections.sort( jsonValues, new Comparator<CoviMap>() {
	        private static final String KEY_NAME = "SortKey";

	        @Override
	        public int compare(CoviMap a, CoviMap b) {
	        	int compare = 0;
                int valA = a.getInt(KEY_NAME);
                int valB = b.getInt(KEY_NAME);

                compare = Integer.compare(valA, valB);
	        	return compare;
	        }
	    });
		
	    for (int i = 0; i < jsonValues.size(); i++) {
	        sortedJsonArray.add(jsonValues.get(i));
	    }
	    
	    return sortedJsonArray;
	}
	
	public static CoviMap getBaseCodeGroupDic(String pCodeGroup) throws Exception {
		StringUtil func = new StringUtil();
		CoviMap dicObj = new CoviMap();
		try {
			String pDomainId = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(pDomainId).equals("")){
				pDomainId = "0";
			}
			
			return getBaseCodeGroupDic(pCodeGroup, pDomainId);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return dicObj;
	}
	
	public static CoviMap getBaseCodeGroupDic(String pCodeGroup, String pDomainID) throws Exception {
		StringUtil func = new StringUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String lang = SessionHelper.getSession("lang");
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		Set<String> names = instance.keys(pCodeGroup, PRE_BASECODE + pDomainID +"_" + pCodeGroup + "_*");
		if(names == null || names.size() == 0){
			names = instance.keys(pCodeGroup, PRE_BASECODE + "0" + "_" + pCodeGroup + "_*");
		}
		
		Iterator<String> it = names.iterator();
		CoviMap dicObj = new CoviMap();
		CoviMap temp;
		
		while (it.hasNext()) {
			//key에 해당하는 jsonobject를 array로 
			String baseCodeJsonStr = instance.get(it.next());
			if (StringUtils.isNoneBlank(baseCodeJsonStr)) {
				temp = new ObjectMapper().readValue(baseCodeJsonStr, CoviMap.class);
				dicObj.put(temp.getString("Code"), DicHelper.getDicInfo(temp.getString("MultiCodeName"),lang));
			}
		}
		
		return dicObj;
	}

	/*public static String getBaseCodeDic(String pCodeGroup, String pCode) throws Exception {
		
		return getBaseCodeDic(pCodeGroup, pCodeGroup, SessionHelper.getSession("lang"));
	}
	
	public static String getBaseCodeDic(String pCodeGroup, String pCode, String pDomainId) throws Exception {
		
		return getBaseCodeDic(pCodeGroup, pCodeGroup, SessionHelper.getSession("lang"));
	}*/
	public static String getBaseCodeDic(String pCodeGroup, String pCode, String pLang) throws Exception {
		StringUtil func = new StringUtil();
		String dic = "";
		try {
			String pDomainId = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(pDomainId).equals("")){
				pDomainId = "0";
			}
			
			return getBaseCodeDic(pCodeGroup, pCode, pLang, pDomainId);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return dic;
	}
	
	public static String getBaseCodeDic(String pCodeGroup, String pCode, String pLang, String pDomainID) throws Exception {
		String dic = "";
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String codeStr = instance.get(PRE_BASECODE + pDomainID + "_"  + pCodeGroup + "_" + pCode);
		
		if(codeStr == null){
			codeStr = instance.get(PRE_BASECODE + "0" + "_"  + pCodeGroup + "_" + pCode);
		}

		if(codeStr != null){
			dic = CoviMap.fromObject(codeStr).getString("MultiCodeName");
			dic = DicHelper.getDicInfo(dic, pLang);
		}
		
		return dic;
	}
	
	/**
	 * redis에 sys_base_code 값 set
	 * @param pKey
	 * @param pCodeGroup
	 * @param pValue는 json string 형태임에 주의할 것.
	 * @throws Exception
	 */
	public static void setBaseCode(String pKey, String pValue, String pCodeGroup) throws Exception {
/*		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.save(PRE_BASECODE + pCodeGroup + "_" + pKey, pValue);*/
		StringUtil func = new StringUtil();
		try {
			String pDomainID = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(pDomainID).equals("")){
				pDomainID = "0";
			}
			
			setBaseCode(pKey, pCodeGroup, pValue, pDomainID);
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	}
	
	public static void setBaseCode(String pKey, String pCodeGroup, String pValue, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		instance.save(PRE_BASECODE + pDomainID + "_" + pCodeGroup + "_" + pKey, pValue);
	}
	
	public static void removeBaseCode(String pKey, String pCodeGroup) throws Exception {
		StringUtil func = new StringUtil();
		try {
			String pDomainID = SessionHelper.getSession("DN_ID");
			
			if(func.f_NullCheck(pDomainID).equals("")){
				pDomainID = "0";
			}
			
			removeBaseCode(pKey, pCodeGroup,pDomainID);
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	}
	
	public static void removeBaseCode(String pKey, String pCodeGroup, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.remove(PRE_BASECODE + pDomainID + "_" +  pCodeGroup + "_" + pKey);
	}
	
	//dictionary
	public static String getDic(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		String strDic = "";
		
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0"; 
		}
		
		strDic = instance.get(PRE_DICTIONARY + pDomainID + "_" + pKey);
		
		if(!func.f_NullCheck(strDic).equals("")){
			return strDic;
		}else{
			strDic = instance.get(PRE_DICTIONARY + "0" + "_" + pKey);
			
			if(!func.f_NullCheck(strDic).equals("")){
				return strDic;
			}else{
				return "";
			}
		}
		
	}
	
	public static String getDicElement(String pKey, String pDomainID, String pColName) throws Exception {
		String strDicRet = "";
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(pDomainID).equals("")){
			pDomainID = "0";
		}
		
		String strJsonDic = instance.get(PRE_DICTIONARY + pDomainID + "_" + pKey);
		
	/*	if(func.f_NullCheck(strJsonDic).equals("")){
			//JSONObject jsonObj = new ObjectMapper().readValue(strJsonDic, CoviMap.class);
			//strDicRet = StringUtil.replaceNull(jsonObj.get(pColName));

			strDicRet = "";
		} else {*/
			if(!func.f_NullCheck(strJsonDic).equals("")){
				CoviMap jsonObj = new ObjectMapper().readValue(strJsonDic, CoviMap.class);
				strDicRet = StringUtil.replaceNull(jsonObj.get(pColName));
			}else{
				strJsonDic = instance.get(PRE_DICTIONARY + "0" + "_" + pKey);
				if(!func.f_NullCheck(strJsonDic).equals("")){
					CoviMap jsonObj = new ObjectMapper().readValue(strJsonDic, CoviMap.class);
					strDicRet = StringUtil.replaceNull(jsonObj.get(pColName));
				}else{
					strDicRet = "";
				}
			}
			
//		}
		
		return strDicRet;
	}
	
	public static void setDic(String pKey, String pDomainID, String pValue) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.save(PRE_DICTIONARY + pDomainID + "_" + pKey, pValue);
	}
	
	public static void removeDic(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.remove(PRE_DICTIONARY + pDomainID + "_" + pKey);
	}
	
	//ACL
	public static String getACL(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		return instance.get(PRE_ACL + pDomainID + "_" + pKey);
	}
	
	public static void setACL(String pKey, String pDomainID, String pValue) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.setex(PRE_ACL + pDomainID + "_" + pKey, 7200, pValue);
	}
	
	public static void removeACL(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.remove(PRE_ACL + pDomainID + "_" + pKey);
	}
	
	//Menu 보기 권한
	public static String getMenu(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		return instance.get(PRE_MENU + pDomainID + "_" + pKey);
	}
	
	public static void setMenu(String pKey, String pDomainID, String pValue) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.setex(PRE_MENU + pDomainID + "_" + pKey, 7200, pValue);
	}
	
	//Menu 실행 권한
	public static String getMenuExecute(String pKey, String pDomainID) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		return instance.get(PRE_MENU_E + pDomainID + "_" + pKey);
	}
	
	public static void setMenuExecute(String pKey, String pDomainID, String pValue) throws Exception {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.setex(PRE_MENU_E + pDomainID + "_" + pKey, 7200, pValue);
	}
	
	public static boolean checkExecute(String url, CoviList menuExecuteArray){
		boolean bRet = false;
		
		for (int i = 0; i < menuExecuteArray.size(); i++) {
			CoviMap menuObj = (CoviMap)menuExecuteArray.get(i);
			String menuURL = menuObj.getString("URL");
			//String splittedMenuURL = menuObj.getString("URL").split(".do")[0];
			//String splittedURL = url.split(".do")[0];
			if(StringUtils.isNoneBlank(menuURL) && url.contains(menuURL)){
				bRet = true;
				break;
			}
	    }
		
		return bRet;
	}
	

	public static void setACL(String pKey, String pDomainID, String pFieldName, String pValue, int pExpireTime) {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String keyName = "";
		
		keyName = PRE_H_ACL + pDomainID + "_" + pKey;
		instance.hset(keyName, pFieldName.toUpperCase(), pValue);
		instance.setExpireTime(keyName, pExpireTime);
	}
	
	public static void setACLAll(String pKey, String pDomainID, Map<String, String> pFieldValueMap, int pExpireTime) {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String keyName = "";
		keyName = PRE_H_ACL + pDomainID + "_" + pKey;
		instance.hmset(keyName, pFieldValueMap);
		instance.setExpireTime(keyName, pExpireTime);
	}
	
	
	public static String getACL(String pKey, String pDomainID, String pFieldName, int pExpireTime) {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String fieldValue = null;
		String keyName = "";
		
		keyName = PRE_H_ACL + pDomainID + "_" + pKey;
				
		fieldValue = instance.hget(keyName, pFieldName.toUpperCase());
		instance.setExpireTime(keyName, pExpireTime);
		return fieldValue;
	}
	
	public static String getACLSyncKey(String pDomainID, String pFieldName) {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String fieldValue = null;
		String keyName = PRE_H_ACL + pDomainID + "_SYNC_MAP";
		fieldValue = instance.hget(keyName, pFieldName.toUpperCase());
		
		// fieldValue 유효성 검사 및 키 유실의 경우 새로운 키 발급
		if(fieldValue == null || fieldValue.isEmpty()) {
			fieldValue = UUID.randomUUID().toString();
			// 새로운 synckey 저장 ( 전원 동기화 )
			instance.hset(keyName, pFieldName.toUpperCase(), fieldValue);
		}
		
		return fieldValue;
	}
	
	public static String refreshACLSyncKey(String pDomainID, String pFieldName) {
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String fieldValue = null;
		String keyName = PRE_H_ACL + pDomainID + "_SYNC_MAP";
		fieldValue = UUID.randomUUID().toString();
		// 새로운 synckey 저장 ( 전원 동기화 )
		instance.hset(keyName, pFieldName.toUpperCase(), fieldValue);
		return fieldValue;
	}
	
}
