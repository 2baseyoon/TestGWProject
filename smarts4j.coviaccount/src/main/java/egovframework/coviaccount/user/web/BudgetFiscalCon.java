package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

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
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.BudgetFiscalSvc;
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
public class BudgetFiscalCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BudgetFiscalSvc budgetFiscalSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	
	/**
	 * @Method Name : getBudgetFiscalList
	 * @Description : 회계년도 목록 조회
	 */
	@RequestMapping(value = "budgetFiscal/getBudgetFiscalList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBudgetFiscalList(HttpServletRequest request) throws Exception{

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
			
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("companyCode",		request.getParameter("companyCode"));
			
			resultList = budgetFiscalSvc.getBudgetFiscalList(params);
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
	@RequestMapping(value = "budgetFiscal/BudgetFiscalPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView budgetFiscalPopup(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/BudgetFiscalPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		CoviList resultList = budgetFiscalSvc.getBudgetFiscalCode();

		for (int i=0; i <	resultList.size(); i++)
		{
			CoviMap coviMap = resultList.getMap(i);
			mav.addObject(coviMap.getString("Code"),		coviMap.getString("Reserved1"));
		}

		return mav;
	}
	
	@RequestMapping(value = "budgetFiscal/addBudgetFiscal.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap addBudgetFiscal(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("yearStart",		request.getParameter("yearStart"));
			params.put("yearEnd",		request.getParameter("yearEnd"));

			resultList = budgetFiscalSvc.addBudgetFiscal(params);
			resultList.put("result", "ok");

			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	@RequestMapping(value = "budgetFiscal/getFiscalYearByDate.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFiscalYearByDate(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			params.put("executeDate",	request.getParameter("executeDate"));
			params.put("companyCode",	request.getParameter("companyCode"));

			resultList = budgetFiscalSvc.getFiscalYearByDate(params);
			
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
