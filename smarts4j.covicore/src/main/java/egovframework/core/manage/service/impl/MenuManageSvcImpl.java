package egovframework.core.manage.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Stack;

import javax.annotation.Resource;





import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.manage.service.MenuManageSvc;
import egovframework.coviframework.exception.MenuAliasDuplicationException;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.logging.LoggerHelper;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("MenuManageSvc")
public class MenuManageSvcImpl extends EgovAbstractServiceImpl implements MenuManageSvc{
	
	@Autowired
	AuthorityService authSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		
		/*
		 * select 해 온 list를 tree형태의 데이터로 만드는 코드 필요
		 * */
		
		CoviList clist = coviMapperOne.list("menu.selectgrid", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "MenuID,DomainID,IsAdmin,MenuType,BizSection,ParentObjectID,ParentObjectType,ServiceDevice,DisplayName,MultiDisplayName,IconClass,MemberOf,MenuPath,LinkMenuID,SecurityLevel,SortKey,SortPath,SiteMapPosition,HasFolder,IsInherited,IsUse,IsDisplay,URL,MobileURL,Target,MobileTarget,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,MenuTypeName,BizSectionName"));
		return resultList;
	}
	
	/**
	 * 메뉴 트리
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */	
	@Override
	public CoviMap selectTree(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("menu.selectTree", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "no,nodeName,pno,SortPath,childCnt,DomainID,IsAdmin"));
				  
		return resultList;
	}
	
	/**
	 * 메뉴 트리(이동 대상의 부모, 자식 menuId 조회)
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */	
	@Override
	public CoviMap selectMoveTargetForValidation(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("menu.selectMoveTargetForValidation", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "menuIds,parentMenuId,tarSortUpYn"));	
		
		return resultList;
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public CoviMap insert(CoviMap paramMenu, CoviList aclInfo)throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		
		if(checkDuplicatedMenuAlias(paramMenu)) {
			throw new MenuAliasDuplicationException(DicHelper.getDic("msg_duplicated_menuAlias"));		// 입력하신 메뉴 별칭은 사용할 수 없습니다.
		}
		
		//Menu insert
		cnt = coviMapperOne.insert("menu.insertMenu", paramMenu);
		String menuID = paramMenu.getString("MenuID");
		
		//ACL insert
		if(cnt > 0 || !menuID.isEmpty()){
			cnt += updateACL(aclInfo, menuID, null);
			
			CoviMap selectOneParam = new CoviMap();
			selectOneParam.put("menuID", menuID);	
			resultList = selectOne(selectOneParam);
		}
		return resultList;
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("menu.selectone", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(map, "MenuID,DomainID,IsAdmin,MenuType,BizSection,ParentObjectID,ParentObjectType,ServiceDevice,DisplayName,MultiDisplayName,IconClass,MemberOf,MenuPath,LinkMenuID,SecurityLevel,SortKey,SortPath,SiteMapPosition,HasFolder,IsInherited,IsUse,IsDisplay,URL,MobileURL,Target,MobileTarget,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,OriginMenuID,IsCopy,MenuAlias"));
		
		return resultList;
	}
	
	@Override
	public int move(CoviMap params) throws Exception {
		return coviMapperOne.update("menu.moveMenu", params);
	}
	
	public Long selectChildCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("menu.selectChildCount", params);
	}
	public Long selectMaxSortKey(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("menu.selectMaxSortKey", params);
	}

	@Override
	public int moveMenu(CoviMap params) throws Exception {
		String menuId = params.getString("menuId");	// 이동 대상 menuId
		String sortPath = params.getString("sortPath");	// 이동 대상 sortPath
		String tarMenuId = params.getString("tarMenuId");	// 선택 대상 menuId
		String tarSortPath = params.getString("tarSortPath");	// 선택 대상 sortPath
		String tarChildCnt = params.getString("tarChildCnt");	// 선택 대상 자식 갯수
		String tarSortUpYn = params.getString("tarSortUpYn");	// 이동 대상과 선택 대상이 같은 depth의 항목이며 이동 대상보다 선택 대상의sort가 뒤인지 여부(sort -1을 하기  위함)
		String tarDomainId = params.getString("tarDomainId");	// 선택 대상 domainId
		String tarIsAdmin = params.getString("tarIsAdmin");	// 선택 대상 관리자 여부
		String userCode = params.getString("userCode");	// 세션 userId
		
		StringUtil func = new StringUtil();

		int returnCnt = 0;
		String newSortPath = "";
		String[] orgPath = null;
		
		if (tarSortUpYn.equals("Y")) {
			orgPath = tarSortPath.split(";");
			int len = orgPath.length;
			String [] newPath = Arrays.copyOf(orgPath, len);
			newPath[len -1] = String.format("%015d", Integer.parseInt(orgPath[len -1]) -1); 
			newSortPath = StringUtils.join(newPath, ";") + ";";
		} else {
			newSortPath = tarSortPath;
		}
		newSortPath += String.format("%015d", Integer.parseInt(tarChildCnt));	// sortPath 생성
		newSortPath += ";";

		// 1. 이동대상 데이터 가공
		ArrayList<CoviMap> dataList = null;
		dataList = new ArrayList<CoviMap>();
		CoviMap jo = null;
		
		jo = new CoviMap();
		jo.put("sortKey", tarChildCnt);
		jo.put("sortPath", newSortPath);
		jo.put("parentObjectId", tarMenuId);
		jo.put("memberOf", tarMenuId);
		jo.put("domainId", tarDomainId);
		jo.put("isAdmin", tarIsAdmin);
		jo.put("userCode", userCode);
		jo.put("menuId", menuId);
		
		dataList.add(jo);
		
		// 2. 이동대상 자식 데이터 가공
		CoviList list = null;
		list = coviMapperOne.list("menu.selectMoveTargetChild", params);
		
		int size = 0;
		size = list.size();
		
		if (size > 0) {
			for (int i=0; i<size; i++) {
				CoviMap map = (CoviMap) list.get(i);
				
				String newPath = map.getString("SortPath").replaceFirst(sortPath,"");
				
				jo = new CoviMap();
				jo.put("sortPath", newSortPath + newPath);
				jo.put("domainId", tarDomainId);
				jo.put("isAdmin", tarIsAdmin);
				jo.put("userCode", userCode);
				jo.put("menuId", map.getString("MenuID"));
				
				dataList.add(jo);
			}
		}
		
		// 3. 이동대상 동료, 동료 자식 데이터 가공
		list = coviMapperOne.list("menu.selectMoveTargetSiblings", params);
		
		size = list.size();
		
		if (size > 0) {
			String newKey = "";
			String newPathStr = "";
			String childNewPath = "";
			int len = 0;
			
			for (int i=0; i<size; i++) {
				// 3-1. 이동대상 동료 데이터 가공
				CoviMap map = (CoviMap) list.get(i);
				String siblingsSortPath = map.getString("SortPath");
				
				newKey = String.valueOf(map.getInt("SortKey") - 1);
				orgPath = siblingsSortPath.split(";");
				len = orgPath.length;
				String [] newPath = Arrays.copyOf(orgPath, len);
				newPath[len -1] = String.format("%015d", Integer.parseInt(newKey));
				newPathStr = StringUtils.join(newPath, ";") + ";";
				
				jo = new CoviMap();
				jo.put("sortKey", newKey);
				jo.put("sortPath", newPathStr);
				jo.put("userCode", userCode);
				jo.put("menuId", map.getString("MenuID"));
				
				dataList.add(jo);
				
				// 3-2. 이동대상 동료 자식 데이터 가공
				params.put("menuId", map.getString("MenuID"));
				CoviList childList = coviMapperOne.list("menu.selectMoveTargetChild", params);
				
				int childSize = childList.size(); 
				
				if (childSize > 0) {
					for (int j=0; j<childSize; j++) {
						CoviMap childMap = (CoviMap) childList.get(j);
						
						childNewPath = childMap.getString("SortPath").replaceFirst(siblingsSortPath, newPathStr);
						
						jo = new CoviMap();
						jo.put("sortPath", childNewPath);
						jo.put("userCode", userCode);
						jo.put("menuId", childMap.getString("MenuID"));
						
						dataList.add(jo);
					}
				}	
			}
		}
		
		// 4. 데이터 수정
		if (dataList.size() > 0) {
			
			String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				CoviMap FolderParams = new CoviMap();
				CoviMap obj = null;
				
				for(int j = 0; j < dataList.size(); j ++){
					obj = dataList.get(j);
					
					FolderParams.put("sortKey", obj.get("sortKey"));
					FolderParams.put("parentObjectId", obj.get("parentObjectId"));
					FolderParams.put("memberOf", obj.get("memberOf"));
					FolderParams.put("domainId", obj.get("domainId"));
					FolderParams.put("isAdmin", obj.get("isAdmin"));
					FolderParams.put("sortPath", obj.get("sortPath"));
					FolderParams.put("userCode", obj.get("userCode"));
					FolderParams.put("menuId", obj.get("menuId"));
					
					returnCnt = coviMapperOne.update("menu.moveMenuByPopup", FolderParams);
				}	
				
			}else{
				params.put("dataList", dataList);
				returnCnt = coviMapperOne.update("menu.moveMenuByPopup", params);
			}
			
		}
		
		// 5. 상속 권한 처리
		CoviMap delParams = new CoviMap();
		delParams.put("objectID", menuId);
		delParams.put("objectType", "MN");
		
		authSvc.deleteInheritedACL(delParams);
		
		return returnCnt;
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAuth(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("menu.admin.selectAuth", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GrID,GrName,GrType"));
		return resultList;
	}
	
	/**
	 * 데이터 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public CoviMap update(CoviMap params, CoviList aclArray)throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		
		if(checkDuplicatedMenuAlias(params)) {
			throw new MenuAliasDuplicationException(DicHelper.getDic("msg_duplicated_menuAlias"));		// 입력하신 메뉴 별칭은 사용할 수 없습니다.
		}
		
		//menu update
		String menuID = params.get("menuID").toString();
		cnt = coviMapperOne.update("menu.updateMenu", params);
		
		if(cnt > 0) {
			// 권한 변경 내역이 있으면 변경한다.
			if(StringUtil.isNotNull(params.getString("aclIsChange")) && "Y".equals(params.getString("aclIsChange"))) {
				CoviMap deleteAclParam = new CoviMap();
				deleteAclParam.put("objectID", menuID);
				deleteAclParam.put("objectType", "MN");
				deleteAclParam.put("registerCode", SessionHelper.getSession("USERID"));
				
				// 권한 변경 이력
				String logChangeID = LoggerHelper.authLogger(deleteAclParam, "Before");

				// 권한 삭제
				coviMapperOne.delete("framework.authority.deleteACL", deleteAclParam);
				
				// 권한 수정
				cnt += updateACL(aclArray, menuID, logChangeID);
				
				// 권한 상속 처리
				authSvc.setInheritedACL(menuID, "MN", ("Y".equals(params.getString("isUpdateChildren"))));
			}
			
			CoviMap selectOneParam = new CoviMap();
			selectOneParam.put("menuID", menuID);
			resultList = selectOne(selectOneParam);
		}
		
		// 메뉴 사용 안함 처리 시 하위 메뉴도 사용 안함으로 처리
		if (StringUtil.isNotNull(params.getString("isUse")) && params.getString("isUse").equals("N")) {
			Stack<String> stack = new Stack<>();
			stack.add(menuID);
			
			CoviMap menuParams = new CoviMap();
			menuParams.put("modID", params.getString("modID"));
			menuParams.put("isUse", "N");
			
			while (!stack.isEmpty()) {
				String sMenuID = stack.pop();
				menuParams.put("menuId", sMenuID); // menu.selectMoveTargetChild parameter
				menuParams.put("menuID", sMenuID); // menu.updateMenuIsUse parameter
				
				coviMapperOne.update("menu.updateMenuIsUse", menuParams);
				
				// 하위 메뉴 조회
				CoviList list = coviMapperOne.list("menu.selectMoveTargetChild", menuParams);
				for (int i = 0; i < list.size(); i++) {
					CoviMap map = (CoviMap) list.get(i);
					stack.add(map.getString("MenuID"));
				}
			}
		}
		
		return resultList;
	}
	
	/**
	 * 사용유무 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public Object updateIsUse(CoviMap params) throws Exception {
		CoviList childrenList = new CoviList();
		String menuID = params.get("cnID").toString();
		String isUse = params.get("isUse").toString();
		
		CoviMap menuParams = new CoviMap();
		menuParams.put("menuID", menuID);
		menuParams.put("isUse", isUse);
		coviMapperOne.update("menu.updateMenuIsUse", menuParams);
		
		if (StringUtil.isNotNull(isUse) && isUse.equals("N")) {
			Stack<String> stack = new Stack<>();
			menuParams.put("menuId", menuID);
			CoviList list = coviMapperOne.list("menu.selectMoveTargetChild", menuParams);
			for (int i = 0; i < list.size(); i++) {
				CoviMap map = (CoviMap) list.get(i);
				stack.add(map.getString("MenuID"));
			}
			
			while (!stack.isEmpty()) {
				String sMenuID = stack.pop();
				CoviMap childMenuParams = new CoviMap(menuParams);
				childMenuParams.put("menuId", sMenuID); // menu.selectMoveTargetChild parameter
				childMenuParams.put("menuID", sMenuID); // menu.updateMenuIsUse parameter
				
				childrenList.add(sMenuID);
				
				coviMapperOne.update("menu.updateMenuIsUse", childMenuParams);
				
				// 하위 메뉴 조회
				CoviList childlist = coviMapperOne.list("menu.selectMoveTargetChild", childMenuParams);
				for (int i = 0; i < childlist.size(); i++) {
					CoviMap map = (CoviMap) childlist.get(i);
					stack.add(map.getString("MenuID"));
				}
			}
		}
		
		return childrenList;
	};
	
	/**
	 * 데이터 삭제
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public int delete(CoviMap params)throws Exception {
		//sql injection 방지 처리 할 것
		//delete menu
		int cnt = 0;
		String menuIDs = params.get("menuIDs").toString();
		CoviMap paramsMenu = new CoviMap();
		paramsMenu.put("menuIDs", menuIDs);
		paramsMenu.put("menuIDArr", menuIDs.split(","));
		cnt = coviMapperOne.delete("menu.deleteMenu", paramsMenu);
		
		if(cnt > 0){
			CoviMap paramsACL = new CoviMap();
			paramsACL.put("objectIDs", menuIDs.split(","));
			paramsACL.put("objectType", "MN");
			cnt += coviMapperOne.delete("framework.authority.deleteACLList", paramsACL);
		}
		
		return cnt;
	}
	
	/**
	 * 메뉴 내보내기
	 * @param params - CoviMap
	 * @return int - 내보내기 결과 상태
	 * @throws Exception
	 */
	@Override
	public int exportMenu(CoviMap params) throws Exception {
		int result = 0;
		
		String[] importDomainIDList = params.getString("domainIds").split(";");
		String originSortPath = params.getString("sortPath"); 
		// 메뉴 전체 내보내기를 할 때 , originSortPath의 값은 관리자 메뉴 : Y, 사용자 메뉴 : N 으로 사용
		CoviList list = new CoviList();
		
		for(String importDomainId : importDomainIDList) { // 내보낼 메뉴를 받을 도메인 리스트
			ArrayList<String> newMenuIDList = new ArrayList<>();
			
			CoviList menuList = new CoviList();
			CoviMap menuParam = new CoviMap();
			
			menuParam.put("ExportDomainId", params.getString("exportMenuDomain"));
			menuParam.put("menuId", params.getString("menuId"));
			// menuId  값이 -1이면, 메뉴 전체 내보내기 사용
			menuParam.put("IsAdmin", originSortPath); 
			// 메뉴 전체 내보내기를 할 때 사용, 이 때 IsAdmin 키에 originSortPath 값 들어감(Y or N)
			
			menuParam.put("IsAll", params.getString("isAll"));
			menuParam.put("ImportDomainId", importDomainId);
			
			list = coviMapperOne.list("menu.selectExportMenu", menuParam);
			
			if(list.size() > 0) { // 내보낼 메뉴들에 대해서 데이터를 가공
				for(int i = 0; i <list.size(); i++) {
					CoviMap map = list.getMap(i);
					menuParam = new CoviMap();
					
					menuParam.put("menuId", map.getString("MenuID"));
					menuParam.put("sortPath", map.getString("SortPath"));
					menuParam.put("sortKey", map.getString("SortKey"));
					menuParam.put("isAdmin", map.getString("IsAdmin"));
					menuParam.put("isExistMenu", map.getString("IsExistMenu"));
					
					menuList.add(menuParam);
				}
				
				CoviList cList = new CoviList();
				
				for (int i = 0; i < menuList.size(); i++) {
					CoviMap cMap = menuList.getMap(i);
					cMap.put("domainID", importDomainId);
					/* sortPath 와 sortKey는 도메인이 달라도 항상 같게 조정 */
					String updateSortPath = cMap.getString("sortPath");
					String updateSortKey = cMap.getString("sortKey");
					
					cMap.put("sortPath", updateSortPath);
					cMap.put("sortKey", updateSortKey);
					
					cList.add(cMap);
				}

				CoviList newExportMenuList = new CoviList();
				CoviList existExportMenuList = new CoviList();
				
				for(int i=0; i<cList.size(); i++) {
					CoviMap map = cList.getMap(i);
					
					if("N".equals(map.get("isExistMenu"))) {
						newExportMenuList.add(cList.get(i)); //새로운 메뉴
						newMenuIDList.add(map.getString("menuId"));
					} else {
						existExportMenuList.add(cList.get(i)); //내보내기로 이미 받았던 메뉴
					}
				}
				
				CoviMap newExportMenuObject = new CoviMap();
				
				newExportMenuObject.put("cList", newExportMenuList);
				newExportMenuObject.put("menuIDList", newMenuIDList);
				newExportMenuObject.put("userCode", SessionHelper.getSession("USERID"));
				newExportMenuObject.put("domainID", importDomainId);
				
				if(newExportMenuList.size() > 0) {
					result += coviMapperOne.insert("menu.insertExportMenu", newExportMenuObject);
					coviMapperOne.update("menu.updateExportMenu", newExportMenuObject);
					coviMapperOne.insert("menu.insertExportMenuACL", newExportMenuObject);
				}
				
				if(existExportMenuList.size()>0) {
					coviMapperOne.update("menu.updateExportMenuPath", existExportMenuList);
				}
				
			}
		}
		
		return result;
	}
	
	@Override
	public void removeRedisMenuCache(String pDomainID){
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		instance.removeAll("",  RedisDataUtil.PRE_MENU + pDomainID + "*");
		// instance.removeAll("",  RedisDataUtil.PRE_MENU_E + pDomainID + "*");
	}
	
	private int updateACL(CoviList aclInfo, String menuID, String logChangeID) throws Exception {
		int cnt = 0;
		CoviMap aclObj;
		for(int i=0;i<aclInfo.size();i++){
			aclObj = aclInfo.getJSONObject(i);
			String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
			
			CoviMap params = new CoviMap();
			params.put("objectID", menuID);			//ObjectID: FolderID
			params.put("objectType", "MN");			//ObjectType: FD
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
			params.put("registDate", System.currentTimeMillis());
			params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
			params.put("isSubInclude", aclObj.get("IsSubInclude"));			
			cnt += coviMapperOne.insert("framework.authority.insertACL", params);

			if(logChangeID != null) {
				params.put("logChangeID", logChangeID);
			}
			
			// 로그 변경 이력
			logChangeID = LoggerHelper.authLogger(params, "After");
		}
		
		return cnt;
	}
	
	private boolean checkDuplicatedMenuAlias(CoviMap params) throws Exception {
		int cnt = coviMapperOne.selectOne("menu.checkDuplicatedMenuAlias", params);
		return (cnt > 0);
	};
}
