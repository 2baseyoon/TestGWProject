package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.InvestigationSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : InvestigationCon.java
 * @Description : 경조사 관리 컨트롤러
 * @Modification Information 
 * @ 2019.11.11 최초생성
 *
 * @author 코비젼 연구 2팀
 * @since 2019.11.11
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class InvestigationCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private InvestigationSvc investigationSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getInvestigationList
	 * @Description : 경조사 관리 목록 조회
	 */
	@RequestMapping(value = "investigation/getInvestigationList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getInvestigationList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "searchGrp" ,		required = false, defaultValue="") String searchGrp ,
			@RequestParam(value = "searchText",		required = false, defaultValue="")	String searchText) throws Exception{
			
		CoviMap resultList = new CoviMap();
		try {
			int pageSize = 10;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null || request.getParameter("pageSize").length()> 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}
			
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
			params.put("searchGrp", 	searchGrp);
			params.put("searchText" , 	ComUtils.RemoveSQLInjection(searchText, 100));
			
			resultList = investigationSvc.getInvestigationList(params);
			
			resultList.put("result" , "ok");
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
	 * @Method Name : getInvestigationPopup
	 * @Description : 경조사 관리 팝업 호출
	 */
	@RequestMapping(value = "investigation/getInvestigationPopup" , method = RequestMethod.GET)
	public ModelAndView getInvestigationPopup(HttpServletRequest request){
		String returnURL = "user/account/InvestigationPopup";
		ModelAndView mav = new ModelAndView(returnURL);

		String investigationID = request.getParameter("InvestigationID");
		mav.addObject("InvestigationID", investigationID);
		
		return mav;
	}
	
	/**
	 * @Method Name : saveInvestInfo
	 * @Description : 경조사 관리 저장
	 */
	@RequestMapping(value = "investigation/saveInvestInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveInvestInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "InvestCodeGroup",	required = false , defaultValue="") String investCodeGroup,
			@RequestParam(value = "InvestCode",			required = false , defaultValue="") String investCode,
			@RequestParam(value = "InvestCodeName",		required = false , defaultValue="") String investCodeName,
			@RequestParam(value = "IsGroup",			required = false , defaultValue="") String isGroup,
			@RequestParam(value = "IsUse",				required = false , defaultValue="") String isUse,
			@RequestParam(value = "SortKey",			required = false , defaultValue="") String sortKey,
			@RequestParam(value = "InvestAmount",		required = false , defaultValue="") String investAmount,
			@RequestParam(value = "Description",		required = false , defaultValue="") String description,
			@RequestParam(value = "InvestigationID",	required = false , defaultValue="") String investigationID) throws Exception{
		
		CoviMap resultList = new CoviMap();
		CoviMap params 		= new CoviMap();
		
		try {
			params.put("investCodeGroup",	investCodeGroup);
			params.put("investCode",		investCode);
			params.put("investCodeName",	ComUtils.RemoveScriptAndStyle(investCodeName));
			params.put("isGroup",			isGroup);
			params.put("isUse",				isUse);
			params.put("sortKey",			sortKey);
			params.put("investAmount",		investAmount);
			params.put("description",		ComUtils.RemoveScriptAndStyle(description));
			params.put("investigationID",	investigationID);
			
			resultList = investigationSvc.saveInvestInfo(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteInvestInfo
	 * @Description : 경조사관리 삭제
	 */
	@RequestMapping(value = "investigation/deleteInvestInfo.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteInvestInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq", required = false , defaultValue ="") String deleteSeq) throws Exception {
		CoviMap resultList  = new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			params.put("deleteSeq" , deleteSeq);
			investigationSvc.deleteInvestInfo(params);
			
			resultList.put("result" , "ok");
			resultList.put("status" , Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message" , "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : getInvestigationListExcel
	 * @Description : 경조사 관리 엑셀 다운로드
	 */
	@RequestMapping(value ="investigation/getInvestigationListExcel.do" , method = RequestMethod.GET)
	public ModelAndView getInvestigationListExcel(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "searchGrp",			required = false, defaultValue="") String searchGrp,
			@RequestParam(value = "searchText",			required = false, defaultValue="") String searchText,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			
			String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			
			CoviMap params = new CoviMap();;
			params.put("searchGrp",	commonCon.convertUTF8(searchGrp));
			params.put("searchStr",	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchText, 100)));
			params.put("headerKey",	commonCon.convertUTF8(headerKey));
			resultList = investigationSvc.getInvestigationListExcel(params);
			
			viewParams.put("list" ,		resultList.get("list"));
			viewParams.put("cnt"  , 	resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			
			mav = new ModelAndView(returnURL , viewParams);
		
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}	

	/**
	 * @Method Name : getInvestigationInfo
	 * @Description : 경조사 관리 상세 정보 조회
	 */
	@RequestMapping(value="investigation/getInvestigationInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getInvestigationInfo(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String investigationID =  request.getParameter("InvestigationID");
			
			CoviMap params = new CoviMap();
			params.put("investigationID", investigationID);
			resultMap = investigationSvc.getInvestigationInfo(params);
			returnObj.put("data", resultMap.get("result"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (SQLException e) {
			returnObj.put("status",	Return.FAIL);
			returnObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}

	/**
	 * @Method Name : getInvestItemCombo
	 * @Description : 경조항목 selectbox
	 */
	@RequestMapping(value="investigation/getInvestItemCombo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInvestItemCombo(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String companyCode = request.getParameter("CompanyCode");
			
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			resultMap = investigationSvc.getInvestItemCombo(params);
			returnObj.put("list", resultMap.get("result"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (SQLException e) {
			returnObj.put("status",	Return.FAIL);
			returnObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}

	/**
	 * @Method Name : getInvestTargetCombo
	 * @Description : 경조대상 selectbox
	 */
	@RequestMapping(value="investigation/getInvestTargetCombo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInvestTargetCombo(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String investCodeGroup = request.getParameter("InvestCodeGroup");
			String companyCode = request.getParameter("CompanyCode");
			
			CoviMap params = new CoviMap();
			params.put("investCodeGroup", investCodeGroup);
			params.put("companyCode", companyCode);
			
			resultMap = investigationSvc.getInvestTargetCombo(params);
			returnObj.put("list", resultMap.get("result"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (SQLException e) {
			returnObj.put("status",	Return.FAIL);
			returnObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	/**
	 * InvestCrtrPop : 경조사비 지급 기준 팝업
	 * @return mav
	 */
	@RequestMapping(value = "investigation/InvestCrtrPop.do",method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView investCrtrPop(HttpServletRequest request,	HttpServletResponse response,
			@RequestParam(value = "popupName",	required = false,	defaultValue = "") String popupName) throws Exception {
		ModelAndView mav = new ModelAndView("cmmn/popup/" + popupName);
		mav.addObject("info",investigationSvc.getInvestCrtr());
		return mav;
	}
	
	/**
	 * @Method Name : getInvestigationUseList
	 * @Description : 경조사비 사용내역 목록 조회
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "investigation/getInvestigationUseList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getInvestigationUseList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy) throws Exception{
			
		CoviMap resultList = new CoviMap();
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap jsonParams = CoviMap.fromObject(searchParam);
			
			int pageSize = 10;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null || request.getParameter("pageSize").length()> 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}
			
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
			params.putAll(jsonParams);
			
			resultList = investigationSvc.getInvestigationUseList(params);
			
			resultList.put("result" , "ok");
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
	 * @Method Name : getInvestigationUseListExcel
	 * @Description : 경조사비 사용내역 엑셀 다운로드
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value ="investigation/getInvestigationUseListExcel.do" , method = RequestMethod.GET)
	public ModelAndView getInvestigationUseListExcel(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap jsonParams = CoviMap.fromObject(searchParam);
			
			CoviMap params = new CoviMap();
			
			params.putAll(jsonParams);
			params.put("headerKey",	commonCon.convertUTF8(headerKey));
			resultList = investigationSvc.getInvestigationUseListExcel(params);
			
			viewParams.put("list" ,			resultList.get("list"));
			viewParams.put("cnt"  , 		resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL , viewParams);
		
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}	
}
