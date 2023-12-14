package egovframework.covision.groupware.portal.admin.web;

import javax.servlet.http.HttpServletRequest;




import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.portal.admin.service.PortalManageSvc;

/**
 * @Class Name : PortalManageCon.java
 * @Description : 포탈 관리 페이지를 위한 클라이언트 요청 처리
 * @Modification Information 
 * @ 017.05.22 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.05.22
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class PortalManageCon {
	
	private Logger LOGGER = LogManager.getLogger(PortalManageCon.class);
	
	@Autowired
	private PortalManageSvc portalManageSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getPortalList - 포탈 관리 - 포탈 목록 조회
	 * @param companyCode
	 * @param portalType
	 * @param searchType
	 * @param searchWord
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getPortalList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPortalList(
			HttpServletRequest request,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "portalType", required = false) String portalType,
			@RequestParam(value = "searchType", required = false) String searchType,
			@RequestParam(value = "searchWord", required = false) String searchWord,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
		
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("companyCode", companyCode);
			params.put("portalType", portalType);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = portalManageSvc.getPortalList(params);
			
			returnData.put("page",resultList.get("page")) ;
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getLayoutList - 포탈 관리 설정 팝업에서 사용하는레이아웃, 업무구분 selectBox 바인딩 데이터 조회 
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getSelectBoxData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLayoutList() throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			returnData.put("layoutList",portalManageSvc.getLayoutList().get("list"));
			returnData.put("themeList",portalManageSvc.getThemeList().get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	
	/**
	 * goPortalManageSetPopup : 포탈 관리 - 포탈 관리 설정 팝업 표시 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "portal/goPortalManageSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goPortalManageSetPopup() {
		return (new ModelAndView("admin/portal/PortalManageSetPopup"));
	}
	
	
	/**
	 *  setPortalData - 포탈 정보 저장
	 * @param copyPortalID
	 * @param mode
	 * @param portalName
	 * @param dicPortalName
	 * @param companyCode
	 * @param layoutID
	 * @param portalType
	 * @param bizSection
	 * @param sortKey
	 * @param url
	 * @param description
	 * @param permission
	 * @param permissionDel
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/insertPortalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertPortalData(
			@RequestParam(value = "portalID", required = false) String copyPortalID,
			@RequestParam(value = "mode", required = false) String mode,
			@RequestParam(value = "portalName", required = false) String portalName,
			@RequestParam(value = "dicPortalName", required = false) String dicPortalName,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "layoutID", required = false) String layoutID,
			@RequestParam(value = "portalType", required = false) String portalType,
			@RequestParam(value = "bizSection", required = false) String bizSection,
			@RequestParam(value = "themeCode", required = false) String themeCode,
			@RequestParam(value = "sortKey", required = false) String sortKey,
			@RequestParam(value = "portalCode", required = false) String portalCode,
			@RequestParam(value = "url", required = false) String url,
			@RequestParam(value = "description", required = false) String description,
			@RequestParam(value = "permission", required = false , defaultValue = "{}") String permission,
			@RequestParam(value = "permissionDel", required = false  , defaultValue = "{}") String permissionDel,
			@RequestParam(value = "actionData", required = false  , defaultValue = "") String actionData			
			) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap permissionObj =  CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permission)); //권한 정보
			CoviMap permissionDelObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permissionDel)); //삭제될 권한 정보
			CoviList aclActionDataObj = new CoviList();
			
			if(!actionData.equals("[]")){
				aclActionDataObj = CoviList.fromObject(StringEscapeUtils.unescapeHtml(actionData));		
			}
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("mode", mode); //'copy' or ''
			params.put("copyPortalID", copyPortalID);  //복사 시 복사할 포탈 ID
			params.put("portalName", portalName);
			params.put("dicPortalName", dicPortalName);
			params.put("companyCode", companyCode);
			params.put("layoutID", layoutID);
			params.put("portalType", portalType);
			params.put("bizSection", bizSection);
			params.put("themeCode", themeCode);
			params.put("sortKey", sortKey);
			params.put("portalCode", portalCode);
			params.put("url", url);
			params.put("description", description);
			params.put("permission", permissionObj);
			params.put("permissionDel", permissionDelObj);
			
			portalManageSvc.insertPortalData(params);
			
			if(aclActionDataObj.size() > 0)
				authSvc.syncActionACL(aclActionDataObj, "PT");
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	
	/**
	 * getPortalData - 포탈 수정화면 - 특정 포탈 정보(기본정보, 권한정보) 조회
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */

	@RequestMapping(value = "portal/getPortalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPortalData(
			@RequestParam(value = "portalID", required = false) String portalID) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("objectID", portalID);
			params.put("objectType", "PT");
			
			resultList = portalManageSvc.getPortalData(params);
			
			returnData.put("data", resultList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	
	/**
	 *  getPortalData - 포탈 수정화면 - 특정 포탈 정보(기본정보, 권한정보) 조회
	 * @param portalID
	 * @param portalName
	 * @param dicPortalName
	 * @param companyCode
	 * @param layoutID
	 * @param portalType
	 * @param bizSection
	 * @param sortKey
	 * @param url
	 * @param description
	 * @param permission
	 * @param permissionDel
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/updatePortalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updatePortalData(
			@RequestParam(value = "portalID", required = false) String portalID,
			@RequestParam(value = "portalName", required = false) String portalName,
			@RequestParam(value = "dicPortalName", required = false) String dicPortalName,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "layoutID", required = false) String layoutID,
			@RequestParam(value = "portalType", required = false) String portalType,
			@RequestParam(value = "bizSection", required = false) String bizSection,
			@RequestParam(value = "themeCode", required = false) String themeCode,
			@RequestParam(value = "sortKey", required = false) String sortKey,
			@RequestParam(value = "portalCode", required = false) String portalCode,
			@RequestParam(value = "url", required = false) String url,
			@RequestParam(value = "description", required = false) String description,
			@RequestParam(value = "permission", required = false , defaultValue = "{}") String permission,
			@RequestParam(value = "permissionDel", required = false  , defaultValue = "{}") String permissionDel,
			@RequestParam(value = "actionData", required = false  , defaultValue = "") String actionData
			) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap permissionObj =  CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permission)); //권한 정보
			CoviMap permissionDelObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permissionDel)); //삭제될 권한 정보
		
			CoviList aclActionDataObj = new CoviList();
			
			if(!actionData.equals("[]")){
				aclActionDataObj = CoviList.fromObject(StringEscapeUtils.unescapeHtml(actionData));		
			}
			
			
			CoviMap params = new CoviMap();
			params.put("portalID", portalID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("portalName", portalName);
			params.put("dicPortalName", dicPortalName);
			params.put("companyCode", companyCode);
			params.put("layoutID", layoutID);
			params.put("portalType", portalType);
			params.put("bizSection", bizSection);
			params.put("themeCode", themeCode);
			params.put("sortKey", sortKey);
			params.put("portalCode", portalCode);
			params.put("url", url);
			params.put("description", description);
			params.putOrigin("permission", permissionObj);
			params.putOrigin("permissionDel", permissionDelObj);
			
			portalManageSvc.updatePortalData(params);
			
			if(aclActionDataObj.size() > 0)
				authSvc.syncActionACL(aclActionDataObj, "PT");
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * setPortalData - 포탈 삭제
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/deletePortalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deletePortalData(
			@RequestParam(value = "portalID", required = true, defaultValue="") String portalID) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] arrPortalID  = portalID.split(";"); //삭제할 포탈 ID
		 
			if(arrPortalID.length > 0 ){
				CoviMap delParam = new CoviMap();
				delParam.put("arrPortalID",arrPortalID);
				portalManageSvc.deletePortalData(delParam);
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * chnagePortalIsUse - 포탈 사용여부 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/chnagePortalIsUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap chnagePortalIsUse(
			@RequestParam(value = "portalID", required = true) String portalID) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("portalID",portalID);
			portalManageSvc.chnagePortalIsUse(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	
}
