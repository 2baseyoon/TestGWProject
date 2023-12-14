package egovframework.covision.coviflow.admin.web;


import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.UnitDirectorSvc;



@Controller
public class UnitDirectorCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(UnitDirectorCon.class);
	
	@Autowired
	private UnitDirectorSvc unitDirectorSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getUnitDirectorList : 결재함권한부여 - 특정 사용자 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getUnitDirectorList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUnitDirectorList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String entCode = request.getParameter("EntCode");
			String unitCode = request.getParameter("UnitCode");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);			
			params.put("UnitCode", unitCode);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = unitDirectorSvc.getUnitDirectorList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getUnitDirectorData : 결재함권한부여 - 특정 부서의 타 부서 열람권한 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getUnitDirectorData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUnitDirectorData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String unitCode = request.getParameter("UnitCode");
			String entCode = request.getParameter("EntCode");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("UnitCode", unitCode);		
			params.put("EntCode", entCode);	
				
			resultList = unitDirectorSvc.getUnitDirectorData(params);				
	
			returnList.put("list", resultList.get("list"));
			returnList.put("cnt", resultList.get("cnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	
	/**
	 * goUnitDirectorSetPopup : 결재함 권한 부여 - 특정 사용자 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goUnitDirectorSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goUnitDirectorSetPopup(Locale locale, Model model) {		
		String returnURL = "admin/approval/UnitDirectorSetPopup";		
		return new ModelAndView(returnURL);
	}	
	
	/**
	 * insertUnitDirector : 결재함 권한 부여 - 특정 사용자 레이어팝업 저장
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/insertUnitDirector.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertUnitDirector(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			String unitCode = request.getParameter("UnitCode");
			String entCode = request.getParameter("EntCode");
			String description = request.getParameter("Description");
			String sortKey = request.getParameter("SortKey");
			String unitName = request.getParameter("UnitName");
			String authStartDate = request.getParameter("AuthStartDate");
			String authEndDate = request.getParameter("AuthEndDate");
			String jsonString = request.getParameter("jwf_unitdirectormember");

			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
			
			CoviList jarr = CoviList.fromObject(escapedJson);
						
			//날짜의 경우 timezone 적용 할 것
			CoviMap params = new CoviMap();			
			params.put("UnitCode", unitCode);
			params.put("EntCode", entCode);
			params.put("Description", ComUtils.RemoveScriptAndStyle(description));
			params.put("SortKey", sortKey);
			params.put("UnitName", unitName);
			params.put("AuthStartDate", ComUtils.RemoveScriptAndStyle(authStartDate));
			params.put("AuthEndDate", ComUtils.RemoveScriptAndStyle(authEndDate));
			
			unitDirectorSvc.deletejwf_unitdirector(params);
			unitDirectorSvc.deletejwf_unitdirectormember(params);
			
			for(int i=0; i<jarr.size(); i++){			
				CoviMap order = jarr.getJSONObject(i);
				
				CoviMap params2 = new CoviMap();
				params2.put("UnitCode",order.getString("UnitCode"));
				params2.put("TargetUnitCode",order.getString("TargetUnitCode"));
				params2.put("TargetUnitName",order.getString("TargetUnitName"));
				params2.put("ViewStartDate",order.getString("ViewStartDate"));
				params2.put("ViewEndDate",order.getString("ViewEndDate"));			
				
				unitDirectorSvc.insertjwf_unitdirectormember(params2);				
			}
			
			returnList.put("object", unitDirectorSvc.insertjwf_unitdirector(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * deleteUnitDirector : 결재함권한부여 - 특정 사용자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteUnitDirector.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteUnitDirector(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {			
			String unitCode = request.getParameter("UnitCode");
			String entCode = request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();
			params.put("UnitCode",unitCode);
			params.put("EntCode",entCode);
		
			int result = unitDirectorSvc.deletejwf_unitdirector(params);
			result += unitDirectorSvc.deletejwf_unitdirectormember(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "admin/addunitdirectorlayerpopup.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView addschemalayerpopup(Locale locale, Model model) {
		String returnURL = "admin/approval/addschemalayerpopup";
		return new ModelAndView(returnURL);
	}
}
