package egovframework.covision.coviflow.store.web;

import java.sql.SQLException;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.store.service.StoreAdminCategorySvc;
import egovframework.covision.coviflow.store.service.StoreAdminFormSvc;

@Controller
public class StoreAdminCategoryCon {
	private static final Logger LOGGER = LogManager.getLogger(StoreAdminCategoryCon.class);
			
	@Autowired
	private StoreAdminCategorySvc storeAdminCategorySvc;
	
	@Autowired
	private StoreAdminFormSvc storeAdminFormSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "manage/getCategoryList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getCategoryList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String sortColumn = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[0]; 
			String sortDirection = request.getParameter("sortBy")==null ? "" : request.getParameter("sortBy").split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DomainID", paramMap.get("DomainID"));
			
			resultList = storeAdminCategorySvc.selectCategoryList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			LoggerHelper.errorLogger(npE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * goFormClassPopup : 분류관리 팝업창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/storeAddCategoryPopup.do", method = RequestMethod.GET)
	public ModelAndView goAddCategoryPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreAddCategoryPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * insertCategoryData : 결재 분류 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertCategoryData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertFormClassData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String categoryName  = request.getParameter("CategoryName");
			String sortKey = request.getParameter("SortKey");
			String registerCode = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();
			params.put("CategoryName"  , categoryName);
			params.put("SortKey", (StringUtil.isEmpty(sortKey) ? "0": sortKey)); // 오라클 대비 수정
			params.put("RegisterCode"  , registerCode);
			
			storeAdminCategorySvc.insertCategoryData(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_136"));//"저장되었습니다."
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			LoggerHelper.errorLogger(npE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateIsUseCategory : 분류관리 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/updateIsUseCategory.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseCategory(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String categoryID = request.getParameter("CategoryID");
			String iseUse = request.getParameter("IseUse");
			String modUserId = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();
			params.put("CategoryID", categoryID);
			params.put("IseUse", iseUse);
			params.put("ModUserId", modUserId);

			storeAdminCategorySvc.updateIsUseCategory(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_137")); //성공적으로 갱신되었습니다.
			returnList.put("etcs", "");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			LoggerHelper.errorLogger(npE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsUseCategory : 분류관리 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/deleteCategory.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteCategory(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String categoryCodes = StringUtil.replaceNull(request.getParameter("CategoryCodes"));
			String[] arrCategoryCodes = categoryCodes.split(",");

			CoviMap params = new CoviMap();
			params.put("CategoryID", arrCategoryCodes);
			
			// 등록된 양식이 존재하는지 체크
			CoviMap chkParams = new CoviMap();
			for(int i = 0; arrCategoryCodes != null && i < arrCategoryCodes.length; i++) {
				String categoryID = arrCategoryCodes[i];
				chkParams.put("filterCategoryID", categoryID);
				long formCnt = storeAdminFormSvc.getCategoryFormCnt(chkParams);
				if(formCnt > 0) {
					throw new java.sql.SQLIntegrityConstraintViolationException(DicHelper.getDic("msg_apv_storeFormExists"));
				}
			}
			storeAdminCategorySvc.deleteCategory(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_138")); //성공적으로 삭제되었습니다.
			returnList.put("etcs", "");
		} catch (SQLException sqlE) {
			LOGGER.error(sqlE.getLocalizedMessage(), sqlE);
			LoggerHelper.errorLogger(sqlE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			if(sqlE != null && sqlE instanceof java.sql.SQLIntegrityConstraintViolationException) {
				returnList.put("message", sqlE.getMessage());
			}else {
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
			}
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			if(e != null && e instanceof java.sql.SQLIntegrityConstraintViolationException) {
				returnList.put("message", e.getMessage());
			}else {
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
			}
		}
		return returnList;
	}
	
	/**
	 * getFormClassData : 양식분류 관리 - 특정 양식분류 레이어팝업 수정화면에 대한 데이터 바인드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getCategoryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCategoryData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			CoviMap resultList = null;
			String categoryID = request.getParameter("CategoryID");
			
			CoviMap params = new CoviMap();	
			params.put("CategoryID", categoryID);		
			
			resultList = storeAdminCategorySvc.getCategoryData(params);						
	
			returnList.put("list", resultList.get("map"));
			returnList.put("cnt", resultList.get("cnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			LoggerHelper.errorLogger(npE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * updateIsUseCategory : 분류관리 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/updateCategoryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateCategoryData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String categoryID = request.getParameter("CategoryID");
			String categoryName = request.getParameter("CategoryName");
			String sortKey = request.getParameter("SortKey");
			String modUserId = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();
			params.put("CategoryID", categoryID);			
			params.put("CategoryName", categoryName);
			params.put("SortKey", sortKey);
			params.put("ModUserId", modUserId);

			storeAdminCategorySvc.updateCategoryData(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_137"));
			returnList.put("etcs", "");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			LoggerHelper.errorLogger(npE, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, this.getClass().getName(), "RUN");
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}	
}
