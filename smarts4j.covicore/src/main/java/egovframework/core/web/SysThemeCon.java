package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SysThemeSvc;
import egovframework.coviframework.util.ComUtils;

@Controller
public class SysThemeCon {

	@Autowired
	private SysThemeSvc sysThemeSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * addThemeLayerPopup : 테마 관리 추가 및 수정 버튼 레이어팝업
	 * @return mav
	 */
	@RequestMapping(value = "theme/goThemePopup.do", method = RequestMethod.GET)
	public ModelAndView addThemeLayerPopup() {
		return (new ModelAndView("core/system/addthemelayerpopup"));
	}
	
	/**
	 * getThemeList : 테마 그리드 데이터 바인드
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getThemeList(
			HttpServletRequest request,
			@RequestParam(value = "domainID", required = false, defaultValue = "") String domainID,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try { 
			String sort = request.getParameter("sortBy");
			
			String sortKey =  (! StringUtil.replaceNull(sort).equals("") )? StringUtil.replaceNull(sort).split(" ")[0] : "";
			String sortDirec =  (! StringUtil.replaceNull(sort).equals("") )? StringUtil.replaceNull(sort).split(" ")[1] : "";
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domainID", domainID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			if(domainID.isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			resultList = sysThemeSvc.select(params);
			
			returnList.put("page", resultList.get("page"));
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
	
//	/**
//	 * selectDomainCode : 하나의 도메인 데이터 바인드
//	 * @return returnList
//	 * @throws Exception
//	 */
//	@RequestMapping(value = "theme/getCode.do", method=RequestMethod.POST)
//	public @ResponseBody CoviMap selectDomainCode() throws Exception
//	{
//		CoviMap resultList = new CoviMap();
//		CoviMap returnList = new CoviMap();
//		
//		try {
//			CoviList domainList = ComUtils.getAssignedDomainID();
//			CoviMap params = new CoviMap();
//			
//			params.put("assignedDomain", domainList);
//			
//			resultList = sysThemeSvc.selectCode(params);
//			
//			returnList.put("list", resultList.get("list"));
//			returnList.put("result", "ok");
//
//			returnList.put("status", Return.SUCCESS);
//			returnList.put("message", "조회되었습니다");
//		} catch (Exception e) {
//			returnList.put("status", Return.FAIL);
//			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
//		}
//		return returnList;
//	}
	
	/**
	 * selectOneDomain : 하나의 테마 데이터 바인드
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectOneDomain(
			@RequestParam(value = "themeID", required = true) int themeID) throws Exception
	{

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("themeID", themeID);
			
			resultList = sysThemeSvc.selectOne(params);
			
			returnList.put("list", resultList.get("map"));
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
	 * addTheme - 테마 데이터 추가
	 * @param themeCode
	 * @param domainID
	 * @param themeType
	 * @param themeName
	 * @param multiDisplayName
	 * @param isUse
	 * @param description
	 * @return
	 * @throws Exception
	 */
	
	@RequestMapping(value = "theme/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addTheme(
			@RequestParam(value = "themeCode", required = true) String themeCode,
			@RequestParam(value = "domainID", required = true) String domainID,
			@RequestParam(value = "themeName", required = true) String themeName,
			@RequestParam(value = "description", required = false) String description) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			// TODO 날짜의  timezone 적용 할 것
			CoviMap params = new CoviMap();
			
			params.put("themeCode", themeCode);
			params.put("domainID", domainID);
			params.put("themeName", themeName);
			params.put("description", description);
			params.put("regID", SessionHelper.getSession("USERID"));
			
			returnList.put("result", sysThemeSvc.insert(params));
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
	 * updateTheme - 테마 데이터 수정
	 * @param themeID
	 * @param themeCode
	 * @param domainID
	 * @param themeType
	 * @param themeName
	 * @param multiDisplayName
	 * @param isUse
	 * @param description
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateTheme(
			@RequestParam(value = "domainID", required = true) String domainID,
			@RequestParam(value = "themeID", required = true) String themeID,
			@RequestParam(value = "themeCode", required = true) String themeCode,
			@RequestParam(value = "themeName", required = true) String themeName,
			@RequestParam(value = "description", required = false) String description) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			// TODO 날짜의 경우 timezone 적용 할 것
			CoviMap params = new CoviMap();
			
			params.put("themeID", themeID);
			params.put("domainID", domainID);
			params.put("themeName", themeName);
			params.put("themeCode", themeCode);
			params.put("description", description);
			
			returnList.put("result", sysThemeSvc.update(params));
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
	 * delete : 테마 삭제
	 * @param themeIDs
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/delete.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteTheme(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String themeIDs[]  = StringUtil.replaceNull(request.getParameter("themeIDs")).split(";"); //삭제할 포탈 ID
			
			for(int i = 0; i < themeIDs.length; i++){
				CoviMap params = new CoviMap();
				params.put("themeID",themeIDs[i]);
				sysThemeSvc.delete(params);
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
	 * updateIsUse - 테마 사용 여부 수정
	 * @param themeID
	 * @param themeCode
	 * @param isUse
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUse(
			@RequestParam(value = "themeID", required = true) String themeID,
			@RequestParam(value = "themeCode", required = true) String themeCode,
			@RequestParam(value = "themeCode", required = true) String themeName,
			@RequestParam(value = "domainID", required = true) String domainID) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			// TODO 날짜의 경우 timezone 적용 할 것
			params.put("themeID", themeID);
			params.put("themeCode", themeCode);
			params.put("themeName", themeName);
			params.put("domainID", domainID);
			
			returnList.put("result", sysThemeSvc.updateIsUse(params));
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
	 * changeSortKey - 테마 관리 위 아래 버튼에 대한 데이터 수정
	 * @param sortKey1
	 * @param sortKey2
	 * @param domainCode1
	 * @param domainCode2
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "theme/changeSortkey.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap changeSortKey(
			@RequestParam(value = "sortKey1", required = true) String sortKey1,
			@RequestParam(value = "sortKey2", required = true) String sortKey2,
			@RequestParam(value = "themeCode1", required = true) String themeCode1,
			@RequestParam(value = "themeCode2", required = true) String themeCode2) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("sortKey1", sortKey1);
			params.put("sortKey2", sortKey2);
			params.put("themeCode1", themeCode1);
			params.put("themeCode2", themeCode2);
			
			sysThemeSvc.changeSortKey(params);
			
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
