package egovframework.core.web;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
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
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.PBE;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.sevice.SysDomainSvc;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.MessageHelper;

/**
 * @Class Name : SystemDomainCon.java
 * @Description : 시스템 - 도메인(회사) 관리
 * @Modification Information 
 * @ 2016.04.21 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.21
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysDomainCon {
	private Logger LOGGER = LogManager.getLogger(SysDomainCon.class);
	
	@Autowired
	private SysDomainSvc sysDomainSvc;
	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * addDomainLayerPopup : 도메인(회사) 관리 추가 및 수정 버튼 레이어팝업
	 * @return mav
	 */
	@RequestMapping(value = "domain/goDomainPopup.do", method = RequestMethod.GET)
	public ModelAndView addDomainLayerPopup() {
		return (new ModelAndView("core/system/adddomainlayerpopup"));
	}
	
	/**
	 * goDomainInfoConfigAddPopup : 도메인(회사) 관리 추가 및 수정 버튼 레이어팝업
	 * @return mav
	 */
	@RequestMapping(value = "domain/goDomainInfoConfigAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goDomainInfoConfigAddPopup() {
		return (new ModelAndView("core/system/DomainInfoConfigAddPopup"));
	}
	
	/**
	 * goDomainInfoConfigAddPopup : 도메인(회사) 관리 추가 및 수정 버튼 레이어팝업
	 * @return mav
	 */
	@RequestMapping(value = "domain/goLoginPopup.do", method = RequestMethod.GET)
	public ModelAndView goLoginPopup() {
		return (new ModelAndView("core/login/login"));
	}
	
	/**
	 * goDomainLicPopup : 도메인 라이선스 팝업
	 * @return mav
	 */
	@RequestMapping(value = "domain/goDomainLicPopup.do", method = RequestMethod.GET)
	public ModelAndView goDomainLicPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap){
		ModelAndView mav = new ModelAndView("core/system/DomainLicPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * getDataDomain : 도메인 그리드 데이터 바인드
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDataDomain(
			HttpServletRequest request,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try { 
			String sort = request.getParameter("sortBy");
			
			String sortKey =    (sort!= null &&  !sort.equals("") )? sort.split(" ")[0] : "";
			String sortDirec =  (sort!= null &&  !sort.equals("") )? sort.split(" ")[1] : "";
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("selectsearch", request.getParameter("selectsearch"));
			params.put("isUse", request.getParameter("isUse"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			resultList = sysDomainSvc.select(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
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
	 * selectDomainCode : 하나의 도메인 데이터 바인드
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/getCode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectDomainCode(HttpServletRequest request) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList domainList = ComUtils.getAssignedDomainID();
			CoviMap params = new CoviMap();
			
			params.put("assignedDomain", domainList);
			String isService = request.getParameter("isService") ;
			params.put("isService", isService);
			
			resultList = sysDomainSvc.selectCode(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * selectOneDomain : 하나의 도메인 데이터 바인드
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectOneDomain(
			@RequestParam(value = "DomainID", required = true) int domainID) throws Exception
	{

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("DomainID", domainID);
			
			resultList = sysDomainSvc.selectOne(params);
			
			returnList.put("list", resultList.get("map"));
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
	 * addDomain - 도메인 데이터 추가
	 * @param req
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addDomain(MultipartHttpServletRequest req, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String domainCode = req.getParameter("DomainCode");
			String domainURL = req.getParameter("DomainURL");
			String domainType = req.getParameter("DomainType");
			String mailDomain = req.getParameter("MailDomain");
			String isCPMail = req.getParameter("IsCPMail");
			String domainName = req.getParameter("DomainName");
			String MultiDomainName = req.getParameter("MulitiDomainName");
			String serviceStart = req.getParameter("ServiceStart");
			String serviceEnd = req.getParameter("ServiceEnd");
			String description = req.getParameter("Description");
			String subDomain = req.getParameter("SubDomain");
			String orgSyncType = req.getParameter("OrgSyncType");
			String domainCorpTel = req.getParameter("DomainCorpTel");
			String domainRepName = req.getParameter("DomainRepName");
			String domainRepTel = req.getParameter("DomainRepTel");
			String domainAddress = req.getParameter("DomainAddress");
			String chargerName = req.getParameter("ChargerName");
			String chargerTel = req.getParameter("ChargerTel");
			String chargerID = req.getParameter("ChargerID");
			String chargerEmail = req.getParameter("ChargerEmail");
			MultipartFile pcLogoFile = req.getFile("PCLogoFile");
			MultipartFile mobileLogoFile = req.getFile("MobileLogoFile");
			List<MultipartFile> portalBannerFileList = req.getFiles("PortalBannerFile");
			String googleClientID = req.getParameter("GoogleClientID");
			String googleClientKey = req.getParameter("GoogleClientKey");
			String googleRedirectURL = req.getParameter("GoogleRedirectURL");
			String licDomain = req.getParameter("LicDomain");
			String licExpireDate = req.getParameter("LicExpireDate");
			/*String licUserCount = req.getParameter("LicUserCount");
			String lieExUserCount = req.getParameter("LieExUserCount");
			String licEx1Date = req.getParameter("LicEx1Date");*/
			CoviList licInfoList = new CoviList(req.getParameter("LicInfoList").replaceAll("&quot;", "\""));
			String registDate = req.getParameter("RegistDate");
			String EntireMailID = req.getParameter("EntireMailID");
			EntireMailID = (StringUtil.isNotNull(EntireMailID))?EntireMailID:domainCode;		
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			String rootPath, savePath;
			String domainImagePath = "", domainBannerPath = "";
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", domainCode);
			
			if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			CoviMap paramDN = new CoviMap();
			
			if(pcLogoFile != null){
				long fileSize = pcLogoFile.getSize();
			
				if(fileSize > 0){
					savePath = rootPath.substring(0, rootPath.length() - 1) + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = pcLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "PC_Logo." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					pcLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName + ";";
				}else{
					domainImagePath += ";";
				}
			}else{
				domainImagePath += ";";
			}
			
			if(mobileLogoFile != null){
				long fileSize = mobileLogoFile.getSize();
				
				if(fileSize > 0){
					savePath = rootPath.substring(0, rootPath.length() - 1) + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = mobileLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "Mobile_Logo." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					mobileLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName;
				}
			}
			
			if(portalBannerFileList.size() != 0){
				int portalBannerCnt = 1;
				
				for(MultipartFile mf : portalBannerFileList){
					savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("PortalBanner_SavePath");
					long fileSize = mf.getSize();
					
					if(fileSize > 0){
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						//폴더가없을 시 생성
						if(!realUploadDir.exists()){
							if(realUploadDir.mkdirs()){
								LOGGER.info("path : " + realUploadDir + " mkdirs();");
							}
						}
						
						// 본래 파일명
						String originalfileName = mf.getOriginalFilename();
						String ext = FilenameUtils.getExtension(originalfileName);
						
						// 저장되는 파일 이름
						String saveFileName = "PortalBanner_" + portalBannerCnt + "." + ext;
						savePath += saveFileName; // 저장 될 파일 경로
						
						//한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
						File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
						
						// 파일 중복 처리
						if(saveFile.exists()){
							if(saveFile.delete()){
								LOGGER.info("file : " + saveFile.toString() + " delete();");
							} else {
								LOGGER.error("Fail on deleteFile() : " + saveFile);
								throw new Exception("deleteFile error.");
							}
						}
						
						mf.transferTo(saveFile); // 파일 저장
						domainBannerPath += saveFileName + ";";
					}
					
					portalBannerCnt++;
				}
				
				if(!StringUtil.isEmpty(domainBannerPath) && domainBannerPath.substring(domainBannerPath.length() - 1, domainBannerPath.length()).equals(";")){
					domainBannerPath = domainBannerPath.substring(0, domainBannerPath.length() - 1);
				}
			}
			
			paramDN.put("DomainCode", domainCode);
			paramDN.put("Domain", domainURL);
			paramDN.put("DomainType", domainType);
			paramDN.put("MailDomain", mailDomain);
			paramDN.put("IsCPMail", isCPMail);
			paramDN.put("DisplayName", domainName);
			paramDN.put("ExFullName", MultiDomainName);
			paramDN.put("ServiceUser", "0");
			paramDN.put("ServiceStart", serviceStart);
			paramDN.put("ServiceEnd", serviceEnd);
			paramDN.put("Description", description);
			paramDN.put("SubDomain", subDomain);
			paramDN.put("OrgSyncType", orgSyncType);
			paramDN.put("DomainCorpTel", domainCorpTel);
			paramDN.put("DomainRepName", domainRepName);
			paramDN.put("DomainRepTel", domainRepTel);
			paramDN.put("DomainAddress", domainAddress);
			paramDN.put("ChargerName", chargerName);
			paramDN.put("ChargerTel", chargerTel);
			paramDN.put("ChargerID", chargerID);
			paramDN.put("ChargerEmail", chargerEmail);
			paramDN.put("DomainImagePath", domainImagePath.equals(";") ? "" : domainImagePath);
			paramDN.put("DomainBannerPath", domainBannerPath);
			paramDN.put("LicDomain", licDomain);
			paramDN.put("LicExpireDate", licExpireDate);
			/*paramDN.put("LicUserCount", licUserCount);
			paramDN.put("LieExUserCount", lieExUserCount);
			paramDN.put("LicEx1Date", licEx1Date);*/
			paramDN.put("RegistDate", registDate);
			paramDN.put("EntireMailID", EntireMailID);
			paramDN.put("UserCode", SessionHelper.getSession("UR_Code"));
			
			returnList.put("result", sysDomainSvc.insert(paramDN));
			//insertAdminUser(paramDN);
			//insertDomainFolder(paramDN);
			
			paramDN.put("MemberOf", "ORGROOT");
			paramDN.put("PrimaryMail", domainCode+"@"+domainURL);
			sendMailApi(paramDN);
			//orgSyncManageSvc.addGroup(paramDN);
			 
			if (!returnList.get("result").equals(-1)){
				if(StringUtil.isNotNull(googleClientID) || StringUtil.isNotNull(googleClientKey) || StringUtil.isNotNull(googleRedirectURL)) {
					paramDN.put("GoogleClientID", googleClientID);
					paramDN.put("GoogleClientKey", googleClientKey);
					paramDN.put("GoogleRedirectURL", googleRedirectURL);
					
					sysDomainSvc.insertDomainGoogleSchedule(paramDN);
				}
			}
			
			// 도메인 별 라이선스 정보 저장
			if (licInfoList.size() > 0) {
				paramDN.put("LicInfoList", licInfoList);
				
				sysDomainSvc.saveDoaminLicInfo(paramDN);
			}
			
			returnList.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * updateDomain - 도메인 데이터 수정
	 * @param req
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateDomain(MultipartHttpServletRequest req, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
			
			String domainID = req.getParameter("DomainID");
			String domainCode = req.getParameter("DomainCode");
			String domainURL = req.getParameter("DomainURL");
			String domainType = req.getParameter("DomainType");
			String domainName = req.getParameter("DomainName");
			String MultiDomainName = req.getParameter("MulitiDomainName");
			String serviceStart = req.getParameter("ServiceStart");
			String serviceEnd = req.getParameter("ServiceEnd");
			String description = req.getParameter("Description");
			String subDomain = req.getParameter("SubDomain");
			String orgSyncType = req.getParameter("OrgSyncType");
			String domainCorpTel = req.getParameter("DomainCorpTel");
			String domainRepName = req.getParameter("DomainRepName");
			String domainRepTel = req.getParameter("DomainRepTel");
			String domainAddress = req.getParameter("DomainAddress");
			String chargerName = req.getParameter("ChargerName");
			String chargerTel = req.getParameter("ChargerTel");
			String chargerID = req.getParameter("ChargerID");
			String chargerEmail = req.getParameter("ChargerEmail");
			MultipartFile pcLogoFile = req.getFile("PCLogoFile");
			MultipartFile mobileLogoFile = req.getFile("MobileLogoFile");
			List<MultipartFile> portalBannerFileList = req.getFiles("PortalBannerFile");
			String googleClientID = req.getParameter("GoogleClientID");
			String googleClientKey = req.getParameter("GoogleClientKey");
			String googleRedirectURL = req.getParameter("GoogleRedirectURL");
			String licDomain = req.getParameter("LicDomain");
			String licExpireDate = req.getParameter("LicExpireDate");
			/*String licUserCount = req.getParameter("LicUserCount");
			String lieExUserCount = req.getParameter("LieExUserCount");
			String licEx1Date = req.getParameter("LicEx1Date");*/
			CoviList licInfoList = new CoviList(req.getParameter("LicInfoList").replaceAll("&quot;", "\""));
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			String rootPath, savePath;
			String domainImagePath = "", domainBannerPath = "";
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", domainCode);
			
			if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			CoviMap paramDN = new CoviMap();
			
			if(pcLogoFile != null){
				long fileSize = pcLogoFile.getSize();
			
				if(fileSize > 0){
					savePath = rootPath.substring(0, rootPath.length() - 1) + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = pcLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "PC_Logo." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					pcLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName + ";";
				}else{
					domainImagePath += ";";
				}
			}else{
				domainImagePath += ";";
			}
			
			if(mobileLogoFile != null){
				long fileSize = mobileLogoFile.getSize();
				
				if(fileSize > 0){
					savePath = rootPath.substring(0, rootPath.length() - 1) + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = mobileLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "Mobile_Logo." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					mobileLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName;
				}
			}
			
			if(portalBannerFileList.size() != 0){
				int portalBannerCnt = 1;
				
				for(MultipartFile mf : portalBannerFileList){
					savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("PortalBanner_SavePath");
					long fileSize = mf.getSize();
					
					if(fileSize > 0){
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						//폴더가없을 시 생성
						if(!realUploadDir.exists()){
							if(realUploadDir.mkdirs()){
								LOGGER.info("path : " + realUploadDir + " mkdirs();");
							}
						}
						
						// 본래 파일명
						String originalfileName = mf.getOriginalFilename();
						String ext = FilenameUtils.getExtension(originalfileName);
						
						// 저장되는 파일 이름
						String saveFileName = "PortalBanner_" + portalBannerCnt + "." + ext;
						savePath += saveFileName; // 저장 될 파일 경로
						
						//한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
						File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
						
						// 파일 중복 처리
						if(saveFile.exists()){
							if(saveFile.delete()){
								LOGGER.info("file : " + saveFile.toString() + " delete();");
							} else {
								LOGGER.error("Fail on deleteFile() : " + saveFile);
								throw new Exception("deleteFile error.");
							}
						}
						
						mf.transferTo(saveFile); // 파일 저장
						domainBannerPath += saveFileName + ";";
					}
					
					portalBannerCnt++;
				}
				
				if(!StringUtil.isEmpty(domainBannerPath) && domainBannerPath.substring(domainBannerPath.length() - 1, domainBannerPath.length()).equals(";")){
					domainBannerPath = domainBannerPath.substring(0, domainBannerPath.length() - 1);
				}
			}

			paramDN.put("DomainID", domainID);
			paramDN.put("DomainCode", domainCode);
			paramDN.put("Domain", domainURL);
			paramDN.put("DomainType", domainType);
			paramDN.put("DisplayName", domainName);
			paramDN.put("ExFullName", MultiDomainName);
			paramDN.put("ServiceUser", 0);
			paramDN.put("ServiceStart", serviceStart);
			paramDN.put("ServiceEnd", serviceEnd);
			paramDN.put("Description", description);
			paramDN.put("SubDomain", subDomain);
			paramDN.put("OrgSyncType", orgSyncType);
			paramDN.put("DomainCorpTel", domainCorpTel);
			paramDN.put("DomainRepName", domainRepName);
			paramDN.put("DomainRepTel", domainRepTel);
			paramDN.put("DomainAddress", domainAddress);
			paramDN.put("ChargerName", chargerName);
			paramDN.put("ChargerTel", chargerTel);
			paramDN.put("ChargerID", chargerID);
			paramDN.put("ChargerEmail", chargerEmail);
			paramDN.put("DomainImagePath", domainImagePath.equals(";") ? "" : domainImagePath);
			paramDN.put("DomainBannerPath", domainBannerPath);
			paramDN.put("LicDomain", licDomain);
			paramDN.put("LicExpireDate", licExpireDate);
			/*paramDN.put("LicUserCount", licUserCount);
			paramDN.put("LieExUserCount", lieExUserCount);
			paramDN.put("LicEx1Date", licEx1Date);*/
			paramDN.put("UserCode", SessionHelper.getSession("UR_Code"));
			
			if (StringUtil.isNotNull(googleClientID) || StringUtil.isNotNull(googleClientKey) || StringUtil.isNotNull(googleRedirectURL)) {
				paramDN.put("GoogleClientID", googleClientID);
				paramDN.put("GoogleClientKey", googleClientKey);
				paramDN.put("GoogleRedirectURL", googleRedirectURL);
				
				sysDomainSvc.insertDomainGoogleSchedule(paramDN);
			}
			
			returnList.put("result", sysDomainSvc.update(paramDN));
			// 도메인 별 라이선스 정보 저장
			if (licInfoList.size() > 0) {
				paramDN.put("LicInfoList", licInfoList);
				
				sysDomainSvc.saveDoaminLicInfo(paramDN);
			}
			
			
			//라이선스 캐시 초기화
			//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리 
			if(isSaaS.equalsIgnoreCase("N")){
				domainID = "0";
			}
			
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + LicenseHelper.SUF_LIC_INFO);
			instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_CHECK);
			instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_STATE);				
			
			instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_INFO);
			returnList.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * updateIsUseDomain - 도메인 데이터 사용 여부 수정
	 * @param domainID
	 * @param domainCode
	 * @param isUse
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseDomain(
			@RequestParam(value = "DomainID", required = true) String domainID,
			@RequestParam(value = "DomainCode", required = true) String domainCode,
			@RequestParam(value = "IsUse", required = false, defaultValue="Y") String isUse ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			// TODO 날짜의 경우 timezone 적용 할 것
			params.put("DomainID", domainID);
			params.put("DomainCode", domainCode);
			params.put("IsUse", isUse);
			
			returnList.put("result", sysDomainSvc.updateIsUse(params));
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
	 * addDomainInfo - 도메인 정보 추가
	 * @param req
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/addInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addDomainInfo(MultipartHttpServletRequest req, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String domainID = req.getParameter("DomainID");
			String domainCode = req.getParameter("DomainCode");
			String displayName = req.getParameter("DisplayName");
			String multiDisplayName = req.getParameter("MultiDisplayName");
			String domainRepName = req.getParameter("DomainRepName");
			String domainRepTel = req.getParameter("DomainRepTel");
			String domainCorpTel = req.getParameter("DomainCorpTel");
			String domainAddress = req.getParameter("DomainAddress");
			String chargerName = req.getParameter("ChargerName");
			String chargerTel = req.getParameter("ChargerTel");
			String pcLogoPath = req.getParameter("PCLogoPath");
			String mobileLogoPath = req.getParameter("MobileLogoPath");
			String pcLoginPath = req.getParameter("PCLoginPath");
			String portalBannerPaths = req.getParameter("PortalBannerPaths");
			MultipartFile pcLogoFile = req.getFile("PCLogoFile");
			MultipartFile mobileLogoFile = req.getFile("MobileLogoFile");
			MultipartFile pcLoginFile = req.getFile("PCLoginFile");
			List<MultipartFile> portalBannerFileList = req.getFiles("PortalBannerFile");
			
			String isUseGoogleSchedule = req.getParameter("IsUseGoogleSchedule");
			String googleClientID = req.getParameter("GoogleClientID");
			String googleClientKey = req.getParameter("GoogleClientKey");
			String googleRedirectURL = req.getParameter("GoogleRedirectURL");
			String domainBannerLink = req.getParameter("DomainBannerLink");
			String domainThemeCode = req.getParameter("DomainThemeCode");
			
			CoviMap params = new CoviMap();
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", domainCode);
			String rootPath, savePath;
			String domainImagePath = "", domainBannerPath = "";
			
			if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			if(pcLogoFile != null && pcLogoFile.getSize() > 0){
				savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
				long fileSize = pcLogoFile.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = pcLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "PC_Logo." + ext.toLowerCase();
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					pcLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName + ";";
				}else{
					domainImagePath += ";";
				}
			}else if(!pcLogoPath.equals("")){
				domainImagePath += pcLogoPath + ";";
			}else{
				domainImagePath += ";";
			}
			
			if(mobileLogoFile != null && mobileLogoFile.getSize() > 0){
				savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
				long fileSize = mobileLogoFile.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = mobileLogoFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "Mobile_Logo." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					mobileLogoFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName+ ";";
				}
			}else if(!mobileLogoPath.equals("")){
				domainImagePath += mobileLogoPath+ ";";
			}else{
				domainImagePath += ";";
			}
			

			if(pcLoginFile != null && pcLoginFile.getSize() > 0){
				savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("LogoImage_SavePath");
				long fileSize = pcLoginFile.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 본래 파일명
					String originalfileName = pcLoginFile.getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					// 저장되는 파일 이름
					String saveFileName = "PC_Login." + ext;
					savePath += saveFileName; // 저장 될 파일 경로
					
					//한글명저장
					savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
					File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
					
					// 파일 중복 처리
					if(saveFile.exists()){
						if(saveFile.delete()){
							LOGGER.info("file : " + saveFile.toString() + " delete();");
						} else {
							LOGGER.error("Fail on deleteFile() : " + saveFile);
							throw new Exception("deleteFile error.");
						}
					}
					
					pcLoginFile.transferTo(saveFile); // 파일 저장
					domainImagePath += saveFileName+ ";";
				}else{
					domainImagePath += ";";
				}
			}else if(pcLoginPath!= null && !pcLoginPath.equals("")){
				domainImagePath += pcLoginPath+ ";";
			}else{
				domainImagePath += ";";
			}
			
			if(portalBannerFileList.size() != 0){
				int portalBannerCnt = 1;
				String portalBannerPathArr[] = portalBannerPaths.split(";");
				String bannerPath = RedisDataUtil.getBaseConfig("PortalBanner_SavePath");
				savePath = rootPath + backStorage + bannerPath;
				
				if(portalBannerPathArr.length > 0){
					for(int i = 0; i < portalBannerPathArr.length; i++){
						String fileName = portalBannerPathArr[i];
						
						if(!fileName.equals("")) {
							MultipartFile mf = FileUtil.makeMockMultipartFile(bannerPath, "", URLDecoder.decode(fileName, "UTF-8"), fileName);
							portalBannerFileList.add(i, mf);
						}
					}
				}
				
				// 기존 파일 전부 삭제
				File[] files = new File(FileUtil.checkTraversalCharacter(savePath)).listFiles();
				if(files != null && files.length > 0) {
					for(File file : files){
						if(file.exists()){
							if(!file.delete()) {
								LOGGER.debug("Failed to delete file.");
							}
						}
					}
				}
				
				StringBuilder domainBannerPathArr = new StringBuilder();
				for(MultipartFile mf : portalBannerFileList){
					savePath = rootPath + backStorage + bannerPath;
					long fileSize = mf.getSize();
					
					if(fileSize > 0){
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						//폴더가 없을 시 생성
						if(!realUploadDir.exists()){
							if(realUploadDir.mkdirs()){
								LOGGER.info("path : " + realUploadDir + " mkdirs();");
							}
						}
						
						// 본래 파일명
						String originalfileName = mf.getOriginalFilename();
						String ext = FilenameUtils.getExtension(originalfileName);
						
						// 저장되는 파일 이름
						String saveFileName = "PortalBanner_" + portalBannerCnt + "." + ext;
						savePath += saveFileName; // 저장 될 파일 경로
						
						//한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
						File saveFile = new File(FileUtil.checkTraversalCharacter(savePath));
						
						mf.transferTo(saveFile); // 파일 저장
//						domainBannerPath += saveFileName + ";";
						domainBannerPathArr.append(saveFileName).append(";");
					}
					
					portalBannerCnt++;
				}
				domainBannerPath += domainBannerPathArr.toString();
				
				if(!"".equals(domainBannerPath) && domainBannerPath.substring(domainBannerPath.length() - 1, domainBannerPath.length()).equals(";")){
					domainBannerPath = domainBannerPath.substring(0, domainBannerPath.length() - 1);
				}
			}else if(portalBannerPaths != null && !portalBannerPaths.equals("")){
				domainBannerPath = portalBannerPaths;
			}else{
				savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("PortalBanner_SavePath");
				
				// 기존 파일 전부 삭제
				File[] files = new File(FileUtil.checkTraversalCharacter(savePath)).listFiles();
				if (files != null && files.length > 0) {
					for(File file : files) {
						if(!file.delete()) {
							LOGGER.error("Fail on deleteFile() : " + file);
						}
					}
				}
			}
			
			params.put("DomainID", domainID);
			params.put("DomainCode", domainCode);
			params.put("DisplayName", displayName);
			params.put("MultiDisplayName", multiDisplayName);
			params.put("DomainRepName", domainRepName);
			params.put("DomainRepTel", domainRepTel);
			params.put("DomainCorpTel", domainCorpTel);
			params.put("DomainAddress", domainAddress);
			params.put("ChargerName", chargerName);
			params.put("ChargerTel", chargerTel);
			params.put("DomainImagePath", domainImagePath.equals(";") ? "" : domainImagePath);
			params.put("DomainBannerPath", domainBannerPath);
			params.put("IsUseGoogleSchedule", isUseGoogleSchedule);
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("DomainBannerLink", domainBannerLink);
			params.put("DomainThemeCode", domainThemeCode);
			
			if (StringUtil.isNotNull(googleClientID) || StringUtil.isNotNull(googleClientKey) || StringUtil.isNotNull(googleRedirectURL)) {
				params.put("GoogleClientID", googleClientID);
				params.put("GoogleClientKey", googleClientKey);
				params.put("GoogleRedirectURL", googleRedirectURL);
				
				sysDomainSvc.insertDomainGoogleSchedule(params);
			}
			
			returnList.put("result", sysDomainSvc.updateDomainInfo(params));
			returnList.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * selectOneDomain : 하나의 도메인 데이터 바인드
	 * @param domainID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/sendMail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendMail(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			String chargerID = request.getParameter("ChargerID");
			String chargerEmail = request.getParameter("ChargerEmail");
			String domainName = request.getParameter("DomainName");
			String bodyText = makeMailContext(chargerID,domainName);

			CookiesUtil cUtil = new CookiesUtil();
			
			String key = cUtil.getCooiesValue(request);
			
			TokenHelper tokenHelper = new TokenHelper();
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			String decodeKey = tokenHelper.getDecryptToken(key);
			
			Map map = new HashMap();
			
			map = tokenParserHelper.getSSOToken(decodeKey);
			
			LoggerHelper.auditLogger(chargerID, "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", map.get("dnId").toString()), bodyText, "MailAddress");
			Boolean IsSendMail = MessageHelper.getInstance().sendSMTP(map.get("name").toString(), map.get("mail").toString(), chargerEmail, "[" + domainName + "] 그룹웨어 계정 생성 안내 메일", bodyText, true);
			
			if(IsSendMail){
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	@RequestMapping(value = "domain/clearDomain.do")
	public @ResponseBody CoviMap clearDomain(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		instance.removeAll(RedisDataUtil.PRE_LICENSE + "0" + LicenseHelper.SUF_LIC_INFO);
		instance.removeAll(RedisDataUtil.PRE_LICENSE + "0" + "_*" + LicenseHelper.SUF_LIC_INFO);
		instance.removeAll(RedisDataUtil.PRE_LICENSE + "0" + "_*" + LicenseHelper.SUF_LIC_CHECK);
		instance.removeAll(RedisDataUtil.PRE_LICENSE + "0" + "_*" + LicenseHelper.SUF_LIC_STATE);	
		return returnList;
	}
	
	// 도메일 라이선스 목록 조회
	@RequestMapping(value = "domain/getDomainLicenseList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomainLicenseList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try { 
			CoviMap params = new CoviMap();
			
			params.put("domainID", request.getParameter("domainID"));
			params.put("isOpt", request.getParameter("isOpt"));
			
			returnList = sysDomainSvc.selectDomainLicenseList(params);
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
	
	// 도메일 라이선스 목록 조회
	@RequestMapping(value = "domain/getDomainLicAddList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomainLicAddList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try { 
			CoviMap params = new CoviMap();
			
			params.put("domainID", request.getParameter("domainID"));
			params.put("isOpt", request.getParameter("isOpt"));
			
			returnList = sysDomainSvc.selectDomainLicAddList(params);
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
	
	@RequestMapping(value = "domain/decryptLic.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap decryptAPI(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnList = new CoviMap();
		
		try{
			CoviList list = new CoviList(StringUtil.replaceNull(request.getParameter("list")).replaceAll("&quot;", "\""));
			String key = PropertiesUtil.getSecurityProperties().getProperty("sec.pbe.key");
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap map = list.getJSONObject(i);
				String encrypt = map.getString("encrypt").replaceFirst("ENC\\(", "").replaceFirst("(?s)\\)(?!.*?\\))", "");
				
				boolean ret = false;
				String decrypted =  LicenseHelper.getDecryptedProperty(map.getString("encrypt"), request.getParameter("siteUrl"), map.getString("item"));  //PBE.decode(encrypt, key);
				
				if (decrypted.equals(map.getString("text"))) {
					ret = true;
				}
				
				map.put("ret", ret);
				
				list.set(i, map);
			}
			
			returnList.put("result", list.toString());
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	public String makeMailContext(String userID, String companyName){
		String bodyText = "";
		
			bodyText = "<html>";
			bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
				bodyText += "<tbody>";
					bodyText += "<tr>";
						bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#b8bbbd'>";
							bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
										bodyText += "[" + companyName + "] 그룹웨어 계정 생성 안내 메일";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";	
					bodyText += "<tr>";
						bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4; border-bottom: 1px solid #d4d4d4;'>";
							bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
											bodyText += "<div style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">"+companyName+" 그룹웨어의 관리자 계정이 생성되었습니다.</div>";
											bodyText += "<div style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">아이디: "+userID+"</div>";
											bodyText += "<div style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">비밀번호: 1234</div>";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";
				
					bodyText += "<tr>";
						bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
						bodyText += "</td>";
					bodyText += "</tr>";	
				bodyText += "</tbody>";
			bodyText += "</table>";
		bodyText += "</html>";
		
		return bodyText;
	}
	
	public Boolean insertAdminUser(CoviMap paramDN) throws Exception{
		CoviMap params = new CoviMap();
		String strJobPositionCode = "";
		String stroldJobPositionCode = "";
		String strJobTitleCode = "";
		String stroldJobTitleCode = "";
		String strJobLevelCode = "";
		String stroldJobLevelCode = "";
		String strUserCode = paramDN.getString("ChargerID");
		String strDeptCode = paramDN.getString("DomainID") + "_RetireDept";
		String strRegistDate = paramDN.getString("RegistDate");
		
		params.put("ObjectCode", strUserCode);
		params.put("ObjectType", "UR");
		params.put("IsSync", "N");
		params.put("SyncManage", "Manage");
		
		params.put("UserCode", strUserCode);
		params.put("LogonID", strUserCode);
		params.put("LogonPassword", "1234");
		params.put("DecLogonPassword", "1234");
		params.put("EmpNo", strUserCode);
		params.put("DisplayName", paramDN.getString("ChargerName"));
		params.put("MultiDisplayName", paramDN.getString("ChargerName") + ";;;;;;;;;;");
		params.put("Mobile", paramDN.getString("ChargerTel"));
		params.put("SortKey", "0");
		params.put("SecurityLevel", "0");
		params.put("IsUse", "Y");
		params.put("IsHR", "N");
		params.put("IsDisplay", "Y");
		params.put("EnterDate", StringUtil.getNowDate("yyyy-MM-dd"));
		params.put("UseMailConnect", "N");
		params.put("MailAddress", strUserCode + "@" + paramDN.getString("Domain"));
		params.put("ExternalMailAddress", paramDN.getString("ChargerEmail"));
		params.put("LanguageCode", SessionHelper.getSession("lang"));
		params.put("MobileThemeCode", "MobileTheme_Base");
		params.put("TimeZoneCode", "TIMEZO0048");
		params.put("RegistDate", strRegistDate);
		
		params.put("JobType", "Origin");
		params.put("BaseGroupSortKey", "0");
		params.put("CompanyCode", paramDN.getString("DomainCode"));
		params.put("CompanyName", paramDN.getString("DomainName"));
		params.put("DeptCode", strDeptCode);
		params.put("oldDeptCode", "");
		params.put("oldCompanyCode", "");
		params.put("DeptName", "퇴직부서");
		
		params.put("UseDeputy", "N");
		params.put("AlertConfig", "{\"mailconfig\":{\"APPROVAL\":\"N;\",\"COMPLETE\":\"N;\",\"REJECT\":\"N;\",\"CCINFO\":\"N;\",\"CIRCULATION\":\"N;\",\"HOLD\":\"N;\",\"WITHDRAW\":\"N;\",\"ABORT\":\"N;\",\"APPROVECANCEL\":\"N;\",\"REDRAFT\":\"N;\",\"CHARGEJOB\":\"N;\"}}");
		
		params.put("SyncType", "INSERT");
		params.put("mailStatus", "A");
		int ireturn = orgSyncManageSvc.insertUser(params);
		if(ireturn < 1) {
			throw new Exception("Object Error!");
		}
		
		//인디메일 사용자 추가
		try {
			CoviMap reObject = null;
			if(orgSyncManageSvc.getIndiSyncTF()) {
				reObject = orgSyncManageSvc.getUserStatus(params);
				if(reObject.has("returnCode") && reObject.has("result")){
					if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
						try {
							reObject = orgSyncManageSvc.modifyUser(params);
							if(!reObject.get("returnCode").toString().equals("0")) {
								throw new Exception(" [메일] " + reObject.get("returnMsg"));
							} else {
								if(!(strJobPositionCode.equals("") || strJobPositionCode == null || strJobPositionCode.equalsIgnoreCase("undefined")) 
										|| !(stroldJobPositionCode.equals("") || stroldJobPositionCode == null || stroldJobPositionCode.equalsIgnoreCase("undefined"))) {
									params.put("DeptCode", !strJobPositionCode.equalsIgnoreCase("undefined") ? strJobPositionCode : "");
									params.put("oldDeptCode", !stroldJobPositionCode.equalsIgnoreCase("undefined") ? stroldJobPositionCode : "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strJobTitleCode.equals("") || strJobTitleCode == null || strJobTitleCode.equalsIgnoreCase("undefined")) 
										|| !(stroldJobTitleCode.equals("") || stroldJobTitleCode == null || stroldJobTitleCode.equalsIgnoreCase("undefined"))) {
									params.put("DeptCode", !strJobTitleCode.equalsIgnoreCase("undefined") ? strJobTitleCode : "");
									params.put("oldDeptCode", !stroldJobTitleCode.equalsIgnoreCase("undefined") ? stroldJobTitleCode : "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strJobLevelCode.equals("") || strJobLevelCode == null || strJobLevelCode.equalsIgnoreCase("undefined")) 
										|| !(stroldJobLevelCode.equals("") || stroldJobLevelCode == null || stroldJobLevelCode.equalsIgnoreCase("undefined"))) {
									params.put("DeptCode", !strJobLevelCode.equalsIgnoreCase("undefined") ? strJobLevelCode : "");
									params.put("oldDeptCode", !stroldJobLevelCode.equalsIgnoreCase("undefined") ? stroldJobLevelCode : "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
						} catch (NullPointerException e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						} catch (Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
					}else if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("-1")) { //응답코드0:성공  result-1:계정없음
						try {
							reObject = orgSyncManageSvc.addUser(params);
							if(!reObject.get("returnCode").toString().equals("1")) {
								throw new Exception(" [메일] " + reObject.get("returnMsg"));
							} else {
								if(!strJobPositionCode.equals("") || strJobPositionCode != null) {
									params.put("DeptCode", strJobPositionCode != null && !strJobPositionCode.equalsIgnoreCase("undefined") ? strJobPositionCode : "");
									params.put("oldDeptCode", "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));										
								}
								if(!strJobTitleCode.equals("") || strJobTitleCode!= null) {
									params.put("DeptCode", strJobTitleCode != null && !strJobTitleCode.equalsIgnoreCase("undefined") ? strJobTitleCode : "");
									params.put("oldDeptCode", "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
								}
								if(!strJobLevelCode.equals("") || strJobLevelCode != null) {
									params.put("DeptCode", strJobLevelCode != null && !strJobLevelCode.equalsIgnoreCase("undefined") ? strJobLevelCode : "");
									params.put("oldDeptCode", "");
									reObject = orgSyncManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
								}
							}
						} catch (NullPointerException e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						} catch (Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
					}
				}
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}

		return true;
	}
	
	public void insertDomainFolder(CoviMap paramDN) throws Exception{
		CoviMap params = new CoviMap();
		String domainID = paramDN.getString("DomainID");
		String domainCode = paramDN.getString("DomainCode");
		String ChargerID = paramDN.getString("ChargerID");
		
		params.put("UserCode", ChargerID);
		params.put("DomainID", domainID);
		params.put("DomainCode", domainCode);
		
		// 회사 일정
		params.put("ObjectType", "Schedule");
		params.put("FolderType", "Schedule");
		params.put("ManageCompany", domainID);

		sysDomainSvc.insertDomainFolder(params);
		
		params.put("ManageCompany", "");
		
		// 자원예약 Root
		params.put("ObjectType", "Resource");
		params.put("FolderType", "Root");
		
		sysDomainSvc.insertDomainFolder(params);
		
		// 통합게시 Root
		params.put("OwnerCode", ChargerID + ";");
		params.put("ObjectType", "Board");
		params.put("FolderType", "Root");
		
		sysDomainSvc.insertDomainFolder(params);
		
		// 문서관리 Root
		params.put("ObjectType", "Doc");
		params.put("FolderType", "Root");
		
		sysDomainSvc.insertDomainFolder(params);
	}
	
	public boolean sendMailApi(CoviMap params) {
		boolean bReturn = false;
		String apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL");
		String method = "POST";
		
		try
		{
			//도메인 연동
			String sendParam = apiURL+
					"?job=domainModify"+
					"&domain="+java.net.URLEncoder.encode(params.get("MailDomain").toString(), java.nio.charset.StandardCharsets.UTF_8.toString())+
					"&name="+java.net.URLEncoder.encode(params.get("DisplayName").toString(), java.nio.charset.StandardCharsets.UTF_8.toString())+
					"&status=1";
			
			CoviMap jObj = orgSyncManageSvc.getJson(sendParam, method);
			LOGGER.debug( "sendMailApi ==> sendParam:"+sendParam+", return:" + jObj.toString() );
			//메일 사용자 추가
			if(jObj.get("returnCode").toString().equals("0")) {
				CoviMap mailParams = new CoviMap();
				mailParams.put("UserCode",params.get("DomainCode").toString()+"_"+params.get("ChargerID").toString());
				mailParams.put("LogonID", params.get("ChargerID").toString()+"@"+params.get("MailDomain"));
				mailParams.put("DisplayName", params.get("DisplayName").toString());
				mailParams.put("CompanyCode", params.get("DomainCode").toString());
				mailParams.put("LanguageCode", "ko");
				mailParams.put("TimeZoneCode", "GMT+9");
				mailParams.put("MailAddress", params.get("ChargerEmail").toString());
				
				String sNewPassword = "";
				if(!RedisDataUtil.getBaseConfig("InitPassword").equals("")) {
					sNewPassword = RedisDataUtil.getBaseConfig("InitPassword");
				}
				
				mailParams.put("DecLogonPassword",sNewPassword);
				mailParams.put("GroupMailAddress","");
				mailParams.put("DeptCode","");
				mailParams.put("DeptName","");
				
				CoviMap jUserObj = orgSyncManageSvc.addUser(mailParams);
			}	
				
			/*그룹연동
			sendParam = apiURL+
					"?job=addGroup"+
					"&id="+java.net.URLEncoder.encode(params.get("GroupCode").toString(), java.nio.charset.StandardCharsets.UTF_8.toString())+
					"&name="+java.net.URLEncoder.encode(params.get("DisplayName").toString(), java.nio.charset.StandardCharsets.UTF_8.toString())+
					"&enc=0"+
					"&deptId="+java.net.URLEncoder.encode(params.get("MemberOf").toString(), java.nio.charset.StandardCharsets.UTF_8.toString())+
					"&status=A"+
					"&domain="+java.net.URLEncoder.encode(params.get("MailDomain").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
			
			jObj = orgSyncManageSvc.getJson(sendParam, method);
			*/
		} catch (UnsupportedEncodingException ex) {
			LOGGER.error("addGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		} catch(Exception ex) {
			LOGGER.error("addGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		}
		return bReturn;
	}

	/**
	 * deleteDomainLic - 도메인에 연결된 라이선스 삭제(Table : sys_object_domain_license).
	 * @parameters request
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/deleteDomainLic.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteDomainLic(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String domainID = request.getParameter("domainID");
			String licSeq = request.getParameter("LicSeq");
			
			if (StringUtil.isNotEmpty(domainID) && StringUtil.isNotEmpty(licSeq)) {
				params.put("DomainID", domainID);
				
				String[] arrLicSeq = licSeq.split(";");
				for (String el : arrLicSeq) {
					if (StringUtil.isNotEmpty(el)) {
						params.put("licSeq", el);
						sysDomainSvc.deleteDomainLic(params);
					}
				}
			}
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
}
