package egovframework.covision.groupware.resource.manage.service.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.covision.groupware.resource.manage.service.ResourceVManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("resourceNManageService")
public class ResourceVManageSvcImpl extends EgovAbstractServiceImpl implements ResourceVManageSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	AuthorityService authSvc;
	
	@Override
	public CoviMap getEquipmentList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		int cnt = (int) coviMapperOne.getNumber("admin.resource.selectEquipmentListCnt", params);
		CoviList list = coviMapperOne.list("admin.resource.selectEquipmentList", params);
		CoviList equipmentList = CoviSelectSet.coviSelectJSON(list, "EquipmentID,MultiEquipmentName,IconPath,IsUse,SortKey,MultiRegisterName,RegistDate,CompanyCode");
		
		returnObj.put("equipmentList", equipmentList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}

	@Override
	public int chnageEquipmentIsUse(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateEquipmentIsUse", params);
	}

	@Override
	public int deleteEquipmentData(CoviMap delParam) throws Exception {
		return coviMapperOne.delete("admin.resource.deleteEquipmentData", delParam);
	}

	@Override
	public int insertEquipmentData(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.resource.insertEquipmentData", params);
	}
	
	@Override
	public int updateEquipmentData(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateEquipmentData", params);
	}

	@Override
	public CoviMap getEquipmentData(CoviMap params) throws Exception {
		CoviMap returnObj  = new CoviMap();
		
		CoviMap map = coviMapperOne.selectOne("admin.resource.selectEquipmentData", params);
		CoviList equipmentData = CoviSelectSet.coviSelectJSON(map, "DN_ID,MultiEquipmentName,IconPath,IsUse,SortKey,CompanyCode");
		
		returnObj.put("list", equipmentData);
		
		return returnObj;
	}

	@Override
	public CoviMap getMainResourceList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		int cnt = (int) coviMapperOne.getNumber("admin.resource.selectMainResourceListCnt", params);
		CoviList list = coviMapperOne.list("admin.resource.selectMainResourceList", params);
		CoviList mainResourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,DomainName,ResourceName,FolderPath,SortKey,RegisterName,RegistDate");
		
		for(Object resource : mainResourceList){
			CoviMap resourceObj  =  (CoviMap) resource;
			String folderPath = resourceObj.getString("FolderPath");
			int beginIdx =	folderPath.indexOf(';') == -1? folderPath.length() : folderPath.indexOf(';')+1 ;
			
			folderPath = folderPath.substring(beginIdx);
			folderPath = folderPath.replace(";", " > ");
		    ((CoviMap)resource).put("FolderPath", folderPath);
		}
		
		
		returnObj.put("list", mainResourceList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}

	@Override
	public CoviList getMainResourceTreeList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		CoviList returnList = new CoviList();
		
		CoviList list = coviMapperOne.list("admin.resource.selectResourceList", params);
		CoviList resourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,DomainID,MultiDisplayName,MemberOf,SortPath");
		
		for(Object resource : resourceList){
			CoviMap resourceObj = (CoviMap) resource;
			
			// 트리를 그리기 위한 데이터
			//resourceObj.put("no", StringUtil.getSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("no", resourceObj.getString("FolderID"));
			resourceObj.put("nodeName", DicHelper.getDicInfo(resourceObj.getString("MultiDisplayName"),lang));
			resourceObj.put("nodeValue", resourceObj.get("FolderID"));
			//resourceObj.put("pno", StringUtil.getParentSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("pno", resourceObj.getString("MemberOf"));
			
			if(resourceObj.getString("FolderType").startsWith("Resource")){
				resourceObj.put("chk", "Y");
			}else{
				resourceObj.put("type", "folder");
				resourceObj.put("chk", "N");
			}
			
			resourceObj.put("rdo", "N");
			resourceObj.put("url", "#");
			
			returnList.add(resourceObj);
		}
		
		return returnList;
	}
	
	@Override
	public CoviList getFolderResourceTreeList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		CoviList returnList = new CoviList();
		
		CoviList list = coviMapperOne.list("admin.resource.selectResourceList", params);
		CoviList resourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,DomainID,MultiDisplayName,FolderPath,MemberOf,SortKey,SortPath,IconCode,maxFolderID,FolderName,PlaceOfBusiness,BookingType,ReturnType,IsDisplay,IsUse,RegisterName,RegistDate");
		
		// 사업명 코드 추가 - Redis에서 codeGroup=PlaceOfBusiness 을 가져온다.  
		CoviList placeCodeList = new CoviList();
		placeCodeList = RedisDataUtil.getBaseCode("PlaceOfBusiness", "0");
		CoviMap placeMap = new CoviMap();
		for (Object place : placeCodeList) {
			CoviMap tmpMap = (CoviMap)place;
			String[] tmpStrArr = tmpMap.getString("MultiCodeName").split(";");
			if (lang.equalsIgnoreCase("ko")) {
				placeMap.put(tmpMap.get("Code"), tmpStrArr[0]);
			} else if (lang.equalsIgnoreCase("en")) {
				placeMap.put(tmpMap.get("Code"), tmpStrArr[1]);
			} else if (lang.equalsIgnoreCase("ja")) {
				placeMap.put(tmpMap.get("Code"), tmpStrArr[2]);
			} else if (lang.equalsIgnoreCase("zh")) {
				placeMap.put(tmpMap.get("Code"), tmpStrArr[3]);
			} else {
				placeMap.put(tmpMap.get("Code"), tmpMap.get("CodeName"));
			}
		}
		
		for(Object resource : resourceList){
			CoviMap resourceObj = (CoviMap) resource;
						
			// 트리를 그리기 위한 데이터
			//resourceObj.put("no", StringUtil.getSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("no", resourceObj.get("FolderID"));
			resourceObj.put("nodeName", DicHelper.getDicInfo(resourceObj.getString("MultiDisplayName"), lang));
			resourceObj.put("nodeValue", resourceObj.get("FolderID"));
			//resourceObj.put("pno", StringUtil.getParentSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("pno",resourceObj.get("MemberOf"));
			resourceObj.put("chk", "N");
			resourceObj.put("domainID", params.getString("domainID"));
			
			//resourceObj.put("url", "javascript:selectResourceFolder( \"" + resourceObj.get("FolderID") + "\", \"" + params.getString("domainID") + "\" );");
			
			
			
			if(resourceObj.getString("FolderType").startsWith("Resource")){
				resourceObj.put("type", "resource_displayicon_"+resourceObj.getString("IconCode"));
			}else{ //Root or Folder
				resourceObj.put("type", "folder");
			}
			
			resourceObj.put("maxFolderID", resourceObj.get("maxFolderID"));
			
			// 사업명 코드 추가 - 사업장 코드를 코드이름으로 변환.
			String tmpPlace = resourceObj.getString("PlaceOfBusiness"); 	// Seoul;Busan;
			String strPlace = "";
			if (!tmpPlace.equals("")) {
				String[] tmpPlaceArr = tmpPlace.split(";"); 	// Seoul[0], Busan[1]
				for (String tmpStr : tmpPlaceArr) {
					strPlace += placeMap.get(tmpStr)+",";
				}
			}
			resourceObj.put("PlaceOfBusiness", strPlace);
			
			returnList.add(resourceObj);
		}
		
		return returnList;
	}
	
	//디자인 상으로 ICON 빠짐
	/*@Override
	public String getFolderIconCss() throws Exception{
		StringBuilder cssStr  = new StringBuilder();
		
		CoviList iconArr = RedisDataUtil.getBaseCode("DisplayICon");
		
		for(Object iconObj : iconArr){
			CoviMap tIconObj = (CoviMap)iconObj;
			String code = tIconObj.has("Code") ? tIconObj.getString("Code") : "";
			String imagePath = tIconObj.has("Reserved1") ? tIconObj.getString("Reserved1") : "";
			
			//하드코딩: 기초코드 Reserved까지 가져오도록 변경되면 변경
			cssStr.append(String.format(".resource_displayicon_%s{ background:url('%s') no-repeat; background-position: 5px 2px; }"
					, code.toLowerCase(),imagePath));
			cssStr.append(System.getProperty("line.separator"));
		}
		
		return cssStr.toString();
	}*/

	@Override
	public int insertMainResourceList(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt += coviMapperOne.delete("admin.resource.deleteOldMainResource",params);
		
		if(params.get("resourceIDArr") != null) {
			retCnt += coviMapperOne.insert("admin.resource.insertNewMainResource",params);
		}
		
		return retCnt;
	}

	@Override
	public int changeResourceSortKey(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateResourceSortKey",params);
	}

	@Override
	public CoviMap getFolderInfo(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap folderObj = new CoviMap();
		
		CoviMap folderInfo = coviMapperOne.select("admin.resource.selectFolderInfo",params); 
		folderObj = CoviSelectSet.coviSelectJSON(folderInfo, "FolderType,FolderPath,FolderName").getJSONObject(0);
		
		returnObj.put("folderInfo", folderObj);
		
		return returnObj;
	}

	@Override
	public CoviMap getBookingOfResourceList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		int cnt = (int) coviMapperOne.getNumber("admin.resource.selectBookingOfResourceListCnt", params);
		CoviList list = coviMapperOne.list("admin.resource.selectBookingOfResourceList", params);
		CoviList bookingList = coviSelectJSONForResourceList(list, "EventID,DateID,FolderID,RepeatID,Subject,StartDateTime,EndDateTime,ApprovalState,ApprovalStateCode,RegisterCode,RegisterName,RegistDate");
		
		returnObj.put("list", bookingList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	@Override
	public CoviMap getResourceOfFolderList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		int cnt = (int) coviMapperOne.getNumber("admin.resource.selectResourceOfFolderListCnt", params);
		CoviList list = coviMapperOne.list("admin.resource.selectResourceOfFolderList", params);
		CoviList resourceList = coviSelectJSONForResourceList(list, "FolderID,FolderType,PlaceOfBusiness,IconPath,FolderName,BookingType,ReturnType,SortKey,IsDisplay,IsUse,RegisterName,RegistDate");
		
		returnObj.put("list", resourceList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}

	@Override
	public int changeIsSwitch(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateIsSwitch",params);
	}
	
	@Override
	public int deleteFolderData(CoviMap params) throws Exception {
		coviMapperOne.delete("admin.resource.deleteACLList", params); //ACL 데이터 삭제
		coviMapperOne.delete("admin.resource.deleteMainResource",params); //Main Resource 데이터 삭제
		return coviMapperOne.delete("admin.resource.deleteFolderData",params);
	}
	
	@Override
	public int changeFolderSortKey(CoviMap params) throws Exception {
		
		int cnt = coviMapperOne.update("admin.resource.updateFolderSortKey",params);
		coviMapperOne.update("admin.resource.updateFolderSortPath",params);
		
		return cnt;
	}
	
	//순서 변경용 게시판 SortKey 조회
	@Override
	public CoviMap selectTargetSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("target", coviMapperOne.select("admin.resource.selectFolderSortPath", params));
		return result;
	}

	/**
	 * @param params folderID
	 * @description 사용자 정의 필드 Grid 데이터 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserDefFieldGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.resource.selectUserDefFormGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "FolderID,UserFormID,FieldName,DisplayName,FieldType,FieldInputLimit,IsOption,IsList,IsCheckVal,OptionCnt,SortKey"));
		return resultList;
	}
	
	@Override
	public int getUserDefFieldGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.resource.selectUserDefFormGridCount", params);
	}
	
	/**
	 * @param params folderID, userFormID
	 * @description 사용자 정의 필드 Grid의 선택한 행에 해당하는 옵션 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserDefFieldOptionList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.resource.selectUserDefFieldOptionList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "OptionID,SortKey,OptionName,OptionValue"));
		return resultList;
	}
	
	@Override
	public int createUserDefField(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.resource.createUserDefField", params);
	}
	
	@Override
	public int createUserDefOption(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.resource.createUserDefFieldOption", params);
	}
	
	@Override
	public int updateUserDefField(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateUserDefField", params);
	}
	
	@Override
	public int deleteUserDefField(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.resource.deleteUserDefField", params);
	}
	
	@Override
	public int deleteUserDefFieldOption(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.resource.deleteUserDefFieldOption", params);
	}
	

	@Override
	public CoviMap getTargetUserDefFieldSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("target", coviMapperOne.select("admin.resource.selectTargetUserDefFieldSortKey", params));
		return result;
	}

	@Override
	public int updateUserDefFieldSortKey(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.resource.updateUserDefFieldSortKey", params);
	}

	@Override
	public CoviList getOnlyFolderTreeList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		CoviList returnList = new CoviList();
		
		CoviList list = coviMapperOne.list("admin.resource.selectResourceList", params);
		CoviList resourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,DomainID,MultiDisplayName,FolderPath,MemberOf,SortPath,IconCode");
		
		for(Object resource : resourceList){
			CoviMap resourceObj = (CoviMap) resource;
			
			// 트리를 그리기 위한 데이터
			//resourceObj.put("no", StringUtil.getSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("no", resourceObj.getString("FolderID"));
			resourceObj.put("nodeName", DicHelper.getDicInfo(resourceObj.getString("MultiDisplayName"),lang));
			resourceObj.put("nodeValue", resourceObj.get("FolderID"));
			//resourceObj.put("pno", StringUtil.getParentSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("pno", resourceObj.getString("MemberOf"));
			resourceObj.put("chk", "N");
			resourceObj.put("url", "#");
			resourceObj.put("type", "folder");
			
			returnList.add(resourceObj);
		}
		
		return returnList;
	}

	@Override
	public CoviMap getShareResourceList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		
		int cnt = (int) coviMapperOne.getNumber("admin.resource.selectShareResourceListCnt", params);
		CoviList list = coviMapperOne.list("admin.resource.selectShareResourceList", params);
		CoviList shareResourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,DomainName,ResourceName,RegisterName,RegistDate");
		
		returnObj.put("list", shareResourceList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}

	@Override
	public int getMenuByDomainID(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.resource.selectMenuByDomainID", params);
	}
	
	@Override
	public int getTopFolderByMenuID(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.resource.selectTopFolderByMenuID", params);
	}

	@Override
	public int insertFolderData(CoviMap params) throws Exception {		
		CoviMap folderDataObj = (CoviMap) JSONSerializer.toJSON(params.get("folderData"));
		CoviList aclDataList = (CoviList) JSONSerializer.toJSON(params.get("aclData"));
		CoviList attributeList = (CoviList) JSONSerializer.toJSON(params.get("attributeData"));
		CoviList managementList = (CoviList) JSONSerializer.toJSON(params.get("managementData"));
		
		if(folderDataObj.getString("folderType").toUpperCase().equals("RESOURCELINK")){
			if(folderDataObj.getString("folderType").toUpperCase().equals("Resource")){
				folderDataObj.put("linkFolderID",  folderDataObj.getString("linkFolderID"));
				folderDataObj.put("isShared", "N");
			}
		}else{
			folderDataObj.put("isShared",  folderDataObj.getString("isShared"));
			folderDataObj.put("linkFolderID", null);
		}
		
		if(folderDataObj.getString("folderType").toUpperCase().startsWith("RESOURCE")){
			folderDataObj.put("folderType", folderDataObj.getString("folderType")+"."+folderDataObj.getString("resourceType") );
		}
		
		folderDataObj.put("objectType", "Resource");
		folderDataObj.put("parentObjectID", folderDataObj.get("domainID"));
		folderDataObj.put("parentObjectType", "DN");
		folderDataObj.put("registerCode", SessionHelper.getSession("USERID"));
		folderDataObj.put("ownerCode", SessionHelper.getSession("USERID"));
		
		if("Root".equals(folderDataObj.getString("folderType"))) {
			folderDataObj.put("isInherited", "N");
		}
		
		int returnVal = coviMapperOne.insert("admin.resource.insertFolderData", folderDataObj);
		String sortPath = coviMapperOne.selectOne("admin.resource.selectComSortPathCreateS", folderDataObj);
		String folderPath = coviMapperOne.selectOne("admin.resource.selectComObjectPathCreateS", folderDataObj);
		folderDataObj.put("SortPath", sortPath);
		folderDataObj.put("FolderPath", folderPath);
		coviMapperOne.update("admin.resource.updatePathData", folderDataObj);
		
		if(folderDataObj.getString("isInheritedSetting").equals("N")){
			coviMapperOne.insert("admin.resource.insertResourceData", folderDataObj);
		}
		
		String folderID = folderDataObj.getString("folderID");

		if(!params.get("equipmentData").equals("")){
			CoviMap equipmentData = new CoviMap();
			
			String[] equipmentIDArr = params.getString("equipmentData").split(";");
			equipmentData.put("folderID", folderID);
			equipmentData.put("equipmentIDArr", equipmentIDArr);
			
			coviMapperOne.update("admin.resource.insertAddEquipmentData", equipmentData);
		}
		
		// Menu(메뉴) ACL을 상속 또는 Folder의 상위 권한을 상속
		CoviMap aclParams = new CoviMap();
		
		// FolderType 이 최상위 폴더일 경우 Menu(메뉴) ACL을 상속 받는다.
		if("Root".equals(folderDataObj.getString("folderType"))) {					
			aclParams.put("objectType", "MN");				//메뉴권한 상속
			aclParams.put("objectID", folderDataObj.getString("menuID"));				//현재 Folder가 참조하는 Menu ID
			aclParams.put("inheritedObjectID", folderDataObj.getString("memberOf"));						
			aclDataList = authSvc.selectACL(aclParams);		//Menu ACL 정보 조회
		} else {
			aclParams.put("objectType", "FD");				//Folder 권한 상속
			aclParams.put("objectID", folderDataObj.getString("memberOf"));				//현재 Folder 및 Board 가 참조하는 FolderID
			aclParams.put("inheritedObjectID", folderDataObj.getString("memberOf"));	//상속 받는 ObjectID
			aclDataList = authSvc.selectACL(aclParams);		//Folder ACL 정보 조회
		}
		
		// ACL 정보 저장
		if(!aclDataList.isEmpty()){
			params.put("objectID", Integer.parseInt(folderID));
			params.put("objectType", "FD");
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			// 권한 데이터 추가
			for(int i=0;i<aclDataList.size();i++){
				CoviMap aclObj = aclDataList.getJSONObject(i);
				
				if(!aclObj.getString("SubjectType").equals("RM")) {				
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
		}
		
		// 추가 속성 저장
		if(!attributeList.isEmpty()){
			List<CoviMap> attributeDatas = new ArrayList<CoviMap>();
			
			for(Object obj : attributeList){
				CoviMap attributeObj = (CoviMap) obj;
				attributeObj.put("folderID", Integer.parseInt(folderID));
				attributeDatas.add(attributeObj);
			}
			
			coviMapperOne.insert("admin.resource.insertAttributeData", attributeDatas);
		}		

		// 담당자 정보 저장
		if(!managementList.isEmpty()){
			List<CoviMap> managementDatas = new ArrayList<CoviMap>();
			for(Object obj : managementList){
				CoviMap managementDataObj = (CoviMap) obj;			
				
				CoviMap aclMap = new CoviMap();
				String AclList = "SCDMEVR";
				String[] aclShard = AclList.split("(?!^)");											
				aclMap.put("objectID", Integer.parseInt(folderID));									
				aclMap.put("objectType", "FD");														
				aclMap.put("subjectCode", managementDataObj.get("subjectCode"));
				aclMap.put("subjectType", "RM");
				aclMap.put("aclList", AclList);
				aclMap.put("security", aclShard[0]);
				aclMap.put("create", aclShard[1]);
				aclMap.put("delete", aclShard[2]);
				aclMap.put("modify", aclShard[3]);
				aclMap.put("execute", aclShard[4]);
				aclMap.put("view", aclShard[5]);
				aclMap.put("read", aclShard[6]);
				aclMap.put("description", "");
				aclMap.put("registerCode", SessionHelper.getSession("USERID"));				
				managementDatas.add(aclMap);
			}

			if(managementDatas.size() > 0 ){
				coviMapperOne.insert("framework.authority.insertACLList", managementDatas);
			}
		}
		
		CoviList frontFileInfos = CoviList.fromObject(folderDataObj.getString("resorceImagePath"));
		CoviList backFileInfos = fileSvc.moveToBack(frontFileInfos, "Resource/", "Resource", folderID, "FD", "0");
		
		int size = backFileInfos.size();
		
		if(size > 0){
			  CoviMap spaceJSON = backFileInfos.getJSONObject(0);
			  params.put("FolderID",  folderID);
              params.put("FileID",  spaceJSON.getString("FileID"));
              
              coviMapperOne.update("admin.resource.updateImagePath", params);
		}
		
		// Redis 권한 데이터 초기화
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.removeAll(folderDataObj.getString("domainID"), RedisDataUtil.PRE_ACL + folderDataObj.getString("domainID") + "_*");
		
		return returnVal;
	}

	@Override
	public int updateFolderData(CoviMap params) throws Exception {
		String userCode = SessionHelper.getSession("UR_Code");		
		
		CoviMap folderDataObj = (CoviMap) JSONSerializer.toJSON(params.get("folderData"));
		CoviList aclDataList = (CoviList) JSONSerializer.toJSON(params.get("aclData"));
		CoviList attributeList = (CoviList) JSONSerializer.toJSON(params.get("attributeData"));
		CoviList managementList = (CoviList) JSONSerializer.toJSON(params.get("managementData"));
		
		String folderID = folderDataObj.getString("folderID");
		
		if(folderDataObj.getString("folderType").toUpperCase().equals("RESOURCELINK")){
			if(folderDataObj.getString("folderType").toUpperCase().equals("Resource")){
				folderDataObj.put("linkFolderID",  folderDataObj.getString("linkFolderID"));
				folderDataObj.put("isShared", "N");
			}
		}else{
			folderDataObj.put("isShared",  folderDataObj.getString("isShared"));
			folderDataObj.put("linkFolderID", null);
		}
		
		if(folderDataObj.getString("folderType").toUpperCase().startsWith("RESOURCE")){
			folderDataObj.put("folderType", folderDataObj.getString("folderType")+"."+folderDataObj.getString("resourceType") );
		}
		
		folderDataObj.put("parentObjectID",1);
		folderDataObj.put("parentObjectType", "DN");
		folderDataObj.put("modifierCode", userCode);
	
		int returnVal = coviMapperOne.update("admin.resource.updateFolderData", folderDataObj);
		
		String sortPath = coviMapperOne.selectOne("admin.resource.selectComSortPathCreateS", folderDataObj);
		String folderPath = coviMapperOne.selectOne("admin.resource.selectComObjectPathCreateS", folderDataObj);
		
		folderDataObj.put("SortPath", sortPath);
		folderDataObj.put("FolderPath", folderPath);
		
		coviMapperOne.update("admin.resource.updatePathData", folderDataObj);
		
		if(folderDataObj.getString("isInheritedSetting").equals("N")){

			int cnt = coviMapperOne.selectOne("admin.resource.selectResourceData", folderDataObj);
			if(cnt == 0){
				folderDataObj.put("registerCode", userCode);
				coviMapperOne.insert("admin.resource.insertResourceData", folderDataObj);
			}
			else{
				coviMapperOne.update("admin.resource.updateResourceData", folderDataObj);
			}				
		}else{
			coviMapperOne.delete("admin.resource.deleteResourceData", folderDataObj);
			
			folderDataObj.put("registerCode", userCode);
			coviMapperOne.insert("admin.resource.insertInheritResourceData", folderDataObj);
		}

		coviMapperOne.delete("admin.resource.deleteAddOptionData", folderDataObj);
		
		if(!params.get("equipmentData").equals("")){
			CoviMap equipmentData = new CoviMap();
			
			String[] equipmentIDArr = params.getString("equipmentData").split(";");
			equipmentData.put("folderID",folderID);
			equipmentData.put("equipmentIDArr", equipmentIDArr);
			
			coviMapperOne.update("admin.resource.insertAddEquipmentData", equipmentData);
		}

		// ACL 정보 저장
		if(!aclDataList.isEmpty() && "Y".equals(params.getString("aclIsChange"))){
			params.put("objectID", Integer.parseInt(folderID));
			params.put("objectType", "FD");
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			// 권한 변경 이력
			String logChangeID = LoggerHelper.authLogger(params, "Before");
			
			// ACL 정보 삭제
			authSvc.deleteACL(params);
			
			// 본인 권한 데이터 추가
			for(int i=0;i<aclDataList.size();i++){
				CoviMap aclObj = aclDataList.getJSONObject(i);
				
				if(!aclObj.getString("SubjectType").equals("RM")) {				
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
					
					if(logChangeID != null) {
						params.put("logChangeID", logChangeID);
					}
					
					// 권한 변경 이력
					logChangeID = LoggerHelper.authLogger(params, "After");
				}
			}
			
			// 하위 자원 권한 상속 처리
			authSvc.setInheritedACL(folderID, "FD", false);
		}

		// 추가 속성 저장
		if(!attributeList.isEmpty()){
			List<CoviMap> attributeDatas = new ArrayList<CoviMap>();
			
			for(Object obj : attributeList){
				CoviMap attributeObj = (CoviMap) obj;
				attributeObj.put("folderID", Integer.parseInt(folderID));
				attributeDatas.add(attributeObj);
			}
			
			coviMapperOne.insert("admin.resource.insertAttributeData", attributeDatas);
		}

		// 담당자 정보 저장
		if(!managementList.isEmpty()){
			List<CoviMap> managementDatas = new ArrayList<CoviMap>();
			for(Object obj : managementList){
				CoviMap managementDataObj = (CoviMap) obj;

				CoviMap aclParams = new CoviMap();
				aclParams.put("objectID", Integer.parseInt(folderID));
				aclParams.put("objectType", "FD");
				aclParams.put("subjectCode", managementDataObj.getString("subjectCode"));
				
				if(!managementDataObj.getString("isRemove").isEmpty() && managementDataObj.getString("isRemove").equals("Y")) {
					// 삭제된 담당자 ACL 정보 삭제
					authSvc.deleteACL(aclParams);
				} else {
					int aclCount = coviMapperOne.selectOne("admin.resource.selectACLList", aclParams);

					if(aclCount == 0){
						CoviMap aclMap = new CoviMap();
						String AclList = "SCDMEVR";
						String[] aclShard = AclList.split("(?!^)");											
						aclMap.put("objectID", Integer.parseInt(folderID));									
						aclMap.put("objectType", "FD");														
						aclMap.put("subjectCode", managementDataObj.get("subjectCode"));
						aclMap.put("subjectType", "RM");
						aclMap.put("aclList", AclList);
						aclMap.put("security", aclShard[0]);
						aclMap.put("create", aclShard[1]);
						aclMap.put("delete", aclShard[2]);
						aclMap.put("modify", aclShard[3]);
						aclMap.put("execute", aclShard[4]);
						aclMap.put("view", aclShard[5]);
						aclMap.put("read", aclShard[6]);
						aclMap.put("description", "");
						aclMap.put("registerCode", SessionHelper.getSession("USERID"));				
						managementDatas.add(aclMap);
					}
				}
			}

			if(managementDatas.size() > 0 ){
				coviMapperOne.insert("framework.authority.insertACLList", managementDatas);
			}
		}
		
		CoviList frontFileInfos = CoviList.fromObject(folderDataObj.getString("resorceImagePath"));
		if(frontFileInfos.size() >0){
			CoviList backFileInfos = fileSvc.moveToBack(frontFileInfos, "Resource/", "Resource", folderID, "FD", "0");
			
			int size = backFileInfos.size();
			
			if(size > 0){
				CoviMap spaceJSON = backFileInfos.getJSONObject(0);
				params.put("FolderID",  folderID);
				params.put("FileID",  spaceJSON.getString("FileID"));
				
				coviMapperOne.update("admin.resource.updateImagePath", params);
			}
		}
		
		// Redis 권한 데이터 초기화
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		instance.removeAll(folderDataObj.getString("domainID"), RedisDataUtil.PRE_ACL + folderDataObj.getString("domainID") + "_*");
		
		return returnVal;
	}

	@Override
	public CoviMap getFolderData(CoviMap folderParams) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap folderData = coviSelectJSONForResourceList(coviMapperOne.select("admin.resource.selectFolderData",folderParams),"FolderID,DomainID,MenuID,ObjectType,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,LinkFolderName,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,ManageCompany,Description,OwnerCode,Reserved1,PlaceOfBusiness,Reserved2,Reserved3,BookingType,BookingTypeCode,ReturnType,ReturnTypeCode,NotificationState,NotificationKind,LeastRentalTime,LeastPartRentalTime,DescriptionURL,ParentFolderName"); 
		returnObj.put("folderData", folderData);

		CoviMap aclParam = new CoviMap();
		aclParam.put("objectID", folderParams.getString("folderID"));
		aclParam.put("objectType", "FD");
		
		CoviList aclData = coviMapperOne.list("framework.authority.selectACL",aclParam); 
		returnObj.put("aclData", aclData);
		
		CoviList equipmentData = coviMapperOne.list("admin.resource.selectAddEquipmentData",folderParams); 
		returnObj.put("equipmentData", equipmentData);
		
		CoviList attributeData = coviMapperOne.list("admin.resource.selectAttributeData",folderParams); 
		returnObj.put("attributeData", attributeData);
		
		CoviList managementData = coviMapperOne.list("admin.resource.selectManagementData",aclParam); 
		returnObj.put("managementData", managementData);
		
		return returnObj;
	}
	
	
	@SuppressWarnings("unchecked")
	public CoviList coviSelectJSONForResourceList(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap resourceDic = getResourceDic();
		CoviMap placeOfBusiness = resourceDic.getJSONObject("PlaceOfBusiness");

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
							if (ar.equals("ApprovalState")) {
									newObject.put(cols[j], Objects.toString(resourceDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));
							} else if (ar.equals("BookingType") || ar.equals("ReturnType")) {
								newObject.put(cols[j], Objects.toString(resourceDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));	
							}else if(ar.equals("PlaceOfBusiness")){
								
								if(clist.getMap(i).getString(cols[j]).equals("")){
									newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
								}else{
									String placeStr = clist.getMap(i).getString(cols[j]);
									
									Iterator iter1 =placeOfBusiness.keys();
						            while(iter1.hasNext())
						            {
						            	String key =  iter1.next().toString();
						            	placeStr = placeStr.replace(key, placeOfBusiness.getString(key));
						            }
						            newObject.put(cols[j], Objects.toString(placeStr,clist.getMap(i).getString(cols[j])));
								}
							} else {
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
	public  CoviMap coviSelectJSONForResourceList(CoviMap obj, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap resourceDic = getResourceDic();
		CoviMap placeOfBusiness = resourceDic.getJSONObject("PlaceOfBusiness");
		
		CoviMap newObject = new CoviMap();
		for(int j=0; j<cols.length; j++){
			Set<String> set = obj.keySet();
			Iterator<String> iter = set.iterator();
			
			while(iter.hasNext()){   
				String ar = (String)iter.next();
				if(ar.equals(cols[j].trim())){
					if (ar.equals("ApprovalState")) {
						newObject.put(cols[j], Objects.toString(resourceDic.getString(obj.getString(cols[j])), obj.getString(cols[j]) ));
					} else if (ar.equals("BookingType") || ar.equals("ReturnType")) {
						newObject.put(cols[j], Objects.toString(resourceDic.getString(obj.getString(cols[j])),obj.getString(cols[j]) ));	
					} else if(ar.equals("PlaceOfBusiness")){
						
						if(obj.getString(cols[j]).equals("")){
							newObject.put(cols[j], obj.getString(cols[j]));
						}else{
							String placeStr = obj.getString(cols[j]);
							
							Iterator i =placeOfBusiness.keys();
				            while(i.hasNext())
				            {
				            	String key =  i.next().toString();
				            	placeStr = placeStr.replace(key, placeOfBusiness.getString(key));
				            }
				            newObject.put(cols[j], Objects.toString(placeStr,obj.getString(cols[j]) ) );	
						}
					} else {
						newObject.put(cols[j], obj.getString(cols[j]));
					}
				}
			}
		}
		
		return newObject;
	}
	
	// 자원에서 사용하는 다국어 값 세팅
	public CoviMap getResourceDic() throws Exception {
		CoviMap resourceDicObj = new CoviMap();
		
		resourceDicObj.put("Inherited", "lbl_Inherited"); // 상속
		resourceDicObj.put("ChargeApproval", "lbl_ChargeApproval"); // 담당승인
		resourceDicObj.put("DirectApproval", "lbl_DirectApproval"); // 바로승인
		resourceDicObj.put("ApprovalProhibit", "lbl_NotBooking"); // 예약불가
		resourceDicObj.put("ChargeConfirm", "lbl_adminconfirm"); // 담당확인
		resourceDicObj.put("AutoReturn", "lbl_AutoReturn"); // 자동반납
		
		resourceDicObj.put("ApprovalRequest", "lbl_ApprovalReq"); // 승인요청
		resourceDicObj.put("Reject", "lbl_Deny"); // 거부
		resourceDicObj.put("Approval", "lbl_Approved"); // 승인
		resourceDicObj.put("ReturnRequest", "btn_Returnrequest"); // 반납요청
		resourceDicObj.put("ReturnComplete", "lbl_res_ReturnComplete"); // 반납완료
		resourceDicObj.put("ApprovalCancel", "lbl_ApplicationWithdrawn"); // 신청철회
		resourceDicObj.put("ApprovalDeny", "lbl_CancelApproval"); // 승인취소
		resourceDicObj.put("AutoCancel", "lbl_AutoCancel"); // 자동 취소
		
		resourceDicObj.put("", "");
		
		String dicCode = "";
		StringBuffer buf = new StringBuffer();
		for (Iterator<String> keys = resourceDicObj.keys(); keys.hasNext();) {
			buf.append(resourceDicObj.getString(keys.next())).append(";");
		}
		dicCode = buf.toString();
		CoviList dicobj = DicHelper.getDicAll(dicCode);

		for (int i = 0; i < resourceDicObj.size(); i++) {
			Iterator<String> keys1 = resourceDicObj.keys();
			String key1 = keys1.next();

			for (Iterator<String> keys2 = dicobj.getJSONObject(0).keys(); keys2	.hasNext();) {
				String key2 = keys2.next();
				if (resourceDicObj.getString(key1).equals(key2)) {
					resourceDicObj.remove(key1);
					resourceDicObj.put(key1, dicobj.getJSONObject(0).getString(key2));
					break;
				}
			}
		}
		
		resourceDicObj.put("PlaceOfBusiness",RedisDataUtil.getBaseCodeGroupDic("PlaceOfBusiness")); 
		
		return resourceDicObj;
	}

	@Override
	public int deleteBookingData(CoviMap dataObj) throws Exception {
		int retCnt = 0;
		
		String[] dateIDArr = dataObj.getString("DateID").split(";");
		
		for(int i = 0 ; i < dateIDArr.length; i++){
			CoviMap params = new CoviMap(); //
			params.put("DateID", dateIDArr[i]);
			
			CoviMap bookData = coviMapperOne.select("admin.resource.seleteDeletedBookingInfo", params);
			
			if(bookData.getString("FolderType").startsWith("Schedule")){
				params.clear();
				params.put("EventID", bookData.getString("EventID"));
				params.put("ResourceID", bookData.getString("ResourceID"));
				params.put("DateID", dateIDArr[i]);
				
				//coviMapperOne.delete("admin.resource.deleteRelationData",params); //relation 테이블 관계 삭제 (반복일 경우 모두 삭제되는 문제 있음)
				coviMapperOne.update("admin.resource.deleteResourceBookingData",params);  //resource booking 테이블 row 삭제
					
			}else if(bookData.getString("FolderType").startsWith("Resource")){
				params.clear();
				params.put("EventID", bookData.getString("EventID"));
				params.put("DateID", dateIDArr[i]);
				
				if(bookData.getInt("RepeatCnt")>0){ //2번이상 반복되는 예약일경우 해당 date정보만 삭제
					coviMapperOne.delete("admin.resource.deleteDateDataByDateID",params); //해당 Date만 삭제
				}else{
					coviMapperOne.delete("admin.resource.deleteDateDataByEventID",params); //해당 Date만 삭제
					coviMapperOne.update("admin.resource.deleteEventData",params); //해당 Date만 삭제
				}
			}
			retCnt += 1;
		}
		
		
		return retCnt;
	}


	@Override
	public String getEquipmentDomainData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.selectOne("admin.resource.selectResourceEquipmentDomainInfo", params);
		
		return map.getString("DomainCode");
	}

}
