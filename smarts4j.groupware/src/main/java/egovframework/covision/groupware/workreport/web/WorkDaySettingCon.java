package egovframework.covision.groupware.workreport.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;



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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkDaySettingService;


@Controller
@RequestMapping("/workreport")
public class WorkDaySettingCon {

	Logger LOGGER = LogManager.getLogger(WorkDaySettingCon.class);
	
	@Autowired
	private WorkDaySettingService workDaySettingService;
	
	
	
	// [ 업무보고 기준일 START ] ---------------------------------------------------------------------------------  
	
	// 업무보고 기준일 리스트 조회
	@RequestMapping(value="GetWorkDaySetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap GetWorkDaySetting(HttpServletRequest request) throws Exception{		
		
		// Parameters
		String strYear = StringUtil.replaceNull(request.getParameter("year"), "");
		
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("year", strYear);		
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = workDaySettingService.selectList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();	
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	
	@RequestMapping(value="InsertWorkDaySetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap InsertWorkDaySetting(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strYear = paramMap.get("year");
		String strMonth = paramMap.get("month");
		String strWorkDay = paramMap.get("workDay");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		params.put("month", strMonth);
		params.put("workDay", strWorkDay);
		
		CoviMap result = workDaySettingService.insert(params);
		
		
		returnObj.put("result", result);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="UpdateWorkDaySetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap UpdateWorkDaySetting(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strYear = paramMap.get("year");
		String strMonth = paramMap.get("month");
		String strWorkDay = paramMap.get("workDay");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		params.put("month", strMonth);
		params.put("workDay", strWorkDay);
		
		int returnCnt = workDaySettingService.update(params);
		
		
		returnObj.put("resultCnt", returnCnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="DeleteWorkDaySetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap DeleteWorkDaySetting(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strChecked = paramMap.get("checkedStr");
		String[] arrChecked = strChecked.split(",");
		
		CoviMap params = new CoviMap();
		params.put("checked", arrChecked);
		
		int returnCnt = workDaySettingService.delete(params);
		
		
		returnObj.put("resultCnt", returnCnt);
		
		return returnObj;
	}
	
	// [ 업무보고 기준일 END ] ---------------------------------------------------------------------------------
}
