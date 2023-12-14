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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.BudgetUsePerformSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : accountPreparCon.java
 * @Description : 예산사용현황 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BudgetUsePerformCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BudgetUsePerformSvc budgetUsePerformSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getApprovalIframeList - 예산사용현황
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/account/BudgetUsePerform.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView budgetUsePerform(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/BudgetUsePerform";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getBuggetUsePerformList
	 * @Description : 예산실행 목록 조회
	 */
	@RequestMapping(value = "budgetUsePerform/getBudgetUsePerformList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBudgetUsePerformList(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap(); 
			
			String sortColumn		= request.getParameter("sortColumn");
			String sortDirection	= request.getParameter("sortDirection");
			String sortBy			= StringUtil.replaceNull(request.getParameter("sortBy"),"");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			StringUtil.replaceNull(request.getParameter("pageNo"),"1"));
			params.put("pageSize",			StringUtil.replaceNull(request.getParameter("pageSize"),"1"));
			
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("costCenterName")).trim(), 100));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			params.put("authMode",			request.getParameter("authMode"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(request.getParameter("searchStr"), 100));
			
			resultList = budgetUsePerformSvc.getBudgetUsePerformList(params);
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
	 * getApprovalIframeList - 예산사용현황
	 * @param request
	 * @param response
	 * @param paramMap
	 * @returnbudgetUsePerform/BudgetUsePerformPopup
	 * @throws ExceptionopenBudgetUsePerformPopup
	 */
	@RequestMapping(value = "budgetUsePerform/BudgetUsePerformPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView budgetUsePerformPopup(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/BudgetUsePerformPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("companyCode",		request.getParameter("companyCode"));
		mav.addObject("fiscalYear",		request.getParameter("fiscalYear"));
		mav.addObject("costCenter",		request.getParameter("costCenter"));
		mav.addObject("costCenterName",	request.getParameter("costCenterName"));
		mav.addObject("accountCode",		request.getParameter("accountCode"));
		mav.addObject("accountName",		request.getParameter("accountName"));
		mav.addObject("standardBriefID",		request.getParameter("standardBriefID"));
		mav.addObject("standardBriefName",	request.getParameter("standardBriefName"));
		mav.addObject("validFrom",	request.getParameter("validFrom"));
		mav.addObject("validTo",	request.getParameter("validTo"));
		mav.addObject("periodLabel", request.getParameter("periodLabel"));

		return mav;
	}
	
	/**
	 * BudgetUsePerformChart - 그래프보기
	 * @param request
	 * @param response
	 * @param paramMap
	 * @returnbudgetUsePerform/BudgetUsePerformPopup
	 * @throws ExceptionopenBudgetUsePerformPopup
	 */
	@RequestMapping(value = "budgetUsePerform/BudgetUsePerformChart.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView budgetUsePerformChart(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/BudgetUsePerformChart";
		
		ModelAndView mav = new ModelAndView(returnURL);
		CoviList resultList = new CoviList();
		try {
			CoviMap params = new CoviMap();
			
			String costCenterType = request.getParameter("costCenterType");
			String groupbyCol = StringUtil.replaceNull(request.getParameter("groupbyCol"), "Cost");
			String fiscalYear = request.getParameter("fiscalYear");
			String costCenterName = request.getParameter("costCenterName");
			String searchType = request.getParameter("searchType");
			String searchStr = request.getParameter("searchStr");
			String companyCode = request.getParameter("companyCode");

			params.put("companyCode",		companyCode);
			params.put("costCenterType",	costCenterType);
			params.put("groupbyCol",		groupbyCol);
			params.put("fiscalYear",		fiscalYear);
			params.put("costCenterName",	costCenterName);
			params.put("searchType",		searchType);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("authMode",			request.getParameter("authMode"));
			
			resultList = budgetUsePerformSvc.getBudgetUsePerformChart(params);
			mav.addObject("resultList", resultList);
			mav.addObject("costCenterType",	costCenterType);
			mav.addObject("groupbyCol",		groupbyCol);
			mav.addObject("fiscalYear",		fiscalYear);
			mav.addObject("companyCode",	companyCode);
			mav.addObject("costCenterName",	costCenterName);
			mav.addObject("searchType",		searchType);
			mav.addObject("searchStr",		searchStr);
			
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * @Method Name : getBuggetUsePerformList
	 * @Description : 예산실행 상세 목록 조회
	 */
	@RequestMapping(value = "budgetUsePerform/getBudgetUsePerformDetailList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBudgetUsePerformDetailList(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= request.getParameter("sortColumn");
			String sortDirection	= request.getParameter("sortDirection");
			String sortBy			= StringUtil.replaceNull(request.getParameter("sortBy"),"");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			StringUtil.replaceNull(request.getParameter("pageNo"),"1"));
			params.put("pageSize",			StringUtil.replaceNull(request.getParameter("pageSize"),"1"));
			
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenter",	request.getParameter("costCenter"));
			params.put("accountCode",			request.getParameter("accountCode"));
			params.put("standardBriefID",				request.getParameter("standardBriefID"));
			params.put("validFrom",				request.getParameter("validFrom"));
			params.put("validTo",				request.getParameter("validTo"));
			params.put("periodLabel",	request.getParameter("periodLabel"));
	
			resultList = budgetUsePerformSvc.getBudgetUsePerformDetailList(params);
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
	 * @Method Name : downloadExcel
	 * @Description : 다운로드
	 */
	@RequestMapping(value = "budgetUsePerform/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(request.getParameter("headerName")).split("†");
			String[] headerNames = URLDecoder.decode(request.getParameter("headerName"),"utf-8").split("†");
			String[] headerKeys  = commonCon.convertUTF8(StringUtil.replaceNull(request.getParameter("headerKey"))).split(",");

			String costCenterName = URLDecoder.decode(request.getParameter("costCenterName"),"utf-8");
			String searchStr = URLDecoder.decode(request.getParameter("searchStr"),"utf-8");
			
			CoviMap params = new CoviMap();
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			
			params.put("authMode",			request.getParameter("authMode"));
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(costCenterName).trim(), 100));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			CoviMap resultList = budgetUsePerformSvc.getBudgetUsePerformList(params);

			CoviMap convertList = new CoviMap ();
			convertList.put("list", resultList.get("list"));
			
			viewParams.put("list",			convertList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			//viewParams.put("title",			accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
}
