package egovframework.covision.groupware.workreport.web;

import java.util.Map;
import java.util.StringTokenizer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.workreport.service.WorkReportProjectCostService;



@Controller
@RequestMapping("/workreport")
public class WorkReportProjectCostManage {
	
	@Autowired
	private WorkReportProjectCostService workReportProjectCostService;
	
	@RequestMapping(value="workreportgetmanageprj.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getManageProject() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String sessionUR_Code = SessionHelper.getSession("UR_Code");
		String sessionGR_Code = SessionHelper.getSession("GR_Code");
		String strDivCodes = RedisDataUtil.getBaseConfig("ManageWorkCode");
		String strManagerList = RedisDataUtil.getBaseConfig("TempWorkReportManager");	// 임시 관리자 여부
		
		String strIsManager = "N";
		
		StringTokenizer stringTokenizer = new StringTokenizer(strManagerList, "|");
		
		while(stringTokenizer.hasMoreTokens()) {
			String strCode = stringTokenizer.nextToken();
			
			String[] arrCode = strCode.split(":");
			
			if(arrCode.length == 2) {
				if(arrCode[0].equalsIgnoreCase("UR")) {
					if(arrCode[1].equalsIgnoreCase(sessionUR_Code)){
						strIsManager = "Y";
						break;
					}
				} else if (arrCode[0].equalsIgnoreCase("GR")) {
					if(arrCode[1].equalsIgnoreCase(sessionGR_Code)){
						strIsManager = "Y";
						break;
					}
				}
			}
		}
		
		String[] arrDivCodes = strDivCodes.split("[|]");
		
		CoviMap params = new CoviMap();
		params.put("userCode", sessionUR_Code);
		params.put("divs", arrDivCodes);
		params.put("isManager", strIsManager);
		
		
		CoviList liProject = workReportProjectCostService.selectManageProject(params);
		
		returnObj.put("list", liProject);
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportgetprojectcost.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getProjectCost(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strJobID = paramMap.get("JobID");
		String strStartDate = paramMap.get("StartDate");
		String strEndDate = paramMap.get("EndDate");
		
		CoviMap params = new CoviMap();
		params.put("jobId", strJobID);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		
		CoviList list = workReportProjectCostService.selectProjectCost(params);
		
		returnObj.put("resultList", list);
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportgetprojectcostos.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getProjectCostOS(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strJobID = paramMap.get("JobID");
		String strStartDate = paramMap.get("StartDate");
		String strEndDate = paramMap.get("EndDate");
		
		CoviMap params = new CoviMap();
		params.put("jobId", strJobID);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		
		CoviList list = workReportProjectCostService.selectProjectCostOS(params);
		
		returnObj.put("resultList", list);
		
		return returnObj;
	}
}
