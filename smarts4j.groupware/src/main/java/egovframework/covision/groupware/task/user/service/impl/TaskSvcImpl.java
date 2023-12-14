package egovframework.covision.groupware.task.user.service.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.task.user.service.TaskSvc;



@Service("taskService")
public class TaskSvcImpl  extends EgovAbstractServiceImpl implements TaskSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AuthorityService authorityService;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	//내가 하는 일 트리 항목 조회
	@Override
	public CoviList getPersonalFolderList(CoviMap params) throws Exception {
		CoviList retArr = new CoviList();
		CoviList folderList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.task.selectPersonalFolderList", params), "FolderID,ParentFolderID,DisplayName,IsShare,ChildCnt");
		
		//최상위 root 폴더 생성
		CoviMap rootFolder = new CoviMap();
		rootFolder.put("FolderID", "0");
		rootFolder.put("no", "0");
		rootFolder.put("ParentFolderID", "");
		rootFolder.put("pno", "");
		rootFolder.put("DisplayName", DicHelper.getDic("lbl_Person_Task")); //내가 하는 일(lbl_Person_Task)
		rootFolder.put("type", "Root");
		rootFolder.put("chk", "N"); 
		rootFolder.put("nodeName", DicHelper.getDic("lbl_Person_Task")); 
		rootFolder.put("nodeValue", "0"); 
		
		retArr.add(rootFolder); //최상위 폴더 추가
		
		for(Object obj : folderList){
			CoviMap folderObj = (CoviMap)obj;
			
			folderObj.put("no", folderObj.getString("FolderID"));
			folderObj.put("pno", folderObj.has("ParentFolderID")? folderObj.getString("ParentFolderID"): "0");
			folderObj.put("nodeValue", folderObj.getString("FolderID"));
			folderObj.put("nodeName", folderObj.getString("DisplayName"));
			folderObj.put("IsShare", folderObj.getString("IsShare"));
			folderObj.put("type", "folder");
			folderObj.put("chk", "N");
			folderObj.put("childCnt", folderObj.getString("ChildCnt"));
			
			retArr.add(folderObj);
		}
		
		return retArr;
	}
	
	//같이 하는 일 트리 목록 조회
	@Override
	public CoviList getShareFolderList(CoviMap params) throws Exception {
		CoviMap userInfoObj = SessionHelper.getSession();
		
		CoviList retArr = new CoviList();
		String[] subjectArr = authorityService.getAssignedSubject(userInfoObj);
		
		params.put("subjectArr", subjectArr);
		CoviList folderList =CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.task.selectShareFolderList", params), "FolderID,ParentFolderID,DisplayName,ChildCnt");
		
		//최상위 root 폴더 생성
		CoviMap rootFolder = new CoviMap();
		rootFolder.put("FolderID", "0");
		rootFolder.put("no", "0");
		rootFolder.put("ParentFolderID", "");
		rootFolder.put("pno", "");
		rootFolder.put("DisplayName", DicHelper.getDic("lbl_Share_Task")); //같이 하는 일(lbl_Share_Task)
		rootFolder.put("type", "Root");
		rootFolder.put("chk", "N"); 
		rootFolder.put("nodeName",  DicHelper.getDic("lbl_Share_Task")); //같이 하는 일
		rootFolder.put("nodeValue", "0"); 
		
		retArr.add(rootFolder); //최상위 폴더 추가
		
		List<String> folderIDs= new ArrayList<String>();
		for(Object obj : folderList){
			folderIDs.add(((CoviMap)obj).getString("FolderID"));
		}
		
		for(Object obj : folderList){
			CoviMap folderObj = (CoviMap)obj;
			
			folderObj.put("no", folderObj.getString("FolderID"));
			folderObj.put("pno", folderObj.has("ParentFolderID")? folderObj.getString("ParentFolderID"): "0");
			folderObj.put("nodeValue", folderObj.getString("FolderID"));
			folderObj.put("nodeName", folderObj.getString("DisplayName"));
			folderObj.put("type", "folder");
			folderObj.put("chk", "N");
			folderObj.put("childCnt", folderObj.getString("ChildCnt"));
			
			//상위 항목이 없는 경우 최상위 폴더의 하위가 되도록 함
			if(!folderIDs.contains(folderObj.getString("pno"))){
				folderObj.put("pno", "0");
			}
			
			retArr.add(folderObj);
		}
		
		return retArr;
	}
	
	//전체 검색
	@Override
	public CoviMap getSearchAll(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap userInfoObj = SessionHelper.getSession();
		
		String userID = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		
		params.put("userID", userID);
		params.put("domainID", domainID);
		
		String[] subjectArr = authorityService.getAssignedSubject(userInfoObj);
		
		params.put("subjectArr", subjectArr);
		
		CoviList folderList = coviMapperOne.list("user.task.selectUserAllFolderList", params);
		CoviList taskList = coviMapperOne.list("user.task.selectUserAllTaskList", params);
		CoviList tempTaskList= coviMapperOne.list("user.task.selectUserAllTempTaskList", params);
		
		resultObj.put("FolderList", coviSelectJSONForTaskList( folderList, "FolderID,DisplayName,FolderState,FolderStateCode,IsShare,OwnerCode,RegisterCode,ParentFolderID"));
		resultObj.put("TaskList", coviSelectJSONForTaskList( taskList, "TaskID,FolderID,Subject,TaskState,TaskStateCode,TaskProgress,IsDelay,IsRead,StartDate,EndDate,RegistDate,OwnerCode,RegisterCode"));
		resultObj.put("TempTaskList",  coviSelectJSONForTaskList( tempTaskList,  "TaskID,FolderID,Subject,TaskState,TaskStateCode,IsDelay,IsRead,RegistDate,OwnerCode,RegisterCode"));
		
		return resultObj;
	}
	
	//업무관리용
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
	
	//업무관리용 
	@SuppressWarnings("unchecked")
	public  CoviMap coviSelectJSONForTaskList(CoviMap obj, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap taskDic = getTaskDic();
		CoviMap newObject = new CoviMap();
		
		for(int j=0; j<cols.length; j++){
			Set<String> set = obj.keySet();
			Iterator<String> iter = set.iterator();
			
			while(iter.hasNext()){   
				String ar = (String)iter.next();
				if(ar.equals(cols[j].trim())){
					if (ar.equals("FolderState") || ar.equals("TaskState")) {
						newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+obj.getString(cols[j])),obj.getString(cols[j]) ));	
					} else {
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
	
	//최상위 폴더 정보 조회 (하드코딩)
	private CoviMap getRootFolderInfo(String isMine) throws Exception {
		CoviMap retObj = new CoviMap();
		
		retObj.put("FolderID", "0");
		
		if(isMine.equalsIgnoreCase("Y")){
			retObj.put("ParentFolderID", "");
			retObj.put("DisplayName", DicHelper.getDic("lbl_Person_Task")); //내가 하는 일
			retObj.put("IsMine", "Y"); 
		}else{
			retObj.put("ParentFolderID", "");
			retObj.put("DisplayName", DicHelper.getDic("lbl_Share_Task")); //같이 하는 일
			retObj.put("IsMine", "N"); 
		}
		
		return retObj;
	}
	
	// 폴더 정보 조회
	@Override
	public CoviMap getFolderData(CoviMap params) throws Exception {
		CoviMap folderInfo = new CoviMap();
		
		if(params.getString("FolderID").equals("0")){
			folderInfo = getRootFolderInfo(params.getString("isMine"));
		}else{
			folderInfo =coviSelectJSONForTaskList(coviMapperOne.select("user.task.selectFolderData", params), "FolderID,ParentFolderID,DisplayName,State,FolderState,Description,IsShare,IDPath,RegisterCode,OwnerCode,RegistDate,RegisterName,Progress");
		}
		
		return folderInfo;
	}
	
	//특정 폴더의 하위 항목 조회(폴더, 업무)
	@Override
	public CoviMap getFolderItemList(CoviMap params) throws Exception {
		CoviMap userInfoObj = SessionHelper.getSession();
		String userID = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		String lang = userInfoObj.getString("lang");
		
		params.put("userID", userID);
		params.put("domainID", domainID);
		params.put("lang", lang);
		
		CoviMap resultObj = new CoviMap();
		CoviMap folderInfo = new CoviMap();
		CoviList folderList = new CoviList();
		CoviList taskList = new CoviList();
		CoviList tempTaskList = new CoviList(); // 임시저장된 업무
		CoviList allShareFolderList = new CoviList();
		List<String> folderIDs= new ArrayList<String>();
		
		params.put("subjectArr", authorityService.getAssignedSubject(userInfoObj));
		
		if(params.getString("isMine").equalsIgnoreCase("N")){
			allShareFolderList = coviSelectJSONForTaskList(coviMapperOne.list("user.task.selectAllShareFolderList", params), "FolderID,ParentFolderID,DisplayName,FolderState,FolderStateCode,IsShare,FolderProgress");
			
			for(Object obj : allShareFolderList){
				folderIDs.add( ((CoviMap)obj).getString("FolderID") );
			}
		}
		
		if(params.getString("FolderID").equals("0")){
			folderInfo = getRootFolderInfo(params.getString("isMine"));
		}else{
			folderInfo = coviSelectJSONForTaskList(coviMapperOne.select("user.task.selectFolderData", params), "FolderID,ParentFolderID,DisplayName,State,Description,IsShare,IDPath,RegisterCode,OwnerCode,RegistDate,FolderProgress");
			
			if(!folderIDs.contains(folderInfo.getString("ParentFolderID")) && params.getString("isMine").equalsIgnoreCase("N")){
				folderInfo.put("ParentFolderID", 0);
			}
		}
		
		if(params.getString("isMine").equalsIgnoreCase("N") && params.getString("FolderID").equals("0")){ //최상위 공유 폴더인 경우
			for(Object obj : allShareFolderList){
				CoviMap folderObj = (CoviMap)obj;
				
				if((!folderObj.has("ParentFolderID")) || (!folderIDs.contains(folderObj.getString("ParentFolderID")))){
					folderList.add(folderObj);
				}
			}
		}else{
			folderList =  coviSelectJSONForTaskList( coviMapperOne.list("user.task.selectFolderOfFolderList", params), "FolderID,DisplayName,FolderState,FolderStateCode,IsShare,OwnerCode,RegisterCode,ParentFolderID,FolderProgress");
			taskList = coviSelectJSONForTaskList( coviMapperOne.list("user.task.selectTaskOfFolderList", params), "TaskID,FolderID,Subject,TaskState,TaskStateCode,IsDelay,IsRead,RegistDate,OwnerCode,RegisterCode,TaskProgress");
			tempTaskList = coviSelectJSONForTaskList( coviMapperOne.list("user.task.selectTempTaskOfFolderList", params), "TaskID,FolderID,Subject,TaskState,TaskStateCode,IsDelay,IsRead,RegistDate,OwnerCode,RegisterCode,TaskProgress");
		}
		
		resultObj.put("FolderInfo", folderInfo);
		resultObj.put("FolderList", folderList);
		resultObj.put("TaskList",taskList);
		resultObj.put("TempTaskList",tempTaskList);
		
		return resultObj;
	}
	
	//폴더 정보 저장
	@Override
	public void saveFolderData(CoviMap folderObj) throws Exception {
		/* 
		 * folderObj Data Format - 추가용
		 {
			  "ParentFolderID": "7",
			  "DisplayName": "AI 사전조사",
			  "State": "Waiting",
			  "Description": "개인 비서용 AI 사전조사",
			  "RegistCode": "bjlsm2",
			  "OwnerCode": "bjlsm2",
			  "ShareMember": [
				{
				  "Code": "yjlee",
				  "Type": "UR"
				},
				{
				  "Code": "gypark",
				  "Type": "UR"
				},
				{
				  "Code": "RD2",
				  "Type": "GR"
				}
			  ]
			}
		**/
		
		//기본 정보 추가
		CoviList shareMemberList = folderObj.getJSONArray("ShareMember");
		String IsShare = (shareMemberList != null && shareMemberList.size() > 0) ? "Y" : "N";
		
		CoviMap params = new CoviMap();
		params.put("ParentFolderID", folderObj.getString("ParentFolderID").equals("0")? null : folderObj.getString("ParentFolderID"));
		params.put("DisplayName", folderObj.getString("DisplayName"));
		params.put("State", folderObj.getString("State"));
		params.put("IsShare", IsShare);
		params.put("RegisterCode", folderObj.getString("RegistCode"));
		params.put("OwnerCode", folderObj.getString("OwnerCode"));
		params.put("Description", folderObj.getString("Description"));
		params.put("Progress", folderObj.getString("Progress"));
		
		coviMapperOne.insert("user.task.insertFolderData",params);
		//공유자 정보 추가 ( 추가시 하위 폴더도 추가 - 새 폴더일 경우 )
		
		if(IsShare.equals("Y")){
			//coviMapperOne.insert("user.task.insertShareData",params);
			params.put("shareMemberList", shareMemberList);
			
			coviMapperOne.insert("user.task.insertShareMemberData",params);
			
			//알림기능추가2019.09
			notifyCreateMessage(params);
		}
		
		coviMapperOne.update("user.task.updateFolderIDPath",params); //IDPath 지정
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", params.getString("FolderID"));
			//params.put("TaskCode", jo.getString("strTaskIDX"));
			params.put("TaskName", folderObj.getString("DisplayName"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",folderObj.getString("State"));
			params.put("TaskPercent", folderObj.getString("Progress"));
			params.put("TaskEtc", folderObj.getString("Description"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//폴더 정보 수정
	@SuppressWarnings("unchecked")
	@Override
	public void modifyFolderData(CoviMap folderObj) throws Exception {
		/*  
		 *  folderObj Data Format - 수정용
		 {
		 	  "FolderID" : "8",
		 	  "ParentFolderID" : "1",
			  "DisplayName": "AI 사전조사",
			  "State": "Waiting",
			  "Description": "개인 비서용 AI 사전조사",
			  "ShareMember": [
				{
				  "Code": "yjlee",
				  "Type": "UR"
				},
				{
				  "Code": "gypark",
				  "Type": "UR"
				},
				{
				  "Code": "RD2",
				  "Type": "GR"
				}
			  ]
			}
		**/
		
		//기본 정보 수정
		CoviList newShareMemberList = folderObj.getJSONArray("ShareMember");
		String IsShare = (newShareMemberList != null && newShareMemberList.size() > 0) ? "Y" : "N";
		
		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("FolderID", folderObj.getString("FolderID"));
		params.put("DisplayName", folderObj.getString("DisplayName"));
		params.put("State", folderObj.getString("State"));
		params.put("Description", folderObj.getString("Description"));
		params.put("IsShare", IsShare);
		params.put("Progress", folderObj.getString("Progress"));
		
		coviMapperOne.update("user.task.updateFolderData",params);
		
		//공유 정보 수정
		//List<String> childFolderList;
		Set<String> childFolderList = new HashSet<String>();
		
		String strChildFolders = coviMapperOne.getString("user.task.selectChildFolder",params); //하위 항목 조회 (자기 자신 제외)
		
		if(StringUtil.isNull(strChildFolders)){
			childFolderList = new HashSet<String>();
		}else{
			childFolderList = new HashSet<String>(Arrays.asList(strChildFolders.split(";")));
		}
		
		CoviList oldList = coviMapperOne.list("user.task.selectOldShareMember",params);
		
		childFolderList.add(folderObj.getString("FolderID")); //자기 자신 추가
		
		//기존 공유데이터 정보가 있을 경우
		if(oldList.size() > 0){
			params.put("childFolderList", childFolderList);
			params.put("ShareMemberList", oldList);
			
			coviMapperOne.delete("user.task.deleteShareMemberData",params); //자기 자신 및 하위에 있는 이전 공유 정보 삭제
		}
		
		if(newShareMemberList != null && newShareMemberList.size() > 0){
			params.put("childFolderList", childFolderList);
			params.put("ShareMemberList", newShareMemberList);
			
			coviMapperOne.delete("user.task.deleteShareMemberData", params); //자기 자신 및 하위에 있는 새로운 공유 정보 삭제 ( 중복 방지 ) 
			coviMapperOne.insert("user.task.insertModifyShareMemberData", params); //insert
		}
		// 공유자가 아닌 수행자 정보 지우기
		if(oldList.size() > 0){
			CoviMap tmpParam = new CoviMap();
			tmpParam.addAll(params);
			
			//1. chile 폴더를 순서대로 돌기
			for(Iterator iter = childFolderList.iterator(); iter.hasNext();){
				tmpParam.put("FolderID",iter.next());
				
				//2. 폴더 정보 조회
				CoviMap tmpFolder = getFolderData(tmpParam);
				
				//3. 해당 폴더의 공유자 목록 조회
				/*CoviList shareMember = coviMapperOne.list("user.task.selectOldShareMember",tmpParam);
				
				CoviMap register = new CoviMap();
				register.put("Code", tmpFolder.getString("RegisterCode"));
				register.put("Type", "UR");
				shareMember.add(register);
				
				CoviMap owner = new CoviMap();
				owner.put("Code", tmpFolder.getString("OwnerCode"));
				owner.put("Type", "UR");
				shareMember.add(owner);
				
				tmpParam.put("shareMemberList", shareMember);*/
				
				//4. 공유자 목록에 속한 사람들 조회(소유자랑 등록자는 추가)
				CoviList shareUserList = coviMapperOne.list("user.task.selectShareMemberUserSimple", tmpParam);
				
				//5. 멤버에 속하지 않은 사람 모두 삭제
				tmpParam.put("shareUserList", shareUserList);
				coviMapperOne.delete("user.task.deleteNoSharePerformer",tmpParam);
			}
		}
		
		//member 여부에 따라 folder IsShare 을 변경
		coviMapperOne.update("user.task.updateIsShare",params);
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", params.getString("FolderID"));
			//params.put("TaskCode", jo.getString("strTaskIDX"));
			params.put("TaskName", folderObj.getString("DisplayName"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",folderObj.getString("State"));
			params.put("TaskPercent", folderObj.getString("Progress"));
			params.put("TaskEtc", folderObj.getString("Description"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//폴더 정보 삭제
	@Override
	public void deleteFolderData(CoviMap params) throws Exception {
		List<String> childFolderList;
		String strChildFolders = coviMapperOne.getString("user.task.selectChildFolder",params); //하위 항목 조회 (자기 자신 제외)
		
		if(StringUtil.isNull(strChildFolders)){
			childFolderList = new ArrayList<String>();
		}else{
			childFolderList = new ArrayList<String>(Arrays.asList(strChildFolders.split(";")));
		}
		childFolderList.add(params.getString("FolderID"));  //자기 자신 추가
		params.put("childFolderList", childFolderList);
		
		coviMapperOne.update("user.task.deleteFolderData",params); // 쿼리 내부에서 하위 항목도 삭제
	}
	
	//업무 정보 저장
	@SuppressWarnings("unchecked")
	@Override
	public void saveTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 저장용
		 {
		  "FolderID": "8",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "inlineImage": "",
		  "Description": "지난 조사를 참고하여 작성",
		  "RegisterCode": "bjlsm2",
		  "OwnerCode": "bjlsm2",
		  "PerformerList": [
			{
			  "PerformerCode": "yjlee"
			},
			{
			  "PerformerCode": "gypark"
			},
			{
			  "PerformerCode": "RD2"
			}
		  ]
		}
		**/
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		
		//기본 정보 저장
		CoviMap params = new CoviMap();
		params.put("FolderID", taskObj.getString("FolderID"));
		params.put("Subject", taskObj.getString("Subject"));
		params.put("Description", editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("Progress", taskObj.getString("Progress"));
		params.put("OwnerCode", taskObj.getString("OwnerCode"));
		params.put("RegisterCode", taskObj.getString("RegisterCode"));
		params.put("Mode", taskObj.getString("Mode"));
		if(!taskObj.getString("StartDate").equals("")){ params.put("StartDate", taskObj.getString("StartDate")); }
		if(!taskObj.getString("EndDate").equals("")){ params.put("EndDate", taskObj.getString("EndDate")); }
		
		coviMapperOne.insert("user.task.insertTaskData", params);
		
		String taskID = params.getString("TaskID");
		String taskFolderID = taskObj.getString("FolderID");
		
		editorParam.put("messageID", taskID);
		editorParam.addAll(editorInfo);
		
		editorService.updateFileMessageID(editorParam);
		
		//수행자 정보 저장
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		//수행자가 지정된 경우 실행
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.task.insertTaskPerformerData", params);
			
			//알림기능추가2019.09
			params.put("userCode", params.getString("RegisterCode"));
			notifyCreateMessage(params);
		}
		
		// 작성자 읽음 정보 저장
		params.put("UserID",params.getString("RegisterCode"));
		coviMapperOne.insert("user.task.insertTaskReadData", params);
		
		
		// [Added][FileUpload]
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", taskID);
			filesParams.put("ObjectID", taskFolderID);
			filesParams.put("ObjectType", "TKFD");
			insertTaskSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", taskFolderID);
			params.put("TaskCode", taskID);
			params.put("TaskName", taskObj.getString("Subject"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", editorInfo.getString("BodyHtml"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//업무 정보 수정
	@Override
	public void modifyTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 수정
		 {
		  "TaskID": "1",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "Description": "지난 조사를 참고하여 작성",
		  "PerformerList": [  ]
		}
		 * */
		
		String taskID = taskObj.getString("TaskID");
		String taskFolderID = taskObj.getString("FolderID");
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", taskObj.getString("TaskID"));
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		
		//기본 정보 수정
		CoviMap params = new CoviMap();
		params.put("TaskID", taskObj.getString("TaskID"));
		params.put("Subject", taskObj.getString("Subject"));
		params.put("Description",  editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("Progress", taskObj.getString("Progress"));
		params.put("Mode", taskObj.getString("Mode"));
		
		if(!taskObj.getString("StartDate").equals("")){
			params.put("StartDate", taskObj.getString("StartDate"));
		}
		if(!taskObj.getString("EndDate").equals("")){
			params.put("EndDate", taskObj.getString("EndDate"));
		}
		
		
		coviMapperOne.update("user.task.updateTaskData",params);
		
		//수행자 정보 수정
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		coviMapperOne.delete("user.task.deleteTaskPerformerData", params);
		
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.task.insertTaskPerformerData",params);
		}
		
		// [Added][FileUpload]
		if(fileInfos != null){
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", taskID);
			filesParams.put("ObjectID", taskFolderID);
			filesParams.put("ObjectType", "TKFD");
			updateTaskSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", taskObj.getString("FolderID"));
			params.put("TaskCode", taskObj.getString("TaskID"));
			params.put("TaskName", taskObj.getString("Subject"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", editorInfo.getString("BodyHtml"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//업무 정보 저장
	@SuppressWarnings("unchecked")
	@Override
	public void saveTaskDataMobile(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 저장용
		 {
		  "FolderID": "8",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "inlineImage": "",
		  "Description": "지난 조사를 참고하여 작성",
		  "RegisterCode": "bjlsm2",
		  "OwnerCode": "bjlsm2",
		  "PerformerList": [
			{
			  "PerformerCode": "yjlee"
			},
			{
			  "PerformerCode": "gypark"
			},
			{
			  "PerformerCode": "RD2"
			}
		  ]
		}
		 * */
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", "0");
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		
		//기본 정보 저장
		CoviMap params = new CoviMap();
		params.put("FolderID", taskObj.getString("FolderID"));
		params.put("Subject", taskObj.getString("Subject"));
		params.put("Description", editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("OwnerCode", taskObj.getString("OwnerCode"));
		params.put("RegisterCode", taskObj.getString("RegisterCode"));
		params.put("Progress", taskObj.getString("Progress"));
		params.put("Mode", taskObj.getString("Mode"));
		if(! taskObj.getString("StartDate").equals("")){ params.put("StartDate", taskObj.getString("StartDate")); }
		if(! taskObj.getString("EndDate").equals("")){ params.put("EndDate", taskObj.getString("EndDate")); }
		
		coviMapperOne.insert("user.task.insertTaskData", params);
		
		String taskID = params.getString("TaskID");
		String taskFolderID = taskObj.getString("FolderID");
		
		editorParam.put("messageID", taskID);
		editorParam.addAll(editorInfo);
		
		editorService.updateFileMessageID(editorParam);
		
		//수행자 정보 저장
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		//수행자가 지정된 경우 실행
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.task.insertTaskPerformerData",params);
		}
		
		// 작성자 읽음 정보 저장
		params.put("UserID",params.getString("RegisterCode"));
		coviMapperOne.insert("user.task.insertTaskReadData", params);
		
		// [Added][FileUpload]
		if(fileInfos != null){
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", taskID);
			filesParams.put("ObjectID", taskFolderID);
			filesParams.put("ObjectType", "TKFD");
			insertTaskSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", taskObj.getString("FolderID"));
			params.put("TaskCode", taskID);
			params.put("TaskName", taskObj.getString("Subject"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", editorInfo.getString("BodyHtml"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	//업무 정보 수정
	@Override
	public void modifyTaskDataMobile(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		/*
		 * taskObj Data Format - 수정
		 {
		  "TaskID": "1",
		  "Subject": "기능명세서 작성",
		  "State": "Waiting",
		  "StartDate": "2017-10-18",
		  "EndDate": "2017-10-19",
		  "Description": "지난 조사를 참고하여 작성",
		  "PerformerList": [  ]
		}
		 * */
		
		String taskID = taskObj.getString("TaskID");
		String taskFolderID = taskObj.getString("FolderID");
		
		//Editor 처리
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Task");
		editorParam.put("imgInfo", taskObj.getString("InlineImage"));
		editorParam.put("objectID", taskObj.getString("FolderID"));
		editorParam.put("objectType", "TKFD");
		editorParam.put("messageID", taskObj.getString("TaskID"));
		editorParam.put("bodyHtml",taskObj.getString("Description"));
		
		CoviMap editorInfo = editorService.getContent(editorParam);
		
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		
		//기본 정보 수정
		CoviMap params = new CoviMap();
		params.put("TaskID", taskObj.getString("TaskID"));
		params.put("Subject", taskObj.getString("Subject"));
		params.put("Description",  editorInfo.getString("BodyHtml"));
		params.put("State", taskObj.getString("State"));
		params.put("Mode", taskObj.getString("Mode"));
		
		if(!taskObj.getString("StartDate").equals("")){
			params.put("StartDate", taskObj.getString("StartDate"));
		}
		if(!taskObj.getString("EndDate").equals("")){
			params.put("EndDate", taskObj.getString("EndDate"));
		}
		params.put("Progress", taskObj.getString("Progress"));
		
		
		coviMapperOne.update("user.task.updateTaskData", params);
		
		//수행자 정보 수정
		CoviList performerList = taskObj.getJSONArray("PerformerList");
		
		coviMapperOne.delete("user.task.deleteTaskPerformerData", params);
		
		if(performerList != null && performerList.size() > 0){
			params.put("arrPerformer", performerList);
			
			coviMapperOne.insert("user.task.insertTaskPerformerData", params);
		}
		
		// [Added][FileUpload]
		if(fileInfos != null){
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", taskID);
			filesParams.put("ObjectID", taskFolderID);
			filesParams.put("ObjectType", "TKFD");
			updateTaskSysFile(filesParams, mf);
		}
		
		//업무보고추가2019.10
		if(RedisDataUtil.getBaseConfig("IsUseReportSave").equalsIgnoreCase("Y")){
			params.put("TaskFolderCode", taskObj.getString("FolderID"));
			params.put("TaskCode", taskObj.getString("TaskID"));
			params.put("TaskName", taskObj.getString("Subject"));
			//params.put("TaskDate", jo.getString("strTaskDate"));
			params.put("TaskHour", "0");
			params.put("TaskStatusCode",taskObj.getString("State"));
			params.put("TaskPercent", taskObj.getString("Progress"));
			params.put("TaskEtc", editorInfo.getString("BodyHtml"));
			params.put("TaskMemCode", SessionHelper.getSession("USERID"));
			params.put("TaskMemDeptCode", SessionHelper.getSession("GR_Code"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("TaskGubunCode", "T");
			coviMapperOne.insert("user.bizreport.insertTaskReport", params);
		}
	}
	
	/*
	 * isDuplicationName: 한 폴더 내 동일한 타입의 이름 중복 확인 (overloading - 복사/이동용)
	 * type: Folder OR Task
	 * originID: FolderID OR TaskID
	 * targetID: 이동할 FolderID
	 * isCopy: 복사일 경우 Y , 이동일 경우 N
	 */
	@Override
	public CoviMap isDuplicationName(String type, String originID, String targetFolderID, String isCopy) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String ownerCode = SessionHelper.getSession("USERID"); //복사 이동은 내 업무 내 가능하므로 세션값 사용
		String originName = "";
		String tempName = "";
		
		CoviMap params = new CoviMap();
		params.put("isCopy", isCopy);
		params.put("targetFolderID", targetFolderID);
		
		if(type.equalsIgnoreCase("FOLDER")){
			params.put("originFolderID", originID);
			
			originName = coviMapperOne.getString("user.task.selectOrginFolderName", params);
			tempName = originName;
			
			int loopCnt = 0; //중복 횟수;
			int dupCnt = 0 ;
			
			while(true){
				params.put("folderName", tempName);
				params.put("targetFolderID", targetFolderID);
				params.put("ownerCode", ownerCode);
				
				dupCnt = (int)coviMapperOne.getNumber("user.task.checkDuplicationFolder", params);
				
				if(dupCnt > 0 ){
					tempName = originName +" ("+ (loopCnt+1) + ")";
				}else{
					break;
				}
				
				loopCnt++;
			}
			
			returnObj.put("saveName",tempName);
			if(loopCnt <= 0){
				returnObj.put("isDuplication",  "N"); // Y: 중복, N: 중복X
			}else{
				returnObj.put("isDuplication",  "Y"); // Y: 중복, N: 중복X
			}
			
		}else if(type.equalsIgnoreCase("TASK")){
			params.put("originTaskID", originID);
			
			originName = coviMapperOne.getString("user.task.selectOrginTaskName", params);
			tempName = originName;
			
			int loopCnt = 0; //중복 횟수;
			int dupCnt = 0 ;
			
			while(true){
				params.put("taskName", tempName);
				params.put("targetFolderID", targetFolderID);
				params.put("ownerCode", ownerCode);
				
				dupCnt = (int)coviMapperOne.getNumber("user.task.checkDuplicationTask", params);
				
				if(dupCnt > 0 ){
					tempName = originName + " (" + (loopCnt+1) + ")";
				}else{
					break;
				}
				
				loopCnt++;
			}
			
			returnObj.put("saveName", tempName);
			if(loopCnt <= 0){
				returnObj.put("isDuplication", "N"); // Y: 중복, N: 중복X
			}else{
				returnObj.put("isDuplication", "Y"); // Y: 중복, N: 중복X
			}
		}else{
			returnObj.put("isDuplication", "Y"); // Y: 중복, N: 중복X
			returnObj.put("saveName", ""); 
		}
		
		return returnObj;
	}
	
	/*
	 * isDuplicationSaveName: 한 폴더 내 동일한 타입의 이름 중복 확인 (저장 수정 용)
	 * type: Folder OR Task
	 * originName: 저장명
	 * originID: 수정 시 사용( 기존 폴더 또는 업무 ID)
	 * targetFolderID: 저장될 폴더 위치
	 * isModify: Y or N
	 */
	@Override
	public CoviMap isDuplicationSaveName(String type, String originName, String originID, String targetFolderID, String isModify) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String ownerCode = SessionHelper.getSession("USERID"); //folderID가 0일 때 필요, 공유는 0에 수정, 삭제 못하므로 세션값 사용
		String tempName = "";
		
		CoviMap params = new CoviMap();
		params.put("isModify", isModify);
		params.put("targetFolderID", targetFolderID);
		
		if(type.equalsIgnoreCase("FOLDER")){
			params.put("originFolderID", originID);
			tempName = originName;
			
			int loopCnt = 0; //중복 횟수;
			int dupCnt = 0 ;
			
			while(true){
				params.put("folderName", tempName);
				params.put("ownerCode", ownerCode);
				
				dupCnt = (int)coviMapperOne.getNumber("user.task.checkDuplicationFolder", params);
				
				if(dupCnt > 0 ){
					tempName = originName + " (" + (loopCnt+1) + ")";
				}else{
					break;
				}
				
				loopCnt++;
			}
			
			returnObj.put("saveName",tempName);
			if(loopCnt <= 0){
				returnObj.put("isDuplication",  "N");  // Y: 중복, N: 중복X
			}else{
				returnObj.put("isDuplication",  "Y");  // Y: 중복, N: 중복X
			}
		}else if(type.equalsIgnoreCase("TASK")){
			params.put("originTaskID", originID);
			tempName = originName;
			
			int loopCnt = 0; //중복 횟수;
			int dupCnt = 0 ;
			
			while(true){
				params.put("taskName", tempName);
				params.put("ownerCode", ownerCode);
				params.put("targetFolderID", targetFolderID);
				
				dupCnt = (int)coviMapperOne.getNumber("user.task.checkDuplicationTask", params);
				
				if(dupCnt > 0 ){
					tempName = originName + " (" + (loopCnt+1) + ")";
				}else{
					break;
				}
				
				loopCnt++;
			}
			
			returnObj.put("saveName", tempName);
			if(loopCnt <= 0){
				returnObj.put("isDuplication", "N"); // Y: 중복, N: 중복X
			}else{
				returnObj.put("isDuplication", "Y"); // Y: 중복, N: 중복X
			}
		}else{
			returnObj.put("isDuplication", "Y"); // Y: 중복, N: 중복X
			returnObj.put("saveName", "");  
		}
		
		return returnObj;
	}
	
	//업무 복사
	@Override
	public void copyTask(CoviMap params) throws Exception {
		coviMapperOne.insert("user.task.copyTask", params);
		coviMapperOne.insert("user.task.copyTaskFile", params);
		
		params.put("UserID", params.getString("RegisterCode"));
		coviMapperOne.insert("user.task.insertTaskReadData", params);
		//coviMapperOne.insert("user.task.copyTaskPerformer",params); //수행자가 공유자이기 때문에 발생하는 문제점으로 인해 복사 시 수행자 정보 저장 X
	}
	
	//업무 정보 삭제
	@Override
	public void deleteTaskData(CoviMap params) throws Exception {
		coviMapperOne.update("user.task.deleteTaskData",params);
	}
	
	//업무 이동
	@Override
	public void moveTask(CoviMap params) throws Exception {
		coviMapperOne.update("user.task.moveTaskFile", params);
		coviMapperOne.update("user.task.moveTask", params);
		coviMapperOne.delete("user.task.deletePerformerData", params);
	}
	
	//하위 항목에 공유 항목이 있는지 조회
	@Override
	public String isHaveShareChild(String folderID) throws Exception {
		String retVal ="Y"; //Y: 하위 중 공유 폴더가 있음, N:하위 중 공유 폴더가 있음
		
		CoviMap params = new CoviMap();
		params.put("FolderID",folderID);
		
		List<String> childFolderList;
		String strChildFolders = coviMapperOne.getString("user.task.selectChildFolder",params); //하위 항목 조회 (자기 자신 제외)
		
		if(StringUtil.isNull(strChildFolders)){
			 childFolderList = new ArrayList<String>();
		}else{
			childFolderList = new ArrayList<String>(Arrays.asList(strChildFolders.split(";")));
		}
		
		childFolderList.add(folderID); // 자기 자신 추가
		
		params.put("childFolderList", childFolderList);
		int shareChildCnt = (int)coviMapperOne.getNumber("user.task.selectShareChildCnt",params);
		
		if(shareChildCnt>0){
			retVal = "Y";
		}else{
			retVal = "N";
		}
		
		return retVal;
	}
	
	//하위 항목 소유 여부 반환
	@Override
	public String isHaveChild(String folderID) throws Exception {
		String retVal ="Y"; //Y: 하위 폴더가 있음, N:하위  폴더가 없음
		
		CoviMap params = new CoviMap();
		params.put("FolderID",folderID);
		
		String strChildFolders = coviMapperOne.getString("user.task.selectChildFolder",params); //하위 항목 조회 (자기 자신 제외)
		
		if(StringUtil.isNull(strChildFolders)){
			retVal = "N";
		}else{
			retVal = "Y";
		}
		
		return retVal;
	}
	
	//폴더 이동
	@Override
	public void moveFolder(CoviMap params) throws Exception {
		//폴더 위치 이동
		coviMapperOne.update("user.task.moveFolder",params);
		
		params.put("FolderID", params.getString("originFolderID"));
		//IDPath 변경
		List<String> childFolderList;
		String strChildFolders = coviMapperOne.getString("user.task.selectChildFolder",params); //하위 항목 조회 (자기 자신 제외)
		
		if(StringUtil.isNull(strChildFolders)){
			 childFolderList = new ArrayList<String>();
		}else{
			childFolderList = new ArrayList<String>(Arrays.asList(strChildFolders.split(";")));
		}
		childFolderList.add(params.getString("originFolderID"));  //자기 자신 추가
		
		params.remove("FolderID");
		params.put("childFolderList",childFolderList);
		coviMapperOne.update("user.task.updateFolderIDPath",params); //자신과 하위 항목의 IDPath update
		
		//상위 폴더들의 공유자 정보를 조회하여 이동할 폴더와 폴더들의 하위에 insert
		if(params.get("targetFolderID") != null ){
			/* 하위 항목에 공유 폴더가 있을 경우 이동이 불가능 하므로 주석 처리	
			params.put("ShareMemberList",coviMapperOne.list("user.task.selectTargetFolderShareMember",params));
			coviMapperOne.delete("user.task.deleteShareMemberData",params); //자기 자신 및 하위에 있는 새로운 공유 정보 삭제 ( 중복 방지 )
			*/
			CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.task.insertParentShareMemberToFolder", params), "Code,Type");
		}
		//member여부에 따라 folder IsShare을 변경
		coviMapperOne.update("user.task.updateIsShare",params);
	}
	
	//폴더 접근 권한 체크
	@Override
	public boolean checkAuthority(CoviMap params) throws Exception {
		boolean retVal = false;
		
		CoviMap userInfoObj = SessionHelper.getSession();
		String userID = userInfoObj.getString("USERID");
		
		params.put("userID", userID);
		params.put("subjectArr", authorityService.getAssignedSubject(userInfoObj));
		
		if(params.getString("FolderID").equals("0")){
			return true;
		}
		CoviList folderList = coviMapperOne.list("user.task.selectUserAllFolderList", params);
		
		for(Object map : folderList){
			String objFolderID = ((CoviMap)map).getString("FolderID");
			
			if(objFolderID.equals(params.getString("FolderID"))){
				retVal = true;
				break;
			}
		}
		
		return retVal;
	}
	
	//폴더의 공유자 목록 조회
	@Override
	public CoviList getFolderShareMember(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.task.selectFolderShareMember", params), "ShareID,Code,Type,Name,DeptName");
	}
	
	//상위 폴더의 공유 멤버 조회
	@Override
	public CoviList getParentFolderShareMember(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.task.selectParentFolderShareMember", params), "Code,Type,Name,DeptName");
	}
	
	//특정 Task 정보 조회
	@Override
	public CoviMap getTaskData(CoviMap params) throws Exception {
		return coviSelectJSONForTaskList(coviMapperOne.select("user.task.selectTaskData", params), "TaskID,FolderID,FolderName,Subject,Description,TaskState,TaskStateCode,StartDate,EndDate,RegistDate,RegistDate,OwnerCode,RegisterCode,RegisterName,DeleteDate,IsTempSave,Progress");
	}
	
	// 수행자 정보 조회
	@Override
	public CoviList getTaskPerformer(CoviMap params) throws Exception {
		return coviSelectJSONForTaskList(coviMapperOne.list("user.task.selectTaskPerformerList", params),"Code,Type,Name,DeptName");
	}
	
	// 특정 폴더에 조회 권한이 있는 모든 사용자 조회
	@SuppressWarnings("unchecked")
	@Override
	public CoviMap getShareUseList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		int cnt = 0;
		
		if(params.containsKey("pageNo") && (params.get("KeyWord") == null || "".equals(params.getString("KeyWord")))) {
 			cnt = (int)coviMapperOne.getNumber("user.task.selectShareMemberUserCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}
		
		// ※ 속도개선 Query : selectOldShareMember, selectFolderData 사용하지않고, Query 통합/개선하여 execution time 을 30% 정도 줄임
		CoviList list = coviMapperOne.list("user.task.selectShareMemberUser", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Code,Name,Type,DeptName,PhotoPath"));
		
		return resultList;
	}
	
	//업무 읽음 정보 확인 및 저장
	@Override
	public void checkTaskReadData(CoviMap params) throws Exception {
		int cnt = (int)coviMapperOne.getNumber("user.task.selectTaskReadDataCnt", params);
		
		if(cnt < 1){
			coviMapperOne.insert("user.task.insertTaskReadData",params);
		}
	}
	
	@Override
	public int selectTaskSearchListCnt(CoviMap params) throws Exception {
		CoviMap userInfoObj = SessionHelper.getSession();
		String[] subjectArr = authorityService.getAssignedSubject(userInfoObj);
		
		params.put("subjectArr", subjectArr);
		
		return (int) coviMapperOne.getNumber("user.task.selectTaskSearchListCnt", params);
	}
	
	@Override
	public CoviMap selectTaskSearchList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap userInfoObj = SessionHelper.getSession();
		String[] subjectArr = authorityService.getAssignedSubject(userInfoObj);
		
		params.put("subjectArr", subjectArr);
		CoviList list = coviMapperOne.list("user.task.selectTaskSearchList", params);
		
		resultList.put("list", coviSelectJSONForTaskList(list, "TaskID,FolderID,Subject,TaskState,TaskStateCode,TaskProgress,IsDelay,IsRead,RegistDate,RegisterCode,OwnerCode,OwnerName"));
		return resultList;
	}
	
	// 상세일정등록시 파일첨부에 사용
	public void insertTaskSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		String uploadPath = params.getString("ServiceType") + File.separator;
		String orgPath = params.getString("ServiceType") + File.separator;
		
		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath, params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
	}
	
	// 일정수정시 파일정보 수정
	public void updateTaskSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		// 파일을 모두 삭제후 수정누를 경우 삭제처리
		String uploadPath = params.getString("ServiceType") + File.separator;
		if("0".equals(params.get("fileCnt"))){
			//fileSvc.deleteFileDb(params);
			fileSvc.clearFile(uploadPath, params.getString("ServiceType") ,params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"));
		} else {
			CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
			
			CoviMap filesParams = new CoviMap();
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mf, uploadPath , params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
		}
	}
	
	//알림기능 추가 시작
	//폴더공유알림
	private void notifyCreateMessage(CoviMap params) throws Exception {
		String goToUrl = createMessageUrl(params);
		String mobileUrl = createMessageMobileUrl(params);
		String Receivers = "";
		CoviMap notiParams = new CoviMap();
		
		// MessageContext용 파라미터 세팅
		params.put("bizSection", "Task");
		params.put("GotoURL", goToUrl);
		
		notiParams.put("ServiceType", "Task");
		if(params.containsKey("ParentFolderID")){
			notiParams.put("MsgType", "TaskFolderRegist");
			notiParams.put("MessagingSubject", params.getString("DisplayName"));
			notiParams.put("ReceiverText", params.getString("DisplayName"));
		}else{
			notiParams.put("MsgType", "TaskRegist");
			notiParams.put("MessagingSubject", params.getString("Subject"));
			notiParams.put("ReceiverText", params.getString("Subject"));
		}
		
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", mobileUrl);
		//notiParams.put("MessageContext", createMessageContext(params));
		notiParams.put("MessageContext", (params.containsKey("Subject")? params.get("Subject"):params.get("DisplayName")));
		notiParams.put("SenderCode", params.getString("userCode"));
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("DomainID", SessionHelper.getSession("DN_ID"));
		
		if(params.containsKey("ParentFolderID")){
			CoviList shareMemberList = (CoviList)params.get("shareMemberList");
			StringBuffer buf = new StringBuffer();
			for (int i=0; i < shareMemberList.size(); i++) {
				CoviMap shareMemberData = shareMemberList.getJSONObject(i);
			
				String memberCode = shareMemberData.getString("Code");
				String memberType = shareMemberData.getString("Type");
				if(memberType.equals("UR")){
					buf.append(";").append(memberCode);
				}
			}
			Receivers = buf.toString();
		}else{
			CoviList performerList = (CoviList)params.get("arrPerformer");
			StringBuffer buf = new StringBuffer();
			for (int i=0; i < performerList.size(); i++) {
				CoviMap performerData = performerList.getJSONObject(i);
			
				String memberCode = performerData.getString("PerformerCode");
				buf.append(";").append(memberCode);
			}
			Receivers = buf.toString();
		}
		
		if(Receivers.length() > 0){
			notiParams.put("ReceiversCode", Receivers.substring(1));		//공유자
			MessageHelper.getInstance().createNotificationParam(notiParams);
			messageSvc.insertMessagingData(notiParams);
		}
	}
	
	//URL생성
	public String createMessageUrl(CoviMap params){
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();
		
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
		}
		
		//Folder 공유인 경우 - task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID=45&isMine=N
		if(params.containsKey("ParentFolderID")){
			returnUrl += String.format("/%s/%s/%s","groupware", "layout", "task_ItemList.do");	// {Domain}/groupware/layout/task_ItemList.do
			returnUrl += "?CLSYS=task&CLMD=user&CLBIZ=Task&isMine=N&folderID=" + params.get("FolderID");
		} else {//Task 수행자인 경우 - /groupware/task/goTaskSetPopup.do?mode=Modify&amp;isOwner=Y&amp;taskID=10&amp;folderID=0&amp;isSearch=undefined
			returnUrl += String.format("/%s/%s/%s","groupware", "task", "goTaskSetPopup.do");	// {Domain}/groupware/task/goTaskSetPopup.do
			returnUrl += "?CLSYS=task&CLMD=user&CLBIZ=Task&isOwner=N";
			returnUrl += String.format("&taskID=%s&folderID=%s", params.get("TaskID"), params.get("FolderID"));
			returnUrl += "&mode=Modify&isSearch=undefined";
		}
		
		return returnUrl;
	}
	
	public String createMessageMobileUrl(CoviMap params){
		String returnUrl = "";
		
		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if(params.containsKey("ParentFolderID")){//groupware/mobile/task/list.do?folderid=0&ismine=N
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "task", "list.do");	// {Domain}//groupware/mobile/board/view.do
			returnUrl += String.format("?folderid=%s&ismine=N",params.get("FolderID"));
		} else {//groupware/mobile/task/view.do?taskid=65&folderid=9&isowner=Y&ismine=N
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "task", "view.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?taskid=" + params.get("TaskID");
			returnUrl += "&folderid=" + params.get("FolderID");
			returnUrl += "&isowner=N";
			returnUrl += "&ismine=N";
		}
		
		return returnUrl;
	}
	
	public String createMessageContext(CoviMap params){
		String strHTML = "";	//알림 메일 본문
		
		strHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>";
		strHTML += "<body>"
				+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
						+ "<tr>"
						+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
								+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
										+ "<tr>"
										+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
										+ DicHelper.getDic("BizSection_" + params.getString("bizSection")) + "(" + params.get("bizSection") + ")"	//Title
										+"</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>"
						+ "<tr>"
						+ "<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">"
								+ "<!-- 문서현황 시작-->"
								+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">"
										+ "<tr>"
										+ "<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">"
												+ "<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">"
												+ (params.containsKey("Subject")? params.get("Subject"):params.get("DisplayName"))		//Context
												+ "</span>"
												+ " <br />"
										+ "</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>";
		strHTML += "</table></td></tr>"
				+ "<tr>"
				+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">"
						+ "<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
								+ "<tr>"
								+ "<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">"
										+ "Title"
								+ "</th>"
								+ "<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">"
										+ "<a href=\""+ params.get("GotoURL")	//URL : 페이지 연결 URL
												+ "\" style=\"cursor: pointer;\">"
										+ (params.containsKey("Subject")? params.get("Subject"):params.get("DisplayName"))	//SUBJECT : 제목
										+ "</a>"
								+ "</td>"
								+ "</tr>"
						+ "</table>"
				+ "</td>"
				+ "</tr>"
				+ "</table></td></tr>";
		strHTML += "</table></body></html>";
		return strHTML;
	}
}
