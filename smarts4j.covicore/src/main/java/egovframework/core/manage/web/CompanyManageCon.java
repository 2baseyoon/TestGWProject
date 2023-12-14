package egovframework.core.manage.web;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.output.FileWriterWithEncoding;
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

import egovframework.core.sevice.LicenseSvc;
import egovframework.core.sevice.SysBaseConfigSvc;
import egovframework.core.sevice.SysDomainSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

import org.codehaus.jackson.map.ObjectMapper;

/**
 * @Class Name : MenuCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2017.06.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("manage")
public class CompanyManageCon {

	private Logger LOGGER = LogManager.getLogger(this);
	
	@Autowired
	private SysDomainSvc sysDomainSvc;

	@Autowired
	private LicenseSvc licenseSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private SysBaseConfigSvc sysBaseConfigSvc;
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "domain/getCompanyInfo.do")
	public @ResponseBody CoviMap getCompanyInfo(
			HttpServletRequest request,
			@RequestParam(value = "DomainID", required = true, defaultValue = "1") String domainID) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("DomainID", domainID);
			
			CoviMap resultList = sysDomainSvc.selectOne(params);
			CoviList licenseInfo = ComUtils.getLicenseInfo(domainID);

			CoviMap map = (CoviMap)((CoviList)resultList.get("map")).get(0);
			returnList.put("map", map);
			returnList.put("licenseList",licenseInfo);
			returnList.put("vacationPolicy", getVacaionPolicy(request, map.getString("DomainCode")));
			returnList.put("status", Return.SUCCESS);
		} 
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
	
	

	
	private String getVacationFile(String domainCode, boolean bMake){
		String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		String filePath;
		String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", domainCode);
		String rootPath;
		if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
		else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
		
		filePath= rootPath + backStorage + "template";
		
		//디렉토리가 없으면 생성
		if (bMake){
			File fileDir = new File(filePath);
			if(!fileDir.isDirectory() && !fileDir.mkdirs()) {
				LOGGER.debug("Failed to make directories.");
			}
		}
		return filePath+ "/VacationPolicy.html";
	}
	private String getVacaionPolicy(HttpServletRequest request, String domainCode){
		String lineSeparator = System.getProperty("line.separator");
		StringBuffer result = new StringBuffer();
		
		String filePath = "";
		if (domainCode.equals("")){
			filePath = request.getSession().getServletContext().getRealPath("WEB-INF//views//manage//system//VacationPolicy.html");

		}else{
			filePath = getVacationFile(domainCode, false);
		}
		File file = new File(filePath);
		
		if(filePath.isEmpty() || !file.exists() ){
			return "";
		}
		try (
				InputStream fis = new FileInputStream(filePath);
				BufferedReader br = new BufferedReader(new InputStreamReader(fis, "UTF8"));
				){
			StringBuilder builder = new StringBuilder();
			String sCurrentLine;
			
			while ((sCurrentLine = br.readLine()) != null) {
				builder.append(sCurrentLine + lineSeparator);
			}
			String text = builder.toString();
			Pattern p = Pattern.compile("<spring:message[^>]*code=[\"']?([^>\"']+)[\"']?[^>]*(/>|></spring>|></spring:message>)");
			Matcher m = p.matcher(text);
			
			result = new StringBuffer(text.length());
			while(m.find()){
				String key = m.group(1).replace("Cache.", "");
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, DicHelper.getDic(key));
			}
			m.appendTail(result);
		}
		catch(FileNotFoundException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		}
		catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		}
		catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		}
		
		return result.toString();
	}
	
	@RequestMapping(value = "domain/loadTemplate.do")
	public @ResponseBody CoviMap loadTemplate(HttpServletRequest request) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			returnList.put("vacationPolicy", getVacaionPolicy(request, ""));
			returnList.put("status", Return.SUCCESS);
		} 
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
	
	@RequestMapping(value = "domain/saveCompanyVac.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCompanyVac(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String domainID = request.getParameter("DomainID");
		String domainCode = request.getParameter("DomainCode");
		String vacationPolicy = request.getParameter("body");
		try {
			String filePath = getVacationFile(domainCode, true);
			
			File file = new File(filePath);
			if(!file.exists()){ // 파일이 존재하지 않으면 
				if(!file.createNewFile()) {// 신규생성
					 LOGGER.warn("Fail to create file [" + filePath + "]");
				}
			} 
			else{
				File newfile = new File(filePath+"_back");
				if(!file.renameTo(newfile)) {
					LOGGER.warn("Fail to rename file [" + newfile.getAbsolutePath() + "]");
				}
			}
			
			CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "BodyForm");  //BizSection
		    editorParam.put("imgInfo", request.getParameter("bodyInlineImage"));
		    editorParam.put("backgroundImage", request.getParameter("bodyBackgroundImage"));
		    editorParam.put("objectID", "0");     
		    editorParam.put("objectType", "VAC");   
		    editorParam.put("messageID", "0");  
		    editorParam.put("frontStorageURL", RedisDataUtil.getBaseConfig("CommonGWServerURL") + RedisDataUtil.getBaseConfig("FrontStorage"));
			editorParam.putOrigin("bodyHtml", URLDecoder.decode(request.getParameter("body"),"utf-8"));
			if (!StringUtil.replaceNull(editorParam.get("imgInfo"),"").equals("") || !StringUtil.replaceNull(editorParam.get("backgroundImage"),"").equals("")){
			    CoviMap editorInfo = editorService.getInlineValue(editorParam);
			    vacationPolicy =editorInfo.getString("BodyHtml");
			}
			
			try(BufferedWriter writer = new BufferedWriter(new FileWriterWithEncoding(file, StandardCharsets.UTF_8, false))) {
				writer.write(URLDecoder.decode((vacationPolicy),"utf-8")); 
			}
			
			CoviMap exObj = new CoviMap();
			exObj.put("BizSection", "Vacation");
			exObj.put("SettingKey", "vactionPolicyPath");
			exObj.put("SettingValue", filePath);
			exObj.put("ConfigType", "System");
			exObj.put("ConfigName", "휴가 규정파일경로");
			exObj.put("Description", "휴가 규정파일경로");
			exObj.put("IsCheck", "Y");
			exObj.put("IsUse", "Y");
			
			exObj.put("DN_ID", domainID);
			exObj.put("RegID", SessionHelper.getSession("USERID"));
			exObj.put("ModID", SessionHelper.getSession("USERID"));
			
			sysBaseConfigSvc.insertMerge(exObj);

			ObjectMapper mapperObj = new ObjectMapper();
			String jsonResp = mapperObj.writeValueAsString(exObj);
			RedisDataUtil.setBaseConfig("vactionPolicyPath", domainID, jsonResp);
			returnList.put("status", Return.SUCCESS);

		} 
		catch(IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/* saveCompanyInfo - 도메인 정보 수정
	 * @param req
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/saveCompanyInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCompanyInfo(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String domainID = request.getParameter("DomainID");
			String domainCode = request.getParameter("DomainCode");
			String displayName = request.getParameter("DisplayName");
			String multiDisplayName = request.getParameter("MultiDisplayName");
			String domainRepName = request.getParameter("DomainRepName");
			String domainRepTel = request.getParameter("DomainRepTel");
			String domainCorpTel = request.getParameter("DomainCorpTel");
			String domainAddress = request.getParameter("DomainAddress");
			String chargerName = request.getParameter("ChargerName");
			String chargerTel = request.getParameter("ChargerTel");

			String isUseGoogleSchedule = request.getParameter("IsUseGoogleSchedule");
			String googleClientID = request.getParameter("GoogleClientID");
			String googleClientKey = request.getParameter("GoogleClientKey");
			String googleRedirectURL = request.getParameter("GoogleRedirectURL");
			String domainBannerLink = request.getParameter("DomainBannerLink");
			String domainThemeCode = request.getParameter("DomainThemeCode");
			
			CoviMap params = new CoviMap();
			
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
			params.put("IsUseGoogleSchedule", isUseGoogleSchedule);
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			
			if (StringUtil.isNotNull(googleClientID) || StringUtil.isNotNull(googleClientKey) || StringUtil.isNotNull(googleRedirectURL)) {
				params.put("GoogleClientID", googleClientID);
				params.put("GoogleClientKey", googleClientKey);
				params.put("GoogleRedirectURL", googleRedirectURL);
				
				sysDomainSvc.insertDomainGoogleSchedule(params);
			}
			
			returnList.put("result", sysDomainSvc.updateDomainInfoDesign(params));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	 /* addDomainInfo - 도메인 정보 추가
	 * @param req
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "domain/saveCompanyDesign.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCompanyDesign(MultipartHttpServletRequest req, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String domainID = req.getParameter("DomainID");
			String domainCode = req.getParameter("DomainCode");
			String pcLogoPath1 = req.getParameter("PCLogoPath1");
			String pcLogoPath2 = req.getParameter("PCLogoPath2");
			String mobileLogoPath1 = req.getParameter("MobileLogoPath1");
			String mobileLogoPath2 = req.getParameter("MobileLogoPath2");
			String pcLoginPath = req.getParameter("PCLoginPath");
			String portalBannerPaths = req.getParameter("PortalBannerPaths");
			String contentsBannerPaths = req.getParameter("ContentsBannerPaths");
			
			MultipartFile pcLogoFile1 = req.getFile("PCLogoFile1");
			MultipartFile pcLogoFile2 = req.getFile("PCLogoFile2");
			
			MultipartFile mobileLogoFile1 = req.getFile("MobileLogoFile1");
			MultipartFile mobileLogoFile2 = req.getFile("MobileLogoFile2");
			
			MultipartFile pcLoginFile = req.getFile("PCLoginFile");
//			List<MultipartFile> portalBannerFileList = req.getFiles("PortalBannerFile");
			
			String portalBannerLink = req.getParameter("PortalBannerLink");
			String contentsBannerLink = req.getParameter("ContentsBannerLink");
			
			String domainThemeCode = req.getParameter("DomainThemeCode");
			
			CoviMap params = new CoviMap();
			String saveFileName="";
			StringBuffer domainImagePath = new StringBuffer();
			StringBuffer domainBannerPath = new StringBuffer();
			
			//PC 로고1
			if(pcLogoFile1 == null) {
				domainImagePath.append(pcLogoPath1);
			} else {
				saveFileName = saveImageFile(domainCode, pcLogoFile1,  RedisDataUtil.getBaseConfig("LogoImage_SavePath"), "PC_Logo1", true);
				domainImagePath.append(saveFileName + ";");
			}
			
			//모바일 로고1
			if(mobileLogoFile1 == null) {
				domainImagePath.append(mobileLogoPath1);
			} else {
				saveFileName = saveImageFile(domainCode, mobileLogoFile1,  RedisDataUtil.getBaseConfig("LogoImage_SavePath"), "Mobile_Logo1", true);
				domainImagePath.append(saveFileName + ";");
			}
			
			//로그인 파일
			if(pcLoginFile != null && pcLoginFile.getSize() > 0){
				saveFileName = saveImageFile(domainCode, pcLoginFile, RedisDataUtil.getBaseConfig("LogoImage_SavePath"), "PC_Login", false);
				domainImagePath.append(saveFileName).append(";");
			}else if(pcLoginPath!= null && !pcLoginPath.equals("")){
				domainImagePath.append(pcLoginPath).append(";");
			}else{
				domainImagePath.append(";");
			}
			
			//PC 로고2
			if(pcLogoFile2 == null) {
				domainImagePath.append(pcLogoPath2);
			} else {
				saveFileName = saveImageFile(domainCode, pcLogoFile2,  RedisDataUtil.getBaseConfig("LogoImage_SavePath"), "PC_Logo2", true);
				domainImagePath.append(saveFileName + ";");
			}
			
			//모바일 로고2
			if(mobileLogoFile2 == null) {
				domainImagePath.append(mobileLogoPath2);
			} else {
				saveFileName = saveImageFile(domainCode, mobileLogoFile2,  RedisDataUtil.getBaseConfig("LogoImage_SavePath"), "Mobile_Logo2", true);
				domainImagePath.append(saveFileName + ";");
			}

			//배너
			String portalBannerPathArr[] = portalBannerPaths.split(";",-1);
			for (int i=0; i < portalBannerPathArr.length; i++){
				MultipartFile portalBannerFileList = req.getFile("PortalBannerFile_"+i);

				if(portalBannerFileList != null && portalBannerFileList.getSize() > 0){	//신규파일
					saveFileName = saveImageFile(domainCode, portalBannerFileList, RedisDataUtil.getBaseConfig("PortalBanner_SavePath"), "PB_" +UUID.randomUUID().toString().replace("-", ""), true);
					domainBannerPath.append(saveFileName).append(";");
				}else if(portalBannerPathArr[i]!= null && !portalBannerPathArr[i].equals("")){//기존파일
					domainBannerPath.append(portalBannerPathArr[i]).append(";");
				}else{
					domainBannerPath.append(";");
				}	
			}
			
			domainBannerPath.append("|");
			
			String contentsBannerPathArr[] = contentsBannerPaths.split(";",-1);
			for (int i=0; i < contentsBannerPathArr.length; i++){
				MultipartFile contentsBannerFileList = req.getFile("ContentsBannerFile_"+i);
				
				if(contentsBannerFileList != null && contentsBannerFileList.getSize() > 0){	//신규파일
					saveFileName = saveImageFile(domainCode, contentsBannerFileList, RedisDataUtil.getBaseConfig("PortalBanner_SavePath"), "ContentsBanner_" + i, true);
					domainBannerPath.append(saveFileName).append(";");
				}else if(contentsBannerPathArr[i]!= null && !contentsBannerPathArr[i].equals("")){//기존파일
					domainBannerPath.append(contentsBannerPathArr[i]).append(";");
				}else{
					domainBannerPath.append(";");
				}
			}
			
			params.put("DomainID", domainID);
			params.put("DomainCode", domainCode);
			params.put("DomainImagePath", domainImagePath.toString().equals(";") ? "" : domainImagePath.toString());
			params.put("DomainBannerPath", domainBannerPath.toString());
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("DomainBannerLink", portalBannerLink + "|" + contentsBannerLink);
			params.put("DomainThemeCode", domainThemeCode);

			params.put("DESIGN","Y");
			returnList.put("result", sysDomainSvc.updateDomainInfoDesign(params));
			
			returnList.put("status", Return.SUCCESS);
		}
		catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	private String saveImageFile(String domainCode, MultipartFile imgFile,  String savePath, String saveFileName, boolean addExt){
		String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", domainCode);
		String rootPath;
		if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
		else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
		
		savePath = rootPath + backStorage + savePath;
		
		long fileSize = imgFile.getSize();
		String retFileName="";
		try{
			if(fileSize > 0){
				File realUploadDir = new File(savePath);
				//폴더가없을 시 생성
				if(!realUploadDir.exists()){
					if(realUploadDir.mkdirs()){
						LOGGER.info("path : " + realUploadDir + " mkdirs();");
					}
				}
				
				// 본래 파일명
				String originalfileName = imgFile.getOriginalFilename();
				String ext = FilenameUtils.getExtension(originalfileName);
				
				if (addExt == true) saveFileName += "."+ext.toLowerCase();
				
				// 저장되는 파일 이름
				savePath += saveFileName; // 저장 될 파일 경로
				
				//한글명저장
				savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
				File saveFile = new File(savePath);
				
				// 파일 중복 처리
				if(saveFile.exists()){
					if(saveFile.delete()){
						LOGGER.info("file : " + saveFile.toString() + " delete();");
					} else {
						LOGGER.error("Fail on deleteFile() : " + saveFile);
						throw new Exception("deleteFile error.");
					}
				}
				
				imgFile.transferTo(saveFile); // 파일 저장
				retFileName = saveFileName;
			}
		} 
		catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return retFileName;
	}
	
	// 라이선스 사용자 관리, 라이선스 정보 불러오기.
	@RequestMapping(value = "domain/getLicenseInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseInfo(
			HttpServletRequest request,
			@RequestParam(value = "domainId", required = true, defaultValue = "1") String domainId
			) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("domainID", domainId);
			
			CoviList licenseInfo = ComUtils.getLicenseInfo(domainId);
			
			returnList.put("list",licenseInfo);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 라이선스 사용자 관리, 사용자 정보 불러오기.
	@RequestMapping(value = "domain/getUserInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserInfo(
			HttpServletRequest request
			, @RequestParam(value = "licSeq", required = true) String licSeq
			, @RequestParam(value = "isOpt", required = true) String isOpt
			, @RequestParam(value = "lang", required = false, defaultValue = "ko") String lang
			, @RequestParam(value = "category", required = false, defaultValue = "name") String category
			, @RequestParam(value = "searchText", required = false, defaultValue = "") String searchText
			, @RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo
			, @RequestParam(value = "domainId", required = true) String domainId
			) throws Exception {
			
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licSeq", licSeq);
			params.put("isOpt", isOpt);
			params.put("lang", lang);
			params.put("category", category);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("pageNo", pageNo);
			
			//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
			params.put("isSaaS", isSaaS);
			if (!isSaaS.equalsIgnoreCase("Y")) {
				params.put("domainId", "0");
			}
			params.put("domainId", domainId);
			
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"));
			params.put("pageSize", pageSize);

			String sortColumn = request.getParameter("sortBy") != null ? request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!= null? request.getParameter("sortBy").split(" ")[1]:"";
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap userInfo = licenseSvc.getUserInfo(params);
			returnList.put("page", userInfo.get("page"));
			returnList.put("list", userInfo.get("list"));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 라이선스 사용자 추가 팝업
	@RequestMapping(value = "/domain/LicenseUserManagePopup.do", method = RequestMethod.GET)
	public ModelAndView licenseUserManagePopup(HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("/manage/system/LicenseUserManagePopup");
		return mav;
	}
	
	// 라이선스 추가 사용자 조회
	@RequestMapping(value = "domain/getLicenseAddUser.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseAddUser(HttpServletRequest request,
			@RequestParam(value = "domainId", required = true) String domainId,
			@RequestParam(value = "licSeq", required = true) String licSeq,
			@RequestParam(value = "lang", required = false, defaultValue = "ko") String lang,
			@RequestParam(value = "category", required = false, defaultValue = "name") String category,
			@RequestParam(value = "searchText", required = false, defaultValue = "") String searchText,
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		params.put("domainId", domainId);
		params.put("licSeq", licSeq);
		params.put("lang", lang);
		params.put("category", category);
		params.put("searchText", searchText);
		params.put("pageNo", pageNo);
		
		String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"));
		params.put("pageSize", pageSize);

		try {
			CoviMap userInfo = licenseSvc.getLicenseAddUser(params);
			returnList.put("page", userInfo.get("page"));
			returnList.put("list", userInfo.get("list"));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 라이선스 부여하기
	@RequestMapping(value = "domain/grantLicense.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap grantLicense(HttpServletRequest request,
			@RequestParam(value = "list", required = true) String paramList,
			@RequestParam(value = "licSeq", required = true) String licSeq,
			@RequestParam(value = "domainId", required = true) String domainId
			) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		params.put("licSeq", licSeq);
		params.put("domainId", domainId);
		params.put("registerCode", SessionHelper.getSession("USERID"));
		
		String userCode = paramList;
		String[] arrUserCode = userCode.split(",");
		
		List<String> arrayList = new ArrayList<>();
		for (String item : arrUserCode) {
			arrayList.add(item);
		}
		
		try {
			int resultCnt = 0;
			for(int i=0; i<arrayList.size(); i++){
				params.put("userCode", arrayList.get(i));
				resultCnt += licenseSvc.insertUserLicense(params);
			}
			returnList.put("cnt", resultCnt);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 부가라이선스, 개인별 라이선스 삭제. deleteUserLicense.do
	@RequestMapping(value = "domain/deleteUserLicense.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserLicense(HttpServletRequest request
			, @RequestParam(value = "list", required = true) String list
			) throws Exception {
		
		CoviList paramList = new CoviList();
		CoviMap returnList = new CoviMap();

		try {
			int resultCnt = 0;
			String[] arrStr1 = list.split(",");
			for (int i=0;arrStr1.length>i;i++) {
				CoviMap paramMap = new CoviMap();
				
				String[] arrStr2 = arrStr1[i].split(":");
				for(int j=0;arrStr2.length>j;j++) {
					paramMap.put("UserCode", arrStr2[0]);
					paramMap.put("LicSeq", arrStr2[1]);
					paramMap.put("DomainID", arrStr2[2]);
				}

				resultCnt += licenseSvc.deleteUserLicense(paramMap);
			}

			returnList.put("cnt", resultCnt);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
}
