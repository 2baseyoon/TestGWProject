package egovframework.covision.groupware.bizreport.user.service.impl;

import java.util.Iterator;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.bizreport.user.service.BizReportService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import egovframework.baseframework.util.json.JSONSerializer;

@Service("BizReportService")
public class BizReportServiceImpl extends EgovAbstractServiceImpl implements BizReportService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	// 업무보고 프로젝트셀렉트박스by userCd
	public CoviMap getMyProject(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.bizreport.selectMyProject", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProjectCode,ProjectName"));
		
		return resultList;
	}
	
	//업무보고 목록조회
	public CoviMap getTaskReportDailyListAll(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList activityList = coviMapperOne.list("user.bizreport.selectProjectTaskReportDailyListAll", params);
		CoviList folderList = coviMapperOne.list("user.bizreport.selectFolderReportDailyListAll", params);
		CoviList taskList = coviMapperOne.list("user.bizreport.selectTaskReportDailyListAll", params);
		CoviList reportList = coviMapperOne.list("user.bizreport.selectGReportDailyListAll", params);
		
		resultList.put("ProjectTaskList", coviSelectJSONForTaskList(activityList, "ReportID,TaskID,ProjectCode,CommunityName,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("FolderList", coviSelectJSONForTaskList(folderList, "ReportID,TaskID,ProjectCode,DisplayName,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("TaskList", coviSelectJSONForTaskList(taskList, "ReportID,TaskID,ProjectCode,Subject,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("ReportList", coviSelectJSONForTaskList(reportList, "ReportID,TaskID,ProjectCode,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		
		return resultList;
	}
	
	// 업무보고 > 업무수정
	public int updateTaskReport(CoviMap params) throws Exception {
		return (int) coviMapperOne.update("user.bizreport.updateTaskReport", params);
	}
	
	// 업무보고 > 업무삭제
	public boolean deleteTaskReport(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("user.bizreport.deleteTaskReport", params);
		if(cnt > 0){
			flag = true;
		}else{
			flag = false;
		}
		
		return flag;
	}
	
	//일일보고등록 > 등록 및 수정
	public int insertTaskReportDaily(CoviMap params) throws Exception {	
		CoviList insertJa = (CoviList) JSONSerializer.toJSON(params.getString("insertData"));
		CoviList updateJa = (CoviList) JSONSerializer.toJSON(params.getString("updateData"));
		CoviList deleteJa = (CoviList) JSONSerializer.toJSON(params.getString("deleteData"));
		
		int m_jaSize = insertJa.size();
		for (int i=0; i<m_jaSize; i++) {
			CoviMap jo = insertJa.getJSONObject(i);
			params.put("PjtCode", jo.getString("strPrjCode"));
			params.put("TaskCode", jo.getString("strTaskIDX"));
			params.put("TaskName", jo.getString("strTaskName"));
			params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", jo.getString("strTaskHour"));
			params.put("TaskStatusCode", jo.getString("strTaskStatusCode"));
			params.put("TaskPercent", jo.getString("strTaskPercent"));
			params.put("TaskEtc", jo.getString("strTaskEtc"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("DEPTID"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", jo.getString("TaskGubunCode"));
			
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
		
		m_jaSize = updateJa.size();
		for (int i=0; i<m_jaSize; i++) {
			CoviMap jo = updateJa.getJSONObject(i);
			params.put("PtjCode", jo.getString("strPrjCode"));
			params.put("TaskCode", jo.getString("strTaskIDX"));
			params.put("TaskName", jo.getString("strTaskName"));
			params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", jo.getString("strTaskHour"));
			params.put("TaskStatusCode", jo.getString("strTaskStatusCode"));
			params.put("TaskPercent", jo.getString("strTaskPercent"));
			params.put("TaskEtc", jo.getString("strTaskEtc"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("DEPTID"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("ReportCode", jo.getString("strReportCode"));
			params.put("TaskGubunCode", jo.getString("TaskGubunCode"));
			
			coviMapperOne.insert("user.bizreport.updateTaskReport", params);
		}
		
		m_jaSize = deleteJa.size();
		for (int i=0; i<m_jaSize; i++) {
			CoviMap jo = deleteJa.getJSONObject(i);
			params.put("PtjCode", jo.getString("strPrjCode"));
			params.put("TaskCode", jo.getString("strTaskIDX"));
			params.put("TaskName", jo.getString("strTaskName"));
			params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", jo.getString("strTaskHour"));
			params.put("TaskStatusCode", jo.getString("strTaskStatusCode"));
			params.put("TaskPercent", jo.getString("strTaskPercent"));
			params.put("TaskEtc", jo.getString("strTaskEtc"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("DEPTID"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("ReportCode", jo.getString("strReportCode"));
			params.put("TaskGubunCode", jo.getString("TaskGubunCode"));
			
			coviMapperOne.insert("user.bizreport.deleteTaskReport", params);
		}
		
		return 0;
	}
	
	@Override
	public CoviMap getTaskReportDailyList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap userInfoObj = SessionHelper.getSession();
		String userID = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		
		params.put("userID", userID);
		params.put("domainID", domainID);
		
		CoviList folderList = coviMapperOne.list("user.bizreport.selectFolderReportDailyList", params);
		CoviList taskList = coviMapperOne.list("user.bizreport.selectTaskReportDailyList", params);
		CoviList activityList = coviMapperOne.list("user.bizreport.selectProjectTaskReportDailyList", params);
		CoviList reportList = coviMapperOne.list("user.bizreport.selectGReportDailyList", params);
		
		resultList.put("ProjectTaskList", coviSelectJSONForTaskList(activityList, "AT_ID,FolderID,CU_ID,ATName,StartDate,EndDate,State,TaskState,Progress,ReportID,TaskGubunCode,CommunityName"));
		resultList.put("FolderList", coviSelectJSONForTaskList(folderList, "TaskID,FolderID,ProjectCode,DisplayName,Description,State,FolderState,Progress,StartDate,EndDate,ReportID,TaskGubunCode"));
		resultList.put("TaskList", coviSelectJSONForTaskList(taskList, "TaskID,FolderID,ProjectCode,Subject,Description,State,TaskState,Progress,StartDate,EndDate,ReportID,TaskGubunCode,FolderName"));
		resultList.put("ReportList", coviSelectJSONForTaskList(reportList, "ReportID,TaskID,ProjectCode,TaskFolderID,TaskGubunCode,TaskName,TaskDate,TaskHour,TaskStatus,TaskState,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,RegisterCode,RegistDate"));
		
		return resultList;
	}
	
	//주간보고등록 > 항목 조회
	public CoviMap getTaskReportWeeklyList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.bizreport.selectTaskReportWeeklyList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", coviSelectJSONForTaskList(list, "ReportWeekID,TaskID,TaskName,TaskState,TaskStateName,TaskPercent,TaskHour,TaskDate,TaskEtc,TaskGubunCode,ProjectCode,TaskFolderID"));
		
		return resultList;
	}
	
	//주간보고등록 > 등록
	public int insertProjectTaskReportWeekly(CoviMap params) throws Exception {
		return (int) coviMapperOne.insert("user.bizreport.insertProjectTaskReportWeekly", params);
	}
	
	//주간보고등록 > 수정
	public int updateProjectTaskReportWeekly(CoviMap params) throws Exception {
		return (int) coviMapperOne.insert("user.bizreport.updateProjectTaskReportWeekly", params);
	}
	
	//주간보고등록 > 등록 조회
	public CoviMap checkReportWeeklyRegistered(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("user.bizreport.selectReportWeeklyRegistered", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ReportWeekID,ProjectCode,TaskFolderID,TaskGubunCode,StartDate,EndDate,WeekEtc,NextPlan,RegisterCode,RegistDate,RegisterDeptCode"));
		
		return resultList;
	}
	
	//주간보고현황 > 리스트 조회
	public CoviMap getTaskReportWeeklyListAll(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList activityList= coviMapperOne.list("user.bizreport.selectProjectTaskReportDailyListAll", params);
		CoviList folderList = coviMapperOne.list("user.bizreport.selectFolderReportDailyListAll", params);
		CoviList taskList = coviMapperOne.list("user.bizreport.selectTaskReportDailyListAll", params) ;
		CoviList generalList= coviMapperOne.list("user.bizreport.selectGReportDailyListAll", params);
		CoviList reportList= coviMapperOne.list("user.bizreport.selectReportWeeklyListAll", params);
		
		resultList.put("ProjectTaskList", coviSelectJSONForTaskList(activityList, "ReportID,TaskID,ProjectCode,CommunityName,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("FolderList", coviSelectJSONForTaskList(folderList, "ReportID,TaskID,ProjectCode,DisplayName,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("TaskList", coviSelectJSONForTaskList(taskList, "ReportID,TaskID,ProjectCode,Subject,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("GeralList", coviSelectJSONForTaskList(generalList, "ReportID,TaskID,ProjectCode,TaskName,TaskDate,TaskState,TaskStateName,TaskPercent,TaskEtc,TaskMemberCode,TaskMemberDeptCode,TaskHour,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		resultList.put("ReportList", CoviSelectSet.coviSelectJSON(reportList, "ReportWeekID,ProjectCode,StartDate,EndDate,WeekEtc,NextPlan,RegisterDeptCode,RegisterCode,TaskGubunCode,DeptName,UserName,SortPath,SortKey"));
		
		return resultList;
	}
	
	//주간보고 > 주간보고 조회
	public CoviMap getTaskReportWeeklyView(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.bizreport.selectTaskReportWeeklyView", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ReportWeekID,ProjectCode,TaskFolderID,TaskGubunCode,StartDate,EndDate,WeekEtc,NextPlan,RegisterCode,RegistDate"));
		
		return resultList;
	}
	
	//업무관리용 -> 업무보고에서 그대로 사용 
	@SuppressWarnings("unchecked")
	public CoviList coviSelectJSONForTaskList(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviList returnArray = new CoviList();
		
		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {
				CoviMap newObject = new CoviMap();
				
				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("FolderState") || ar.equals("TaskState")){
								newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));
							}else{
								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
							}
						}
					}
				}
				
				returnArray.add(newObject);
			}
		}
		
		return returnArray;
	}
	
	@SuppressWarnings("unchecked")
	public  CoviMap coviSelectJSONForTaskList(CoviMap obj, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviMap newObject = new CoviMap();
		
		for(int j=0; j<cols.length; j++){
			Set<String> set = obj.keySet();
			Iterator<String> iter = set.iterator();
			
			while(iter.hasNext()){
				String ar = (String)iter.next();
				if(ar.equals(cols[j].trim())){
					if (ar.equals("FolderState") || ar.equals("TaskState")){
						newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+obj.getString(cols[j])),obj.getString(cols[j]) ));
					}else{
						newObject.put(cols[j], obj.getString(cols[j]));
					}
				}
			}
		}
		
		return newObject;
	}
	
	// 업무관리에서 사용하는 다국어 값 세팅
	public CoviMap getTaskDic() throws Exception {
		CoviMap taskDic = new CoviMap();
		
		CoviMap taskState = RedisDataUtil.getBaseCodeGroupDic("TaskState");
		CoviMap workState = RedisDataUtil.getBaseCodeGroupDic("FolderState");
		
		for(Object key : taskState.keySet()){
			String strKey = key.toString();
			taskDic.put("TaskState_"+strKey, taskState.getString(strKey));
		}
		
		for(Object key : workState.keySet()){
			String strKey = key.toString();
			taskDic.put("FolderState_"+strKey, workState.getString(strKey));
		}
		
		taskDic.put("", "");
		
		return taskDic;
	}
	
	@Override
	public CoviMap getMyTeamMembers(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.bizreport.selectMyTeamMembers", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptCode,DeptName,DeptSortPath,JobType,UserCode,UserName,UserSortPath"));
		
		return resultList;
	}
	
}
