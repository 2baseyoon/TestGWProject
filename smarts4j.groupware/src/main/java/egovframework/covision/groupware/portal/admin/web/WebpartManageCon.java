package egovframework.covision.groupware.portal.admin.web;

import java.io.File;
import java.io.IOException;

import javax.servlet.http.HttpServletRequest;



import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.portal.admin.service.WebpartManageSvc;



	
/**
 * @Class Name : WebpartManageCon.java
 * @Description : 웹파트 관리 페이지를 위한 클라이언트 요청 처리
 * @Modification Information 
 * @ 017.05.30 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.05.30
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class WebpartManageCon {

	private Logger LOGGER = LogManager.getLogger(WebpartManageCon.class);
	
	@Autowired
	private WebpartManageSvc webpartManageSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 *  getWebpartList - 웹파트 관리 - 웹파트 목록 조회
	 * @param companyCode - 회사 코드
	 * @param bizSection - 업무 구분
	 * @param searchType - 검색 타입
	 * @param searchWord - 검색어
	 * @param sortBy - 정렬키
	 * @param pageNo - 페이지 번호
	 * @param pageSize - 페이지 사이즈
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartList(
			HttpServletRequest request,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "bizSection", required = false) String bizSection,
			@RequestParam(value = "searchType", required = false) String searchType,
			@RequestParam(value = "searchWord", required = false) String searchWord,
			@RequestParam(value = "range", required = false) String range,
			@RequestParam(value = "reserved1", required = false) String reserved1,
			@RequestParam(value = "reserved2", required = false) String reserved2,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("companyCode", companyCode);
			params.put("bizSection", bizSection);
			params.put("searchType", searchType);
			params.put("searchWord", searchWord);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("range", range);
			params.put("reserved1", reserved1);
			params.put("reserved2", reserved2);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = webpartManageSvc.getWebpartList(params);
			
			returnData.put("page", resultList.get("page"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	

	/**
	 * getWebpartSearchSelectBoxData - 웹파트 관리 화면에 소유 회사, 업무영역, 검색 조건 select box 데이터 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
/*	@RequestMapping(value = "portal/getWebpartSearchSelectBoxData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartSearchSelectBoxData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap companyList = new CoviMap();
		CoviList bizSectionList = new CoviList();
		CoviList searchTypeList = new CoviList();
		
		try {
			companyList = webpartManageSvc.getCompanyList();
			bizSectionList =RedisDataUtil.getBaseCode("BizSection");
			
			// 기초 코드 개발 후 하드 코딩 제거
			
			//검색조건 SelectBox Binding Data
			CoviMap itme = new CoviMap();
			itme.put("optionValue", "");
			itme.put("optionText", DicHelper.getDic("lbl_selection")); //선택
			searchTypeList.add(itme);
			
			itme.put("optionValue", "WebpartName");
			itme.put("optionText", DicHelper.getDic("lbl_WebPartName")); //웹파트명
			searchTypeList.add(itme);
			
			itme.put("optionValue", "RegisterName");
			itme.put("optionText", DicHelper.getDic("lbl_Register")); //등록자
			searchTypeList.add(itme);
			
			itme.put("optionValue", "Description");
			itme.put("optionText", DicHelper.getDic("lbl_Description")); //설명
			searchTypeList.add(itme);
			
			returnData.put("company",companyList.get("list"));
			returnData.put("bizSection",bizSectionList);
			returnData.put("searchType",searchTypeList);
			returnData.put("status", Return.SUCCESS);
			
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}*/
	
	
	/**
	 * goWebpartManageSetPopup : 웹파트 관리 - 웹파트 관리 설정 팝업 표시 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/goWebpartManageSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goLayoutManageSetPopup() {
		return (new ModelAndView("admin/portal/WebpartManageSetPopup"));
	}
	
	
	/**
	 * getWebpartPopupSelectBoxData - 웹파트 관리 화면에 소유 회사, 업무영역, 검색 조건 select box 데이터 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
/*	@RequestMapping(value = "portal/getWebpartPopupSelectBoxData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartPopupSelectBoxData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap companyList = new CoviMap();
		CoviList bizSectionList = new CoviList();
		CoviList rangeList = new CoviList();
		
		try {
			companyList = webpartManageSvc.getCompanyList();

			bizSectionList = RedisDataUtil.getBaseCode("BizSection");
			rangeList =  RedisDataUtil.getBaseCode("WebmoduleRange"); 
			
			returnData.put("company",companyList.get("list"));
			returnData.put("bizSection",bizSectionList);
			returnData.put("range",rangeList);
			returnData.put("status", Return.SUCCESS);
			
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}*/
	
	/**
	 *  insertWebpartData - 포탈 정보 저장
	 * @param userCode - 등록자 ID
	 * @param webpartName - 웹파트 명칭
	 * @param dicWebpartName - 웹파트 명칭(다국어)
	 * @param companyCode - 회사 코드
	 * @param isUse - 사용여부
	 * @param bizSection - 업무구분
	 * @param range - 사용범위
	 * @param minHeight - 최소높이
	 * @param htmlPath - html 경로
	 * @param jsPath - js 경로
	 * @param jsModuleName  - js 모듈명
	 * @param preview - 미리보기 html 
	 * @param ref - 참조
	 * @param scriptMethod - 클라이언트 단의 메소드
	 * @param description - 설명
	 * @param exJson - 확장 json 
	 * @param dataInfo - 데이터 정보 json 
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/insertWebpartData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertWebpartData(
			@RequestParam(value = "userCode", required = false) String userCode,
			@RequestParam(value = "webpartName", required = false) String webpartName,
			@RequestParam(value = "dicWebpartName", required = false) String dicWebpartName,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "isUse", required = false) String isUse,
			@RequestParam(value = "bizSection", required = false) String bizSection,
			@RequestParam(value = "range", required = false) String range,
			@RequestParam(value = "minHeight", required = false) String minHeight,
			@RequestParam(value = "htmlPath", required = false) String htmlPath,
			@RequestParam(value = "jsPath", required = false) String jsPath,
			@RequestParam(value = "jsModuleName", required = false) String jsModuleName,
			@RequestParam(value = "preview", required = false) String preview,
			@RequestParam(value = "ref", required = false) String ref,
			@RequestParam(value = "scriptMethod", required = false) String scriptMethod,
			@RequestParam(value = "description", required = false) String description,
			@RequestParam(value = "thumbnail", required = false) MultipartFile fileInfo,
			@RequestParam(value = "thumbnailPath", required = false) String thumbnailPath,
			@RequestParam(value = "reserved1", required = false) String reserved1,
			@RequestParam(value = "reserved2", required = false) String reserved2,
			@RequestParam(value = "reserved3", required = false) String reserved3,
			@RequestParam(value = "reserved4", required = false) String reserved4,
			@RequestParam(value = "reserved5", required = false) String reserved5,
			@RequestParam(value = "sortKey", required = false) String sortKey,
			@RequestParam(value = "exJson", required = false  , defaultValue = "{}") String exJson,
			@RequestParam(value = "dataInfo", required = false , defaultValue = "[]") String dataInfo,
			@RequestParam(value = "permission", required = false , defaultValue = "{}") String permission,
			@RequestParam(value = "permissionDel", required = false  , defaultValue = "{}") String permissionDel,
			@RequestParam(value = "actionData", required = false  , defaultValue = "") String actionData
			) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			
			CoviMap permissionObj =  CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permission)); //권한 정보
			CoviMap permissionDelObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permissionDel)); //삭제될 권한 정보
			CoviList aclActionDataObj = new CoviList();
			
			if(userCode == null){
				userCode =  SessionHelper.getSession("USERID");
			}
			
			CoviMap exJsonObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(exJson));
			CoviList dataInfoArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(dataInfo));
			
			CoviMap params = new CoviMap();
			params.setConvertJSONObject(false);
			params.put("registerCode", userCode);
			params.put("displayName", webpartName);
			params.put("dicWebpartName", dicWebpartName);
			params.put("companyCode", companyCode);
			params.put("isUse", isUse);
			params.put("bizSection", bizSection);
			params.put("range", range);
			params.put("minHeight", minHeight);
			params.put("htmlFilePath", htmlPath);
			params.put("jsFilePath", jsPath);
			params.put("jsModuleName", jsModuleName);
			params.put("preview", preview);
			params.put("resource", ref);
			params.put("scriptMethod", scriptMethod);
			params.put("description", description);
			params.put("reserved1", reserved1);
			params.put("reserved2", reserved2);
			params.put("reserved3", reserved3);
			params.put("reserved4", reserved4);
			params.put("reserved5", reserved5);
			params.put("sortKey", sortKey);
			params.put("extentionJSON",exJsonObj.toString());
			params.put("dataJSON", dataInfoArr.toString());
			
			params.put("permission", permissionObj);
			params.put("permissionDel", permissionDelObj);
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;
			String rootPath;
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = rootPath + RedisDataUtil.getBaseConfig("WebpartThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename();
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                String savePath = filePath + saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장
	                savePath = new String(savePath.getBytes("UTF-8"), "UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("webpartThumnail", savePath.replace(rootPath, ""));
				}else{
					params.put("webpartThumnail", "");
				}
				
			}else{
				params.put("webpartThumnail", thumbnailPath);
			}
			
			webpartManageSvc.insertWebpartData(params);
			
			if(aclActionDataObj.size() > 0)
				authSvc.syncActionACL(aclActionDataObj, "WP");
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 *  updateWebpartData - 웹 정보  수정
	 * @param webpartID - 웹파트 ID
	 * @param userCode - 등록자 ID
	 * @param webpartName - 웹파트 명칭
	 * @param dicWebpartName - 웹파트 명칭(다국어)
	 * @param companyCode - 회사 코드
	 * @param isUse - 사용여부
	 * @param bizSection - 업무구분
	 * @param range - 사용범위
	 * @param minHeight - 최소높이
	 * @param htmlPath - html 경로
	 * @param jsPath - js 경로
	 * @param jsModuleName  - js 모듈명
	 * @param preview - 미리보기 html 
	 * @param ref - 참조
	 * @param scriptMethod - 클라이언트 단의 메소드
	 * @param description - 설명
	 * @param exJson - 확장 json 
	 * @param dataInfo - 데이터 정보 json 
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/updateWebpartData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateWebpartData(MultipartHttpServletRequest req) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			String webpartID = req.getParameter("webpartID");
			String userCode = req.getParameter("userCode");
			String webpartName = req.getParameter("webpartName");
			String dicWebpartName = req.getParameter("dicWebpartName");
			String companyCode = req.getParameter("companyCode");
			String isUse = req.getParameter("isUse");
			String bizSection = req.getParameter("bizSection");
			String range = req.getParameter("range");
			String minHeight = req.getParameter("minHeight");
			String htmlPath = req.getParameter("htmlPath");
			String jsPath = req.getParameter("jsPath");
			String jsModuleName = req.getParameter("jsModuleName");
			String preview = req.getParameter("preview");
			String ref = req.getParameter("ref");
			String scriptMethod = req.getParameter("scriptMethod");
			String description = req.getParameter("description");
			String exJson = req.getParameter("exJson") == null ? "{}" : req.getParameter("exJson");
			String dataInfo = req.getParameter("dataInfo") == null ? "[]" : req.getParameter("dataInfo");
			String reserved1 = req.getParameter("reserved1");
			String reserved2 = req.getParameter("reserved2");
			String reserved3 = req.getParameter("reserved3");
			String reserved4 = req.getParameter("reserved4");
			String reserved5 = req.getParameter("reserved5");
			String sortKey = req.getParameter("sortKey");
			
			String permission = req.getParameter("permission") == null ? "{}" : req.getParameter("permission");
			String permissionDel = req.getParameter("permissionDel") == null ? "{}" : req.getParameter("permissionDel");
			String actionData = req.getParameter("actionData") == null ? "" : req.getParameter("actionData");
			
			if(userCode == null){
				userCode =  SessionHelper.getSession("USERID");
			}
			
			CoviMap permissionObj =  CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permission)); //권한 정보
			CoviMap permissionDelObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(permissionDel)); //삭제될 권한 정보
		
			CoviList aclActionDataObj = new CoviList();
			
			if(!actionData.equals("[]")){
				aclActionDataObj = CoviList.fromObject(StringEscapeUtils.unescapeHtml(actionData));		
			}
			
			CoviMap exJsonObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(exJson));
			CoviList dataInfoArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(dataInfo));
			MultipartFile fileInfo = req.getFile("thumbnail");
			CoviMap params = new CoviMap();
			params.setConvertJSONObject(false);
			params.put("registerCode", userCode);
			params.put("webpartID", webpartID);
			params.put("displayName", webpartName);
			params.put("dicWebpartName", dicWebpartName);
			params.put("companyCode", companyCode);
			params.put("isUse", isUse);
			params.put("bizSection", bizSection);
			params.put("range", range);
			params.put("minHeight", minHeight);
			params.put("htmlFilePath", htmlPath);
			params.put("jsFilePath", jsPath);
			params.put("jsModuleName", jsModuleName);
			params.put("preview", preview);
			params.put("resource", ref);
			params.put("scriptMethod", scriptMethod);
			params.put("description", description);
			params.put("extentionJSON", exJsonObj.toString());
			params.put("dataJSON", dataInfoArr.toString());
			
			params.put("reserved1", reserved1);
			params.put("reserved2", reserved2);
			params.put("reserved3", reserved3);
			params.put("reserved4", reserved4);
			params.put("reserved5", reserved5);
			params.put("sortKey", sortKey);
			
			params.putOrigin("permission", permissionObj);
			params.putOrigin("permissionDel", permissionDelObj);
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;
			String rootPath;
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = rootPath + RedisDataUtil.getBaseConfig("WebpartThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename();
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                String savePath = filePath + saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장
	                savePath = new String(savePath.getBytes("UTF-8"), "UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("webpartThumnail", savePath.replace(rootPath, ""));
				}else{
					params.put("webpartThumnail", "");
				}
				
			}else{
				params.put("webpartThumnail", req.getParameter("thumbnailPath"));
			}
			
			webpartManageSvc.updateWebpartData(params);
			
			if(aclActionDataObj.size() > 0)
				authSvc.syncActionACL(aclActionDataObj, "WP");
			
			returnData.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	/**
	 * chnagePortalIsUse - 포탈 사용여부 변경
	 * @param webpartID 
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/chnageWebpartIsUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap chnagePortalIsUse(
			@RequestParam(value = "webpartID", required = true) String webpartID) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("webpartID",webpartID);
			webpartManageSvc.chnageWebpartIsUse(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	/**
	 * deleteWebpartData - 웹파트 삭제
	 * @param webpartID - 삭제할 웹파트 ID 목록 (;로 구분)
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/deleteWebpartData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteWebpartData(
			@RequestParam(value = "webpartID", required = true, defaultValue= "") String webpartID) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] arrWebpartID  = webpartID.split(";"); //삭제할 포탈 ID

			if(arrWebpartID.length > 0){
				CoviMap delParam = new CoviMap();
				delParam.put("arrWebpartID",arrWebpartID);
				webpartManageSvc.deleteWebpartData(delParam);
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * getWebpartData - 특정 웹파트 데이터 조회
	 * @param webpartID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getWebpartData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartData(
			@RequestParam(value = "webpartID", required = true) String webpartID) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("objectID", webpartID);
			params.put("objectType", "WP");
			
			resultList = webpartManageSvc.getWebpartData(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("item", resultList.get("item"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	
	/**
	 * checkJsModuleNameDuplication - 모듈명 중복 체크
	 * @param webpartID
	 * @param moduleName
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/checkJsModuleNameDuplication.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkJsModuleNameDuplication(
			@RequestParam(value = "webpartID", required = true) String webpartID,
			@RequestParam(value = "moduleName", required = true, defaultValue= "") String moduleName	) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("webpartID", webpartID);
			params.put("moduleName", moduleName);
			
			int cnt = webpartManageSvc.selectDuplJsModuleName(params);
			
			returnData.put("cnt",cnt);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
}
