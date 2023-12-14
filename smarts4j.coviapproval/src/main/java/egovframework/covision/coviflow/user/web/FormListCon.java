package egovframework.covision.coviflow.user.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.user.service.FormListSvc;

/**
 * @Class Name : FormListCon.java
 * @Description : 사용자 > 전자결재 > 결재문서작성
 * @ 2016.11.18 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class FormListCon {
	
	private AuthHelper authHelper;

	private static final Logger LOGGER = LogManager.getLogger(FormListCon.class);
	
	@Autowired
	private FormListSvc formListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	/** 
	 * getClassificationListData : 결재문서작성 : 양식 폼 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */

	@RequestMapping(value = "user/getClassificationListData.do")
	public @ResponseBody CoviMap getClassificationListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			// viewAll: 전자결재 양식 조회 구분 T : 전체 F : 회사별 - 기존에 Config 값으로 빠져있던 값 기본 F로 사용 
			// T로 사용하고 싶을 경우 전체 양식의 EntCode를 WF로 지정.
			//String viewAll = request.getParameter("viewAll"); 
			//String entCode =  request.getParameter("entCode");
			
			CoviMap params = new CoviMap();

			//params.put("viewAll", viewAll);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("deptCode", SessionHelper.getSession("GR_Code"));
			params.put("isSaaS", isSaaS);			
			
			CoviMap resultList = formListSvc.getClassificationListData(params);
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/** 
	 * getFormListData : 결재문서작성 : 양식조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/getFormListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			//String viewAll = request.getParameter("viewAll");
			String formClassID =  request.getParameter("FormClassID");
			String formName =  request.getParameter("FormName");
			
			CoviMap params = new CoviMap();

			//params.put("viewAll", viewAll);
			params.put("FormClassID", formClassID);
			params.put("FormName", ComUtils.RemoveSQLInjection(formName, 100));
			params.put("entCode",  SessionHelper.getSession("DN_Code"));
			params.put("deptCode",  SessionHelper.getSession("GR_Code"));
			params.put("userCode",  SessionHelper.getSession("USERID"));
			params.put("isSaaS", isSaaS);
			
			CoviMap resultList = formListSvc.getFormListData(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/** 
	 * getLastestUsedFormListData : 결재문서작성 : 최근사용양식조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/getLastestUsedFormListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLastestUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try
		{
			String userCode = request.getParameter("userCode");
			
			CoviMap params = new CoviMap();

			params.put("userCode", userCode);
			params.put("entCode",  SessionHelper.getSession("DN_Code"));
			params.put("deptCode",  SessionHelper.getSession("GR_Code"));
			params.put("isSaaS", isSaaS);
			
			resultList = formListSvc.getLastestUsedFormListData(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/** 
	 * getFavoriteUsedFormListData : 결재문서작성 : 즐겨찾기조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/getFavoriteUsedFormListData.do")
	public @ResponseBody CoviMap getFavoriteUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			CoviMap params = new CoviMap();
			
			params.put("userCode",  SessionHelper.getSession("USERID"));
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("deptCode", SessionHelper.getSession("GR_Code"));
			params.put("isSaaS", isSaaS);
			
			CoviMap resultList = formListSvc.getFavoriteUsedFormListData(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/** 
	 * getFormListData : 결재홈 : 즐겨찾는 양식조회(별도조회)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getHomeFavorageFormListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getHomeFavorageFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("userCode",  SessionHelper.getSession("USERID"));
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("deptCode", SessionHelper.getSession("GR_Code"));
			params.put("isSaaS", isSaaS);
			
			CoviMap resultList = formListSvc.getHomeFavoriteFormListData(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	
	
	/** 
	 * addFavoriteUsedFormListData : 결재문서작성 : 즐겨찾기추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/addFavoriteUsedFormListData.do")
	public @ResponseBody CoviMap addFavoriteUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String formID = request.getParameter("formID");
			
			CoviMap params = new CoviMap();
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("formID", formID);
			
			int cnt = formListSvc.addFavoriteUsedFormListData(params);
			returnList.put("cnt",cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/** 
	 * removeFavoriteUsedFormListData : 결재문서작성 : 즐겨찾기삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/removetFavoriteUsedFormListData.do")
	public @ResponseBody CoviMap removeFavoriteUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try
		{
			String formID = request.getParameter("formID");
			
			CoviMap params = new CoviMap();
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("formID", formID);
			
			int cnt = formListSvc.removeFavoriteUsedFormListData(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/** 
	 * getCompleteAndRejectListData : 결재문서작성 : 최근기안(반려,완료함)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "user/getCompleteAndRejectListData.do")
	public @ResponseBody CoviMap getCompleteAndRejectListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try
		{
			String userCode = request.getParameter("userCode");
			
			CoviMap params = new CoviMap();
			
			params.put("userCode", userCode);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("deptCode", SessionHelper.getSession("GR_Code"));
			params.put("isSaaS", isSaaS);
			
			CoviMap resultList = formListSvc.getCompleteAndRejectListData(params);
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * getNotDocReadCnt : HOME화면 - 읽지 않은 form갯수
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "user/getNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap setMonitorChangeState(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		CoviMap returnList = new CoviMap();		
		try {
			String formInstIDTemp = StringEscapeUtils.unescapeHtml((request.getParameter("FormInstID")));
			String[] formInstID	= formInstIDTemp.split(",");			
			
			CoviMap params = new CoviMap();		
			params.put("FormInstID", formInstID);		
			
			returnList.put("cnt", formListSvc.getNotDocReadCnt(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	@RequestMapping(value = "user/updateFavoriteUsedFormSort.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap updateFavoriteUsedFormSort(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
	
		try{
			CoviMap params = new CoviMap(paramMap);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			int cnt = formListSvc.updateFavoriteUsedFormSort(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다");
		} catch(NullPointerException npE){
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
