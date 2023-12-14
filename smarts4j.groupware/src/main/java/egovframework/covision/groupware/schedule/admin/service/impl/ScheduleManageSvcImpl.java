package egovframework.covision.groupware.schedule.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.covision.groupware.schedule.admin.service.ScheduleManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("scheduleManageService")
public class ScheduleManageSvcImpl extends EgovAbstractServiceImpl implements ScheduleManageSvc{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	AuthorityService authSvc;
	
	@Override
	public CoviList selectFolderTreeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderTreeList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,itemType,FolderType,FolderPath,MenuID,FolderName,MemberOf,DisplayName,SortPath,hasChild");
	}

	@Override
	public CoviMap selectFolderDisplayName(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderDisplayName", param);
		
		return CoviSelectSet.coviSelectJSON(list, "MultiDisplayName").getJSONObject(0);
	}

	@Override
	public CoviMap selectFolderList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderList", params);	
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", list);
		
		return resultList;
	}

	@Override
	public int selectFolderListCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("admin.schedule.selectFolderListCnt", params);
	}
	
	@Override
	public CoviMap selectShareScheduleData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectShareScheduleData", params);		
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SpecifierCode,SpecifierName,TargetData"));
		
		return resultList;
	}

	@Override
	public int selectShareScheduleDataCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("admin.schedule.selectShareScheduleCnt", params);
	}

	@Override
	public int insertShareData(CoviList paramsList) throws Exception {
		int returnVal = 0;
		/*
		CoviList aclList = new CoviList();
		
		//권한 설정
		for(Object obj: paramsList){
			CoviMap paramObj = new CoviMap();
			paramObj.addAll((Map) obj);
			
			ObjectAcl aclObj = new ObjectAcl();
			aclObj.setObjectID(paramObj.getInt("ObjectID"));
			aclObj.setObjectType("FD");
			aclObj.setSubjectCode(paramObj.getString("TargetCode"));
			aclObj.setSubjectType(paramObj.getString("TargetType").equals("user") ? "UR" : "GR");
			aclObj.setAclList(paramObj.getString("ACL"));
			aclObj.setRegisterCode(paramObj.getString("SpecifierCode"));
			aclObj.setDescription("ShareSchedule");
			
			aclList.add(aclObj);
		}
		coviMapperOne.insert("framework.authority.insertACLList", aclList);*/

		//공유 데이터 추가
		returnVal = coviMapperOne.insert("admin.schedule.insertShareSchedule", paramsList);
		
		return returnVal;
	}

	@Override
	public CoviMap selectOneShareScheduleData(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("admin.schedule.selectOneShareScheduleData", params);		
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ShareID,SpecifierCode,SpecifierName,TargetCode,TargetName,StartDate,EndDate"));
		
		return resultList;
	}

	@Override
	public int deleteShareData(CoviMap param) throws Exception {
		int returnVal = 0;
		
		returnVal = coviMapperOne.delete("admin.schedule.deleteShareSchedule", param);
		
		return returnVal;
	}
	
	@Override
	public CoviList selectLinkFolderListData(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectLinkFolderListData", param);	
		
		return CoviSelectSet.coviSelectJSON(list, "optionValue,optionData,optionText");
	}
	

	@Override
	public CoviList selectFolderTypeData() throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderTypeData", null);
		
		return CoviSelectSet.coviSelectJSON(list, "optionValue,optionText");
	}
	
	@Override
	public CoviList selectFolderTypeData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderTypeData", params);
		
		return CoviSelectSet.coviSelectJSON(list, "optionValue,optionText");
	}

	@Override
	public int insertFolderData(CoviMap params) throws Exception {
		CoviMap folderDataObj = (CoviMap) JSONSerializer.toJSON(params.get("FolderData"));
		CoviList aclDataList = (CoviList) JSONSerializer.toJSON(params.get("ACLData"));		
		
		CoviMap ids = coviMapperOne.select("admin.schedule.selectDomainMenuID", folderDataObj);
		
		folderDataObj.put("MemberOf", folderDataObj.getString("MemberOf").equals("") ? ids.getString("FolderID") : folderDataObj.getString("MemberOf"));			
		folderDataObj.put("DomainID", folderDataObj.get("DomainID") == null ? ids.getString("DomainID") : folderDataObj.getString("DomainID"));
		folderDataObj.put("MultiDisplayName", folderDataObj.getString("MultiDisplayName").equals("") ? null : folderDataObj.getString("MultiDisplayName"));
		folderDataObj.put("MenuID", ids.get("MenuID"));
		folderDataObj.put("SortKey", coviMapperOne.selectOne("admin.schedule.selectSortKey", folderDataObj));
		folderDataObj.put("SecurityLevel", folderDataObj.getString("SecurityLevel").equals("") ? 0 : folderDataObj.getString("SecurityLevel"));
		folderDataObj.put("ParentObjectID", ids.get("DomainID"));
		folderDataObj.put("ParentObjectType", "DN");
		folderDataObj.put("LinkFolderID", folderDataObj.getString("LinkFolderID").equals("") ? null : folderDataObj.getString("LinkFolderID"));
		folderDataObj.put("ManageCompany", folderDataObj.getString("ManageCompany").equals("") ? null : folderDataObj.getString("ManageCompany"));
		folderDataObj.put("IsMobileSupport", null);
		folderDataObj.put("IsAdminNotice", null);
		folderDataObj.put("IsMsgSecurity", null);
		folderDataObj.put("Reserved1", folderDataObj.getString("PersonLinkCode").equals("") ? null : folderDataObj.getString("PersonLinkCode"));			// 개인일정 공유
		folderDataObj.put("Reserved2", folderDataObj.getString("DefaultColor").equals("") ? null : folderDataObj.getString("DefaultColor"));					// 일정 기본 컬러
		folderDataObj.put("Reserved3", null);
		folderDataObj.put("Reserved4", folderDataObj.getString("IsAdminSubMenu"));		// 관리자 하위메뉴 표시 여부
		folderDataObj.put("Reserved5", null);
		folderDataObj.put("Reserved5", null);
		folderDataObj.put("IsInherited", folderDataObj.getString("IsInherited"));
		
		int returnVal = coviMapperOne.insert("admin.schedule.insertFolderData", folderDataObj);
		
		String folderID = folderDataObj.getString("FolderID");
		
		CoviMap idParam = new CoviMap();
		idParam.put("FolderID", folderID);
		
		// Folder SortPath, FolderPath Update
		String sortPath = coviMapperOne.selectOne("admin.schedule.selectComSortPathCreateS", idParam);
		String folderPath = coviMapperOne.selectOne("admin.schedule.selectComObjectPathCreateS", idParam);
		
		idParam.put("SortPath", sortPath);
		idParam.put("FolderPath", folderPath);
		
		coviMapperOne.update("admin.schedule.updateSortPath", idParam);
		coviMapperOne.update("admin.schedule.updateFolderPath", idParam);
		
		//권한 데이터 저장
		if(!aclDataList.isEmpty()){
			for(int i = 0; i < aclDataList.size(); i++){
				CoviMap aclObj = aclDataList.getJSONObject(i);		
				String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
				params.put("objectID", Integer.parseInt(folderID));							//ObjectID: FolderID
				params.put("objectType", "FD");												//ObjectType: FD
				params.put("subjectCode", aclObj.get("SubjectCode"));
				params.put("subjectType", aclObj.get("SubjectType"));
				params.put("aclList", aclObj.get("AclList"));
				params.put("security", aclShard[0]);
				params.put("create", aclShard[1]);
				params.put("delete", aclShard[2]);
				params.put("modify", aclShard[3]);
				params.put("execute", aclShard[4]);
				params.put("view", aclShard[5]);
				params.put("read", aclShard[6]);
				params.put("description", "");
				params.put("registerCode", SessionHelper.getSession("USERID"));
				params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
				params.put("isSubInclude", aclObj.get("IsSubInclude"));
				
				authSvc.insertACL(params);
				
				// 권한 변경 이력
				LoggerHelper.authLogger(params, "After");
			}
		}
		
		// Redis 권한 데이터 초기화
		RedisShardsUtil.getInstance().removeAll(folderDataObj.getString("domainID"), RedisDataUtil.PRE_ACL + folderDataObj.getString("domainID") + "_*");
		
		return returnVal;
	}

	@Override
	public int deleteFolderData(CoviList params) throws Exception {
		int returnVal = 0;
		for(Object obj : params){
			CoviMap param = (CoviMap) obj;
			
			// 폴더 데이터 삭제
			returnVal = coviMapperOne.update("admin.schedule.deleteFolderData", param);
			
			// 권한 데이터 삭제
			returnVal = coviMapperOne.update("admin.schedule.deleteFolderACLData", param);
		}
		
		return returnVal;
	}

	@Override
	public CoviMap selectFolderData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.schedule.selectFolderData", params);		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,OwnerName,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,PersonLinkCode,PersonLinkName,DefaultColor,Reserved3,IsAdminSubMenu,Reserved5").getJSONObject(0);
	}

	@Override
	public int updateFolderData(CoviMap params) throws Exception {
		int returnVal = 0;
		
		CoviMap folderDataObj = (CoviMap) JSONSerializer.toJSON(params.get("FolderData"));
		CoviList aclDataList = (CoviList) JSONSerializer.toJSON(params.get("ACLData"));
		
		String folderID = folderDataObj.getString("FolderID");
		
		// ACL 정보 저장
		if(!aclDataList.isEmpty() && "Y".equals(params.getString("aclIsChange"))){
			//권한 데이터 삭제 후 다시 Insert
			params.put("objectID", Integer.parseInt(folderID));
			params.put("objectType", "FD");
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			// 권한 변경 이력
			LoggerHelper.authLogger(params, "Before");
			
			// ACL 정보 삭제
			authSvc.deleteACL(params);
			
			// 본인 권한 데이터 추가
			for(int i=0;i<aclDataList.size();i++){
				CoviMap aclObj = aclDataList.getJSONObject(i);		
				String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
				params.put("objectID", Integer.parseInt(folderID));							//ObjectID: FolderID
				params.put("objectType", "FD");												//ObjectType: FD
				params.put("subjectCode", aclObj.get("SubjectCode"));
				params.put("subjectType", aclObj.get("SubjectType"));
				params.put("aclList", aclObj.get("AclList"));
				params.put("security", aclShard[0]);
				params.put("create", aclShard[1]);
				params.put("delete", aclShard[2]);
				params.put("modify", aclShard[3]);
				params.put("execute", aclShard[4]);
				params.put("view", aclShard[5]);
				params.put("read", aclShard[6]);
				params.put("description", "");
				params.put("registerCode", SessionHelper.getSession("USERID"));
				params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
				params.put("isSubInclude", aclObj.get("IsSubInclude"));
				
				authSvc.insertACL(params);
				
				// 권한 변경 이력
				LoggerHelper.authLogger(params, "After");
			}
			
			// 하위 일정 권한 상속 처리
			// authSvc.setInheritedACL(folderID, "FD");
		}
		
		folderDataObj.put("SecurityLevel", folderDataObj.getString("SecurityLevel").equals("") ? 0 : folderDataObj.getString("SecurityLevel"));
		folderDataObj.put("MultiDisplayName", folderDataObj.getString("MultiDisplayName").equals("") ? null : folderDataObj.getString("MultiDisplayName"));
		folderDataObj.put("LinkFolderID", folderDataObj.getString("LinkFolderID").equals("") ? null : folderDataObj.getString("LinkFolderID"));
		folderDataObj.put("ManageCompany", folderDataObj.getString("ManageCompany").equals("") ? null : folderDataObj.getString("ManageCompany"));
		folderDataObj.put("PersonLinkCode", folderDataObj.getString("PersonLinkCode").equals("") ? null : folderDataObj.getString("PersonLinkCode"));			// 개인일정 공유
		folderDataObj.put("DefaultColor", folderDataObj.getString("DefaultColor").equals("") ? null : folderDataObj.getString("DefaultColor"));					// 일정 기본 컬러
    	
		//폴더 데이터 Update
		returnVal = coviMapperOne.update("admin.schedule.updateFolderData", folderDataObj);
		
		return returnVal;
	}
	
	@Override
	public CoviMap selectDomainMenuID(CoviMap params) throws Exception {
		return coviMapperOne.select("admin.schedule.selectDomainMenuID", params);
	}
	
	@Override
	public int updateFlag(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.schedule.updateFlag", params);
	}
}
