package egovframework.covision.coviflow.store.web;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
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
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.store.service.StoreUserFormSvc;

@Controller
public class StoreUserFormCon {
	private static final Logger LOGGER = LogManager.getLogger(StoreUserFormCon.class);
	
	@Autowired
	private StoreUserFormSvc storeUserFormSvc;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	//양식목록 분류그룹
	@RequestMapping(value = "user/getFormsCategoryList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getFormsCategoryList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			returnList.put("data", storeUserFormSvc.getFormsCategoryList(params));

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	//양식목록
	@RequestMapping(value = "user/getStoreUserFormList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getStoreUserFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String sortColumn = ""; 
			String sortDirection = "";
			String companyCode = SessionHelper.getSession("DN_Code");
			if(paramMap.get("sortBy") != null && !"".equals((String)paramMap.get("sortBy"))) {
				String sortBy = (String)paramMap.get("sortBy");
				sortColumn = sortBy.split(" ")[0]; 
				sortDirection = sortBy.split(" ")[1];
			}
			CoviMap resultList = null;
			
			CoviMap params = new CoviMap(paramMap);		
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("CompanyCode", companyCode);
			
			resultList = storeUserFormSvc.getStoreUserFormList(params, true);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//유료양식 count
	@RequestMapping(value = "user/getPurchaseFormData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getPurchaseFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			
			CoviMap params = new CoviMap(paramMap);
			params.put("CompanyCode", companyCode);
			
			returnList.put("data", storeUserFormSvc.getPurchaseFormData(params));

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "user/StoreUserFormViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goUserFormViewPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreUserFormViewPopup";		
		return new ModelAndView(returnURL);
	}
	
	/** 
	 * 결재양식 data info
	 */
	@RequestMapping(value = "user/getStoreUserFormData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getStoreUserFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			
			CoviMap params = new CoviMap(paramMap);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode", companyCode);
			
			CoviMap info = storeUserFormSvc.getStoreUserFormData(params);
			String formDescDecode = new String(Base64.decodeBase64(info.optString("FormDescription")),StandardCharsets.UTF_8);
			info.put("FormDescription", formDescDecode);
			returnList.put("info", info);

			List<String> fileIDs = new ArrayList<String>();
			fileIDs.add(info.getString("FormHtmlFileID"));
			fileIDs.add(info.getString("FormJsFileID"));
			fileIDs.add(info.getString("MobileFormHtmlFileID"));
			fileIDs.add(info.getString("MobileFormJsFileID"));
			CoviList fileList = fileUtilSvc.getFileListByID(fileIDs);
			FileUtil.getFileTokenArray(fileList);
			returnList.put("fileList", fileList);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "user/goStoreFormBuyPopup.do", method = RequestMethod.GET)
	public ModelAndView goStoreFormBuyPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreFormBuyPopup";		
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "user/getStoreFormClassList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStoreFormClassList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String companyCode = SessionHelper.getSession("DN_Code");

			CoviMap params = new CoviMap(paramMap);
			params.put("IsSaaS", isSaaS);
			params.put("CompanyCode", companyCode);

			CoviMap resultList = storeUserFormSvc.getStoreFormClassList(params);
			CoviList formCLassListData = (CoviList)resultList.get("classlist");
						
			for(int i=0; i<formCLassListData.size(); i++) { // 다국어 처리
				CoviMap jsonObj = (CoviMap) formCLassListData.get(i);
				jsonObj.put("optionText", DicHelper.getDicInfo(jsonObj.optString("optionText"), SessionHelper.getSession("lang")));
			}
				
			returnList.put("classlist", formCLassListData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	/** 
	 * 결재양식 구매
	 * @throws Exception 
	 */
	@RequestMapping(value = "user/storePurchaseForm.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap storePurchaseForm(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			String storedFormClass = request.getParameter("StoredFormClass");
			String storedFormSchema = request.getParameter("StoredFormSchema");
			
			CoviMap params = new CoviMap(paramMap);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode", companyCode);
			
			CoviMap getFormObj = storeUserFormSvc.getStoreUserFormData(params); 
			getFormObj.putAll(storeUserFormSvc.getPurchaseFormData(params));
			getFormObj.put("StoredFormClass", storedFormClass);
			getFormObj.put("StoredFormSchema", storedFormSchema);
			getFormObj.put("RegisterCode", Objects.toString(SessionHelper.getSession("USERID"),""));
			getFormObj.put("CompanyCode", companyCode);
			getFormObj.put("CouponID", paramMap.get("CouponID"));
			
			returnList = storeUserFormSvc.storePurchaseForm(getFormObj);

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("returnMsg", DicHelper.getDic("msg_FailFormPaurchase")); //"양식구매시 오류가 발생하였습니다. 관리자에게 문의하세요."
		}
		
		return returnList;
	}
}
