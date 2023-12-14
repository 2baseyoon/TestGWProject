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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AffiliatesAggregateInformationSvc;

@Controller
public class AffiliatesAggregateInformationCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(AffiliatesAggregateInformationCon.class);
	
	@Autowired
	private AffiliatesAggregateInformationSvc affiliatesAggregateInformationSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
	/**
	 * getEntCountList : 계열사별 집계정보 보기 - 부서별 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getEntCountList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntCountList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
					
			CoviMap resultList = null;
			
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			if (isSaaS.equalsIgnoreCase("Y") && !egovframework.baseframework.util.SessionHelper.getSession("DN_ID").equalsIgnoreCase("0")){
				params.put("companyCode", egovframework.baseframework.util.SessionHelper.getSession("DN_Code"));
			}
			
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = affiliatesAggregateInformationSvc.getEntCountList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}  catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	
	/**
	 * getEntMonthlyCountList : 계열사별 집계정보 보기  - 양식별 월별 집계
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getEntMonthlyCountList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntMonthlyCountList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));

			if (isSaaS.equalsIgnoreCase("Y") && !egovframework.baseframework.util.SessionHelper.getSession("DN_ID").equalsIgnoreCase("0")){
				params.put("companyCode", egovframework.baseframework.util.SessionHelper.getSession("DN_Code"));
			}			
			resultList = affiliatesAggregateInformationSvc.getEntMonthlyCountList(params);
			
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
	@RequestMapping(value = "admin/affiliatesAggregateInformationExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView affiliatesAggregateInformationExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			String radioval = request.getParameter("radioval");
			String startDate = request.getParameter("startDate");			
			String endDate = request.getParameter("endDate");
			String compareItem = request.getParameter("CompareItem");
			String year = request.getParameter("Year");
			String sortKey = request.getParameter("sortKey");
			String sortWay = request.getParameter("sortWay");
			String headerName = URLDecoder.decode(request.getParameter("headerName"), "UTF-8");
			String[] headerNames = headerName.split(";");
			
			CoviMap params = new CoviMap();
			params.put("pageNo", 1);
			params.put("pageSize", Integer.MAX_VALUE);
			params.put("radioval", radioval);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("CompareItem", ComUtils.RemoveSQLInjection(compareItem, 100));
			params.put("Year", year);	
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));

			if (isSaaS.equalsIgnoreCase("Y") && !egovframework.baseframework.util.SessionHelper.getSession("DN_ID").equalsIgnoreCase("0")){
				params.put("companyCode", egovframework.baseframework.util.SessionHelper.getSession("DN_Code"));
			}			
			
			if("GetDept".equals(radioval)){
				resultList = affiliatesAggregateInformationSvc.getEntCountList(params);
			}else if("GetForm".equals(radioval)){
				resultList = affiliatesAggregateInformationSvc.getEntMonthlyCountList(params);
			}
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("headerName", headerNames);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		viewParams.put("title", "AffiliatesAggregateInformation");
		return new ModelAndView(returnURL, viewParams);
	}	
}
