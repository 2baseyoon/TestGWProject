package egovframework.covision.coviflow.admin.web;


import java.util.ArrayList;
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
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.admin.service.PersonDirectorSvc;

@Controller
public class PersonDirectorCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(PersonDirectorCon.class);
	
	@Autowired
	private PersonDirectorSvc personDirectorSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getPersonDirectorList : 결재함권한부여 - 특정 사용자 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception 
	 */
	@RequestMapping(value = "admin/getPersonDirectorList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String entCode = request.getParameter("EntCode");
			String userCode = request.getParameter("UserCode");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("UserCode", userCode);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap resultList = personDirectorSvc.getPersonDirectorList(params);
	
			returnList.put("page",resultList.get("page"));
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
	 * getPersonDirectorData : 결재함권한부여 - 특정 사용자 레이어팝업 수정화면에 대한 데이터 바인드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getPersonDirectorData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();		
			params.put("UserCode", userCode);		
			params.put("EntCode", entCode);	
			
			CoviMap resultList = personDirectorSvc.getPersonDirectorData(params);
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
	 * goPersonDirectorSetPopup : 결재함 권한 부여 - 특정 사용자 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goPersonDirectorSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goPersonDirectorSetPopup(Locale locale, Model model) {		
		String returnURL = "admin/approval/PersonDirectorSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * insertPersonDirector : 결재함 권한 부여 - 특정 사용자 레이어팝업 저장
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/insertPersonDirector.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertPersonDirector(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {
			String userCode  = request.getParameter("UserCode");
			String entCode     = request.getParameter("EntCode");
			String userName = request.getParameter("UserName");
			String description  = request.getParameter("Description");
			String sortKey     = request.getParameter("SortKey");
			String authStartDate   = request.getParameter("AuthStartDate");
			String authEndDate     = request.getParameter("AuthEndDate");			
			
			String jsonString = request.getParameter("persondirectormember");

			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
			
			CoviList jarr = CoviList.fromObject(escapedJson);
			
			CoviMap chkDupParams = new CoviMap();
			ArrayList<String> targetCodeArr = new ArrayList<>();
			
			for (int i = 0; i < jarr.size(); i++) {
				targetCodeArr.add(jarr.getJSONObject(i).getString("TargetCode"));
			}
			
			chkDupParams.put("UserCode", userCode);
			chkDupParams.put("EntCode", entCode);
			chkDupParams.put("TargetCodes", targetCodeArr);

			// 권한자에 대하여 피권한 부서 조회 권한 중복 체크
			if (!targetCodeArr.isEmpty() && personDirectorSvc.chkDuplicateTarget(chkDupParams) > 0) {
				returnList.put("result", "fail");
				returnList.put("message", DicHelper.getDic("msg_apv_DupDirectorTarget"));
			} else {
				//날짜의 경우 timezone 적용 할 것
				CoviMap params = new CoviMap();
				params.put("UserCode", userCode);
				params.put("EntCode", entCode);
				params.put("UserName", userName);
				params.put("Description", ComUtils.RemoveSQLInjection(description, 100) );
				params.put("SortKey", sortKey);
				params.put("AuthStartDate", authStartDate);
				params.put("AuthEndDate", authEndDate);
				
				personDirectorSvc.deletejwf_persondirector(params);			
				personDirectorSvc.deletejwf_persondirectormember(params);
				
				for(int i=0; i<jarr.size(); i++){			
					CoviMap order = jarr.getJSONObject(i);		
					CoviMap params2 = new CoviMap();		
					params2.put("UserCode",order.getString("UserCode"));
					params2.put("EntCode", entCode);
					params2.put("TargetCode",order.getString("TargetCode"));
					params2.put("TargetName",order.getString("TargetName"));				
					params2.put("ViewStartDate", order.getString("ViewStartDate"));
					params2.put("ViewEndDate"  , order.getString("ViewEndDate")  );
					
					personDirectorSvc.insertjwf_persondirectormember(params2);				
				}
				
				returnList.put("object", personDirectorSvc.insertjwf_persondirector(params));
				returnList.put("result", "ok");
				returnList.put("message", "저장되었습니다.");
			}

			returnList.put("status", Return.SUCCESS);
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
	 * deletePersonDirector : 결재함권한부여 - 특정 사용자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deletePersonDirector.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deletePersonDirector(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {			
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");			
			
			CoviMap params = new CoviMap();
			params.put("UserCode",userCode);
			params.put("EntCode",entCode);
		
			int result = personDirectorSvc.deletejwf_persondirectormember(params);
			result += personDirectorSvc.deletejwf_persondirector(params);
			
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
}
