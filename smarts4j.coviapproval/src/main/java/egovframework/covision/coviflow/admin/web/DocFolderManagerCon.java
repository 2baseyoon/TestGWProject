package egovframework.covision.coviflow.admin.web;


import java.util.Locale;
import java.util.Map;

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
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.DocFolderManagerSvc;


@Controller
public class DocFolderManagerCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(DocFolderManagerCon.class);
	
	@Autowired
	private DocFolderManagerSvc docFolderManagerSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getDocFolderManagerCount : 문서분류관리 - 해당 계열사의 최상위 폴더 정보를 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getTopFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDocFolderManagerCount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("EntCode");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("EntCode", entCode);
			
			resultList = docFolderManagerSvc.selectDocClass(params);
			
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
	
	@RequestMapping(value = "admin/getFolderPopup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderPopup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("EntCode");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("EntCode", entCode);
			
			resultList = docFolderManagerSvc.selectDocClassPopup(params);
			
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
	 * getDocFolderData : 문서분류관리 - 특정 폴더 데이터 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getDocFolderData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDocFolderData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("EntCode");
			String docClassID = request.getParameter("DocClassID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("EntCode", entCode);
			params.put("DocClassID", docClassID);
			
			resultList = docFolderManagerSvc.selectdocclassOne(params);
			returnList.put("map", resultList.get("map"));
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
	 * getselectUseAuthority : 문서분류관리에서 루트별 Select Box에 대한 데이터 바인드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getselectDdlCompany.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getselectUseAuthority(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			resultList = docFolderManagerSvc.selectDdlCompany(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
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
	 * goDocFolderManagerSetPopup : 결재함 권한 부여 - 특정부서(사용자) 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goDocFolderManagerSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goDocFolderManagerSetPopup(Locale locale, Model model) {
		String returnURL = "admin/approval/DocFolderManagerSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	
	/**
	 * insertDocFolder : 문서분류관리 - 새폴더 생성
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/insertDocFolder.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertDocFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnData = new CoviMap();
		try {
			String docClassID = request.getParameter("DocClassID");
			String parentDocClassID = request.getParameter("ParentDocClassID");
			String entCode = request.getParameter("EntCode");
			String className = request.getParameter("ClassName");
			String sortKey = request.getParameter("SortKey");
			String keepYear = request.getParameter("KeepYear");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("DocClassID",docClassID);
			params.put("ParentDocClassID",parentDocClassID);
			params.put("EntCode",entCode);
			params.put("ClassName",ComUtils.RemoveScriptAndStyle(className));
			params.put("SortKey",sortKey);
			params.put("KeepYear",keepYear);		
		
			resultList = docFolderManagerSvc.selectdocclassOne(params);			
			
			if("[{}]".equals(resultList.optString("map"))){ 
				int result = (int)docFolderManagerSvc.insert(params);				
				returnData.put("data", result);
				returnData.put("result", "ok");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "저장되었습니다");
			}else{
				returnData.put("result", "overlap");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "중복된 문서폴드 코드입니다.");
			}
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}	
	
	/**
	 * updateDocFolder : 문서분류관리 - 폴더 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateDocFolder.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateDocFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {
			String docClassID = request.getParameter("DocClassID");			
			String entCode = request.getParameter("EntCode");
			String className = request.getParameter("ClassName");
			String sortKey = request.getParameter("SortKey");
			String keepYear = request.getParameter("KeepYear");
			
			CoviMap params = new CoviMap();
			params.put("DocClassID",docClassID);		
			params.put("EntCode",entCode);
			params.put("ClassName",ComUtils.RemoveScriptAndStyle(className));
			params.put("SortKey",sortKey);
			params.put("KeepYear",keepYear);
			
			int result = docFolderManagerSvc.update(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	/**
	 * deleteDocFolder : 문서분류관리 - 폴더 삭제(하위 폴더가 있을 경우 삭제 불가능)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteDocFolder.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteDocFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnData = new CoviMap();
		try {
			String docClassID = request.getParameter("DocClassID");			
			String entCode = request.getParameter("EntCode");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("DocClassID",docClassID);		
			params.put("EntCode",entCode);
		
			resultList = docFolderManagerSvc.selectdocclassRetrieveFolder(params);
						
			if((int)resultList.get("cnt") > 0){ 
				
				returnData.put("result", "RetrieveFolder");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "하위폴더가 존재합니다. 삭제할 수 없습니다.");
			}else{
				int result = docFolderManagerSvc.delete(params);				
				returnData.put("data", result);
				returnData.put("result", "ok");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "삭제되었습니다");
			}			
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	/**
	 * goAdminFormPopup : 문서분류관리팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goDocTreePop.do", method = RequestMethod.GET)
	public ModelAndView goDocTreePop(Locale locale, Model model) {		
		String returnURL = "admin/approval/DocTreePop";		
		return new ModelAndView(returnURL);
	}
}
