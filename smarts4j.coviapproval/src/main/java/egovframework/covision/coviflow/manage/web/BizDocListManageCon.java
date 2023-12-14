package egovframework.covision.coviflow.manage.web;


import java.util.Locale;
import java.util.Map;
import java.util.Objects;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.BizDocListSvc;



@Controller
public class BizDocListManageCon {
	private Logger LOGGER = LogManager.getLogger(BizDocListManageCon.class);
	
	@Autowired
	private BizDocListSvc bizDocListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getBizDocList : 업무문서함관리 - 업무 문서함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getBizDocList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String state = request.getParameter("sel_State");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String dateType = request.getParameter("sel_Date");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String bizDocType = request.getParameter("bizDocType");
			String entCode = request.getParameter("entCode");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sel_State", state);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sel_Date", dateType);
			params.put("BizDocType", bizDocType);
			params.put("EntCode", entCode);
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = bizDocListSvc.selectBizDocList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * insertBizDoc : 업무문서함관리 - 업무 문서함 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertBizDoc.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertBizDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocCode	= request.getParameter("BizDocCode");
			String bizDocName	= request.getParameter("BizDocName");
			String bizDocType	= request.getParameter("BizDocType");
			String description	= request.getParameter("Description");
			String linktable	= request.getParameter("Linktable");
			String sortKey		= request.getParameter("SortKey");			
			String isUse		= request.getParameter("IsUse");		
			String entCode		= request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();
			params.put("BizDocCode"  , ComUtils.RemoveScriptAndStyle(bizDocCode));
			params.put("BizDocName"  , ComUtils.RemoveScriptAndStyle(bizDocName));
			params.put("BizDocType"  , ComUtils.RemoveScriptAndStyle(bizDocType));
			params.put("Description" , ComUtils.RemoveScriptAndStyle(description));
			params.put("Linktable"	 , linktable);
			params.put("SortKey"	 , sortKey);			
			params.put("IsUse"  	 , isUse);
			params.put("EntCode"	 , entCode);
			
			returnList.put("object", bizDocListSvc.insertBizDoc(params));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateBizDoc : 업무문서함관리 - 업무 문서함 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateBizDoc.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateBizDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocID		= request.getParameter("BizDocID");
			String bizDocCode	= request.getParameter("BizDocCode");
			String bizDocName	= request.getParameter("BizDocName");
			String bizDocType	= request.getParameter("BizDocType");
			String description	= request.getParameter("Description");
			String linktable	= request.getParameter("Linktable");
			String sortKey		= request.getParameter("SortKey");			
			String isUse		= request.getParameter("IsUse");		
			String entCode		= request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();			
			params.put("BizDocID"  , bizDocID);
			params.put("BizDocCode"  , ComUtils.RemoveScriptAndStyle(bizDocCode));
			params.put("BizDocName"  , ComUtils.RemoveScriptAndStyle(bizDocName));
			params.put("BizDocType"  , ComUtils.RemoveScriptAndStyle(bizDocType));
			params.put("Description" , ComUtils.RemoveScriptAndStyle(description));
			params.put("Linktable"	 , linktable);
			params.put("SortKey"	 , sortKey);			
			params.put("IsUse"  	 , isUse);
			params.put("EntCode"	 , entCode);
			
			returnList.put("object", bizDocListSvc.updateBizDoc(params));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	/**
	 * deleteBizDoc : 업무문서함관리 - 업무 문서함 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteBizDoc.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteBizDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocID  = request.getParameter("BizDocID");
			
			CoviMap params = new CoviMap();		
			params.put("BizDocID"  , bizDocID);
							
			returnList.put("object", bizDocListSvc.deleteBizDoc(params));					
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * getBizDocData : 업무문서함관리 - 특정 담당 업무 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getBizDocData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String bizDocID = request.getParameter("BizDocID");
			CoviMap resultList = null;
			
			CoviMap params = new CoviMap();		
			params.put("BizDocID", bizDocID);		
			
			resultList = bizDocListSvc.selectBizDocData(params);	
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goBizDocListSetPopup : 업무문서함관리 - 업무 문서함 설정 팝업 표시
	 */
	@RequestMapping(value = "manage/goBizDocListSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goDocFolderManagerSetPopup() {
		String returnURL = "manage/approval/BizDocListSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goBizDocForm : 업무문서함관리 - 담당 양식목록 팝업 표시
	 */
	@RequestMapping(value = "manage/goBizDocForm.do", method = RequestMethod.GET)
	public ModelAndView goBizDocForm() {
		String returnURL = "manage/approval/BizDocForm";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goBizDocMember : 업무문서함관리 - 담당자 목록 팝업 표시 
	 */
	@RequestMapping(value = "manage/goBizDocMember.do", method = RequestMethod.GET)
	public ModelAndView goBizDocMember() {
		String returnURL = "manage/approval/BizDocMember";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getBizDocFormList : 업무문서함관리 - 담당문서 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getBizDocFormList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocFormList(
			@RequestParam (value = "BizDocID", required=true) String bizDocID,
			@RequestParam (value = "SearchType", required=false) String searchType,
			@RequestParam (value = "SearchWord", required=false) String searchWord,
			@RequestParam (value = "pageNo", required=false , defaultValue="1") int pageNo,
			@RequestParam (value = "pageSize", required=false , defaultValue="10" ) int pageSize,
			@RequestParam (value = "sortBy", required=false, defaultValue="") String sortBy
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("bizDocID", bizDocID);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = bizDocListSvc.selectBizDocFormList(params);
			
			returnList.put("page", resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goBizDocFormSetPopup : 업무문서함관리 - 양식 추가 팝업 표시
	 */
	@RequestMapping(value = "manage/goBizDocFormSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goBizDocFormSetPopup() {		
		String returnURL = "manage/approval/BizDocFormSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goBizDocSelOrginFormPopup : 업무문서함관리 - 양식 기본양식 리스트 팝업 표시
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "manage/goBizDocSelOrginFormPopup.do", method = RequestMethod.GET)
	public ModelAndView goBizDocSelOrginFormPopup(HttpServletRequest request, Locale locale, Model model) {		
		String returnURL = "manage/approval/BizDocSelOrginFormPopup";
		
		String key = request.getParameter("key");
		String entCode = request.getParameter("entCode");
		String data = request.getParameter("data");
		
		ModelAndView mav = new ModelAndView(returnURL);	
		mav.addObject("key", key);
		mav.addObject("entCode", entCode);
		mav.addObject("data", data);
		
		return mav;
	}

	/**
	 * goBizDocFormDetailPopup : 업무문서함관리 - 양식 수정 팝업 표시
	 */
	@RequestMapping(value = "manage/goBizDocFormDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goBizDocFormDetailPopup() {		
		String returnURL = "manage/approval/BizDocFormDetailPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getBizDocSelOrginFormList : 업무문서함관리 - 기본양식 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getBizDocSelOrginFormList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocSelOrginFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String searchType = Objects.toString(request.getParameter("SearchType"), "");
			String searchWord = Objects.toString(request.getParameter("SearchWord"), "");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("bizDocID", paramMap.get("bizDocID"));
			params.put("bizEntCode", paramMap.get("bizEntCode"));
			params.put("SearchType", ComUtils.RemoveSQLInjection(searchType, 100));
			params.put("SearchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			// Add Paging 
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = bizDocListSvc.selectBizDocSelOrginFormList(params);
			//returnList.put("selectDataList", bizDocListSvc.selectBizDocFormAllList(params));
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * insertBizDocForm : 업무문서함관리 - 담당약식 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertBizDocForm.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertBizDocForm(
			@RequestParam (value = "BizDocID", required=true) String bizDocID,
			@RequestParam (value = "BizDocForm", required=true, defaultValue="[]") String strBizDocForm
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			CoviList arrBizForm = CoviList.fromObject(StringEscapeUtils.unescapeHtml(strBizDocForm));

			CoviMap params = new CoviMap();
			params.put("BizDocID", bizDocID);
			params.put("BizDocFormList", arrBizForm);
			
			bizDocListSvc.insertBizDocForm(params);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	/**
	 * getBizDocFormData : 업무문서함관리 - 특정 담당 양식 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getBizDocFormData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String bizDocFormID = request.getParameter("BizDocFormID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("BizDocFormID", bizDocFormID);		
						
			resultList = bizDocListSvc.selectBizDocFormData(params);
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * updateBizDocForm : 업무문서함관리 - 특정 업무 문서함  양식 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateBizDocForm.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateBizDocForm(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocFormID  = request.getParameter("BizDocFormID");
			String formPrefix  = request.getParameter("FormPrefix");
			String formName  = request.getParameter("FormName");
			String sortKey  = request.getParameter("SortKey");
			
			CoviMap params = new CoviMap();
			
			params.put("BizDocFormID"  , bizDocFormID);
			params.put("FormPrefix"  , ComUtils.RemoveScriptAndStyle(formPrefix));	
			params.put("FormName"  , ComUtils.RemoveScriptAndStyle(formName));			
			params.put("SortKey"  , sortKey);
			
			returnList.put("object", bizDocListSvc.updateBizDocForm(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	/**
	 * deleteBizDocForm : 업무문서함관리 - 특정 업무 문서함  양식 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteBizDocForm.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteBizDocForm(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocFormID  = request.getParameter("BizDocFormID");
			
			CoviMap params = new CoviMap();		
			params.put("BizDocFormID"  , bizDocFormID);
							
			returnList.put("object", bizDocListSvc.deleteBizDocForm(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * getBizDocMemberList : 업무문서함관리 - 담당자 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getBizDocMemberList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String bizDocID = request.getParameter("BizDocID");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("BizDocID", bizDocID);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = bizDocListSvc.selectBizDocMemberList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goBizDocMemberSetPopup : 업무문서함관리 - 담당자목록 추가 팝업 표시 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goBizDocMemberSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goBizDocMemberSetPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/BizDocMemberSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goBizDocMemberDetailPopup : 업무문서함관리 - 담당자목록 수정 팝업 표시 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goBizDocMemberDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goBizDocMemberDetailPopup() {
		String returnURL = "manage/approval/BizDocMemberDetailPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * insertBizDocMember : 업무문서함관리 - 담당자 정보 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertBizDocMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertBizDocMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {			
			String jsonString = request.getParameter("BizDocMember");
			
			CoviMap params = new CoviMap();
			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
			CoviList jarr = CoviList.fromObject(escapedJson);
			
			for(int i=0; i<jarr.size(); i++){			
				CoviMap order = jarr.getJSONObject(i);
				
				params.put("BizDocID"  , order.getString("BizDocID"));				
				params.put("UserCode", order.getString("UserCode"));
				params.put("SortKey", order.getString("SortKey"));
				
				bizDocListSvc.insertBizDocMember(params);				
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateBizDocMember : 업무문서함관리 - 담당자 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateBizDocMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateBizDocMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocMemberID  = request.getParameter("BizDocMemberID");		
			String sortKey  = request.getParameter("SortKey");
			
			CoviMap params = new CoviMap();
		
			params.put("BizDocMemberID"  , bizDocMemberID);			
			params.put("SortKey"  , sortKey);
			
			returnList.put("object", bizDocListSvc.updateBizDocMember(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	/**
	 * deleteBizDocMember : 업무문서함관리 - 담당자 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteBizDocMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteBizDocMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String bizDocMemberID  = request.getParameter("BizDocMemberID");
			
			CoviMap params = new CoviMap();			
			params.put("BizDocMemberID"  , bizDocMemberID);
							
			returnList.put("object", bizDocListSvc.deleteBizDocMember(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * getBizDocMemberData : 업무문서함관리 - 특정 담당자 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getBizDocMemberData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocMemberData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String bizDocMemberID = request.getParameter("BizDocMemberID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("BizDocMemberID", bizDocMemberID);
			
			resultList = bizDocListSvc.selectBizDocMemberData(params);
			
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
}
