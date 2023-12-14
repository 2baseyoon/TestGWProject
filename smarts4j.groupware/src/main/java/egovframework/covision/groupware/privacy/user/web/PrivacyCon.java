package egovframework.covision.groupware.privacy.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.PrivateKey;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.RSA;
import egovframework.baseframework.data.CoviList;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.SessionService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import egovframework.covision.groupware.privacy.user.service.PrivacySvc;
import egovframework.covision.groupware.util.BoardUtils;

// 개인환경설정
@Controller
@RequestMapping("privacy")
public class PrivacyCon {
	private Logger LOGGER = LogManager.getLogger(PrivacyCon.class);
	private final String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
		
	@Autowired
	private PrivacySvc privacySvc;
	@Autowired
	private PortalSvc portalSvc;
	@Autowired
	private SessionService sessionSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	// 개인환경 설정 > 기본정보
	@RequestMapping(value = "/getUserPrivacySetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserPrivacySetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		PrivacyCon privacyCon = new PrivacyCon();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap param = new CoviMap();
			param.put("userCode", SessionHelper.getSession("USERID"));
			param.put("seq", SessionHelper.getSession("URBG_ID"));
			param.put("nowPassword",request.getParameter("nowPassword"));
			param.put("id",request.getParameter("id"));
			param.put("__CoviRPK__", request.getSession().getAttribute("__CoviRPK__"));

			switch(PropertiesUtil.getSecurityProperties().getProperty("loginAuthType").toUpperCase()) {
				case "DB":
				case "AD":
					String pId = privacySvc.selectUserAuthetication(param) ;
					if(!"".equals(func.f_NullCheck(pId))) {
						if(privacySvc.checkPasswordCnt(param) > 0) {
							returnList.put("data", privacySvc.getUserPrivacySetting(param).get("map"));
							returnList.put("status", Return.SUCCESS);
							returnList.put("message", "조회 되었습니다");
						}else {
							returnList.put("status", "NOT_ALLOW");
							returnList.put("message", DicHelper.getDic("msg_ObjectUR_05"));
							return returnList;
						}
					}else {
						returnList.put("status", "NOT_ALLOW");
						returnList.put("message", DicHelper.getDic("msg_ObjectUR_05"));
						return returnList;
					}
					break;
				default :
					returnList.put("data", privacySvc.getUserPrivacySetting(param).get("map"));
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "조회 되었습니다");
					break;
			}
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 개인환경 설정 > 패스워드 암호화 방식 체크
	@RequestMapping(value = "/cryptoTypeCheck.do")
	public @ResponseBody CoviMap cryptoTypeCheck(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		RSA rsa = RSA.getEncKey();
		
		CoviMap returnData = new CoviMap();
		if(func.f_NullCheck(cryptoType).equals("R")){
			returnData.put("publicKeyModulus", rsa.getPublicKeyModulus());
			returnData.put("publicKeyExponent", rsa.getPublicKeyExponent());
			
			request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
		}
		returnData.put("status", Return.SUCCESS);
		return returnData;
	}

	// 개인환경 설정 > 기본정보 수정
	@RequestMapping(value = "/updateUserInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateUserInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userId", request.getParameter("userId"));
			//2019.05 인증된 사용자 정보 변경하도록 변경
			//params.put("userCode", request.getParameter("userCode"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("birthDiv", request.getParameter("birthDiv"));
			params.put("birthDate", ComUtils.RemoveScriptAndStyle(request.getParameter("birthDate")));
			params.put("isBirthLeapMonth", request.getParameter("isBirthLeapMonth"));
			params.put("externalMailAddress", ComUtils.RemoveScriptAndStyle(request.getParameter("externalMailAddress")));
			params.put("mobile", ComUtils.RemoveScriptAndStyle(request.getParameter("mobile")));
			params.put("fax", ComUtils.RemoveScriptAndStyle(request.getParameter("fax")));
			params.put("phoneNumberInter", ComUtils.RemoveScriptAndStyle(request.getParameter("phoneNumberInter")));
			params.put("phoneNumber", ComUtils.RemoveScriptAndStyle(request.getParameter("phoneNumber")));
			params.put("chargeBusiness", ComUtils.RemoveScriptAndStyle(request.getParameter("chargeBusiness")));
			params.put("photoFileId", request.getParameter("photoFileId"));
			params.put("deleteFileId", request.getParameter("deleteFileId"));
			params.put("timeZoneCode", request.getParameter("timeZoneCode"));
						
			int result = privacySvc.updateUserInfo(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경 설정 > 부재설정 수정
	@RequestMapping(value = "/updateUserAbsense.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateUserAbsense(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", request.getParameter("userCode"));
			params.put("absenseUseYn", request.getParameter("absenseUseYn"));
			params.put("absenseType", request.getParameter("absenseType"));
			params.put("absenseTermStart", request.getParameter("absenseTermStart"));
			params.put("absenseTermEnd", request.getParameter("absenseTermEnd"));
			params.put("absenseDuty", request.getParameter("absenseDuty"));
			params.put("absenseReason", request.getParameter("absenseReason"));
		
			int result = privacySvc.updateUserAbsense(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}	
	
	// 개인환경 설정 > PUSH알림설정 수정
	@RequestMapping(value = "/updateUserPush.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateUserPush(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("pushAllowYN", request.getParameter("pushAllowYN"));
			params.put("pushAllowStartTime", request.getParameter("pushAllowStartTime"));
			params.put("pushAllowEndTime", request.getParameter("pushAllowEndTime"));
			params.put("pushAllowWeek", request.getParameter("pushAllowWeek"));
			
			int result = privacySvc.updateUserPush(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	//세션값 변경
	@RequestMapping(value = "/setMyInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setSession(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try{
			String paramType = request.getParameter("type");
			String paramValue = request.getParameter("value");
			CoviMap params = new CoviMap();
			if ("ChangePosition".equals(paramType)) {
				params.put("seq", paramValue);
				params.put("lang", SessionHelper.getSession("lang"));
				
				CoviMap map = privacySvc.getUseBaseGroup(params);
				
				if(map == null || map.get("DomainID") == null) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_hr_od_err13")); // 이미 해제된 겸직 내역입니다.
					return returnList;
				}
				SessionHelper.setSession("URBG_ID", paramValue);
				SessionHelper.setSession("GR_FullName", map.getString("GroupFullName"));
				SessionHelper.setSession("GR_GroupPath", map.getString("GroupPath"));
				SessionHelper.setSession("DEPTID", map.getString("DeptCode"));
				SessionHelper.setSession("DEPTNAME", map.getString("DeptName"));
				SessionHelper.setSession("GR_Name", map.getString("DeptName"));
				SessionHelper.setSession("GR_Code", map.getString("DeptCode"));
				SessionHelper.setSession("DN_ID", map.getString("DomainID"));
				SessionHelper.setSession("DN_Code", map.getString("CompanyCode"));
				SessionHelper.setSession("DN_Name", map.getString("CompanyName"));
				SessionHelper.setSession("UR_JobPositionName", map.getString("JobPositionName"));
				SessionHelper.setSession("UR_JobPositionCode", map.getString("JobPositionCode"));
				SessionHelper.setSession("UR_JobTitleCode", map.getString("JobTitleCode"));
				SessionHelper.setSession("UR_JobTitleName", map.getString("JobTitleName"));
				SessionHelper.setSession("UR_JobLevelCode", map.getString("JobLevelCode"));
				SessionHelper.setSession("UR_JobLevelName", map.getString("JobLevelName"));
				SessionHelper.setSession("ApprovalParentGR_Code", map.getString("ApprovalParentGR_Code")); // [19-08-28] kimhs, 전자결재 부서함에서 겸직부서 문서 볼 수 있도록 처리.
				SessionHelper.setSession("ApprovalParentGR_Name", map.getString("ApprovalParentGR_Name")); 
				
				// 다국어정보 추가 갱신(결재에서 사용) 2020.7.15
				SessionHelper.setSession("UR_MultiJobPositionName", map.getString("UR_MultiJobPositionName"));
				SessionHelper.setSession("UR_MultiJobTitleName", map.getString("UR_MultiJobTitleName"));
				SessionHelper.setSession("UR_MultiJobLevelName", map.getString("UR_MultiJobLevelName"));
				SessionHelper.setSession("GR_MultiName", map.getString("GR_MultiName"));
			} else if("Lang".equals(paramType)){
				params.put("seq", SessionHelper.getSession("URBG_ID"));
				params.put("lang", paramValue);
				
				CoviMap map = privacySvc.getUserGroupName(params);
				
				SessionHelper.setSession("lang", paramValue);
				SessionHelper.setSession("LanguageCode", paramValue);
				SessionHelper.setSession("USERNAME", map.getString("UR_Name"));
				SessionHelper.setSession("UR_Name", map.getString("UR_Name"));
				SessionHelper.setSession("GR_Name", map.getString("DeptName"));
				SessionHelper.setSession("DEPTNAME", map.getString("DeptName"));
				SessionHelper.setSession("DN_Name", map.getString("CompanyName"));
				SessionHelper.setSession("UR_JobPositionName", map.getString("JobPositionName"));
				SessionHelper.setSession("UR_JobTitleName", map.getString("JobTitleName"));
				SessionHelper.setSession("UR_JobLevelName", map.getString("JobLevelName"));

				sessionSvc.updateUserLanguageCode(SessionHelper.getSession("UR_Code"), paramValue);
			} else if("Theme".equals(paramType)){
				SessionHelper.setSession("UR_ThemeType", paramValue);		//blue, red, green
				params.put("themeType", paramValue);
				params.put("userCode", SessionHelper.getSession("USERID"));
				privacySvc.updateThemeType(params);
			}else if("Portal".equals(paramType)){
				SessionHelper.setSession("UR_InitPortal", paramValue);		//blue, red, green
				params.put("initPortalID", paramValue);
				params.put("userCode", SessionHelper.getSession("USERID"));
				portalSvc.updateInitPortal(params);
			}
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	
	// 개인환경 설정 > 부재설정 수정
	@RequestMapping(value = "/getUserBaseGroupAll.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserBaseGroupAll(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			params.put("userCode",userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
		
			CoviList list = (CoviList) privacySvc.getUserBaseGroupAll(params).get("list");
			
			returnData.put("list", list);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인정보 조회
	@RequestMapping(value = "/getUserBasicInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {			
			CoviMap params = new CoviMap();
			params.put("userCode",request.getParameter("userCode"));
			params.put("lang", SessionHelper.getSession("lang"));
		
			CoviList list = (CoviList) privacySvc.getUserBaseGroupAll(params).get("list");
			
			returnData.put("list", list);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 통합 메세징 설정 조회
	@RequestMapping(value = "/getUserMessagingSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserMessagingSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
		
			CoviMap msgData = privacySvc.getUserMessagingSetting(params);
			CoviList list = (CoviList)msgData.get("data");
			CoviList retList = new CoviList();
			
			for (int i=0; i< list.size();i++){
				CoviMap cmap = (CoviMap)list.get(i);
				if (ComUtils.getAssignedBizSection(cmap.getString("bizSection"))){
					retList.add(cmap);
				}

			}	
			msgData.put("data", retList);
			returnData.put("list", msgData);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 통합 메세징 설정
	@RequestMapping(value = "/updateUserMessagingSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateUserMessagingSetting(@RequestBody SettingVO settingVO) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("settingVO", settingVO);
			
			int result = privacySvc.updateUserMessagingSetting(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 통합 메세징 설정 > 모두 초기화
	@RequestMapping(value = "/deleteUserMessagingSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserMessagingSetting(@RequestBody SettingVO settingVO) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("settingVO", settingVO);
			
			int result = privacySvc.deleteUserMessagingSetting(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 접속이력
	@RequestMapping(value = "/getConnectionLogList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getConnectionLogList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("userId", SessionHelper.getSession("LogonID"));
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			resultList = privacySvc.getConnectionLogList(params);			
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//개인 메인메뉴(탑메뉴) 설정
	@RequestMapping(value = "/updateTopMenuManage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateTopMenuManage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int result = privacySvc.updateTopMenuManage(params);
			if(result > 0){
				SessionHelper.setSession("TopMenuConf", params.getString("topMenuConf"));
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "수정 되었습니다");
			} else {
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "설정 변경에 실패했습니다.");
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 기념일 관리
	@RequestMapping(value = "/getAnniversaryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAnniversaryList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("messageId", request.getParameter("messageId"));
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			resultList = privacySvc.getAnniversaryList(params);
						
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 개인환경설정 > 기념일 관리
	@RequestMapping(value = "/getAnniversary.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAnniversary(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("messageId", request.getParameter("messageId"));
			
			resultList = privacySvc.getAnniversaryList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 개인환경설정 > 기념일 관리 > 추가, 수정 팝업
	@RequestMapping(value = "/goAnniversaryPopup.do", method = RequestMethod.GET)
	public ModelAndView goAnniversaryPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/privacy/AnniversaryPopup");
	}
	
	// 개인환경설정 > 기념일 관리 > 추가
	@RequestMapping(value = "/insertAnniversary.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertAnniversary(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("urCode", SessionHelper.getSession("USERID"));
			params.put("subject", request.getParameter("subject"));
			params.put("description", request.getParameter("description"));
			params.put("alramPeriod", request.getParameter("alramPeriod"));
			params.put("anniDate", request.getParameter("anniDate"));
			params.put("anniDateType", request.getParameter("anniDateType"));
			params.put("priority", request.getParameter("priority"));
			params.put("alarmYn", request.getParameter("alarmYn"));
			params.put("isLeapMonth", request.getParameter("isLeapMonth"));
			
			int result = privacySvc.insertAnniversary(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 기념일 관리 > 수정
	@RequestMapping(value = "/updateAnniversary.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateAnniversary(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("messageId", request.getParameter("messageId"));
			params.put("subject", request.getParameter("subject"));
			params.put("description", request.getParameter("description"));
			params.put("alramPeriod", request.getParameter("alramPeriod"));
			params.put("anniDate", request.getParameter("anniDate"));
			params.put("anniDateType", request.getParameter("anniDateType"));
			params.put("priority", request.getParameter("priority"));
			params.put("alarmYn", request.getParameter("alarmYn"));
			params.put("isLeapMonth", request.getParameter("isLeapMonth"));
			
			int result = privacySvc.updateAnniversary(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 기념일 관리 > 삭제
	@RequestMapping(value = "/deleteAnniversary.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteAnniversary(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("messageIdArr", StringUtil.replaceNull(request.getParameter("messageIdArr"), "").split("\\,"));
			
			int result = privacySvc.deleteAnniversary(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 기념일 관리 > 기념일 가져오기
	@RequestMapping(value = "/goAnniversaryExcelUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView goAnniversaryExcelUploadPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/privacy/AnniversaryExcelUploadPopup");
	}
	
	// 개인환경설정 > 기념일 관리 > 기념일 가져오기 > 템플릿 파일 다운로드
	@RequestMapping(value = "/excelTemplateDownload.do")
	public void excelTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String FileName = "AnniversaryInsertExcel.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AnniversaryInsert_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, new CoviMap());
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 개인환경설정 > 기념일 관리 > 기념일 가져오기 > 엑셀 업로드
	@RequestMapping(value = "/excelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("urCode", SessionHelper.getSession("USERID"));
			params.put("uploadfile", uploadfile);
			
			int result = privacySvc.insertAnniversaryByExcel(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "업로드 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	// 개인환경설정 > 기념일 관리 > 기념일 가져오기 > 엑셀 다운로드
	@RequestMapping(value = "/excelDownload.do")
	public void excelDownload(HttpServletRequest request, HttpServletResponse response) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = new CoviMap();
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			
			String FileName = "Anniversary.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Anniversary_templete.xlsx");
			
			CoviMap resultList = privacySvc.getAnniversaryList(params);
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, resultList);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 개인환경설정 > 기념일 관리 > 일정등록 팝업
	@RequestMapping(value = "/goCalendarPopup.do", method = RequestMethod.GET)
	public ModelAndView goCalendarPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/privacy/CalendarPopup");
	}
	
	// 개인환경설정 > 기념일 관리 > 일정등록 팝업
	@RequestMapping(value = "/goSimpleMake.do", method = RequestMethod.GET)
	public ModelAndView goSimpleMake(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("cmmn/simple_make");
	}
	
	// 개인환경설정 > 기본정보 > 이미지업로드 팝업
	@RequestMapping(value = "/goImageUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView goImageUploadPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/privacy/ImageUploadPopup");
	}
	
	// 개인환경설정 > 기본정보 > 이미지업로드
	@RequestMapping(value = "/imageUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap imageUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		int modifyStatus = 0;
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			CoviMap result = privacySvc.updateUserImage(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "업로드 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	@RequestMapping(value = "/removeGmail.do")
	public @ResponseBody CoviMap removeGmail(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UR_CODE", SessionHelper.getSession("USERID"));
			
			if(!privacySvc.removeGmail(params)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", "삭제에 실패하였습니다.");
			}else{
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "삭제 되었습니다");
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "삭제에 실패하였습니다.");
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "삭제에 실패하였습니다.");
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		
		return returnData;
	}
	
	// 나의 메뉴 > 포탈 리스트 
	@RequestMapping(value = "/getMyPortalList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyPortalList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CookiesUtil cUtil = new CookiesUtil();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			String key = cUtil.getCooiesValue(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile, key);
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "PT", "", "V");
			
			String userID = userDataObj.getString("USERID");
			
			CoviList list = privacySvc.selectMyPortalList(authorizedObjectCodeSet, userID);
			
			returnData.put("status", Return.SUCCESS);
			returnData.put("list", list);
			returnData.put("result", "ok");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
		
	
	
}
