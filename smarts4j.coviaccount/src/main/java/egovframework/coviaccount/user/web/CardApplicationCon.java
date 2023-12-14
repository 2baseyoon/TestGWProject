package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
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
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.user.service.CardApplicationSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : cardApplicationCon.java
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
public class CardApplicationCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CardApplicationSvc cardApplicationSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getCardApplicationList
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "cardApplication/getCardApplicationList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardApplicationList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "registerCode",	required = false, defaultValue="")	String registerCode,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
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
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("registerCode",	registerCode);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("isUse",			isUse);
			
			resultList = cardApplicationSvc.getCardApplicationList(params);
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
	 * getCardApplicationDetail
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "cardApplication/getCardApplicationDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardApplicationDetail(
			@RequestParam(value = "cardApplicationID",	required = false, defaultValue="")	String cardApplicationID,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{

		
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("cardApplicationID",		cardApplicationID);
			params.put("companyCode",			companyCode);
			
			resultList = cardApplicationSvc.getCardApplicationDetail(params);
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
	 * getCardApplicationUserPopup
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "cardApplication/getCardApplicationUserPopup.do", method = RequestMethod.GET)
	public ModelAndView costCenterExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/CardApplicationUserPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * saveCardApplicationInfo
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "cardApplication/saveCardApplicationInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCardApplicationInfo(	HttpServletRequest		request
															,	HttpServletResponse		response
															,	@RequestBody HashMap	paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		try {
			rtValue = cardApplicationSvc.saveCardApplicationInfo(params);
			rtValue.put("status",	Return.SUCCESS);
			
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return rtValue;
	}
	
	/**
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "cardApplication/cardApplicationExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardApplicationExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "registerCode",	required = false, defaultValue="")	String registerCode,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "isUse",			required = false, defaultValue="")	String isUse,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String convertHeaderName	= new String(headerName.getBytes("8859_1"), "UTF-8");
			String convertHeaderName	= headerName;
			String[] headerNames		= convertHeaderName.split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",	companyCode);
			params.put("registerCode",	registerCode);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("isUse",			isUse);
			params.put("headerKey",		headerKey);
			resultList = cardApplicationSvc.cardApplicationExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);

			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("headerType",headerType);
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
}
