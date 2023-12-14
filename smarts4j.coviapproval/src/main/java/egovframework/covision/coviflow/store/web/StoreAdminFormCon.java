package egovframework.covision.coviflow.store.web;

import java.io.File;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.ZipFileUtil;
import egovframework.covision.coviflow.store.service.StoreAdminFormSvc;

@Controller
public class StoreAdminFormCon {
	private static final Logger LOGGER = LogManager.getLogger(StoreAdminFormCon.class);
	
	@Autowired
	private StoreAdminFormSvc storeAdminFormSvc;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	private final String CHARSET = "UTF-8";
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//양식관리 분류그룹
	@RequestMapping(value = "manage/selectFormsCategoryList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectFormsCategoryList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
			
			returnList.put("data", storeAdminFormSvc.selectFormsCategoryList(params));

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
	@RequestMapping(value = "manage/selectStoreFormList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectStoreFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String sortColumn = ""; 
			String sortDirection = "";
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
			
			resultList = storeAdminFormSvc.selectStoreFormList(params, true);

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

	@RequestMapping(value = "manage/updateIsUseStoredForm.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseStoredForm(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String modUserId = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap(paramMap);
			params.put("ModifierCode", modUserId);

			storeAdminFormSvc.updateIsUseForm(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_137")); //성공적으로 갱신되었습니다.
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//구매목록
	@RequestMapping(value = "manage/StoreAdminPurchaseListData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap storeAdminPurchaseListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String sortColumn = ""; 
			String sortDirection = "";
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
			
			resultList = storeAdminFormSvc.storeAdminPurchaseListData(params, true);

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
	/**
	 * goFormClassPopup : 결재양식 레이어팝업 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/StoreAddFormPopup.do", method = RequestMethod.GET)
	public ModelAndView goAddFormPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreAddFormPopup";		
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/StoreAdminFormViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goAdminFormViewPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreAdminFormViewPopup";		
		return new ModelAndView(returnURL);
	}
	
	//구매고객 조회팝업
	@RequestMapping(value = "manage/StoreAdminPurchaseListPopup.do", method = RequestMethod.GET)
	public ModelAndView storePurchaseListPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/StoreAdminPurchaseListPopup";		
		return new ModelAndView(returnURL);
	}

	//양식 등록시 분류 selectbox
	@RequestMapping(value = "manage/getStoreCategorySelectbox.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getStoreCategorySelectbox(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			resultList = storeAdminFormSvc.getStoreCategorySelectbox(params);
			CoviList formCategoryListData = (CoviList)resultList.get("list");
			
			for(int i=0; i<formCategoryListData.size(); i++) { // 다국어 처리
				CoviMap jsonObj = (CoviMap) formCategoryListData.get(i);
				jsonObj.put("optionText", DicHelper.getDicInfo(jsonObj.optString("optionText"), SessionHelper.getSession("lang")));
			}

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
	
	/**
	 * storeInsertFormData : 결재 양식등록
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/storeInsertFormData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap storeInsertFormData(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			Date currentTime = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("HHmmss");
			String servicePath = sdf.format(currentTime);
			String unzipFolderName = "";
			String registerCode = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap formObj = CoviMap.fromObject(request.getParameter("formObj"));
			formObj.put("RegisterCode", registerCode);
			formObj.put("FormDescription", replaceEncodeContext(formObj.optString("FormDescription")));
			String formPrefix = formObj.optString("FormPrefix");
			if(!formPrefix.toUpperCase().startsWith("CSTF_")) { 
				formPrefix = "CSTF_" + formPrefix;
				formObj.put("FormPrefix", formPrefix);
			}
			String mobileFormYN = formObj.optString("MobileFormYN");
			
			MultipartFile imgFileInfo = request.getFile("ImgFileInfo");
			List<MultipartFile> multiFile = request.getFiles("MultiFileData[]");
			multiFile.add(imgFileInfo);			
			
			//첨부파일 확장자 체크, 양식파일 fontStorage에 upload
			CoviList frontUploadResultArr = new CoviList();
 			if(FileUtil.isEnableExtention(multiFile)){
 				frontUploadResultArr = fileUtilSvc.uploadToFront(null, multiFile, servicePath);
			}

 			//양식 zip풀기
            String frontFullPath = "";
            String frontAddPath = "";
    		for(int i = 0; i < frontUploadResultArr.size(); i++)
    		{
    			CoviMap fobj = (CoviMap)frontUploadResultArr.get(i);
				
				String fileExtension = FilenameUtils.getExtension(fobj.optString("FileName")).toLowerCase();
				if(fileExtension.equals("zip")) {
					String companyCode = SessionHelper.getSession("DN_Code");
					String FrontPath = FileUtil.getFrontPath(companyCode);
					if(FrontPath.endsWith("/")){
						FrontPath = FrontPath.substring(0,FrontPath.length()-1);
					}
					frontAddPath = fobj.optString("FrontAddPath");
					frontFullPath = FrontPath + File.separator + companyCode + File.separator + frontAddPath;
					
            		ZipFileUtil zipUtil = new ZipFileUtil();
            		File zipFile = new File(FileUtil.checkTraversalCharacter(frontFullPath + File.separator + fobj.optString("SavedName")));
            		unzipFolderName = fobj.optString("SavedName").split("[.]")[0];
            		
            		File dir = new File(FileUtil.checkTraversalCharacter(frontFullPath + File.separator + unzipFolderName));
            		zipUtil.unzip(zipFile, dir);
            		frontUploadResultArr.remove(i);
				}
			}
			
    		// UnZiped files process
    		boolean bUploadFileType = true;
    		if(!"".equals(unzipFolderName)) {
    			File file = new File(FileUtil.checkTraversalCharacter(frontFullPath + File.separator + unzipFolderName));
    			File[] fileList = file.listFiles();
    			int mobileFormUploadCnt = 0;
    			int pcFormUploadCnt = 0;
    			
    			for(int i=0; fileList != null && i<fileList.length;i++) {
    				CoviMap unzipObj = new CoviMap();
    				String getFileName = fileList[i].getName();
    				String fileExtension = FilenameUtils.getExtension(getFileName);
    				String setFileName = formPrefix + "." + fileExtension;
    				if ("Y".equals(mobileFormYN) && FilenameUtils.getBaseName(getFileName).endsWith("_MOBILE")) {
    					setFileName = formPrefix+ "_MOBILE." + fileExtension;
    					mobileFormUploadCnt++;
    				} else {
    					pcFormUploadCnt++;
    				}
    				unzipObj.put("FileName", setFileName);
    				unzipObj.put("Size", fileList[i].length());
    				unzipObj.put("SavedName", getFileName);
    				unzipObj.put("FrontAddPath", frontAddPath + File.separator + unzipFolderName + File.separator);
    				
    				if(!(fileExtension.equals("html") || fileExtension.equals("js"))) {
    					bUploadFileType = false;
    					break;
    				}
    				frontUploadResultArr.add(unzipObj);
    			}
    			if(pcFormUploadCnt != 2 && mobileFormUploadCnt != ("Y".equals(mobileFormYN) ? 2 : 0)) bUploadFileType = false;
    		}
            
            if(bUploadFileType && storeAdminFormSvc.storeInsertFormData(formObj, frontUploadResultArr) > 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_apv_331"));//저장되었습니다.
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
			}
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
	 * storeUpdateFormData : 결재 양식 수정
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/storeUpdateFormData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap storeUpdateFormData(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			Date currentTime = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("HHmmss");
			String servicePath = sdf.format(currentTime);
			String unzipFolderName = "";
			String registerCode = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap formObj = CoviMap.fromObject(request.getParameter("formObj"));
			formObj.put("ModifierCode", registerCode);
			formObj.put("FormDescription", replaceEncodeContext(formObj.optString("FormDescription")));
			String formPrefix = formObj.optString("FormPrefix");
			if(!formPrefix.toUpperCase().startsWith("CSTF_")) { 
				formPrefix = "CSTF_" + formPrefix;
				formObj.put("FormPrefix", formPrefix);
			}
			String mobileFormYN = formObj.optString("MobileFormYN");
			
			List<MultipartFile> modifyFiles = new ArrayList<MultipartFile>();
			MultipartFile imgFileInfo = request.getFile("ImgFileInfo");
			List<MultipartFile> multiFile = request.getFiles("MultiFileData[]");
			
			if(multiFile != null && multiFile.size() > 0) {
				modifyFiles.addAll(multiFile); // zip
			}
			if(imgFileInfo != null) {
				modifyFiles.add(imgFileInfo); // thumbnail
			}
			
			//첨부파일 확장자 체크, 양식파일 fontStorage에 upload
			CoviList frontUploadResultArr = null;
 			if(modifyFiles != null && modifyFiles.size() > 0 && FileUtil.isEnableExtention(modifyFiles)){
 				frontUploadResultArr = fileUtilSvc.uploadToFront(null, modifyFiles, servicePath);
			}

 			//양식 zip풀기
            String frontFullPath = "";
            String frontAddPath = "";
    		for(int i = 0; frontUploadResultArr != null && i < frontUploadResultArr.size(); i++)
    		{
    			CoviMap fobj = (CoviMap)frontUploadResultArr.get(i);
				
				String fileExtension = FilenameUtils.getExtension(fobj.optString("FileName")).toLowerCase();
				if(fileExtension.equals("zip")) {
					String companyCode = SessionHelper.getSession("DN_Code");
					String FrontPath = FileUtil.getFrontPath(companyCode);
					if(FrontPath.endsWith("/")){
						FrontPath = FrontPath.substring(0,FrontPath.length()-1);
					}
					frontAddPath = fobj.optString("FrontAddPath");
					frontFullPath = FrontPath + File.separator + companyCode + File.separator + frontAddPath;
										
            		ZipFileUtil zipUtil = new ZipFileUtil();
            		File zipFile = new File(frontFullPath + File.separator + fobj.optString("SavedName"));
            		unzipFolderName = fobj.optString("SavedName").split("[.]")[0];
            		
            		File dir = new File(frontFullPath + File.separator + unzipFolderName);
            		zipUtil.unzip(zipFile, dir);
            		frontUploadResultArr.remove(i);
				}
			}
			
    		// UnZiped files process
    		boolean bUploadFileType = true;
    		if(!"".equals(unzipFolderName)) {
    			
    			File file = new File(frontFullPath + File.separator + unzipFolderName);
    			File[] fileList = file.listFiles();
    			int mobileFormUploadCnt = 0;
    			int pcFormUploadCnt = 0;
    			
    			for(int i=0; fileList != null && i < fileList.length; i++) {
    				CoviMap unzipObj = new CoviMap(); 
    				String getFileName = fileList[i].getName();
    				String fileExtension = FilenameUtils.getExtension(getFileName);
    				String setFileName = formPrefix + "." + fileExtension;
        			if ("Y".equals(mobileFormYN) && FilenameUtils.getBaseName(getFileName).endsWith("_MOBILE")) {
    					setFileName = formPrefix+ "_MOBILE." + fileExtension;
    					mobileFormUploadCnt++;
        			} else {
    					pcFormUploadCnt++;
    				}
    				unzipObj.put("FileName", setFileName);
    				unzipObj.put("Size", fileList[i].length());
    				unzipObj.put("SavedName", getFileName);
    				unzipObj.put("FrontAddPath", frontAddPath + File.separator + unzipFolderName + File.separator);
    				
    				if(!(fileExtension.equals("html") || fileExtension.equals("js"))) {
    					bUploadFileType = false;
    					break;
    				}
    				frontUploadResultArr.add(unzipObj);
    			}
    			if(pcFormUploadCnt != 2 && mobileFormUploadCnt != ("Y".equals(mobileFormYN) ? 2 : 0)) bUploadFileType = false;
    		}
            
            if(bUploadFileType && storeAdminFormSvc.storeUpdateFormData(formObj, frontUploadResultArr) > 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_137")); //성공적으로 갱신되었습니다.
			} else {
				// 압축파일 내 파일확장자 오류 , 잘못된 압축파일입니다.
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Zip file can including HTML, JS files Only.");
			}
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
	
	//스토어 FormPrefix 중복체크
	@RequestMapping(value = "manage/storeFormDuplicateCheck.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap storeFormDuplicateCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			String formPrefix = request.getParameter("FormPrefix");

			CoviMap params = new CoviMap();
			if(!StringUtil.replaceNull(formPrefix, "").toUpperCase().startsWith("CSTF_")) { 
				formPrefix = "CSTF_" + formPrefix;
			}
			params.put("FormPrefix", formPrefix);
			
			returnList.put("result", storeAdminFormSvc.storeFormDuplicateCheck(params));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/** 
	 * 결재양식 data info
	 */
	@RequestMapping(value = "manage/getStoreFormData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getStoreFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {

			CoviMap params = new CoviMap(paramMap);
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap info = storeAdminFormSvc.getStoreFormData(params);
			String formDescDecode = new String(Base64.decodeBase64(info.optString("FormDescription")),StandardCharsets.UTF_8);
			info.put("FormDescription", formDescDecode);
			returnList.put("info", info);

			// File Info.
			List<String> fileIDs = new ArrayList<String>();
			fileIDs.add(info.getString("FormHtmlFileID"));
			fileIDs.add(info.getString("FormJsFileID"));
			fileIDs.add(info.getString("MobileFormHtmlFileID"));
			fileIDs.add(info.getString("MobileFormJsFileID"));
			CoviList fileList = fileUtilSvc.getFileListByID(fileIDs);
			FileUtil.getFileTokenArray(fileList);
			returnList.put("fileList", fileList);
			
			// Version List
			if("View".equals(params.optString("mode"))) {
				params.put("StoredFormID", info.getString("StoredFormID"));
				CoviList revList = storeAdminFormSvc.getStoreFormRevList(params);
				returnList.put("revList", revList);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "manage/storeFormListExcelDownload.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView storeFormListExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			String title = params.getString("title");
			String headerName = params.getString("headername");
			String[] headerNames = headerName.split(";");
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap resultList = storeAdminFormSvc.selectStoreFormList(params, false);
			
			CoviMap viewParams = new CoviMap();
			viewParams.put("list", resultList.get("list"));
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);
		}catch(ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));			
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));			
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getLocalizedMessage():DicHelper.getDic("msg_apv_030"));			
		}
		return mav;
	}
	
	public String replaceEncodeContext(String oContext){
		if(oContext == null)
			return null;
		return new String(Base64.encodeBase64(oContext.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
	}
}
