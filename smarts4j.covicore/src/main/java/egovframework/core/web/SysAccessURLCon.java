package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.core.sevice.SysAccessURLSvc;
import egovframework.coviframework.util.AccessURLUtil;
import egovframework.coviframework.util.ComUtils;



@Controller
public class SysAccessURLCon {

	@Autowired
	private SysAccessURLSvc sysAccessURLSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 익명 접근 URL 목록 조회
	 * @param request
	 * @param searchType
	 * @param searchWord
	 * @param startdate
	 * @param enddate
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "searchType", required = false, defaultValue = "") String searchType,
			@RequestParam(value = "searchWord", required = false, defaultValue = "") String searchWord,
			@RequestParam(value = "startdate", required = false, defaultValue = "") String startdate,
			@RequestParam(value = "enddate", required = false, defaultValue = "") String enddate,
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "10") String pageSize) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			CoviMap resultList = sysAccessURLSvc.getList(params);

			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
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
	
	/**
	 * 익명 접근 URL 설정 팝업
	 * @param request
	 * @return ModelAndView
	 */
	@RequestMapping(value = "accessurl/goAccessURLPopup.do", method = RequestMethod.GET)
	public ModelAndView goAccessURLPopup(HttpServletRequest request) {
		return (new ModelAndView("core/system/AccessURLManagePopup"));
	}
	
	/**
	 * 특정 익명 접근 URL 정보 조회 
	 * @param accessURLID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/getInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInfo(
			@RequestParam(value = "accessURLID", required = true) String accessURLID	) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("accessURLID", accessURLID);
			
			returnList.put("info", sysAccessURLSvc.getInfo(params));
			
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
	
	/**
	 * 익명 접근 URL 추가
	 * @param url
	 * @param isUse
	 * @param description
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap add(
			@RequestParam(value = "url", required = true) String url
			, @RequestParam(value = "isUse", required = false, defaultValue = "N") String isUse
			, @RequestParam(value = "isAdmin", required = false, defaultValue = "Y") String isAdmin
			, @RequestParam(value = "description", required = false, defaultValue = "") String description ) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("url", url);
			params.put("isUse", isUse);
			params.put("isAdmin", isAdmin);
			params.put("description", description);
			params.put("registerCode", SessionHelper.getSession("USERID"));
	
			if(sysAccessURLSvc.add(params)){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
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
	 * 익명 접근 URL 수정
	 * @param accessURLID
	 * @param url
	 * @param isUse
	 * @param description
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modify(
			@RequestParam(value = "accessURLID", required = true) String accessURLID
			, @RequestParam(value = "url", required = true) String url
			, @RequestParam(value = "isUse", required = false, defaultValue = "N") String isUse
			, @RequestParam(value = "isAdmin", required = false, defaultValue = "Y") String isAdmin
			, @RequestParam(value = "description", required = false, defaultValue = "") String description ) throws Exception	{
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("accessURLID", accessURLID);
			params.put("url", url);
			params.put("isUse", isUse);
			params.put("isAdmin", isAdmin);
			params.put("description", description);
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			
			if(sysAccessURLSvc.modify(params)){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
			
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
	 * 익명 접근 URL 사용여부 수정
	 * @param accessURLID
	 * @param isUseValue
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/modifyIsUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyIsUse(
			@RequestParam(value = "accessURLID", required = true) String accessURLID,
			@RequestParam(value = "isUse", required = true) String isUse ) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("accessURLID", accessURLID);
			params.put("isUse", isUse);
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			
			if(sysAccessURLSvc.modifyIsUse(params)){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
			
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
	 * 익명 접근 URL 관리자여부 수정
	 * @param accessURLID
	 * @param isUseValue
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/modifyIsAdmin.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyIsAdmin(
			@RequestParam(value = "accessURLID", required = true) String accessURLID,
			@RequestParam(value = "isAdmin", required = true) String isAdmin ) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("accessURLID", accessURLID);
			params.put("isAdmin", isAdmin);
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			
			if(sysAccessURLSvc.modifyIsAdmin(params)){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
			
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
	 * 익명 접근 URL 삭제
	 * @param deleteAccessURLIDs
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/delete.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap delete(
			@RequestParam(value = "deleteAccessURLIDs", required = false, defaultValue = "") String deleteAccessURLIDs) throws Exception	{
		
		CoviMap returnList = new CoviMap();

		try {
			String[] arrAccessURLID = deleteAccessURLIDs.split("[|]");
			
			CoviMap params = new CoviMap();
			
			params.put("arrAccessURLID", arrAccessURLID);
			
			boolean bdeleteUrl = sysAccessURLSvc.delete(params);
			
			if(bdeleteUrl){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
			
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
	 * 익명 접근 URL 재캐시
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accessurl/resetCache.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap resetCache() throws Exception	{
		
		CoviMap returnList = new CoviMap();

		try {
			AccessURLUtil.resetAccessURLList();
			
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
