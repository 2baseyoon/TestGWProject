package egovframework.covision.groupware.workreport.web;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkManageService;



@Controller
@RequestMapping("/workreport")
public class WorkManageCon {
	final static Object lock = new Object();
	
	@Autowired
	private WorkManageService workManageService;
	
	
	// [ 업무관리 START ] ---------------------------------------------------------------------------------
	@RequestMapping(value="addJob.do", method=RequestMethod.GET)
	public ModelAndView getAddGradePage(HttpServletRequest request) throws Exception {
		String returnUrl = "user/workreport/addJob";
		String mode = request.getParameter("mode");
		String jobID = request.getParameter("jobID");
		
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("mode", mode);
		mav.addObject("jobID", jobID);
		
		return mav;
	}
	
	@RequestMapping(value="WorkReportCateTypeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportCateTypeList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap params = new CoviMap();
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
				
		CoviMap listData = workManageService.getCateTypeList(params);
		
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="WorkReportCateDivList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportCateDivList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap params = new CoviMap();
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));

		CoviMap listData = workManageService.getCateDivList(params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	
	@RequestMapping(value="DuplicateWorkCate.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap checkWorkReportCate(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strCate = paramMap.get("cate");
		String strCode = paramMap.get("code");
		
		CoviMap params = new CoviMap();
		params.put("cate", strCate);
		params.put("code", strCode);
		
		int returnCnt = workManageService.checkDuplicateCode(params);
				
		returnObj.put("cnt", returnCnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="AddWorkReportCate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addWorkReportCate(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strCate = paramMap.get("cate");
		String strName = paramMap.get("name");
		String strCode = paramMap.get("code");
		
		CoviMap params = new CoviMap();
		params.put("cate", strCate);
		params.put("name", strName);
		params.put("code", strCode);
		
		int returnCnt = workManageService.insertWorkCategorie(params);
		
		returnObj.put("resultCnt", returnCnt);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="workreportdeletecate.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap deleteWorkReportCate(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strCate = paramMap.get("cate");
		String strCode = paramMap.get("code");
		
		CoviMap params = new CoviMap();
		params.put("cate", strCate);
		params.put("code", strCode);
		
		int returnCnt = workManageService.deleteCateCode(params);
				
		returnObj.put("cnt", returnCnt);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="getWorkReportDiv.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportDiv() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap listObj = workManageService.getCateDivList(new CoviMap());
		returnObj.put("list", listObj.get("list"));
		return returnObj;
	}
	
	@RequestMapping(value="getWorkReportType.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportType() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap listObj = workManageService.getCateTypeList(new CoviMap());
		returnObj.put("list", listObj.get("list"));
		return returnObj;
	}
	
	@RequestMapping(value="getWorkReportTypeSel.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportTypeSelList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = null;
		
		String code = paramMap.get("code");
		CoviMap params = new CoviMap();
		params.put("code", code);
		returnObj = workManageService.getCateTypeSelList(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="acceptworktype.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap acceptWorkType(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = null;
		
		String strDivCode = paramMap.get("seldiv");
		String strNewCode = paramMap.get("newcode");
		String strDelCode = paramMap.get("delcode");
		
		String[] arrNewCode = strNewCode.split(",");
		String[] arrDelCode = strDelCode.split(",");
		
		if(arrNewCode[0].equals(""))	arrNewCode = null;
		if(arrDelCode[0].equals(""))	arrDelCode = null;
		
		CoviMap params = new CoviMap();
		params.put("seldiv", strDivCode);
		params.put("newcode", arrNewCode);
		params.put("delcode", arrDelCode);
		
		returnObj = workManageService.setDivisionWorkType(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportjobwrite.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportJobWrite(@RequestParam Map<String, String> paramMap) throws Exception {
		
		String strJobName = paramMap.get("jobName");
		String strJobDivision = paramMap.get("jobDivision");
		String strUseYN = paramMap.get("useYN");
		String strManagerCode = paramMap.get("managerCode");
		String strStartDate = paramMap.get("startDate");
		String strEndDate = paramMap.get("endDate");
		
		// 세션정보
		String strCreatorCode = SessionHelper.getSession("UR_Code");
				
		CoviMap params = new CoviMap();
		params.put("jobName", strJobName);
		params.put("jobDivision", strJobDivision);
		params.put("useYN", strUseYN);
		params.put("managerCode", strManagerCode);
		params.put("creatorCode", strCreatorCode);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		
		// 서비스 호출
		int cnt = workManageService.insertWork(params);
		
		CoviMap resultObj = new CoviMap();
		resultObj.put("resultCnt", cnt);
		
		return resultObj;
	}
	
	// 전자결재 연동용
	@RequestMapping(value="workreportjobwrite_approval.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportJobWrite_Approval(@RequestBody Map<String, String> paramMap) throws Exception {
		
		CoviMap params = new CoviMap();
		params.putAll(paramMap);
		
		// 서비스 호출
		// Isolation 을 위해 번호 발번 및 채번을 하나의 서비스로 묶음. 2021.2.23 hgsong
		SimpleDateFormat format = new SimpleDateFormat("yyyy");				
		Calendar time = Calendar.getInstance();
		String year = format.format(time.getTime());
		params.put("year", year);
		
		String displayNumber = "";
		synchronized (lock) {
			displayNumber = workManageService.createWorkWithNumber(params);
		}
		
		CoviMap resultObj = new CoviMap();
		resultObj.put("result", displayNumber);
		
		return resultObj;
	}
	
	@RequestMapping(value="getworkjoblist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkJobList(HttpServletRequest request) throws Exception {
		// Parameters
		String strDivision = StringUtil.replaceNull(request.getParameter("division"), "");
		String strUseYN = StringUtil.replaceNull(request.getParameter("useyn"), "");
		String strSearchText = StringUtil.replaceNull(request.getParameter("searchtext"), "");
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = null;
		String strSortDirection = null;
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("division", strDivision);
		params.put("useyn", strUseYN);
		params.put("searchtext", ComUtils.RemoveSQLInjection(strSearchText, 100));
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = workManageService.selectWorkList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	
	@RequestMapping(value="workreportjobchangeuse.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap workReportJobChangeUse(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("jobid", paramMap.get("jobId"));
		params.put("useyn", paramMap.get("useYN"));
		
		int cnt = workManageService.changeUseYN(params); 
		
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="workreportjobdelete.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportJobDelete(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		String strDeleteIds = paramMap.get("deleteIds");
		
		CoviMap params = new CoviMap();
		params.put("deleteids", strDeleteIds.split(","));
		
		int cnt = 0;
		cnt = workManageService.deleteWorkJob(params);
		
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	
	@RequestMapping(value="workreportjobselectone.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap workReportJobSelectOne(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = null;
		String strJobId = paramMap.get("jobid");
		
		CoviMap params = new CoviMap();
		params.put("jobid", strJobId);
		
		returnObj = workManageService.selectOneWorkJob(params); 
						
		return returnObj;
	}
	
	
	
	@RequestMapping(value="workreportjobupdate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap workReportJobUpdate(@RequestParam Map<String, String> paramMap) throws Exception {
		
		String strJobName = paramMap.get("jobName");
		String strJobDivision = paramMap.get("jobDivision");
		String strUseYN = paramMap.get("useYN");
		String strManagerCode = paramMap.get("managerCode");
		String strJobId = paramMap.get("jobId");
		String strStartDate = paramMap.get("startDate");
		String strEndDate = paramMap.get("endDate");
		
		CoviMap params = new CoviMap();
		params.put("jobId", strJobId);
		params.put("jobName", strJobName);
		params.put("jobDivision", strJobDivision);
		params.put("useYN", strUseYN);
		params.put("managerCode", strManagerCode);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		
		// 서비스 호출
		int cnt = workManageService.updateWork(params);
		
		CoviMap resultObj = new CoviMap();
		resultObj.put("resultCnt", cnt);
		
		return resultObj;
	}
	
	
	
	@RequestMapping(value="getworkjob.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkJob(HttpServletRequest request) throws Exception {
		// Parameters
		String strDivision = StringUtil.replaceNull(request.getParameter("division"), "");
		String strUseYN = "Y";

		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("division", strDivision);
		params.put("useyn", strUseYN);
		params.put("searchtext", null);
		
		params.put("pageOffset", null);
		params.put("pageSize", null);
		
		params.put("sortColumn", "JobName");
		params.put("sortDirection", "ASC");
		
		CoviMap listData = workManageService.selectWorkList(params);
		
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	// [ 업무관리 END ] ---------------------------------------------------------------------------------
	
	
	@RequestMapping(value="InsertApproverSetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertApproverSetting(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		// Parameters
		String strURCode = request.getParameter("urCode");
		String strGRCode = request.getParameter("grCode");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("urCode", strURCode);
		params.put("grCode", strGRCode);
		
		CoviMap result = workManageService.insertApprover(params);
		
		
		returnObj.put("result", result);
		
		return returnObj;
	}
	
	@RequestMapping(value="GetApproverSetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getApproverSetting(HttpServletRequest request) throws Exception {
		// Parameters
		String strGRCode = StringUtil.replaceNull(request.getParameter("grCode"), "");
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = null;
		String strSortDirection = null;
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("grCode", strGRCode);		
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = workManageService.selectApproverList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	
	@RequestMapping(value="DeleteApproverSetting.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteApproverSetting(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		// Parameters
		String strDeleteList = StringUtil.replaceNull(request.getParameter("checkedStr"), "");
		String[] arrDeleteList = strDeleteList.split(",");
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("deleteList", arrDeleteList);
		
		int result = workManageService.deleteApprover(params);
		
		returnObj.put("result", result);
		
		return returnObj;
	}
}
