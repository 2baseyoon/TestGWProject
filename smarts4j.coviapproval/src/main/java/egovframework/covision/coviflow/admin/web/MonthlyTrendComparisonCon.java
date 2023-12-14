package egovframework.covision.coviflow.admin.web;


import java.net.URLDecoder;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MonthlyTrendComparisonSvc;

@Controller
public class MonthlyTrendComparisonCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(MonthlyTrendComparisonCon.class);
	
	@Autowired
	private MonthlyTrendComparisonSvc monthlyTrendComparisonSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getMonthlyDeptList : 유형별 건수 - 부서별 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getMonthlyDeptList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMonthlyDeptList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String entCode = request.getParameter("EntCode");
			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = monthlyTrendComparisonSvc.getMonthlyDeptList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getMonthlyFormList : 유형별 건수 - 양식별 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getMonthlyFormList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMonthlyFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String entCode = request.getParameter("EntCode");
			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = monthlyTrendComparisonSvc.getMonthlyFormList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getMonthlyPersonList : 유형별 건수 - 개인별조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getMonthlyPersonList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMonthlyPersonList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String entCode = request.getParameter("EntCode");
			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = monthlyTrendComparisonSvc.getMonthlyPersonList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}	
	
	// 엑셀 다운로드
	@RequestMapping(value = "admin/monthlyTrendComparisonExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView monthlyTrendComparisonExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		try {
			String radioval = request.getParameter("radioval");
			String entCode = request.getParameter("EntCode");			
			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");		
			String sortKey = request.getParameter("sortKey");
			String sortWay = request.getParameter("sortWay");
			String headerName = URLDecoder.decode(request.getParameter("headerName"), "UTF-8");
			String[] headerNames = headerName.split(";");
			String lang = SessionHelper.getSession("lang");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("pageNo", 1);
			params.put("pageSize", Integer.MAX_VALUE);
			params.put("radioval", radioval);
			params.put("EntCode", entCode);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortWay, 100));
			params.put("lang", lang);
			
			if("GetDept".equals(radioval)){
				resultList = monthlyTrendComparisonSvc.getMonthlyDeptList(params);
			}else if("GetForm".equals(radioval)){
				resultList = monthlyTrendComparisonSvc.getMonthlyFormList(params);
			}else{
				resultList = monthlyTrendComparisonSvc.getMonthlyPersonList(params);
			}				
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "MonthlyTrendComparison");
			
			mav = new ModelAndView(returnURL, viewParams);			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}	
		return mav;
	}	
}
