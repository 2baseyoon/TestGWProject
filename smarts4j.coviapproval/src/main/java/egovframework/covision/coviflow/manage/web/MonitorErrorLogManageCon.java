package egovframework.covision.coviflow.manage.web;


import java.util.Map;
import java.util.Objects;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MonitorErrorLogSvc;

@Controller
public class MonitorErrorLogManageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(MonitorErrorLogManageCon.class);
	
	@Autowired
	private MonitorErrorLogSvc monitorErrorLogSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getMonitorErrorLog : 엔진 오류 로그 - 엔진 오류 로그 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getMonitorErrorLog.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMonitorErrorLog(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String txtSDate = request.getParameter("txtSDate");			
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("txtSDate", txtSDate);			
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("EntCode", paramMap.get("EntCode"));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = monitorErrorLogSvc.getMonitorErrorLog(params);

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
	
	@RequestMapping(value = "manage/deleteErrorLog.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteErrorLog(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String errorID = request.getParameter("errorID");
			
			CoviMap params = new CoviMap();
			params.put("errorID", errorID);			
			monitorErrorLogSvc.deleteErrorLog(params);
			
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
}
