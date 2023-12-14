package egovframework.coviaccount.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
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
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.CardReceiptSvc;
import egovframework.coviframework.util.ComUtils;
import net.sf.jxls.transformer.XLSTransformer;

/**
 * @Class Name : CardReceiptCon.java
 * @Description : 카드사용내역 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CardReceiptCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CardReceiptSvc cardReceiptSvc;

	@Autowired
	private CommonCon commonCon;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//CardReceipt - Start
	/**
	 * @Method Name : getCardReceiptList
	 * @Description : 법인카드 사용내역 목록 조회
	 */
	@RequestMapping(value = "cardReceipt/getCardReceiptList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptList(
			@RequestParam(value = "selectType",		required = false, defaultValue="")	String selectType,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "infoIndex",		required = false, defaultValue="")	String infoIndex,
			@RequestParam(value = "isPersonalUse",	required = false, defaultValue="")	String isPersonalUse) throws Exception{
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
			params.put("selectType",		selectType);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("cardClass",			cardClass);
			params.put("cardUserCode",		cardUserCode);
			params.put("approveDateS",		approveDateS);
			params.put("approveDateE",		approveDateE);
			params.put("active",			active);
			params.put("cardNo",			ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("infoIndex",			infoIndex);
			params.put("isPersonalUse",		isPersonalUse);
			
			resultList = cardReceiptSvc.getCardReceiptList(params);
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
	 * @Method Name : getCardReceiptPopup
	 * @Description : 법인카드 사용내역 팝업 호출
	 */
	@RequestMapping(value = "cardReceipt/getCardReceiptPopup.do", method = RequestMethod.GET)
	public ModelAndView getCardReceiptPopup(Locale locale, Model model) {
		String returnURL = "user/account/CardReceiptPopup";
		ModelAndView mav = new ModelAndView(returnURL);				
		return mav;
	}
	
	/**
	 * @Method Name : cardReceiptExcelDownload
	 * @Description : 법인카드 사용내역 엑셀 다운로드
	 */
	@RequestMapping(value = "cardReceipt/cardReceiptExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardReceiptExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "infoIndex",		required = false, defaultValue="")	String infoIndex,
			@RequestParam(value = "isPersonalUse",	required = false, defaultValue="")	String isPersonalUse,
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
			params.put("cardClass",			commonCon.convertUTF8(cardClass));
			params.put("cardUserCode",		commonCon.convertUTF8(cardUserCode));
			params.put("approveDateS",		commonCon.convertUTF8(approveDateS));
			params.put("approveDateE",		commonCon.convertUTF8(approveDateE));
			params.put("active",			commonCon.convertUTF8(active));
			params.put("cardNo",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("infoIndex",			commonCon.convertUTF8(infoIndex));
			params.put("isPersonalUse",		commonCon.convertUTF8(isPersonalUse));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			
			resultList = cardReceiptSvc.getCardReceiptExcelList(params);
			
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
	 * @Method Name : saveCardReceiptTossUser
	 * @Description : 법인카드 사용내역 전달 사용자 저장
	 */
	@RequestMapping(value = "cardReceipt/saveCardReceiptTossUser.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCardReceiptTossUser(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				cardReceiptSvc.saveCardReceiptTossUser(params);
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
	//CardReceipt - End
	
	//CardReceiptCancel - Start
	
	/**
	 * @Method Name : getCardReceiptCancelList
	 * @Description : 법인카드 승인 취소 내역 목록 조회
	 */
	@RequestMapping(value = "cardReceipt/getCardReceiptCancelList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptCancelList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo) throws Exception{
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
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("cardClass",		cardClass);
			params.put("cardUserCode",	cardUserCode);
			params.put("approveDateS",	approveDateS);
			params.put("approveDateE",	approveDateE);
			params.put("storeName",		ComUtils.RemoveSQLInjection(storeName, 100));
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			
			resultList = cardReceiptSvc.getCardReceiptCancelList(params);
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
	 * @Method Name : cardReceiptCancelExcelDownload
	 * @Description : 법인카드 승인 취소 내역 엑셀 다운로드
	 */
	@RequestMapping(value = "cardReceipt/cardReceiptCancelExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardReceiptCancelExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("cardClass",		commonCon.convertUTF8(cardClass));
			params.put("cardUserCode",	commonCon.convertUTF8(cardUserCode));
			params.put("approveDateS",	commonCon.convertUTF8(approveDateS));
			params.put("approveDateE",	commonCon.convertUTF8(approveDateE));
			params.put("storeName",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(storeName, 100)));
			params.put("cardNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			
			resultList = cardReceiptSvc.getCardReceiptCancelExcelList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	//CardReceiptCancel - End
	
	//CardReceiptUser - Start
	
	/**
	 * @Method Name : getCardReceiptUserList
	 * @Description : 법인카드 사용내역 [사용자] 목록 조회
	 */
	@RequestMapping(value = "cardReceipt/getCardReceiptUserList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptUserList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "approveNo",		required = false, defaultValue="")	String approveNo) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("searchProperty",searchProperty);
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("storeName",		ComUtils.RemoveSQLInjection(storeName, 100));
			params.put("cardUserCode",	cardUserCode);
			params.put("approveDateS",	approveDateS);
			params.put("approveDateE",	approveDateE);
			params.put("active",		active);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("approveNo",		ComUtils.RemoveSQLInjection(approveNo, 100));
			
			resultList = cardReceiptSvc.getCardReceiptUserList(params);
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
	 * @Method Name : cardReceiptUserExcelDownload
	 * @Description : 법인카드 사용내역 [사용자] 엑셀 다운로드
	 */
	@RequestMapping(value = "cardReceipt/cardReceiptUserExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardReceiptUserExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "approveNo",		required = false, defaultValue="")	String approveNo,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title) {
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("searchProperty",commonCon.convertUTF8(searchProperty));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("storeName",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(storeName, 100)));
			params.put("cardUserCode",	commonCon.convertUTF8(cardUserCode));
			params.put("approveDateS",	commonCon.convertUTF8(approveDateS));
			params.put("approveDateE",	commonCon.convertUTF8(approveDateE));
			params.put("active",		commonCon.convertUTF8(active));
			params.put("cardNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("approveNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(approveNo, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			
			resultList = cardReceiptSvc.getCardReceiptUserExcelList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : saveCardReceiptPersonal
	 * @Description : 법인카드 사용내역 개인 사용 처리 유무 저장
	 */
	@RequestMapping(value = "cardReceipt/saveCardReceiptPersonal.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCardReceiptPersonal(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				cardReceiptSvc.saveCardReceiptPersonal(params);
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status",	Return.FAIL);
				rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			} catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			}
		return rtValue;
	}
	//CardReceiptUser - End
	
	//CardReceiptUserPersonalUse - Start
	
	/**
	 * @Method Name : getCardReceiptUserPersonalUseList
	 * @Description : 개인카드 청구내역 목록 조회
	 */
	@RequestMapping(value = "cardReceipt/getCardReceiptUserPersonalUseList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptUserPersonalUseList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardUserCode",	required = false, defaultValue="")	String cardUserCode,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "active",			required = false, defaultValue="")	String active,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo) throws Exception{
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
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("storeName",		ComUtils.RemoveSQLInjection(storeName, 100));
			params.put("cardUserCode",	cardUserCode);
			params.put("approveDateS",	approveDateS);
			params.put("approveDateE",	approveDateE);
			params.put("active",		active);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			
			resultList = cardReceiptSvc.getCardReceiptUserPersonalUseList(params);
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
	//CardReceiptUserPersonalUse - End
	
	/**
	 * @Method Name : cardReceiptSync
	 * @Description : 카드 승인 내역 동기화
	 */
	@RequestMapping(value = "cardReceipt/cardReceiptSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap cardReceiptSync(@RequestParam java.util.Map<String, String> paramMap){
		CoviMap	resultList	= new CoviMap();
		
		CoviMap params = new CoviMap();
		String reqCompanyCode = paramMap.get("CompanyCode");
		interfaceUtil.setDomainInfo(paramMap, params);
		if(reqCompanyCode != null && !reqCompanyCode.equals(params.getString("CompanyCode"))) {
			resultList.put("status",	Return.FAIL);
			return resultList;
		}
		
		resultList = cardReceiptSvc.cardReceiptSync(params);
		return resultList;
	}
	

	
	/**
	 * @Method Name : downloadTemplateFile
	 * @Description : 법인카드 엑셀 템플릿 다운로드
	 */
	@RequestMapping(value = "cardReceipt/downloadTemplateFile.do")
	public void downloadTemplateFile(HttpServletRequest request, HttpServletResponse response) throws Exception {
		XSSFWorkbook workbook = null;
		Workbook resultWorkbook = null;
		InputStream is = null;
		ByteArrayOutputStream baos = null;
		try {
			CoviMap params = new CoviMap();
			
			workbook = new XSSFWorkbook();
			XSSFSheet sheet = workbook.createSheet("Sheet1");
			String FileName = "CardUploadTemplate.xls";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//CardUploadTemplate.xls");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			is = new BufferedInputStream(new FileInputStream(ExcelPath));
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			baos.flush();
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		} finally {
			if(is != null) { is.close(); }
			if(baos != null) { baos.close(); }
			if(workbook != null) { workbook.close(); }
			if(resultWorkbook != null) { resultWorkbook.close(); }
		}
	}
	
	/**
	 * @Method Name : goCardReceiptExcelPopup
	 * @Description : 법인카드 엑셀 업로드 팝업
	 */
	@RequestMapping(value = "cardReceipt/CardReceiptExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView goCardReceiptExcelPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "/user/account/CardReceiptExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * @Method Name : cardReceiptExcelUpload
	 * @Description : 법인카드 엑셀 업로드
	 */
	@RequestMapping(value = "cardReceipt/cardReceiptExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap cardReceiptExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			returnData = cardReceiptSvc.cardReceiptExcelUpload(params);
			
			returnData.put("status",	Return.SUCCESS);
			returnData.put("message",	"업로드 되었습니다");
		} catch (SQLException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	e.getMessage());
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	e.getMessage());
		}
		
		return returnData;		
	}
	
	/**
	 * @Method Name : getSendDelayCorpCardList
	 * @Description : 법인카드 미정산 내역
	 */
	@RequestMapping(value = "cardReceipt/getSendDelayCorpCardList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getSendDelayCorpCardList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "approveDateS",	required = false, defaultValue="")	String approveDateS,
			@RequestParam(value = "approveDateE",	required = false, defaultValue="")	String approveDateE,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo) throws Exception{
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
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("cardClass",	cardClass);
			params.put("approveDateS",	approveDateS);
			params.put("approveDateE",	approveDateE);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			
			resultList = cardReceiptSvc.getSendDelayCorpCardList(params);
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
	//CardReceiptUserPersonalUse - End
	/**
	 * @Method Name : getCardCompare
	 * @Description : 법인카드 사용내역 대사
	 */
	@RequestMapping(value = "cardReceipt/getCardCompare.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardCompare(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "useDateS",		required = false, defaultValue="")	String useDateS,
			@RequestParam(value = "useDateE",		required = false, defaultValue="")	String useDateE) throws Exception{
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
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("useDateS",	useDateS);
			params.put("useDateE",	useDateE);
			
			resultList = cardReceiptSvc.getCardCompare(params);
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