package egovframework.core.web;

import java.net.URLDecoder;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.MenuSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : MenuCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2017.06.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MenuCon {

	private Logger LOGGER = LogManager.getLogger(MenuCon.class);
	
	@Autowired
	private AuthorityService authSvc;
	
	@Autowired
	private MenuSvc menuSvc;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "menu/getmenu.do")
	public @ResponseBody CoviMap getMenu(
			HttpServletRequest request,
			@RequestParam(value = "DomainID", required = true, defaultValue = "1") String domainId,
			@RequestParam(value = "IsAdmin", required = true, defaultValue = "N") String isAdmin,
			@RequestParam(value = "BizSection", required = false, defaultValue = "") String bizSection,
			@RequestParam(value = "MenuType", required = true, defaultValue = "") String menuType,
			@RequestParam(value = "MemberOf", required = false, defaultValue = "0") String memberOf) throws Exception {
		
		CoviMap returnList = new CoviMap();
		JSONSerializer jUtil = new JSONSerializer();
		
		try {
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			// 1. redis menu로 부터 menu 정보를 쿼리
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String menuStr = instance.get("MENU_" + userDataObj.getString("DN_ID") + "_" +userDataObj.getString("USERID"));
			
			CoviList queriedMenu = null;
			if(StringUtils.isNoneBlank(menuStr)){
				CoviList menuArray = jUtil.jsonGetObject(menuStr);
				
				// 2. menuArray로 부터 menuType, BizSection별로 쿼리
				if(bizSection.equals("")){
					queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, menuType, memberOf, menuArray);	
				} else{
					queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, bizSection, menuType, memberOf, menuArray, userDataObj.getString("lang"));
				}
				
				LOGGER.debug(queriedMenu.toString());
			}
			
			returnList.put("data", queriedMenu);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/reload.do")
	public @ResponseBody CoviMap reloadMenu(
			HttpServletRequest request,
			@RequestParam(value = "Key", required = true, defaultValue = "") String key) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			// 1. redis menu로 부터 menu 정보를 쿼리
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			instance.remove(key + SessionHelper.getSession("USERID"));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/getacl.do")
	public @ResponseBody CoviMap getACL(
			HttpServletRequest request,
			@RequestParam(value = "ObjectType", required = true, defaultValue = "") String objectType,
			@RequestParam(value = "ObjectID", required = true, defaultValue = "") String objectId) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("objectType", objectType);
			params.put("objectID", objectId);
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			
			CoviList aclArray = new CoviList();
			
			if(!StringUtil.isEmpty(objectId)) {
				aclArray = authSvc.selectACL(params);
			} else {
				aclArray = authSvc.selectCompanyACL(params);
			}
			
			returnList.put("data", aclArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminMenuTreeData(HttpServletRequest request,
			@RequestParam(value = "domain", required = true, defaultValue = "0") String domainID,
			@RequestParam(value = "isAdmin", required = true, defaultValue = "N") String isAdmin) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("isAdmin", isAdmin);

			
			//관리메뉴 트리
			resultList = menuSvc.select(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "menu/getTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTreeList(HttpServletRequest request,
		@RequestParam(value = "domain", required = true, defaultValue = "0") String domainID,
		@RequestParam(value = "isAdmin", required = true, defaultValue = "N") String isAdmin) throws Exception {
			
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
	
		try {
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("isAdmin", isAdmin);
			
			resultList = menuSvc.selectTree(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/goMoveMenuPopup.do", method = RequestMethod.GET)
	public ModelAndView goMovePopup(Locale locale, Model model) {
		return new ModelAndView("core/menu/MoveMenuPopup");
	}
	
	@RequestMapping(value = "menu/goExportMenuPopup.do", method = RequestMethod.GET)
	public ModelAndView goExportMenuPopup(@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView("core/menu/ExportMenuPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	@RequestMapping(value = "menu/moveMenu.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap moveMenu(@RequestParam(value = "menuId", required = true) String menuId,
		@RequestParam(value = "sortPath", required = true) String sortPath,
		@RequestParam(value = "tarMenuId", required = true) String tarMenuId,
		@RequestParam(value = "tarSortPath", required = true) String tarSortPath,
		@RequestParam(value = "tarDomainId", required = true) String tarDomainId,
		@RequestParam(value = "tarIsAdmin", required = true) String tarIsAdmin, 
		@RequestParam(value = "sourceDomain", required = true) String sourceDomain) throws Exception {
				
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("menuId", menuId);
			params.put("sortPath", sortPath.replaceAll("%3B", ";"));
			params.put("tarMenuId", tarMenuId);
			params.put("tarSortPath", tarSortPath);
			params.put("tarDomainId", tarDomainId);
			params.put("tarIsAdmin", tarIsAdmin);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			String tarChildCnt =String.valueOf((Long)menuSvc.selectChildCount(params));
			params.put("tarChildCnt", tarChildCnt);
			
			// 1. validation
			CoviMap jo = menuSvc.selectMoveTargetForValidation(params).getJSONArray("map").getJSONObject(0);
			String[] menuIds = jo.getString("menuIds").split(",");
			String parentMenuId = jo.getString("parentMenuId");
			
			if (menuId.equals(tarMenuId)) {	// 이동할 대상 선택
				throw new Exception("동일 대상 입니다.");
			}
			
			if (Arrays.asList(menuIds).contains(tarMenuId)) {	// 이동할 대상의 자식 선택
				throw new Exception("대상에 포함된 위치 입니다.");
			}
			
			if (parentMenuId.equals(tarMenuId)) {	// 이동할 대상과 같은 위치 선택
				throw new Exception("동일 위치 입니다.");
			}
			
			// 2. 이동
			params.put("tarSortUpYn", jo.getString("tarSortUpYn"));	// 이동대상과 선택한 대상이 같은 depth의 항목이며 이동대상보다 선택한 대상의sort가 뒤인지 여부(sort -1을 하기  위함)
			int result = menuSvc.moveMenu(params);
			if(result > 0) {
				// source
				authSvc.syncDomainACL(sourceDomain, "MN");
				menuSvc.removeRedisMenuCache(sourceDomain);
				
				// target
				authSvc.syncDomainACL(tarDomainId, "MN");
				menuSvc.removeRedisMenuCache(tarDomainId);
			}
			
			returnList.put("data", result);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/exportMenu.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap exportMenu(@RequestParam(value = "menuId", required = true) String menuId,
		@RequestParam(value = "domainIds", required = true) String domainIds,
		@RequestParam(value = "sortPath", required = true) String sortPath) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("menuId", menuId);
			params.put("domainIds", domainIds);
			params.put("sortPath", sortPath);
			
			int result = menuSvc.exportMenu(params);
			
			if (result > 0) {
				String[] domainIdList = domainIds.split(";");
				
				for (String domainId : domainIdList) {
					authSvc.syncDomainACL(domainId, "MN");
					menuSvc.removeRedisMenuCache(domainId);
				}
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_170")); // 완료되었습니다.
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "menu/goMenuPopup.do", method = RequestMethod.GET)
	public ModelAndView goMenuPopup(@RequestParam Map<String, String> paramMap, Locale locale, Model model) {
		String returnURL = "core/menu/AddMenuPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * addMenu : 관리자 메뉴 관리 데이터 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addMenu(HttpServletRequest request, 
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID,
			@RequestParam(value = "isAdmin", required = true, defaultValue = "N") String pIsAdmin,
			@RequestParam(value = "parentObjectID", required = true, defaultValue = "") String pParentObjectID,
			@RequestParam(value = "parentObjectType", required = true, defaultValue = "") String pParentObjectType,
			@RequestParam(value = "displayName", required = true, defaultValue = "") String pDisplayName,
			@RequestParam(value = "multiDisplayName", required = true, defaultValue = "") String pMultiDisplayName,
			@RequestParam(value = "iconClass", required = false, defaultValue = "") String pIconClass,
			@RequestParam(value = "menuType", required = true, defaultValue = "") String pMenuType,
			@RequestParam(value = "bizSection", required = true, defaultValue = "") String bizSection,
			@RequestParam(value = "target", required = true, defaultValue = "Current") String pTarget,
			@RequestParam(value = "mobileTarget", required = true, defaultValue = "Current") String pMobileTarget,
			@RequestParam(value = "sortKey", required = true, defaultValue = "") String pSortKey,
			@RequestParam(value = "sortPath", required = true, defaultValue = "") String pSortPath,
			@RequestParam(value = "isUse", required = true, defaultValue = "Y") String pIsUse,
			@RequestParam(value = "isCopy", required = true, defaultValue = "Y") String pIsCopy,
			@RequestParam(value = "securityLevel", required = true, defaultValue = "90") String pSecurityLevel,
			@RequestParam(value = "url", required = true, defaultValue = "") String pURL,
			@RequestParam(value = "mobileUrl", required = true, defaultValue = "") String pMobileURL,
			@RequestParam(value = "serviceDevice", required = true, defaultValue = "") String pServiceDevice,
			@RequestParam(value = "description", required = true, defaultValue = "") String pDescription,
			@RequestParam(value = "memberOf", required = true, defaultValue = "") String pMemberOf,
			@RequestParam(value = "reserved1", required = true, defaultValue = "") String pReserved1,
			@RequestParam(value = "reserved2", required = true, defaultValue = "") String pReserved2,			
			@RequestParam(value = "reserved5", required = true, defaultValue = "") String pReserved5,
			@RequestParam(value = "siteMapPosition", required = true, defaultValue = "") String pSiteMapPosition,
			@RequestParam(value = "aclInfo", required = true, defaultValue = "") String pAclInfo,
			@RequestParam(value = "aclActionInfo", required = true, defaultValue = "") String pAclActionInfo,
			@RequestParam(value = "isInherited", required = true, defaultValue = "") String pIsInherited) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap paramMenu = new CoviMap();
			//menu insert
			paramMenu.put("domainID", pDomainID);
			paramMenu.put("isAdmin", pIsAdmin);
			paramMenu.put("menuType", pMenuType);
			paramMenu.put("bizSection", bizSection);
			paramMenu.put("parentObjectID", pParentObjectID);
			paramMenu.put("parentObjectType", pParentObjectType);
			paramMenu.put("serviceDevice", pServiceDevice);
			paramMenu.put("displayName", pDisplayName.replace("'","").replace("&apos;", "").replace("\"","").replace("&quot;", ""));
			paramMenu.put("multiDisplayName", pMultiDisplayName.replace("'","").replace("&apos;", "").replace("\"","").replace("&quot;", ""));
			paramMenu.put("iconClass", pIconClass);
			paramMenu.put("memberOf", pMemberOf);
			paramMenu.put("securityLevel", pSecurityLevel);
			paramMenu.put("sortKey", pSortKey);
			paramMenu.put("sortPath", pSortPath);
			paramMenu.put("isUse", pIsUse);
			paramMenu.put("isCopy", pIsCopy);
			paramMenu.put("isDisplay", "Y");
			paramMenu.put("url", pURL);
			paramMenu.put("mobileURL", pMobileURL);
			paramMenu.put("target", pTarget);
			paramMenu.put("mobileTarget", pMobileTarget);
			paramMenu.put("description", pDescription);
			paramMenu.put("registerCode", SessionHelper.getSession("USERID"));
			paramMenu.put("reserved1", pReserved1);
			paramMenu.put("reserved2", pReserved2);
			paramMenu.put("reserved5", pReserved5);
			paramMenu.put("siteMapPosition", pSiteMapPosition);
			paramMenu.put("reserved3", null);
			paramMenu.put("reserved4", null);
			paramMenu.put("isInherited", pIsInherited);
			
			CoviList aclArray = new CoviList();
			CoviList aclActionArray = new CoviList();
			
			// Root Level 일때는 직접 입력한 권한 데이터를 넣어준다. 
			if(StringUtils.equals("DN", pParentObjectType)) {
				aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pAclInfo, "utf-8"));
				aclActionArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pAclActionInfo, "utf-8"));
			} else {
				CoviMap aclParams = new CoviMap();						
				aclParams.put("objectType", "MN");				//Menu 권한 상속
				aclParams.put("objectID", pMemberOf);			//현재 Menu 가 참조하는 Menu ID
				aclParams.put("inheritedObjectID", pMemberOf);	//상속 받는 ObjectID					
				aclArray = authSvc.selectACL(aclParams);		//Menu ACL 정보 조회
				
				// 상위 권한 상속
				paramMenu.put("isInherited", "Y");
			}
			
			resultList = menuSvc.insert(paramMenu, aclArray);
			
			//Redis Menu Cache 삭제
			if((StringUtils.equals("DN", pParentObjectType) && aclActionArray.size() > 0) || StringUtils.equals("MN", pParentObjectType)) {
				authSvc.syncDomainACL(pDomainID, "MN");
			}
			
			menuSvc.removeRedisMenuCache(pDomainID);
			reloadRedisAuthMenuCache();
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "menu/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOne(HttpServletRequest request,
			@RequestParam(value = "menuID", required = true, defaultValue = "") String pMenuID) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("menuID", pMenuID);
			
			resultList = menuSvc.selectOne(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * deleteMenu : 관리자 메뉴 데이터 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteMenu(HttpServletRequest request,
			@RequestParam(value = "removeMenuIDs", required = true, defaultValue = "") String pRemoveMenuIDs,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("menuIDs", pRemoveMenuIDs);
			menuSvc.delete(params);
			
			//Redis Menu Cache 삭제
			menuSvc.removeRedisMenuCache(pDomainID);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * addAdminMenu : 관리자 메뉴 관리 데이터 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/move.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap move(HttpServletRequest request,
			@RequestParam(value = "rows", required = true, defaultValue = "") String pRows,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList rowArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pRows, "utf-8"));
			for(int i=0; i < rowArray.size(); i++){
				CoviMap row = rowArray.getJSONObject(i);
				CoviMap paramMenu = new CoviMap();
				//menu insert
				paramMenu.put("sortKey", row.get("sortkey").toString());
				paramMenu.put("memberOf", row.get("memberof").toString());
				paramMenu.put("sortPath", row.get("sortpath").toString());
				paramMenu.put("modID", SessionHelper.getSession("USERID"));
				paramMenu.put("menuID", row.get("menuid").toString());
				menuSvc.move(paramMenu);	
			}
			
			//Redis Menu Cache 삭제
			menuSvc.removeRedisMenuCache(pDomainID);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "menu/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyMenu(HttpServletRequest request, 
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID,
			@RequestParam(value = "menuID", required = true, defaultValue = "") String pMenuID,
			@RequestParam(value = "displayName", required = true, defaultValue = "") String pDisplayName,
			@RequestParam(value = "multiDisplayName", required = true, defaultValue = "") String pMultiDisplayName,
			@RequestParam(value = "iconClass", required = false, defaultValue = "") String pIconClass,
			@RequestParam(value = "menuType", required = true, defaultValue = "") String pMenuType,
			@RequestParam(value = "bizSection", required = true, defaultValue = "") String bizSection,
			@RequestParam(value = "target", required = true, defaultValue = "") String pTarget,
			@RequestParam(value = "mobileTarget", required = true, defaultValue = "") String pMobileTarget,
			@RequestParam(value = "isUse", required = true, defaultValue = "Y") String pIsUse,
			@RequestParam(value = "isCopy", required = true, defaultValue = "Y") String pIsCopy,
			@RequestParam(value = "securityLevel", required = true, defaultValue = "90") String pSecurityLevel,
			@RequestParam(value = "url", required = true, defaultValue = "") String pURL,
			@RequestParam(value = "mobileUrl", required = true, defaultValue = "") String pMobileURL,
			@RequestParam(value = "serviceDevice", required = true, defaultValue = "") String pServiceDevice,
			@RequestParam(value = "description", required = true, defaultValue = "") String pDescription,
			@RequestParam(value = "reserved1", required = true, defaultValue = "") String pReserved1,
			@RequestParam(value = "reserved2", required = true, defaultValue = "") String pReserved2,
			@RequestParam(value = "reserved5", required = true, defaultValue = "") String pReserved5,
			@RequestParam(value = "siteMapPosition", required = true, defaultValue = "") String pSiteMapPosition,
			@RequestParam(value = "aclInfo", required = true, defaultValue = "") String pAclInfo,
			@RequestParam(value = "aclActionInfo", required = true, defaultValue = "") String pAclActionInfo,
			@RequestParam(value = "memberOf", required = true, defaultValue = "") String pMemberOf,
			@RequestParam(value = "isInherited", required = true, defaultValue = "") String pIsInherited) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap paramMenu = new CoviMap();
			paramMenu.put("menuType", pMenuType);
			paramMenu.put("bizSection", bizSection);
			paramMenu.put("serviceDevice", pServiceDevice);
			paramMenu.put("displayName", pDisplayName.replace("'","").replace("&apos;", "").replace("\"","").replace("&quot;", ""));
			paramMenu.put("multiDisplayName", pMultiDisplayName.replace("'","").replace("&apos;", "").replace("\"","").replace("&quot;", ""));
			paramMenu.put("iconClass", pIconClass);
			paramMenu.put("securityLevel", pSecurityLevel);
			paramMenu.put("isUse", pIsUse);
			paramMenu.put("isCopy", pIsCopy);
			paramMenu.put("url", pURL);
			paramMenu.put("mobileURL", pMobileURL);
			paramMenu.put("target", pTarget);
			paramMenu.put("mobileTarget", pMobileTarget);
			paramMenu.put("description", pDescription);
			paramMenu.put("modID", SessionHelper.getSession("USERID"));
			paramMenu.put("menuID", pMenuID);
			paramMenu.put("reserved1", pReserved1);
			paramMenu.put("reserved2", pReserved2);
			paramMenu.put("reserved5", pReserved5);
			paramMenu.put("siteMapPosition", pSiteMapPosition);
			paramMenu.put("memberOf", pMemberOf);
			paramMenu.put("isInherited", pIsInherited);
			
			CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pAclInfo, "utf-8"));
			CoviList aclActionArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pAclActionInfo, "utf-8"));
			resultList = menuSvc.update(paramMenu, aclArray);

			if(aclActionArray.size() > 0) authSvc.syncDomainACL(pDomainID, "MN");
			
			// Redis Menu Cache 삭제
			menuSvc.removeRedisMenuCache(pDomainID);
			reloadRedisAuthMenuCache();
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/***************************************************************************************************************************/
	/****************************   수  정  ****************************************************************************************/
	/***************************************************************************************************************************/
	
	/**
	 * selectOneBaseConfig : 기초설정 관리에서 하나의 데이터 셀렉트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/getadminmenudata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminMenuData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		int cnID = Integer.parseInt(request.getParameter("cnID"));

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("cnID", cnID);
			//params.put("bizSection", "Admin");
			params.put("isUse", "Y");
			resultList = menuSvc.selectOne(params);
			
			returnList.put("list", resultList.get("map"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * getAdminMenuAuth : 관리자메뉴에서 권한 select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/getadminmenuauth.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminMenuAuth(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		int cnID = Integer.parseInt(request.getParameter("cnID"));

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("cnID", cnID);
			//params.put("bizSection", "Admin");
			//params.put("isUse", "Y");
			resultList = menuSvc.selectAuth(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "menu/addadminmenu.do", method = RequestMethod.GET)
	public ModelAndView addUserMenu(Locale locale, Model model) {
		String returnURL = "admin/menumanage/addadminmenu";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	@RequestMapping(value = "menu/moveadminmenulayerpopup.do", method = RequestMethod.GET)
	public ModelAndView moveMenuLayerPopup(Locale locale, Model model) {
		String returnURL = "admin/menumanage/moveadminmenulayerpopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	@RequestMapping(value = "menu/getadminmovemenutreedata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMoveMenuTreeData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String listData = "["+
			"{no:0, nodeName:'Root', type:'n', pno:100000, url:'#', chk:'N', rdo:'N'},"+
			"{no:1, nodeName:'관리홈', type:'n', pno:0, url:'#', chk:'N', rdo:'Y'},"+
			"{no:2, nodeName:'시스템 관리', type:'n', pno:0, url:'#', chk:'N', rdo:'Y'},"+
			"{no:21, nodeName:'작업 스케줄러 관리', type:'n', pno:2, url:'#', chk:'N', rdo:'Y'},"+
			"{no:211, nodeName:'메세징 발송 관리', type:'n', pno:21, url:'#', chk:'N', rdo:'Y'}"+
		"]";
		
		CoviMap returnList = new CoviMap();
		returnList.put("list", listData);
		
		return returnList;
	}
	
	/**
	 * updateIsUseAdminMenu : 관리자 메뉴 관리에서 사용여부 값 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "menu/updateisuseadminmenu.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseAdminMenu(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int cnID = Integer.parseInt(request.getParameter("CN_ID"));
			String isUse = request.getParameter("IsUse");
			
			CoviMap params = new CoviMap();
			//날짜의 경우 timezone 적용 할 것
			params.put("cnID", cnID);
			params.put("isUse", isUse);
			params.put("modID", "admin"); //하드코딩을 제거하고, 세션아이디 값을 넣을 것
			
			returnList.put("object", menuSvc.updateIsUse(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "menu/getadminbasedata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String filter = request.getParameter("filter");
		CoviMap returnList = new CoviMap();

		try {
			String listData = "";
			
			/*
			 * filter는 .NET 방식을 가져 올 것
			 * return 형태는 json
			 * 현재 클라이언트는 AXSelect
			 * */
			switch (filter) {
		    	case "selectMenuType"  :
		    		//Top, TopSub, Left, Hidden
		    		listData = "[ { optionValue: '', optionText:'메뉴유형'},{optionValue: 'Top', optionText: '상단'},{optionValue: 'TopSub', optionText: '상단좌측'},	{optionValue: 'Left', optionText: '좌측'},{optionValue: 'Hidden', optionText: '숨김'}]";
		    		break;
		    	case "selectWorkType"  :
		    		listData = "[ { optionValue: '', optionText:'업무영역'},{optionValue: 'Base', optionText: '기초'},	{optionValue: 'Common', optionText: '공통'},{optionValue: 'Admin', optionText: '관리'}]";
			    	break;
		    }
			
			returnList.put("list", listData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	public  void reloadRedisAuthMenuCache()  throws Exception
	{
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		//권한 메뉴 전체 목록 
		instance.removeAll(RedisDataUtil.PRE_AUTH_MENU+"*");
		List<?> authMenu = cacheLoadSvc.selectAuthMenu();
		instance.saveList(authMenu,RedisDataUtil.PRE_AUTH_MENU,  "_", "UrlKey", "MenuID");
		LOGGER.info("Redis 권한 메뉴를  삭제 후 재 캐쉬하였습니다.");
	}
	
	//메뉴 권한 redis 재설정
	@RequestMapping(value = "menu/reloadCache.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyMenu(HttpServletRequest request, 
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			authSvc.syncDomainACL(pDomainID, "MN");
			//Redis Menu Cache 삭제
			menuSvc.removeRedisMenuCache(pDomainID);
			reloadRedisAuthMenuCache();
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
}
