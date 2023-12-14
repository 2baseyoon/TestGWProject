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
import egovframework.covision.coviflow.admin.service.AdminFormClassSvc;



@Controller
public class AdminFormClassCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(AdminFormClassCon.class);
	
	@Autowired
	private AdminFormClassSvc adminFormClassSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	/**
	 * getFormClassList : 양식분류 관리 - 양식 분류 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getFormClassList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormClassList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultList = null;
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
		
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DomainID",paramMap.get("DomainID"));
			params.put("isSaaS",isSaaS);
			
			resultList = adminFormClassSvc.getFormClassList(params);
			
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();
			
			CoviList arrList = (CoviList)resultList.get("list");
			for(Object obj : arrList) {
				CoviMap list = (CoviMap)obj;
				if(assignedDomainList.size() == 0 || assignedDomainList.contains("ORGROOT") || assignedDomainList.contains(list.optString("EntCode"))) {
					list.put("ModifyAcl", "Y");
				} else {
					list.put("ModifyAcl", "N");
				}
			}
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
	 * goFormClassPopup : 양식분류 관리 - 분류관리 팝업창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goFormClassPopup.do", method = RequestMethod.GET)
	public ModelAndView goFormClassPopup(Locale locale, Model model) {		
		String returnURL = "admin/approval/FormClassPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getFormClassData : 양식분류 관리 - 특정 양식분류 레이어팝업 수정화면에 대한 데이터 바인드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getFormClassData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormClassData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			CoviMap resultList = null;
			String formClassID = request.getParameter("FormClassID");
			
			CoviMap params = new CoviMap();	
			params.put("FormClassID", formClassID);		
			
			resultList = adminFormClassSvc.getFormClassData(params);						
	
			returnList.put("list", resultList.get("map"));
			returnList.put("item", resultList.get("item"));
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
	 * insertFormClassData : 양식분류 관리 - 양식 분류 데이터 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/insertFormClassData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertFormClassData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String formClassName  = request.getParameter("FormClassName");
			String sortKey = request.getParameter("SortKey");
			String entCode= request.getParameter("EntCode");
			String authDept = StringEscapeUtils.unescapeHtml(request.getParameter("AuthDept"));
			String aclAllYN = request.getParameter("AclAllYN");
			
			CoviMap params = new CoviMap();
			
			params.put("FormClassName"  , formClassName);
			params.put("SortKey", (StringUtil.isEmpty(sortKey) ? "0": sortKey)); // 오라클 대비 수정
			params.put("EntCode", entCode);
			params.put("AuthDept", authDept);
			params.put("AclAllYN", aclAllYN);
			
			returnList.put("object", adminFormClassSvc.insertFormClassData(params));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_136"));//"저장되었습니다."
			
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
	 * updateFormClassData : 양식분류 관리 - 양식 분류 데이터 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/updateFormClassData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateFormClassData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String formClassID  = request.getParameter("FormClassID");
			String formClassName  = request.getParameter("FormClassName");
			String sortKey= request.getParameter("SortKey");
			String entCode= request.getParameter("EntCode");
			String authDept = StringEscapeUtils.unescapeHtml(request.getParameter("AuthDept"));
			String aclAllYN = StringUtil.replaceNull(request.getParameter("AclAllYN"));
			
			CoviMap params = new CoviMap();			
			params.put("FormClassID"  , formClassID);
			params.put("FormClassName"  , ComUtils.RemoveScriptAndStyle(formClassName));
			params.put("SortKey", sortKey);
			params.put("EntCode", entCode);
			params.put("AclAllYN", aclAllYN);
			
			returnList.put("object", adminFormClassSvc.updateFormClassData(params));
			
			CoviMap map = new CoviMap();
			if(aclAllYN.equals("N")) {
				
				CoviMap obj = CoviMap.fromObject(authDept);
				CoviList result = (CoviList) obj.get("item");
				
				CoviList resultList = new CoviList();
				for(int i=0; i<result.size(); i++){
					CoviMap tmp = new CoviMap();
					CoviMap aclObj = CoviMap.fromObject(result.getJSONObject(i));
					
					tmp.put("ObjectType", "CLASS");
					tmp.put("TargetID", formClassID);
					tmp.put("CompanyCode", aclObj.getString("CompanyCode"));
					tmp.put("GroupCode", aclObj.getString("GroupCode"));
					tmp.put("GroupType", aclObj.getString("GroupType"));
					tmp.put("RegisterCode", SessionHelper.getSession("USERID"));
					
					resultList.add(tmp);
				}
				
				map.put("FormClassID", formClassID);
				map.put("list", resultList);
				map.put("size", result.size()-1);
				adminFormClassSvc.updateAclListClassData(map);
			}else {
				map.put("ObjectType", "CLASS");
				map.put("FormClassID", formClassID);
				adminFormClassSvc.deleteAclListClassData(map);
			}
			
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_137")); //성공적으로 갱신되었습니다.
			
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
	 * deleteFormClassData : 양식분류 관리 - 양식 분류 데이터 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/deleteFormClassData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteFormClassData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String formClassID   = request.getParameter("FormClassID");
			
			CoviMap params = new CoviMap();			
			params.put("FormClassID",formClassID);
			params.put("ObjectType", "CLASS");
					
			int selectEachFormClassCnt = adminFormClassSvc.selectEachFormClassData(params);
			
			if(selectEachFormClassCnt==0){			
				returnList.put("object", adminFormClassSvc.deleteFormClassData(params));
				returnList.put("result", "ok");
				returnList.put("cnt", selectEachFormClassCnt);
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_apv_138"));
			}else{			
				returnList.put("result", "ok");
				returnList.put("cnt", selectEachFormClassCnt);
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_DontDelAsInvolveForm"));//"포함된 양식이 있으므로 삭제할 수 없습니다."
			}			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
}
