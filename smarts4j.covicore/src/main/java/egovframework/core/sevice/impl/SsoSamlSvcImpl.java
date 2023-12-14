package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.sevice.SsoSamlSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ssoSaml")
public class SsoSamlSvcImpl extends EgovAbstractServiceImpl implements SsoSamlSvc{

	private Logger LOGGER = LogManager.getLogger(SsoSamlSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	
	@Override
	public String checkTokenKey(String empno) throws Exception {
		
		String value = "";
		CoviMap params = new CoviMap();
		params.put("empno",empno);
		
		value = (String) coviMapperOne.getString("sys.SsoSaml.selectTokenKey", params);
		return value;
		
	}
	
	public int checkUserCnt(String empno, String code) throws Exception{
		int cnt = 0;
		CoviMap params = new CoviMap();
		params.put("empno", empno);
		params.put("code", code);
		
		cnt = (int) coviMapperOne.getNumber("sys.SsoSaml.checkUserCnt", params);
		
		return cnt;
	}
	
	public String checkSSO(String OpType){
		String value = "";
		CoviMap params = new CoviMap();
		
		//향후 password는 암호화를 구현 할 것
		switch(OpType){
		
		 case "SERVER":
			params.put("Code", "sso_server");
			break;
		 case "DAY":
			params.put("Code","sso_expiration_day");
			break;
		 default: 
			 params.put("Code","sso_storage_path");
			 break;
		}
		params.put("DomainID", "0");
		value = (String) coviMapperOne.getString("sys.SsoSaml.selectSSOValue", params);
		return value;
	}
	
	public CoviMap checkAuthetication(String empno, String code) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("empno", empno);
		params.put("code", code);
			
		CoviMap account;
		account = coviMapperOne.select("sys.SsoSaml.selectSSO", params);
				
		resultList.put("map", CoviSelectSet.coviSelectJSON(account, "LanguageCode,LogonID,LogonPW,UR_ID,UR_Code,UR_EmpNo,UR_Name,UR_Mail,UR_JobPositionCode,UR_JobPositionName,UR_JobTitleCode,UR_JobTitleName,UR_JobLevelCode,UR_JobLevelName,UR_ManagerCode,UR_ManagerName,UR_IsManager,DN_ID,DN_Code,DN_Name,GR_Code,GR_Name,GR_GroupPath,GR_FullName,Attribute"));		
			
		resultList.put("account", account);
		resultList.put("status", "OK");
		
		return resultList;
	}
	

	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id)throws Exception{
		CoviMap params = new CoviMap();
		
		params.put("token", key);
		params.put("urid", urId);
		params.put("urname", urName);
		params.put("urcode", urCode);
		params.put("empno", empNo);
		params.put("maxage", maxAge);
		params.put("type", type);
		params.put("assertion_id", assertion_id);
		
		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.insert("common.login.ssoTokenHistory", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int checkUserAuthetication(String id, String password) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("id", id);
		params.put("password", password);
		params.put("aeskey", aeskey);
		
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("common.login.selectSSOCount", params);
		
		return cnt;
	}
	
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		/*
		 * 인증 처리를 세분화 할 것
		 * */
		boolean isAuthenticated = false;
		switch(authType){
			case "SAML":
				isAuthenticated = true;
				break;
				
			case "OAUTH":
				isAuthenticated = true;
				break;
				
			case "SSO":
				isAuthenticated = true;
				break;
			default :
				break;
		}
		
		
		if (isAuthenticated){
			//account 획득
			CoviMap params = new CoviMap();
			params.put("id", id);
			params.put("password", password);
			params.put("aeskey", aeskey);
			CoviMap account;
			
			if("SSO".equals(authType) || "SAML".equals(authType) || "OAUTH".equals(authType)){
				account = coviMapperOne.select("common.login.selectSSO", params);
			}else{
				account = coviMapperOne.select("common.login.select", params);
			}
			
				
			resultList.put("map", CoviSelectSet.coviSelectJSON(account, "LanguageCode,LogonID,LogonPW,UR_ID,UR_Code,UR_EmpNo,UR_Name,UR_Mail,UR_JobPositionCode,UR_JobPositionName,UR_JobTitleCode,UR_JobTitleName,UR_JobLevelCode,UR_JobLevelName,UR_ManagerCode,UR_ManagerName,UR_IsManager,DN_ID,DN_Code,DN_Name,GR_Code,GR_Name,GR_GroupPath,GR_FullName,Attribute"));		
			
			resultList.put("account", account);
			resultList.put("status", "OK");
			
		} else {
			resultList.put("account", null);
			resultList.put("status", "NOT");

		}
		
		return resultList;
	}
	
	public CoviMap selectTokenInForMation(String key) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		//account 획득
		CoviMap params = new CoviMap();
		params.put("key", key);
			
		CoviMap account;
			
		account = coviMapperOne.select("common.login.selectTokenInForMation", params);
				
		resultList.put("map", CoviSelectSet.coviSelectJSON(account, "TOKEN, LogonID, UR_Name, UR_Code, UR_EmpNo, MAXAGE, MODIFIERDATE"));		
			
		resultList.put("account", account);
		resultList.put("status", "OK");
		
		return resultList;
	}
	
}
