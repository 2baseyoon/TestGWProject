package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;

import javax.annotation.Resource;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service("CollabProjectSvc")
public class CollabProjectSvcImpl extends EgovAbstractServiceImpl implements CollabProjectSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	
	
	@Autowired
	private FileUtilService fileUtilService;
	
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	public static final String fileSvcType = "CollabPrj";
	public static final String fileSvcPath = fileSvcType + "/";

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트등록
	 * @throws Exception
	 */
	public CoviMap addProject(CoviMap params, List objMember, List objManager, List objViewer, List objUserForm, MultipartFile[] mf) throws Exception {
		int cnt = coviMapperOne.insert("collab.project.addProject", params);
//		return params.getInt("ProSeq") ;
		params.put("prjSeq", params.getInt("PrjSeq"));
		params.put("memberList", objMember);
		params.put("managerList", objManager);
		params.put("viewerList", objViewer);
		params.put("userFormList", objUserForm);
		
		if (objMember != null && objMember.size()>0){
			coviMapperOne.insert("collab.project.addProjectMember", params);
		}
		if (objManager != null  && objManager.size()>0){
			coviMapperOne.insert("collab.project.addProjectManager", params);		
		}	
		if (objViewer != null  && objViewer.size()>0){
			coviMapperOne.insert("collab.project.addProjectViewer", params);		
		}	
		if (objUserForm != null  && objUserForm.size()>0){
			coviMapperOne.insert("collab.project.addProjectUserForm", params);		
		}	
	
		if(mf != null && mf.length>0) {
			String prjSeq = params.getString("prjSeq");
			List<MultipartFile> mockedFileList = new ArrayList<>();
			for (int i=0; i <mf.length; i++){
				if(mf[i] != null && mf[i].getSize()>0) {
					mockedFileList.add(mf[i]);
				}	
			}
			CoviList fileObj = fileUtilService.uploadToBack(null, mockedFileList, fileSvcPath, fileSvcType, prjSeq, "NONE", "0", false);
		}	

		return params;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트등록
	 * @throws Exception
	 */
	@Override
	public CoviMap addProjectByTmpl(CoviMap params, List objMember, List objManager) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.addProjectByTmpl", params);
		params.put("prjSeq", params.getInt("PrjSeq"));
		cnt = coviMapperOne.insert("collab.project.addProjectUserformByTmpl", params);
		cnt = coviMapperOne.insert("collab.project.addProjectSectionByTmpl", params);
		
		params.put("managerList", objManager);
		params.put("memberList", objMember);
		cnt = coviMapperOne.insert("collab.project.addProjectManager", params);
		cnt = coviMapperOne.insert("collab.project.addProjectMember", params);
		
		List taskList = coviMapperOne.selectList("collab.project.getTmplTaskList", params);
		for (int i=0; i < taskList.size(); i++){
			CoviMap taskMap = (CoviMap)taskList.get(i);
			//System.out.println(taskMap.toString());
			if (taskMap.get("taskName") == null || taskMap.get("taskName").equals("")) continue;
			
			taskMap.put("CompanyCode", params.get("CompanyCode"));
			taskMap.put("USERID", params.get("USERID"));
			taskMap.put("prjSeq", params.getInt("PrjSeq"));
			taskMap.put("prjType", "P");
			taskMap.put("progRate", 0);
			taskMap.put("parentKey", 0);
			taskMap.put("topParentKey", 0);
			
			cnt = coviMapperOne.insert("collab.task.addTask", taskMap);
			taskMap.put("taskSeq", taskMap.getInt("TaskSeq"));
			cnt = coviMapperOne.insert("collab.task.addTaskMap", taskMap);
		}
		
		return params;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 수정
	 * @throws Exception
	 */
	@Override
	public CoviMap saveProject(CoviMap params, List objMember, List objManager, List objViewer, List objUserForm, MultipartFile[] mf, List objDelFile) throws Exception {
		
		int cnt = coviMapperOne.insert("collab.project.saveProject", params);
//		return params.getInt("ProSeq") ;
		params.put("memberList", objMember);
		params.put("managerList", objManager);
		params.put("viewerList", objViewer);
		params.put("userFormList", objUserForm);

		coviMapperOne.delete("collab.project.deleteProjectMember", params);
		coviMapperOne.delete("collab.project.deleteProjectManager", params);
		coviMapperOne.delete("collab.project.deleteProjectViewer", params);
		coviMapperOne.delete("collab.project.deleteProjectUserForm", params);
		
		if (objMember != null && objMember.size()>0){
			coviMapperOne.insert("collab.project.addProjectMember", params);
		}
		if (objManager != null  && objManager.size()>0){
			coviMapperOne.insert("collab.project.addProjectManager", params);		
		}	
		if (objViewer != null  && objViewer.size()>0){
			coviMapperOne.insert("collab.project.addProjectViewer", params);		
		}	
		if (objUserForm != null  && objUserForm.size()>0){
			coviMapperOne.insert("collab.project.addProjectUserForm", params);		
		}	
		
		if (objDelFile != null ){
			for (int i=0; i < objDelFile.size(); i++){
				HashMap fileMap = (HashMap)objDelFile.get(i);
				fileUtilService.deleteFileByID((String)fileMap.get("FileID"), true);
			}	
		}

		if (mf != null && mf.length>0){
			CoviMap filesParams = new CoviMap();
			String prjSeq = params.getString("prjSeq");
			List<MultipartFile> mockedFileList = new ArrayList<>();
			for(int i =0; i < mf.length; i++){
				if(mf[i] != null && mf[i].getSize()>0) {
					mockedFileList.add(mf[i]);
					
				}	
			}	
			CoviList fileObj = fileUtilService.uploadToBack(null, mockedFileList, fileSvcPath, fileSvcType, prjSeq, "NONE", "0", false);
		
		}	
		return params;
	}
	

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보(수정용)
	 * @throws Exception
	 */
	@Override
	public CoviMap getProject(int prjSeq) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("prjSeq", prjSeq);
		params.put("prjType", "P");
		params.put("USERID", SessionHelper.getSession("USERID"));
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("ObjectID", prjSeq);
		params.put("ServiceType", fileSvcType);
		params.put("MessageID", 0);
		
		resultList.put("prjData", coviMapperOne.selectOne("collab.project.getProject", params));
		resultList.put("memberList", coviMapperOne.selectList("collab.project.getProjectMember", prjSeq));
		resultList.put("managerList", coviMapperOne.selectList("collab.project.getProjectManager", prjSeq));
		resultList.put("viewerList", coviMapperOne.selectList("collab.project.getProjectViewer", prjSeq));
		resultList.put("mileList", coviMapperOne.selectList("collab.project.getProjectMileList", params));
		resultList.put("sectionList", coviMapperOne.selectList("collab.project.getProjectSection", params));
		resultList.put("userformList", coviMapperOne.selectList("collab.project.getProjectUserForm", prjSeq));
		resultList.put("fileList", fileUtilService.selectAttachAll(params));

		return resultList;
	}
	
	public CoviMap getProjectUserForm(int prjSeq) throws Exception {
		CoviMap resultMap = new CoviMap();
		resultMap.put("list", coviMapperOne.selectList("collab.project.getProjectUserForm", prjSeq));
		return resultMap;
	}

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보
	 * @throws Exception
	 */
	@Override
	public CoviMap getProjectStat(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap prjData = new CoviMap();
		if (params.get("prjType").equals("P")){
			params.put("USERID", SessionHelper.getSession("USERID"));
			prjData = coviMapperOne.selectOne("collab.project.getProject",params);
		}else{
			prjData = coviMapperOne.selectOne("collab.project.getTeam", params);
		}		
		
		resultList.put("prjData", prjData);
		resultList.put("prjStat", coviMapperOne.selectOne("collab.project.getProjectStat", params));
		return  resultList;
	}


	
	@Override
	public CoviMap getProjectMain(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		CoviMap memberMap = getMemberList(params);		
		resultList.put("managerList", memberMap.get("managerList"));
		resultList.put("memberList", memberMap.get("memberList"));
		resultList.put("prjData", memberMap.get("prjData"));
		resultList.put("prjStat", coviMapperOne.selectOne("collab.project.getProjectStat", params));
//		resultList.put("sectionList", coviMapperOne.selectList("collab.project.getProjectSection", params));
//        modelMap.put("taskList", collabProjectSvc.getProjectTask(cmap).get("list"));
//		resultList.put("taskList", coviMapperOne.selectList("collab.project.getProjectTask", params));
		CoviMap taskInfo  = getProjectTask(params);
		resultList.put("taskData", taskInfo.get("taskData"));
		resultList.put("taskFilter", taskInfo.get("taskFilter"));
//		resultList.put("sectionList", taskInfo.get("taskFilter"));
//		returnObj.put("taskFilter", taskInfo.get("taskFilter"));
		
		return resultList;
	}


	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보
	 * @throws Exception
	 */
	public CoviMap  getProjectTask(CoviMap params, List filter)	throws Exception  {
		CoviList returnMap = new CoviList();
		
		//CoviMap coviMap = putCoviMap(params);
	    if (params.get("tagtype") != null  && params.get("tagval") != null  && !params.getString("tagval").equals("")){
        	CoviMap tagMap = coviMapperOne.selectOne("collab.todo.getTagList",params.getString("tagval"));
        	String tagData = tagMap.getString("tagData");
        	//사용자 정의 치환
        	tagData = tagData.replace("@@{USERID}@@", "'"+SessionHelper.getSession("USERID")+"'");
        	
        	params.put("tagData", tagData);
        }
	  	
		if (params.get("myTodo") != null && params.get("myTodo").equals("Y")){//내껏만
		}
		else{
			params.put("allView","Y");
			/*if (params.get("prjType").equals("P")){
				//CoviMap resultMap = coviMapperOne.selectOne("collab.project.getProject", params);
				//resultList.put("prjData", resultMap);
			}*/	
		}	
		
		if (filter != null && filter.size() > 0){
			for (int i = 0; i < filter.size(); ++i) {
				switch (params.getString("mode")){
					case "STAT"://상태별
						params.put("taskStatus", filter.get(i));
						break;
					case "MEM"://담당자별
						params.put("memberId", ((CoviMap)filter.get(i)).get("UserCode"));
						break;
					default://섹션별
						params.put("sectionSeq", ((CoviMap)filter.get(i)).get("SectionSeq"));
						break;
					
				}

		        int cnt = (int) coviMapperOne.getNumber("collab.project.getProjectTaskCnt", params);
		        
		        CoviMap page = ComUtils.setPagingData(params, cnt);
				params.addAll(page);
				CoviMap dataMap = new CoviMap();
				dataMap.put("key", filter.get(i));
				dataMap.put("list", coviMapperOne.list("collab.project.getProjectTask", params));
				dataMap.put("page", page);
				returnMap.add(dataMap);
	        }
		}
		else{
	        int cnt = (int) coviMapperOne.getNumber("collab.project.getProjectTaskCnt", params);
	        
	        CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			CoviMap dataMap = new CoviMap();
			dataMap.put("list", coviMapperOne.list("collab.project.getProjectTask", params));
			dataMap.put("page", page);
			returnMap.add(dataMap);
		}
		
      
        
        CoviMap  resultMap = new CoviMap();
        resultMap.put("taskData", returnMap);
        resultMap.put("taskFilter", filter);
		return resultMap;
	}
	@Override
	public CoviMap  getProjectTask(CoviMap params)	throws Exception  {
		
		java.util.ArrayList<Object> filterList = null;
		CoviMap dataMap = new CoviMap();
		switch (params.getString("mode")){
			case "STAT"://상태별
				filterList = new java.util.ArrayList<>(java.util.Arrays.asList("W", "P", "H", "C")); // Arrays.asList()
				break;
			case "MEM"://담당자별
				if (params.getString("prjType").equals("P"))
					filterList = new java.util.ArrayList<>((List)coviMapperOne.selectList("collab.project.getProjectMember", params));
				else
					filterList = new java.util.ArrayList<>((List)coviMapperOne.selectList("collab.project.getTeamMember", params));
				
				dataMap.put("UserCode", "NONE");
				dataMap.put("DisplayName", "No assignee");
				filterList.add(0,dataMap);
				break;
			default://섹션별
				if(params.get("sectionSeq") != null && !params.getString("sectionSeq").equals("")){
					dataMap.put("SectionName", params.get("sectionName"));
					dataMap.put("SectionSeq", params.get("sectionSeq"));
					filterList = new java.util.ArrayList<>();
					filterList.add(0,dataMap);
				}
				else{
					filterList = new java.util.ArrayList<>((List)coviMapperOne.selectList("collab.project.getProjectSection", params));
				}	
				break;
			
		}
		
		return getProjectTask(params, filterList);
/*		CoviList returnMap = new CoviList();
		
		//CoviMap coviMap = putCoviMap(params);
	    if (params.get("tagtype") != null  && params.get("tagval") != null  && !params.getString("tagval").equals("")){
        	CoviMap tagMap = coviMapperOne.selectOne("collab.todo.getTagList",params.getString("tagval"));
        	String tagData = tagMap.getString("tagData");
        	//사용자 정의 치환
        	tagData = tagData.replace("@@{USERID}@@", "'"+SessionHelper.getSession("USERID")+"'");
        	
        	params.put("tagData", tagData);
        }
	  	
	    java.util.ArrayList<String> integers5 = null;
		if (params.get("myTodo") != null && params.get("myTodo").equals("Y")){
			integers5 = new java.util.ArrayList<>(java.util.Arrays.asList("W", "P", "H", "C")); // Arrays.asList()
		}
		else{
			params.put("allView","Y");
			
		}	
		
		for (int i = 0; i < integers5.size(); ++i) {
			if (params.get("myTodo") != null && params.get("myTodo").equals("Y")){
				params.put("taskStatus", integers5.get(i));
			}	
	        int cnt = (int) coviMapperOne.getNumber("collab.project.getProjectTaskCnt", params);
	        
	        CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			CoviMap dataMap = new CoviMap();
			dataMap.put("key", integers5.get(i));
			dataMap.put("list", coviMapperOne.list("collab.project.getProjectTask", params));
			dataMap.put("page", page);
			returnMap.add(dataMap);
        }
		
      
        
        
		return returnMap;*/
	}
	
	//초대
	@Override
	public CoviMap addProjectInvite(CoviMap params) throws Exception {
		coviMapperOne.insert("collab.project.addProjectMember", params);
		return params;
	}
	//삭제
	public int deleteProject  (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.delete("collab.project.deleteProjectSection", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectUserForm", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectManager", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectMember", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectViewer", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectMap", params);
		cnt = coviMapperOne.delete("collab.project.deleteProject", params);
		return cnt;
	}
	
	//섹션 카운트
	public int projectSectionCnt (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("collab.project.getExistsProjectSection", params);
		return cnt;
	}
	
	public String getProjectSectionSeq (CoviMap params) throws Exception {
    	CoviMap resultMap = coviMapperOne.selectOne("collab.project.getProjectSectionSeq", params);
    	String Seq = resultMap.getString("SectionSeq");
		return Seq;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 섹션추가
	 * @throws Exception
	 */
	@Override
	public CoviMap addProjectSection(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		long iCnt = coviMapperOne.getNumber("collab.project.getExistsProjectSection", params);
		
		if (iCnt >0){
			resultList.put("status", Return.FAIL);
			resultList.put("code", "DUP");
			resultList.put("message", "DUP");
		}	
		else{
			int cnt = coviMapperOne.insert("collab.project.addProjectSection", params);
			resultList.put("SectionSeq", params.get("SectionSeq"));
			resultList.put("SectionName", params.get("sectionName"));
			resultList.put("status", Return.SUCCESS);
		}	
		return resultList;
	}
	
	@Override
	public CoviMap saveProjectSection(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int iCnt = coviMapperOne.insert("collab.project.saveProjectSection", params);
		resultList.put("SectionSeq", params.get("sectionSeq"));
		resultList.put("SectionName", params.get("sectionName"));
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 섹션삭제
	 * @throws Exception
	 */
	@Override
	public int deleteProjectSection(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("collab.project.deleteProjectSection", params);
		cnt = coviMapperOne.delete("collab.project.deleteProjectSectionMap", params);
		return cnt;
	}
	
	/**
	 * @param params
	 * @return CoviMap 프로젝트 멤버, 관리자 리스트 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap getProjectMemberList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		String queryId = "";
		if (!"".equals(params.getString("taskSeq"))){
			queryId = "collab.task.getTaskMember";
		}	
		else{
			queryId = "collab.project.selectProjectMemberList";
		}
		int cnt = (int) coviMapperOne.getNumber(queryId+"Cnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		result.put("page", page);
		result.put("list", coviMapperOne.selectList(queryId, params));
		
		return result;
	}
	
	/**
	 * @param params
	 * @return CoviMap 프로젝트 멤버, 관리자 리스트 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap getProjectMemberTagList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("collab.project.selectProjectMemberTagListCnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		result.put("page", page);
		result.put("list", coviMapperOne.selectList("collab.project.selectProjectMemberTagList", params));
		
		return result;
	}
	
	/**
	 * @param params
	 * @return CoviList 협업 스페이스 설문 리스트 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap getFileList(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		String tagVal= (String)ComUtils.nullToString(params.get("tagval"), "");
		
		params.put("filterType", "FILE");
	    if (!tagVal.equals("")  && !tagVal.equals("OVERVIEW")){
        	CoviMap tagMap = coviMapperOne.selectOne("collab.todo.getTagList",params.getString("tagval"));
        	String tagData = tagMap.getString("tagData");
        	//사용자 정의 치환
        	tagData = tagData.replace("@@{USERID}@@", "'"+SessionHelper.getSession("USERID")+"'");
        	
        	params.put("tagData", tagData);
	    }	
		if (params.get("myTodo") != null && params.get("myTodo").equals("Y")){
		}
		else{
			params.put("allView","Y");
		}
				
		CoviMap page = new CoviMap();
		CoviList taskList = new CoviList();
		CoviList prjList = new CoviList();
		
		if (!tagVal.equals("ONLYOVERVIEW")){//개요파일만 경우 프로젝트 파일 제외
			taskList = (CoviList)coviMapperOne.list("collab.project.getProjectTaskFile", params);
		}
		
		if (!tagVal.equals("ONLYNORMAL")){	//프로젝트 파일인 경우 개요 제외
			prjList = (CoviList)coviMapperOne.list("collab.project.getProjectFile", params);
		}
		
		CoviList joined = new CoviList();
		joined.addAll(prjList);
		joined.addAll(taskList);
		
		resultMap.put("list", joined);

		return resultMap;
	}
	/**
	 * @param params
	 * @return CoviList 협업 스페이스 설문 리스트 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap getCollabSurveyList(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = 0;
			if (params.getString("tagval").equalsIgnoreCase("CompSurvey")) {
				cnt = (int) coviMapperOne.getNumber("collab.project.selectCompleteCollabSurveyListCnt", params);
			}
			else if (params.getString("tagval").equalsIgnoreCase("MySurvey")) {
				cnt = (int) coviMapperOne.getNumber("collab.project.selectMyCollabSurveyListCnt", params);
			}
			else if (params.getString("tagval").equalsIgnoreCase("ProcSurvey") || !params.getString("searchSurvey").isEmpty()) {
				cnt = (int) coviMapperOne.getNumber("collab.project.selectProceedCollabSurveyListCnt", params);
			}
			else if (params.getString("tagval").equalsIgnoreCase("WritingSurvey")) {
				cnt = (int) coviMapperOne.getNumber("collab.project.selectTempSaveCollabSurveyListCnt", params);
			}
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			resultMap.put("page", page);
		}
		
		List list = new ArrayList();
		if (params.getString("tagval").equalsIgnoreCase("CompSurvey")) {
			list = coviMapperOne.selectList("collab.project.selectCompleteCollabSurveyList", params);
		}
		else if (params.getString("tagval").equalsIgnoreCase("MySurvey")) {
			list = coviMapperOne.selectList("collab.project.selectMyCollabSurveyList", params);
		}
		else if (params.getString("tagval").equalsIgnoreCase("ProcSurvey")) {
			list =  coviMapperOne.selectList("collab.project.selectProceedCollabSurveyList", params);
		}
		else if (params.getString("tagval").equalsIgnoreCase("WritingSurvey")) {
			list = coviMapperOne.selectList("collab.project.selectTempSaveCollabSurveyList", params);
		}
		resultMap.put("list", list);
		
		/* 설문 진행률과 업무 진행률을 맞춰주는 부분 */
		CoviList taskList = new CoviList();
		taskList.addAll(list);
		
		int rateCnt = 0;
		
		for(int i=0; i<taskList.size(); i++) {
			CoviMap map = taskList.getMap(i);
			
			String SurveyID = map.getString("SurveyID");
			String JoinRate = map.getString("JoinRate");
			
			CoviMap taskMap = new CoviMap();
			taskMap.put("ObjectID", SurveyID);
			taskMap.put("ObjectType", "SURVEY");
			taskMap.put("JoinRate", JoinRate);
			
			rateCnt += coviMapperOne.update("collab.task.updateSurveyProgRate", taskMap);
		}
		
		return resultMap;
	}
	
	/**
	 * 협업 스페이스 결재 리스트 조회
	 * @param params
	 * @return JSONArray
	 * @throws Exception
	 */
	@Override
	public List<CoviMap> getCollabApprovalList(CoviMap params) throws Exception {
		// 태그 검색
		String tagVal= (String)ComUtils.nullToString(params.get("tagval"), "");
		if(params.get("tagtype") != null && params.get("tagtype").equals("APPROVAL") && !tagVal.equals("")){
			CoviMap tagMap = coviMapperOne.selectOne("collab.todo.getTagList", tagVal);
			String tagData = tagMap.getString("tagData");
			//사용자 정의 치환
			tagData = tagData.replace("@@{USERID}@@", "'"+SessionHelper.getSession("USERID")+"'");
			params.put("tagData", tagData);
		}
		
		return coviMapperOne.selectList("collab.project.selectCollabApprovalList", params);
	}
	
	//복사
	public int copyProject  (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.copyProject", params);
		params.put("prjSeq", params.getInt("PrjSeq"));
		cnt = coviMapperOne.insert("collab.project.copyProjectUserform", params);
		cnt = coviMapperOne.insert("collab.project.copyProjectManager", params);
		cnt = coviMapperOne.insert("collab.project.copyProjectMember", params);
		cnt = coviMapperOne.insert("collab.project.copyProjectViewer", params);
		
//		cnt = coviMapperOne.insert("collab.project.copyProjectMap", params);
		cnt = coviMapperOne.insert("collab.project.copyProjectSection", params);
		return cnt;
	}
	
	
	@Override
	public CoviMap getMemberList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();		
		if (params.get("prjType").equals("P")){
			params.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap resultMap = coviMapperOne.selectOne("collab.project.getProject", params);
			resultList.put("prjData", resultMap);
			//params.put("prjAdmin", resultMap.get("PrjAdmin"));
			resultList.put("memberList", coviMapperOne.selectList("collab.project.getProjectMember", params));
			resultList.put("managerList", coviMapperOne.selectList("collab.project.getProjectManager", params));
		}else{
			CoviMap resultMap = coviMapperOne.selectOne("collab.project.getTeam", params);
			resultList.put("prjData", resultMap);
			//params.put("prjAdmin", resultMap.get("PrjAdmin"));
			resultList.put("memberList", coviMapperOne.selectList("collab.project.getTeamMember", params));
		}		
		return resultList;		
	}
	//템플릿 요충
	@Override
	public CoviMap addProjectTmpl(CoviMap params) throws Exception {
		coviMapperOne.insert("collab.project.addProjectTmpl", params);
		return params;
	}

	//팀 업무 마감
	public int closeTeamExec (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.closeTeamExec", params);
		cnt = coviMapperOne.insert("collab.project.createTeamExec", params);
		return cnt;
	}

	//프로젝트 마감
	public int closeProject(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.closeProject", params);
		return cnt;
	}
	

	//프로젝트 채널 생성
	public int saveProjectChannel(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.saveProjectChannel", params);
		return cnt;
	}
	
	//섹션조회
	public List<CoviMap> getSectionList(CoviMap params) throws Exception {
		return coviMapperOne.selectList("collab.project.getProjectSection", params);
	}
	
	//섹션변경
	@Override
	public int updateSectionChange(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.update("collab.project.updateSectionChange", params);
		return cnt;
	}

	//섹션순서변경
	@Override
	public int updateSectionOrder(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.update("collab.project.updateSectionOrder", params);
		return cnt;
	}
	
	//즐겨찾기
	@Override
	public int addProjectFavorite(CoviMap params) throws Exception {
		return coviMapperOne.insert("collab.project.addProjectFavorite", params);
	}

	//즐겨찾기 해제
	@Override
	public int deleteProjectFavorite(CoviMap params) throws Exception {
		return coviMapperOne.delete("collab.project.deleteProjectFavorite", params);
	}
	
	//진행중인 프로젝트 조회
	@Override 
	public CoviMap getGoingProject(CoviMap params) {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.project.getGoingProjectCnt" , params);
			page = ComUtils.setPagingCoviData(params, cnt);
			params.addAll(page);
		}	
		list = coviMapperOne.list("collab.project.getGoingProject", params);
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList; 
	}
	
	//프로젝트별 알림설정
	@Override
	public int saveProjectAlarm(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.project.saveProjectAlarm", params);
		return cnt;
	}
	
	//프로젝트별 알림해제
	@Override
	public int cencelProjectAlarm(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.delete("collab.project.cencelProjectAlarm", params);
		return cnt;
	}
	
	//마감일 알림 상세 설정 조회
	@Override 
	public CoviMap getClosingAlarm(CoviMap params) {
		CoviMap resultList	= new CoviMap();
		resultList.put("confData", coviMapperOne.selectOne("collab.admin.getCollabUserConf", params));
		
		return resultList; 
	}
	
	//마감일 알림 상세 설정 처리
	@Override
	public int saveClosingAlarm(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.admin.saveClosingAlarm", params);
		return cnt;
	}

	//설문 상태
	@Override
	public CoviMap getSurveyInfo(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("collab.project.getSurveyInfo", params);

	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 명 개인화 명칭 추가 
	 * @throws Exception
	 */
	@Override
	public CoviMap addPrjPersonalName(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		coviMapperOne.insert("collab.project.addPrjPersonalName", params);
		resultList.put("prjSeq", params.get("prjSeq"));
		resultList.put("prjName", params.get("prjName"));
		resultList.put("PrjPersonalName", params.get("PrjPersonalName"));
		resultList.put("status", Return.SUCCESS);
		
		return resultList;
	}
}
