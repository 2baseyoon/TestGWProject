package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.coviaccount.user.service.StandardBriefSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : standardBriefCon.java
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
public class StandardBriefCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private StandardBriefSvc standardBriefSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getStandardBrieflist
	 * @Description : 표준적요 목록 조회
	 */
	@RequestMapping(value = "standardBrief/getStandardBrieflist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getStandardBrieflist(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr) throws Exception{

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
			params.put("searchType",	searchType);
			params.put("searchStr",		ComUtils.RemoveSQLInjection(searchStr, 100));
			
			resultList = standardBriefSvc.getStandardBrieflist(params);
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
	 * @Method Name : getStandardBriefPopup
	 * @Description : 표준적요 팝업 호출
	 */
	@RequestMapping(value = "standardBrief/getStandardBriefPopup.do", method = RequestMethod.GET)
	public ModelAndView getStandardBriefPopup(Locale locale, Model model) {
		String returnURL = "user/account/StandardBriefPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * @Method Name : getStandardBriefDetail
	 * @Description : 표준적요 상세 조회
	 */
	@RequestMapping(value = "standardBrief/getStandardBriefDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getStandardBriefDetail(
			@RequestParam(value = "accountID",	required = false, defaultValue="") String accountID) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("accountID",	accountID);
			resultList = standardBriefSvc.getStandardBriefDetail(params);
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
	 * @Method Name : saveStandardBriefInfo
	 * @Description : 표준적요 정보 저장
	 */
	@RequestMapping(value = "standardBrief/saveStandardBriefInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveStandardBriefInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				rtValue = standardBriefSvc.saveStandardBriefInfo(params);
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
	 * @Method Name : deleteStandardBriefInfoByAccountID
	 * @Description : 표준적요 삭제
	 */
	@RequestMapping(value = "standardBrief/deleteStandardBriefInfoByAccountID.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteStandardBriefInfoByAccountID(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",		required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				params.put("deleteSeq",	deleteSeq);	
				standardBriefSvc.deleteStandardBriefInfoByAccountID(params);
				
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
	 * @Method Name : standardBriefExcelDownload
	 * @Description : 표준적요 엑셀 다운로드
	 */
	@RequestMapping(value = "standardBrief/standardBriefExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView standardBriefExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "searchType",		required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames		= commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("searchType",	commonCon.convertUTF8(searchType));
			params.put("searchStr",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = standardBriefSvc.standardBriefExcelDownload(params);
			
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
	 * @Method Name : standardBriefExcelPopup
	 * @Description : 표준적요 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "standardBrief/standardBriefExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView standardBriefExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/StandardBriefExcelPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * @Method Name : standardBriefExcelPopup
	 * @Description : 표준적요 엑셀 업로드
	 */
	@RequestMapping(value = "standardBrief/standardBriefExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap standardBriefExcelPopup(
			@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) { 
		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			result = standardBriefSvc.standardBriefExcelUpload(params);
			
			result.put("status", Return.SUCCESS);
			result.put("message",	"업로드 되었습니다");
		} catch (SQLException e) {
			result.put("status",	Return.FAIL);
			result.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status",	Return.FAIL);
			result.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return result;		
	}
}
