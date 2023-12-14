package egovframework.covision.groupware.resource.manage.web;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.auth.BoardAuth;
import egovframework.covision.groupware.resource.manage.service.ResourceVManageSvc;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;


@Controller
@RequestMapping("resource/manage")
public class ResourceVManageCon {

	@Autowired
	private AuthHelper authHelper;

	@Autowired
	private ResourceVManageSvc resourceManageSvc;
	
	@Autowired
	private ResourceSvc resourceSvc;

	@Autowired
	AuthorityService authSvc;
	
	private Logger LOGGER = LogManager.getLogger(ResourceVManageCon.class); 
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getLeftDefaultData - 좌측 메뉴 필요 데이터 조회
	 * @param locale
	 * @param model
	 * @return mav
	 * @throws Exception
	 */
	@RequestMapping(value = "/getLeftDefaultData.do", method =  {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getLeftDefaultData(Locale locale, 
			@RequestParam(value = "domainID", required = false) String domainID) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		if(domainID == null || domainID.equals("")){
			domainID = SessionHelper.getSession("DN_ID");
		}
		
		CoviMap params = new CoviMap();
	    params.put("domainID", domainID);
		
	    returnObj.put("menuID", resourceManageSvc.getMenuByDomainID(params));
	    //returnObj.put("folderIcon", resourceManageSvc.getFolderIconCss());
	    
		return returnObj;
	}
	
	/**
	 * getEquipmentList - 자원 장비 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param searchType
	 * @param searchWord
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getEquipmentList.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getEquipmentList(   
			   @RequestParam(value = "isPaging", required = false, defaultValue="Y" ) String isPaging,
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			   @RequestParam(value = "domainID", required = false) String domainID,
			   @RequestParam(value = "searchType", required = false) String searchType,
			   @RequestParam(value = "searchWord", required = false) String searchWord) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageOffset = (pageNo - 1) * pageSize;
			String sortKey = sortBy.equals("") ? "" : sortBy.split(" ")[0];
			String sortDirec = sortBy.equals("") ? "" : sortBy.split(" ")[1];
			
			params.put("domainID", domainID);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			if(!isPaging.equals("N")){
				params.put("pageSize", pageSize);
				params.put("pageOffset", pageOffset);
			}
			
			CoviMap resultList = resourceManageSvc.getEquipmentList(params);

			int pageCount = (int) Math.ceil(resultList.getDouble("cnt")/ pageSize); 
			int listCount =resultList.getInt("cnt");
		
			page.put("pageNo", pageNo);
			page.put("pageSize", pageSize);
			page.put("listCount", listCount);
			page.put("pageCount", pageCount);
			
			if(!isPaging.equals("N")){
				returnList.put("page", page);
			}
			returnList.put("list", resultList.get("equipmentList"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * chnageEquipmentIsUse: 자원 장비 사용여부 변경
	 * @param equipmentID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/chnageEquipmentIsUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap chnageEquipmentIsUse(
			@RequestParam(value="equipmentID", required=true) int equipmentID) throws Exception{
		
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("equipmentID",equipmentID);
			resourceManageSvc.chnageEquipmentIsUse(params);
			
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
	 * deleteEquipmentData - 자원 장비 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/deleteEquipmentData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteEquipmentData(
			@RequestParam(value="equipmentID", required = true, defaultValue = "") String equipmentID) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
				String[] equipmentIDArr  = equipmentID.split(";"); //삭제할 자원장비 ID
		 
				CoviMap delParam = new CoviMap();
				delParam.put("equipmentIDArr",equipmentIDArr);
				
				resourceManageSvc.deleteEquipmentData(delParam);
			
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
	 * goEquipmentManageSetPopup : 자원 장비 관리 - 자원장비 관리 설정 팝업 표시 
	 * @return mav
	 */
	@RequestMapping(value = "/goEquipmentManageSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goEquipmentManageSetPopup() {
		String returnURL = "manage/resource/EquipmentManageSetPopup";
		
		return (new ModelAndView(returnURL));
	}	
	
	/**
	 * saveEquipmentData : 레이아웃 관리 - 레이아웃 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "/saveEquipmentData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap saveEquipmentData(MultipartHttpServletRequest req) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("thumbnail");
			String userID = SessionHelper.getSession("USERID");
			String equipmentName = req.getParameter("equipmentName");
			String sortKey = req.getParameter("sortKey");
			String isUse = req.getParameter("isUse");
			String domainID = req.getParameter("domainID");
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("equipmentName", equipmentName);
			params.put("sortKey", sortKey);
			params.put("isUse", isUse);
			params.put("domainID", domainID);
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;						
			String rootPath;
			String savePath;
			String companyCode = resourceManageSvc.getEquipmentDomainData(params);
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = RedisDataUtil.getBaseConfig("EquipmentThumbnail_SavePath"); ///GWStorage/Groupware/BizCard/
			savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("EquipmentThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
			
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()) {
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename(); 
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = "equipment_" + genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                filePath += saveFileName;
	                savePath += saveFileName; // 저장 될 파일 경로
	                 
	                //한글명저장	                 
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("equipmentThumbnail", filePath);
				}else{
					params.put("equipmentThumbnail","");
				}
				
			}else{
				params.put("equipmentThumbnail","");
			}
						
			resourceManageSvc.insertEquipmentData(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * modifyEquipmentData - 장비 정보 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "/modifyEquipmentData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap modifyEquipmentData(MultipartHttpServletRequest req) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("thumbnail");
			String userID = SessionHelper.getSession("USERID");
			String equipmentID = req.getParameter("equipmentID");
			String equipmentName = req.getParameter("equipmentName");
			String sortKey = req.getParameter("sortKey");
			String isUse = req.getParameter("isUse");
			String domainID = req.getParameter("domainID");
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("equipmentID", equipmentID);
			params.put("equipmentName", equipmentName);
			params.put("sortKey", sortKey);
			params.put("isUse", isUse);
			params.put("domainID", domainID);
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;						
			String rootPath;
			String savePath;
			String companyCode = resourceManageSvc.getEquipmentDomainData(params);
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = RedisDataUtil.getBaseConfig("EquipmentThumbnail_SavePath"); ///GWStorage/Groupware/BizCard/
			savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("EquipmentThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
			
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()) {
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename(); 
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = "equipment_" + genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                filePath += saveFileName;
	                savePath += saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장	                 
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("equipmentThumbnail", filePath);
				}
				
			}
						
			resourceManageSvc.updateEquipmentData(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	
	/**
	 * getEquipmentData - 특정 자원 장비 정보 조회
	 * @param equipmentID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getEquipmentData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getEquipmentData(   
			   @RequestParam(value = "equipmentID", required = true) int equipmentID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("equipmentID", equipmentID);
			
			CoviMap resultList = resourceManageSvc.getEquipmentData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getMainResourceList - 메인 화면 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getMainResourceList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getMainResourceList(   
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			   @RequestParam(value = "domainID", required = false) String domainID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageOffset = (pageNo - 1) * pageSize;
			String sortKey = sortBy.equals("") ? "" : sortBy.split(" ")[0];
			String sortDirec = sortBy.equals("") ? "" : sortBy.split(" ")[1];
			
			params.put("domainID", domainID);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageSize", pageSize);
			params.put("pageOffset", pageOffset);
			
			CoviMap resultList = resourceManageSvc.getMainResourceList(params);

			int pageCount = (int) Math.ceil(resultList.getDouble("cnt")/ pageSize); 
			int listCount =resultList.getInt("cnt");
		
			page.put("pageNo", pageNo);
			page.put("pageSize", pageSize);
			page.put("listCount", listCount);
			page.put("pageCount", pageCount);

			returnList.put("page", page);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getMainResourceTreeList - 자원 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getMainResourceTreeList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getMainResourceTreeList(   
			   @RequestParam(value = "domainID", required = false) String domainID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if(domainID == null){
				domainID = SessionHelper.getSession("DN_ID");
			}
			
			params.put("domainID", domainID);
			params.put("lang", SessionHelper.getSession("lang"));
			CoviList resultList = resourceManageSvc.getMainResourceTreeList(params);

			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	/**
	 * getFolderResourceTreeList - 자원 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getFolderResourceTreeList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getFolderResourceTreeList(   
			   @RequestParam(value = "domainID", required = false) String domainID,HttpServletRequest request) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if(domainID == null){
				domainID = SessionHelper.getSession("DN_ID");
			}
			
			params.put("domainID", domainID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("isAll", request.getParameter("isAll"));

			CoviList resultList = resourceManageSvc.getFolderResourceTreeList(params);

			String forderID = "";
			
			for(Object jsonobject : resultList){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				forderID = folderData.get("maxFolderID").toString();
			}
			
			returnList.put("forderID", forderID);
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getFolderResourceTreeList - 자원 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getOnlyFolderTreeList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getOnlyFolderTreeList(   
			   @RequestParam(value = "domainID", required = false) String domainID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("domainID", domainID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("selectType", "Folder");
			
			CoviList resultList = resourceManageSvc.getOnlyFolderTreeList(params);

			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	
	
	/**
	 * goResourceTreePopup : 메인 화면 자원 관리 - 자원 목록 선택
	 * @return mav
	 */
	@RequestMapping(value = "/goResourceTreePopup.do", method = RequestMethod.GET)
	public ModelAndView goResourceTreePopup() {
		String returnURL = "manage/resource/ResourceTree";
		
		return (new ModelAndView(returnURL));
	}	
	
	/**
	 * insertMainResource - 메인 화면 저장
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/insertMainResourceList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap insertMainResourceList(
			@RequestParam(value = "domainID", required = true, defaultValue="0") String domainID,
			@RequestParam(value = "resourceIDs", required = false, defaultValue="") String resourceID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			String userID = SessionHelper.getSession("USERID");
			String[] resourceIDArr = resourceID.equals("") ? null : resourceID.split(";");
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("resourceIDArr", resourceIDArr);
			params.put("userID", userID);
			
			resourceManageSvc.insertMainResourceList(params);

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * changeResourceSortKey - 메인 화면 목록 관리 상하이동
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/changeResourceSortKey.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changeResourceSortKey(   
			   @RequestParam(value = "folderID1", required = true) String folderID1,
			   @RequestParam(value = "sortKey1", required = true) String sortKey1,
			   @RequestParam(value = "folderID2", required = true) String folderID2,
			   @RequestParam(value = "sortKey2", required = true) String sortKey2 ) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("folderID1", folderID1);
			params.put("sortKey1", sortKey1);
			params.put("folderID2", folderID2);
			params.put("sortKey2", sortKey2);
			
			resourceManageSvc.changeResourceSortKey(params);

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getFolderInfo - 폴더 정보 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getFolderInfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getFolderInfo(   
			// @RequestParam(value = "menuID", required = false) String menuID ,
			   @RequestParam(value = "folderID", required = false, defaultValue = "0") int folderID ) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			//params.put("menuID", menuID);
			
			/*if(folderID == 0 ){
				folderID = resourceManageSvc.getTopFolderByMenuID(params);
			}*/
			
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));

			
			returnList.put("data",resourceManageSvc.getFolderInfo(params).getJSONObject("folderInfo"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getFolderList - 트리의 폴더 선택 시 하위 자원 정보조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getFolderList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getFolderList(   
			   @RequestParam(value = "folderID", required = true) String folderID,
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy	) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));

			
			CoviMap resultList = resourceManageSvc.getFolderInfo(params);
			
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getBookingOfResourceList -트리의 자원 선택 시 예약 정보 표시
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getBookingOfResourceList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getBookingOfResourceList(
			   @RequestParam(value = "folderID", required = true) String folderID,
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "searchType", required = false) String searchType,
			   @RequestParam(value = "searchWord", required = false) String searchWord,
			   @RequestParam(value = "startDate", required = false) String startDate,
			   @RequestParam(value = "endDate", required = false) String endDate,
			   @RequestParam(value = "bookingState", required = false) String bookingState,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy
			) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			int pageOffset = (pageNo - 1) * pageSize;

			int start =  (pageNo - 1) * pageSize +1; 
			int end = start + pageSize -1;
			
			sortBy = sortBy.equals("") ? "" : sortBy.split(",")[0];
			String sortKey = sortBy.equals("") ? "" : sortBy.split(" ")[0];
			String sortDirec = sortBy.equals("") ? "" : sortBy.split(" ")[1];
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("pageOffset", pageOffset);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("bookingState", bookingState);
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("rowStart",start);
			params.put("rowEnd",end);
			
			CoviMap resultList = resourceManageSvc.getBookingOfResourceList(params);

			params.addAll(ComUtils.setPagingData(params,resultList.getInt("cnt")));			//페이징 parameter set
			returnList.put("page",params);
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getResourceOfFolderList -트리의 퐅러 선택 시 자원 정보 표시
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getResourceOfFolderList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getResourceOfFolderList(
			   @RequestParam(value = "folderID", required = true) String folderID,
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy )  throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			String sortKey = sortBy.equals("") ? "" : sortBy.split(" ")[0];
			String sortDirec = sortBy.equals("") ? "" : sortBy.split(" ")[1];

			int pageOffset = (pageNo - 1) * pageSize;

			int start =  (pageNo - 1) * pageSize +1; 
			int end = start + pageSize -1;
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("folderID", folderID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("pageOffset", pageOffset);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("rowStart",start);
			params.put("rowEnd",end);
			
			CoviMap resultList = resourceManageSvc.getResourceOfFolderList(params);
			
			params.addAll(ComUtils.setPagingData(params,resultList.getInt("cnt")));			//페이징 parameter set
			
			returnList.put("page",params);
			returnList.put("list",resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * changeIsSwitch -폴더 IsUse or IsDisplay 상태 변경
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/changeIsSwitch.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changeIsSwitch(  
		     @RequestParam(value = "folderID", required = true) String folderID,
		     @RequestParam(value = "columnName", required = true) String columnName  ) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("columnName", columnName);
			
			 resourceManageSvc.changeIsSwitch(params);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * deleteFolderData -폴더 정보 삭제
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/deleteFolderData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteFolderData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			String[] folderIDArr  = StringUtil.replaceNull(request.getParameter("folderID"), "").split(";"); //삭제할 폴더 ID
			 
			CoviMap params = new CoviMap();
			params.put("folderIDArr",folderIDArr);
			params.put("objectIDs",folderIDArr);
			params.put("objectType","FD");
			params.put("bizSection","Resource");
			
			resourceManageSvc.deleteFolderData(params);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	/**
	 * changeFolderSortKey - 폴더 상하 이동
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/changeFolderSortKey.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changeFolderSortKey(
			 @RequestParam(value = "folderID1", required = true) String folderID1,
			 @RequestParam(value = "sortKey1", required = true) String sortKey1,
			 @RequestParam(value = "folderID2", required = true) String folderID2,
			 @RequestParam(value = "sortKey2", required = true) String sortKey2
			) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("folderID1", folderID1);
			params.put("sortKey1", sortKey1);
			params.put("folderID2", folderID2);
			params.put("sortKey2", sortKey2);
			
			resourceManageSvc.changeFolderSortKey(params);

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * 자원 위치 변경
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "moveFolderResource.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveFolder(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String domainID = request.getParameter("domainID");
			String folderID = request.getParameter("folderID");
			String memberOf = request.getParameter("memberOf");
			String sortKey = request.getParameter("sortKey");
			String mode = request.getParameter("mode");
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("memberOf", memberOf);
			params.put("orgSortKey", sortKey);
			params.put("mode", mode);
			
			result = (CoviMap) resourceManageSvc.selectTargetSortKey(params).get("target");	//순서 변경할 sortkey 조회
			if(!result.isEmpty()){	//최상위 혹은 최하위에 해당하거나 순서 변경을 할 대상을 찾지 못할경우의 처리 
				
				//현재 sortkey를 검색된 sortkey로 update
				CoviMap changeParams = new CoviMap();
				changeParams.put("folderID1", result.get("FolderID"));
				changeParams.put("sortKey1", result.get("SortKey"));
				changeParams.put("folderID2", folderID);
				changeParams.put("sortKey2", sortKey);
				
				resourceManageSvc.changeFolderSortKey(changeParams);
				
			} else {
				returnData.put("message", DicHelper.getDic("msg_gw_UnableChangeSortKey"));
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
	 * goResourceManageSetPopup : 자원예약 - 자원 관리 팝업
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/goResourceManagePopup.do", method = RequestMethod.GET)
	public ModelAndView goResourceManagePopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView("manage/resource/ResourceManagePopup");
		mav.addAllObjects(paramMap);
		StringUtil func = new StringUtil();
		try {
			if(!func.f_NullCheck(request.getParameter("parentFolderID")).equals("") && func.f_NullCheck(request.getParameter("folderID")).equals("")){
				CoviMap params = new CoviMap();
				params.put("folderID", request.getParameter("parentFolderID"));
				CoviMap folderInfo = resourceManageSvc.getFolderInfo(params);
				mav.addObject("folderPathName", ((CoviMap)folderInfo.get("folderInfo")).get("FolderPath"));
				mav.addObject("folderName", ((CoviMap)folderInfo.get("folderInfo")).get("FolderName"));
			}
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		return mav;
	}
	
	/**
	 * selectResourceACLData - 상위 권한 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/selectResourceACLData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectResourceACLData(
			@RequestParam(value = "objectID", required=false) String objectID,
			@RequestParam(value = "objectType", required=false) String objectType) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			
			CoviMap params = new CoviMap();
			params.put("objectID", objectID);
			params.put("objectType", objectType);
			
			result = authSvc.selectACL(params);
			
		    returnData.put("data",result);
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
	 * getUserDefFieldGridList : 확장옵션 - 사용자 정의 필드 Grid 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/getUserDefFieldGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserDefFieldGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			resultList = resourceManageSvc.getUserDefFieldGridList(params);
	
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
	 * createUserDefField : 확장옵션 - 사용자 정의 필드 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/createUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");				//FolderID
			String fieldName = request.getParameter("fieldName");			//FieldName
			String fieldType = request.getParameter("fieldType");			//필드 타입
			String fieldLimitCnt = request.getParameter("fieldLimitCnt");	//제한 설정
			String isList = request.getParameter("isList");					//목록 표시
			String isOption = StringUtil.replaceNull(request.getParameter("isOption"), "N");				//옵션 사용 여부
			String isCheckVal = request.getParameter("isCheckVal");			//필수 여부
			String isSearchItem = request.getParameter("isSearchItem");		//검색항목
			String optionStr = StringUtil.replaceNull(request.getParameter("optionStr"), "");			//필드 옵션 항목  ex) 옵션1|옵션2|옵션3|옵션|...|...
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("fieldName", fieldName);
			params.put("fieldType", fieldType);
			params.put("fieldLimitCnt", fieldLimitCnt);
			params.put("isList", isList);
			params.put("isOption", isOption);
			params.put("isCheckVal", isCheckVal);
			params.put("isSearchItem", isSearchItem);
			
			//해당항목에서의 최대값으로...조회
			int sortKey = resourceManageSvc.getUserDefFieldGridCount(params);
			params.put("sortKey", sortKey+1);
			
			int cnt = resourceManageSvc.createUserDefField(params);
			if(cnt>0){
				if(isOption.equals("Y")){	//필드 옵션 사용 여부 
					CoviMap optionParams = new CoviMap();
					String[] optionName = optionStr.split("\\|");
					for(int i = 0; i < optionName.length; i++){
						optionParams.put("optionName",optionName[i]);
						optionParams.put("optionValue", i);
						optionParams.put("sortKey", i);
						optionParams.put("userFormID", params.get("userFormID"));
						optionParams.put("folderID", folderID);
						resourceManageSvc.createUserDefField(optionParams);
					}
				}
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
	 * editUserDefField : 확장옵션 - 사용자 정의 필드 수정
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/updateUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap editUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String userFormID = request.getParameter("userFormID");			//UesrFormID
			String folderID = request.getParameter("folderID");				//FolderID
			String fieldName = request.getParameter("fieldName");			//FieldName
			String fieldType = request.getParameter("fieldType");			//필드 타입
			String fieldLimitCnt = request.getParameter("fieldLimitCnt");	//제한 설정
			String isList = request.getParameter("isList");					//목록 표시
			String isOption = StringUtil.replaceNull(request.getParameter("isOption"), "N");				//옵션 사용 여부
			String isCheckVal = request.getParameter("isCheckVal");			//필수 여부
			String isSearchItem = request.getParameter("isSearchItem");		//검색항목
			String optionStr = StringUtil.replaceNull(request.getParameter("optionStr"), "");			//필드 옵션 항목  ex) 옵션1|옵션2|옵션3|옵션|...|...
			
			CoviMap params = new CoviMap();
			params.put("userFormID", userFormID);
			params.put("folderID", folderID);
			params.put("fieldName", fieldName);
			params.put("fieldType", fieldType);
			params.put("fieldLimitCnt", fieldLimitCnt);
			params.put("isList", isList);
			params.put("isOption", isOption);
			params.put("isCheckVal", isCheckVal);
			params.put("isSearchItem", isSearchItem);
			
			int cnt = resourceManageSvc.updateUserDefField(params);		//사용자 정의 필드 정보 업데이트
			if(cnt>0){
				if(isOption.equals("Y")){	//필드 옵션 사용 여부 
					resourceManageSvc.deleteUserDefFieldOption(params);	//필드 옵션이 존재할경우 기존 필드옵션 삭제 처리 이후 새로 등록
					CoviMap optionParams = new CoviMap();
					String[] optionName = optionStr.split("\\|");
					for(int i = 0; i < optionName.length; i++){
						optionParams.put("optionName",optionName[i]);
						optionParams.put("optionValue", i);
						optionParams.put("sortKey", i);
						optionParams.put("userFormID", params.get("userFormID"));
						optionParams.put("folderID", folderID);
						resourceManageSvc.createUserDefField(optionParams);
					}
				}
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
	 * selectUserDefFieldOptionList : 확장옵션 - 사용자정의 필드Grid의 행을 선택할 경우 필드 옵션 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/getUserDefFieldOptionList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserDefFieldOptionList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			String userFormID = request.getParameter("userFormID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userFormID", userFormID);

			//이전의 폴더 ID 경로 조회
			result = (CoviList) resourceManageSvc.getUserDefFieldOptionList(params).get("list");
			
		    returnData.put("optionList",result);
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
	 * deleteUserDefOption : 필드 옵션 삭제 - 수정/필드 삭제시 옵션데이터 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/deleteUserDefOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserDefOption(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String optionID = request.getParameter("optionID");
			
			CoviMap params = new CoviMap();
			params.put("optionID", optionID);

			resourceManageSvc.deleteUserDefFieldOption(params);
			
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
	 * deleteUserDefField : 확장옵션 - 사용자정의 필드Grid에서 체크된 항목 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "/deleteUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			String[] userFormIDs = StringUtil.replaceNull(request.getParameter("userFormIDs"), "").split(";");
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("userFormIDs", userFormIDs);
			params.put("folderID", folderID);
			
			resourceManageSvc.deleteUserDefField(params);			//board_userform
			resourceManageSvc.deleteUserDefFieldOption(params);		//board_userform_option
			
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
	
	
	@RequestMapping(value = "/moveUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");
			String sortKey = request.getParameter("sortKey");
			String userFormID = request.getParameter("userFormID");
			String mode = request.getParameter("mode");
				
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("orgSortKey", sortKey);
			params.put("userFormID", userFormID);
			params.put("mode", mode);
			
			result = (CoviMap) resourceManageSvc.getTargetUserDefFieldSortKey(params).get("target");	//순서 변경할 sortkey 조회
			if(!result.isEmpty()){	//최상위 혹은 최하위에 해당하거나 순서 변경을 할 대상을 찾지 못할경우의 처리 
				//현재 sortkey를 검색된 sortkey로 update
				params.put("sortKey", result.get("SortKey"));
				
				int cnt = resourceManageSvc.updateUserDefFieldSortKey(params);
				if(cnt > 0 ){
					CoviMap targetParams = new CoviMap();
					targetParams.put("userFormID", result.get("UserFormID"));
					targetParams.put("sortKey", sortKey);
					resourceManageSvc.updateUserDefFieldSortKey(targetParams);
				}
			} else {
				returnData.put("message", DicHelper.getDic("msg_gw_UnableChangeSortKey"));
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
	
	/*
	 * goFindParentFolder : 자원 분류 지정
	 * @return mav
	 */
	@RequestMapping(value = "/goFindParentFolder.do", method = RequestMethod.GET)
	public ModelAndView goFindParentFolder() {
		String returnURL = "manage/resource/ResourceFolderTree";
		
		return (new ModelAndView(returnURL));
	}	
	
	/*
	 * goFindParentFolder : 사업장 지정
	 * @return mav
	 */
	@RequestMapping(value = "/goPlaceOfBusinessSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goPlaceOfBusinessSetPopup(HttpServletRequest request) throws Exception {
		CoviList placeOfBusiness =  RedisDataUtil.getBaseCode("PlaceOfBusiness", request.getParameter("domainID"));
		
		for(int i = 0; i < placeOfBusiness.size(); i++){
			if(placeOfBusiness.getJSONObject(i).getString("Code").equals("PlaceOfBusiness")){
				placeOfBusiness.remove(i);
				break;
			}
		}
		
		ModelAndView mav = new ModelAndView("manage/resource/PlaceOfBusinessSetPopup");
		mav.addObject("placeOfBusinessData", placeOfBusiness);
		
		return mav;
	}
	
	/*
	 * goShareResourceListSetPopup : 공유 자원 연결
	 * @return mav
	 */
	@RequestMapping(value = "/goShareResourceListSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goShareResourceListSetPopup() {
		String returnURL = "manage/resource/ShareResourceListSetPopup";
		
		return (new ModelAndView(returnURL));
	}	
	
	
	/*
	 * goResourceEquipmentSetPopup : 지원장비
	 * @return mav
	 */
	@RequestMapping(value = "/goResourceEquipmentSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goResourceEquipmentSetPopup() {
		String returnURL = "manage/resource/ResourceEquipmentSetPopup";
		
		return (new ModelAndView(returnURL));
	}	

	/*
	 * goResourceAttributeSetPopup : 추가속성
	 * @return mav
	 */
	@RequestMapping(value = "/goResourceAttributeSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goResourceAttributeSetPopup() {
		String returnURL = "manage/resource/ResourceAttributeSetPopup";
		
		return (new ModelAndView(returnURL));
	}	

	/**
	 * getShareResourceList - 공유 자원 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param searchType
	 * @param searchWord
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getShareResourceList.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getShareResourceList(   
			   @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			   @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			   @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			   @RequestParam(value = "domainID", required = false) String domainID,
			   @RequestParam(value = "searchWord", required = false) String searchWord) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String sortKey = sortBy.equals("") ? "" : sortBy.split(" ")[0];
			String sortDirec = sortBy.equals("") ? "" : sortBy.split(" ")[1];
			
			int start =  (pageNo - 1) * pageSize +1; 
			int end = start + pageSize -1;
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("domainID", domainID);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("rowStart",start);
			params.put("rowEnd",end);
			
			
			CoviMap resultList = resourceManageSvc.getShareResourceList(params);

			params.addAll(ComUtils.setPagingData(params,resultList.getInt("cnt")));			//페이징 parameter set
			returnList.put("page", params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/*
	 * goDisplayIconSetPopup : 표시 아이콘 지정
	 * @return mav
	 */
	@RequestMapping(value = "/goDisplayIconSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goDisplayIconSetPopup() throws Exception {
		String returnURL = "admin//DisplayIconSetPopup";
		CoviList displayIcon =  RedisDataUtil.getBaseCode("DisplayICon");
		for(int i = 0 ; i <displayIcon.size(); i++){
			if(displayIcon.getJSONObject(i).getString("Code").equals("DisplayICon")){
				displayIcon.remove(i);
				break;
			}
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("displayIcon",displayIcon);
		
		return mav;
	}	
	
	
	/**
	 * saveFolderData - 자원 저장
	 * @param mode
	 * @param folderData
	 * @param aclData
	 * @param equipmentData
	 * @param attributeData
	 * @param managementData
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/saveFolderData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap saveFolderData(   
			   @RequestParam(value = "mode", required = true) String mode,
			   @RequestParam(value = "folderData", required = true) String folderData,
			   @RequestParam(value = "aclIsChange", required = true, defaultValue = "N") String aclIsChange,
			   @RequestParam(value = "aclData", required = false, defaultValue="") String aclData,
			   @RequestParam(value = "aclActionData", required = false, defaultValue="") String aclActionData,
			   @RequestParam(value = "equipmentData", required = false, defaultValue="") String equipmentData,
			   @RequestParam(value = "attributeData", required = false, defaultValue="") String attributeData,
			   @RequestParam(value = "managementData", required = false, defaultValue="") String managementData	) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			String folderDataStr = StringEscapeUtils.unescapeHtml(folderData);
			String aclDataStr = StringEscapeUtils.unescapeHtml(aclData);
			String aclActionDataStr = StringEscapeUtils.unescapeHtml(aclActionData);
			String attributeDataStr = StringEscapeUtils.unescapeHtml(attributeData);
			String managementDataStr = StringEscapeUtils.unescapeHtml(managementData);
			
			CoviMap folderDataObj = CoviMap.fromObject(folderDataStr);
			CoviList aclDataObj = new CoviList();
			CoviList aclActionDataObj = new CoviList();
			CoviList attributeDataObj = new CoviList();
			CoviList managementDataOb = new CoviList();
			
			if(!aclDataStr.equals("[]")){
				aclDataObj = CoviList.fromObject(aclDataStr);
			}
			
			if(!aclActionDataStr.equals("[]")){
				aclActionDataObj = CoviList.fromObject(aclActionDataStr);
			}
			
			if (SessionHelper.getSession("isEasyAdmin").equals("Y") && mode.equals("I")){
				folderDataObj.put("securityLevel", "256");
				folderDataObj.put("isDisplay", "Y");
			}
			int menuID = (!"".equals(folderDataObj.getString("menuID"))) ? Integer.parseInt(folderDataObj.getString("menuID")) : 0;
			folderDataObj.put("menuID", menuID);
			
			if(!attributeDataStr.equals("[]")){
				attributeDataObj = CoviList.fromObject(attributeDataStr);
			}
			
			if(!managementDataStr.equals("[]")){
				managementDataOb = CoviList.fromObject(managementDataStr);
			}
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			params.put("folderData", folderDataObj);
			params.put("aclIsChange", aclIsChange);
			params.put("aclData", aclDataObj);
			
			params.put("equipmentData", equipmentData);
			params.put("attributeData", attributeDataObj);
			params.put("managementData", managementDataOb);

			if(mode.equals("I")){
				resourceManageSvc.insertFolderData(params);
				
				if(aclActionDataObj.size() > 0) authSvc.syncActionACL(aclActionDataObj, "FD_RESOURCE");
			}else if(mode.equals("U")){
				resourceManageSvc.updateFolderData(params);
				
				if(aclActionDataObj.size() > 0) authSvc.syncActionACL(aclActionDataObj, "FD_RESOURCE");
			}

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	
	/**
	 * getFolderData - 자원 장비 목록 조회
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param searchType
	 * @param searchWord
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/getFolderData.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getFolderData(   
			   @RequestParam(value = "folderID", required = true) String folderID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
			CoviMap folderData = resourceManageSvc.getFolderData(params);
			
			returnList.put("folderData", folderData);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * deleteBookingData - 예약 정보 삭제
	 * @param DateID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value="/deleteBookingData.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteBookingData(   
			@RequestParam(value = "DateID", required = true) String dateID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		// 권한 체크(isAdmin/isEasyAdmin을 session에서 체크, 작성자(isOwner) 체크 안함).
		CoviMap coviMap = new CoviMap();
		coviMap.put("userCode", SessionHelper.getSession("UR_Code"));
		if (!BoardAuth.getAdminAuth(coviMap)) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));       // 오류가 발생했습니다.
            return returnList;
		}
		
		try {
			CoviMap params = new CoviMap();
			params.put("DateID",dateID);
			
			resourceManageSvc.deleteBookingData(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 *  modifyBookingState - 자원예약 상태 변경
	 * @param dateID
	 * @param state 변경할 상태코드
	 * @return
	 */
	@RequestMapping(value = "modifyBookingState.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyBookingState(
			@RequestParam(value = "ApprovalState", required = true) String ApprovalState,
			 @RequestParam(value = "DateID", required = false) String DateID,
			 @RequestParam(value = "EventID", required = false) String EventID,
			 @RequestParam(value = "ResourceID", required = false) String ResourceID, 
			 @RequestParam(value = "IsRepeatAll", required = false, defaultValue = "N") String IsRepeatAll
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		// 간편관리자 혹은 시스템관리자 권한 확인.
		CoviMap coviMap = new CoviMap();
		coviMap.put("userCode", SessionHelper.getSession("UR_Code"));
		if (!BoardAuth.getAdminAuth(coviMap)) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));       // 오류가 발생했습니다.
			return returnList;
		}
		
		CoviMap resultObj = new CoviMap();
		CoviList resultArr = new CoviList();
		int failCnt = 0, successCnt = 0;
		try {
			String[] dataIDArr = DateID.split(";");			

			CoviMap params = new CoviMap();
			params.put("ApprovalState", ApprovalState);
			params.put("ResourceID", ResourceID);
			params.put("IsRepeatAll", IsRepeatAll);
			params.put("lang", SessionHelper.getSession("lang"));
			
			if(IsRepeatAll.equals("Y")) { //반복일정 모두 보기이면 조건에 맞는 대상 모두 변경
				params.put("EventID", EventID);
				
				resultObj = resourceSvc.modifyAllBookingState(params);
				
				failCnt = resultObj.getInt("FailCnt");
				successCnt = resultObj.getInt("SuccessCnt");
				resultArr = resultObj.getJSONArray("bookingArray");
			}else {
				for(int i = 0 ;i < dataIDArr.length; i++){
					params.put("DateID", dataIDArr[i]);
					
					resultObj = resourceSvc.modifyBookingState(params);
					resultObj.put("DateID", dataIDArr[i]);
					
					if(resultObj.getString("retType").equalsIgnoreCase("FAIL")) {
						failCnt++;
					}else {
						successCnt++;
					}
					
					resultArr.add(resultObj);
				}
			}
			
			returnList.put("result", resultArr);
			returnList.put("failCnt", failCnt);
			returnList.put("successCnt", successCnt);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
}
