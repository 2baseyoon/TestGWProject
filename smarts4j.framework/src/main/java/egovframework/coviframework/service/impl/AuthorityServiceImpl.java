package egovframework.coviframework.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Map.Entry;
import java.util.Set;
import java.util.Stack;

import javax.annotation.Resource;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLSerializeUtil;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.vo.ACLMapper;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



/**
 * @Class Name : AuthorityServiceImpl.java
 * @Description : 권한 처리
 * @Modification Information 
 * @ 2017.06.14 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.06.14
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Service("authorityService")
public class AuthorityServiceImpl extends EgovAbstractServiceImpl implements AuthorityService{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public HashMap<String, String> selectAllowedURL() throws Exception {
		return selectAllowedURL(true);
	}
	@Override
	public HashMap<String, String> selectAllowedURL(boolean isAdmin) throws Exception {
		// isAdmin : true => 세션체크 X
		// isAdmin : false => 세션체크 O, 세션만료연장 X
		HashMap<String, String> ret = new HashMap<String, String>();
		CoviMap param = new CoviMap(false);
		param.put("IsAdmin", isAdmin);
		CoviList list = coviMapperOne.list("framework.authority.selectAllowedURL", param);
		
		for(Object obj : list){
			CoviMap accessURLObj = (CoviMap) obj;

			String url = accessURLObj.getString("URL");
			String accessUrlID = accessURLObj.getString("AccessUrlID");
			
			ret.put(url, accessUrlID);
		}

		return ret;
	}
	
	/**
	 * session상의 user가 소속된 Subject(주체)를 가져온다.
	 */
	@Override
	public String[] getAssignedSubject(CoviMap userInfoObj) throws Exception {
		String returnStr = "";
		Set<String> assignedSubjectCodeSet = new HashSet<>();
		
		CoviMap params = new CoviMap();
		
		String userCode = userInfoObj.getString("USERID");
		String deptCode = userInfoObj.getString("DEPTID");
		String domainCode = userInfoObj.getString("DN_Code");
		
		params.put("userCode", userCode);
		params.put("deptCode", deptCode);
		params.put("domainID", userInfoObj.getString("DN_ID"));
		params.put("domainCode", domainCode);
		
		// 자신이 로그인한 소속 조직에 대해서만 권한을 세팅함 (겸직일 경우)
		assignedSubjectCodeSet.add(userCode);
		assignedSubjectCodeSet.add(deptCode);
		assignedSubjectCodeSet.add(domainCode);
		assignedSubjectCodeSet.add("ORGROOT");
		
		if(userInfoObj.containsKey("UR_JobLevelCode") && !userInfoObj.getString("UR_JobLevelCode").equals(""))
			assignedSubjectCodeSet.add(userInfoObj.getString("UR_JobLevelCode"));
		if(userInfoObj.containsKey("UR_JobPositionCode") && !userInfoObj.getString("UR_JobPositionCode").equals(""))
			assignedSubjectCodeSet.add(userInfoObj.getString("UR_JobPositionCode"));
		if(userInfoObj.containsKey("UR_JobTitleCode") && !userInfoObj.getString("UR_JobTitleCode").equals(""))
			assignedSubjectCodeSet.add(userInfoObj.getString("UR_JobTitleCode"));
		
		//쿼리에서 처리하도록 제거
		/*String groupPath = coviMapperOne.selectOne("framework.authority.selectGroupPath", params);
		if(StringUtils.isNoneBlank(groupPath)){
			String[] groupPathArray = groupPath.split(";");
			for (String groupCode: groupPathArray) {           
				assignedSubjectCodeSet.add(groupCode);
		    }
		}*/
		
		CoviList groupList = coviMapperOne.list("framework.authority.selectAssignedGroup", params);
		for (int i = 0; i < groupList.size(); i++) {
			if(StringUtils.isNoneBlank(groupList.getMap(i).getString("GroupCode"))){
				assignedSubjectCodeSet.add(groupList.getMap(i).getString("GroupCode"));	
			}
		}
		
		/*그룹멤버로 으로 속한 그룹 가져오기*/
		params.put("groupIDArr", assignedSubjectCodeSet);
		CoviList groupMemgerList = coviMapperOne.list("framework.authority.selectAssignedGroupMember", params);
		for (int i = 0; i < groupMemgerList.size(); i++) {
			if(StringUtils.isNoneBlank(groupMemgerList.getMap(i).getString("GroupCode"))){
				assignedSubjectCodeSet.add(groupMemgerList.getMap(i).getString("GroupCode"));	
			}
		}

		String[] subjectArray = assignedSubjectCodeSet.toArray(new String[assignedSubjectCodeSet.size()]);
		/*if(subjectArray.length > 0){
			returnStr = "(" + ACLHelper.join(subjectArray, ",") + ")";
		}*/
		
		return subjectArray;
	}
	
	@Override
	public Map<String, String> getAuthorizedACL(CoviMap userInfoObj) throws Exception{
	//	String subjectCodes = getAssignedSubject(userInfoObj);
		String[] subjectCodeArr = getAssignedSubject(userInfoObj);
		
		String userCode = userInfoObj.getString("USERID");
		String domainID = userInfoObj.getString("DN_ID");
		String deptPath = userInfoObj.getString("GR_GroupPath");
		
		
		ACLMapper menuACL = getAuthorizedACL_Menu(userCode, domainID, deptPath, subjectCodeArr);
		HashMap<String, ACLMapper> folderACLMap = getAuthorizedACL_FolderList(userCode, domainID, deptPath, subjectCodeArr);
		ACLMapper portalACL = getAuthorizedACL_Portal(userCode, domainID, deptPath, subjectCodeArr);
		ACLMapper webpartACL = getAuthorizedACL_Portal(userCode, domainID, deptPath, subjectCodeArr, "WP");
		
		// Redis 세팅
		Map<String, String> mapAcl = new HashMap<String, String>();
		ACLSerializeUtil sUtil = new ACLSerializeUtil();
		String menuACLStr = sUtil.serializeObj(menuACL);
		String portalACLStr = sUtil.serializeObj(portalACL);
		String webpartACLStr = sUtil.serializeObj(webpartACL);
		
		mapAcl.put(menuACL.getSettingKey(), menuACLStr);
		mapAcl.put(portalACL.getSettingKey(), portalACLStr);
		mapAcl.put(webpartACL.getSettingKey(), webpartACLStr);
		
		ACLMapper folderACL = null;
		String folderACLStr = "";
		for(Entry<String, ACLMapper> entry : folderACLMap.entrySet()) {
			folderACL = entry.getValue();
			folderACLStr = sUtil.serializeObj(folderACL);
			mapAcl.put(folderACL.getSettingKey(), folderACLStr);
		}
		
		return mapAcl;
	}
	
	@Override
	public ACLMapper getAuthorizedACL_Menu(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception {
		ACLMapper menuACLMapper = new ACLMapper("MN");
		
		// sync key setting
		String currentSyncKey = RedisDataUtil.getACLSyncKey(domainID, "MN");
		menuACLMapper.setSynchronizeKey(currentSyncKey);
		
		// MN ACL 조회
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		params.put("objectType", "MN");
		params.put("deptPath", deptPath);
	//	params.put("subjectCodes", subjectCodes);
		params.put("subjectCodeArr", subjectCodeArr);
		
		CoviList menuACLList_User = coviMapperOne.list("framework.authority.selectAuthorizedACL_User", params);
		CoviList menuACLList_Group = coviMapperOne.list("framework.authority.selectAuthorizedACL_Group", params);
		
		// 우선순위 조정
		Set<String> ignoreGroup = new HashSet<>();
		for(Object obj : menuACLList_Group){
			CoviMap menuACL = (CoviMap)obj;
			
			String objectID = menuACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				menuACLMapper.clearACLInfo(objectID);
			menuACLMapper.setACLListInfo(menuACL.getString("AclList"), objectID);
			
			ignoreGroup.add(objectID);
		}
		for(Object obj : menuACLList_User){
			CoviMap menuACL = (CoviMap)obj;
			
			String objectID = menuACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				menuACLMapper.clearACLInfo(objectID);
			menuACLMapper.setACLListInfo(menuACL.getString("AclList"), objectID);
			
			ignoreGroup.add(objectID);
		}
		
		return menuACLMapper;
	}
	
	@Override
	public ACLMapper getAuthorizedACL_Folder(String serviceType, String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception {
		String settingKey = "FD_" + serviceType.toUpperCase();
				
		ACLMapper folderACLMapper = new ACLMapper(settingKey);
		
		// sync key setting
		String currentSyncKey = RedisDataUtil.getACLSyncKey(domainID, settingKey);
		folderACLMapper.setSynchronizeKey(currentSyncKey);
		
		// FD ACL 조회
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		params.put("objectType", "FD");
		params.put("deptPath", deptPath);
	//	params.put("subjectCodes", subjectCodes);
		params.put("subjectCodeArr", subjectCodeArr);
		params.put("serviceType", serviceType);
		
		CoviList folderACLList_User = coviMapperOne.list("framework.authority.selectAuthorizedACL_Folder_User", params);
		CoviList folderACLList_Group = coviMapperOne.list("framework.authority.selectAuthorizedACL_Folder_Group", params);
		
		// 우선순위 조정
		Set<String> ignoreGroup = new HashSet<>();
		for(Object obj : folderACLList_Group){
			CoviMap folderACL = (CoviMap)obj;
			
			String objectID = folderACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				folderACLMapper.clearACLInfo(objectID);
			folderACLMapper.setACLListInfo(folderACL.getString("AclList"), objectID);
			
			ignoreGroup.add(objectID);
		}
		for(Object obj : folderACLList_User){
			CoviMap folderACL = (CoviMap)obj;
			
			String objectID = folderACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				folderACLMapper.clearACLInfo(objectID);
			folderACLMapper.setACLListInfo(folderACL.getString("AclList"), objectID);
			
			ignoreGroup.add(objectID);
		}
		
		return folderACLMapper;
	}
	
	@Override
	public HashMap<String, ACLMapper> getAuthorizedACL_FolderList(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception {
		HashMap<String, ACLMapper> folderACLListMapper = new HashMap<String, ACLMapper>();
	
		// FD ACL 조회
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		params.put("objectType", "FD");
		params.put("deptPath", deptPath);
	//	params.put("subjectCodes", subjectCodes);
		params.put("subjectCodeArr", subjectCodeArr);
		
		CoviList folderACLList_User = coviMapperOne.list("framework.authority.selectAuthorizedACL_Folder_User", params);
		CoviList folderACLList_Group = coviMapperOne.list("framework.authority.selectAuthorizedACL_Folder_Group", params);
		
		// 우선순위 조정
		Set<String> ignoreGroup = new HashSet<>();
		for(Object obj : folderACLList_Group){
			CoviMap folderACL = (CoviMap)obj;
			
			String settingKey = "FD_" + folderACL.getString("BizSection").toUpperCase();
			ACLMapper folderACLMapper;
			if(folderACLListMapper.containsKey(settingKey)){
				folderACLMapper = folderACLListMapper.get(settingKey);
			}else{
				folderACLMapper = new ACLMapper(settingKey);
				
				// Object 생성 시 syncKey 조회 후 입력
				String currentSyncKey = RedisDataUtil.getACLSyncKey(domainID, settingKey);
				folderACLMapper.setSynchronizeKey(currentSyncKey);
			}
			
			String objectID = folderACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				folderACLMapper.clearACLInfo(objectID);
			folderACLMapper.setACLListInfo(folderACL.getString("AclList"), objectID);
			
			folderACLListMapper.put(settingKey, folderACLMapper);
			ignoreGroup.add(objectID);
		}
		for(Object obj : folderACLList_User){
			CoviMap folderACL = (CoviMap)obj;
			
			String settingKey = "FD_" + folderACL.getString("BizSection").toUpperCase();
			ACLMapper folderACLMapper;
			if(folderACLListMapper.containsKey(settingKey)){
				folderACLMapper = folderACLListMapper.get(settingKey);
			}else{
				folderACLMapper = new ACLMapper(settingKey);
				
				// Object 생성 시 syncKey 조회 후 입력
				String currentSyncKey = RedisDataUtil.getACLSyncKey(domainID, settingKey);
				folderACLMapper.setSynchronizeKey(currentSyncKey);
			}
			
			String objectID = folderACL.getString("ObjectID");
			if(ignoreGroup.contains(objectID))
				folderACLMapper.clearACLInfo(objectID);
			folderACLMapper.setACLListInfo(folderACL.getString("AclList"), objectID);
			
			folderACLListMapper.put(settingKey, folderACLMapper);
			ignoreGroup.add(objectID);
		}
		
		return folderACLListMapper;
	}
	
	@Override
	public ACLMapper getAuthorizedACL_Portal(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception {
		return getAuthorizedACL_Portal(userCode, domainID, deptPath, subjectCodeArr, "PT");
	}	
	public ACLMapper getAuthorizedACL_Portal(String userCode, String domainID, String deptPath, String[] subjectCodeArr, String aclType) throws Exception {
		
		ACLMapper portalACLMapper = new ACLMapper(aclType);
		
		// sync key setting
		String currentSyncKey = RedisDataUtil.getACLSyncKey(domainID, aclType);
		portalACLMapper.setSynchronizeKey(currentSyncKey);
		
		// PT ACL 조회
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		params.put("objectType", aclType);
		params.put("deptPath", deptPath);
	//	params.put("subjectCodes", subjectCodes);
		params.put("subjectCodeArr", subjectCodeArr);
		
		CoviList portalACLList_User = coviMapperOne.list("framework.authority.selectAuthorizedACL_User", params);
		CoviList portalACLList_Group = coviMapperOne.list("framework.authority.selectAuthorizedACL_Group", params);
		CoviList portalACLList_Lic = new CoviList();
		// 우선순위 조정
		Set<String> ignoreGroup = new HashSet<>();
		
		if (aclType.equals("PT")){		//라이선스 관련 포탈 확인용
			portalACLList_Lic =  coviMapperOne.list("framework.authority.selectAuthorizedACL_Lic", params);
	
			for(Object obj : portalACLList_Lic){
				CoviMap portalACL = (CoviMap)obj;
				
				String objectID = portalACL.getString("ObjectID");
				if(ignoreGroup.contains(objectID))
					portalACLMapper.clearACLInfo(objectID);
				portalACLMapper.setACLListInfo(portalACL.getString("AclList"), objectID);
				
				ignoreGroup.add(objectID);
			}
		}	
		//라이선스 포탈이 있을 경우 다른 포탈 무시
		if (portalACLList_Lic.size()==0){
			
			for(Object obj : portalACLList_Group){
				CoviMap portalACL = (CoviMap)obj;
				
				String objectID = portalACL.getString("ObjectID");
				if(ignoreGroup.contains(objectID))
					portalACLMapper.clearACLInfo(objectID);
				portalACLMapper.setACLListInfo(portalACL.getString("AclList"), objectID);
				
				ignoreGroup.add(objectID);
			}
			for(Object obj : portalACLList_User){
				CoviMap portalACL = (CoviMap)obj;
				
				String objectID = portalACL.getString("ObjectID");
				if(ignoreGroup.contains(objectID))
					portalACLMapper.clearACLInfo(objectID);
				portalACLMapper.setACLListInfo(portalACL.getString("AclList"), objectID);
				
				ignoreGroup.add(objectID);
			}
		}
		return portalACLMapper;
	}
	
	/*@Override
	public String[] getAuthorizedACL(String userId, String objectType, String aclColName, String aclValue) throws Exception {
		String[] ret = null;
		
		//1. 접속자가 소속된 그룹을 쿼리
		CoviMap subjectParams = new CoviMap();
		subjectParams.put("userCode", userId);
		
		Set<String> assignedSubjectCodeSet = getAssignedSubject(subjectParams);
		//2. userId도 추가
		//assignedSubjectCodeSet.add(userId);
		
		//3. subject코드를 in절에 들어갈 string으로 변환
		String[] subjectArray = assignedSubjectCodeSet.toArray(new String[assignedSubjectCodeSet.size()]);
		
		if(subjectArray.length > 0){
			
			String subjectInStr = "(" + ACLHelper.join(subjectArray, ",") + ")";
		
		String subjectInStr = getAssignedSubject(userId);
		
		if(!subjectInStr.equals("")){
		
			//4. subject코드로 acl을 쿼리
			CoviMap aclParams = new CoviMap();
			aclParams.put("subjectCodes", subjectInStr);
			CoviList aclArray = getAuthorizedACL(aclParams);
			
			//6. acl 중 MN, View 권한 쿼리
			Set<String> authorizedObjectCodeSet = ACLHelper.queryObjectFromACL(objectType, aclArray, aclColName, aclValue);
			
			//7. object코드를 in절에 들어갈 string으로 변환
			ret = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
		}
		
		return ret;
	}*/
	
	
	/**
	 * ACL data로 부터 MN에 대한 것들을 쿼리해서
	 * menu data를 return
	 */
	@Override
	public CoviList getAuthorizedMenu(CoviMap params) throws Exception {
		CoviList ret = new CoviList();
		
		/*
		 * V 권한
		 * Object가 MN 타입인 ObjectID
		 * Set<String> -> string array -> comma로 seperate된 IN절
		 * */
		
		CoviList cList = coviMapperOne.list("framework.authority.selectAuthorizedMenu", params);
		ret = CoviSelectSet.coviSelectJSON(cList, "MenuID,DomainID,IsAdmin,MenuType,BizSection,ParentObjectID,ParentObjectType,ServiceDevice,MultiDisplayName,IconClass,MemberOf,SecurityLevel,SortKey,SortPath,SiteMapPosition,IsUse,IsDisplay,URL,MobileURL,Target,MobileTarget,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,OriginMenuID");
		
		return ret;
	}
	
	
	
	/**
	 * 
	 */
	@Override
	public Object insertACL(CoviMap params)throws Exception{
		return coviMapperOne.insert("framework.authority.insertACL", params);
	}
	
	@Override
	public Object deleteACL(CoviMap params)throws Exception{
		return coviMapperOne.insert("framework.authority.deleteACL", params);
	}
	
	@Override
	public CoviList selectACL(CoviMap params) throws Exception {
		CoviList ret = new CoviList();
		
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList cList = coviMapperOne.list("framework.authority.selectACL", params);
		ret = CoviSelectSet.coviSelectJSON(cList, "AclID,ObjectID,ObjectType,SubjectCode,SubjectType,AclList,Security,Create,Delete,Modify,Execute,View,Read,SubjectName,MultiSubjectName,CompanyCode,GroupType,SortKey,InheritedObjectID,IsSubInclude");
		
		return ret;
	}
	
	@Override
	public CoviList selectCompanyACL(CoviMap params) throws Exception {
		CoviList ret = new CoviList();
		
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList cList = coviMapperOne.list("framework.authority.selectCompanyACL", params);
		ret = CoviSelectSet.coviSelectJSON(cList, "AclID,ObjectID,ObjectType,SubjectCode,SubjectType,AclList,Security,Create,Delete,Modify,Execute,View,Read,SubjectName,MultiSubjectName,CompanyCode,GroupType,SortKey,InheritedObjectID,IsSubInclude");
		
		return ret;
	}
	
	@Override
	public ACLMapper rebuildACL(CoviMap userDataObj, String fieldName) throws Exception {
		ACLSerializeUtil sUtil = new ACLSerializeUtil();
		
		ACLMapper aclMap = null;
		
		String userCode = userDataObj.getString("USERID");
		String jobSeq = userDataObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
		String domainID = userDataObj.getString("DN_ID");
		String deptPath = userDataObj.getString("GR_GroupPath");
		
		String redisKey = userCode + "_" + jobSeq;
		
		String serializedStr = "";
		// 권한데이터 재세팅
		
		String[] subjectCodes = getAssignedSubject(userDataObj);	// TODO getAssignedSubject(userCode);
		if("MN".equals(fieldName)) {
			aclMap = getAuthorizedACL_Menu(userCode, domainID, deptPath, subjectCodes);
		} else if ("PT".equals(fieldName)) {
			aclMap = getAuthorizedACL_Portal(userCode, domainID, deptPath, subjectCodes);
		} else if ("WP".equals(fieldName)) {	//webpart
			aclMap = getAuthorizedACL_Portal(userCode, domainID, deptPath, subjectCodes, "WP");
		} else if (fieldName.indexOf("FD") == 0) {
			String serviceType = fieldName.substring(fieldName.indexOf("_") + 1);
			aclMap = getAuthorizedACL_Folder(serviceType, userCode, domainID, deptPath, subjectCodes);
			
			//folder의 조회권한은 db에 넣기
			Map<String, Set<String>> aclFolder= aclMap.getACLMap();

			CoviMap insertMap = new CoviMap();
			insertMap.put("UserCode",userCode);
			insertMap.put("JobSeq",jobSeq);
			insertMap.put("ServiceType",serviceType);
			insertMap.put("ObjectType","FD");

			/*	// db에서 중복 체크
			insertMap.put("SyncKey",UUID.randomUUID().toString());
			insertMap.put("aclList", aclFolder.get("V"));
			coviMapperOne.update("framework.authority.mergeUserAcl", insertMap);
			*/
			
			CoviList aclOldMap = coviMapperOne.list("framework.authority.getUserAcl", insertMap);
			Set<String> aclNewMap = new HashSet<String>(aclFolder.get("V"));
			Set<String> delMap = new HashSet<String>();// = new CoviMap();
			
            for(Object obj : aclOldMap){
    			CoviMap folderACL = (CoviMap)obj;
    			
    			String objectID = folderACL.getString("ObjectID");
    			if(aclNewMap.contains(objectID)){	//존재하면(중복임)
    				aclNewMap.remove(objectID);
            	}	else{//없으면 삭제에 추가
            		delMap.add(objectID);
            	}
    		}
			
            if (aclNewMap.size()>0){	//신규건 관련
				insertMap.put("aclList", aclNewMap);
				coviMapperOne.insert("framework.authority.insertUserAcl", insertMap);
            }
            
            if (delMap.size()>0){		//삭제건관련
				insertMap.put("aclList", delMap);
				coviMapperOne.delete("framework.authority.deleteUserAcl", insertMap);
            }
            
		}		
		
		serializedStr = sUtil.serializeObj(aclMap);
		RedisDataUtil.setACL(redisKey, domainID, fieldName, serializedStr, 7200);
		
		return aclMap;
	}
	
	@Override
	public void syncActionACL(CoviList aclActionData, String changeField) throws Exception {
		ArrayList<String> arrActionUser = new ArrayList<String>();
		ArrayList<String> arrActionGroup = new ArrayList<String>();
		CoviMap params = new CoviMap();
		
		// aclActionData에서 UR, GR(회사, 부서, 임의그룹) 분류
		CoviMap actionObj = null;
		for(int i=0; i<aclActionData.size(); i++) {
			actionObj = aclActionData.getJSONObject(i);
			if(actionObj.getString("SubjectType").equals("UR")) {
				arrActionUser.add(actionObj.getString("SubjectCode"));
			} else {
				arrActionGroup.add(actionObj.getString("SubjectCode"));
			}
		}
		
		params.put("URAction", arrActionUser.toArray());
		params.put("GRAction", arrActionGroup.toArray());
		
		// DomainID 조회 
		CoviList domainIDs = coviMapperOne.list("framework.authority.selectSyncDomain", params);
		
		// 분류된 DomainID들의 synckey refresh 처리
		CoviMap syncDomain = null;
		for(int i=0; i<domainIDs.size(); i++) {
			syncDomain = domainIDs.getMap(i);
			RedisDataUtil.refreshACLSyncKey(syncDomain.getString("DomainID"), changeField);
		}
	}
	
	@Override
	public void syncDomainACL(String domainID, String changeField)
			throws Exception {
		// 해당 Domain의 sync key refresh
		RedisDataUtil.refreshACLSyncKey(domainID, changeField);
	}
	
	@Override
	public void syncUserACL(String key, String domainID, String changeField)
			throws Exception {
		// 특정 사용자의 특정필드 권한 제거
		RedisDataUtil.setACL(key, domainID, changeField, "", 7200);
	}
	
	@Override
	public int selectTwoFactorIpCheck(CoviMap params, String isTarget) throws Exception{
		
		StringUtil func = new StringUtil();
		int cnt = 0;
		
		params.put("isTarget", StringUtil.replaceNull(isTarget,"U"));
		cnt = (int)coviMapperOne.getNumber("common.login.selectTwoFactorIpCheck", params);
		
		return cnt;
		
	}
	
	@Override
	public Object insertInheritedACL(CoviMap params)throws Exception{
		return coviMapperOne.insert("framework.authority.insertInheritedACL", params);
	}
	
	@Override
	public Object deleteInheritedACL(CoviMap params)throws Exception{
		return coviMapperOne.insert("framework.authority.deleteInheritedACL", params);
	}
	
	@Override
	public List<CoviMap> selectInheritedACL(CoviMap params) throws Exception {
		return coviMapperOne.selectList("framework.authority.selectInheritedACL", params);
	}
	
	@Override
	public void setInheritedACL(String pObjectID, String pObjectType, boolean pIsUpdateChildren) throws Exception {
		Stack<String> stack = new Stack<String>();
		stack.add(pObjectID);
		
		CoviMap aclMap = new CoviMap();
		aclMap.put("registerCode", SessionHelper.getSession("USERID"));
		aclMap.put("objectType", pObjectType);
		aclMap.put("isUpdateChildren", (pIsUpdateChildren) ? "Y" : "N");
		
		while (!stack.isEmpty()) {
			aclMap.put("inheritedObjectID", stack.pop());
			
			// 하위 객체 조회
			List<CoviMap> authList = selectInheritedACL(aclMap);
			
			if (authList.size() > 0) {
				for (CoviMap auth : authList) {
					CoviMap deleteAclParam = new CoviMap();
					deleteAclParam.put("objectID", auth.getString("ObjectID"));
					deleteAclParam.put("objectType", aclMap.getString("objectType"));
					deleteAclParam.put("isUpdateChildren", aclMap.getString("isUpdateChildren"));
					deleteAclParam.put("registerCode", SessionHelper.getSession("USERID"));
					
					// 권한 변경 이력 (기존 권한 정보)
					String logChangeID = LoggerHelper.authLogger(deleteAclParam, "Before");
					
					// 하위 객체의 상속 권한 삭제
					int delCnt = (int) deleteInheritedACL(deleteAclParam);
					
					aclMap.put("objectID", auth.getString("ObjectID"));
					aclMap.put("inheritedObjectID", auth.getString("MemberOf"));
					aclMap.put("setInheritedACL", "Y");
					
					if(logChangeID != null) {
						aclMap.put("logChangeID", logChangeID);
					}
					
					// 권한 변경 이력 (변경 권한 정보)
					logChangeID = LoggerHelper.authLogger(aclMap, "After");
					
					// 권한 상속
					insertInheritedACL(aclMap);
					
					aclMap.put("isInherited", "Y");
					coviMapperOne.update("framework.authority.updateObjectIsInherited", aclMap);
				}
			}
		}
	}
	
	@Override
	public HashMap<String, String> selectMenuAuthURL() throws Exception {
		HashMap<String, String> ret = new HashMap<String, String>();
		CoviList list = coviMapperOne.list("framework.authority.selectMenuAuthURL", new CoviMap());
		
		for(Object obj : list){
			CoviMap accessURLObj = (CoviMap) obj;

			String url = accessURLObj.getString("URL");
			String[] urls= url.split("\\?");
			String key = "";
			if (urls.length>1){
				key = urls[0];
			}
			else key = url;
			
			ret.put(key, url);
		}

		return ret;
	}
}
