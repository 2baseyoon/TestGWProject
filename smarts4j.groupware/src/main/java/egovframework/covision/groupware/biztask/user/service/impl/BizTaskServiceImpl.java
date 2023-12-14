package egovframework.covision.groupware.biztask.user.service.impl;

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
import egovframework.covision.groupware.biztask.user.service.BizTaskService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizTaskService")
public class BizTaskServiceImpl extends EgovAbstractServiceImpl implements BizTaskService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectUserTFGridList(CoviMap params)throws Exception {
		CoviList selList = new CoviList();
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserTFGridList", params);
		
		return CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,AppStatus,AppStatusName,RegRequestDate,RegProcessDate,MemberCount,MsgCount,VisitCount,Point,Grade,OperatorCode,OperatorName,TF_DN_ID,TF_DomainName,TF_DeptCode,DomainCode,GroupCode,CreatorCode,CreatorName,FilePath,TF_Period,DisplayName,UserCode,MailAddress,CuAppDetail,CommunityJoin,CommunityType,num,TF_PM,TF_Admin,TF_Member");
	}
	
	@Override
	public CoviMap getMyTaskList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap userInfoObj = SessionHelper.getSession();
		
		String userID = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		
		params.put("userID", userID);
		params.put("domainID", domainID);
		
		CoviList activityList = coviMapperOne.list("user.biztask.selectMyActivityList", params);
		CoviList taskList = coviMapperOne.list("user.biztask.selectMyTaskList", params);
		
		resultList.put("ProjectTaskList", coviSelectJSONForTaskList(activityList, "AT_ID,FolderID,CU_ID,ATName,StartDate,EndDate,State,TaskState,Progress,CommunityName,CommunityType,AppStatus,DelayDay"));
		resultList.put("TaskList", coviSelectJSONForTaskList(taskList, "TaskID,FolderID,ProjectCode,Subject,Description,State,TaskState,Progress,StartDate,EndDate,DisplayName,DelayDay,RegisterCode,OwnerCode"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getAllMyTaskList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap userInfoObj = SessionHelper.getSession();
		String userID = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		
		params.put("userID", userID);
		params.put("domainID", domainID);
		
		CoviList activityList = coviMapperOne.list("user.biztask.selectAllMyActivityList", params);
		CoviList taskList = coviMapperOne.list("user.biztask.selectAllMyTaskList", params);
		
		resultList.put("ProjectTaskList", coviSelectJSONForTaskList(activityList, "AT_ID,FolderID,CU_ID,ATName,StartDate,EndDate,State,TaskState,Progress,CommunityName,CommunityType,AppStatus,DelayDay"));
		resultList.put("TaskList", coviSelectJSONForTaskList(taskList, "TaskID,FolderID,ProjectCode,Subject,Description,State,TaskState,Progress,StartDate,EndDate,DisplayName,DelayDay,RegisterCode,OwnerCode,IsShare"));
		
		return resultList;
	}
	
	//업무관리용 -> 업무보고에서 그대로 사용 
	@SuppressWarnings("unchecked")
	public CoviList coviSelectJSONForTaskList(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviList returnArray = new CoviList();
		
		if (clist != null && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {
				CoviMap newObject = new CoviMap();
				
				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("FolderState") || ar.equals("TaskState")) {
								newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));
							}else {
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
	
	// 업무관리에서 사용하는 다국어 값 세팅
	public CoviMap getTaskDic() throws Exception {
		CoviMap taskDic = new CoviMap();
		CoviMap taskState = RedisDataUtil.getBaseCodeGroupDic("TaskState");
		CoviMap workState = RedisDataUtil.getBaseCodeGroupDic("FolderState");
		
		for(Object key : taskState.keySet()){
			String strKey = key.toString();
			taskDic.put("TaskState_"+strKey, taskState.getString(strKey) );
		}
		
		for(Object key : workState.keySet()){
			String strKey = key.toString();
			taskDic.put("FolderState_"+strKey, workState.getString(strKey) );
		}
		
		taskDic.put("", "");
		
		return taskDic;
	}
	
	//간트차트정보가져오기
	public CoviMap getGanttList(CoviMap params) throws Exception {
		CoviList activityList = coviMapperOne.list("user.biztask.selectProjectDetailStatusListforGantt", params); //Gantt Chart 조회
		/*Activity 리스트 가져오기*/
		CoviList memberlist = coviMapperOne.list("user.tf.selectTFPrintTaskMemberList", params);		
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(activityList, "AT_ID,ATName,PerformerCode,MultiDisplayName,State,Progress,StartDate,EndDate,MemberOf,SortPath,CodeName,Weight,SubCnt"));
		resultList.put("memberlist", CoviSelectSet.coviSelectJSON(memberlist, "AT_ID,ATName,PerformerCode,MultiDisplayName,PerformerType"));
		
		return resultList;
	}
	
	//부서장 부서 목록 가져오기
	public CoviMap getMyTeams(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.biztask.selectMyTeams", params); //Gantt Chart 조회
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,MultiDisplayName,GroupPath"));
		return resultList;
	}
	
	//부서 프로젝트/업무관리 요약정보 가져오기
	public CoviMap getMyTeamProjectSummary(CoviMap params) throws Exception {
		CoviList projectList = coviMapperOne.list("user.biztask.selectMyTeamProjectSummary", params); //프로젝트 요약정보
		CoviList taskList = coviMapperOne.list("user.biztask.selectMyTeamTaskSummary", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("projectlist", CoviSelectSet.coviSelectJSON(projectList, "CU_ID,CommunityName,TF_MajorDeptCode,TF_MajorDept,TF_STATE,TF_StartDate,TF_EndDate,TF_TERM,AT_ID,ATName,StartDate,EndDate,ATState,ATProgress,Weight,DELAYCNT"));
		resultList.put("tasklist", CoviSelectSet.coviSelectJSON(taskList, "TaskID,FolderID,Subject,Description,State,StartDate,EndDate,Progress,DeptCode,MultiDeptName,DELAYCNT"));
		
		return resultList;
	}
	
	@Override
	public int selectMyTeamProjectSummaryListCNT(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.biztask.selectMyTeamProjectSummaryListCNT", params);
	}
	
	@Override
	public CoviMap selectMyTeamProjectSummaryList(CoviMap params)throws Exception {
		CoviList list = coviMapperOne.list("user.biztask.selectMyTeamProjectSummaryList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CU_ID,CommunityName,TF_StartDate,TF_EndDate,TF_MajorDept,TF_TERM,TF_AVGProgress,TF_WProgress,DELAYCNT,RNUM"));
		
		return resultList;
	}
	
	@Override
	public int selectMyPreTaskListCNT(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.biztask.selectPreTaskListCNT", params);
	}
	
	@Override
	public CoviMap selectMyPreTaskList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.biztask.selectPreTaskList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "PreTaskID,ReportDate,Term,TermMode,BeforeAfter,TaskDate,Subject"));
		
		return resultList;
	}
	
	@Override
	public void setPreTaskSchedule(CoviMap params) throws Exception {
		coviMapperOne.insert("user.biztask.insertPreTask", params);
	}
	
	@Override
	public int deleteMyPreTask(CoviMap params) throws Exception {
		return (int)coviMapperOne.update("user.biztask.deletePreTask", params);
	}
	
	@Override
	public int deletePreTaskSchedule(CoviMap params) throws Exception {
		return (int)coviMapperOne.delete("user.biztask.deletePreTaskSchedule", params);
	}
	
	@Override
	public CoviMap selectPortalMyActivityList(CoviMap params) throws Exception {
		CoviMap returnObject = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.biztask.selectPortalMyActivityList", params);
		returnObject.put("list", coviSelectJSONForTaskList(list, "AT_ID,FolderID,CU_ID,ATName,StartDate,EndDate,State,TaskState,Progress,CommunityName,CommunityType,AppStatus,DelayDay,PjState"));
		return returnObject;
	}
	
	@Override
	public CoviMap selectPortalMyTaskList(CoviMap params) throws Exception {
		CoviMap returnObject = new CoviMap();
		
		CoviList list= coviMapperOne.list("user.biztask.selectPortalMyTaskList", params);
		returnObject.put("list", coviSelectJSONForTaskList(list, "TaskID,FolderID,ProjectCode,Subject,Description,State,TaskState,Progress,StartDate,EndDate,DisplayName,DelayDay,RegisterCode,OwnerCode,IsShare,PjState"));
		return returnObject;
	}
	
	@Override
	public CoviMap selectPortalMyActivityGraph(CoviMap params) throws Exception {
		CoviMap returnObject = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.biztask.selectPortalMyActivityGraph", params);
		returnObject.put("list", coviSelectJSONForTaskList(list, "Code,Cnt"));
		return returnObject;
	}
	
	@Override
	public CoviMap selectPortalMyTaskGraph(CoviMap params) throws Exception {
		CoviMap returnObject = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.biztask.selectPortalMyTaskGraph", params);
		returnObject.put("list", coviSelectJSONForTaskList(list, "Code,Cnt"));
		return returnObject;
	}
	
	@Override
	public CoviList selectUserTFLeftGridList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("PMLevel", RedisDataUtil.getBaseConfig("TFPMLevel"));
		params.put("AdminLevel", RedisDataUtil.getBaseConfig("TFAdminLevel"));
		params.put("MemberLevel", RedisDataUtil.getBaseConfig("TFMemberLevel"));
		
		// 전체 리스트 조회
		selList = coviMapperOne.list("user.tf.selectUserTFLeftGridList", params);
		
		return CoviSelectSet.coviSelectJSON(selList, "CU_ID,MN_ID,CategoryID,CU_Code,DN_ID,SearchTitle,CommunityName,AppStatus,AppStatusName,RegRequestDate,RegProcessDate,MemberCount,MsgCount,VisitCount,Point,Grade,OperatorCode,OperatorName,TF_DN_ID,TF_DomainName,TF_DeptCode,DomainCode,GroupCode,CreatorCode,CreatorName,FilePath,TF_Period,DisplayName,UserCode,MailAddress,CuAppDetail,CommunityJoin,CommunityType,num,TF_PM,TF_Admin,TF_Member");
	}
}
