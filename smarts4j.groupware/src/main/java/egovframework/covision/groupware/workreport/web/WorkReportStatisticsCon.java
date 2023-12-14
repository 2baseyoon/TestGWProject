package egovframework.covision.groupware.workreport.web;


import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
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
import egovframework.covision.groupware.workreport.service.WorkReportStatisticsService;




@Controller
@RequestMapping("/workreport")
public class WorkReportStatisticsCon {

	@Autowired
	private WorkReportStatisticsService workreportstatisticsService;
	
	
	@RequestMapping(value="workreportreportbyteam.do", method=RequestMethod.GET)
	public ModelAndView workreportreportByTeam() throws Exception {
		String returnUrl = "workreport/reportbyteam.workreport";
		
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
	
	@RequestMapping(value="getProjectList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getProjectList() throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		CoviMap listObj = workreportstatisticsService.getProjectList(params);

		returnObj.put("list", listObj.get("list"));
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getStatisticsProject.do", method=RequestMethod.GET , produces="application/json; charset=utf8")
	public @ResponseBody CoviMap getStatisticsProject(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		String jobID = paramMap.get("jobID");
		String startDate = paramMap.get("startdate") + "-01";
		String endDate = paramMap.get("enddate") + "-01";
		String grcode = paramMap.get("grcode");
		
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		
		Date date = df.parse(startDate);
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		
		int sYear = Integer.parseInt(startDate.substring(0,4));
		int sMonth = Integer.parseInt(startDate.substring(5,7));
		int eYear = Integer.parseInt(endDate.substring(0,4)); 
		int eMonth = Integer.parseInt(endDate.substring(5,7)); 

		int month_diff = (eYear - sYear)* 12 + (eMonth - sMonth) + 1; 
		
		String months[] = new String[month_diff];
		String smonths = "";
		
		int tYear = 0;
		int tMonth = 0;
		StringBuffer buf = new StringBuffer();
		for(int i=0; i<month_diff ; i++){	
			
			tYear = cal.get(Calendar.YEAR);
			tMonth = cal.get(Calendar.MONTH) + 1;
			
			months[i] = "M" + tYear + "" + (tMonth < 10 ? "0" + tMonth : tMonth);
			buf.append(months[i]).append(";");
			cal.add(Calendar.MONTH,1);		
		}
		smonths = buf.toString();
		smonths = smonths.substring(0,smonths.length()-1);
		
		params.put("jobID", jobID);
		params.put("months", months);
		params.put("smonths", smonths.replace(";", ","));
		params.put("grcode", grcode);
		
		CoviMap listObj = workreportstatisticsService.getStatisticsProject(params);
		
		returnObj.put("list", listObj.get("list"));
		returnObj.put("months", smonths);

		return returnObj;
	}
	
	@RequestMapping(value="getJobTypeList.do", method=RequestMethod.GET , produces="application/json; charset=utf8")
	public @ResponseBody CoviMap getJobTypeList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		String gr_code = paramMap.get("gr_code");
		String startDate = paramMap.get("startdate");
		String endDate = paramMap.get("enddate");

		params.put("gr_code", gr_code);
		params.put("startdate", startDate);
		params.put("enddate", endDate);
		
		CoviMap listObj = workreportstatisticsService.getJobTypeList(params);

		returnObj.put("list", listObj.get("list"));
		return returnObj;
	}
	

	@RequestMapping(value="getSumHourList.do", method=RequestMethod.GET , produces="application/json; charset=utf8")
	public @ResponseBody CoviMap getSumHourList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();

		String gr_code = paramMap.get("gr_code");
		String typecodes = paramMap.get("typecodes");
		String startDate = paramMap.get("startdate");
		String endDate = paramMap.get("enddate");
			
		String sTypeCodes[] = typecodes.split(";");
		
		params.put("gr_code", gr_code);
		params.put("startdate", startDate);
		params.put("enddate", endDate);
		params.put("typecodes", sTypeCodes);
	
		CoviMap listObj = workreportstatisticsService.getSumHourList(params);
	
		returnObj.put("list", listObj.get("list"));
		return returnObj;
	}

	
	@RequestMapping(value="chartReportByTeam.do", method=RequestMethod.GET)
	public ModelAndView chartReportByTeam(@RequestParam Map<String, String> paramMap) throws Exception {
		String returnUrl = "user/workreport/chart/chartreportbyteam";
		ModelAndView mav = new ModelAndView(returnUrl);
		
		String gr_code = paramMap.get("gr_code");
		String startDate = paramMap.get("startdate");
		String endDate = paramMap.get("enddate");
		
		mav.addObject("grCode", gr_code);
		mav.addObject("startDate", startDate);
		mav.addObject("endDate", endDate);
		
		return mav;
	}
	
	
	@RequestMapping(value="workreportgetprojecttime.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getProjectCost(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strJobID = paramMap.get("JobID");
		String strStartDate = paramMap.get("StartDate");
		String strEndDate = paramMap.get("EndDate");
		
		CoviMap params = new CoviMap();
		params.put("jobId", strJobID);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		
		CoviList list = workreportstatisticsService.selectProjectTime(params);
		
		returnObj.put("resultList", list);
		
		return returnObj;
	}
	
}
