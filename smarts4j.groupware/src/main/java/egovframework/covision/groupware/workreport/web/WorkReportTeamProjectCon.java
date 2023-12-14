package egovframework.covision.groupware.workreport.web;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.workreport.service.WorkReportTeamProjectService;




@Controller
@RequestMapping("/workreport")
public class WorkReportTeamProjectCon {
	
	@Autowired
	private WorkReportTeamProjectService workReportTeamProjectService;
	
	@RequestMapping(value="workreportteamproject.do", method=RequestMethod.GET)
	public ModelAndView workReportTeamProject() throws Exception {
		String returnUrl = "workreport/teamproject.workreport";
		
		String sessionUR_Code = SessionHelper.getSession("UR_Code");
		String sessionGR_Code = SessionHelper.getSession("GR_Code");
		String sessionGR_Name = SessionHelper.getSession("GR_Name");
		// MARK 권한 확인 
		
		// 확인여부 전달
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("gr_code", sessionGR_Code);
		mav.addObject("gr_name", sessionGR_Name);
		
		return mav;
	}
	
	
	@RequestMapping(value="getWorkReportTeamProject.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportTeamProject(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String pGR_Code = paramMap.get("grcode");
		String pStartDate = paramMap.get("startDate");
		String pEndDate = paramMap.get("endDate");
		
		CoviMap params = new CoviMap();
		params.put("grcode", pGR_Code);
		params.put("startDate", pStartDate);
		params.put("endDate", pEndDate);
		
		CoviList resultList = workReportTeamProjectService.getWorkReportTeamProject(params);
		
		returnObj.put("list", resultList);
		
		return returnObj;
	}
	
	@RequestMapping(value="getWorkReportTeamProjectSummary.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportTeamProjectSummary(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String pGR_Code = paramMap.get("grcode");
		String pStartDate = paramMap.get("startDate");
		String pEndDate = paramMap.get("endDate");
		
		CoviMap params = new CoviMap();
		params.put("grcode", pGR_Code);
		params.put("startDate", pStartDate);
		params.put("endDate", pEndDate);
		
		CoviList resultList = workReportTeamProjectService.getWorkReportTeamProjectSummary(params);
		
		returnObj.put("list", resultList);
		
		return returnObj;
	}
	
	@RequestMapping(value="chartTeamProject.do", method=RequestMethod.GET)
	public ModelAndView chartTeamProject(@RequestParam Map<String, String> paramMap) throws Exception {
		String strReturnUrl = "user/workreport/chart/teamprojectchart";
		ModelAndView mav = new ModelAndView(strReturnUrl);
		
		String pGR_Code = paramMap.get("grcode");
		String pStartDate = paramMap.get("startDate");
		String pEndDate = paramMap.get("endDate");
		
		
		mav.addObject("grCode", pGR_Code);
		mav.addObject("startDate", pStartDate);
		mav.addObject("endDate", pEndDate);
		
		return mav;
	}
	
}
