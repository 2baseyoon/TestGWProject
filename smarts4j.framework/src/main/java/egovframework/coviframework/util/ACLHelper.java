package egovframework.coviframework.util;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import com.google.common.collect.ImmutableList;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.vo.ACLMapper;



/**
 * @Class Name : ACLHelper.java
 * @Description : 권한 처리
 * @Modification Information 
 * @ 2017.06.14 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.06.14
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */


public class ACLHelper {
	/**
	 * @param objectType
	 * @param aclList
	 * @param aclArray
	 * @return
	 * @throws Exception
	 * @description ACL 데이터로 부터 특정 데이터 쿼리
	 */
	public static Set<String> queryObjectFromACL(String objectType, String aclList, CoviList aclArray) throws Exception {
		Set<String> ret = new HashSet<>();
		
		for (int i = 0; i < aclArray.size(); i++) {
			CoviMap aclObj = aclArray.getJSONObject(i);
			
			if(!aclObj.isNullObject()){
				if(aclObj.getString("ObjectType").equalsIgnoreCase(objectType)
						&& aclObj.getString("AclList").equalsIgnoreCase(aclList)){
					ret.add(aclObj.getString("ObjectID"));
				}
			}
		}
		
		return ret;
	}
	
	/**
	 * @param objectType
	 * @param aclArray
	 * @param aclColName
	 * @param aclValue
	 * @return
	 * @throws Exception
	 * @description
	 * ACL 데이터로 부터 특정 데이터 쿼리
	 * 1. 권한의 우선 순위가 낮은 순서대로 Redis에 ACL 정보로 저장
	 * 2. 순서대로 반복문을 돌며 같은 ObjectType이 나왔을 경우 이전 내용을 엎어쓴다. 
	 * 
	 * [권한 관련 정책]
	 * 1. 개인 > 그룹 , 개인에게 권한이 지정되었을 경우 다른 정책에 관련 없이 권한 부여.
 	 * 2. 조직그룹(회사, 부서) 일 경우  하위부서 권한 > 상위부서 권한 단, 같은 수준의 부서일 경우 원소속  > 겸직소속
 	 * 3. 비조직 그룹(직위, 커뮤니티, )일 경우 하나라도 거부된 항목이 있을 때는 거부가 되는 거부우선
  	 * 4. 비조직 그룹과 조직그룹이 겹칠 경우 하나라도 거부된 항목이 있을 때는 거부가 되는 거부우선
 	 * 5. 권한 그룹에 대한 처리는 각 모듈별로 개별적 처리
	 * 
	 * 2번의 겸직 처리와 3, 4 번 구현해야 함.
	 * 
	 * [권한 관련 정책 - 2019-06-05]
	 * 위 2~4번 구현되지 않았으므로 아래와 같이 재정의
	 * 2. 겸직 권한은 세션의 계열사 및 부서 기준으로 현재 로그인한 조직정보 기준으로 조회함
	 * 3. 비조직 그룹(직위, 커뮤니티, )일 경우, 1차적으로 sys_object_group_type 테이블의  Priority 기준으로 정렬 후, AclID 기준으로 정렬함 (가장 먼저 등록된 것 기준)
	 * 4. 비조직 그룹보다는 조직 그룹이 우선순위가 높음
	 * 
	 */
	public static Set<String> queryObjectFromACL(String objectType, CoviList aclArray, String aclColName, String aclValue) throws Exception {
		Set<String> ret = new HashSet<>();
		Set<String> ignoreGroup = new HashSet<>();
		ImmutableList<String> customGroup = ImmutableList.of("JL", "JP", "JT", "MN", "OF", "GR", "CU");	//covi_smart4j.sys_object_group_type 테이블에서 확인 가능
		
		for (int i = 0; i < aclArray.size(); i++) {
			CoviMap aclObj = aclArray.getJSONObject(i);
			
			if(!aclObj.isNullObject()){
				//사용자 권한이 최우선 적으로 설정되므로 ignoreList 항목으로 skip 처리
				if(ignoreGroup.contains(aclObj.getString("ObjectID")) && !"UR".equals(aclObj.getString("SubjectType"))){
					continue;
				}
				if(	aclObj.getString("ObjectType").equalsIgnoreCase(objectType)	&& aclObj.getString(aclColName).equalsIgnoreCase(aclValue)){
						ret.add(aclObj.getString("ObjectID"));
				}else if(aclObj.getString("ObjectType").equalsIgnoreCase(objectType)	&& 
						!aclObj.getString(aclColName).equalsIgnoreCase(aclValue)){
						if(customGroup.contains(aclObj.getString("SubjectType"))){	//임의 그룹(GR)/조직(부서)이 거부로 설정 됐을 경우 부서, 직위, 직급, 직책 등의 계층적 성격의 권한 모두 거부 처리
							ignoreGroup.add(aclObj.getString("ObjectID"));
						}
						ret.remove(aclObj.getString("ObjectID"));
				}
			}
		}
		
		return ret;
	}
	
	/**
	 * @param aclList
	 * @param aclArray
	 * @return
	 * @throws Exception
	 * @description ACL 데이터로 부터 특정 데이터 쿼리
	 */
	public static Set<String> queryObjectFromACL(String aclList, CoviList aclArray) throws Exception {
		Set<String> ret = new HashSet<>();
		
		for (int i = 0; i < aclArray.size(); i++) {
			CoviMap aclObj = aclArray.getJSONObject(i);
			
			if(!aclObj.isNullObject()&& aclObj.getString("AclList").equalsIgnoreCase(aclList)){
				ret.add(aclObj.getString("ObjectID"));
			}
		}
		
		return ret;
	}
	
	
	public static Set<String> getACL(CoviMap userDataObj, String objectType, String serviceType, String aclColName) throws Exception {
		ACLSerializeUtil sUtil = new ACLSerializeUtil();
		
		ACLMapper aclMap = null;
		Set<String> ret = null;
		
		String userId = userDataObj.getString("USERID");
		String jobSeq = userDataObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
		String domainID = userDataObj.getString("DN_ID");
		String key = userId + "_" + jobSeq;
		
		String fieldName = objectType;
		
		if(serviceType != null && !serviceType.isEmpty())
			fieldName = fieldName + "_" + serviceType;
		
		// redis 에서 직렬화된 데이터 조회
		String fieldValue = RedisDataUtil.getACL(key, domainID, fieldName, 7200);
		
		if(fieldValue != null && !fieldValue.isEmpty()) {
			StringUtil func = new StringUtil();
			
			// 권한 데이터 역직렬화 ( ACLMapper 생성 )
			try {
				// 역직렬화 시 발생하는 오류에 대해서만 아래 catch문에서 처리 ( IOE, CNFE )
				aclMap = sUtil.deserializeObj(fieldValue);
				String syncKey = RedisDataUtil.getACLSyncKey(domainID, fieldName);

				//확인 필요 
				if(func.f_NullCheck(syncKey).equals(aclMap.getSynchronizeKey())) {
					// 서버에 세팅된 sync key 와 일치할경우 권한데이터 그대로 사용
					ret = aclMap.getACLInfo(aclColName);					
				} else {
					// 서버에 세팅된 sync key 와 일치하지 않을경우 DB에서 최신 권한데이터 조회 후 재세팅
					AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
					aclMap = authSvc.rebuildACL(userDataObj, fieldName);
					ret = aclMap.getACLInfo(aclColName);				
				}
			} catch(IOException ioex) {
				AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
				aclMap = authSvc.rebuildACL(userDataObj, fieldName);
				ret = aclMap.getACLInfo(aclColName);
			} catch(ClassNotFoundException cnfex) {
				AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
				aclMap = authSvc.rebuildACL(userDataObj, fieldName);
				ret = aclMap.getACLInfo(aclColName);
			}
			
		} else {
			AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
			aclMap = authSvc.rebuildACL(userDataObj, fieldName);
			ret = aclMap.getACLInfo(aclColName);
		}
		
		return ret;
	}
	
	public static ACLMapper getACLMapper(CoviMap userDataObj, String objectType, String serviceType) throws Exception {
		ACLSerializeUtil sUtil = new ACLSerializeUtil();
		
		ACLMapper aclMap = null;
		
		String userId = userDataObj.getString("USERID");
		String jobSeq = userDataObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
		String domainID = userDataObj.getString("DN_ID");
		String key = userId + "_" + jobSeq;
		
		
		String fieldName = objectType;
		
		if(serviceType != null && !serviceType.isEmpty())
			fieldName = fieldName + "_" + serviceType;
		
		// redis 에서 직렬화된 데이터 조회
		String fieldValue = RedisDataUtil.getACL(key, domainID, fieldName, 7200);
		
		if(fieldValue != null && !fieldValue.isEmpty()) {
			StringUtil func = new StringUtil();
			// 권한 데이터 역직렬화 ( ACLMapper 생성 )
			try {
				// 역직렬화 시 발생하는 오류에 대해서만 아래 catch문에서 처리 ( IOE, CNFE )
				aclMap = sUtil.deserializeObj(fieldValue);
				String syncKey = RedisDataUtil.getACLSyncKey(domainID, fieldName);
				if(!func.f_NullCheck(syncKey).equals(aclMap.getSynchronizeKey())) {
					// 서버에 세팅된 sync key 와 일치하지 않을경우 DB에서 최신 권한데이터 조회 후 재세팅
					AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
					aclMap = authSvc.rebuildACL(userDataObj, fieldName);					
				}
			} catch(IOException ioex) {
				AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
				aclMap = authSvc.rebuildACL(userDataObj, fieldName);
			} catch(ClassNotFoundException cnfex) {
				AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
				aclMap = authSvc.rebuildACL(userDataObj, fieldName);
			}
			
		} else {
			AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
			aclMap = authSvc.rebuildACL(userDataObj, fieldName);
		}
		
		return aclMap;
	}
	
	
	public static String getMenu(CoviMap userDataObj) throws Exception {
		String userId = userDataObj.getString("USERID");
		String jobSeq = userDataObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
		String domainID = userDataObj.getString("DN_ID");
		String key = userId + "_" + jobSeq;
		
		// redis 에서 직렬화된 데이터 조회
		String menuStr = RedisDataUtil.getMenu(key, domainID);
		
		if(menuStr == null || menuStr.isEmpty()) {
			menuStr = ACLHelper.setMenuArray(userDataObj);
		}
		
		return menuStr;
	}
	
	
	/**
	 * 사용자의 메뉴정보 조회
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static String setMenuArray(CoviMap userInfoObj) throws Exception{
		String menuStr = "";
		CoviList menuArray = new CoviList();
		
		String userId = userInfoObj.getString("USERID");
		String jobSeq = userInfoObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
		String domainID = userInfoObj.getString("DN_ID");
		String redisKey = userId + "_" + jobSeq;
		
		//6. acl 중 MN, View 권한 쿼리
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userInfoObj, "MN", "", "V");
		//7. object코드를 in절에 들어갈 string으로 변환
		String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		
		//8. object코드로 menu를 쿼리
		if(objectArray.length > 0){
			AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
		
			CoviMap menuParams = new CoviMap();
			menuParams.setConvertJSONObject(false);
			menuParams.put("menuIDArr", objectArray);
			menuParams.put("domainID", domainID);
			menuParams.put("lang", userInfoObj.getString("lang"));
			menuParams.put("userID", userId);
			menuParams.putOrigin("bizSectionArr", StringUtil.toTokenArray(userInfoObj.getString("UR_AssignedBizSection"),"|"));
			menuArray = authSvc.getAuthorizedMenu(menuParams);
		}
		
		//9. menu를 캐쉬에 저장
		if(menuArray != null){
			//메뉴 중복 제거
			for (int i=0; i < menuArray.size();i++){
				String originMenuId = ((CoviMap)menuArray.get(i)).getString("OriginMenuID");
				for (int j=i+1; j < menuArray.size();j++){
					if(!StringUtil.isEmpty(originMenuId) && !StringUtil.isEmpty(((CoviMap)menuArray.get(j)).getString("OriginMenuID"))) {
						if (originMenuId.equals(((CoviMap)menuArray.get(j)).getString("OriginMenuID"))){
							menuArray.remove(j);
						}
					}
				}
			}
			menuStr = menuArray.toString();
			RedisDataUtil.setMenu(redisKey, domainID, menuStr);
			//LOGGER.debug("MENU_" + domainID + "_" + userId + " : " + menuArray.toString());
		}
		
		return menuStr;
	}
	
	
	
	/**
	 * @param domainId
	 * @param isAdmin
	 * @param bizSection
	 * @param menuType
	 * @param memberOf
	 * @param menuArray
	 * @return
	 * @throws Exception
	 * @description
	 * Menu 데이터로 부터 특정 데이터 쿼리
	 * domainId와 isAdmin, BizSection은 필수 parameter
	 * menuType, parentObjectId, parentObjectType은 null 허용
	 * 
	 */
	public static CoviList queryMenu(String domainId, String isAdmin, String bizSection, String menuType, String memberOf, CoviList menuArray, String lang) throws Exception {
		return queryMenu(domainId, isAdmin, bizSection, menuType, memberOf, menuArray, lang, "P");
	}
	public static CoviList queryMenu(String domainId, String isAdmin, String bizSection, String menuType, String memberOf, CoviList menuArray, String lang, String serviceDevice) throws Exception {
		CoviList ret = new CoviList();
		
		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareIsAdmin = StringUtil.replaceNull(menuObj.get("IsAdmin"));
				String compareBizSection = StringUtil.replaceNull(menuObj.get("BizSection"));
				String compareMenuType = StringUtil.replaceNull(menuObj.get("MenuType"));
				String compareMemberOf = StringUtil.replaceNull(menuObj.get("MemberOf"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if((compareDomainID.equalsIgnoreCase("0") ||  compareDomainID.equalsIgnoreCase(domainId)) && 
					compareIsAdmin.equalsIgnoreCase(isAdmin) && 
					compareBizSection.equalsIgnoreCase(bizSection) && 
					compareMenuType.equalsIgnoreCase(menuType) && 
					compareMemberOf.equalsIgnoreCase(memberOf)){
					
					if ((compareServiceDevice.equals("") || compareServiceDevice.equals("A") ||  serviceDevice.equals(""))
							|| compareServiceDevice.equals(serviceDevice)) {
						
						if(menuObj.containsKey("MultiDisplayName")){
							menuObj.put("DisplayName", DicHelper.getDicInfo(StringUtil.replaceNull(menuObj.get("MultiDisplayName")), lang));
						}else{
							menuObj.put("DisplayName", "");
						}
						ret.add(menuObj);
					
					}
				}
			}
		}
		
		return ret;
	}
	
	/**
	 * @param domainId
	 * @param isAdmin
	 * @param menuType
	 * @param memberOf
	 * @param menuArray
	 * @return
	 * @throws Exception
	 */
	public static CoviList queryMenu(String domainId, String isAdmin, String menuType, String memberOf, CoviList menuArray) throws Exception {
		return queryMenu(domainId, isAdmin, menuType, memberOf, menuArray, "P");
	}	
	public static CoviList queryMenu(String domainId, String isAdmin, String menuType, String memberOf, CoviList menuArray, String serviceDevice) throws Exception {
		
		CoviList ret = new CoviList();
		String lang = SessionHelper.getSession("lang");
		
		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareIsAdmin = StringUtil.replaceNull(menuObj.get("IsAdmin"));
				String compareMenuType = StringUtil.replaceNull(menuObj.get("MenuType"));
				String compareMemberOf = StringUtil.replaceNull(menuObj.get("MemberOf"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if(( compareDomainID.equalsIgnoreCase("0") || compareDomainID.equalsIgnoreCase(domainId) )&& 
					compareIsAdmin.equalsIgnoreCase(isAdmin) && 
					compareMenuType.equalsIgnoreCase(menuType) && 
					compareMemberOf.equalsIgnoreCase(memberOf)){

					if ((compareServiceDevice.equals("") || compareServiceDevice.equals("A") ||  serviceDevice.equals(""))
							|| compareServiceDevice.equals(serviceDevice)) {

						if(menuObj.containsKey("MultiDisplayName")){
							menuObj.put("DisplayName", DicHelper.getDicInfo(StringUtil.replaceNull(menuObj.get("MultiDisplayName")), lang));
						}else{
							menuObj.put("DisplayName", "");
						}
						
						
						ret.add(menuObj);
					}	
				}
			}
		}
		
		return ret;
	}
	
	
	/**
	 * 
	 * @param domainId
	 * @param isAdmin
	 * @param bizSection
	 * @param menuType
	 * @param menuArray
	 * @return 권한처리된 menu 맵에서 유형별 menu 데이터 셋을 쿼리
	 * @throws Exception
	 */
	public static CoviList parseMenu(String domainId, String isAdmin, String bizSection, String menuType, String memberOf, CoviList menuArray, String lang) throws Exception {
		return parseMenu(domainId, isAdmin, bizSection, menuType, memberOf, menuArray, lang, "P");
	}
	public static CoviList parseMenu(String domainId, String isAdmin, String bizSection, String menuType, String memberOf, CoviList menuArray, String lang, String serviceDevice) throws Exception {
		CoviList ret = new CoviList();
		
		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareIsAdmin = StringUtil.replaceNull(menuObj.get("IsAdmin"));
				String compareBizSection = StringUtil.replaceNull(menuObj.get("BizSection"));
				String compareMenuType = StringUtil.replaceNull(menuObj.get("MenuType"));
				String compareMemberOf = StringUtil.replaceNull(menuObj.get("MemberOf"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if(( compareDomainID.equalsIgnoreCase("0") || compareDomainID.equalsIgnoreCase(domainId)) && 
					compareIsAdmin.equalsIgnoreCase(isAdmin) && 
					compareBizSection.equalsIgnoreCase(bizSection) && 
					compareMenuType.equalsIgnoreCase(menuType) && 
					compareMemberOf.equalsIgnoreCase(memberOf)){
					if ((compareServiceDevice.equals("") || compareServiceDevice.equals("A") ||  serviceDevice.equals(""))
							|| compareServiceDevice.equals(serviceDevice)) {
	
						String menuId = StringUtil.replaceNull(menuObj.get("MenuID"));
						if(menuObj.containsKey("MultiDisplayName")){
							menuObj.put("DisplayName", DicHelper.getDicInfo(StringUtil.replaceNull(menuObj.get("MultiDisplayName")), lang));
						}else{
							menuObj.put("DisplayName", "");
						}
						
						
						//menuType이 top, left인 경우 sub 구성
						if(menuType.equalsIgnoreCase("Top")){
							CoviList topSubArray = ACLHelper.queryMenu(domainId, isAdmin, bizSection, "TopSub", menuId, menuArray, lang);
							menuObj.put("Sub", topSubArray);
						}
						
						if(menuType.equalsIgnoreCase("Left")){
							CoviList leftSubArray = ACLHelper.queryMenu(domainId, isAdmin, bizSection, "LeftSub", menuId, menuArray, lang);
							menuObj.put("Sub", leftSubArray);
						}
						
						//해당 row 추가
						ret.add(menuObj);
					}	
				}
			}
		}
		
		return ret;
	}
	
	/**
	 * 
	 * @param domainId
	 * @param isAdmin
	 * @param bizSection
	 * @param menuType
	 * @param menuArray
	 * @return 권한처리된 menu 맵에서 유형별 menu 데이터 셋을 쿼리
	 * @throws Exception
	 */
	public static CoviList parseMenuByBiz(String domainId, String isAdmin, String bizSection, String menuType, CoviList menuArray, String lang) throws Exception {
		return parseMenuByBiz(domainId, isAdmin, bizSection, menuType, menuArray, lang, "P");
	}
	public static CoviList parseMenuByBiz(String domainId, String isAdmin, String bizSection, String menuType, CoviList menuArray, String lang, String serviceDevice) throws Exception {
		CoviList ret = new CoviList();
		
		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareIsAdmin = StringUtil.replaceNull(menuObj.get("IsAdmin"));
				String compareBizSection = StringUtil.replaceNull(menuObj.get("BizSection"));
				String compareMenuType = StringUtil.replaceNull(menuObj.get("MenuType"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if(( compareDomainID.equalsIgnoreCase("0") || compareDomainID.equalsIgnoreCase(domainId) ) && 
					compareIsAdmin.equalsIgnoreCase(isAdmin) && 
					compareBizSection.equalsIgnoreCase(bizSection) && 
					compareMenuType.equalsIgnoreCase(menuType)){
						
					if ((compareServiceDevice.equals("") || compareServiceDevice.equals("A") ||  serviceDevice.equals(""))
							|| compareServiceDevice.equals(serviceDevice)) {
						String menuId = (String)menuObj.get("MenuID");
						
						if(menuObj.containsKey("MultiDisplayName")){
							menuObj.put("DisplayName", DicHelper.getDicInfo(StringUtil.replaceNull(menuObj.get("MultiDisplayName")), lang));
						}else{
							menuObj.put("DisplayName", "");
						}
						
						//menuType이 top, left인 경우 sub 구성
						if(menuType.equalsIgnoreCase("Top")){
							CoviList topSubArray = ACLHelper.queryMenu(domainId, isAdmin, bizSection, "TopSub", menuId, menuArray, lang, serviceDevice);
							menuObj.put("Sub", topSubArray);
						}
						
						if(menuType.equalsIgnoreCase("Left")){
							CoviList leftSubArray = ACLHelper.queryMenu(domainId, isAdmin, bizSection, "LeftSub", menuId, menuArray, lang, serviceDevice);
							
							CoviList retSub = new CoviList();
							for (int j = 0; j < leftSubArray.size(); j++) {
								CoviMap menuSubObj = (CoviMap) leftSubArray.get(j);
								menuSubObj.put("Sub", ACLHelper.queryMenu(domainId, isAdmin, bizSection, "LeftSub", (String)menuSubObj.get("MenuID"), menuArray, lang, serviceDevice));
								retSub.add(menuSubObj);
							}
							menuObj.put("Sub", retSub);
						}
						
						//해당 row 추가
						ret.add(menuObj);
					}	
				}
			}
		}
		return ret;
	}
	
	/**
	 * 
	 * @param domainId
	 * @param isAdmin
	 * @param bizSection
	 * @param menuType
	 * @param menuArray
	 * @return 권한처리된 menu 맵에서 유형별 menu 데이터 셋을 쿼리
	 * @throws Exception
	 */
	public static CoviList parseMenu(String domainId, String isAdmin, String menuType, String memberOf, CoviList menuArray) throws Exception {
		return parseMenu(domainId, isAdmin, menuType, memberOf, menuArray, "P");
	}
	public static CoviList parseMenu(String domainId, String isAdmin, String menuType, String memberOf, CoviList menuArray, String serviceDevice) throws Exception {
		CoviList ret = new CoviList();
		String lang = SessionHelper.getSession("lang");

		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareIsAdmin = StringUtil.replaceNull(menuObj.get("IsAdmin"));
				String compareMenuType = StringUtil.replaceNull(menuObj.get("MenuType"));
				String compareMemberOf = StringUtil.replaceNull(menuObj.get("MemberOf"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if((compareDomainID.equalsIgnoreCase("0") || compareDomainID.equalsIgnoreCase(domainId) )&& 
					compareIsAdmin.equalsIgnoreCase(isAdmin) && 
					compareMenuType.equalsIgnoreCase(menuType) && 
					compareMemberOf.equalsIgnoreCase(memberOf)){

					if ((compareServiceDevice.equals("") || compareServiceDevice.equals("A") ||  serviceDevice.equals(""))
							|| compareServiceDevice.equals(serviceDevice)) {

						String menuId = StringUtil.replaceNull(menuObj.get("MenuID"));
						
						if(menuObj.containsKey("MultiDisplayName")){
							menuObj.put("DisplayName", DicHelper.getDicInfo((String)menuObj.get("MultiDisplayName"), lang));
						}else{
							menuObj.put("DisplayName", "");
						}
						
						//menuType이 top, left인 경우 sub 구성
						if(menuType.equalsIgnoreCase("Top")){
							CoviList topSubArray = ACLHelper.queryMenu(domainId, isAdmin, "TopSub", menuId, menuArray, serviceDevice);
							menuObj.put("Sub", topSubArray);
						}
						
						if(menuType.equalsIgnoreCase("Left")){
							CoviList leftSubArray = ACLHelper.queryMenu(domainId, isAdmin, "LeftSub", menuId, menuArray, serviceDevice);
							menuObj.put("Sub", leftSubArray);
						}
						
						//해당 row 추가
						ret.add(menuObj);
					}	
					
				}
			}
		}
		
		return ret;
	}
	
	/**
	 * DomainID(0번 도메인 포함), BizSection, ServiceDevice별 메뉴 파싱
	 * @param domainId
	 * @param bizSection
	 * @param serviceDevice
	 * @param menuArray
	 * @return
	 * @throws Exception
	 */
	public static CoviList parseMenu(String domainId, String bizSection, String serviceDevice, CoviList menuArray) throws Exception {
		CoviList ret = new CoviList();
		String lang = SessionHelper.getSession("lang");
		
		for (int i = 0; i < menuArray.size(); i++) {
			CoviMap menuObj = (CoviMap) menuArray.get(i);
			
			if(menuObj != null && !menuObj.isEmpty()) {
				String compareDomainID = StringUtil.replaceNull(menuObj.get("DomainID"));
				String compareBizSection = StringUtil.replaceNull(menuObj.get("BizSection"));
				String compareServiceDevice = StringUtil.replaceNull(menuObj.get("ServiceDevice"));
				
				if( (compareDomainID.equalsIgnoreCase("0") || compareDomainID.equalsIgnoreCase(domainId)) && 
					compareBizSection.equalsIgnoreCase(bizSection) && 
					compareServiceDevice.equalsIgnoreCase(serviceDevice)){
					//해당 row 추가
					
					if(menuObj.containsKey("MultiDisplayName")){
						menuObj.put("DisplayName", DicHelper.getDicInfo((String)menuObj.get("MultiDisplayName"), lang));
					}else{
						menuObj.put("DisplayName", "");
					}
					
					
					ret.add(menuObj);
				}
			}
		}
		
		return ret;
	}
	
	
	/**
	 * 'strings[0]'separator'strings[1]'separator...String 배열 문자열로 변환
	 * @param strings
	 * @param separator
	 * @return
	 */
	public static String join(String[] strings, String separator) {
	    StringBuffer sb = new StringBuffer();
	    for (int i = 0; i < strings.length; i++) {
	        if(i > 0){ 
	        	sb.append(separator);
        	}
	        sb.append("'" + strings[i] + "'");
	    }
	    return sb.toString();
	}	
	
	 public static String[] getAssignedGroup(CoviMap userInfo) throws Exception {
		AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
		String[] subjectInArr =  authSvc.getAssignedSubject(userInfo);
		return subjectInArr;
	 }
	 
	 public static boolean getExitsUserGroup(CoviMap userInfo, String sFindGroup) throws Exception {
		String[] subjectInArr = getAssignedGroup(userInfo);
		if(java.util.Arrays.asList(subjectInArr).contains(sFindGroup)) {
			return true;
		}else{
			return false;
		}
			
    }
}
