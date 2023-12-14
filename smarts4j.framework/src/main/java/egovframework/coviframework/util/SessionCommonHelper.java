package egovframework.coviframework.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.baseframework.util.SessionHelper;

public class SessionCommonHelper extends SessionHelper{
	
	/**
	 * @param pUserId
	 * @description 세션 생성
	 */
	
	public static void makeSession(String pUserId, boolean mobile) {
		CoviMap obj = new CoviMap();
		CoviMap obj_psm = new CoviMap();
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder
		        .getRequestAttributes()).getRequest();
		
		HttpSession session = request.getSession();
		
		//세션에 담을 데이터
		obj.put("USERID", pUserId);
		obj.put("GR_CODE", "CT");
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		String key = getSessionKey(request, mobile);
		String key_psm = pUserId ;
		
/*		if(mobile){
			key = session.getId();		//모바일로 접속시 CoviInterCeptor.java 에서 WAS session에 key값 등록 이후 참조
		} else {
			key = cUtil.getCooiesValue(request);
		}
		*/
		obj_psm.put("UserCode", pUserId);
		obj_psm.put("TokenKey", key);
		obj_psm.put("TEMP", func.getRandom());
		obj_psm.put("CSA_SC", "");
		obj_psm.put("UPCMD", "N");
		
		int sessionExpirationTime = Integer.parseInt(StringUtil.replaceNull(
												RedisDataUtil.getBaseConfig("sessionExpirationTime"), "3600"
									));
		
		if(!func.f_NullCheck(key).equals("")){
			instance.setex(key, sessionExpirationTime, obj.toString());
		}
		
		if(!func.f_NullCheck(key_psm).equals("") && !mobile){
			key_psm = key_psm + "_PSM";
			instance.setex(key_psm, sessionExpirationTime, obj_psm.toString());
		}
		
	}
	
	/**
	 * 세션 생성
	 * @param pUserId
	 * @param account
	 */
	public static void makeSession(String pUserId, CoviMap account, boolean mobile) throws Exception {
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
		String key = getSessionKey(request, mobile);
		makeSession(pUserId, account, mobile, key) ;
		 /*
		CoviMap obj = new CoviMap();
		CoviMap obj_psm = new CoviMap();
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder
		        .getRequestAttributes()).getRequest();
		
		HttpSession session = request.getSession();
		
		//세션에 담을 데이터
		obj.put("USERID", pUserId);
		obj.put("isAdmin", StringUtil.replaceNull(account.getString("IsAdmin"), ""));
		obj.put("isEasyAdmin", !StringUtil.replaceNull(account.getString("IsAdmin"),"N").equals("Y")&& StringUtil.replaceNull(account.getString("IsEasyAdmin"),"N").equals("Y")?"Y":"N");
		obj.put("AssignedDomain", StringUtil.replaceNull(account.getString("AssignedDomain"), ""));
		obj.put("USERNAME", StringUtil.replaceNull(account.get("UR_Name").toString(), ""));
		obj.put("DEPTID", StringUtil.replaceNull(account.get("GR_Code").toString(), ""));
		obj.put("DEPTNAME", StringUtil.replaceNull(account.get("GR_Name").toString(), ""));
		obj.put("lang", StringUtil.replaceNull(account.get("LanguageCode").toString(), ""));
		obj.put("LanguageCode", StringUtil.replaceNull(account.get("LanguageCode").toString(), ""));
		obj.put("LogonID", StringUtil.replaceNull(account.get("LogonID").toString(), ""));
		//obj.put("LogonPW", StringUtil.replaceNull(account.get("LogonPW").toString(), ""));
		obj.put("UR_ID", StringUtil.replaceNull(account.get("UR_ID").toString(), ""));
		obj.put("URBG_ID", StringUtil.replaceNull(account.get("URBG_ID").toString(), ""));
		obj.put("UR_Code", StringUtil.replaceNull(account.get("UR_Code").toString(), ""));
		obj.put("UR_EmpNo", StringUtil.replaceNull(account.get("UR_EmpNo").toString(), ""));
		obj.put("UR_Name", StringUtil.replaceNull(account.get("UR_Name").toString(), ""));
		obj.put("UR_Mail", StringUtil.replaceNull(account.get("UR_Mail").toString(), ""));
		obj.put("UR_JobPositionCode", StringUtil.replaceNull(account.get("UR_JobPositionCode").toString(), ""));
		obj.put("UR_JobPositionName", StringUtil.replaceNull(account.get("UR_JobPositionName").toString(), ""));
		obj.put("UR_JobTitleCode", StringUtil.replaceNull(account.get("UR_JobTitleCode").toString(), ""));
		obj.put("UR_JobTitleName", StringUtil.replaceNull(account.get("UR_JobTitleName").toString(), ""));
		obj.put("UR_JobLevelCode", StringUtil.replaceNull(account.get("UR_JobLevelCode").toString(), ""));
		obj.put("UR_JobLevelName", StringUtil.replaceNull(account.get("UR_JobLevelName").toString(), ""));
		obj.put("UR_ManagerCode", StringUtil.replaceNull(account.get("UR_ManagerCode").toString(), ""));
		obj.put("UR_ManagerName", StringUtil.replaceNull(account.get("UR_ManagerName").toString(), ""));
		obj.put("UR_IsManager", StringUtil.replaceNull(account.get("UR_IsManager").toString(), ""));
		obj.put("UR_InitPortal", StringUtil.replaceNull(account.get("UR_InitPortal").toString(), ""));
		obj.put("DN_ID", StringUtil.replaceNull(account.get("DN_ID").toString(), ""));
		obj.put("DN_Code", StringUtil.replaceNull(account.get("DN_Code").toString(), ""));
		obj.put("DN_Name", StringUtil.replaceNull(account.get("DN_Name").toString(), ""));
		obj.put("GR_Code", StringUtil.replaceNull(account.get("GR_Code").toString(), ""));
		obj.put("ApprovalParentGR_Code", StringUtil.replaceNull(account.get("ApprovalParentGR_Code").toString(), "")); // 전자결재 approvalble 0인 경우 상위부서 코드
		obj.put("ApprovalParentGR_Name", StringUtil.replaceNull(account.get("ApprovalParentGR_Name").toString(), "")); // 전자결재 approvalble 0인 경우 상위부서 이름
		obj.put("GR_Name", StringUtil.replaceNull(account.get("GR_Name").toString(), ""));
		obj.put("GR_GroupPath", StringUtil.replaceNull(account.get("GR_GroupPath").toString(), ""));
		obj.put("GR_FullName", StringUtil.replaceNull(account.get("GR_FullName").toString(), ""));
		obj.put("TopMenuConf", StringUtil.replaceNull(account.get("TopMenuConf").toString(), ""));
		obj.put("PhotoPath", StringUtil.replaceNull(account.get("PhotoPath").toString(), ""));
		obj.put("UR_TimeZone", StringUtil.replaceNull(account.get("UR_TimeZone").toString(), ""));
		obj.put("UR_TimeZoneCode", StringUtil.replaceNull(account.get("UR_TimeZoneCode").toString(), ""));
		obj.put("UR_TimeZoneDisplay", ComUtils.ConvertToTimeZoneDisplay(StringUtil.replaceNull(account.get("UR_TimeZone").toString(), "")));
		obj.put("UR_ThemeType", StringUtil.replaceNull(account.get("UR_ThemeType").toString(), ""));
		obj.put("UR_ThemeCode", StringUtil.replaceNull(account.get("UR_ThemeCode").toString(), ""));
		obj.put("DN_URL", account.get("UR_ThemeType").toString());
		obj.put("SubDomain", StringUtil.replaceNull(account.get("SubDomain").toString(), ""));
		obj.put("DN_Theme", "");
		obj.put("DELETE", "N");
		obj.put("DomainImagePath", StringUtil.replaceNull(account.get("DomainImagePath").toString(), ""));
		
		// 사용자 로그인 IP
		obj.put("UR_LoginIP", account.get("UR_LoginIP") != null?account.getString("UR_LoginIP"):"");

		// 사용자, 부서 다국어명 추가
		obj.put("UR_MultiName", StringUtil.replaceNull(account.get("UR_MultiName").toString(), ""));
		obj.put("UR_MultiJobPositionName", StringUtil.replaceNull(account.get("UR_MultiJobPositionName").toString(), ""));
		obj.put("UR_MultiJobTitleName", StringUtil.replaceNull(account.get("UR_MultiJobTitleName").toString(), ""));
		obj.put("UR_MultiJobLevelName", StringUtil.replaceNull(account.get("UR_MultiJobLevelName").toString(), ""));
		obj.put("GR_MultiName", StringUtil.replaceNull(account.get("GR_MultiName").toString(), ""));
		obj.put("UR_LoginTime",  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"));

		// 사용자 사업장 정보 추가
		obj.put("UR_RegionCode", StringUtil.replaceNull(account.get("UR_RegionCode").toString(), ""));
		obj.put("UR_MultiRegionName", StringUtil.replaceNull(account.get("UR_MultiRegionName").toString(), ""));

		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		String key = getSessionKey(request, mobile);
		String key_psm = pUserId;
		
		obj_psm.put("UserCode", pUserId);
		obj_psm.put("TokenKey", key);
		obj_psm.put("TEMP", func.getRandom());
		obj_psm.put("CSA_SC", "");
		obj_psm.put("UPCMD", "N");
		
		int sessionExpirationTime = Integer.parseInt(StringUtil.replaceNull(
												RedisDataUtil.getBaseConfig("sessionExpirationTime", obj.getString("DN_ID")), "3600"
									));
		
		if(!"".equals(func.f_NullCheck(key))){
			instance.setex(key, sessionExpirationTime, obj.toString());
		}
		
		if(!"".equals(func.f_NullCheck(key_psm)) && !mobile){
			key_psm = key_psm + "_PSM";
			instance.setex(key_psm, sessionExpirationTime, obj_psm.toString());
		}*/
		
	}

	public static void makeSession(String pUserId, CoviMap account, boolean mobile, String key) throws Exception {
		CoviMap obj = new CoviMap();
		CoviMap obj_psm = new CoviMap();
		StringUtil func = new StringUtil();
		//CookiesUtil cUtil = new CookiesUtil();
		
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder
		        .getRequestAttributes()).getRequest();
		
		HttpSession session = request.getSession();
		/*StringBuffer temp = new StringBuffer();*/
		
		//세션에 담을 데이터
		account.setReturnNullString(false);
		obj.put("USERID", pUserId);
		obj.put("isAdmin", StringUtil.replaceNull(account.getString("IsAdmin"), ""));
		
		//obj.put("isEasyAdmin", !StringUtil.replaceNull(account.getString("IsAdmin"),"N").equals("Y")&& StringUtil.replaceNull(account.getString("IsEasyAdmin"),"N").equals("Y")?"Y":"");
		obj.put("AssignedDomain", StringUtil.replaceNull(account.getString("AssignedDomain"), ""));
		obj.put("USERNAME", StringUtil.replaceNull(account.get("UR_Name"), ""));
		obj.put("DEPTID", StringUtil.replaceNull(account.get("GR_Code"), ""));
		obj.put("DEPTNAME", StringUtil.replaceNull(account.get("GR_Name"), ""));
		obj.put("lang", StringUtil.replaceNull(account.get("LanguageCode"), ""));
		obj.put("LanguageCode", StringUtil.replaceNull(account.get("LanguageCode"), ""));
		obj.put("LogonID", StringUtil.replaceNull(account.get("LogonID"), ""));
		//obj.put("LogonPW", StringUtil.replaceNull(account.get("LogonPW"), ""));
		obj.put("UR_ID", StringUtil.replaceNull(account.get("UR_ID"), ""));
		obj.put("URBG_ID", StringUtil.replaceNull(account.get("URBG_ID"), ""));
		obj.put("UR_Code", StringUtil.replaceNull(account.get("UR_Code"), ""));
		obj.put("UR_EmpNo", StringUtil.replaceNull(account.get("UR_EmpNo"), ""));
		obj.put("UR_Name", StringUtil.replaceNull(account.get("UR_Name"), ""));
		obj.put("UR_Mail", StringUtil.replaceNull(account.get("UR_Mail"), ""));
		obj.put("UR_JobPositionCode", StringUtil.replaceNull(account.get("UR_JobPositionCode"), ""));
		obj.put("UR_JobPositionName", StringUtil.replaceNull(account.get("UR_JobPositionName"), ""));
		obj.put("UR_JobTitleCode", StringUtil.replaceNull(account.get("UR_JobTitleCode"), ""));
		obj.put("UR_JobTitleName", StringUtil.replaceNull(account.get("UR_JobTitleName"), ""));
		obj.put("UR_JobLevelCode", StringUtil.replaceNull(account.get("UR_JobLevelCode"), ""));
		obj.put("UR_JobLevelName", StringUtil.replaceNull(account.get("UR_JobLevelName"), ""));
		obj.put("UR_ManagerCode", StringUtil.replaceNull(account.get("UR_ManagerCode"), ""));
		obj.put("UR_ManagerName", StringUtil.replaceNull(account.get("UR_ManagerName"), ""));
		obj.put("UR_IsManager", StringUtil.replaceNull(account.get("UR_IsManager"), ""));
		obj.put("UR_InitPortal", StringUtil.replaceNull(account.get("UR_InitPortal"), ""));
		obj.put("DN_ID", StringUtil.replaceNull(account.get("DN_ID"), ""));
		obj.put("DN_Code", StringUtil.replaceNull(account.get("DN_Code"), ""));
		obj.put("DN_Name", StringUtil.replaceNull(account.get("DN_Name"), ""));
		obj.put("GR_Code", StringUtil.replaceNull(account.get("GR_Code"), ""));
		obj.put("ApprovalParentGR_Code", StringUtil.replaceNull(account.get("ApprovalParentGR_Code"), "")); // 전자결재 approvalble 0인 경우 상위부서 코드
		obj.put("ApprovalParentGR_Name", StringUtil.replaceNull(account.get("ApprovalParentGR_Name"), "")); // 전자결재 approvalble 0인 경우 상위부서 이름
		obj.put("GR_Name", StringUtil.replaceNull(account.get("GR_Name"), ""));
		obj.put("GR_GroupPath", StringUtil.replaceNull(account.get("GR_GroupPath"), ""));
		obj.put("GR_FullName", StringUtil.replaceNull(account.get("GR_FullName"), ""));
		obj.put("TopMenuConf", StringUtil.replaceNull(account.get("TopMenuConf"), ""));
		obj.put("PhotoPath", StringUtil.replaceNull(account.get("PhotoPath"), ""));
		obj.put("UR_TimeZone", StringUtil.replaceNull(account.get("UR_TimeZone"), ""));
		obj.put("UR_TimeZoneCode", StringUtil.replaceNull(account.get("UR_TimeZoneCode"), ""));
		obj.put("UR_TimeZoneDisplay", ComUtils.ConvertToTimeZoneDisplay(StringUtil.replaceNull(account.get("UR_TimeZone_Display"), "")));
//		obj.put("UR_ThemeType", StringUtil.replaceNull(account.get("UR_ThemeType"), ""));
//		obj.put("DN_URL", account.get("UR_ThemeType"));
		obj.put("SubDomain", StringUtil.replaceNull(account.get("SubDomain"), ""));
		obj.put("DN_URL", StringUtil.replaceNull(account.get("DomainUrl"), ""));
		
		obj.put("DN_Theme", "");
		obj.put("DELETE", "N");
		obj.put("DomainImagePath", StringUtil.replaceNull(account.get("DomainImagePath"), ""));
		obj.put("IsUseMessenger", StringUtil.replaceNull(account.get("IsUseMessenger"), "N"));
		
		// 사용자 로그인 IP
		obj.put("UR_LoginIP", account.get("UR_LoginIP") != null?account.getString("UR_LoginIP"):"");

		// 사용자, 부서 다국어명 추가
		obj.put("UR_MultiName", StringUtil.replaceNull(account.get("UR_MultiName"), ""));
		obj.put("UR_MultiJobPositionName", StringUtil.replaceNull(account.get("UR_MultiJobPositionName"), ""));
		obj.put("UR_MultiJobTitleName", StringUtil.replaceNull(account.get("UR_MultiJobTitleName"), ""));
		obj.put("UR_MultiJobLevelName", StringUtil.replaceNull(account.get("UR_MultiJobLevelName"), ""));
		obj.put("GR_MultiName", StringUtil.replaceNull(account.get("GR_MultiName"), ""));
		obj.put("UR_LoginTime",  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss",0,StringUtil.replaceNull(account.get("UR_TimeZone"), "") ));

		// 사용자 사업장 정보 추가
		obj.put("UR_RegionCode", StringUtil.replaceNull(account.get("UR_RegionCode"), ""));
		obj.put("UR_MultiRegionName", StringUtil.replaceNull(account.get("UR_MultiRegionName"), ""));

		//사용자 개인키 생성 
		obj.put("UR_PrivateKey",  makePrivateKey(pUserId));
		
		obj.put("UR_InitialConnection",  StringUtil.replaceNull(account.get("INITIAL_CONNECTION"), ""));
		obj.put("UR_UseMailConnect",  StringUtil.replaceNull(account.get("UseMailConnect"), "Y"));
		obj.put("UR_LicSeq",  StringUtil.replaceNull(account.get("LicSeq"), ""));
		obj.put("UR_LicName",  StringUtil.replaceNull(account.get("LicName"), ""));
		obj.put("UR_LicInitPortal",  StringUtil.replaceNull(account.get("LicInitPortal"), ""));
		obj.put("UR_LicIsMbPortal",  StringUtil.replaceNull(account.get("LicIsMbPortal"), "Y"));
		
		// 사용자 보안등급
		obj.put("SecurityLevel",  StringUtil.replaceNull(account.get("SecurityLevel"), "256"));
		obj.put("PortalOption",  StringUtil.replaceNull(account.get("PortalOption"), "{}"));
		
		//최근접속정보
		if (!StringUtil.replaceNull(account.get("LogonDate"), "").equals("")){
			obj.put("RecentLogonDate",  ComUtils.TransLocalTime(StringUtil.replaceNull(account.get("LogonDate"), ""),"yyyy-MM-dd HH:mm:ss",StringUtil.replaceNull(account.get("UR_TimeZone"))));
		}

		String easyAdmin  = StringUtil.replaceNull(account.get("DN_ID"), "")+"_EasyAdmin";
		if (!StringUtil.replaceNull(account.getString("IsAdmin"),"N").equals("Y") 
				&& ACLHelper.getExitsUserGroup(obj, easyAdmin) ) {
			obj.put("isEasyAdmin", "Y");
		}	else{
			obj.put("isEasyAdmin", "");
		}	
			
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		String key_psm = pUserId;
		
		if(mobile){
			key = getSessionKey(request, mobile);		//모바일로 접속시 CoviInterCeptor.java 에서 WAS session에 key값 등록 이후 참조
		}
		
		obj_psm.put("UserCode", pUserId);
		obj_psm.put("TokenKey", key);
		obj_psm.put("TEMP", func.getRandom());
		obj_psm.put("CSA_SC", "");
		obj_psm.put("UPCMD", "N");
		
		int sessionExpirationTime = Integer.parseInt(StringUtil.replaceNull(
												RedisDataUtil.getBaseConfig("sessionExpirationTime", obj.getString("DN_ID")), "3600"
									));
		
		// TODO : 세션 생성
		if(!"".equals(func.f_NullCheck(key))){
			instance.setex(key, sessionExpirationTime, obj.toString());
		}
		
		if(!"".equals(func.f_NullCheck(key_psm)) && !mobile){
			key_psm = key_psm + "_PSM";
			instance.setex(key_psm, sessionExpirationTime, obj_psm.toString());
		}
		
		//권한 삭제
		instance.remove(RedisDataUtil.PRE_H_ACL + StringUtil.replaceNull(account.get("DN_ID") + "_" + pUserId + "_" + StringUtil.replaceNull(account.get("URBG_ID"), "")));
		
		//메뉴 삭제
		instance.remove(RedisDataUtil.PRE_MENU + StringUtil.replaceNull(account.get("DN_ID") + "_" + pUserId + "_" + StringUtil.replaceNull(account.get("URBG_ID"), "")));
	}
	
	public static String getSessionKey(HttpServletRequest request, boolean mobile){
//		HttpServletRequest request = requestAttr.getRequest();
		HttpSession session = request.getSession();
		CookiesUtil cUtil = new CookiesUtil();
		String key = cUtil.getCooiesValue(request);
		if (mobile && key.isEmpty() && session.getAttribute("KEY") != null){
			key = (String)session.getAttribute("KEY");
		}
/*		if(mobile){
			key = session.getId();		//모바일로 접속시 CoviInterCeptor.java 에서 WAS session에 key값 등록 이후 참조
		} else {
			key = cUtil.getCooiesValue(request);
		}*/
		return key;
	}
	
	private static String makePrivateKey(String userId){
		return egovframework.baseframework.sec.Sha512.encrypt(userId+ComUtils.GetLocalCurrentDate("yyyyMMddHHmmss"));
	}
	
	/**
	 * 세션 데이터 추가
	 * @param pKey
	 * @param pValue
	 */
	public static void setSession(String pKey, CoviMap pValue) {
		StringUtil func = new StringUtil();
		
		CookiesUtil cUtil = new CookiesUtil();
		
		ServletRequestAttributes requestAttr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		
		if(requestAttr == null) {
			logger.error("[setSession] RequestAttributes is null");
			return;
		}
		
		HttpServletRequest request = requestAttr.getRequest();
		HttpSession session = request.getSession();
		
		String key = getSessionKey(request, ClientInfoHelper.isMobile(request));
		/*
		if(ClientInfoHelper.isMobile(request)){
			key = session.getId();		//모바일로 접속시 CoviInterCeptor.java 에서 WAS session에 key값 등록 이후 참조
		} else {
			key = cUtil.getCooiesValue(request);
		}*/
		
		if(!func.f_NullCheck(key).equals("")){
			int sessionExpirationTime = Integer.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("sessionExpirationTime"), "3600"));
			
			CoviMap obj = new CoviMap();
			
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			obj = CoviMap.fromObject(instance.get(key));
			obj.put(pKey,pValue);
			instance.setex(key, sessionExpirationTime, obj.toString());
		}
		 
	}
	
	
	/**
	 * 세션 속성값 조회
	 * @param pKey
	 * @return
	 */
	public static CoviMap getSessionMap(String pKey) {
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		CoviMap cmap  = new CoviMap();
		
		ServletRequestAttributes requestAttr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		
		if(requestAttr == null) {
			return cmap;
		}
		
		HttpServletRequest request = requestAttr.getRequest();
		String key = getSessionKey(request, ClientInfoHelper.isMobile(request));

		if(!func.f_NullCheck(key).equals("")){
			CoviMap obj = new CoviMap();
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			obj = CoviMap.fromObject(instance.get(key));
			
			if(obj.containsKey(pKey) && obj.get(pKey) instanceof CoviMap ){
				return (CoviMap)obj.get(pKey);
			} else {
				return cmap;
			}
		}else{
			return cmap;
		}
		
	}
	
	

	/**
	 * 세션 속성값 조회
	 * @param pKey
	 * @return
	 */
	public static String getSessionMapKey(String pKey, String pOptKey) {
		return getSessionMapKey(pKey, pOptKey, "");
	}
	
	public static String getSessionMapKey(String pKey, String pOptKey, String def) {
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		CoviMap cmap = (CoviMap)getSessionMap(pKey);

		if (cmap != null && cmap.get(pOptKey) != null ){
			return cmap.get(pOptKey).toString();
		}else{
			return def;
		}
	}
}
 