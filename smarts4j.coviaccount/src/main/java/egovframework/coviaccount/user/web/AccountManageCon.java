package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.AccountManageSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : accountManageCon.java
 * @Description : 계정관리 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class AccountManageCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountManageSvc accountManageSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getAccountManagelist
	 * @Description : 계정관리 목록 조회
	 */
	@RequestMapping(value = "accountManage/getAccountManagelist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAccountManagelist(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "accountClass",	required = false, defaultValue="")	String accountClass,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "taxCode",		required = false, defaultValue="")	String taxCode,
			@RequestParam(value = "taxType",		required = false, defaultValue="")	String taxType,
			@RequestParam(value = "isUse",			required = false, defaultValue="")	String isUse,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "soapAccountCD",	required = false, defaultValue="")	String soapAccountCD,
			@RequestParam(value = "soapAccountCN",	required = false, defaultValue="")	String soapAccountCN) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";
			
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("searchProperty",	searchProperty);
			params.put("soapAccountCD",		soapAccountCD);
			params.put("soapAccountCN",		soapAccountCN);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("accountClass",		accountClass);
			params.put("searchType",		searchType);
			params.put("taxCode",			taxCode);
			params.put("taxType",			taxType);
			params.put("isUse",				isUse);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			resultList = accountManageSvc.getAccountmanagelist(params);
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
	 * @Method Name : getAccountManagePopup
	 * @Description : 계정관리 팝업 호출
	 */
	@RequestMapping(value = "accountManage/getAccountManagePopup.do", method = RequestMethod.GET)
	public ModelAndView getAccountManagePopup(Locale locale, Model model) {
		String returnURL = "user/account/AccountPopup";
		ModelAndView mav = new ModelAndView(returnURL);				
		return mav;
	}
	
	/**
	 * @Method Name : getAccountManageDetail
	 * @Description : 계정관리 상세 조회
	 */
	@RequestMapping(value = "accountManage/getAccountManageDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAccountManageDetail(
			@RequestParam(value = "accountID",	required = false, defaultValue="") String accountID
			) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("accountID",	accountID);
			resultList = accountManageSvc.getAccountManageDetail(params);
			resultList.put("result",	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : saveAccountManageInfo
	 * @Description : 계정관리 저장
	 */
	@RequestMapping(value = "accountManage/saveAccountManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveAccountManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "accountID",			required = false,	defaultValue = "") String  accountID,
			@RequestParam(value = "companyCode",		required = false,	defaultValue = "") String  companyCode,
			@RequestParam(value = "accountClass",		required = false,	defaultValue = "") String  accountClass,
			@RequestParam(value = "accountCode",		required = false,	defaultValue = "") String  accountCode,
			@RequestParam(value = "accountName",		required = false,	defaultValue = "") String  accountName,
			@RequestParam(value = "accountShortName",	required = false,	defaultValue = "") String  accountShortName,
			@RequestParam(value = "taxCode",			required = false,	defaultValue = "") String  taxCode,
			@RequestParam(value = "taxType",			required = false,	defaultValue = "") String  taxType,
			@RequestParam(value = "isUse",				required = false,	defaultValue = "") String  isUse,
			@RequestParam(value = "description",		required = false,	defaultValue = "") String  description,
			@RequestParam(value = "listPage",			required = false,	defaultValue = "N") String listPage
			) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				params.put("accountID",			accountID);
				params.put("companyCode",		companyCode);
				params.put("accountClass",		accountClass);
				params.put("accountCode",		ComUtils.RemoveScriptAndStyle(accountCode));
				params.put("accountName",		ComUtils.RemoveScriptAndStyle(accountName));
				params.put("accountShortName",	ComUtils.RemoveScriptAndStyle(accountShortName));
				params.put("taxCode",			taxCode);
				params.put("taxType",			taxType);
				params.put("isUse",				isUse);
				params.put("description",		ComUtils.RemoveScriptAndStyle(description));
				params.put("listPage",			listPage);
				
				rtValue = accountManageSvc.saveAccountManageInfo(params);
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}  catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}
		return rtValue;
	}
	
	/**
	 * @Method Name : deleteAccountManageInfo
	 * @Description : 계정관리 삭제
	 */
	@RequestMapping(value = "accountManage/deleteAccountManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteAccountManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",	required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				params.put("deleteSeq",		deleteSeq);	
				accountManageSvc.deleteAccountManage(params);
				
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
	 * @Method Name : accountManageExcelDownload
	 * @Description : 계정관리 엑셀 다운로드
	 */
	@RequestMapping(value = "accountManage/accountManageExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView accountManageExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "accountClass",	required = false, defaultValue="")	String accountClass,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "taxCode",		required = false, defaultValue="")	String taxCode,
			@RequestParam(value = "taxType",		required = false, defaultValue="")	String taxType,
			@RequestParam(value = "isUse",			required = false, defaultValue="")	String isUse,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "soapAccountCD",	required = false, defaultValue="")	String soapAccountCD,
			@RequestParam(value = "soapAccountCN",	required = false, defaultValue="")	String soapAccountCN,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType
			){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("accountClass",	commonCon.convertUTF8(accountClass));
			params.put("searchType",	commonCon.convertUTF8(searchType));
			params.put("taxCode",		commonCon.convertUTF8(taxCode));
			params.put("taxType",		commonCon.convertUTF8(taxType));
			params.put("isUse",			commonCon.convertUTF8(isUse));
			params.put("searchStr",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("searchProperty",commonCon.convertUTF8(searchProperty));
			params.put("soapAccountCD",	commonCon.convertUTF8(soapAccountCD));
			params.put("soapAccountCN",	commonCon.convertUTF8(soapAccountCN));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = accountManageSvc.accountManageExcelDownload(params);

			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",			accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));	
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : accountManageExcelPopup
	 * @Description : 계정관리 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "accountManage/accountManageExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView accountManageExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/AccountManageExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : accountManageExcelPopup
	 * @Description : 계정관리 엑셀 업로드
	 */
	@RequestMapping(value = "accountManage/accountManageExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap accountManageExcelPopup(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			returnData = accountManageSvc.accountManageExcelUpload(params);
			
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
	 * @Method Name : accountManageSync
	 * @Description : 동기화
	 */
	@RequestMapping(value = "accountManage/accountManageSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap accountManageSync(){
		CoviMap	resultList	= new CoviMap();
		resultList = accountManageSvc.accountManageSync();
		return resultList;
	}
}
