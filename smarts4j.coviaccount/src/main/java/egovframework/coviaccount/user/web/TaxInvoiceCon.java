package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.TaxInvoiceSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : TaxInvoiceCon.java
 * @Description : 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class TaxInvoiceCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private TaxInvoiceSvc taxInvoiceSvc;

	@Autowired
	private CommonCon commonCon;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getTaxInvoiceList
	 * @Description : 매입수신내역 목록 조회
	 */
	@RequestMapping(value = "taxInvoice/getTaxInvoiceList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoiceList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty) throws Exception{
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
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("taxInvoiceActive",	taxInvoiceActive);
			params.put("writeDateS",		writeDateS);
			params.put("writeDateE",		writeDateE);
			params.put("searchType",		searchType);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			resultList = taxInvoiceSvc.getTaxInvoiceList(params);
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
	 * @Method Name : getTaxInvoiceUserList
	 * @Description : 매입수신내역[사용자] 목록 조회
	 */
	@RequestMapping(value = "taxInvoice/getTaxInvoiceUserList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoiceUserList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr) throws Exception{
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
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("taxInvoiceActive",	taxInvoiceActive);
			params.put("writeDateS",		writeDateS);
			params.put("writeDateE",		writeDateE);
			params.put("searchType",		searchType);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			resultList = taxInvoiceSvc.getTaxInvoiceList(params);
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
	 * @Method Name : taxInvoiceExcelDownload
	 * @Description : 매입수신내역 엑셀 다운로드
	 */
	@RequestMapping(value = "taxInvoice/taxInvoiceExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView taxInvoiceExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("searchProperty",	commonCon.convertUTF8(searchProperty));
			params.put("companyCode",		commonCon.convertUTF8(companyCode));
			params.put("taxInvoiceActive",	commonCon.convertUTF8(taxInvoiceActive));
			params.put("writeDateS",		commonCon.convertUTF8(writeDateS));
			params.put("writeDateE",		commonCon.convertUTF8(writeDateE));
			params.put("searchType",		commonCon.convertUTF8(searchType));
			params.put("searchStr",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			resultList = taxInvoiceSvc.taxInvoiceExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
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
	 * @Method Name : taxInvoiceExcelDownloadUser
	 * @Description : 매입수신내역[사용자] 엑셀 다운로드
	 */
	@RequestMapping(value = "taxInvoice/taxInvoiceExcelDownloadUser.do" , method = RequestMethod.GET)
	public ModelAndView taxInvoiceExcelDownloadUser(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",		commonCon.convertUTF8(companyCode));
			params.put("taxInvoiceActive",	commonCon.convertUTF8(taxInvoiceActive));
			params.put("writeDateS",		commonCon.convertUTF8(writeDateS));
			params.put("writeDateE",		commonCon.convertUTF8(writeDateE));
			params.put("searchType",		commonCon.convertUTF8(searchType));
			params.put("searchStr",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			resultList = taxInvoiceSvc.taxInvoiceExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
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
	 * @Method Name : saveExpence
	 * @Description : 
	 */
	@RequestMapping(value = "taxInvoice/saveExpence.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveExpence(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				taxInvoiceSvc.saveExpence(params);
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
	 * @Method Name : saveIsOffset
	 * @Description : 매입수신내역 개인사용처리 유무 저장
	 */
	@RequestMapping(value = "taxInvoice/saveIsOffset.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveIsOffset(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				taxInvoiceSvc.saveIsOffset(params);
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
	 * @Method Name : saveTaxInvoiceTossUser
	 * @Description : 매입수신내역 전달 사용자 저장
	 */
	@RequestMapping(value = "taxInvoice/saveTaxInvoiceTossUser.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveTaxInvoiceTossUser(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
		try {
			taxInvoiceSvc.saveTaxInvoiceTossUser(params);
			rtValue.put("status", Return.SUCCESS);
			rtValue.put("tossUserName", params.get("tossUserName"));
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
	 * @Method Name : cashBillSync
	 * @Description : 현금 영수증 동기화
	 */
	@RequestMapping(value = "taxInvoice/cashBillSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap cashBillSync(@RequestParam java.util.Map<String, String> paramMap){
		
		CoviMap	resultList	= new CoviMap();
		
		CoviMap params = new CoviMap();

		String reqCompanyCode = paramMap.get("CompanyCode");
		interfaceUtil.setDomainInfo(paramMap, params);
		if(reqCompanyCode != null && !reqCompanyCode.equals(params.getString("CompanyCode"))) {
			resultList.put("status",	Return.FAIL);
			return resultList;
		}
		
		resultList = taxInvoiceSvc.cashBillSync(params);
		return resultList;
	}
	
	/**
	 * @Method Name : taxInvoiceSync
	 * @Description : 매입수신내역 동기화
	 */
	@RequestMapping(value = "taxInvoice/taxInvoiceSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap taxInvoiceSync(@RequestParam java.util.Map<String, String> paramMap){
		CoviMap	resultList	= new CoviMap();
		
		CoviMap params = new CoviMap();
		
		String reqCompanyCode = paramMap.get("CompanyCode");
		interfaceUtil.setDomainInfo(paramMap, params);
		if(reqCompanyCode != null && !reqCompanyCode.equals(params.getString("CompanyCode"))) {
			resultList.put("status",	Return.FAIL);
			return resultList;
		}
		
		resultList = taxInvoiceSvc.taxInvoiceSync(params);
		return resultList;
	}
}
