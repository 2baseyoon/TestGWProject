package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.Locale;
import java.util.Map;

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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.FormManageSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : formManageCon.java
 * @Description : 비용신청서관리 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class FormManageCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private FormManageSvc formManageSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getFormManagelist
	 * @Description : 비용신청서관리 목록 조회
	 */
	@RequestMapping(value = "formManage/getFormManagelist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFormManagelist(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "expAppType",		required = false, defaultValue="")	String expAppType,
			@RequestParam(value = "menuType",		required = false, defaultValue="")	String menuType,
			@RequestParam(value = "isUse",			required = false, defaultValue="")	String isUse) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";
			
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("searchType",		searchType);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("companyCode",		companyCode);
			params.put("expAppType",		expAppType);
			params.put("menuType",			menuType);
			params.put("isUse",				isUse);
			
			resultList = formManageSvc.getFormManagelist(params);
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
	 * @Method Name : getFormManagePopup
	 * @Description : 비용신청서관리 팝업 호출
	 */
	@RequestMapping(value = "formManage/getFormManagePopup.do", method = RequestMethod.GET)
	public ModelAndView getFormManagePopup(Locale locale, Model model) {
		String returnURL = "user/account/FormManagePopup";
		ModelAndView mav = new ModelAndView(returnURL);				
		return mav;
	}
	
	/**
	 * @Method Name : getFormManageDetail
	 * @Description : 비용신청서관리 상세 조회
	 */
	@RequestMapping(value = "formManage/getFormManageDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFormManageDetail(
			@RequestParam(value = "expenceFormID",	required = false, defaultValue="") String expenceFormID,
			@RequestParam(value = "formCode",	required = false, defaultValue="") String FormCode
			) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("expenceFormID",	expenceFormID);
			params.put("FormCode",	FormCode);
			resultList = formManageSvc.getFormManageDetail(params);
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
	 * @Method Name : getInfoListData
	 * @Description : 비용신청서 정보 목록 조회
	 */
	@RequestMapping(value = "formManage/getInfoListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInfoListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap params = new CoviMap();
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("TargetType", request.getParameter("TargetType"));
			params.put("TargetArea", request.getParameter("TargetArea"));
			if(StringUtil.replaceNull(request.getParameter("TargetType")).equals("BaseCode")) {
				params.put("CodeGroup", request.getParameter("CodeGroup"));
			}
			
			resultList = formManageSvc.getInfoListData(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
		
	}
	
	/**
	 * @Method Name : saveFormManageInfo
	 * @Description : 비용신청서관리 저장
	 */
	@RequestMapping(value = "formManage/saveFormManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveFormManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "expenceFormID",		required = false,	defaultValue = "") String  expenceFormID,
			@RequestParam(value = "companyCode",		required = false,	defaultValue = "") String  companyCode,
			@RequestParam(value = "formCode",			required = false,	defaultValue = "") String  formCode,
			@RequestParam(value = "formName",			required = false,	defaultValue = "") String  formName,
			@RequestParam(value = "sortKey",			required = false,	defaultValue = "") String  sortKey,
			@RequestParam(value = "expAppType",			required = false,	defaultValue = "") String  expAppType,
			@RequestParam(value = "menuType",			required = false,	defaultValue = "") String  menuType,
			@RequestParam(value = "isUse",				required = false,	defaultValue = "") String  isUse,
			@RequestParam(value = "approvalFormInfo",	required = false,	defaultValue = "") String  approvalFormInfo,
			@RequestParam(value = "accountChargeInfo",	required = false,	defaultValue = "") String  accountChargeInfo,
			@RequestParam(value = "reservedStr1",		required = false,	defaultValue = "") String  reservedStr1,
			@RequestParam(value = "accountInfo",		required = false,	defaultValue = "") String  accountInfo,
			@RequestParam(value = "standardBriefInfo",	required = false,	defaultValue = "") String  standardBriefInfo,
			@RequestParam(value = "ruleInfo",			required = false,	defaultValue = "") String  ruleInfo,
			@RequestParam(value = "proofInfo",			required = false,	defaultValue = "") String  proofInfo,
			@RequestParam(value = "auditInfo",			required = false,	defaultValue = "") String  auditInfo,
			@RequestParam(value = "taxInfo",			required = false,	defaultValue = "") String  taxInfo,
			@RequestParam(value = "listPage",			required = false,	defaultValue = "N") String listPage,
			@RequestParam(value = "noteIsUse",			required = false,	defaultValue = "") String noteIsUse,
			@RequestParam(value = "reservedStr2",		required = false,	defaultValue = "") String reservedStr2
			) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				params.setConvertJSONObject(false); // covilist 객체가 아닌 string으로 추가되도록
				params.put("expenceFormID",		expenceFormID);
				params.put("companyCode",		companyCode);
				params.put("formCode",			ComUtils.RemoveScriptAndStyle(formCode));
				params.put("formName",			ComUtils.RemoveScriptAndStyle(formName));
				params.put("sortKey",			sortKey);
				params.put("menuType",			menuType);
				params.put("expAppType",		expAppType);
				params.put("isUse",				isUse);
				params.put("approvalFormInfo",	approvalFormInfo);
				params.put("accountChargeInfo",	accountChargeInfo);
				params.put("reservedStr1",		reservedStr1);
				params.put("accountInfo",		accountInfo);
				params.put("standardBriefInfo",	standardBriefInfo);
				params.put("ruleInfo",			ruleInfo);
				params.put("proofInfo",			proofInfo);
				params.put("auditInfo",			auditInfo);
				params.put("taxInfo",			taxInfo);
				params.put("listPage",			listPage);
				params.put("noteIsUse",			noteIsUse);
				params.put("reservedStr2",		reservedStr2);
				
				rtValue = formManageSvc.saveFormManageInfo(params);
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status",	Return.FAIL);
				rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}
		return rtValue;
	}
	
	/**
	 * @Method Name : deleteFormManageInfo
	 * @Description : 비용신청서관리 삭제
	 */
	@RequestMapping(value = "formManage/deleteFormManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteFormManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",	required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			params.put("deleteSeq",		deleteSeq);	
			formManageSvc.deleteFormManage(params);
			
			rtValue.put("result", "ok");
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : formManageExcelDownload
	 * @Description : 비용신청서관리 엑셀 다운로드
	 */
	@RequestMapping(value = "formManage/formManageExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView formManageExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "expAppType",		required = false, defaultValue="")	String expAppType,
			@RequestParam(value = "menuType",		required = false, defaultValue="")	String menuType,
			@RequestParam(value = "isUse",			required = false, defaultValue="")	String isUse,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("searchType",	commonCon.convertUTF8(searchType));
			params.put("searchStr",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("expAppType",	commonCon.convertUTF8(expAppType));
			params.put("menuType",		commonCon.convertUTF8(menuType));
			params.put("isUse",			commonCon.convertUTF8(isUse));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = formManageSvc.formManageExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",			accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : formManageExcelPopup
	 * @Description : 비용신청서관리 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "formManage/formManageExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView formManageExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/FormManageExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : formManageExcelPopup
	 * @Description : 비용신청서관리 엑셀 업로드
	 */
	@RequestMapping(value = "formManage/formManageExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap formManageExcelPopup(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			returnData = formManageSvc.formManageExcelUpload(params);
			
			returnData.put("status",	Return.SUCCESS);
			returnData.put("message",	"업로드 되었습니다");
		} catch (SQLException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	/**
	 * @Method Name : getFormMenuList
	 * @Description : 메뉴 영역에 뿌려질 신청서 목록 조회
	 */
	@RequestMapping(value = "formManage/getFormMenuList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormMenuList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap params = new CoviMap();			
			resultList = formManageSvc.getFormMenuList(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
		
	}
	
	/**
	 * @Method Name : getFormManageInfo
	 * @Description : 신청서 별 관리 정보 조회
	 */
	@RequestMapping(value = "formManage/getFormManageInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormManageInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap params = new CoviMap();		
			params.put("companyCode", request.getParameter("companyCode"));
			params.put("formCode", request.getParameter("formCode"));
			params.put("isSaaS", PropertiesUtil.getGlobalProperties().getProperty("isSaaS"));
			
			resultList = formManageSvc.getFormManageInfo(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
		
	}
	
	/**
	 * @Method Name : getFormLegacyManageInfo
	 * @Description : 조회용 신청서 별 관리 정보 조회
	 */
	@RequestMapping(value = "formManage/getFormLegacyManageInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormLegacyManageInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap params = new CoviMap();		
			params.put("companyCode", request.getParameter("companyCode"));
			params.put("formCode", request.getParameter("formCode"));
			params.put("ExpAppID", request.getParameter("ExpAppID"));
			
			resultList = formManageSvc.getFormLegacyManageInfo(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
		
	}
}
