package egovframework.covision.groupware.webpart.web;

import java.util.Map;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.webpart.service.OfficerAdminSvc;


@Controller
public class OfficerAdminCon {

	@Autowired
	private OfficerAdminSvc officerAdminSvc;
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 임원재실현황 - 어드민 페이지 이동
	 * @param request
	 * @param paramMap
	 * @return mav
	 */	
	@RequestMapping(value="webpart/goOfficerAdminPopup.do", method=RequestMethod.GET)
	public @ResponseBody ModelAndView goOfficerAdminPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String returnURL = "user/webpart/manage/OfficerAdmin";		
		String isAdmin = SessionHelper.getSession("isAdmin");
		
		// 권한 확인
		if(!isAdmin.equals("Y")) {
			String sRequestProtocal = request.getRequestURL().toString().split("/")[0];
			String sRequestDomain = request.getRequestURL().toString().split("/")[2];
			returnURL = "redirect:" + sRequestProtocal + "//" + sRequestDomain + "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);		
		
		return mav;
	}
	
	
	/**
	 * 임원재실현황 - 매니저 페이지 이동
	 * @param request
	 * @param paramMap
	 * @return mav
	 */	
	@RequestMapping(value="webpart/goOfficerManagePopup.do", method=RequestMethod.GET)
	public @ResponseBody ModelAndView goOfficerManagePopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String returnURL = "user/webpart/manage/OfficerManage";
		
		String userCode = SessionHelper.getSession("USERID");		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		
		String isManager = "N";
//		CoviMap resultList = new CoviMap();	
//		resultList = officerAdminSvc.getIsAdminUser(params);		
		isManager = officerAdminSvc.getIsAdminUser(params).getJSONArray("list").getJSONObject(0).getString("IsManager");
		
		if(!isManager.equals("Y")) {
			String sRequestProtocal = request.getRequestURL().toString().split("/")[0];
			String sRequestDomain = request.getRequestURL().toString().split("/")[2];
			returnURL = "redirect:" + sRequestProtocal + "//" + sRequestDomain + "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);		
		
		return mav;
	}
	
	/**
	 * 임원재실현황 - 임원 추가 페이지 이동
	 * @param request
	 * @param paramMap
	 * @return mav
	 */	
	@RequestMapping(value="webpart/goAddOfficerPopup.do", method=RequestMethod.GET)
	public @ResponseBody ModelAndView goAddOfficerPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String returnURL = "user/webpart/manage/AddOfficer";
				
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);		
		
		return mav;
	}
	
	/**
	 * 임원재실현황 - 매니저 여부 가져오기
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getIsAdminUser.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getIsAdminUser(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		//CoviMap returnObj = new CoviMap();
		
		String userCode = SessionHelper.getSession("USERID");
		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		
		CoviMap resultList = new CoviMap();		
		resultList = officerAdminSvc.getIsAdminUser(params);
		
		//returnObj.put("list", resultList.get("list"));
		
		return resultList;
	}
	
	
	/**
	 * 임원재실현황 - 임원 리스트 가져오기
	 * @param request	
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getOfficerList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOfficerList(HttpServletRequest request) throws Exception {			
		
		CoviMap returnObj = new CoviMap();
		String lang = SessionHelper.getSession("lang");
		
		CoviMap params = new CoviMap();
		params.put("lang", lang);		
		
		CoviMap resultList = new CoviMap();
		resultList = officerAdminSvc.getOfficerList(params);
		
		returnObj.put("list", resultList.get("list"));
		
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 관리자 리스트 가져오기
	 * @param request	
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getOfficerListAdmin.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOfficerListAdmin(HttpServletRequest request,
												@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
												@RequestParam(value = "pageSize", required = false , defaultValue = "1000000" ) int pageSize) throws Exception {			
		
		CoviMap returnObj = new CoviMap();
		String lang = SessionHelper.getSession("lang");
		
		CoviMap params = new CoviMap();
		params.put("lang", lang);
		params.put("pageNo", pageNo);
		params.put("pageSize", pageSize);		
		
		CoviMap resultList = new CoviMap();
		resultList = officerAdminSvc.getOfficerListAdmin(params);
		returnObj.put("page", resultList.get("page"));
		returnObj.put("list", resultList.get("list"));
		
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 담당자 리스트 가져오기
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getOfficerTargetList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOfficerTargetList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String userCode = SessionHelper.getSession("USERID");
		String lang = SessionHelper.getSession("lang");
		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("lang", lang);
		
		CoviMap resultList = new CoviMap();
		
		resultList = officerAdminSvc.getOfficerTargetList(params);
		
		returnObj.put("list", resultList.get("list"));
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 상태값 변경
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/updateOfficerState.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateOfficerState(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();	
		try {
			CoviMap params = new CoviMap();
			
			String ModifierCode = SessionHelper.getSession("USERID");
			
			params.put("UserCode", (String)request.getParameter("UserCode"));
			params.put("State", (String)request.getParameter("State"));
			params.put("ModifierCode", ModifierCode);
			
			if ( (params.get("UserCode") != null) && !params.get("UserCode").equals("") ) {
				returnObj.put("result", officerAdminSvc.updateOfficerState(params));
			}
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 리스트 사용유무 변경
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/updateOfficerUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateOfficerUse(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();	
		try {
			CoviMap params = new CoviMap();
			
			String ModifierCode = SessionHelper.getSession("USERID");
			
			params.put("UserCode", (String)request.getParameter("UserCode"));
			params.put("IsUse", (String)request.getParameter("IsUse"));
			params.put("ModifierCode", ModifierCode);
			
			if ( (params.get("UserCode") != null) && !params.get("UserCode").equals("") ) {
				returnObj.put("result", officerAdminSvc.updateOfficerUse(params));
			}
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 리스트 사용유무 변경
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/deleteOfficer.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteOfficer(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();	
		try {
			CoviMap params = new CoviMap();
			String[] TargetID = null;
			String   TargetIDTemp = null;
			
			TargetIDTemp = StringUtil.replaceNull(request.getParameter("TargetIDs"), "");
			TargetID = TargetIDTemp.split(",");
			
			params.put("TargetIDs", TargetID);
			
			if ( (params.get("TargetIDs") != null) && !params.get("TargetIDs").equals("") ) {
				returnObj.put("result", officerAdminSvc.deleteOfficer(params));
			}
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	/**
	 * moveSortKey_GroupUser : 임원 리스트 우선순위 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "webpart/moveofficersort.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap moveofficersort(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {		
		
		String pStrCode_A		= null;
		String pStrCode_B		= null;		
		CoviMap params = null;
		CoviMap returnData = new CoviMap();
		try {
			params = new CoviMap();
			
			pStrCode_A = request.getParameter("UserCode_A");		
			pStrCode_B = request.getParameter("UserCode_B");

			params.put("Code_A",pStrCode_A);
			params.put("Code_B",pStrCode_B);
			
			returnData = officerAdminSvc.moveofficersort(params);
			
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	
	/**
	 * 임원재실현황 - 임원 추가 중복 체크여부
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getIsDuplicate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIsDuplicate(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String officerCode = request.getParameter("OfficerCode");
		
		CoviMap params = new CoviMap();
		params.put("OfficerCode", officerCode);
		
		CoviMap resultList = new CoviMap();		
		resultList = officerAdminSvc.getIsDuplicate(params);
		
		returnObj.put("list", resultList.get("list"));
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 추가
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/addOfficer.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addOfficer(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {	
			String officerCode = request.getParameter("officerCode");
			String secretarysCode = request.getParameter("secretarysCode");
			String sort = request.getParameter("sort");
			String isUse = request.getParameter("isUse");
			String registerCode = SessionHelper.getSession("USERID");;
			
			CoviMap params = new CoviMap();
			params.put("OfficerCode", officerCode);
			params.put("SecretarysCode", secretarysCode);
			params.put("Sort", sort);
			params.put("IsUse", isUse);
			params.put("RegisterCode", registerCode);
			
			if ( (params.get("OfficerCode") != null) && !params.get("OfficerCode").equals("") ) {
				returnObj.put("result", officerAdminSvc.addOfficer(params));
			}
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 수정	
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/UpdateOfficer.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateOfficerInfo(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {	
			String officerCode = request.getParameter("officerCode");
			String secretarysCode = request.getParameter("secretarysCode");
			String sort = request.getParameter("sort");
			String isUse = request.getParameter("isUse");
			String registerCode = SessionHelper.getSession("USERID");;
			
			CoviMap params = new CoviMap();
			params.put("OfficerCode", officerCode);
			params.put("SecretarysCode", secretarysCode);
			params.put("Sort", sort);
			params.put("IsUse", isUse);
			params.put("RegisterCode", registerCode);
			
			if ( (params.get("OfficerCode") != null) && !params.get("OfficerCode").equals("") ) {
				returnObj.put("result", officerAdminSvc.updateOfficerInfo(params));
			}
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			//LoggerHelper.errorLogger(e, Thread.currentThread().getStackTrace()[1].getClassName() + "." + Thread.currentThread().getStackTrace()[1].getMethodName(), "CON");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * 임원재실현황 - 임원 수정 > 정보 가져오기
	 * @param request
	 * @param paramMap
	 * @return CoviMap
	 */
	@RequestMapping(value="webpart/getOfficerInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOfficerInfo(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		String lang = SessionHelper.getSession("lang");
		
		CoviMap params = new CoviMap();
		params.put("UserCode", request.getParameter("usercode"));
		params.put("lang", lang);
		
		CoviMap resultList = new CoviMap();
		
		resultList = officerAdminSvc.getOfficerInfo(params);
		
		returnObj.put("list", resultList.get("list"));
		
		return returnObj;
	}
	 
}



