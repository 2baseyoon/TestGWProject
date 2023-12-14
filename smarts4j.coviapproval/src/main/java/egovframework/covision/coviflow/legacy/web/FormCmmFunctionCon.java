package egovframework.covision.coviflow.legacy.web;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.Map;
import java.util.Objects;
import java.util.Arrays;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import egovframework.baseframework.util.*;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.*;
import egovframework.coviframework.logging.LoggerHelper;
import net.sf.json.JSONException;


import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.LegacyConnectionFactory;
import egovframework.covision.coviflow.legacy.service.FormCmmFunctionSvc;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceSvc;
import egovframework.covision.coviflow.legacy.service.impl.LegacyInterfaceHTTPImpl;
import egovframework.covision.coviflow.legacy.service.impl.LegacyInterfaceJAVAMgr;
import egovframework.covision.coviflow.legacy.service.impl.LegacyInterfaceSOAPImpl;
import egovframework.covision.coviflow.legacy.service.impl.LegacyInterfaceSQLImpl;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;
import egovframework.covision.coviflow.govdocs.service.OpenDocSvc;


/**
 * @Class Name : FormCmmFunctionCon.java
 * @Description : 양식 내에서 DB 내용을 조회
 * @Modification Information 
 * @ 2017.01.31 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 01.31
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class FormCmmFunctionCon {
	
	private Logger LOGGER = LogManager.getLogger(FormCmmFunctionCon.class);
	
	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	
	@Autowired
	private FormCmmFunctionSvc formCmmFunctionSvc;
	
	@Autowired
	private ApprovalGovDocSvc approvalGovDocSvc;
	
	@Autowired
	private OpenDocSvc openDocSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	static final Object lock = new Object();
	
	/**
	 * 프로젝트 리스트 조회
	 * SP: COVI_FLOW_SI..usp_select_projectname_gw
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getProjectList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getProjectList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		String appr_key = request.getParameter("appr_key");
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("appr_key", appr_key);
			
			resultArray = formCmmFunctionSvc.getProjectName(params);
			
			returnList.put("Table", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "legacy/getProjectList.do");
			
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getVacationData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVacationDataTest(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap formInstObj = new CoviMap();
		
		String userCode = request.getParameter("UR_CODE");
		String year = request.getParameter("year");
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("urCode", userCode);
			params.put("year", year);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("DomainID", SessionHelper.getSession("DN_ID"));
			
			formInstObj = formCmmFunctionSvc.getVacationData(params);
			String appVacProcessCheck = RedisDataUtil.getBaseConfig("AppVacProcessCheck");
			if("SUM".equals(appVacProcessCheck) || "REJECT".equals(appVacProcessCheck)) {
				params.put("UserCode", userCode);
				CoviMap vacInfo = formCmmFunctionSvc.getVacationProcessInfo(params);
				returnList.put("PROCDAYS", vacInfo.get("days"));
			}
			
			returnList.put("Table", formInstObj.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	/**
	 * 휴가신청 진행중인 건
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getVacationProcessInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVacationProcessInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObject = new CoviMap();
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("year", paramMap.get("year"));
			params.put("UserCode", paramMap.get("UR_CODE"));
			
			resultObject = formCmmFunctionSvc.getVacationProcessInfo(params);
			
			returnList.put("vacInfo", resultObject);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * 그룹사 직인 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getGovUsingStamp.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGovUsingStamp(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap formInstObj = new CoviMap();
		
		String entCode = request.getParameter("entCode");
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("entCode", entCode);
			
			formInstObj = formCmmFunctionSvc.getGovUsingStamp(params);
			
			returnList.put("Table", formInstObj.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	
	/**
	 * 고객사 정보 조회
	 * SP: COVI_SMART..BDT_CUSTOM_select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getCustomerData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCustomerData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = new CoviList();
		
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try
		{
			conn = LegacyConnectionFactory.getDatabaseConnection();
			
			String insertStoreProc = "exec COVI_SMART..BDT_CUSTOM_select";
			
			//exec COVI_SMART..BDT_CUSTOM_select
			
			ps = conn.prepareStatement(insertStoreProc);
			ps.setEscapeProcessing(true);
			ps.setQueryTimeout(100);
			rs = ps.executeQuery();
			
			int no = 1;
			while(rs.next())
			{
				CoviMap row  = new CoviMap();
				ResultSetMetaData rmd = rs.getMetaData();
				
				for ( int i=1; i<=rmd.getColumnCount(); i++ )
				{
					row.put(rmd.getColumnName(i),rs.getString(rmd.getColumnName(i)));
				}
				row.put("nodeName",row.getString("CustomName"));
				row.put("no",no);
				row.put("url","#");
				no++;
				
				resultArray.add(row);
				
			}
			
			returnList.put("Table", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "exec dbo.BDT_CUSTOM_select");
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}finally{
			if (rs != null) {
				try {
					rs.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if (ps != null) {
				try {
					ps.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return returnList;
	}
	
	
	
	/**
	 * FormInstance 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getFormInstData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormInstData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap formInstObj = new CoviMap();
		
		String formInstID = request.getParameter("FormInstID");
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("FormInstID", formInstID);
			
			formInstObj = formCmmFunctionSvc.getFormInstData(params);
			
			returnList.put("Table", formInstObj.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	
	/**
	 * 
	 * OS 정보 조회 
	 * SP: COVI_FLOW_SI..USP_FORM_BASE_OS_S
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getFormBaseOS.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormBaseOS(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		try
		{
			String codeGroup = request.getParameter("CodeGroup");
			
			CoviMap params = new CoviMap();
			params.put("CodeGroup", codeGroup);
			
			resultArray = formCmmFunctionSvc.getFormBaseOS(params);
			
			returnList.put("Table", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	

	@RequestMapping(value = "goCustomName.do")
	public ModelAndView goCustomName(Locale locale, Model model) {
		return new ModelAndView("forms/CustomName");
	}
	
	/**
	 * 휴가신청 시 해당 날짜에 이미 휴가가 신청된 경우
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getVacationInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVacationInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		try
		{
			CoviList vacationInfo = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("vacationInfo")));
			
			CoviMap params = new CoviMap();
			params.put("vacationInfo", vacationInfo);
			params.put("chkType", paramMap.get("chkType"));
			
			resultArray = formCmmFunctionSvc.getVacationInfo(params);
			
			returnList.put("dupVac", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * activiti-rest (엔진) 에서 호출하는 Controller. 
	 * 여기서 다시 Legacy 시스템등 호출한다.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/executeLegacy.do", method=RequestMethod.POST)
	public @ResponseBody String executeLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Throwable
	{
		String sReturn = "";
		String dataInfo = null;
		String formInstID = "";
		
		try{
			//1. parameter 처리
			/*
			 *{"formPrefix":"","bodyContext":"","formInfoExt":"","approvalContext":"","preApproveprocsss":"","apvResult":"","docNumber":"","approverId":"","formInstID":"","apvMode":"","processID":"","formHelperContext":"","formNoticeContext":""}
			 */
			
			/*
			 * {
				  "LegacyInfo": 
				   {
					  "formPrefix": "",
					  "bodyContext": "",
					  "formInfoExt": "",
					  "approvalContext": "",
					  "preApproveprocsss": "",
					  "apvResult": "",
					  "docNumber": "",
					  "approverId": "",
					  "comment":"",
					  "formInstID": "",
					  "apvMode": "",
					  "processID":"",
					  "formHelperContext":"",
					  "formNoticeContext":""
				    }
				}
			 * 
			 */
			String domainID;
			String formPrefix;
			String bodyContext;
			String formInfoExt;
			String approvalContext;
			String preApproveprocsss;
			String apvResult;
			String docNumber;
			String approverId;
			//String comment;  //결재 연동 오류로 임시 주석처리
			String apvMode;
			String processID;
			String formHelperContext;
			String formNoticeContext;
			String formIsUseMultiEdit="";
			CoviMap legacyInfo = new CoviMap();
			CoviMap formInstance = new CoviMap();
			
			if(request.getParameter("LegacyInfo") != null){
				dataInfo = new String(Base64.decodeBase64(request.getParameter("LegacyInfo")), StandardCharsets.UTF_8);
				
			} else {
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("LegacyInfo");
			}
			
			try {
				legacyInfo = CoviMap.fromObject(dataInfo);
			} catch (JSONException e) {
				legacyInfo = (CoviMap)CoviList.fromObject(dataInfo).get(0);
			}
			
			formPrefix = new String(Base64.decodeBase64(legacyInfo.getString("formPrefix")), StandardCharsets.UTF_8);
			//bodyContext = new String(Base64.decodeBase64(legacyInfo.getString("bodyContext")));
			formInfoExt = new String(Base64.decodeBase64(legacyInfo.getString("formInfoExt")), StandardCharsets.UTF_8);
			approvalContext = new String(Base64.decodeBase64(legacyInfo.getString("approvalContext")), StandardCharsets.UTF_8);
			preApproveprocsss = new String(Base64.decodeBase64(legacyInfo.getString("preApproveprocsss")), StandardCharsets.UTF_8);
			apvResult = new String(Base64.decodeBase64(legacyInfo.getString("apvResult")), StandardCharsets.UTF_8);
			docNumber = new String(Base64.decodeBase64(legacyInfo.getString("docNumber")), StandardCharsets.UTF_8);
			approverId = new String(Base64.decodeBase64(legacyInfo.getString("approverId")), StandardCharsets.UTF_8);
			//comment = new String(Base64.decodeBase64(legacyInfo.getString("comment")));
			formInstID = new String(Base64.decodeBase64(legacyInfo.getString("formInstID")), StandardCharsets.UTF_8);
			apvMode = new String(Base64.decodeBase64(legacyInfo.getString("apvMode")), StandardCharsets.UTF_8);
			processID = legacyInfo.has("processID")?new String(Base64.decodeBase64(legacyInfo.getString("processID")), StandardCharsets.UTF_8):"";
			formHelperContext = legacyInfo.has("formHelperContext")?new String(Base64.decodeBase64(legacyInfo.getString("formHelperContext")), StandardCharsets.UTF_8):"";
			formNoticeContext = legacyInfo.has("formNoticeContext")?new String(Base64.decodeBase64(legacyInfo.getString("formNoticeContext")), StandardCharsets.UTF_8):"";
			
	        CoviMap formInfoExtObj = CoviMap.fromObject(formInfoExt);
	        if (formInfoExtObj.has("IsUseMultiEdit")) {
	        	formIsUseMultiEdit = formInfoExtObj.getString("IsUseMultiEdit");
	        }
			
			// BodyContext DB에서 다시 조회
			CoviMap bCParams = new CoviMap();
			
			bCParams.put("FormInstID", formInstID);
			formInstance = formCmmFunctionSvc.getFormInstAll(bCParams);
			//bodyContext = formCmmFunctionSvc.getBodyContextData(bCParams);
			
			int chkSleepLimit = 0;
			String strSleepLimit = RedisDataUtil.getBaseConfig("ApprovalLegacySleepLimit");
			int intSleepLimit = (strSleepLimit != null && !strSleepLimit.equals("")) ? Integer.parseInt(strSleepLimit) : 120;
			while(formInstance.isEmpty() && chkSleepLimit < intSleepLimit){ // bodyContext == null
				int approvalLegacySleepTime = Integer.parseInt(RedisDataUtil.getBaseConfig("ApprovalLegacySleepTime"));
				Thread.sleep(approvalLegacySleepTime);
				
				formInstance = formCmmFunctionSvc.getFormInstAll(bCParams);
				//bodyContext = formCmmFunctionSvc.getBodyContextData(bCParams);
				chkSleepLimit++;
			}
			if(formInstance.isEmpty()) { // bodyContext == null
				throw new Exception("Bodycontext not found");
			}
				
			// bodycontext 는 base64 decode 후 별도로 관리
			bodyContext = new String(Base64.decodeBase64(formInstance.optString("BODYCONTEXT")), StandardCharsets.UTF_8);
			CoviMap bodyContextObj = CoviMap.fromObject(bodyContext);
			formInstance.remove("BODYCONTEXT");
			formInstance.remove("BODYCONTEXTORG");
			
			// bodydata(subtable) 조회
			bCParams.put("FormID",formInstance.optString("FORMID"));
			CoviMap bodyData = legacyCmmnSvc.getBodyData(bCParams);
			
			// attachfileinfo base64 descode
			String attachFileInfo = formInstance.optString("ATTACHFILEINFO");
			if(!attachFileInfo.isEmpty()) {
				attachFileInfo = new String(Base64.decodeBase64(formInstance.optString("ATTACHFILEINFO")), StandardCharsets.UTF_8);
				formInstance.setConvertJSONObject(false);
				formInstance.put("ATTACHFILEINFO",attachFileInfo); // CoviMap.fromObject(attachFileInfo)
				formInstance.setConvertJSONObject(true);
			}
			
			// 도메인 조회
			domainID = formCmmFunctionSvc.getDomainID(bCParams);
			
			// 각 프로시저 매개변수
			CoviMap spParams = new CoviMap(); 

			spParams.put("formPrefix",formPrefix);
			spParams.put("bodyContext",bodyContext);
			spParams.put("formInfoExt",formInfoExt);
			spParams.put("approvalContext",approvalContext);
			spParams.put("preApproveprocsss",preApproveprocsss);
			spParams.put("apvResult",apvResult);
			spParams.put("docNumber",docNumber);
			spParams.put("approverId",approverId);
			//spParams.put("comment",comment);
			spParams.put("formInstID",formInstID);
			spParams.put("apvMode",apvMode);
			spParams.put("processID",processID);
			spParams.put("formHelperContext",formHelperContext);
			spParams.put("formNoticeContext",formNoticeContext);
			spParams.put("domainID",domainID);
			spParams.put("formInstance",formInstance);
			spParams.put("bodyData",bodyData);
			spParams.put("subject",formInstance.optString("SUBJECT"));

			// 연동누락 확인용 로그
			//legacyCmmnSvc.insertLegacy("LEGACY", "start_executeLegacy", dataInfo, formInstID, null);
			
			switch(spParams.getString("formPrefix")){
			 case "WF_FORM_DRAFT_License": // 라이선스 인증서 발급 품의
				 formCmmFunctionSvc.execWF_FORM_DRAFT_License(spParams);
				 break;
             case "WF_FORM_EACCOUNT_LEGACY":				// E-Accounting 경비신청서
             case "WF_FORM_EACCOUNT_LEGACY_CO":				// E-Accounting 지출결의서(통합비용신청)
             case "WF_FORM_EACCOUNT_LEGACY_NORMAL":
             case "WF_FORM_EACCOUNT_LEGACY_PROJECT":
             case "WF_FORM_EACCOUNT_LEGACY_SELFDEVELOP":
             case "WF_FORM_EACCOUNT_LEGACY_INVEST":
             case "WF_FORM_EACCOUNT_LEGACY_ENTERTAIN":
             case "WF_FORM_EACCOUNT_LEGACY_BIZTRIP":
             case "WF_FORM_EACCOUNT_LEGACY_OVERSEA":
             case "WF_FORM_EACCOUNT_LEGACY_VENDOR":
             case "WF_FORM_EACCOUNT_LEGACY_OUTSOURCING":
             case "WF_FORM_EACCOUNT_LEGACY_LICENSE":
            	 formCmmFunctionSvc.setApvStatus(spParams);
                 break;
             case "WF_FORM_EACCOUNT_CAPITAL_RES":	// E-Accounting 자금지출결의서
            	 formCmmFunctionSvc.setApvStatus(spParams);
            	 if(apvMode.equals("COMPLETE"))
            		 formCmmFunctionSvc.saveCapitalResolution(spParams);
                 break;
             case "WF_FORM_EACCOUNT_CAPITAL_REP":		// E-Accounting 자금지출보고서
            	 formCmmFunctionSvc.createCapitalReportInfo(spParams); 
                 break;
			 case "WF_FORM_EACCOUNT_REQ_BIZTRIP": // 출장신청서
				 formCmmFunctionSvc.saveBizTripRequestInfo(spParams);
				 break;
             case "WF_EXTERNAL_ACCESS_REQ": // 사외접속 신청서(본사용)
            	 formCmmFunctionSvc.execWF_EXTERNAL_ACCESS_REQ(spParams);
            	 break;
             // 운영 - 사업관리 시스템 양식 상태값 연동
             case "WF_FORM_BIZMNT_CONTRACT":
             case "WF_FORM_BIZMNT_ORDERED":
             case "WF_FORM_BIZMNT_EXECPLAN":
             case "WF_FORM_BIZMNT_BUYORDERS":
             case "WF_FORM_BIZMNT_BUYOUTSOURCING":
             case "WF_FORM_BIZMNT_PROJDAILYPAY":
             case "WF_FORM_BIZMNT_COMPLETION":
            	 formCmmFunctionSvc.execBizUpdateStatus(spParams);
            	 break;
             case "WF_FORM_CRMMNT_ESTIMATE":
            	 formCmmFunctionSvc.execCrmUpdateStatus(spParams);
            	 break;
			 case "WF_FORM_BIZMNT_PROJECTCODE": // 프로젝트 코드신청서
				 CoviMap result = null;
				 // 동일데이터 핸들링 포함되어 Deadlock 발생 방지.
				 synchronized (lock) {
					 result = formCmmFunctionSvc.execWF_FORM_BIZMNT_PROJECTCODE(spParams);
				 }
				 if(result.containsKey("jobNo")) spParams.put("jobNo", result.getString("jobNo"));
				 if(result.containsKey("projectCd")) spParams.put("projectCd", result.getString("projectCd"));
				 if(result.containsKey("projectNm")) spParams.put("projectNm", result.getString("projectNm"));
				 
				 formCmmFunctionSvc.execEAccountInsertProjectCode(spParams);
				 
				 formCmmFunctionSvc.execBizUpdateStatus(spParams);
				 break;
             case "WF_FORM_CALL": //소명신청서
             case "WF_FORM_HOLIDAY_WORK": //휴일근무신청서
			 case "HOLIDAY_REPLACEMENT_WORK": //휴일대체근무신청서
             case "WF_FORM_OVERTIME_WORK": //연장근무신청서
			 case "WF_FORM_WORK_SCHEDULE": // 근무일정 신청서
			 case "WF_OTHER_WORK": // 기타 근무 신청서			 
			 case "WF_FORM_VACATION_REQUEST2": // 휴가신청
			 case "WF_FORM_VACATIONCANCEL": // 휴가 취소 신청서
//				 formCmmFunctionSvc.execWF_FORM_VACATION_REQUEST(spParams);
 //           	 formCmmFunctionSvc.execWF_FORM_VACATION_CANCEL(spParams);
				 formCmmFunctionSvc.execAttendRequest(spParams);
//            	 formCmmFunctionSvc.execCall(spParams);
//            	 formCmmFunctionSvc.execAttendance(spParams);
            	 break;
			 case "HR_CERT_REQUEST": // 인사카드관리 - 제증명신청서
			 case "HR_EDU_REQUEST": // 인사카드관리 - 교육신청 
			 case "HR_EDU_REPORT": // 인사카드관리 - 교육완료보고서
			 case "HR_EDU_REQUEST_NEW": // 인사카드관리 - 교육신청 NEW
			 case "HR_EDU_REPORT_NEW": // 인사카드관리 - 교육완료보고서 NEW
				 formCmmFunctionSvc.execHrManage(dataInfo, bodyContext);
				 break;	 
             default:

            	 //문서24 개인회신 연동
            	 if( apvMode.equals("DRAFT") && bodyContextObj.optString("govDocReply", "N").equals("Y") ) {
            		 spParams.put("govFormInstID", bodyContextObj.get("govFormInstID"));
            		 approvalGovDocSvc.updateReplyStatusInfo(spParams);
            	 }
            	 if (formInfoExtObj.has("scPubOpenDoc")) {
            		 String scPubOpenDoc = formInfoExtObj.getString("scPubOpenDoc");
            		 if("true".equalsIgnoreCase(scPubOpenDoc)) {
            			 // 원문공개 연계용 데이터 입력
            			 openDocSvc.insertOpenDocInfo(spParams);
            		 }
            	 }
            	 //Legacy 프로젝트 연동
            	 String isUseOtherLegacy = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.isUse");
            	 if("Y".equalsIgnoreCase(isUseOtherLegacy)) {
            		 CoviMap ctxJsonObj = CoviMap.fromObject(formInfoExt);
            		 String DN_Code = "";
            		 if(ctxJsonObj.has("entcode")) {
            			 DN_Code = (String)ctxJsonObj.get("entcode");
            		 }
            		 formCmmFunctionSvc.callOtherService(dataInfo, bodyContext, DN_Code);
            	 }
            	 
            	 executeCommonLegacy(spParams);
            	 break;
			}
			
		 // 기록물철 이관
       	 if (formInfoExtObj.has("scRecordDocOpen")) {
    		 String scRecordDoc = formInfoExtObj.getString("scRecordDocOpen");
    		 if("true".equalsIgnoreCase(scRecordDoc)) {
    			 // 기록물철 다안
    			 if (formIsUseMultiEdit.equals("Y")) {
            		 approvalGovDocSvc.executeRecordDocInsert(spParams);
            	 // 기록물철 단건
            	 }else {
        			 approvalGovDocSvc.executeRecordDocSingleInsert(spParams);
            	 }
    		 }
    	 }

            //휴가신청서, 휴가 취소신청서 연동
            /*if (spParams.optString("formPrefix").equals(VacRe) && spParams.optString("apvMode").equals("COMPLETE")) //휴가신청서
            {
            	formCmmFunctionSvc.execWF_FORM_VACATION_REQUEST(spParams);
            }
            else if (spParams.optString("formPrefix").equals(VacCan) && spParams.optString("apvMode").equals("COMPLETE")) //휴가취소신청서
            {
            	formCmmFunctionSvc.execWF_FORM_VACATIONCANCEL(spParams);	
            }*/
            
            legacyCmmnSvc.insertLegacy("LEGACY", "complete", dataInfo, null);
            sReturn = "OK";
            
            // 오류목록에서 재처리한 경우 재처리대상(원본) 레코드에 Flag 처리한다.
 			if(!StringUtils.isEmpty(request.getParameter("LegacyID"))) {
 				String legacyID = request.getParameter("LegacyID");
 				legacyCmmnSvc.updateLegacyRetryFlag(legacyID);
 			}
 			
            // 연동 상세 로그(throw시 롤백되지 않음)
            /*
            CoviMap sampleMap = new CoviMap();
            sampleMap.put("FormInstID","9999");
			sampleMap.put("ProcessID",8888);
			sampleMap.put("UserCode","superadmin");
			sampleMap.put("ApvMode","DRAFT");
			sampleMap.put("LegacySystem","ERP");
			sampleMap.put("State","E");
			sampleMap.put("InputData","입력data test");
			sampleMap.put("OutputData","리턴data test");
			sampleMap.put("Message","S 성공 입니다 test");
			sampleMap.put("Reserved1","예비 필드 1 test");
			sampleMap.put("Reserved3","예비 필드 3 test");
			
            LoggerHelper.legacyDetailLogger(sampleMap);
            */
		}catch(NullPointerException npE){
			LOGGER.error("", npE);
			String isAsync = PropertiesUtil.getFileProperties("coviflow_config.properties").getProperty("IsAsync", "true");
			if("true".equals(isAsync)) {
				legacyCmmnSvc.insertLegacy("LEGACY", "error", dataInfo, npE);
			}
			sReturn = "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030")+ " " + Arrays.toString(npE.getStackTrace());
		}catch(Exception e){
			LOGGER.error("", e);
			String isAsync = PropertiesUtil.getFileProperties("coviflow_config.properties").getProperty("IsAsync", "true");
			if("true".equals(isAsync)) {
				legacyCmmnSvc.insertLegacy("LEGACY", "error", dataInfo, e);
			}
			sReturn = "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030")+ " " + Arrays.toString(e.getStackTrace());
			
			if("false".equals(isAsync)) {
				// foreground 처리시에는 오류처리 ( 기간계 -> executeLegacy -> Engine -> Approval -> 사용자 ) 될 수있도록 Exception 처리함.
				// 반드시 기간계 호출응답에 따라 예외처리 하기 바랍니다.
				LOGGER.error("[ERROR] Error in while process Legacy interface.");
				
				// Error 로 throw 하는 이유, Spring Exception Resolver 가 Throwable 하위 모든 Exception 처리를 egovError.jsp 응답을 하기때문에 호출한 쪽에서는 200 코드를 받게 되므로 시스템 오류 분석이 안됨.
				// 500 응답을 받을수 있도록 함. 
				// Transaction rollbak 을 해야 하므로 return 을 하면 안됨. 
			}
			// spring-webmvc-4.3.22 으로 올라가면서 Error 도 Resolver 가 가로챔. 
			sReturn = "[" + DicHelper.getDic("lbl_apv_lagacySyncerror") + "]" + sReturn;
			response.setHeader("LEGACY_ERRMSG", Base64.encodeBase64String(sReturn.getBytes("UTF-8")));
			throw new Throwable("[ERROR]"+sReturn); 
		}
	
		/*
		if(!"OK".equals(sReturn)) {
			String isAsync = "true";
			isAsync = PropertiesUtil.getFileProperties("coviflow_config.properties").getProperty("IsAsync", "true");
			if("false".equals(isAsync)) {
				// foreground 처리시에는 오류처리 ( 기간계 -> executeLegacy -> Engine -> Approval -> 사용자 ) 될 수있도록 Exception 처리함.
				// 반드시 기간계 호출응답에 따라 예외처리 하기 바랍니다.
				LOGGER.error("[ERROR] Error in while process Legacy interface.");
				
				// Error 로 throw 하는 이유, Spring Exception Resolver 가 Throwable 하위 모든 Exception 처리를 egovError.jsp 응답을 하기때문에 호출한 쪽에서는 200 코드를 받게 되므로 시스템 오류 분석이 안됨.
				// 500 응답을 받을수 있도록 함. 
				// Transaction rollbak 을 해야 하므로 return 을 하면 안됨. 
				throw new Error("[ERROR]"+sReturn); 
			}
		}
		*/
		
		return sReturn; 
	}
	
	//근태관리 휴무일 체크
	@RequestMapping(value = "legacy/attendanceHolidayCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceHolidayCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		try
		{
			CoviList workInfo = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("workInfo")));
			
			CoviMap params = new CoviMap();
			params.put("workInfo", workInfo);
			
			resultArray = formCmmFunctionSvc.attendanceHolidayCheck(params);
			
			returnList.put("notHoliday", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}
	
	//근태관리 주 52시간 체크
	@RequestMapping(value = "legacy/attendanceWorkTimeCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceWorkTimeCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		try
		{
			CoviList workInfo = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("workInfo")));
			
			CoviMap params = new CoviMap();
			params.put("workInfo", workInfo);
			params.put("orgProcessId", request.getParameter("orgProcessId"));
			
			resultArray = formCmmFunctionSvc.attendanceWorkTimeCheck(params);
			
			returnList.put("workTimeList", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}	
	
	
	//휴일근무신청서, 연장근무신청서 - 주 52시간 체크
	@RequestMapping(value = "legacy/attendanceWorkTimeCheckOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceWorkTimeCheckOne(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
				
		try
		{
			CoviMap params = new CoviMap();
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("TargetDate", request.getParameter("TargetDate"));
			params.put("StartTime", request.getParameter("StartTime"));
			params.put("EndTime", request.getParameter("EndTime"));
			params.put("orgProcessId", request.getParameter("orgProcessId"));

			CoviMap resultObj = formCmmFunctionSvc.attendanceWorkTimeCheckOne(params);
			
			returnList.put("list", resultObj);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}
	
	//휴일근무신청서 - 휴일 일자 체크
	@RequestMapping(value = "legacy/attendanceHolidayCheckOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceHolidayCheckOne(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String isHoliday = "";
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("TargetDate", request.getParameter("TargetDate"));
			
			isHoliday = formCmmFunctionSvc.attendanceHolidayCheckOne(params);
			
			returnList.put("isHoliday", isHoliday);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}
	
	
	//소명신청서 - 변경 전 날짜 정보
	@RequestMapping(value = "legacy/attendanceCommuteTime.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceCommuteTime(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String commuteTime ="";
		
		try{
			CoviMap params = new CoviMap();
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("TargetDate", request.getParameter("TargetDate"));
			params.put("Division", request.getParameter("Division"));
			
			commuteTime = formCmmFunctionSvc.attendanceCommuteTime(params);
			
			returnList.put("commuteTime", commuteTime);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		return returnList;
	
	}
	

	
	/**
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getBaseCodeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCodeList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap returnObj = new CoviMap();
		String codeGroup = request.getParameter("CodeGroup");
		String companyCode = StringUtil.replaceNull(request.getParameter("CompanyCode"));
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("CodeGroup", codeGroup);
			params.put("CompanyCode", companyCode);
			
			returnObj = formCmmFunctionSvc.getBaseCodeList(params);
			
			returnList.put("list", returnObj.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}

	//휴일대체근무 - 지정한 날짜에 근무가 설정되어 있는지 체크
	@RequestMapping(value = "legacy/attendDayJobCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendDayJobCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int checkJob = 0;

		try
		{
			CoviMap params = new CoviMap();
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("TargetDate", request.getParameter("TargetDate"));

			checkJob = formCmmFunctionSvc.attendDayJobCheck(params);

			returnList.put("checkJob", checkJob);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);

		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}

		return returnList;
	}

	//연장/휴일 근무 실 근무시간 정보
	@RequestMapping(value = "legacy/attendanceRealWorkInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap attendanceRealWorkInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList resultArray = new CoviList();

		try
		{
			CoviList paramsArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("params")));

			CoviMap params = new CoviMap();
			params.put("paramsArr", paramsArr);

			resultArray = formCmmFunctionSvc.attendanceRealWorkInfo(params);

			returnList.put("realWorkTimeList", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}catch(NullPointerException npE){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}

		return returnList;
	}
	
	// LegacyInterfaceSvc 구현체들이 Autowired 된다.
	@Autowired
	private Map<String, LegacyInterfaceSvc> legacyInterfaceMap;
	
	// 결재 연동(자동화)
	private void executeCommonLegacy(CoviMap params) throws Exception {
		CoviMap qParam = new CoviMap();
		qParam.put("IsUse", "Y");
		qParam.put("SchemaID", params.getJSONObject("formInstance").getString("SCHEMAID"));
		qParam.put("ApvMode", params.getString("apvMode"));
		
		// 1. form 정보로 연동옵션 조회 상태(spParams.getString("apvMode"))에 따른 옵션 조회
		CoviList legacyInfoList = legacyCmmnSvc.getLegacyInterfaceInfo(qParam); // SchemeID, ApvMode (Revision 에 따른 설정은 아님)
		for (int i = 0; legacyInfoList != null && i < legacyInfoList.size(); i++) {
			CoviMap legacyInfo = legacyInfoList.getJSONObject(i);
			if(legacyInfo == null) {
				continue;
			}
			
			String extInfoStr = legacyInfo.getString("ExtInfo");
			CoviMap extInfo = new CoviMap();
			if(!StringUtil.isEmpty(extInfoStr)) {
				// Parse JSON Options.
				extInfo = new CoviMap(extInfoStr);
				legacyInfo.putAll(extInfo);
			}
			// 불필요 정보 삭제 (재처리시 혼돈우려)
			legacyInfo.remove("ExtInfo");
			legacyInfo.remove("SchemaID");
			legacyInfo.remove("ApvMode");
			legacyInfo.remove("Seq");
			
			CoviMap spParams = new CoviMap(params);
			spParams.put("paramDataType","A"); // 데이터타입 - A(전체데이터 spParams) , L(일부 추출된데이터 legacyParams)
			
			callCommonLegacy(legacyInfo, spParams, "CALL");
		}
	}
	
	// 결재 연동 재처리(자동화)
	@RequestMapping(value = "legacy/reExecuteCommonLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap reExecuteCommonLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try
		{
			String legacyInfo = StringUtil.replaceNull(request.getParameter("LegacyInfo"));
			String parameters = StringUtil.replaceNull(request.getParameter("Parameters"));
			String legacyHistoryID = StringUtil.replaceNull(request.getParameter("LegacyHistoryID"));
			
			if(StringUtils.isEmpty(legacyHistoryID)) {
				throw new Exception("Not found legacy historyID.");
			}
			
			String decLegacyInfo = new String(Base64.decodeBase64(legacyInfo), StandardCharsets.UTF_8);
			String decParameters = new String(Base64.decodeBase64(parameters), StandardCharsets.UTF_8);
			CoviMap mapLegacyInfo = new CoviMap(decLegacyInfo);
			CoviMap mapParameters = new CoviMap(decParameters);
			
			// 연동호출
			callCommonLegacy(mapLegacyInfo, mapParameters, "RECALL");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_alert_006"));  // 성공적으로 처리 되었습니다.
			
		}catch(NullPointerException npE){
			//returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", npE.getMessage());
		}catch(Exception e){
			//returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}

		return returnList;
	}
	
	// 결재 연동 테스트(자동화)
	@RequestMapping(value = "legacy/checkExecuteCommonLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkExecuteCommonLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try
		{
			String legacyInfo = StringUtil.replaceNull(request.getParameter("LegacyInfo"));
			String parameters = StringUtil.replaceNull(request.getParameter("Parameters"));
			
			String decLegacyInfo = new String(Base64.decodeBase64(legacyInfo), StandardCharsets.UTF_8);
			String decParameters = new String(Base64.decodeBase64(parameters), StandardCharsets.UTF_8);
			CoviMap mapLegacyInfo = new CoviMap(decLegacyInfo);
			CoviMap mapParameters = new CoviMap(decParameters);
			mapParameters.put("paramDataType","L");
			
			// 연동호출
			returnList = callCommonLegacy(mapLegacyInfo, mapParameters, "CHECK");
			
			returnList.put("legacyCheckStatus", Return.SUCCESS);
			returnList.put("legacyCheckMessage", DicHelper.getDic("msg_apv_alert_006"));  // 성공적으로 처리 되었습니다.
			
		}catch(NullPointerException npE){
			//returnList.put("error", Return.FAIL);
			returnList.put("legacyCheckStatus", Return.FAIL);
			returnList.put("legacyCheckMessage", npE.getMessage());
		}catch(Exception e){
			//returnList.put("error", Return.FAIL);
			returnList.put("legacyCheckStatus", Return.FAIL);
			returnList.put("legacyCheckMessage", e.getMessage());
		}

		return returnList;
	}
	
	// 
	/** 연동 실행
	 * @param legacyInfo : 연동시스템 정보
	 * @param params : 연동 데이터(파라미터)
	 * @param callType : 호츌타입(CALL 일반 , RECALL 재처리 , CHECK 설정창에서 테스트)
	 * @throws Exception
	 */
	private CoviMap callCommonLegacy(CoviMap legacyInfo, CoviMap spParams, String callType) throws Exception {
		LegacyInterfaceSvc interfaceService = null;
		CoviMap resultForCheck = new CoviMap();
		try {
			String ifType = legacyInfo.optString("IfType");
			String className = "";
			switch (ifType) {
				case "JAVA":
					// AOP 에 의한 DatasourceTransactionManager 설정이 되지 않도록 명칭을 *Impl.java 로 사용하지 않음. 
					className = LegacyInterfaceJAVAMgr.class.getSimpleName();
					break;
				case "SOAP":
					className = LegacyInterfaceSOAPImpl.class.getSimpleName();
					break;
				case "HTTP":
					className = LegacyInterfaceHTTPImpl.class.getSimpleName();
					break;
				case "SQL":
				case "SP":
					className = LegacyInterfaceSQLImpl.class.getSimpleName();
					break;
				default:
					throw new Exception("IfType is not parameterized. ["+ ifType +"](JAVA,SOAP,HTTP,SQL,SP...)");
			}
			// Uncapitalize. Invoke Spring Service
			String simpleName = Character.toLowerCase(className.charAt(0)) + className.substring(1);
			interfaceService = legacyInterfaceMap.get( simpleName );
			
			interfaceService.call(legacyInfo, spParams, callType);
			
			// Insert Log
			resultForCheck = legacyCmmnSvc.insertInterfaceHistory(interfaceService.getLogParam(), null, callType);
		} catch(NullPointerException e){
			// Insert Log (시스템오류 별도 기록 , 연동 실행 전 오류면 가지고있는 파라미터로 로그기록
			if(interfaceService != null) resultForCheck = legacyCmmnSvc.insertInterfaceHistory(interfaceService.getLogParam(), e, callType);
			else resultForCheck = legacyCmmnSvc.insertInterfaceHistory(legacyInfo, spParams, e, callType);
			
			if("Y".equalsIgnoreCase(legacyInfo.getString("ErrorOnFail")) || (callType != null && callType.equals("RECALL")) ) { // 오류처리 설정이 Y이거나, 연동재처리 일땐 throw 
				throw e;
			}else {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}catch(Exception e) {
			// Insert Log (시스템오류 별도 기록 , 연동 실행 전 오류면 가지고있는 파라미터로 로그기록
			if(interfaceService != null) resultForCheck = legacyCmmnSvc.insertInterfaceHistory(interfaceService.getLogParam(), e, callType);
			else resultForCheck = legacyCmmnSvc.insertInterfaceHistory(legacyInfo, spParams, e, callType);
			
			if("Y".equalsIgnoreCase(legacyInfo.getString("ErrorOnFail")) || (callType != null && callType.equals("RECALL")) ) { // 오류처리 설정이 Y이거나, 연동재처리 일땐 throw 
				throw e;
			}else {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}finally {
			if(interfaceService != null) {
				interfaceService.clear();// remove threadlocal variables.
			}
		}
		
		return resultForCheck;
	}
	
	
}
