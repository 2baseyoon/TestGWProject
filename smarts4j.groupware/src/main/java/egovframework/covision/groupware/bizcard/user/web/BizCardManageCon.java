package egovframework.covision.groupware.bizcard.user.web;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.s3.AwsS3;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
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
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;
import egovframework.covision.groupware.bizcard.user.service.BizCardListService;
import egovframework.covision.groupware.bizcard.user.service.BizCardManageService;
import ezvcard.Ezvcard;
import ezvcard.VCard;


/**
 * @Class Name : BizCardManageCon.java
 * @Description : 인명관리 연락처 CRUD 처리
 * @Modification Information
 * @ 2017.08.01 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2017.08.01
 * @version 1.0
 * Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizcard")
public class BizCardManageCon {
	@Autowired
	private BizCardManageService bizCardManageService;
	@Autowired
	private BizCardGroupManageService bizCardGroupManageService;
	@Autowired
	private BizCardListService bizCardListService;
	
	private static Logger LOGGER = LogManager.getLogger(BizCardManageCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	static AwsS3 awsS3 = AwsS3.getInstance();
	//페이지 이동	
	@RequestMapping(value="ModifyBizCardPersonPop.do", method=RequestMethod.GET)
	public ModelAndView ModifyBizCardPersonPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strTypeCode = request.getParameter("TypeCode");
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCard";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("TypeCode", strTypeCode);
		mav.addObject("BizCardID", strBizCardID);
		mav.addObject("UR_Code", strUR_Code);
		mav.addObject("mode", "modifyPopup");
		mav.addObject("style", "display: none;");
		
		return mav;
	}
	
	@RequestMapping(value="ModifyBizCard.do", method=RequestMethod.GET)
	public ModelAndView ModifyBizCard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strTypeCode = request.getParameter("TypeCode");
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "bizcard/CreateBizCard.user.content";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("TypeCode", strTypeCode);
		mav.addObject("BizCardID", strBizCardID);
		mav.addObject("UR_Code", strUR_Code);
		mav.addObject("mode", "modify");
		
		return mav;
	}
	
	@RequestMapping(value="ViewBizCardPerson.do", method=RequestMethod.GET)
	public ModelAndView ViewBizCardPerson(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("ShareType");
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/ViewBizCardPerson";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("BizCardID", strBizCardID);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="ViewBizCardCompany.do", method=RequestMethod.GET)
	public ModelAndView ViewBizCardCompany(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("ShareType");
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/ViewBizCardCompany";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("BizCardID", strBizCardID);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="SearchBizCardCompanyPop.do", method=RequestMethod.GET)
	public ModelAndView SearchBizCardCompanyPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnUrl = "user/bizcard/SearchBizCardCompanyPop";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		return mav;
	}
	
	@RequestMapping(value="GoToRegistBizCardCompany.do", method=RequestMethod.GET)
	public ModelAndView GoToRegistBizCardCompany(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCard";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("TypeCode", 'C');
		mav.addObject("mode", "search");
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="OrganizeBizCard.do", method=RequestMethod.GET)
	public ModelAndView OrganizeBizCard(HttpServletRequest request, HttpServletResponse response) throws Exception{

		String strUR_Code = SessionHelper.getSession("UR_Code");
		String returnUrl = "/groupware/bizcard/OrganizeBizCard";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	//명함 관리(등록, 수정, 조회)
	@RequestMapping(value="RegistBizCardPerson.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap RegistBizCardPerson(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = StringUtil.replaceNull(req.getParameter("TypeCode"), "");
			String strShareType = req.getParameter("ShareType");
			String strGroupID = req.getParameter("GroupID");
			String strGroupName = req.getParameter("GroupName");
			String strName = req.getParameter("Name");
			String strMessengerID = req.getParameter("MessengerID");
			String strCompanyID = req.getParameter("CompanyID");
			String strCompanyName = req.getParameter("CompanyName");
			String strJobTitle = req.getParameter("JobTitle");
			String strDeptName = req.getParameter("DeptName");
			String strMemo = req.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(req.getParameter("ImagePath"), "");
			String strPhoneType = req.getParameter("PhoneType");
			String strPhoneNumber = StringUtil.replaceNull(req.getParameter("PhoneNumber"), "");
			String strPhoneName = StringUtil.replaceNull(req.getParameter("PhoneName"), "");
			String strEmail = StringUtil.replaceNull(req.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(req.getParameter("AnniversaryText"), "");
			String strBizCardID = "";
			
			// 값이 비어있을경우 NULL 값으로 전달	
			strGroupID = strGroupID.isEmpty() ? null : strGroupID; 
			strGroupName = strGroupName.isEmpty() ? null : strGroupName; 
			
			if(strGroupID != null){
				if(strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();
					
					paramGroup.put("ShareType", strShareType);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);
					
					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if(!"OK".equals(obj.getString("result"))) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}			
			
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", strUR_Code);
			params.put("UR_Name", strUR_Name);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			params.put("ShareType", strShareType);
			params.put("GroupID", strGroupID);
			params.put("Name", strName);
			params.put("MessengerID", strMessengerID);
			params.put("CompanyID", strCompanyID);
			params.put("CompanyName", strCompanyName);
			params.put("JobTitle", strJobTitle);
			params.put("DeptName", strDeptName);
			params.put("Memo", strMemo);
			params.put("ImagePath", strImagePath);
			
			returnObj = bizCardManageService.insertBizCardPerson(params);
			if(!"OK".equals(returnObj.getString("result"))) {
				return returnObj;
			}
			strBizCardID = params.getString("BizCardID");
			
			if(!strImagePath.equals("")) {			
				MultipartFile FileInfo = req.getFile("FileInfo");

				String filePath;
				String rootPath;
				//System.out.println("[AWS S3]awsS3.getS3Active():"+awsS3.getS3Active());
				if(awsS3.getS3Active(strDN_Code)){
					rootPath = FileUtil.getBackPath(strDN_Code);
				}else {
					String OsType = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType"), "");
					if (OsType.equals("WINDOWS"))
						rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
					else
						rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
				}
				rootPath = rootPath + RedisDataUtil.getBaseConfig("BackStorage", SessionHelper.getSession("DN_ID")).replace("{0}", SessionHelper.getSession("DN_Code"));
				rootPath = rootPath.replaceAll("\\\\", Matcher.quoteReplacement(File.separator)).replaceAll("//", Matcher.quoteReplacement(File.separator));
				String bizCardSavePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));
				//System.out.println("[AWS S3]########rootPath:"+rootPath);
				filePath = rootPath+bizCardSavePath; ///GWStorage/Groupware/BizCard/
				filePath = filePath.replaceAll("\\\\", Matcher.quoteReplacement(File.separator)).replaceAll("//", Matcher.quoteReplacement(File.separator));
				CoviMap fileParam = new CoviMap();

				if(FileInfo != null) {
					long FileSize = FileInfo.getSize();
					
					if(FileSize > 0){
						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						String savePath = filePath + saveFileName; // 저장 될 파일 경로

						//한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");

						if(awsS3.getS3Active(strDN_Code)){
							awsS3.upload(FileInfo.getInputStream(), savePath, FileInfo.getContentType(), FileInfo.getSize());
						}else {
							File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
							//폴더가없을 시 생성
							if (!realUploadDir.exists()) {
								if (realUploadDir.mkdirs()) {
									LOGGER.info("path : " + realUploadDir + " mkdirs();");
								}
							}

							FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						}
		                fileParam.put("ImagePath", savePath.replace(rootPath, ""));
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);
				
				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strPhoneType.equals("") && !strPhoneNumber.equals("")) {
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();
					
					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);
					
					if(phoneMap.get("PhoneType").toString().equals("D")) {
						phoneMap.put("PhoneName", strPhoneName.split(";")[i]);
					} else {
						phoneMap.put("PhoneName", "");
					}
					
					phoneList.add(phoneMap);
				}
				
				CoviMap obj = bizCardManageService.insertBizCardPhone(phoneList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strEmail.equals("")) {
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();
					
					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);
					
					emailList.add(emailMap);
				}
				
				CoviMap obj = bizCardManageService.insertBizCardEmail(emailList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strAnniversaryText.equals("")){
				CoviMap anniversaryMap = new CoviMap();
				
				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);
				
				CoviMap obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="RegistImportBizCardPerson.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap RegistImportBizCardPerson(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = "P";
			String strShareType = req.getParameter("ShareType");
			String strGroupID = req.getParameter("GroupID");
			String strGroupName = req.getParameter("GroupName");
			String strBizCardID = "";
			String strCompanyName = "";
			if(strGroupID != null){
				if(strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();
					
					paramGroup.put("ShareType", strShareType);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);
					
					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if(!"OK".equals(obj.getString("result"))) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}
			
			CoviMap params = new CoviMap();
			String CompanyID = SessionHelper.getSession("DN_ID");
			
			int index = 0;
			while(req.getParameter("Data[" + index + "].Name") != null) {
				if(req.getParameter("Data[" + index + "].ComName") != null && !(req.getParameter("Data[" + index + "].ComName").equals(""))) {
					strCompanyName = req.getParameter("Data[" + index + "].ComName");
				}
				params.put("UR_Code", strUR_Code);
				params.put("UR_Name", strUR_Name);
				params.put("DN_Code", strDN_Code);
				params.put("GR_Code", strGR_Code);
				params.put("ShareType", strShareType);
				params.put("GroupID", strGroupID.equalsIgnoreCase("X") ? null : strGroupID);
				params.put("Name", req.getParameter("Data[" + index + "].Name") == null ? "" : req.getParameter("Data[" + index + "].Name"));
				params.put("MessengerID", req.getParameter("Data[" + index + "].MessengerID") == null ? "" : req.getParameter("Data[" + index + "].MessengerID"));
				params.put("CompanyID", CompanyID);
				params.put("CompanyName", strCompanyName);
				params.put("JobTitle", req.getParameter("Data[" + index + "].JobTitle") == null ? "" : req.getParameter("Data[" + index + "].JobTitle"));
				params.put("DeptName", req.getParameter("Data[" + index + "].DeptName") == null ? "" : req.getParameter("Data[" + index + "].DeptName"));
				params.put("Memo", req.getParameter("Data[" + index + "].Memo") == null ? "" : req.getParameter("Data[" + index + "].Memo"));
				params.put("ImagePath", "");
				
				returnObj = bizCardManageService.insertBizCardPerson(params);
				if(!"OK".equals(returnObj.getString("result"))) {
					return returnObj;
				}
				strBizCardID = params.getString("BizCardID");			
				
				CoviMap obj;
				
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();

				if(req.getParameter("Data[" + index + "].CellPhone") != null && !(req.getParameter("Data[" + index + "].CellPhone").equals(""))) {
					for(int i = 0; i < req.getParameter("Data[" + index + "].CellPhone").split(":").length; i++) {
						phoneMap = new CoviMap();
						
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "C");
						phoneMap.put("PhoneNumber", req.getParameter("Data[" + index + "].CellPhone").split(":")[i]);
						
						phoneList.add(phoneMap);
					}
				}
				
				if(req.getParameter("Data[" + index + "].HomePhone") != null && !(req.getParameter("Data[" + index + "].HomePhone").equals(""))) {
					for(int i = 0; i < req.getParameter("Data[" + index + "].HomePhone").split(":").length; i++) {
						phoneMap = new CoviMap();
					
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "H");
						phoneMap.put("PhoneNumber", req.getParameter("Data[" + index + "].HomePhone").split(":")[i]);
						
						phoneList.add(phoneMap);
					}
				}
				
				if(req.getParameter("Data[" + index + "].ComPhone") != null && !(req.getParameter("Data[" + index + "].ComPhone").equals(""))) {
					for(int i = 0; i < req.getParameter("Data[" + index + "].ComPhone").split(":").length; i++) {
						phoneMap = new CoviMap();
						
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "T");
						phoneMap.put("PhoneNumber", req.getParameter("Data[" + index + "].ComPhone").split(":")[i]);
						
						phoneList.add(phoneMap);
					}
				}
				
				if(req.getParameter("Data[" + index + "].FAX") != null && !(req.getParameter("Data[" + index + "].FAX").equals(""))) {					
					for(int i = 0; i < req.getParameter("Data[" + index + "].FAX").split(":").length; i++) {
						phoneMap = new CoviMap();
						
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "F");
						phoneMap.put("PhoneNumber", req.getParameter("Data[" + index + "].FAX").split(":")[i]);
						
						phoneList.add(phoneMap);
					}
				}
				
				if(req.getParameter("Data[" + index + "].EtcPhone") != null && !(req.getParameter("Data[" + index + "].EtcPhone").equals(""))) {
					for(int i = 0; i < req.getParameter("Data[" + index + "].EtcPhone").split(":").length; i++) {
						phoneMap = new CoviMap();
						
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "E");
						phoneMap.put("PhoneNumber", req.getParameter("Data[" + index + "].EtcPhone").split(":")[i]);
						
						phoneList.add(phoneMap);
					}
				}
				
				if(req.getParameter("Data[" + index + "].DirectPhone") != null && !(req.getParameter("Data[" + index + "].DirectPhone").equals(""))) {
					for(int i = 0; i < req.getParameter("Data[" + index + "].DirectPhone").split(":").length; i++) {
						phoneMap = new CoviMap();
						
						phoneMap.put("BizCardID", strBizCardID);
						phoneMap.put("TypeCode", "P");
						phoneMap.put("PhoneType", "D");
						
						String directPhone = req.getParameter("Data[" + index + "].DirectPhone").split(":")[i];
						String[] directPhoneArr = directPhone.split("\\)");
						
						if(directPhoneArr.length > 1) {
							String phoneName = directPhone.split("\\)")[0].replaceAll("\\(", "");
							String phoneNumber = directPhone.split("\\)")[1];
							
							phoneMap.put("PhoneName", phoneName);
							phoneMap.put("PhoneNumber", StringUtil.trim(phoneNumber));
						} else {
							phoneMap.put("PhoneName", DicHelper.getDic("lbl_DirectPhone"));
							phoneMap.put("PhoneNumber", directPhoneArr[0]);
						}
						
						phoneList.add(phoneMap);
					}
				}
				try {
					if(phoneList.size() > 0) {
						obj = bizCardManageService.insertBizCardPhone(phoneList);
						if(!"OK".equals(obj.getString("result"))) {
							return obj;
						}
					}
				} catch(NullPointerException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
					returnObj.put("result", "FAIL");
					returnObj.put("type", "Phone");
					returnObj.put("data", params);
					return returnObj;
				}  catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
					returnObj.put("result", "FAIL");
					returnObj.put("type", "Phone");
					returnObj.put("data", params);
					return returnObj;
				}
				
				if(req.getParameter("Data[" + index + "].Email") != null && !(req.getParameter("Data[" + index + "].Email").equals(""))) {
				
					List<CoviMap> emailList = new ArrayList<CoviMap>();
					CoviMap emailMap = null;
					
					for(int i = 0; i < req.getParameter("Data[" + index + "].Email").split(":").length; i++) {
						emailMap = new CoviMap();
						
						emailMap.put("BizCardID", strBizCardID);
						emailMap.put("TypeCode", strTypeCode);
						emailMap.put("Email", StringUtils.trim(req.getParameter("Data[" + index + "].Email").split(":")[i]));
						
						emailList.add(emailMap);
					}
					
					try {
						if(emailList.size() > 0) {
							obj = bizCardManageService.insertBizCardEmail(emailList);
							if(!"OK".equals(obj.getString("result"))) {
								return obj;
							}
						}
					} catch(NullPointerException e) {
						LOGGER.error(e.getLocalizedMessage(), e);
						returnObj.put("result", "FAIL");
						returnObj.put("type", "Email");
						returnObj.put("data", params);
						return returnObj;
					} catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
						returnObj.put("result", "FAIL");
						returnObj.put("type", "Email");
						returnObj.put("data", params);
						return returnObj;
					}

				}
				
				if(req.getParameter("Data[" + index + "].AnniversaryText") != null && !(req.getParameter("Data[" + index + "].AnniversaryText").equals(""))) {
					CoviMap anniversaryMap = new CoviMap();
					
					anniversaryMap.put("BizCardID", strBizCardID);
					anniversaryMap.put("TypeCode", strTypeCode);
					anniversaryMap.put("AnniversaryText", req.getParameter("Data[" + index + "].AnniversaryText"));
					
					try {
						obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
						if(!"OK".equals(obj.getString("result"))) {
							return obj;
						}
					} catch(NullPointerException e) {
						LOGGER.error(e.getLocalizedMessage(), e);
						returnObj.put("result", "FAIL");
						returnObj.put("type", "Anniversary");
						returnObj.put("data", params);
						return returnObj;
					} catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
						returnObj.put("result", "FAIL");
						returnObj.put("type", "Anniversary");
						returnObj.put("data", params);
						return returnObj;
					}
					
				}
				
				index++;
			}
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="ModifyBizCardPerson.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap ModifyBizCardPerson(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = req.getParameter("TypeCode");
			String strShareType = req.getParameter("ShareType");
			String strGroupID = req.getParameter("GroupID");
			String strGroupName = req.getParameter("GroupName");
			String strName = req.getParameter("Name");
			String strMessengerID = req.getParameter("MessengerID");
			String strCompanyID = req.getParameter("CompanyID");
			String strCompanyName = req.getParameter("CompanyName");
			String strJobTitle = req.getParameter("JobTitle");
			String strDeptName = req.getParameter("DeptName");
			String strMemo = req.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(req.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(req.getParameter("PhoneType"), "");
			String strPhoneNumber = StringUtil.replaceNull(req.getParameter("PhoneNumber"), "");
			String strPhoneName = StringUtil.replaceNull(req.getParameter("PhoneName"), "");
			String strEmail = StringUtil.replaceNull(req.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(req.getParameter("AnniversaryText"), "");
			String strBizCardID = req.getParameter("BizCardID");
			
			// 값이 비어있을경우 NULL 값으로 전달
			strGroupID = strGroupID.isEmpty() ? null : strGroupID; 
			strGroupName = strGroupName.isEmpty() ? null : strGroupName; 
			
			if(strGroupID != null){
				if(strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();
					
					paramGroup.put("ShareType", strShareType);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);
					
					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if(!"OK".equals(obj.getString("result"))) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}
			
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", strUR_Code);
			params.put("ShareType", strShareType);
			params.put("GroupID", strGroupID);
			params.put("Name", strName);
			params.put("MessengerID", strMessengerID);
			params.put("CompanyID", strCompanyID);
			params.put("CompanyName", strCompanyName);
			params.put("JobTitle", strJobTitle);
			params.put("DeptName", strDeptName);
			params.put("Memo", strMemo);
			params.put("BizCardID", strBizCardID);
			
			returnObj = bizCardManageService.updateBizCardPerson(params);
			if(!"OK".equals(returnObj.getString("result"))) {
				return returnObj;
			}
			
			if(!strImagePath.equals("")) {			
				MultipartFile FileInfo = req.getFile("FileInfo");

				String filePath;
				String rootPath;
				//System.out.println("[AWS S3]awsS3.getS3Active():"+awsS3.getS3Active());
				if(awsS3.getS3Active(strDN_Code)){
					rootPath = FileUtil.getBackPath(strDN_Code);
				}else {
					String OsType = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType"), "");
					if (OsType.equals("WINDOWS"))
						rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
					else
						rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
				}
				rootPath = rootPath + RedisDataUtil.getBaseConfig("BackStorage", SessionHelper.getSession("DN_ID")).replace("{0}", SessionHelper.getSession("DN_Code"));
				rootPath = rootPath.replaceAll("\\\\", Matcher.quoteReplacement(File.separator)).replaceAll("//", Matcher.quoteReplacement(File.separator));
				String bizCardSavePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));
				//System.out.println("[AWS S3]########rootPath:"+rootPath);
				filePath = rootPath+bizCardSavePath; ///GWStorage/Groupware/BizCard/
				filePath = filePath.replaceAll("\\\\", Matcher.quoteReplacement(File.separator)).replaceAll("//", Matcher.quoteReplacement(File.separator));
				CoviMap fileParam = new CoviMap();

				if(FileInfo != null) {
					long FileSize = FileInfo.getSize();
					
					if(FileSize > 0){
						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						String savePath = filePath + saveFileName; // 저장 될 파일 경로

						//한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");

						if(awsS3.getS3Active(strDN_Code)){
							awsS3.upload(FileInfo.getInputStream(), savePath, FileInfo.getContentType(), FileInfo.getSize());
						}else {
							File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
							//폴더가없을 시 생성
							if (!realUploadDir.exists()) {
								if (realUploadDir.mkdirs()) {
									LOGGER.info("path : " + realUploadDir + " mkdirs();");
								}
							}

							FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						}
		                fileParam.put("ImagePath", savePath.replace(rootPath, ""));
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);
				
				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strPhoneType.equals("") && !strPhoneNumber.equals("")) {
				CoviMap phoneParams = new CoviMap();
				CoviMap obj = new CoviMap();
				
				phoneParams.put("BizCardID", strBizCardID);
				phoneParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardPhone(phoneParams);
				
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();
					
					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);
					
					if(phoneMap.get("PhoneType").toString().equals("D")) {
						phoneMap.put("PhoneName", strPhoneName.split(";")[i]);
					} else {
						phoneMap.put("PhoneName", "");
					}
					
					phoneList.add(phoneMap);
				}
				
				obj = bizCardManageService.insertBizCardPhone(phoneList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strEmail.equals("")) {
				CoviMap emailParams = new CoviMap();
				CoviMap obj = new CoviMap();
				
				emailParams.put("BizCardID", strBizCardID);
				emailParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardEmail(emailParams);
				
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();
					
					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);
					
					emailList.add(emailMap);
				}
				
				obj = bizCardManageService.insertBizCardEmail(emailList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strAnniversaryText.equals("")){
				CoviMap anniParams = new CoviMap();
				CoviMap obj = new CoviMap();
				
				anniParams.put("BizCardID", strBizCardID);
				anniParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardAnniversary(anniParams);
				
				CoviMap anniversaryMap = new CoviMap();
				
				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);
				
				obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardPersonView.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardPersonView(HttpServletRequest request) throws Exception {
		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		String strGR_Code = SessionHelper.getSession("GR_Code");
		String strDN_Code = SessionHelper.getSession("DN_Code");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		params.put("BizCardID", strBizCardID);
		if(strShareType != null && !StringUtil.isEmpty(strShareType)) {
			if(strShareType.equals("P")) {
				params.put("UR_Code", strUR_Code);
			}
			else if(strShareType.equals("D")) {
				params.put("GR_Code", strGR_Code);
			}
			else if(strShareType.equals("U")) {
				params.put("DN_Code", strDN_Code);
			}
			else{ //type : A(전체)
				params.put("UR_Code", strUR_Code);
				params.put("GR_Code", strGR_Code);
				params.put("DN_Code", strDN_Code);
			}
		}
		
		CoviMap returnObj = bizCardManageService.selectBizCardPersonView(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardPerson.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardPerson(HttpServletRequest request) throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		
		CoviMap returnObj = bizCardManageService.selectBizCardPerson(params);
		
		return returnObj;
	}
	
	
	//업체 관리(등록, 수정, 조회)
	@RequestMapping(value="RegistBizCardCompany.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap RegistBizCardCompany(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			String strGroupName = StringUtil.replaceNull(request.getParameter("GroupName"), "");
			String strComName = request.getParameter("ComName");
			String strComRepName = request.getParameter("ComRepName");
			String strComWebsite = request.getParameter("ComWebsite");
			String strComZipCode = request.getParameter("ComZipCode");
			String strComAddress = request.getParameter("ComAddress");
			String strMemo = request.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(request.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(request.getParameter("PhoneType"), "");
			String strPhoneNumber = request.getParameter("PhoneNumber");
			String strEmail = StringUtil.replaceNull(request.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(request.getParameter("AnniversaryText"), "");
			String strBizCardID = "";
			
			if(strGroupID != null && !StringUtil.isEmpty(strGroupID)){
				if(strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();
					
					paramGroup.put("ShareType", strTypeCode);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);
					
					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if(!"OK".equals(obj.getString("result"))) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}
			
			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("UR_Name", strUR_Name);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			params.put("GroupID", strGroupID);
			params.put("ComName", strComName);
			params.put("ComRepName", strComRepName);
			params.put("ComWebsite", strComWebsite);
			params.put("ComZipcode", strComZipCode);
			params.put("ComAddress", strComAddress);
			params.put("Memo", strMemo);
			params.put("ImagePath", strImagePath);
			
			returnObj = bizCardManageService.insertBizCardCompany(params);
			if(!"OK".equals(returnObj.getString("result"))) {
				return returnObj;
			}
			strBizCardID = params.getString("BizCardID");
			
			if(!strImagePath.equals("")) {			
				MultipartFile FileInfo = req.getFile("FileInfo");
				
				String OsType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
				
				String filePath;
				String rootPath;
				if(OsType.equals("WINDOWS"))
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
				else
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
				
				filePath = rootPath + RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); ///GWStorage/Groupware/BizCard/
				
				CoviMap fileParam = new CoviMap();

				if(FileInfo != null) {
					long FileSize = FileInfo.getSize();
					
					if(FileSize > 0){
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));				
						//폴더가없을 시 생성
						if(!realUploadDir.exists()){
							if(realUploadDir.mkdirs()) {
								LOGGER.info("path : " + realUploadDir + " mkdirs();");
							}
						}
						
						// 파일 중복명 처리
		                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
						
		                // 본래 파일명
		                String originalfileName = FileInfo.getOriginalFilename(); 
		                
		                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
		                
		                // 저장되는 파일 이름
		                String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);
		                
		                String savePath = filePath + saveFileName; // 저장 될 파일 경로
		                
		                //한글명저장	                 
		                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
		                FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		                fileParam.put("ImagePath", savePath.replace(rootPath, ""));
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);
				
				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!"".equals(strPhoneType) && !"".equals(strPhoneNumber)) {
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();
					
					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType);
					phoneMap.put("PhoneNumber", strPhoneNumber);
					
					phoneList.add(phoneMap);
				}
				
				CoviMap obj = bizCardManageService.insertBizCardPhone(phoneList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strEmail.equals("")) {
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strPhoneType.split(";").length; i++) {
					emailMap = new CoviMap();
					
					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail);
					
					emailList.add(emailMap);
				}
				
				CoviMap obj = bizCardManageService.insertBizCardEmail(emailList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strAnniversaryText.equals("")) {
				CoviMap anniversaryMap = new CoviMap();
					
				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);
					
				CoviMap obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="ModifyBizCardCompany.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap ModifyBizCardCompany(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = req.getParameter("TypeCode");
			String strGroupID = req.getParameter("GroupID");
			String strGroupName = req.getParameter("GroupName");
			String strComName = req.getParameter("ComName");
			String strComRepName = req.getParameter("ComRepName");
			String strComWebsite = req.getParameter("ComWebsite");
			String strComZipCode = req.getParameter("ComZipCode");
			String strComAddress = req.getParameter("ComAddress");
			String strMemo = req.getParameter("Memo");
			String strImagePath = req.getParameter("ImagePath");
			String strPhoneType = req.getParameter("PhoneType");
			String strPhoneNumber = req.getParameter("PhoneNumber");
			String strEmail = req.getParameter("Email");
			String strAnniversaryText = req.getParameter("AnniversaryText");
			String strBizCardID = req.getParameter("BizCardID");
			
			// 값이 비어있을경우 NULL 값으로 전달
			strGroupID = strGroupID.isEmpty() ? null : strGroupID; 
			strGroupName = strGroupName.isEmpty() ? null : strGroupName; 
			
			if(strGroupID != null){
				if(strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();
					
					paramGroup.put("ShareType", strTypeCode);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);
					
					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if(!"OK".equals(obj.getString("result"))) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}
			
			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("GroupID", strGroupID);
			params.put("ComName", strComName);
			params.put("ComRepName", strComRepName);
			params.put("ComWebsite", strComWebsite);
			params.put("ComZipcode", strComZipCode);
			params.put("ComAddress", strComAddress);
			params.put("Memo", strMemo);
			params.put("BizCardID", strBizCardID);
			
			returnObj = bizCardManageService.updateBizCardCompany(params);
			if(!"OK".equals(returnObj.getString("result"))) {
				return returnObj;
			}
			
			if(!strImagePath.equals("")) {			
				MultipartFile FileInfo = req.getFile("FileInfo");
				
				String OsType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
				
				String filePath;
				String rootPath;
				if(OsType.equals("WINDOWS"))
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
				else
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
				
				filePath = rootPath + RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); //C:/eGovFrame-3.5.1/GWStorage/Groupware/BizCard/
				
				CoviMap fileParam = new CoviMap();

				if(FileInfo != null) {
					long FileSize = FileInfo.getSize();
					
					if(FileSize > 0){
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));				
						//폴더가없을 시 생성
						if(!realUploadDir.exists()){
							if(realUploadDir.mkdirs()) {
								LOGGER.info("path : " + realUploadDir + " mkdirs();");
							}
						}
						
						// 파일 중복명 처리
		                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
						
		                // 본래 파일명
		                String originalfileName = FileInfo.getOriginalFilename(); 
		                
		                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
		                
		                // 저장되는 파일 이름
		                String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);
		                
		                String savePath = filePath + saveFileName; // 저장 될 파일 경로
		                
		                //한글명저장	                 
		                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
		                FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		                fileParam.put("ImagePath", savePath.replace(rootPath, ""));
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);
				
				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strPhoneType.equals("") && !strPhoneNumber.equals("")) {
				CoviMap phoneParams = new CoviMap();
				CoviMap obj = new CoviMap();
				
				phoneParams.put("BizCardID", strBizCardID);
				phoneParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardPhone(phoneParams);
				
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();
					
					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);
					
					phoneList.add(phoneMap);
				}
				
				obj = bizCardManageService.insertBizCardPhone(phoneList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strEmail.equals("")) {
				CoviMap emailParams = new CoviMap();
				CoviMap obj = new CoviMap();
				emailParams.put("BizCardID", strBizCardID);
				emailParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardEmail(emailParams);
				
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();
				
				for(int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();
					
					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);
					
					emailList.add(emailMap);
				}
				
				obj = bizCardManageService.insertBizCardEmail(emailList);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
			if(!strAnniversaryText.equals("")){
				CoviMap anniParams = new CoviMap();
				CoviMap obj = new CoviMap();
				
				anniParams.put("BizCardID", strBizCardID);
				anniParams.put("TypeCode", strTypeCode);
				
				bizCardManageService.deleteBizCardAnniversary(anniParams);
				
				CoviMap anniversaryMap = new CoviMap();
				
				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);
				
				obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
			}
			
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardCompanyView.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardCompanyView(HttpServletRequest request) throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		params.put("UR_Code", strUR_Code);
		
		CoviMap returnObj = bizCardManageService.selectBizCardCompanyView(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardCompany.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardCompany(HttpServletRequest request) throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		
		CoviMap returnObj = bizCardManageService.selectBizCardCompany(params);
		
		return returnObj;
	}

	
	//공통 관리
	@RequestMapping(value="getBizCardPhone.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardPhone(HttpServletRequest request) throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		String strTypeCode = request.getParameter("TypeCode");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		params.put("TypeCode", strTypeCode);
		
		CoviMap returnObj = bizCardManageService.selectBizCardPhone(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardEmail.do", method={RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardEmail(HttpServletRequest request) throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		String strTypeCode = request.getParameter("TypeCode");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		params.put("TypeCode", strTypeCode);
		
		CoviMap returnObj = bizCardManageService.selectBizCardEmail(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="DeleteBizCard.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap DeleteBizCard(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strBizCardID = request.getParameter("BizCardID");
			
			CoviMap params = new CoviMap();
			
			params.put("TypeCode", strTypeCode);
			params.put("BizCardID", strBizCardID);
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			
			returnObj = bizCardManageService.deleteBizCard(params);
			
			CoviMap phoneParams = new CoviMap();
			
			phoneParams.put("BizCardID", strBizCardID);
			phoneParams.put("TypeCode", strTypeCode);
			
			bizCardManageService.deleteBizCardPhone(phoneParams);

			CoviMap emailParams = new CoviMap();
			
			emailParams.put("BizCardID", strBizCardID);
			emailParams.put("TypeCode", strTypeCode);
			
			bizCardManageService.deleteBizCardEmail(emailParams);
			
			CoviMap anniParams = new CoviMap();
			
			anniParams.put("BizCardID", strBizCardID);
			anniParams.put("TypeCode", strTypeCode);
			
			bizCardManageService.deleteBizCardAnniversary(anniParams);
			
			CoviMap favrParams = new CoviMap();
			
			favrParams.put("BizCardID", strBizCardID);
			favrParams.put("UR_Code", strUR_Code);
			
			bizCardListService.deleteFromFavoriteList(anniParams);
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	
	/*연락처 정리------------------------------------------------------------------------------------------------------------------*/
	
	@RequestMapping(value="getBizCardSimilarList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardSimilarList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strType = StringUtil.replaceNull(request.getParameter("type"), "");
		strType = strType.isEmpty() ? "Name" : strType;
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("Type", strType);
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		params.put("GR_Code",  SessionHelper.getSession("GR_Code"));
		
		CoviMap listData = bizCardManageService.selectBizCardSimilarList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value = "orgainizeBizCard.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap orgainizeBizCard(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		List<String> list = null;

		try {

			String   DupInfoTemp		= null;
			String[] DupInfo		= null;
			String strBizCardY = null;
			String[] arrBizCard = null;
			String[] arrPhoneChkY = null;
			String[] arrPhoneChkN = null;
			String[] arrEmailChkY = null;
			String[] arrEmailChkN = null;
			
			DupInfoTemp	= StringUtil.replaceNull(request.getParameter("DupInfo"), "");
			DupInfo	=DupInfoTemp.split(",");
						
			int result = 0;
			for (String sInfo: DupInfo){
				
				strBizCardY = sInfo.split(";")[0].isEmpty() ? null : DupInfo[0].split(";")[0];
				arrBizCard = sInfo.split("\\|")[0].split(";");
				list = new ArrayList<String>(Arrays.asList(arrBizCard));
				list.remove(strBizCardY);
				arrBizCard = list.toArray(new String[0]);
				arrPhoneChkY = sInfo.split("\\|", -1)[1].split(";", -1);
				arrPhoneChkN = sInfo.split("\\|", -1)[2].split(";", -1);
				arrEmailChkY = sInfo.split("\\|", -1)[3].split(";", -1);
				arrEmailChkN = sInfo.split("\\|", -1)[4].split(";", -1);
				
				if(arrPhoneChkY[0].isEmpty()){
					arrPhoneChkY = null;
				} else{
					arrPhoneChkY = Arrays.copyOf(arrPhoneChkY, arrPhoneChkY.length-1);
					arrPhoneChkY = new HashSet<String>(Arrays.asList(arrPhoneChkY)).toArray(new String[0]); //중복
				}
				if(arrPhoneChkN[0].isEmpty()){
					arrPhoneChkN = null;
				} else{
					arrPhoneChkN = Arrays.copyOf(arrPhoneChkN, arrPhoneChkN.length-1);
					arrPhoneChkN = new HashSet<String>(Arrays.asList(arrPhoneChkN)).toArray(new String[0]); //중복
				}
				if(arrEmailChkY[0].isEmpty()){
					arrEmailChkY = null;
				} else{
					arrEmailChkY = Arrays.copyOf(arrEmailChkY, arrEmailChkY.length-1);
					arrEmailChkY = new HashSet<String>(Arrays.asList(arrEmailChkY)).toArray(new String[0]); //중복
				}
				if(arrEmailChkN[0].isEmpty()){
					arrEmailChkN = null;
				} else{
					arrEmailChkN = Arrays.copyOf(arrEmailChkN, arrEmailChkN.length-1);
					arrEmailChkN = new HashSet<String>(Arrays.asList(arrEmailChkN)).toArray(new String[0]); //중복
				}
						
				CoviMap params = new CoviMap();

				params.put("BizCardY",strBizCardY);
				params.put("BizCardID",arrBizCard);
				params.put("PhoneChkY",arrPhoneChkY);
				params.put("PhoneChkN",arrPhoneChkN);
				params.put("EmailChkY",arrEmailChkY);
				params.put("EmailChkN",arrEmailChkN);
				
				result += bizCardManageService.orgainizeBizCard(params);
			}
			

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "정상처리되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "/CreateBizCard.do", method = RequestMethod.GET)
	public ModelAndView CreateBizCard(HttpServletRequest request) throws Exception {
		String strName = request.getParameter("Name");
		String strEmail = request.getParameter("Email");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCard";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("Name", strName);
		mav.addObject("Email", strEmail);
		mav.addObject("UR_Code", strUR_Code);
		mav.addObject("mode", "regist");
		
		return mav;
	}
	
	@RequestMapping(value="getImportVCardBizCardPerson.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getImportVCardBizCardPerson(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
    	
    	try {
    		MultipartFile fileObj = request.getFile("fileObj");
        	String content = new String(fileObj.getBytes(), StandardCharsets.UTF_8);
        	
    		List<VCard> vCards = Ezvcard.parse(content).all();
        	int size = Ezvcard.parse(content).all().size();
        	
        	if(size == 0) {
        		returnData.put("status", Return.FAIL);
        		returnData.put("message", "데이터가 없어용");
        	} else {
        		CoviList vCardAry = new CoviList();
        		        		
        		for(int i = 0; i < size; i++) {
            		VCard vCard = vCards.get(i);
            		// 이름
            		String vName = StringUtils.isNotEmpty(vCard.getFormattedName().getValue()) ?
            				vCard.getFormattedName().getValue() : "";
            		// 이메일 (하나만 등록)
            		String vEmail = (vCard.getEmails().size() > 0) ?
            				vCard.getEmails().get(0).getValue() : "";
            		// 핸드폰
            		String vCellPhone = (vCard.getTelephoneNumbers().get(0).getUri() != null) ?
            				vCard.getTelephoneNumbers().get(0).getUri().getNumber() : vCard.getTelephoneNumbers().get(0).getText();
            		// 회사
            		String vComName = (vCard.getOrganization().getValues().size() > 0) ?
            				vCard.getOrganization().getValues().get(0) : "";
            		// 부서
            		String vDeptName = (vCard.getOrganization().getValues().size() > 1) ?
            				vCard.getOrganization().getValues().get(1) : "";
            		// 직책
            		String vJobTitle = (vCard.getTitles().size() > 0) ?
            				vCard.getTitles().get(0).getValue() : "";
            		
            		CoviMap vCardObj = new CoviMap();
            		
            		vCardObj.put("Name", vName);
            		vCardObj.put("Email", vEmail);
            		vCardObj.put("CellPhone", vCellPhone);
            		vCardObj.put("ComName", vComName);
            		vCardObj.put("DeptName", vDeptName);
            		vCardObj.put("JobTitle", vJobTitle);
            		
            		vCardAry.add(vCardObj);
            	}
        		
            	returnData.put("status", Return.SUCCESS);
            	returnData.put("data", vCardAry);
        	}
    	} catch (IOException e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "파싱 오류~~~~");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	} catch (NullPointerException e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "파싱 오류~~~~");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	} catch (Exception e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "파싱 오류~~~~");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	}
    	
		return returnData;
	}
	
	@RequestMapping(value="getExportVCardBizCardPerson.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getExportVCardBizCardPerson(MultipartHttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
    	
    	try {
    		MultipartFile fileObj = request.getFile("fileObj");
        	String content = new String(fileObj.getBytes(), StandardCharsets.UTF_8);
        	
    		List<VCard> vCards = Ezvcard.parse(content).all();
        	int size = Ezvcard.parse(content).all().size();
        	
        	if(size == 0) {
        		returnData.put("status", Return.FAIL);
        		returnData.put("message", "데이터가 없어용");
        	} else {
        		CoviList vCardAry = new CoviList();
        		        		
        		for(int i = 0; i < size; i++) {
            		VCard vCard = vCards.get(i);
            		// 이름
            		String vName = StringUtils.isNotEmpty(vCard.getFormattedName().getValue()) ?
            				vCard.getFormattedName().getValue() : "";
            		// 이메일 (하나만 등록)
            		String vEmail = (vCard.getEmails().size() > 0) ?
            				vCard.getEmails().get(0).getValue() : "";
            		// 핸드폰
            		String vCellPhone = (vCard.getTelephoneNumbers().get(0).getUri() != null) ?
            				vCard.getTelephoneNumbers().get(0).getUri().getNumber() : vCard.getTelephoneNumbers().get(0).getText();
            		// 회사
            		String vComName = (vCard.getOrganization().getValues().size() > 0) ?
            				vCard.getOrganization().getValues().get(0) : "";
            		// 부서
            		String vDeptName = (vCard.getOrganization().getValues().size() > 1) ?
            				vCard.getOrganization().getValues().get(1) : "";
            		// 직책
            		String vJobTitle = (vCard.getTitles().size() > 0) ?
            				vCard.getTitles().get(0).getValue() : "";
            		
            		CoviMap vCardObj = new CoviMap();
            		
            		vCardObj.put("Name", vName);
            		vCardObj.put("Email", vEmail);
            		vCardObj.put("CellPhone", vCellPhone);
            		vCardObj.put("ComName", vComName);
            		vCardObj.put("DeptName", vDeptName);
            		vCardObj.put("JobTitle", vJobTitle);
            		
            		vCardAry.add(vCardObj);
            	}
        		
            	returnData.put("status", Return.SUCCESS);
            	returnData.put("data", vCardAry);
        	}
    	} catch (IOException e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "IOException");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	} catch (NullPointerException e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "NullPointerException");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	} catch (Exception e) {
    		returnData.put("status", Return.FAIL);
    		returnData.put("message", "파싱 오류~~~~");
    		
    		LOGGER.error(e.getLocalizedMessage(), e);
    	}
    	
		return returnData;
	}
}
