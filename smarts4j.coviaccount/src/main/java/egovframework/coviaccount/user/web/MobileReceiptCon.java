package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
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
import egovframework.coviaccount.user.service.MobileReceiptSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : MobileReceiptCon.java
 * @Description : 모바일 영수증 등록내역 컨트롤러
 * @Modification Information 
 * @ 2018.08.29 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.08.29
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MobileReceiptCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private MobileReceiptSvc mobileReceiptSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//CardReceipt - Start
	/**
	 * @Method Name : getMobileReceiptList
	 * @Description : 모바일 영수증 등록내역 목록 조회
	 */
	@RequestMapping(value = "mobileReceipt/getMobileReceiptList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getMobileReceiptList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "userCode",		required = false, defaultValue="")	String userCode,
			@RequestParam(value = "photoDateS",		required = false, defaultValue="")	String photoDateS,
			@RequestParam(value = "photoDateE",		required = false, defaultValue="")	String photoDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "receiptType",	required = false, defaultValue="")	String receiptType) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("lang",				SessionHelper.getSession("lang"));
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("userCode",			userCode);
			params.put("photoDateS",		photoDateS);
			params.put("photoDateE",		photoDateE);
			params.put("active",			active);
			params.put("receiptType",		receiptType);
			
			//timezone 적용 날짜변환
			if(params.get("photoDateS") != null && !params.get("photoDateS").equals("")){
				params.put("photoDateS",ComUtils.TransServerTime(params.get("photoDateS").toString() + " 00:00:00"));
			}
			if(params.get("photoDateE") != null && !params.get("photoDateE").equals("")){
				params.put("photoDateE",ComUtils.TransServerTime(params.get("photoDateE").toString() + " 23:59:59"));
			}
			
			resultList = mobileReceiptSvc.getMobileReceiptList(params);
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
	 * @Method Name : mobileReceiptExcelDownload
	 * @Description : 모바일 영수증 등록내역 엑셀 다운로드
	 */
	@RequestMapping(value = "mobileReceipt/mobileReceiptExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView mobileReceiptExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "userCode",		required = false, defaultValue="")	String userCode,
			@RequestParam(value = "photoDateS",		required = false, defaultValue="")	String photoDateS,
			@RequestParam(value = "photoDateE",		required = false, defaultValue="")	String photoDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "receiptType",	required = false, defaultValue="")	String receiptType,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("lang",				commonCon.convertUTF8(SessionHelper.getSession("lang")));
			params.put("companyCode",		commonCon.convertUTF8(companyCode));
			params.put("userCode",			commonCon.convertUTF8(userCode));
			params.put("photoDateS",		commonCon.convertUTF8(photoDateS));
			params.put("photoDateE",		commonCon.convertUTF8(photoDateE));
			params.put("active",			commonCon.convertUTF8(active));
			params.put("receiptType",		commonCon.convertUTF8(receiptType));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			
			resultList = mobileReceiptSvc.getMobileReceiptExcelList(params);
			
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
	
	//CardReceiptUser - Start
	
	/**
	 * @Method Name : getMobileReceiptUserList
	 * @Description : 모바일 영수증 등록내역 [사용자] 목록 조회
	 */
	@RequestMapping(value = "mobileReceipt/getMobileReceiptUserList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getMobileReceiptUserList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "userCode",		required = false, defaultValue="")	String userCode,
			@RequestParam(value = "photoDateS",		required = false, defaultValue="")	String photoDateS,
			@RequestParam(value = "photoDateE",		required = false, defaultValue="")	String photoDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "receiptType",	required = false, defaultValue="")	String receiptType) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("lang",			SessionHelper.getSession("lang"));
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("userCode",		userCode);
			params.put("photoDateS",	photoDateS);
			params.put("photoDateE",	photoDateE);
			params.put("active",		active);
			params.put("receiptType",	receiptType);
			
			//timezone 적용 날짜변환
			if(params.get("photoDateS") != null && !params.get("photoDateS").equals("")){
				params.put("photoDateS",ComUtils.TransServerTime(params.get("photoDateS").toString() + " 00:00:00"));
			}
			if(params.get("photoDateE") != null && !params.get("photoDateE").equals("")){
				params.put("photoDateE",ComUtils.TransServerTime(params.get("photoDateE").toString() + " 23:59:59"));
			}
			
			resultList = mobileReceiptSvc.getMobileReceiptUserList(params);
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
	 * @Method Name : mobileReceiptUserExcelDownload
	 * @Description : 모바일 영수증 등록 내역 [사용자] 엑셀 다운로드
	 */
	@RequestMapping(value = "mobileReceipt/mobileReceiptUserExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView mobileReceiptUserExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "userCode",		required = false, defaultValue="")	String userCode,
			@RequestParam(value = "photoDateS",		required = false, defaultValue="")	String photoDateS,
			@RequestParam(value = "photoDateE",		required = false, defaultValue="")	String photoDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "receiptType",	required = false, defaultValue="")	String receiptType,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title) {
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("lang",			commonCon.convertUTF8(SessionHelper.getSession("lang")));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("userCode",		commonCon.convertUTF8(userCode));
			params.put("photoDateS",	commonCon.convertUTF8(photoDateS));
			params.put("photoDateE",	commonCon.convertUTF8(photoDateE));
			params.put("active",		commonCon.convertUTF8(active));
			params.put("receiptType",	commonCon.convertUTF8(receiptType));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			
			resultList = mobileReceiptSvc.getMobileReceiptUserExcelList(params);
			
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
	 * @Method Name : deleteMobileReceipt
	 * @Description : 모바일 영수증 삭제
	 */
	@RequestMapping(value = "mobileReceipt/deleteMobileReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteMobileReceipt(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",		required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				if(deleteSeq != null && !deleteSeq.equals("")) params.put("deleteSeq", deleteSeq.split(","));
				mobileReceiptSvc.deleteMobileReceipt(params);
				
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
	
	@GetMapping("mobileReceipt/insertMobileReceipt.do")
	public ModelAndView insertMobileReceipt(Locale locale, Model model) {
		return new ModelAndView("mobileReceipt/insertMobileReceipt");
	}
	
	@PostMapping("mobileReceipt/insertMobileReceipt/save.do")
	public @ResponseBody CoviMap save(@RequestBody Map<String, String> paramMap) throws Exception {
		return mobileReceiptSvc.save(CoviMap.fromObject(paramMap));
	}
}