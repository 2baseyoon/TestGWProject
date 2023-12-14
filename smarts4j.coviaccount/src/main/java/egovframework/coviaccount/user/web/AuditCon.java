package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.AuditSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : AuditCon.java
 * @Description : AuditCon 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class AuditCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());	
	
	@Autowired
	private AuditSvc auditSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getAuditList
	 * @Description : Audit 목록 조회
	 */
	@RequestMapping(value = "audit/getAuditList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAuditList(
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "companyCode", required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("companyCode",	companyCode);
			
			resultList = auditSvc.getAuditList(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : getAuditPopup
	 * @Description : Audit 팝업 호출
	 */
	@RequestMapping(value = "audit/getAuditPopup.do", method = RequestMethod.GET)
	public ModelAndView getAuditPopup(Locale locale, Model model) {
		String returnURL = "user/account/AuditPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * @Method Name : getAuditDetail
	 * @Description : Audit 상세 조회
	 */
	@RequestMapping(value = "audit/getAuditDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAuditDetail(
			@RequestParam(value = "auditID",	required = false, defaultValue="") String auditID) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("auditID",	auditID);
			resultList = auditSvc.getAuditDetail(params);
			resultList.put("result",	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : saveAuditInfo
	 * @Description : Audit 정보 저장
	 */
	@RequestMapping(value = "audit/saveAuditInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveAuditInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "auditID",			required = false,	defaultValue = "") String auditID,
			@RequestParam(value = "stdType",			required = false,	defaultValue = "") String stdType,
			@RequestParam(value = "stdValue",			required = false,	defaultValue = "") String stdValue,
			@RequestParam(value = "stdStartTime",		required = false,	defaultValue = "") String stdStartTime,
			@RequestParam(value = "stdEndTime",			required = false,	defaultValue = "") String stdEndTime,
			@RequestParam(value = "stdDescription",		required = false,	defaultValue = "") String stdDescription,
			@RequestParam(value = "applicationColor",	required = false,	defaultValue = "") String applicationColor,
			@RequestParam(value = "isUse",				required = false,	defaultValue = "") String isUse,
			@RequestParam(value = "ruleInfo",			required = false,	defaultValue = "") String ruleInfo,
			@RequestParam(value = "popupYN",			required = false,	defaultValue = "") String popupYN) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				params.put("auditID",			auditID);
				params.put("stdType",			ComUtils.RemoveScriptAndStyle(stdType));
				params.put("stdValue",			ComUtils.RemoveScriptAndStyle(stdValue));
				params.put("stdStartTime",		ComUtils.RemoveScriptAndStyle(stdStartTime));
				params.put("stdEndTime",		ComUtils.RemoveScriptAndStyle(stdEndTime));
				params.put("stdDescription",	ComUtils.RemoveScriptAndStyle(stdDescription));
				params.put("applicationColor",	applicationColor);
				params.put("isUse",				isUse);
				params.put("ruleInfo",			ruleInfo);
				params.put("popupYN",			popupYN);
				
				auditSvc.saveAuditInfo(params);
				
				rtValue.put("result", "ok");
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}
		return rtValue;
	}
	
	/**
	 * @Method Name : checkAuditRule
	 * @Description : 감사규칙 체크
	 */
	@RequestMapping(value = "audit/getAuditRuleInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap checkAuditRule(
			@RequestParam(value = "ruleCodes",	required = false, defaultValue="") String ruleCodes) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if(ruleCodes != null && !ruleCodes.equals("")) params.put("ruleCodes", ruleCodes.split(","));
			
			resultList = auditSvc.getAuditRuleInfo(params);
			resultList.put("result",	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
