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
import egovframework.coviaccount.user.service.StoreCategoryManageSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : StoreCategoryManageCon.java
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
public class StoreCategoryManageCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private StoreCategoryManageSvc storeCategoryManageSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	* @Method Name : callStoreCategoryManagePopup
	* @Description : 업종 상세화면 호출 
	*/
	@RequestMapping(value = "StoreCategoryManage/callStoreCategoryManagePopup.do", method = RequestMethod.GET)
	public ModelAndView callStoreCategoryManagePopup(HttpServletRequest request, HttpServletResponse response) {
		String returnURL = "user/account/StoreCategoryManagePopup";

		String categoryID = request.getParameter("CategoryID");

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("CategoryID", categoryID);

		return mav;
	}
	
	/**
	 * @Method Name : getStoreCategoryManagelist 
	 * @Description : 업종 목록 조회
	 */
	@RequestMapping(value = "StoreCategoryManage/getStoreCategoryManagelist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getStoreCategoryManagelist(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "CategoryName",	required = false, defaultValue="")	String categoryName,
			@RequestParam(value = "StandardBriefName",	required = false, defaultValue="")	String standardBriefName) throws Exception{

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
			params.put("CompanyCode",		companyCode);
			params.put("CategoryName",		ComUtils.RemoveSQLInjection(categoryName, 100));
			params.put("StandardBriefName",	ComUtils.RemoveSQLInjection(standardBriefName, 100));
			
			resultList = storeCategoryManageSvc.getStoreCategoryManagelist(params);
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
	 * @Method Name : getStoreCategoryManageDetail
	 * @Description : 업종 상세 조회
	 */
	@RequestMapping(value = "StoreCategoryManage/getStoreCategoryManageDetail.do", method=RequestMethod.GET)
	public	@ResponseBody CoviMap getStoreCategoryManageDetail(
			@RequestParam(value = "CategoryID",	required = false, defaultValue="") String categoryID) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("CategoryID",	categoryID);
			resultList = storeCategoryManageSvc.getStoreCategoryManageDetail(params);
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
	 * @Method Name : saveStoreCategoryManageInfo
	 * @Description : 업종 정보 저장
	 */
	@RequestMapping(value = "StoreCategoryManage/saveStoreCategoryManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveStoreCategoryManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
			try {
				rtValue = storeCategoryManageSvc.saveStoreCategoryManageInfo(params);
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
	 * @Method Name : deleteStoreCategoryManageInfo
	 * @Description : 업종 삭제
	 */
	@RequestMapping(value = "StoreCategoryManage/deleteStoreCategoryManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteStoreCategoryManageInfoByAccountID(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",		required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
			try {
				
				params.put("deleteSeq",	deleteSeq);	
				storeCategoryManageSvc.deleteStoreCategoryManageInfo(params);
				
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
	 * @Method Name : StoreCategoryManageExcelDownload
	 * @Description : 업종 엑셀 다운로드
	 */
	@RequestMapping(value = "StoreCategoryManage/StoreCategoryManageExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView storeCategoryManageExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",			required = false, defaultValue="")	String headerType,
			@RequestParam(value = "CompanyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "CategoryName",		required = false, defaultValue="")	String categoryName,
			@RequestParam(value = "StandardBriefName",	required = false, defaultValue="")	String standardBriefName,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames		= commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("CompanyCode",		commonCon.convertUTF8(companyCode));
			params.put("CategoryName",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(categoryName, 100)));
			params.put("StandardBriefName",	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(standardBriefName, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = storeCategoryManageSvc.storeCategoryManageExcelDownload(params);
			
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
	 * @Method Name : StoreCategoryManageExcelPopup
	 * @Description : 업종정보 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "StoreCategoryManage/StoreCategoryManageExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView accountManageExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/StoreCategoryManageExcelPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * @Method Name : StoreCategoryManageExcelUpload
	 * @Description : 업종정보 엑셀 업로드
	 */
	@RequestMapping(value = "StoreCategoryManage/StoreCategoryManageExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap storeCategoryManageExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			returnData = storeCategoryManageSvc.storeCategoryManageExcelUpload(params);
			
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
	
}
