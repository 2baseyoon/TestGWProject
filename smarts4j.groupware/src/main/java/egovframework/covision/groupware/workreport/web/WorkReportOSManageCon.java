package egovframework.covision.groupware.workreport.web;

import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkReportOSManageService;





/**
 * @Class Name : WorkReportOSManageCon.java
 * @Description : 업무보고 외주직원 관리
 * @Modification Information 
 * @ 2017.05.11 최초생성
 *
 * @author 코비젼 협업팀
 * @since 2017.05.11
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/workreport")
public class WorkReportOSManageCon {
	
	@Autowired
	private WorkReportOSManageService workReportOSManageService;
	
	@RequestMapping(value="registOS.do", method=RequestMethod.GET)
	public ModelAndView getAddGradePage(HttpServletRequest request) throws Exception {
		String returnUrl = "user/workreport/registOS";
		String mode = request.getParameter("mode");
		String urcode = request.getParameter("urcode");
		
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("mode", mode);
		mav.addObject("urcode", urcode);
		
		return mav;
	}
	
	@RequestMapping(value="getoutsourcinglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOutSourcingGrade(HttpServletRequest request) throws Exception {
	
		String strStartDate = request.getParameter("startdate");
		String strEndDate = request.getParameter("enddate");
		String strEndContract = request.getParameter("isendcontract");
		String strOSName = request.getParameter("osname");
		
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = null;
		String strSortDirection = null;
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		
		CoviMap params = new CoviMap();
		params.put("startdate", strStartDate);
		params.put("enddate", strEndDate);
		params.put("isendcontract", strEndContract);		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("osName", strOSName);
		
		CoviMap listData = workReportOSManageService.selectOutSourcing(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportoutsourcingset.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportOSSet(@RequestParam Map<String, String> paramMap) throws Exception {
		
		String strMode = paramMap.get("mode");
		String strURCode = paramMap.get("urcode");
		String strName = paramMap.get("name");
		String strGrade = paramMap.get("grade");
		String strAge = paramMap.get("age");
		String strFirstManagerCode = paramMap.get("fmCode");
		String strFirstManagerName = paramMap.get("fmName");
		String strSecondManagerCode = paramMap.get("smCode");
		String strSecondManagerName = paramMap.get("smName");
		String strJobNames = paramMap.get("jobName");
		String strRole = paramMap.get("role");
		String strStatus = paramMap.get("status");
		String strStartDate = paramMap.get("startdate");
		String strEndDate = paramMap.get("enddate");
		String strExPrjYN = paramMap.get("exPrjYn");
		
		
		if(strAge == null ) strAge = "";
		if(strSecondManagerName == null ) strSecondManagerName = "";
		if(strRole == null ) strRole = "";
		
		
		// 세션정보
		String strCreatorCode = SessionHelper.getSession("USERID");
				
		CoviMap params = new CoviMap();
		params.put("mode", strMode);
		params.put("urcode",strURCode);
		params.put("name", strName);
		params.put("grade", strGrade);
		params.put("age", strAge);
		params.put("fmCode", strFirstManagerCode);
		params.put("fmName", strFirstManagerName);
		params.put("smCode", strSecondManagerCode);
		params.put("smName", strSecondManagerName);
		params.put("jobName", strJobNames);
		params.put("role", strRole);
		params.put("status", strStatus);
		params.put("startdate", strStartDate);
		params.put("enddate", strEndDate);
		params.put("creatorCode", strCreatorCode);
		params.put("exprojectyn", strExPrjYN);
				
		// 서비스 호출	
		CoviMap resultObj = new CoviMap();
		resultObj = workReportOSManageService.setOutSourcing(params);
		
		return resultObj;
	}
	
	@RequestMapping(value="getOSGradeList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getOSGradeList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = null;
		
		CoviMap params = new CoviMap();
		
		returnObj = workReportOSManageService.selectOSGrade(params);
		
		return returnObj;
	}
	

	@RequestMapping(value="getOutsourcingDetail.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getOutsourcingDetail(HttpServletRequest request) throws Exception {
		CoviMap returnObj = null;
		
		String strURCode = request.getParameter("urcode");

		CoviMap params = new CoviMap();
		params.put("ur_code", strURCode);

		returnObj = workReportOSManageService.selectOurSourcingDetail(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportosdelete.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteOutSourcing(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strDeleteIds = paramMap.get("deleteIds");
		
		CoviMap params = new CoviMap();
		params.put("our_code", strDeleteIds.split(","));
		
		int cnt = 0;
		cnt = workReportOSManageService.deleteOutSourcing(params);
		
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getOSCalendarInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getOSCalendarInfo(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strOUR_Code = paramMap.get("OUR_Code");
		
		CoviMap params = new CoviMap();
		params.put("our_code", strOUR_Code);
		
		CoviList result = workReportOSManageService.selectOSCalendarInfo(params);
		
		returnObj.put("result", result);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getoutsourcingmanagelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOutSourcingManageList(HttpServletRequest request) throws Exception {
		
		String strStartDate = request.getParameter("startdate");
		String strEndDate = request.getParameter("enddate");
		String strEndContract = request.getParameter("isendcontract");
		String strOSName = request.getParameter("osname");
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = null;
		String strSortDirection = null;
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// 임시 - 관리자
		String strManagerList = RedisDataUtil.getBaseConfig("TempWorkReportManager");
		boolean isViewManager = false;
		
		String grCode = SessionHelper.getSession("GR_Code");
		String urCode = SessionHelper.getSession("UR_Code");
		String jobTitleCode = SessionHelper.getSession("UR_JobTitleCode");
		
		StringTokenizer stringTokenizer = new StringTokenizer(strManagerList, "|");
		
		// 관리자 권한 확인
		while(stringTokenizer.hasMoreTokens()) {
			String strCode = stringTokenizer.nextToken();
			
			String[] arrCode = strCode.split(":");
			
			if(arrCode.length == 2) {
				if(arrCode[0].equalsIgnoreCase("UR")) {
					if(arrCode[1].equalsIgnoreCase(urCode)){
						isViewManager = true;
						break;
					}
				} else if (arrCode[0].equalsIgnoreCase("GR")) {
					if(arrCode[1].equalsIgnoreCase(grCode)){
						isViewManager = true;
						break;
					}
				}
			}
		}
		
		CoviMap params = new CoviMap();
		params.put("startdate", strStartDate);
		params.put("enddate", strEndDate);
		params.put("isendcontract", strEndContract);
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("currentUser", urCode);
		params.put("isManager", isViewManager ? "Y" : "N");		
		params.put("osName", strOSName);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = workReportOSManageService.selectOutSourcingManage(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
}
