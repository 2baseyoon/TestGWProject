package egovframework.covision.groupware.biztask.user.web;

import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.biztask.user.service.BizTaskService;
import egovframework.covision.groupware.tf.user.service.TFUserSvc;
import egovframework.covision.groupware.util.BoardUtils;


/**
 * @Class Name : BizTaskCon.java
 * @Description : 통합업무관리 처리
 * @Modification Information 
 * @ 2019.10.08 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2019.10.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/biztask")
public class BizTaskCon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(BizTaskCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	BizTaskService biztaskSvc;
	
	@Autowired
	TFUserSvc tfSvc;
	
	//좌측 트리메뉴 조회
	@RequestMapping(value = "/getLeftProjectList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getLeftProjectList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		int index = 1;
		String userID = request.getParameter("userID") == null ? SessionHelper.getSession("USERID") : request.getParameter("userID");
		
		try {
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("userCode", userID); //관리자 체크용
			
			/* 관리자 권한 체크 - 주관부서 기준 상위부서 부서장일 경우  표시, 세션의 부서장 코드가 나 자신일 경우 또는 부서장일 경우 조회(추가)*/
			if(SessionHelper.getSession("UR_Code").equals(SessionHelper.getSession("UR_ManagerCode"))){
				params.put("isAdmin", "Y");
			}/*else{
				int adminCnt = projectSvc.selectProjectAdminCount(params);
				if(adminCnt > 0) {
					params.put("isAdmin", "Y");
				} else {
					params.put("isAdmin", "N");
				}
			}*/
			
			BoardUtils.setRequestParam(request, params);
			params.addAll(ComUtils.setPagingData(params, 1000));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			result = biztaskSvc.selectUserTFLeftGridList(params);
			
			//최상위 root 폴더 생성
			CoviMap rootFolder = new CoviMap();
			rootFolder.put("no", "0");
			rootFolder.put("nodeName", DicHelper.getDic("lbl_Project")); //프로젝트
			rootFolder.put("nodeValue", "0");
			rootFolder.put("pno", null);
			rootFolder.put("chk", "N");
			rootFolder.put("type", "Root");
			resultList.add(rootFolder); //최상위 폴더 추가
			
			CoviList ProjectStatus = RedisDataUtil.getBaseCode("TFDetailState"); //프로젝트 상태
			
			for (int i=0; i< ProjectStatus.size(); i++) {
				if(ProjectStatus.getJSONObject(i).getString("Code").equalsIgnoreCase("TFDetailState") ) continue;
				
				CoviMap projectFolder = new CoviMap();
				projectFolder.put("no", ProjectStatus.getJSONObject(i).getString("Code"));
				projectFolder.put("nodeName", DicHelper.getDicInfo(ProjectStatus.getJSONObject(i).getString("MultiCodeName"),params.get("lang").toString())); //진행
				projectFolder.put("nodeValue", ProjectStatus.getJSONObject(i).getString("Code"));
				projectFolder.put("pno", null);
				projectFolder.put("chk", "N");
				projectFolder.put("type", "Folder");
				projectFolder.put("PrjMode", ProjectStatus.getJSONObject(i).getString("Code"));
				resultList.add(projectFolder);
				index++;
			}
			
			// 협업 룸 전체목록 트리 추가
			CoviMap projectFolder = new CoviMap();
			projectFolder.put("no", "");
			projectFolder.put("nodeName", DicHelper.getDic("lbl_collaboration_alll"));
			projectFolder.put("nodeValue", "");
			projectFolder.put("pno", null);
			projectFolder.put("chk", "N");
			projectFolder.put("type", "Folder");
			projectFolder.put("PrjMode", "");
			resultList.add(projectFolder);
			
			for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				//세션사용자 등록 프로젝트만 조회
				folderData.put("no", index);//folderData.getString("PrjCode")
				folderData.put("nodeName", folderData.getString("CommunityName"));
				folderData.put("nodeValue", folderData.getString("CU_Code"));
				folderData.put("pno", folderData.getString("AppStatus"));
				folderData.put("chk", "N");
				folderData.put("type", "project");
				
				resultList.add(folderData);
				index++;
			}
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value="/getMyTaskList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getTaskReportDailyList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("userCode", paramMap.get("userCode"));
		params.put("searchText", paramMap.get("searchText"));
		
		CoviMap resultObj = biztaskSvc.getMyTaskList(params);
		
		returnObj.put("ProjectTaskList", resultObj.get("ProjectTaskList"));
		returnObj.put("TaskList", resultObj.get("TaskList") );
		
		return returnObj;
	}
	
	@RequestMapping(value="/getAllMyTaskList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getAllTaskMyTaskList(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("userCode", paramMap.get("userCode"));
		params.put("stateCode", paramMap.get("stateCode"));
		
		CoviMap resultObj = biztaskSvc.getAllMyTaskList(params);
		
		returnObj.put("ProjectTaskList", resultObj.get("ProjectTaskList"));
		returnObj.put("TaskList", resultObj.get("TaskList"));
		
		return returnObj;
	}
	
	//간트차트 iframe url 이동처리
	@RequestMapping(value = "/goProjectGanttView.do", method = RequestMethod.GET)
	public ModelAndView goProjectGanttByPrjCode(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/biztask/ProjectGanttView";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	//간트차트조회
	@RequestMapping(value = "/getProjectGanttList.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap getProjectGanttList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("ProjectCode", request.getParameter("ProjectCode"));
			params.put("CU_ID", request.getParameter("ProjectCode"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			resultList = biztaskSvc.getGanttList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("memberlist", resultList.get("memberlist"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//관리 팀 및 멤버 조회
	@RequestMapping(value="getMyTeams.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getMyTeams(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", paramMap.get("userCode"));
			
			CoviMap resultList = biztaskSvc.getMyTeams(params);
			returnList.put("MyTeamList", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//프로젝트/Task 요약정보 조회
	@RequestMapping(value="getMyTeamProjectSummary.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getMyTeamProjectSummary(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("deptCode", paramMap.get("deptCode"));
			params.put("userCode", SessionHelper.getSession("UR_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			CoviMap resultList = biztaskSvc.getMyTeamProjectSummary(params);
			returnList.put("projectlist", resultList.get("projectlist"));
			returnList.put("tasklist", resultList.get("tasklist"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//포탈 > 프로젝트 현황 조회
	@RequestMapping(value = "getHomeProjectListData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getHomeProjectListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("deptCode", paramMap.get("deptCode"));
			params.put("mode", paramMap.get("mode"));
			params.put("userCode", SessionHelper.getSession("UR_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = biztaskSvc.selectMyTeamProjectSummaryListCNT(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = biztaskSvc.selectMyTeamProjectSummaryList(params);
			
			returnList.put("page", params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "/goRelationDocumentRegistPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goRelationDocumentRegistPopup() throws Exception {
		String returnURL = "user/biztask/RelationDocumentRegistPopup";
		return new ModelAndView(returnURL);
	}
	
	//포탈 > 예고업무조회
	@RequestMapping(value = "getMyPreTaskList.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getMyPreTaskList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("ownerCode", paramMap.get("ownerCode"));
			params.put("currentDate", paramMap.get("currentDate"));
			
			int cnt = biztaskSvc.selectMyPreTaskListCNT(params);
			
			resultList = biztaskSvc.selectMyPreTaskList(params);
			
			returnList.put("count", cnt);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * deletePreTask - 예고업무 삭제
	 * @param preTaskID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "deleteMyPreTask.do",  method =RequestMethod.POST)
	public @ResponseBody CoviMap deleteMyPreTask(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("preTaskID", paramMap.get("preTaskID"));
			
			biztaskSvc.deleteMyPreTask(params);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/*
	 * sendMessaging : 일별 예고업무 자동생성
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "setPreTaskSchedule.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setPreTaskSchedule(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//처리
			CoviMap params = new CoviMap();
			
			//WAS 서버 기준으로 데이터 생성함
			params.put("startDate", StringUtil.getNowDate("yyyy-MM-dd") + " 00:00:00");
			params.put("endDate", StringUtil.getNowDate("yyyy-MM-dd") + " 23:59:59");
			
			//timezone 적용 날짜변환
			/*if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}*/
			
			biztaskSvc.setPreTaskSchedule(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "성공적으로 생성되었습니다");
		} catch (NullPointerException ex) {
			//LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			//LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/*
	 * sendMessaging : 일별 예고업무 자동삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "deletePreTaskSchedule.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deletePreTaskSchedule(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//처리
			CoviMap params = new CoviMap();
			
			//WAS 서버 기준으로 데이터 생성함
			params.put("currentDate", StringUtil.getNowDate("yyyy-MM-dd") + " 00:00:00");
			
			//timezone 적용 날짜변환
			/*if(params.get("currentDate") != null && !params.get("currentDate").equals("")){
				params.put("currentDate",ComUtils.TransServerTime(params.get("currentDate").toString() + " 00:00:00"));
			}
			*/
			
			biztaskSvc.deletePreTaskSchedule(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "성공적으로 생성되었습니다");
		} catch (NullPointerException ex) {
			//LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			//LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "ProjectDetailStatus.do", method=RequestMethod.GET)
	public ModelAndView getWorkPortal(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "user/biztask/ProjectDetailStatus";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "getBizTaskPortalData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizTaskPortalData(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", paramMap.get("userCode"));
			params.put("stateCode", paramMap.get("stateCode"));
			params.put("sYear", paramMap.get("sYear"));
			
			CoviMap resultObj = new CoviMap();
			
			if("Project".equals(paramMap.get("type"))){ 
				resultObj = biztaskSvc.selectPortalMyActivityList(params);
			}else if("Work".equals(paramMap.get("type"))){
				resultObj = biztaskSvc.selectPortalMyTaskList(params);
			}
			
			returnList.put("list", resultObj.getJSONArray("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.debug(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "getBizTaskPortalGraphData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizTaskPortalGraphData(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", paramMap.get("userCode"));
			params.put("sYear", paramMap.get("sYear"));
			CoviMap resultObj = new CoviMap(); 
			
			if("Project".equals(paramMap.get("type"))){
				resultObj = biztaskSvc.selectPortalMyActivityGraph(params);
			}else if("Work".equals(paramMap.get("type"))){
				resultObj = biztaskSvc.selectPortalMyTaskGraph(params);
			}
			
			returnList.put("list", resultObj.getJSONArray("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
