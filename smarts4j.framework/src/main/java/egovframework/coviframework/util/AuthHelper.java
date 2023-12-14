package egovframework.coviframework.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;



import egovframework.baseframework.util.json.JSONSerializer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.baseframework.util.RedisShardsUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("authHelperService")
public class AuthHelper extends EgovAbstractServiceImpl{

//	@Autowired
//	private CacheManager cacheManager;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;

	/**
	 * @param grIDs
	 * @return
	 * @throws Exception
	 */
	public ArrayList<HashMap<String,String>> getAdminAuthList(String grIDs)throws Exception{
		ArrayList<HashMap<String,String>> adminAuthList = new ArrayList<HashMap<String,String>>();

		CoviMap paramAdminMenu = new CoviMap();
		paramAdminMenu.put("grIDs", grIDs); //그룹아이디 값 하드코딩을 제거 할 것
		//전체 관리자 메뉴를 캐쉬처리 - 위치를 bean으로 이동할 것
		List<?> list = (List<?>) cacheLoadSvc.selectAdminMenuCache(paramAdminMenu);

		for (int i = 0; i < list.size(); i++) {
			CoviMap eMap = (CoviMap) list.get(i);
			if (eMap.get("CN_ID") != null) {
				HashMap<String, String> map = new HashMap<String, String>();

				map.put("CN_ID",Objects.toString(eMap.get("CN_ID"),""));//Integer cnID,
				map.put("ContainerType",Objects.toString(eMap.get("ContainerType"), ""));//String containerType,
				map.put("Alias",Objects.toString(eMap.get("Alias"),""));//String alias,
				map.put("DisplayName",Objects.toString(eMap.get("DisplayName"),""));//String displayName,
				map.put("LinkMN",Objects.toString(eMap.get("LinkMN"),""));//String linkMN,
				map.put("LinkSystem",Objects.toString(eMap.get("LinkSystem"),""));//String linkSystem,
				map.put("MemberOf",Objects.toString(eMap.get("MemberOf"),""));//Integer memberOf,
				map.put("SortKey",Objects.toString(eMap.get("SortKey"),""));//Integer sortKey,
				map.put("IsURL",Objects.toString(eMap.get("IsURL"),""));//String isURL,
				map.put("URL",Objects.toString(eMap.get("URL"),""));//String url,
				map.put("IsUse",Objects.toString(eMap.get("IsUse"),""));//String isUse,
				map.put("Description",Objects.toString(eMap.get("Description"),""));//String description,
				map.put("RegID",Objects.toString(eMap.get("RegID"),""));//String regID,
				map.put("RegDate",Objects.toString(eMap.get("RegDate"),""));//String regDate,
				map.put("ModID",Objects.toString(eMap.get("ModID"),""));//String modID,
				map.put("ModDate",Objects.toString(eMap.get("ModDate"),""));//String modDate,
				map.put("ChildCount",Objects.toString(eMap.get("ChildCount"),""));//Integer childCount,
				map.put("ProgramURL",Objects.toString(eMap.get("ProgramURL"),""));//String programURL,
				map.put("PG_ID",Objects.toString(eMap.get("PG_ID"),""));//Integer pgID,
				map.put("ProgramName",Objects.toString(eMap.get("ProgramName"),""));//String programName,
				map.put("ProgramAlias",Objects.toString(eMap.get("ProgramAlias"),""));//String programAlias,
				map.put("ProgramType",Objects.toString(eMap.get("ProgramType"),""));//String programType,
				map.put("ProgramDescription",Objects.toString(eMap.get("ProgramDescription"),""));//String programDescription,
				map.put("ProgramBizSection",Objects.toString(eMap.get("ProgramBizSection"),""));//String programBizSection,
				map.put("Ko",Objects.toString(eMap.get("Ko"),""));//String ko,
				map.put("En",Objects.toString(eMap.get("En"),""));//String en,
				map.put("Ja",Objects.toString(eMap.get("Ja"),""));//String ja,
				map.put("Zh",Objects.toString(eMap.get("Zh"),""));//String zh,
				map.put("Reserved1",Objects.toString(eMap.get("Reserved1"),""));//String reserved1,
				map.put("Reserved2",Objects.toString(eMap.get("Reserved2"),""));//String reserved2

				adminAuthList.add(map);
			}
		}

		return adminAuthList;
	}

	/**
	 * @param grIDs
	 * @return
	 * @throws Exception
	 */
	public CoviList getAdminAuthJSON(String grIDs)throws Exception{
		CoviList resultList = new CoviList();

		CoviMap paramAdminMenu = new CoviMap();
		paramAdminMenu.put("grIDs", grIDs); //그룹아이디 값 하드코딩을 제거 할 것
		//전체 관리자 메뉴를 캐쉬처리 - 위치를 bean으로 이동할 것
		List<?> list = (List<?>) cacheLoadSvc.selectAdminMenuCache(paramAdminMenu);

		for (int i = 0; i < list.size(); i++) {
			CoviMap eMap = (CoviMap) list.get(i);
			if (eMap.get("CN_ID") != null) {
				CoviMap newObject = new CoviMap();

				newObject.put("CN_ID",Objects.toString(eMap.get("CN_ID"),""));//Integer cnID,
				newObject.put("ContainerType",Objects.toString(eMap.get("ContainerType"), ""));//String containerType,
				newObject.put("Alias",Objects.toString(eMap.get("Alias"),""));//String alias,
				newObject.put("DisplayName",Objects.toString(eMap.get("DisplayName"),""));//String displayName,
				newObject.put("LinkMN",Objects.toString(eMap.get("LinkMN"),""));//String linkMN,
				newObject.put("LinkSystem",Objects.toString(eMap.get("LinkSystem"),""));//String linkSystem,
				newObject.put("MemberOf",Objects.toString(eMap.get("MemberOf"),""));//Integer memberOf,
				newObject.put("SortKey",Objects.toString(eMap.get("SortKey"),""));//Integer sortKey,
				newObject.put("IsURL",Objects.toString(eMap.get("IsURL"),""));//String isURL,
				newObject.put("URL",Objects.toString(eMap.get("URL"),""));//String url,
				newObject.put("IsUse",Objects.toString(eMap.get("IsUse"),""));//String isUse,
				newObject.put("Description",Objects.toString(eMap.get("Description"),""));//String description,
				newObject.put("RegID",Objects.toString(eMap.get("RegID"),""));//String regID,
				newObject.put("RegDate",Objects.toString(eMap.get("RegDate"),""));//String regDate,
				newObject.put("ModID",Objects.toString(eMap.get("ModID"),""));//String modID,
				newObject.put("ModDate",Objects.toString(eMap.get("ModDate"),""));//String modDate,
				newObject.put("ChildCount",Objects.toString(eMap.get("ChildCount"),""));//Integer childCount,
				newObject.put("ProgramURL",Objects.toString(eMap.get("ProgramURL"),""));//String programURL,
				newObject.put("PG_ID",Objects.toString(eMap.get("PG_ID"),""));//Integer pgID,
				newObject.put("ProgramName",Objects.toString(eMap.get("ProgramName"),""));//String programName,
				newObject.put("ProgramAlias",Objects.toString(eMap.get("ProgramAlias"),""));//String programAlias,
				newObject.put("ProgramType",Objects.toString(eMap.get("ProgramType"),""));//String programType,
				newObject.put("ProgramDescription",Objects.toString(eMap.get("ProgramDescription"),""));//String programDescription,
				newObject.put("ProgramBizSection",Objects.toString(eMap.get("ProgramBizSection"),""));//String programBizSection,
				newObject.put("Ko",Objects.toString(eMap.get("Ko"),""));//String ko,
				newObject.put("En",Objects.toString(eMap.get("En"),""));//String en,
				newObject.put("Ja",Objects.toString(eMap.get("Ja"),""));//String ja,
				newObject.put("Zh",Objects.toString(eMap.get("Zh"),""));//String zh,
				newObject.put("Reserved1",Objects.toString(eMap.get("Reserved1"),""));//String reserved1,
				newObject.put("Reserved2",Objects.toString(eMap.get("Reserved2"),""));//String reserved2

				resultList.add(newObject);
			}
		}

		return resultList;
	}

	/**
	 *  관리자 메뉴 그리기
	 * 1. Top 가져오기
	 * 2. TopSub 가져오기
	 * @param menuList
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	public CoviList drawTopMenu(ArrayList<HashMap<String,String>> menuList, String lang)throws Exception{
		CoviList resultList = new CoviList();

		/*
		 * 사용자마다 2개의 row를 할당 - 상단, 좌측
		 * key는 session id
		 * val는 json string [{"childCount":"2","cnID":"1","label":"관리홈","sortKey":"0","memberOf":"0","url":"","sub":[]}....]
		 * */
		ArrayList<HashMap<String,String>> top = new ArrayList<HashMap<String,String>>();

		top = getAdminMenu(menuList,"Top", "0", lang);

		//Top - TopSub, Left
		if(top.size() > 0){

			for(int i=0; i < top.size(); i++){
				CoviMap newObject = new CoviMap();
				HashMap<String, String> map = (HashMap<String, String>) top.get(i);
	            for (Map.Entry<String, String> entry : map.entrySet()) {
	            	newObject.put(entry.getKey(), entry.getValue());
	            }

	            if(Integer.parseInt(newObject.get("childCount").toString()) > 0){
	            	//topsub
	            	ArrayList<HashMap<String,String>> topSub = new ArrayList<HashMap<String,String>>();
	        		topSub = getAdminMenu(menuList,"TopSub", newObject.get("menuid").toString(), lang);
					newObject.put("cn", drawMenu(topSub));

					//left
					/*
					ArrayList<HashMap<String,String>> left = new ArrayList<HashMap<String,String>>();
	        		left = getAdminMenu(menuList,"Left", newObject.get("cnID").toString(), lang);
					newObject.put("left", drawMenu(left));
					*/
				}

	            resultList.add(newObject);
			}
		}


		return resultList;
	}

//	@SuppressWarnings("unchecked")
//	public CoviList getCachedTopMenu(String usrId, String lang)throws Exception{
//		Cache cacheAdminMenu = cacheManager.getCache("cacheAdminMenu");
//		Element element = cacheAdminMenu.get("AdminMenuAuth_" + usrId);
//		ArrayList<HashMap<String,String>> menuList = new ArrayList<HashMap<String,String>>();
//	    if (element != null) {
//	    	menuList = (ArrayList<HashMap<String,String>>)element.getObjectValue();
//	    }
//	    //전체 메뉴에서 home의 top값과 top의 topsub값을 쿼리
//	    CoviList resultList = new CoviList();
//	    resultList = drawTopMenu(menuList, lang);
//
//	    return resultList;
//	}

	
	/**
	 * 정렬 문제로 JsonArray -> ArrayList, 다시 arraylis -> JsonArray로 converting하는 불필요한 과정이 있음
	 * 향후 jsonArray상에서 정렬하는 방식으로 코드를 변경할 것
	 * @param usrId
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	public CoviList getRedisCachedTopMenu(String usrId, String lang)throws Exception{
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String strJsonAuth = instance.get("AdminMenuAuth_" + usrId);

		ArrayList<HashMap<String,String>> menuList = convertJsonStringToList(strJsonAuth);

	    //전체 메뉴에서 home의 top값과 top의 topsub값을 쿼리
	    CoviList resultList = new CoviList();
	    resultList = drawTopMenu(menuList, lang);

	    return resultList;
	}

	public ArrayList<HashMap<String,String>> convertJsonStringToList(String jsonStringAuth){
		ArrayList<HashMap<String,String>> adminAuthList = new ArrayList<HashMap<String,String>>();

		CoviList authJsonArray =(CoviList) JSONSerializer.toJSON(jsonStringAuth);
		for(Object js : authJsonArray){
            CoviMap json = (CoviMap)js;

            HashMap<String, String> map = new HashMap<String, String>();

			map.put("CN_ID",Objects.toString(json.get("CN_ID"),""));//Integer cnID,
			map.put("ContainerType",Objects.toString(json.get("ContainerType"), ""));//String containerType,
			map.put("Alias",Objects.toString(json.get("Alias"),""));//String alias,
			map.put("DisplayName",Objects.toString(json.get("DisplayName"),""));//String displayName,
			map.put("LinkMN",Objects.toString(json.get("LinkMN"),""));//String linkMN,
			map.put("LinkSystem",Objects.toString(json.get("LinkSystem"),""));//String linkSystem,
			map.put("MemberOf",Objects.toString(json.get("MemberOf"),""));//Integer memberOf,
			map.put("SortKey",Objects.toString(json.get("SortKey"),""));//Integer sortKey,
			map.put("IsURL",Objects.toString(json.get("IsURL"),""));//String isURL,
			map.put("URL",Objects.toString(json.get("URL"),""));//String url,
			map.put("IsUse",Objects.toString(json.get("IsUse"),""));//String isUse,
			map.put("Description",Objects.toString(json.get("Description"),""));//String description,
			map.put("RegID",Objects.toString(json.get("RegID"),""));//String regID,
			map.put("RegDate",Objects.toString(json.get("RegDate"),""));//String regDate,
			map.put("ModID",Objects.toString(json.get("ModID"),""));//String modID,
			map.put("ModDate",Objects.toString(json.get("ModDate"),""));//String modDate,
			map.put("ChildCount",Objects.toString(json.get("ChildCount"),""));//Integer childCount,
			map.put("ProgramURL",Objects.toString(json.get("ProgramURL"),""));//String programURL,
			map.put("PG_ID",Objects.toString(json.get("PG_ID"),""));//Integer pgID,
			map.put("ProgramName",Objects.toString(json.get("ProgramName"),""));//String programName,
			map.put("ProgramAlias",Objects.toString(json.get("ProgramAlias"),""));//String programAlias,
			map.put("ProgramType",Objects.toString(json.get("ProgramType"),""));//String programType,
			map.put("ProgramDescription",Objects.toString(json.get("ProgramDescription"),""));//String programDescription,
			map.put("ProgramBizSection",Objects.toString(json.get("ProgramBizSection"),""));//String programBizSection,
			map.put("Ko",Objects.toString(json.get("Ko"),""));//String ko,
			map.put("En",Objects.toString(json.get("En"),""));//String en,
			map.put("Ja",Objects.toString(json.get("Ja"),""));//String ja,
			map.put("Zh",Objects.toString(json.get("Zh"),""));//String zh,
			map.put("Reserved1",Objects.toString(json.get("Reserved1"),""));//String reserved1,
			map.put("Reserved2",Objects.toString(json.get("Reserved2"),""));//String reserved2

			adminAuthList.add(map);
        }


		return adminAuthList;
	}

//	@SuppressWarnings("unchecked")
//	public CoviList getCachedLeftMenu(String usrId, String cnID, String lang)throws Exception{
//		Cache cacheAdminMenu = cacheManager.getCache("cacheAdminMenu");
//		Element element = cacheAdminMenu.get("AdminMenuAuth_" + usrId);
//		ArrayList<HashMap<String,String>> menuList = new ArrayList<HashMap<String,String>>();
//	    if (element != null) {
//	    	menuList = (ArrayList<HashMap<String,String>>)element.getObjectValue();
//	    }
//	    //전체 메뉴에서 home의 left값과 left의 left값을 쿼리
//	    CoviList resultList = new CoviList();
//	    resultList = drawLeftMenu(menuList, cnID, lang);
//
//	    return resultList;
//	}

	/**
	 * Redis에서 관리자 LeftMenu 정보 조회
	 * @param usrId
	 * @param cnID
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	public CoviList getRedisCachedLeftMenu(String usrId, String cnID, String lang)throws Exception{
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String strJsonAuth = instance.get("AdminMenuAuth_" + usrId);

		ArrayList<HashMap<String,String>> menuList = convertJsonStringToList(strJsonAuth);

	    //전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    resultList = drawLeftMenu(menuList, cnID, lang);

	    return resultList;
	}

	/**
	 * 조회된 관리자 Left Menu데이터 파싱
	 * @param menuList
	 * @param cnID
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	public CoviList drawLeftMenu(ArrayList<HashMap<String,String>> menuList, String cnID, String lang)throws Exception{
		CoviList resultList = new CoviList();

		ArrayList<HashMap<String,String>> left = new ArrayList<HashMap<String,String>>();

		left = getAdminMenu(menuList,"Left", cnID, lang);

		//Left
		if(left.size() > 0){

			for(int i=0; i < left.size(); i++){
				CoviMap newObject = new CoviMap();
				HashMap<String, String> map = (HashMap<String, String>) left.get(i);
	            
				for(Map.Entry<String, String> entry : map.entrySet()) {
					newObject.put(entry.getKey(), entry.getValue());
				}

	            if(Integer.parseInt(newObject.get("childCount").toString()) > 0){
	            	//topsub
	            	ArrayList<HashMap<String,String>> topSub = new ArrayList<HashMap<String,String>>();
	        		topSub = getAdminMenu(menuList,"Left", newObject.get("menuid").toString(), lang);
					newObject.put("cn", drawMenu(topSub));
				}

	            resultList.add(newObject);
			}
		}


		return resultList;
	}

	/*
	public CoviList getLeft(CoviList menuList, String cnID)throws Exception{
		CoviList resultList = new CoviList();

		//전체 메뉴권한 loop
		for (int i = 0 ; i < menuList.size(); i++) {
	        CoviMap obj = menuList.getJSONObject(i);

	        //cnID의 left, left의 left를 구함
	        String memberOf = obj.getString("MemberOf");
	        String containerType = obj.getString("ContainerType");
	        if(cnID.equals(memberOf)&& containerType.equals("Left")){
	        	resultList
	        }



	        String A = obj.getString("A");
	        String B = obj.getString("B");
	        String C = obj.getString("C");

	    }

		return resultList;
	}
	*/

	public CoviList drawMenu(ArrayList<HashMap<String,String>> menu)throws Exception{
		CoviList resultList = new CoviList();

		if(menu.size() > 0){

			for(int i=0; i < menu.size(); i++){
				CoviMap newObject = new CoviMap();
				HashMap<String, String> map = (HashMap<String, String>) menu.get(i);
	            
				for(Map.Entry<String, String> entry : map.entrySet()) {
					newObject.put(entry.getKey(), entry.getValue());
				}

	            resultList.add(newObject);
			}
		}
		return resultList;
	}

	/**
	 * 관리자 메뉴 정보 sorting
	 * @param adminAuthList
	 * @param pContainerType
	 * @param pMemberOf
	 * @param pLang
	 * @return
	 * @throws Exception
	 */
	public ArrayList<HashMap<String,String>> getAdminMenu(ArrayList<HashMap<String,String>> adminAuthList, String pContainerType, String pMemberOf, String pLang)throws Exception{

		ArrayList<HashMap<String,String>> resultList = new ArrayList<HashMap<String,String>>();

		for (int k = 0; k < adminAuthList.size(); k++) {

			HashMap<String, String> am = (HashMap<String, String>)adminAuthList.get(k);

			String cnID,conType,memberOf,isURL;

			cnID = am.get("CN_ID");
			conType = am.get("ContainerType");
			memberOf = am.get("MemberOf");
			isURL = am.get("IsURL");

			if(conType.equalsIgnoreCase(pContainerType)&&memberOf.equalsIgnoreCase(pMemberOf))
			{
				  HashMap<String, String> map = new HashMap<String, String>();
				  String label;
				  label = getLocalizedLabel(pLang, am);

				  map.put("menuid", cnID);
				  map.put("label", label);
				  //isurl의 값에 따라 분기처리
				  if(isURL.equals("Y")){
					  map.put("url", am.get("URL"));
				  }else{
					  map.put("url", am.get("ProgramURL"));
				  }

				  map.put("memberOf", memberOf);
				  map.put("childCount", am.get("ChildCount"));
				  map.put("sortKey", am.get("SortKey"));

				  resultList.add(map);

				  Collections.sort(resultList, new Comparator<HashMap<String, String >>() {
					  @Override
					  public int compare(HashMap<String, String> first,HashMap<String, String> second) {
						  Integer firstKey = Integer.parseInt(first.get("sortKey"));
						  Integer secondKey = Integer.parseInt(second.get("sortKey"));

						  return firstKey.compareTo(secondKey);
					  }
				  });


			}

		  }

		return resultList;

	}

	/*
	public ArrayList<HashMap<String,String>> getAdminMenu(String pContainerType, String pMemberOf, String pLang)throws Exception{

		Cache cacheAdminMenu = cacheManager.getCache("cacheAdminMenu");

		ArrayList<HashMap<String,String>> resultList = new ArrayList<HashMap<String,String>>();

		for (Object key: cacheAdminMenu.getKeys()) {
			String cnID,conType,memberOf;
			String[] arrKey;
			arrKey = key.toString().split("_");

			cnID = arrKey[0];
			conType = arrKey[1];
			memberOf = arrKey[2];

			if(conType.equalsIgnoreCase(pContainerType)&&memberOf.equalsIgnoreCase(pMemberOf))
			{
				Element element = cacheAdminMenu.get(key);
			    if (element != null) {
			      AdminMenuAuth am = new AdminMenuAuth();
			      am = (AdminMenuAuth)element.getObjectValue();

			      HashMap<String, String> map = new HashMap<String, String>();
			      String label;
			      label = getLocalizedLabel(pLang, am);

			      map.put("cnID", cnID);
			      map.put("label", label);
			      map.put("url", am.getURL());
			      map.put("memberOf", memberOf);
			      map.put("childCount", Long.toString(am.getChildCount()));
			      map.put("sortKey", am.getSortKey().toString());

			      resultList.add(map);

			      Collections.sort(resultList, new Comparator<HashMap<String, String >>() {
			    	  @Override
			    	  public int compare(HashMap<String, String> first,HashMap<String, String> second) {
			    		  Integer firstKey = Integer.parseInt(first.get("sortKey"));
			    		  Integer secondKey = Integer.parseInt(second.get("sortKey"));

			    		  return firstKey.compareTo(secondKey);
			    	  }
			      });

			    }
			}

		  }

		return resultList;

	}
	*/

	private String getLocalizedLabel(String lang, HashMap<String, String> am){
		String label;

		switch (lang) {
	      case "ko"  : label = am.get("Ko"); break;
	      case "en" : label = am.get("En"); break;
	      case "ja"  : label = am.get("Ja"); break;
	      case "zh"  : label = am.get("Zh"); break;
	      default   : label = am.get("DisplayName"); break;
		}

		return label;
	}



	/////////////////////////////////사용자 메뉴 부분/////////////////////////////////////////////////////////////////////////////////////////////////
	public CoviList getUserAuthJSON(String grIDs)throws Exception{
		CoviList resultList = new CoviList();

		CoviMap paramUserMenu = new CoviMap();
		paramUserMenu.put("grIDs", grIDs); //그룹아이디 값 하드코딩을 제거 할 것
		//전체 관리자 메뉴를 캐쉬처리 - 위치를 bean으로 이동할 것
		List<?> list = (List<?>) cacheLoadSvc.selectUserMenuCache(paramUserMenu);

		for (int i = 0; i < list.size(); i++) {
			CoviMap eMap = (CoviMap) list.get(i);
			if (eMap.get("MN_ID") != null) {
				CoviMap newObject = new CoviMap();

				newObject.put("MN_ID",Objects.toString(eMap.get("MN_ID"),""));//Integer cnID,
				newObject.put("PG_ID",Objects.toString(eMap.get("PG_ID"), ""));//String containerType,
				newObject.put("DIC_ID",Objects.toString(eMap.get("DIC_ID"),""));//String alias,
				newObject.put("AclListID",Objects.toString(eMap.get("AclListID"),""));//String displayName,
				newObject.put("MenuType",Objects.toString(eMap.get("MenuType"),""));//String linkMN,
				newObject.put("MenuAlias",Objects.toString(eMap.get("MenuAlias"),""));//String linkSystem,
				newObject.put("ServiceDevice",Objects.toString(eMap.get("ServiceDevice"),""));//Integer memberOf,
				newObject.put("MPG_ID",Objects.toString(eMap.get("MPG_ID"),""));//Integer sortKey,
				newObject.put("DisplayName",Objects.toString(eMap.get("DisplayName"),""));//String isURL,
				newObject.put("MemberOf",Objects.toString(eMap.get("MemberOf"),""));//String url,
				newObject.put("MenuPath",Objects.toString(eMap.get("MenuPath"),""));//String isUse,
				newObject.put("LinkMN",Objects.toString(eMap.get("LinkMN"),""));//String description,
				newObject.put("SecurityLevel",Objects.toString(eMap.get("SecurityLevel"),""));//String regID,
				newObject.put("SortKey",Objects.toString(eMap.get("SortKey"),""));//String regDate,
				newObject.put("SortPath",Objects.toString(eMap.get("SortPath"),""));//String modID,
				newObject.put("SiteMapPosition",eMap.getString("SiteMapPosition"));//String modID,
				newObject.put("HasFD",Objects.toString(eMap.get("HasFD"),""));//String modDate,
				newObject.put("IsInherited",Objects.toString(eMap.get("IsInherited"),""));//Integer childCount,
				newObject.put("IsUse",Objects.toString(eMap.get("IsUse"),""));//String programURL,
				newObject.put("IsDisplay",Objects.toString(eMap.get("IsDisplay"),""));//Integer pgID,
				newObject.put("IsURL",Objects.toString(eMap.get("IsURL"),""));//String programName,
				newObject.put("URL",Objects.toString(eMap.get("URL"),""));//String programAlias,
				newObject.put("Target",Objects.toString(eMap.get("Target"),""));//String programType,
				newObject.put("Description",Objects.toString(eMap.get("Description"),""));//String programDescription,
				newObject.put("DataStatus",Objects.toString(eMap.get("DataStatus"),""));//String programBizSection,
				newObject.put("RegID",Objects.toString(eMap.get("RegID"),""));//String programBizSection,
				newObject.put("RegDate",Objects.toString(eMap.get("RegDate"),""));//String programBizSection,
				newObject.put("ModID",Objects.toString(eMap.get("ModID"),""));//String programBizSection,
				newObject.put("ModDate",Objects.toString(eMap.get("ModDate"),""));//String programBizSection,
				newObject.put("ChildCount",Objects.toString(eMap.get("ChildCount"),""));//String programBizSection,
				newObject.put("ProgramURL",Objects.toString(eMap.get("ProgramURL"),""));//String programBizSection,
				newObject.put("ProgramName",Objects.toString(eMap.get("ProgramName"),""));//String programBizSection,
				newObject.put("ProgramAlias",Objects.toString(eMap.get("ProgramAlias"),""));//String programBizSection,
				newObject.put("ProgramType",Objects.toString(eMap.get("ProgramType"),""));//String programBizSection,
				newObject.put("ProgramDescription",Objects.toString(eMap.get("ProgramDescription"),""));//String programBizSection,
				newObject.put("ProgramBizSection",Objects.toString(eMap.get("ProgramBizSection"),""));//String programBizSection,
				newObject.put("Ko",Objects.toString(eMap.get("Ko"),""));//String ko,
				newObject.put("En",Objects.toString(eMap.get("En"),""));//String en,
				newObject.put("Ja",Objects.toString(eMap.get("Ja"),""));//String ja,
				newObject.put("Zh",Objects.toString(eMap.get("Zh"),""));//String zh,
				newObject.put("Reserved1",Objects.toString(eMap.get("Reserved1"),""));//String reserved1,
				newObject.put("Reserved2",Objects.toString(eMap.get("Reserved2"),""));//String reserved2

				resultList.add(newObject);
			}
		}

		return resultList;
	}

	//정렬 문제로 JsonArray -> ArrayList, 다시 arraylis -> JsonArray로 converting하는 불필요한 과정이 있음
	//향후 jsonArray상에서 정렬하는 방식으로 코드를 변경할 것
	public CoviList getRedisCachedUserTopMenu(String usrId, String lang)throws Exception{
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String strJsonAuth = instance.get("UserMenuAuth_" + usrId);

		ArrayList<HashMap<String,String>> menuList = convertJsonStringToUserList(strJsonAuth);

	    //전체 메뉴에서 home의 top값과 top의 topsub값을 쿼리
	    CoviList resultList = new CoviList();
	    resultList = drawUserTopMenu(menuList, lang);

	    return resultList;
	}

	public ArrayList<HashMap<String,String>> convertJsonStringToUserList(String jsonStringAuth){
		ArrayList<HashMap<String,String>> userAuthList = new ArrayList<HashMap<String,String>>();

		CoviList authJsonArray =(CoviList) JSONSerializer.toJSON(jsonStringAuth);
		for(Object js : authJsonArray){
            CoviMap json = (CoviMap)js;

            HashMap<String, String> map = new HashMap<String, String>();

			map.put("MN_ID",Objects.toString(json.get("MN_ID"),""));//Integer cnID,
			map.put("PG_ID",Objects.toString(json.get("PG_ID"), ""));//String containerType,
			map.put("DIC_ID",Objects.toString(json.get("DIC_ID"),""));//String alias,
			map.put("AclListID",Objects.toString(json.get("AclListID"),""));//String displayName,
			map.put("MenuType",Objects.toString(json.get("MenuType"),""));//String linkMN,
			map.put("MenuAlias",Objects.toString(json.get("MenuAlias"),""));//String linkSystem,
			map.put("ServiceDevice",Objects.toString(json.get("ServiceDevice"),""));//Integer memberOf,
			map.put("MPG_ID",Objects.toString(json.get("MPG_ID"),""));//Integer sortKey,
			map.put("DisplayName",Objects.toString(json.get("DisplayName"),""));//String isURL,
			map.put("MemberOf",Objects.toString(json.get("MemberOf"),""));//String url,
			map.put("MenuPath",Objects.toString(json.get("MenuPath"),""));//String isUse,
			map.put("LinkMN",Objects.toString(json.get("LinkMN"),""));//String description,
			map.put("SecurityLevel",Objects.toString(json.get("SecurityLevel"),""));//String regID,
			map.put("SortKey",Objects.toString(json.get("SortKey"),""));//String regDate,
			map.put("SortPath",Objects.toString(json.get("SortPath"),""));//String modID,
			map.put("HasFD",Objects.toString(json.get("HasFD"),""));//String modDate,
			map.put("IsInherited",Objects.toString(json.get("IsInherited"),""));//Integer childCount,
			map.put("IsUse",Objects.toString(json.get("IsUse"),""));//String programURL,
			map.put("IsDisplay",Objects.toString(json.get("IsDisplay"),""));//Integer pgID,
			map.put("IsURL",Objects.toString(json.get("IsURL"),""));//String programName,
			map.put("URL",Objects.toString(json.get("URL"),""));//String programAlias,
			map.put("Target",Objects.toString(json.get("Target"),""));//String programType,
			map.put("Description",Objects.toString(json.get("Description"),""));//String programDescription,
			map.put("DataStatus",Objects.toString(json.get("DataStatus"),""));//String programBizSection,
			map.put("RegID",Objects.toString(json.get("RegID"),""));//String programBizSection,
			map.put("RegDate",Objects.toString(json.get("RegDate"),""));//String programBizSection,
			map.put("ModID",Objects.toString(json.get("ModID"),""));//String programBizSection,
			map.put("ModDate",Objects.toString(json.get("ModDate"),""));//String programBizSection,
			map.put("ChildCount",Objects.toString(json.get("ChildCount"),""));//String programBizSection,
			map.put("ProgramURL",Objects.toString(json.get("ProgramURL"),""));//String programBizSection,
			map.put("ProgramName",Objects.toString(json.get("ProgramName"),""));//String programBizSection,
			map.put("ProgramAlias",Objects.toString(json.get("ProgramAlias"),""));//String programBizSection,
			map.put("ProgramType",Objects.toString(json.get("ProgramType"),""));//String programBizSection,
			map.put("ProgramDescription",Objects.toString(json.get("ProgramDescription"),""));//String programBizSection,
			map.put("ProgramBizSection",Objects.toString(json.get("ProgramBizSection"),""));//String programBizSection,
			map.put("Ko",Objects.toString(json.get("Ko"),""));//String ko,
			map.put("En",Objects.toString(json.get("En"),""));//String en,
			map.put("Ja",Objects.toString(json.get("Ja"),""));//String ja,
			map.put("Zh",Objects.toString(json.get("Zh"),""));//String zh,
			map.put("Reserved1",Objects.toString(json.get("Reserved1"),""));//String reserved1,
			map.put("Reserved2",Objects.toString(json.get("Reserved2"),""));//String reserved2

			userAuthList.add(map);
        }

		return userAuthList;
	}

	public CoviList drawUserTopMenu(ArrayList<HashMap<String,String>> menuList, String lang)throws Exception{
		CoviList resultList = new CoviList();
		/*
		 * 사용자 메뉴 그리기
		 * 1. Top 가져오기
		 * 2. TopSub 가져오기
		 * */

		/*
		 * 사용자마다 2개의 row를 할당 - 상단, 좌측
		 * key는 session id
		 * val는 json string [{"childCount":"2","cnID":"1","label":"관리홈","sortKey":"0","memberOf":"0","url":"","sub":[]}....]
		 * */
		ArrayList<HashMap<String,String>> top = new ArrayList<HashMap<String,String>>();

		top = getUserMenu(menuList,"Top", "0", lang);

		//Top - TopSub, Left
		if(top.size() > 0){

			for(int i=0; i < top.size(); i++){
				CoviMap newObject = new CoviMap();
				HashMap<String, String> map = (HashMap<String, String>) top.get(i);
	            
	            for (Map.Entry<String, String> entry : map.entrySet()) {
	            	newObject.put(entry.getKey(), entry.getValue());
	            }

	            if(Integer.parseInt(newObject.get("childCount").toString()) > 0){
	            	//topsub
	            	ArrayList<HashMap<String,String>> topSub = new ArrayList<HashMap<String,String>>();
	        		topSub = getUserMenu(menuList,"TopSub", newObject.get("menuid").toString(), lang);
					newObject.put("cn", drawMenu(topSub));

					//left
					/*
					ArrayList<HashMap<String,String>> left = new ArrayList<HashMap<String,String>>();
	        		left = getAdminMenu(menuList,"Left", newObject.get("cnID").toString(), lang);
					newObject.put("left", drawMenu(left));
					*/
				}

	            resultList.add(newObject);
			}
		}


		return resultList;
	}

	public ArrayList<HashMap<String,String>> getUserMenu(ArrayList<HashMap<String,String>> userAuthList, String pContainerType, String pMemberOf, String pLang)throws Exception{

		ArrayList<HashMap<String,String>> resultList = new ArrayList<HashMap<String,String>>();

		for (int k = 0; k < userAuthList.size(); k++) {

			HashMap<String, String> am = (HashMap<String, String>)userAuthList.get(k);

			String mnID,menuType,memberOf,isURL,menuAlias,SortPath;

			mnID = am.get("MN_ID");
			menuType = am.get("MenuType");
			memberOf = am.get("MemberOf");
			isURL = am.get("IsURL");
			menuAlias = am.get("MenuAlias");
			SortPath = am.get("SortPath");

			if(menuType.equalsIgnoreCase(pContainerType)&&memberOf.equalsIgnoreCase(pMemberOf))
			{
				  HashMap<String, String> map = new HashMap<String, String>();
				  String label;
				  label = getLocalizedLabel(pLang, am);

				  map.put("menuid", mnID);
				  map.put("label", label);
				  //isurl의 값에 따라 분기처리
				  if(isURL.equals("Y")){
					  map.put("url", am.get("URL"));
				  }else{
					  map.put("url", am.get("ProgramURL"));
				  }

				  map.put("memberOf", memberOf);
				  map.put("childCount", am.get("ChildCount"));
				  map.put("sortKey", am.get("SortKey"));
				  map.put("alias", menuAlias);
				  map.put("SortPath", SortPath);

				  resultList.add(map);

				  Collections.sort(resultList, new Comparator<HashMap<String, String >>() {
					  @Override
					  public int compare(HashMap<String, String> first,HashMap<String, String> second) {
						  Integer firstKey = Integer.parseInt(first.get("sortKey"));
						  Integer secondKey = Integer.parseInt(second.get("sortKey"));

						  return firstKey.compareTo(secondKey);
					  }
				  });


			}

		  }

		return resultList;

	}

	//사용자 좌측 메뉴
	public CoviList getRedisCachedUserLeftMenu(String usrId, String mnID, String lang)throws Exception{
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String strJsonAuth = instance.get("UserMenuAuth_" + usrId);

		ArrayList<HashMap<String,String>> menuList = convertJsonStringToUserList(strJsonAuth);

	    //전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    resultList = drawUserLeftMenu(menuList, mnID, lang);

	    return resultList;
	}

	//사용자 좌측 메뉴 그리기
	public CoviList drawUserLeftMenu(ArrayList<HashMap<String,String>> menuList, String mnID, String lang)throws Exception{
		CoviList resultList = new CoviList();

		ArrayList<HashMap<String,String>> left = new ArrayList<HashMap<String,String>>();

		left = getUserMenu(menuList,"Left", mnID, lang);

		//Left
		if(left.size() > 0){

			for(int i=0; i < left.size(); i++){
				CoviMap newObject = new CoviMap();
				HashMap<String, String> map = (HashMap<String, String>) left.get(i);
	            
	            for (Map.Entry<String, String> entry : map.entrySet()) {
	            	newObject.put(entry.getKey(), entry.getValue());
	            }

	            if(Integer.parseInt(newObject.get("childCount").toString()) > 0){
	            	//topsub
	            	ArrayList<HashMap<String,String>> topSub = new ArrayList<HashMap<String,String>>();
	        		topSub = getUserMenu(menuList,"Left", newObject.get("menuid").toString(), lang);
					newObject.put("cn", drawMenu(topSub));
				}

	            resultList.add(newObject);
			}
		}


		return resultList;
	}

}
