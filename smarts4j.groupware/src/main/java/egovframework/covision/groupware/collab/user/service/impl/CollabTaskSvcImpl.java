package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service("CollabTaskSvc")
public class CollabTaskSvcImpl extends EgovAbstractServiceImpl implements CollabTaskSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	
	@Autowired
	private ScheduleSvc scheduleSvc;
	
	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private FileUtilService fileUtilService;
	
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	public static final String fileSvcType = "Collab";
	public static final String fileSvcPath = fileSvcType + "/";

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보(수정용)
	 * @throws Exception
	 */
	@Override
	public CoviMap getTask(CoviMap params) throws Exception {
		return getTask(params, false);
	}
	@Override
	public CoviMap getTask(CoviMap params, boolean bMapAuth) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap taskData = coviMapperOne.selectOne("collab.task.getTask", params);
		if(taskData == null) return null;
		int taskSeq = params.getInt("taskSeq");
		params.put("ServiceType", fileSvcType);
		params.put("ObjectID", taskSeq);
		params.put("MessageID", 0);
		
		String remark = taskData.getString("Remark");
		remark = remark.replaceAll("\r\n", "<br/>");
		
		taskData.put("Remark", remark);

		resultList.put("taskData", taskData);
		resultList.put("memberList", coviMapperOne.selectList("collab.task.getTaskMember", params));
		resultList.put("userformList", coviMapperOne.selectList("collab.task.getTaskUserForm", taskSeq));
		resultList.put("subTaskList", coviMapperOne.selectList("collab.task.getSubTask", params));
		resultList.put("tagList", coviMapperOne.selectList("collab.task.getTaskTag", params));
		resultList.put("fileList", fileUtilService.selectAttachAll(params));
		
		if (taskData.getInt("ParentKey") >0){
			params.put("taskSeq", taskData.getInt("TopParentKey"));
			resultList.put("mapList", coviMapperOne.selectList("collab.task.getTaskMap", params));
		}else{
			resultList.put("mapList", coviMapperOne.selectList("collab.task.getTaskMap", params));
			resultList.put("linkList", coviMapperOne.selectList("collab.task.getTaskLink", params));

		}	
		if (bMapAuth){
			resultList.put("mapUserList", coviMapperOne.selectList("collab.task.getTaskMapUser", params));
		}
		
		//task ObjectType=SURVEY일 경우 설문 완료 여부 가져오기
		if(taskData.get("ObjectType")!=null && taskData.get("ObjectType").equals("SURVEY")) {
			resultList.put("surveyComplete",coviMapperOne.selectList("user.survey.selectSurveyQuestionItemList",taskData.get("ObjectID")));
		}
		
		return resultList;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보(수정용)
	 * @throws Exception
	 */
	@Override
	public List<CoviMap>  getSubTask(CoviMap params) throws Exception {
		return coviMapperOne.selectList("collab.task.getSubTask",  params);
	}
	
	//타스트 추가
	@Override
	public CoviMap addTask(CoviMap params, List objMember) throws Exception {
		return addTask(params, objMember, null, null, null);
	}
	
	//타스트 추가
	@Override
	public CoviMap addTask(CoviMap params, List objMember, List trgUserForm, List<MultipartFile> mf, List tags) throws Exception {
		int cnt = 0;
		params.put("memberList", objMember);
		params.put("userFormList", trgUserForm);
		params.put("taskTagList", tags);
		
		if (params.get("objectID") != null && params.get("objectType").equals("EVENT") ){	//스케쥴에서 가져와서 타스트 생성하기
			cnt = coviMapperOne.insert("collab.task.addTaskBySchedule", params);
			coviMapperOne.insert("collab.task.addTaskMemberBySchedule", params);
			coviMapperOne.insert("collab.task.addTaskMapBySchedule", params);		
			params.put("taskSeq", params.getInt("TaskSeq"));
		}
		else if(params.get("objectID") != null && params.get("objectType").equals("SURVEY") ){
			cnt = coviMapperOne.insert("collab.task.addTaskBySurvey", params);
			coviMapperOne.insert("collab.task.addTaskMemberBySurvey", params);
			coviMapperOne.insert("collab.task.addTaskMapBySurvey", params);
			params.put("taskSeq", params.getInt("TaskSeq"));
		}
		else{
			cnt = coviMapperOne.insert("collab.task.addTask", params);
			params.put("taskSeq", params.getInt("TaskSeq"));
			if (objMember != null && objMember.size()>0){
				coviMapperOne.insert("collab.task.addTaskMember", params);
			}
			
			if (trgUserForm != null  && trgUserForm.size()>0){
				coviMapperOne.insert("collab.task.addTaskUserForm", params);		
			}
	
			if (tags != null  && tags.size()>0){
				coviMapperOne.insert("collab.task.addTaskTag", params);		
			}
			
			if (params.getString("parentKey").equals("0") && params.get("prjSeq") != null &&  !params.getString("prjSeq").equals("")){
				coviMapperOne.insert("collab.task.addTaskMap", params);		
			}	
			
			if(params.getJSONArray("fileInfos").size() > 0) {
				String taskSeq = params.getString("taskSeq");
				CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
				if(mf == null) {
					mf = new ArrayList<>();
				}
				fileUtilService.moveToService(fileInfos, mf, fileSvcPath, fileSvcPath, fileSvcType, taskSeq, "NONE", "0", "0");
			}
						
		}

		// 업무 생성 시, 프로젝트 진행률 수정 프로시저 호출.
		coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);

		//history 
		if (params.getInt("topParentKey") >0){
			params.put("taskSeq", params.getInt("topParentKey"));
			insertTaskHistory  ("Add", "SubTask", params);
		}	else{
			insertTaskHistory  ("Add", "Task", params);
		}	
		return params;
	}
	
	//순서변경
	public int changeProjectTaskOrder  (CoviMap params, List ordTask) throws Exception {
		params.put("taskList", ordTask);
		switch (params.getString("mode")){
			case "MEM":
				if (!params.getString("userCode").equals("NONE")){
					params.put("userCode", params.get("userCode"));
					coviMapperOne.insert("collab.task.deleteTaskMember", params);
				}
				
				if (!params.getString("sectionSeq").equals("NONE")){
					List trgManager = new ArrayList();
					CoviMap trgMap = new CoviMap();
					trgMap.put("userCode", params.get("sectionSeq"));
					trgManager.add(trgMap);
					
					params.put("memberList", trgManager);
					coviMapperOne.insert("collab.task.addTaskMember", params);
				}	
				break;
			case "STAT":
				params.put("taskStatus", params.get("sectionSeq"));
				insertTaskHistory("Mod", "Status", params);
				coviMapperOne.insert("collab.task.changeProjectTaskStatus", params);

				if (params.getString("myTodo").equals("Y")){	//내업무인 경우 순서 변경
					coviMapperOne.insert("collab.task.changeProjectTaskTodoOrder", params);
				}
				coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
				break;
			default:
				insertTaskHistory("Mod", "Section", params);
//				insertTaskHistory("Mod", "Order", params);
				coviMapperOne.insert("collab.task.changeProjectTaskSection", params);
				coviMapperOne.insert("collab.task.changeProjectTaskOrder", params);
				break;
		}
		
		return  1;
	}	
	
	//순서변경-todo
	public int changeProjectTaskTodoOrder  (CoviMap params, List ordTask) throws Exception {
		params.put("taskList", ordTask);
		insertTaskHistory("Mod", "Status", params);
		coviMapperOne.insert("collab.task.changeProjectTaskStatus", params);
		coviMapperOne.insert("collab.task.changeProjectTaskTodoOrder", params);
		 
		//if (params.get("prjType").equals("P")){
			coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
		//}
		return 1;
	}	
		
	//상태변경
	public int changeProjectTaskStatus  (CoviMap params) throws Exception {
		insertTaskHistory("Mod", "Status", params);
		coviMapperOne.insert("collab.task.changeProjectTaskStatus", params);
		//if (params.get("prjType").equals("P")){
			coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
		//}
		return 1;
	}	
	
	//세션및 날짜변경
	public int changeProjectTaskDate(CoviMap params) throws Exception {
		if (params.get("TODO") != null && !params.get("TODO").equals("Y") && params.get("sectionSeq") != null){
			insertTaskHistory("Mod", "Section", params);
			coviMapperOne.insert("collab.task.changeProjectTaskSection", params);
		}	
		
		insertTaskHistory("Mod", "Date", params);
		coviMapperOne.insert("collab.task.changeProjectTaskDate", params);
		
		//if (params.get("prjType").equals("P")){
			coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
		//}
		return 1;
	}	
		
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 수정
	 * @throws Exception
	 */
	@Override
	public CoviMap saveTask(CoviMap params, List objMember, List trgUserForm, MultipartFile[] mf, List objDelFile, List tags) throws Exception {
		insertTaskHistory("Mod", "Task", params);
		
		int cnt = coviMapperOne.insert("collab.task.saveTask", params);
//		return params.getInt("ProSeq") ;
		params.put("memberList", objMember);
		params.put("userFormList", trgUserForm);
		params.put("taskTagList", tags);
		
		if (objMember != null ){
			List bfMemberList = (List)coviMapperOne.selectList("collab.task.getTaskMember", params);
			StringBuffer sbTarget = new StringBuffer();
	        for (int i=0; i < objMember.size(); i++){
	        	boolean bFind = false;
				String newUserId = (String)((HashMap)objMember.get(i)).get("userCode");
				
				for (int j =0; j < bfMemberList.size(); j++ ){
					if (newUserId.equals((String)((CoviMap)(bfMemberList.get(j))).getString("UserCode")))
					{
						bFind = true;
						break;
					}
				}
				if (bFind == false){
		        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
		        	sbTarget.append((String)((HashMap)objMember.get(i)).get("userName")); 
				}	
	        }    
	        
	        if (!sbTarget.toString().equals("")){
	        	params.put("addVal", sbTarget.toString());
	        	insertTaskHistory("Mod", "AddMember", params);
	        } 
	        
	        
			sbTarget = new StringBuffer();
	        for (int i=0; i < bfMemberList.size(); i++){
	        	boolean bFind = false;
				String oldUserId = (String)((CoviMap)bfMemberList.get(i)).get("UserCode");
				
				for (int j =0; j < objMember.size(); j++ ){
					if (oldUserId.equals((String)((HashMap)(objMember.get(j))).get("userCode")))
					{
						bFind = true;
						break;
					}
				}
				if (bFind == false){
		        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
		        	sbTarget.append((String)((CoviMap)bfMemberList.get(i)).get("DisplayName")); 
				}	
	        }    
	        
	        if (!sbTarget.toString().equals("")){
	        	params.put("delVal", sbTarget.toString());
	        	insertTaskHistory("Mod", "DelMember", params);
	        } 

	        coviMapperOne.delete("collab.task.deleteTaskMember", params);
			if (objMember.size()>0)
				coviMapperOne.insert("collab.task.addTaskMember", params);
		}
		
		if (objDelFile != null ){
			StringBuffer sbTarget = new StringBuffer();
			for (int i=0; i < objDelFile.size(); i++){
				HashMap fileMap = (HashMap)objDelFile.get(i);
				
				fileUtilService.deleteFileByID((String)fileMap.get("FileID"), true);
				if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	sbTarget.append((String)fileMap.get("FileName")); 
			}	
			if (objDelFile.size() > 0){
	        	params.put("delVal", sbTarget.toString());
	        	insertTaskHistory("Mod", "DelFile", params);
			}	
		}
		int TaskUserFormCnt = coviMapperOne.selectOne("collab.task.getTaskUserFormCnt", params);
		if(TaskUserFormCnt > 0)
			coviMapperOne.delete("collab.task.deleteTaskUserForm", params);
		if (trgUserForm != null  && trgUserForm.size()>0)			
			coviMapperOne.insert("collab.task.addTaskUserForm", params);
		
		coviMapperOne.delete("collab.task.deleteTaskTag", params);
		if (tags != null  && tags.size()>0){
			coviMapperOne.insert("collab.task.addTaskTag", params);
		}
		params.put("memberList", 	coviMapperOne.selectList("collab.task.getTaskMember", params));
		
		//if (params.get("prjType").equals("P")){
			coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
		//}	
			
		CoviList fileInfos = (CoviList) params.get("fileInfos");
			
		if(mf != null || fileInfos.size() > 0) {
			String taskSeq = params.getString("taskSeq");
			List<MultipartFile> mockedFileList = new ArrayList<>();
			StringBuffer sbTarget = new StringBuffer();
			if(mf != null) {
				for (int i=0; i < mf.length; i++){
					if(mf[i] != null && mf[i].getSize()>0) {
						mockedFileList.add(mf[i]);
						if (!sbTarget.toString().equals("")) sbTarget.append(";");
			        	sbTarget.append(mf[i].getOriginalFilename()); 
					}
				}
			}
			if (mockedFileList.size()>0 || fileInfos.size() > 0){
	        	params.put("addVal", sbTarget.toString());
	        	insertTaskHistory("Mod", "AddFile", params);
				CoviList fileObj = fileUtilService.uploadToBack(fileInfos, mockedFileList, fileSvcPath, fileSvcType, taskSeq, "NONE", "0",false);
			}	
		}	
		
		return params;
	}

	/**
	 * @param params
	 * @return CoviMap 프로젝트 수정
	 * @throws Exception
	 */
	@Override
	public int updateTaskStatus(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.update("collab.task.updateTaskStatus", params);
		coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);

		return cnt;
	}
	
	//삭제
	public int deleteTask (CoviMap params) throws Exception {
		int cnt = 0;
		
		// 프로젝트 진행률 계산을 위해 삭제 전 해당 프로젝트의 다른 Task정보를 가져옴.
		List<CoviMap> otherTask = coviMapperOne.selectList("collab.task.selectOtherTaskDeleted", params);
		List<CoviMap> taskMap = new ArrayList<CoviMap>();
		
		insertTaskHistory  ("Del", "Task", params);
		if (params.get("objectID") != null && params.get("objectType").equals("EVENT")) {
			CoviMap delMap = new CoviMap();
			
			delMap.put("EventID", params.get("objectID"));
			delMap.put("taskSeq", params.get("taskSeq"));
			
			List<CoviMap> taskList = getTaskSeqList(params);
			
			if (taskList.size() == 1) { // 일반 일정
				scheduleSvc.deleteEvent(delMap);
			} else if (taskList.size() > 1) { // 반복일정
				coviMapperOne.delete("collab.task.deleteTaskBySchedule", delMap);
			}
		}
		
		if (params.getString("isTopTask").equals("Y")){
			taskMap = coviMapperOne.selectList("collab.task.getTaskMap", params);
//			cnt = coviMapperOne.delete("collab.task.deleteTaskUserForm", params);
			cnt = coviMapperOne.delete("collab.task.deleteTaskMember", params);
			cnt = coviMapperOne.delete("collab.task.deleteTaskUserForm", params);
			cnt = coviMapperOne.delete("collab.task.deleteTaskMap", params);
		}
		cnt = coviMapperOne.delete("collab.task.deleteSubTask", params);
		cnt = coviMapperOne.delete("collab.task.deleteTask", params);
		cnt = coviMapperOne.delete("collab.task.deleteTaskFavorite", params);
		cnt = coviMapperOne.delete("collab.task.deleteTaskTag", params);
		fileUtilService.clearFile(fileSvcPath, fileSvcType, params.getString("taskSeq"),"", "0");
		
		if ( otherTask.size() > 0 && otherTask.get(0) != null ) {
			params.put("taskSeq", otherTask.get(0).get("TaskSeq")); 	// 프로젝트 진행률을 위해 마지막에 taskSeq 변경. 
			params.put("saturDay", "Y");
            params.put("holiDay", "Y");
            params.put("sunDay", "Y");
			coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);
		} else {
			if(taskMap != null && taskMap.size() > 0 && taskMap.get(0).getString("PrjSeq") != null && !"".equals(taskMap.get(0).getString("PrjSeq"))) {
				params.put("prjSeq",taskMap.get(0).getString("PrjSeq"));
				coviMapperOne.update("collab.project.clearProgRate", params);				
			}
		}

		return cnt;
	}
	
	//초대
	@Override
	public int addTaskInvite(CoviMap params) throws Exception {
		return coviMapperOne.insert("collab.task.addTaskMember", params);
	}

	//담당자 삭제
	@Override
	public int deleteTaskMember(CoviMap params) throws Exception {
		return coviMapperOne.delete("collab.task.deleteTaskMember", params);
	}
	
	//마일스톤
	@Override
	public int saveTaskMile(CoviMap params) throws Exception {
    	insertTaskHistory("Mod", "Mile", params);
		return coviMapperOne.insert("collab.task.saveTaskMile", params);
	}

	//즐겨찾기
	@Override
	public int addTaskFavorite(CoviMap params) throws Exception {
		return coviMapperOne.insert("collab.task.addTaskFavorite", params);
	}

	//즐겨찾기 해제
	@Override
	public int deleteTaskFavorite(CoviMap params) throws Exception {
		return coviMapperOne.delete("collab.task.deleteTaskFavorite", params);
	}

	//미할당 프로젝트 조회
	@Override
	public CoviList getNoAllocProject(CoviMap params) throws Exception {
		return coviMapperOne.list("collab.task.getNoAllocProject", params);
	}
	
	//프로젝트 배정
	@Override
	public int addAllocProject(CoviMap params) throws Exception {
		if (params.getString("isExport").equals("Y")){//내보내기이면 지존 배정건 삭제
			CoviMap delParams = new CoviMap();
			delParams.put("taskSeq", params.get("taskSeq"));
			params.put("delVal",params.get("prjName"));
			insertTaskHistory  ("Mod", "DelAlloc", delParams);
			coviMapperOne.delete("collab.task.deleteTaskMap", delParams);
		}
		int cnt = coviMapperOne.insert("collab.task.addTaskMap", params);
		if (cnt == 1) {
			params.put("addVal",params.get("prjName"));
			insertTaskHistory  ("Mod", "AddAlloc", params);			
		}
		return cnt;
	}
	//프로젝트삭제
	@Override
	public int deleteAllocProject(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("collab.task.deleteTaskMap", params);
		if (cnt > 0) {
			params.put("delVal",params.get("prjName"));
			insertTaskHistory  ("Mod", "DelAlloc", params);
		}
		return cnt;
	}
	
	//태그 추가
	@Override
	public int addTaskTag(CoviMap params) throws Exception {
		return coviMapperOne.insert("collab.task.addTaskTag", params);
	}

	//태그 삭제
	@Override
	public int deleteTaskTag(CoviMap params) throws Exception {
		return coviMapperOne.delete("collab.task.deleteTaskTag", params);
	}
	
	//복사
	public int copyTask  (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.task.copyTask", params);
		params.put("taskSeq", params.getInt("TaskSeq"));
		params.put("copyFileName", "");
		cnt = coviMapperOne.insert("collab.task.copyTaskMember", params);
		cnt = coviMapperOne.insert("collab.task.copyTaskMap", params);
		cnt = coviMapperOne.insert("collab.task.copyTaskTag", params);
		
		CoviList fileList = new CoviList();
		fileList = coviMapperOne.list("collab.task.getTaskFile", params);
		
		for(int i=0; i<fileList.size(); i++) {
			int updateCnt = 0;
			CoviMap insertFile = new CoviMap();
	
			insertFile = fileList.getMap(i);
			
			String[] fileName = ((String) insertFile.get("FileName")).split("\\.");
			
			String copyFileName = "";
			
			if(fileName.length == 2) {
				copyFileName = fileName[0] + "_" + DicHelper.getDic("lbl_Copy") + "." + fileName[1];
			} else if(fileName.length == 1) {
				copyFileName = fileName[0] + "_" + DicHelper.getDic("lbl_Copy");
			}
			
			List<MultipartFile> mf = new ArrayList();
			
			CoviList fileInfoList = new CoviList();
			fileInfoList.add(insertFile);
			CoviList fileObj = fileUtilService.moveToService(fileInfoList, mf, "Collab" + File.separator, "Collab" + File.separator,
					"Collab",  params.getString("TaskSeq"), insertFile.getString("ObjectType"), insertFile.getString("MessageID"), insertFile.getString("Version"));			
		
			CoviMap copyFile = fileObj.getMap(0);
			copyFile.put("copyFileName", copyFileName);
			
			updateCnt = coviMapperOne.update("collab.task.updateCopyFileName", copyFile);
		}
		
		// 업무 복사 시, 프로젝트 진행률 수정.
		params.put("saturDay", "Y");
		params.put("holiDay", "Y");
		params.put("sunDay", "Y");
		coviMapperOne.insert("collab.task.saveProjectWorkLoad", params);		
		
		return cnt;
	}
	
	//링크 추가
	@Override
	public int addTaskLink(CoviMap params) throws Exception {
		coviMapperOne.delete("collab.task.deleteTaskLink", params);
		params.put("addVal",params.get("linkTaskName"));
		insertTaskHistory  ("Mod", "AddLink", params);
		return coviMapperOne.insert("collab.task.addTaskLink", params);
	}
	//링크삭제
	@Override
	public int deleteTaskLink(CoviMap params) throws Exception {
		params.put("delVal",params.get("linkTaskName"));
		insertTaskHistory  ("Mod", "DelLink", params);
		return coviMapperOne.delete("collab.task.deleteTaskLink", params);
	}
	
	@Override
	public CoviMap getTaskMapBySchedule(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("collab.task.getPrjInfoFromObjectTypeObjectID", params);
	}
	
	@Override
	public int updateTaskDateBySchedule(CoviMap params) throws Exception {
		params.put("objectType", "EVENT");
		params.put("startDate", params.getString("startDate").replaceAll("\\-", ""));
		params.put("USERID", SessionHelper.getSession("USERID"));
		
		return coviMapperOne.update("collab.task.updateTaskDate", params);
	}
	
	@Override
	public int updateTaskDate(CoviMap params) throws Exception {
		int cnt = 0;
		
		List<CoviMap> taskSeqList = getTaskSeqList(params);
		
		for(CoviMap taskMap : taskSeqList){
			CoviMap updateMap = new CoviMap();
			String taskSeq = taskMap.getString("taskSeq");
			
			updateMap.put("taskSeq", taskSeq);
			updateMap.put("USERID", SessionHelper.getSession("USERID"));
			updateMap.put("objectType", params.getString("objectType"));
			updateMap.put("startDate", params.getString("startDate"));
			updateMap.put("endDate", params.getString("endDate"));
			
			if((params.getString("flag")).equals("collabSurveyUpdate")) { // 협업스페이스 설문 수정 시, 업무에 설문 제목 반영을 하기 위한 조건
				updateMap.put("taskName", params.getString("surveySubject"));
				updateMap.put("flag", params.getString("flag"));
			}
			
			if(params.containsKey("prjSeq")) {
				updateMap.put("objectID", params.getString("objectID"));
				updateMap.put("prjSeq", params.getString("prjSeq"));
				updateMap.put("prjType", params.getString("prjType"));
				updateMap.put("sectionSeq", params.getString("sectionSeq"));
				updateMap.put("prjTxt", params.getString("prjTxt"));
				
				cnt += coviMapperOne.update("user.survey.updateCollabSurvey", updateMap);
				cnt += coviMapperOne.update("user.survey.updateCollabSurveyTaskMap", updateMap);
			}
			
			cnt += coviMapperOne.update("collab.task.updateTaskDate", updateMap);
		}
		
		return cnt;
	}
	
	@Override
	public List<CoviMap> getTaskSeqList(CoviMap params) throws Exception {
		return coviMapperOne.selectList("collab.task.selectTaskSeqList", params);
	}
	
	@Override
	public int deleteTaskList(CoviMap params) throws Exception {
		int cnt = 0;
		
		List<CoviMap> taskSeqList = getTaskSeqList(params);
		
		for(CoviMap taskMap : taskSeqList){
			CoviMap deleteMap = new CoviMap();
			String taskSeq = taskMap.getString("taskSeq");
			
			deleteMap.put("taskSeq", taskSeq);
			
			cnt = coviMapperOne.delete("collab.task.deleteTaskMember", deleteMap);
			cnt = coviMapperOne.delete("collab.task.deleteTaskUserForm", params);
			cnt = coviMapperOne.delete("collab.task.deleteTaskMap", deleteMap);
			cnt = coviMapperOne.delete("collab.task.deleteSubTask", deleteMap);
			cnt = coviMapperOne.delete("collab.task.deleteTask", deleteMap);
			cnt = coviMapperOne.delete("collab.task.deleteTaskFavorite", deleteMap);
			cnt = coviMapperOne.delete("collab.task.deleteTaskTag", deleteMap);
			fileUtilService.clearFile(fileSvcPath, fileSvcType, taskSeq, "", "0");
			
		}
		
		return cnt;
	}
	
	@Override
	public List<CoviMap> getTaskSeqListByProjectObj(CoviMap params) throws Exception {
		return coviMapperOne.selectList("collab.task.selectTaskSeqByObjectID", params);
	}
	
	@Override
	public List<CoviMap> selectTaskMemberList(CoviMap params) throws Exception {		
		return coviMapperOne.selectList("collab.task.selectTaskMemberList",params);
	}

	//히스토리 로그 생성
	private void insertTaskHistory  (String modType, String modItem, CoviMap params) throws Exception {
		List modList= new ArrayList<>();
		CoviMap modMap = new CoviMap();
		CoviMap taskData = coviMapperOne.selectOne("collab.task.getTask", params);
		CoviMap taskInfo = coviMapperOne.selectOne("collab.task.getTaskInfoFromTaskSeq", params);
		params.addAll(taskInfo);
		//String[][] modItems 
	
		String modItems[][] = {{"TaskName","taskName","TaskName"},{"TaskStatus","taskStatus","Status"}
					,{"ProgRate","progRate","ProgRate"},{"Label","label","Label"},{"RemarkText","remarkText","RemarkText"}, {"ImpLevel","impLevel","ImpLevel"}
					, {"IsMile","isMile","IsMile"}
					}; 
		
		if (modType.equals("Mod")){
			switch (modItem){
				case "Date":	//기간변경
					modMap.put("modType", "Mod");
					modMap.put("modItem", modItem);
					modMap.put("bfVal", taskData.get("StartDate") + "~" + taskData.get("EndDate"));
					modMap.put("afVal", params.get("startDate") + "~" + params.get("endDate"));
					modList.add( modMap);
					break;
				case "Mile":	//마일스톤
					modMap.put("modType", "Mod");
					modMap.put("modItem", modItem);
					modMap.put("bfVal", "");
					modMap.put("afVal", params.get("isMile"));
					modList.add( modMap);
					break;
				case "Section":	//섹션 변경
					if (!taskData.get("SectionSeq").equals(params.get("sectionSeq"))){
						modMap.put("modType", "Mod");
						modMap.put("modItem", modItem);
						modMap.put("bfVal", taskData.get("SectionSeq"));
						modMap.put("afVal", params.get("sectionSeq"));
						modList.add( modMap);
					}	
					break;
				case "Status":	//상태변경
					if (!taskData.get("TaskStatus").equals(params.get("taskStatus"))){
						modMap.put("modType", "Mod");
						modMap.put("modItem", modItem);
						modMap.put("bfVal", taskData.get("TaskStatus") );
						modMap.put("afVal", params.get("taskStatus"));
						modList.add( modMap);
					}	
					break;
				case "AddMember":	//멤버 추가
				case "AddFile":	//파일 추가
				case "AddAlloc":	//프로젝트 추가
				case "AddLink":	//업무링크 추가
					modMap.put("modType", "Mod");
					modMap.put("modItem", modItem);
					modMap.put("afVal", params.get("addVal"));
					modList.add( modMap);
					break;
				case "DelMember":	//멤버 삭제
				case "DelFile":	//파일 삭제
				case "DelAlloc":	//프로젝트 삭제
				case "DelLink":	//업무 링크 삭제
					modMap.put("modType", "Mod");
					modMap.put("modItem", modItem);
					modMap.put("bfVal", params.get("delVal"));
					modList.add( modMap);
					break;
				case "Task":	//타스크의 변경시 항목 비교후 틀린부분만 이력으로 저장
					for (int i=0 ; i < modItems.length; i++){
						if (!StringUtil.replaceNull(taskData.getString(modItems[i][0]),"").equals(StringUtil.replaceNull(params.get(modItems[i][1]),""))){	
							modMap = new CoviMap();
							modMap.put("modType", "Mod");
							modMap.put("modItem", modItems[i][2]);
							modMap.put("bfVal", taskData.get(modItems[i][0]));
							modMap.put("afVal", params.get(modItems[i][1]));
							modList.add( modMap);
						}	
					}	
					break;
				default:
					break;
			}			
		}else{
			modMap.put("modType", modType);
			modMap.put("modItem", modItem);
			if (modType.equals("Del")){
				if (taskData.getInt("TopParentKey") >0)
					 modMap.put("bfVal","Delete SubTask["+taskData.get("TaskName")+"("+taskData.getInt("TopParentKey")+">"+taskData.get("TaskSeq")+")"+"] ");
				else modMap.put("bfVal","Delete Task["+taskData.get("TaskName")+"("+taskData.get("TaskSeq")+")"+"] ");
			}
			else{
				//업무/담당자/맵/파일
				modMap.put("afVal",getHistoryDesc(modType, modItem, params));
			}	
			modList.add( modMap);
		}
		if (modList.size()>0){
			params.put("modList",modList);
			coviMapperOne.insert("collab.hist.insertTaskHist", params);		
		}	
	}	

	private String getHistoryDesc(String modType, String modItem, CoviMap params) throws Exception {
		String sDesc="";
		switch (modItem){
			case "Task":
				sDesc += modType+" Task ["+params.get("taskName")+"]";
				break;
			case "SubTask":
				sDesc += modType+" SubTask ["+params.get("taskName")+"]";
				break;
			default :
				break;
		}
		return sDesc;
	}
	
	public int getTaskMapCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("collab.task.getTaskMapCnt", params);
	}
	
	@Override
	public List<CoviMap> getPrjTask(CoviMap params) throws Exception {
		return coviMapperOne.selectList("collab.task.selectPrjTask", params);
	}
	
	@Override
	public CoviMap getTaskLink(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = new CoviList();
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
            int cnt     = 0;
            if (params.get("prjType").equals("M")) {
            	cnt = (int) coviMapperOne.getNumber("collab.task.selectMyTaskLinkCnt", params);
            } else {
            	cnt = (int) coviMapperOne.getNumber("collab.task.selectTaskLinkCnt", params);
            }
            
            page = ComUtils.setPagingCoviData(params, cnt);
            params.addAll(page);
		}
		if (params.get("prjType").equals("M")) {
			list = coviMapperOne.list("collab.task.selectMyTaskLink", params);
		} else {
			list = coviMapperOne.list("collab.task.selectTaskLink", params);
		}
        
        resultList.put("list", list);
        resultList.put("page", page);
        
        return resultList;
	}
}
