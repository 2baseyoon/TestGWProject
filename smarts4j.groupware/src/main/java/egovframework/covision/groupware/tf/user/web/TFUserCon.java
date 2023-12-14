package egovframework.covision.groupware.tf.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.DataValidation;
import org.apache.poi.ss.usermodel.DataValidationConstraint;
import org.apache.poi.ss.usermodel.DataValidationHelper;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddressList;
import org.apache.poi.xssf.usermodel.XSSFDataValidationHelper;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
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
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.tf.user.service.TFUserSvc;
import egovframework.covision.groupware.util.BoardUtils;


import net.sf.jxls.transformer.XLSTransformer;

@Controller
public class TFUserCon {
	private Logger LOGGER = LogManager.getLogger(TFUserCon.class);
	private static final String FILE_SERVICE_TYPE = "TF";
	private final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	LogHelper logHelper = new LogHelper();
	
	@Autowired
	private TFUserSvc tfSvc;
	
	@Autowired
	private CommunitySvc AdmincommunitySvc;
	
	@Autowired
	private CommunityUserSvc UsercommunitySvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	// 상세조회 팝업 
	@RequestMapping(value = "layout/goTFInfoViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goTFInfoViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/tf/TFInfoViewPopup");
	}
	
	// 수정 팝업
	@RequestMapping(value = "layout/goTFInfoEditPopup.do", method = RequestMethod.GET)
	public ModelAndView goTFInfoEditPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/tf/TFInfoEditPopup");
	}
	// 생성 팝업
	@RequestMapping(value = "layout/goTFTeamRoomPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goTFTeamRoomPopup() throws Exception {
		String returnURL = "user/tf/TFCreatePopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "layout/selectUserJoinTF.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserJoinTF(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_CODE", userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			
			resultList = tfSvc.selectUserJoinTF(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectUserTempTFGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserTempTFGridList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			int cnt = tfSvc.selectUserTempTFGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params, cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectUserTempTFGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/deleteTempTFTeamRoom.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteTempTFTeamRoom(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("CU_IDs", request.getParameter("CU_IDs"));
			
			if(!tfSvc.deleteTempTFTeamRoom(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectUserTFGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserTFGridList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			int cnt = tfSvc.selectUserTFGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params, cnt));
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectUserTFGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectUserMyTFGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserMyTFGridList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			int cnt = tfSvc.selectUserMyTFGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params, cnt));
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectUserMyTFGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectMemberGrade.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMemberGrade(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		String resultString = null;
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			resultString = tfSvc.selectMemberGrade(params);
			
			returnData.put("data", resultString);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectUserAdminTFGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserAdminTFGridList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			int cnt = tfSvc.selectUserAdminTFGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params, cnt));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = tfSvc.selectUserAdminTFGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/deleteTFTeamRoom.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteTFTeamRoom(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		String resultStr = null;
		CoviMap params = new CoviMap();
		
		try {
			params.put("CU_IDs", request.getParameter("CU_IDs"));
			resultStr = tfSvc.deleteTFTeamRoom(params);
			
			if(!resultStr.equals("")){
				returnData.put("message", resultStr);
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/updateTFTeamRoomStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateTFTeamRoomStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("CU_IDs", request.getParameter("CU_IDs"));
			params.put("CU_IDArr", StringUtil.replaceNull(request.getParameter("CU_IDs"), "").split(","));
			params.put("AppStatus", request.getParameter("AppStatus"));
			params.put("ProcesserCode", userDataObj.getString("USERID"));
			
			if(!tfSvc.updateTFTeamRoomStatus(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			} else {
				params.put("UR_Code", userDataObj.getString("USERID"));
				
				if(AdmincommunitySvc.clearRedisCache(params)){
					
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/updateTFTeamRoom.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateTFTeamRoom(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("txtOperator", userDataObj.getString("USERID") );
			params.put("userID",  userDataObj.getString("USERID")); 
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community");//TFRoom
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(!tfSvc.updateTFTeamRoom(params, filesParams, mf)){
				returnData.put("status", Return.FAIL);
			}else{
				
				params.put("UR_Code", userDataObj.getString("USERID"));
				
				if(AdmincommunitySvc.clearRedisCache(params)){
					
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} 
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/updateTFTeamRoomAddFile.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateTFTeamRoomAddFile(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			String saveMode = request.getParameter("saveMode") == null ? "" : request.getParameter("saveMode");
			
			if(saveMode.equals("Approval")){
				String fileNameArr[] = null;
				String filePathArr[] = null;
				String fileIDArr[] = null;
				String strFileIDArr = "";
				
				
				if(request.getParameter("fileName") != null && !request.getParameter("fileName").equals("")){
					fileNameArr = request.getParameter("fileName").split(",");
				}
				if(request.getParameter("filePath") != null && !request.getParameter("filePath").equals("")){
					filePathArr = request.getParameter("filePath").split(",");
				}
				if(request.getParameter("fileID") != null && !request.getParameter("fileID").equals("")){
					strFileIDArr = request.getParameter("fileID");
					fileIDArr = strFileIDArr.split(",");
				}
				
				if(fileNameArr != null && filePathArr != null){
					CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(strFileIDArr);
					
					for(int i = 0; i < fileNameArr.length; i++){
						String fileName = fileNameArr[i];
						String filePath = filePathArr[i];
						String fileID = fileIDArr[i];
						
						if(fileID.equals("")) {
							File file = new File(FileUtil.checkTraversalCharacter(filePath));
							try(FileInputStream ins = new FileInputStream(file);){
								MultipartFile multipartFile = new MockMultipartFile(fileName, fileName, Files.probeContentType(Paths.get(filePath)), IOUtils.toByteArray(ins));
								mf.add(multipartFile);
							}
						}else {
							CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID);
							String companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileStorageInfo.optString("CompanyCode");
							filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
							File file = new File(FileUtil.checkTraversalCharacter(filePath));
							try(FileInputStream ins = new FileInputStream(file);){
								MultipartFile multipartFile = new MockMultipartFile(fileName, fileName, Files.probeContentType(Paths.get(filePath)), IOUtils.toByteArray(ins));
								mf.add(multipartFile);
							}
						}
					}
				}
			}else if(saveMode.equals("Mail")){
				File file = new File(FileUtil.checkTraversalCharacter(request.getParameter("filePath")));
				try(FileInputStream ins = new FileInputStream(file);){
					MultipartFile multipartFile = new MockMultipartFile(request.getParameter("fileName"), file.getName(), Files.probeContentType(Paths.get(request.getParameter("filePath"))), IOUtils.toByteArray(ins));
					mf.add(multipartFile);
				}
			}else{
				mf = request.getFiles("files");
				
				if(!FileUtil.isEnableExtention(mf)){
					returnData.put("status", Return.FAIL);
					returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return returnData;
				}
			}
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("txtOperator", userDataObj.getString("USERID"));
			params.put("userID",  userDataObj.getString("USERID")); 
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community");//TFRoom
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(!tfSvc.updateTFTeamRoom(params, filesParams, mf)){
				returnData.put("status", Return.FAIL);
			}else{
				
				params.put("UR_Code", userDataObj.getString("USERID"));
				
				if(AdmincommunitySvc.clearRedisCache(params)){
					
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/checkTFName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkTFName(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("DisplayName",request.getParameter("DisplayName"));
		
		if(tfSvc.checkTFNameCount(params) > 0){
			returnData.put("status", Return.FAIL);
		}else{
			returnData.put("status", Return.SUCCESS);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/checkTFCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkTFCode(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("CU_Code",request.getParameter("CU_Code"));
		
		if(tfSvc.checkTFCodeCount(params) > 0){
			returnData.put("status", Return.FAIL);
		}else{
			returnData.put("status", Return.SUCCESS);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/createTFTeamRoom.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createTFTeamRoom(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("txtOperator", userDataObj.getString("USERID"));
			params.put("userID", userDataObj.getString("USERID")); 
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community"); // TFRoom
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(request.getParameter("IsUseMessenger").equals("Y")){
				CoviMap MessengerParams = new CoviMap();
				String secretKey = "";
				
				if(params.getString("openType") != null && params.getString("openType").equals("P")
					&& params.getString("security") != null && !params.getString("security").equals("")){
					secretKey = tfSvc.pb_encrypt(params.getString("security"));
				}else{
					secretKey = "1";
				}
				
				MessengerParams.put("name", params.getString("txtTFName"));
				MessengerParams.put("members", params.getString("members"));
				MessengerParams.put("authMembers", params.getString("authMembers"));
				MessengerParams.put("secretKey", secretKey);
				MessengerParams.put("CSJTK", params.getString("CSJTK"));
				
				String roomID = tfSvc.eumChannelCreate(MessengerParams);
				
				if(roomID.equals("FAIL") || roomID.equals("ERROR")){
					returnData.put("status", Return.FAIL);
					return returnData;
				}else{
					params.put("RoomID", roomID);
				}
			}
			
			CoviMap returnObj = tfSvc.createTFTeamRoom(params, filesParams, mf);
			
			if(!returnObj.getBoolean("status")){
				returnData.put("status", Return.FAIL);
			}else{
				params.put("UR_Code", userDataObj.getString("USERID"));
				
				if(AdmincommunitySvc.clearRedisCache(params)){
					
				}
				
				/*
				 * @author : sjhan
				 *프로젝트룸 생성시 팀원 메일 전송
				 *발신자 : PM
				 *수신자 : 지정 팀원 
				 * */
				CoviList userList = new CoviList();
				String[] txtPMCode = params.getString("txtPMCode").split(";");
				String[] txtMemberCode = params.getString("txtMemberCode").split(";");
				
				for(String pmCode : txtPMCode) {
					userList.add(pmCode);
				}
				
				for(String memberCode : txtMemberCode) {
					userList.add(memberCode);
				}
				
				CoviMap userListParams = new CoviMap();
				userListParams.put("userList", userList);
				
				returnData.put("cuId", returnObj.get("CU_ID"));
				returnData.put("toArray", tfSvc.getUserEmailInfo(userListParams));
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/tempSaveTFTeamRoom.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap tempSaveTFTeamRoom(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnData;
			}
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("txtOperator", userDataObj.getString("USERID"));
			params.put("userID",  userDataObj.getString("USERID")); 
			
			if(request.getParameter("IsUseMessenger").equals("Y")){
				if(params.getString("openType") != null && params.getString("openType").equals("P")
					&& params.getString("security") != null && !params.getString("security").equals("")){
					String secureKey = tfSvc.pb_encrypt(params.getString("security"));
					params.put("security", secureKey);
				}
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community"); //TFRoom
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(!tfSvc.tempSaveTFTeamRoom(params, filesParams, mf)){
				returnData.put("status", Return.FAIL);
			}else{
				params.put("UR_Code", userDataObj.getString("USERID")); 
				
				if(AdmincommunitySvc.clearRedisCache(params)){
					
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectTFTempSaveData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectTFTempSaveData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			resultData = tfSvc.selectTFTempSaveData(params);
			
			CoviMap object = resultData.getJSONArray("data").getJSONObject(0);
			
			if(object.get("Reserved1") != null && object.get("Reserved2") != null){
				String secretKey = tfSvc.pb_decrypt(object.getString("Reserved2"));
				resultData.getJSONArray("data").getJSONObject(0).put("Reserved2", secretKey);
			}
			
			returnData.put("TFInfo", resultData.get("data"));
			
			// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community");//TFRoom
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "TF");//TF
			filesParams.put("MessageID", params.getString("CU_ID"));
			filesParams.put("Version", "0");
			
			returnData.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectTFDetailInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectTFDetailInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			resultData = tfSvc.selectTFDetailInfo(params);
			returnData.put("TFInfo", resultData.get("data"));
			
			// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", "Community"); //TFRoom
			filesParams.put("ObjectID", "0");
			filesParams.put("ObjectType", "TF");
			filesParams.put("MessageID", params.getString("CU_ID"));
			filesParams.put("Version", "0");
			returnData.put("fileList", fileSvc.selectAttachAll(filesParams));
			
			//진도율 추가
			returnData.put("TFProgressInfo", tfSvc.selectTFProgressInfo(params));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userTF/TFMain.do")
	public ModelAndView communityMain(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "TF.TFMain.TFMain";
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		
		params.put("UR_Code", SessionHelper.getSession("USERID"));
		params.put("CU_ID", request.getParameter("C"));
		
		//TF의 경우 회원가입이 없음
		if( UsercommunitySvc.selectCommunityHomepageCheck(params) == 0){
			returnURL = "error";
			ModelAndView mav = new ModelAndView(returnURL);
			return mav;
		}
		
		if(UsercommunitySvc.selectCommunityVisitCnt(params) < 1){
			if(!UsercommunitySvc.insertCommunityVisit(params)){
				//실패 처리 없음.
			}
		}
		
		if(AdmincommunitySvc.clearRedisCache(params)){
			
		}
		
		String checkValue = UsercommunitySvc.selectCommunityUserLevelCheck(params);
		String checkType = UsercommunitySvc.selectCommunityTypeCheck(params);
		String returnValue = "Y";
		
		if(!func.f_NullCheck(checkType).equals("") && func.f_NullCheck(checkType).equals("C")){
			if(func.f_NullCheck(checkValue).equals("") || func.f_NullCheck(checkValue).equals("0")){
				returnValue = "N";
			}
		}
		
		if(func.f_NullCheck(returnValue).equals("N")){
			returnURL = "TF.TFMain.TFMain";
		}
		
		CoviList webpartList = UsercommunitySvc.getWebpartList(params);
		String layoutTemplate = UsercommunitySvc.getLayoutTemplate(webpartList, params);
		
		CoviList webpartData = (CoviList)UsercommunitySvc.getWebpartData(webpartList);
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("layout", layoutTemplate);
		mav.addObject("data", webpartData);
		mav.addObject("C", request.getParameter("C"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/userTF/TFMovePage.do", method = RequestMethod.GET)
	public ModelAndView communityInfoPage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "tf."+request.getParameter("move")+".TFMain";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("C", request.getParameter("C"));
		return mav;
	}
	
	@RequestMapping(value = "layout/userTF/TFBoardLeft.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityBoardLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		CoviList result = new CoviList();
		
		boolean flag = true;
		String checkValue = "";
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_Code", userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "TF", "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			
			if (!func.f_NullCheck(params.get("IsAdmin").toString()).trim().equals("") && params.get("IsAdmin").toString().trim().equals("Y")) {
				flag = true;
			} else {
				flag = communityUserInfoCheck(params);
			}
			
			result = (CoviList) tfSvc.selectCommunityBoardLeft(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", StringUtil.getSortNo(folderData.get("SortPath").toString()));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", StringUtil.getParentSortNo(folderData.get("SortPath").toString()));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				
				/*if(func.f_NullCheck(folderData.get("itemType")).equals("Root") || func.f_NullCheck(folderData.get("itemType")).equals("Folder")){
					folderData.put("url", "");
				}else{
					folderData.put("url", "javascript:goFolderContents(\"" + "Board" + "\", \"" + folderData.get("MenuID")+"\", \""+folderData.get("FolderID")+"\", \""+folderData.get("FolderType")+"\", \""+"1" + "\");");
				}*/
				 
				resultList.add(folderData);
			}
			
			if (!func.f_NullCheck(params.get("IsAdmin").toString()).trim().equals("") && params.get("IsAdmin").toString().trim().equals("Y")) {
				checkValue = "9";
			} else {
				checkValue =  UsercommunitySvc.selectCommunityUserLevelCheck(params);
			}
			
			returnData.put("memberLevel", checkValue);
			returnData.put("flag", flag);
			returnData.put("list", resultList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		} 
		
		return returnData;
	}
	
	public boolean communityUserInfoCheck(CoviMap params){
		StringUtil func = new StringUtil();
		
		try {
			if (!func.f_NullCheck(params.get("IsAdmin").toString()).trim().equals("") && params.get("IsAdmin").toString().trim().equals("Y")) {
				return true;
			} else {
				String checkValue = UsercommunitySvc.selectCommunityUserLevelCheck(params);
				if(!func.f_NullCheck(checkValue).equals("") && !func.f_NullCheck(checkValue).equals("0")){
					return true;
				}else{
					return false;
				}
			}
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	@RequestMapping(value = "layout/userTF/TFHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_Code", userDataObj.getString("USERID"));
			params.put("lang",userDataObj.getString("lang"));
			
			resultList = UsercommunitySvc.selectcommunityHeaderSetting(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userTF/setTopMenuPopup.do")
	public ModelAndView setTopMenuPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "user/tf/TFTopMenuPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("C", request.getParameter("C"));
		return mav;
	}
	
	@RequestMapping(value = "layout/userTF/selectTFHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", userDataObj.getString("USERID") );
			params.put("lang", userDataObj.getString("lang"));
			
			if(communityUserInfoCheck(params)){
				resultList = UsercommunitySvc.selectCommunityHeaderSettingList(params);
			}
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userTF/TFSubHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySubHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			resultList = UsercommunitySvc.communitySubHeaderSetting(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userTF/TFLeftUserInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLeftUserInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("UR_Code", userDataObj.getString("USERID"));
			
			resultList = tfSvc.TFLeftUserInfo(params);
			
			returnData.put("USERNAME", userDataObj.getString("USERNAME"));
			returnData.put("UR_Code", userDataObj.getString("USERID"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	// Activity 등록화면 이동
	/**
	 * goActivitySetPopup - 업무단계 설정 팝업
	 * @param mode ??
	 * @param C
	 * @param ActivityId
	 * @return ModelAndView
	 * @throws Exception 
	 */
	@RequestMapping(value = "tf/goActivitySetPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goTaskSetPopup(
			@RequestParam(value = "mode", required=false) String mode,
			@RequestParam(value = "C", required=false) String CU_ID, 
			@RequestParam(value = "ActivityId", required=false) String AT_ID, 
			@RequestParam(value = "userID", required=false) String userID) throws Exception
	{
		String returnURL = "user/tf/ActivitySetPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		CoviMap params = new CoviMap();
		params.put("mode", mode);
		params.put("CU_ID", CU_ID);
		
		if (mode.equalsIgnoreCase("MODIFY")) {
			if (userID == null) {
				userID = SessionHelper.getSession("USERID");
			}
			
			params.put("AT_ID", AT_ID);
			params.put("UserID", userID); 
			params.put("lang", SessionHelper.getSession("lang"));
			mav.addObject("taskInfo", tfSvc.getTaskData(params));
			
			//수정권한 부여
			boolean modifyAuth = false;
			CoviList performerList = tfSvc.getTaskPerformer(params);
			for (int i = 0; i < performerList.size(); i++) {
				CoviMap performer = performerList.getJSONObject(i);
				if (userID.equals(performer.getString("Code"))) {
					modifyAuth = true;
					break;
				}
			}
			
			if (!modifyAuth) {
				CoviMap detailInfo = tfSvc.selectTFDetailInfo(params);
				if (detailInfo.getJSONArray("data") != null && detailInfo.getJSONArray("data").size() != 0) {
					CoviMap detail = detailInfo.getJSONArray("data").getJSONObject(0);
					modifyAuth = userID.equals(detail.getString("TF_PM_CODE"));
				}
			}
			
			mav.addObject("pmYn", modifyAuth ? "Y" : "N");
		}
		
		return mav;
	}
	
	/**
	 * getTaskData - 작업 정보 조회
	 * @param taskID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/getTaskData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getTaskData(
			@RequestParam(value = "CU_ID", required=true) String CU_ID,
			@RequestParam(value = "AT_ID", required=true) String AT_ID
			) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("CU_ID", CU_ID);
			params.put("AT_ID", AT_ID);
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnObj.put("taskInfo", tfSvc.getTaskData(params));
			returnObj.put("performerList",tfSvc.getTaskPerformer(params));
			
			// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", CU_ID);
			filesParams.put("ObjectType", "TFAT");
			filesParams.put("MessageID", AT_ID);
			filesParams.put("Version", "0");
			
			returnObj.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * saveTaskData - 작업 정보 저장
	 * @param mode (I/U)
	 * @param taskStr
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/saveTaskData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveTaskData(MultipartHttpServletRequest request) throws Exception
	{
		String mode = request.getParameter("mode");
		String taskStr = request.getParameter("taskStr");
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(mode).equals(""))
			mode = "I";
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap taskObj = new CoviMap();
		
		try {
			String taskObjStr = taskStr; //StringEscapeUtils.unescapeHtml(taskStr);
			taskObj = CoviMap.fromObject(taskObjStr);
			
			String originName = taskObj.getString("ATName");
			String originID = taskObj.has("AT_ID") ? taskObj.getString("AT_ID") : "";
			String targetCUID = taskObj.has("CU_ID") ? taskObj.getString("CU_ID") : "";
			String isModify = mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT") ? "N" : "Y"; // I: 등록, T:임시저장, U:수정
			
			resultObj = tfSvc.isDuplicationSaveName("Task", originName, originID, targetCUID, isModify);
			taskObj.put("ATName", resultObj.getString("saveName"));
			taskObj.put("Mode", mode);	// 임시저장 처리를 위해 추가
			
			List<MultipartFile> mf = request.getFiles("files"); // [Added][FileUpload]
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT")){
				tfSvc.saveTaskData(taskObj, filesParams, mf);
			}else if(mode.equalsIgnoreCase("U") || mode.equalsIgnoreCase("UT")){
				tfSvc.modifyTaskData(taskObj, filesParams, mf);
			}
			
			returnList.put("chkDuplilcation", resultObj);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * saveTaskDataAddFile - 연관문서 등록 - 작업 정보 저장
	 * @param mode (I/U)
	 * @param taskStr
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/saveTaskDataAddFile.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveTaskDataAddFile(MultipartHttpServletRequest request) throws Exception
	{
		String mode = request.getParameter("mode");
		String taskStr = request.getParameter("taskStr");
		StringUtil func = new StringUtil();
		
		if(func.f_NullCheck(mode).equals(""))
			mode = "I";
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap taskObj = new CoviMap();
		
		try {
			String taskObjStr = taskStr;
			taskObj = CoviMap.fromObject(taskObjStr);
			
			String originName = taskObj.getString("ATName");
			String originID = taskObj.has("AT_ID") ? taskObj.getString("AT_ID") : "";
			String targetCUID = taskObj.has("CU_ID") ? taskObj.getString("CU_ID") : "";
			String isModify = mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT") ? "N" : "Y"; // I: 등록, T:임시저장, U:수정
			
			resultObj = tfSvc.isDuplicationSaveName("Task", originName, originID, targetCUID, isModify);
			taskObj.put("ATName", resultObj.getString("saveName"));
			taskObj.put("Mode", mode); // 임시저장 처리를 위해 추가
			
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			String saveMode = request.getParameter("saveMode") == null ? "" : request.getParameter("saveMode");
			
			if(saveMode.equals("Approval")){
				String fileNameArr[] = null;
				String filePathArr[] = null;
				String fileIDArr[] = null;
				String strFileIDArr = "";
				
				if(request.getParameter("fileName") != null && !request.getParameter("fileName").equals("")){
					fileNameArr = request.getParameter("fileName").split(",");
				}
				if(request.getParameter("filePath") != null && !request.getParameter("filePath").equals("")){
					filePathArr = request.getParameter("filePath").split(",");
				}
				if(request.getParameter("fileID") != null && !request.getParameter("fileID").equals("")){
					strFileIDArr = request.getParameter("fileID");
					fileIDArr = strFileIDArr.split(",");
				}
				
				if(fileNameArr != null && filePathArr != null){
					CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(strFileIDArr);
					
					for(int i = 0; i < fileNameArr.length; i++){
						String fileName = fileNameArr[i];
						String filePath = filePathArr[i];
						String fileID = fileIDArr[i];
						
						if(fileID.equals("")) {
							File file = new File(FileUtil.checkTraversalCharacter(filePath));
							try(FileInputStream ins = new FileInputStream(file);){
								MultipartFile multipartFile = new MockMultipartFile(fileName, fileName, Files.probeContentType(Paths.get(filePath)), IOUtils.toByteArray(ins));
								mf.add(multipartFile);
							}
						}else {
							CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID);
							String companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileStorageInfo.optString("CompanyCode");
							filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
							File file = new File(FileUtil.checkTraversalCharacter(filePath));
							try(FileInputStream ins = new FileInputStream(file);){
								MultipartFile multipartFile = new MockMultipartFile(fileName, fileName, Files.probeContentType(Paths.get(filePath)), IOUtils.toByteArray(ins));
								mf.add(multipartFile);
							}
						}
					}
				}
			}else if(saveMode.equals("Mail")){
				File file = new File(FileUtil.checkTraversalCharacter(request.getParameter("filePath")));
				try(FileInputStream ins = new FileInputStream(file);){
					MultipartFile multipartFile = new MockMultipartFile(request.getParameter("fileName"), file.getName(), Files.probeContentType(Paths.get(request.getParameter("filePath"))), IOUtils.toByteArray(ins));
					mf.add(multipartFile);
				}
			}else{
				mf = request.getFiles("files");
				
				if(!FileUtil.isEnableExtention(mf)){
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return returnList;
				}
			} // [Added][FileUpload]
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT")){
				tfSvc.saveTaskData(taskObj, filesParams, mf);
			}else if(mode.equalsIgnoreCase("U") || mode.equalsIgnoreCase("UT")) {
				tfSvc.modifyTaskData(taskObj, filesParams, mf);
			}
			
			returnList.put("chkDuplilcation", resultObj);
			returnList.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * deleteTaskData - 작업 삭제
	 * @param TaskID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/deleteTask.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String AT_ID[]  = StringUtil.replaceNull(request.getParameter("AT_ID"), "").split(";"); //삭제할 AT_ID ID
			String communityId = request.getParameter("communityId");
			
			for(int i = 0; i < AT_ID.length; i++){
				CoviMap params = new CoviMap();
				params.put("CU_ID",communityId);
				params.put("AT_ID",AT_ID[i]);
				tfSvc.deleteTaskData(params); //작업 삭제
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	//업무 Category조회
	@RequestMapping(value = "tf/getLevelTaskList.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getCategory(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("MemberOf", request.getParameter("MemberOf"));
			
			resultList = tfSvc.getLevelTaskList(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//작업목록조회
	@RequestMapping(value = "tf/getActivityList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getActivityList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = tfSvc.selectTaskGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectTaskGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	//나의 작업목록조회
	@RequestMapping(value = "tf/getMyActivityList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyActivityList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			int cnt = tfSvc.selectMyTaskGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectMyTaskGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	//Activity 최대,최소일자구하기 - 
	@RequestMapping(value = "tf/getActivityMinMaxDate.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getActivityMinMaxDate(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			resultList = tfSvc.selectActivityMinMaxDate(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	//진행상태조회
	@RequestMapping(value = "tf/getActivityProgress.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getActivityProgress(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("DateType", request.getParameter("DateType"));
			params.put("SDate", request.getParameter("SDate"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			resultList = tfSvc.selectActivityProgress(params);
			
			returnData.put("headerlist", resultList.get("headerlist"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	//Activity 정보 조회
	@RequestMapping(value = "tf/goActivityView.do",method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goActivityView(	
			@RequestParam(value = "mode", required=false) String mode,
			@RequestParam(value = "C", required=false) String CU_ID, 
			@RequestParam(value = "ActivityId", required=false) String AT_ID,
			@RequestParam(value = "userID", required=false) String userID) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("mode", mode);
		params.put("CU_ID", CU_ID);
		
		if(mode.equalsIgnoreCase("MODIFY")){
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			params.put("AT_ID", AT_ID);
			params.put("UserID", userID);
			
			//taskSvc.checkTaskReadData(params);
		}
		
		String returnURL = "user/tf/ActivityView";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getPerformerData - 수행자 정보 조회
	 * @param taskID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/getPerformerData.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getPerformerData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("AT_ID", request.getParameter("AT_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnObj.put("performerList",tfSvc.getTaskPerformer(params));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	//프로젝트룸 정보 출력
	@RequestMapping(value = "tf/getTFPrintData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTFPrintData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		CoviMap resultData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultData = tfSvc.selectTFDetailInfo(params);
			returnData.put("TFInfo", resultData.get("data"));
			
			resultList = tfSvc.selectTFPrintData(params);
			
			returnData.put("tasklist", resultList.get("tasklist"));
			returnData.put("memberlist", resultList.get("memberlist"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 엑셀 업로드 팝업
	@RequestMapping(value = "tf/goTFTaskExcelUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationInsertByExcel1Popup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/tf/TFTaskExcelUploadPopup");
	}
	
	// 엑셀 업로드 > 템플릿 파일 다운로드
	@RequestMapping(value = "tf/excelTemplateDownload.do", method = RequestMethod.POST )
	public void excelTemplateDownload(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "CU_ID", required = false, defaultValue="" ) String prjcode)
	{
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		
		try {
			CoviMap params =  new CoviMap();
			params.put("CU_ID", prjcode);
			
			CoviMap resultList = new CoviMap();
			resultList = tfSvc.getTFMemberInfo(params);
			CoviList jArray =  resultList.getJSONArray("memberList");
			
			String memList[] = new String[jArray.size()] ;
			
			for(int i=0 ; i < jArray.size(); i++){
				memList[i] = jArray.getJSONObject(i).getString("NickName") + "(" + jArray.getJSONObject(i).getString("UserCode") + ")";
			}
			
			String FileName = "TFProjectTaskInsert_template.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//TFProjectTaskInsert_template.xlsx");
			
			DataValidation dataValidation = null;
			DataValidationConstraint constraint = null;
			DataValidationHelper validationHelper = null;
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, new CoviMap());
			XSSFSheet realSheet = (XSSFSheet) resultWorkbook.getSheetAt(0);
			
			if (jArray.size() > 0){
				validationHelper = new XSSFDataValidationHelper(realSheet);
				CellRangeAddressList addressList = new CellRangeAddressList(1, 1000, 5, 5);
				constraint = validationHelper.createExplicitListConstraint(memList);
				dataValidation = validationHelper.createValidation(constraint, addressList);
				dataValidation.setSuppressDropDownArrow(true);
				dataValidation.setShowErrorBox(true);
				dataValidation.createErrorBox("ERROR", "프로젝트 구성원만에 있는 인원만 등록할 수 있습니다");
				realSheet.addValidationData(dataValidation);
			}
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 엑셀 업로드(업무등록)
	@RequestMapping(value = "tf/excelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile,
			@RequestParam(value = "CU_ID", required = false, defaultValue="") String prjcode)
	{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			params.put("CU_ID", prjcode);
			
			int	result = tfSvc.insertProjectTaskByExcel(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "업로드 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * Activity 엑셀 다운로드
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping(value = "tf/ExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView messageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String bizSection = request.getParameter("bizSection");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			String headerKey = request.getParameter("headerKey");
			String communityID = request.getParameter("CU_ID");
			
			if(request.getParameter("sortBy") != null && !request.getParameter("sortBy").equals("")){
				String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
				String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			}
			
			String[] headerNames = headerName.split("\\|");
			
			params.put("bizSection", bizSection);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("headerKey", headerKey);
			params.put("CU_ID", communityID);
			
			resultList = tfSvc.selectTaskGridList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "TF_" + communityID);
			mav = new ModelAndView(returnURL, viewParams);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	//간트차트 iframe url 이동처리
	@RequestMapping(value = "/goGanttView.do", method = RequestMethod.GET)
	public ModelAndView goProjectGanttByPrjCode(HttpServletRequest request, Locale locale, Model model) throws Exception {
		return new ModelAndView("user/tf/GanttView");
	}
	
	//가중치 합계 체크
	@RequestMapping(value = "tf/getSumTaskWeight.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSumTaskWeight(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
			String isModify = mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT") ? "N" : "Y"; // I: 등록, T:임시저장, U:수정
			
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("AT_ID", request.getParameter("AT_ID"));
			params.put("MemberOf", request.getParameter("MemberOf"));
			params.put("mode", request.getParameter("mode"));
			params.put("isModify", isModify);
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnData.put("SumTaskWeight", tfSvc.selectSumTaskWeight(params));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * selectUserMailList - 프로젝트 수행자 메일주소 조회
	 * @param taskID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "tf/selectUserMailList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserMailList(@RequestParam(value = "userCode[]", required=false) String[] userCode) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			CoviList userList = tfSvc.selectUserMailList(params);
			returnData.put("userList", userList); 
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
	
	@RequestMapping(value = "layout/selectUserTFGridListPopup.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserTFGridListPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			int cnt = tfSvc.selectUserTFGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = tfSvc.selectUserTFGridList(params);
			
			if(params.get("AppStatus") == null || "".equals(params.getString("AppStatus"))) {
				params.put("projectInfo", tfSvc.selectUserTFGridListGroupCount(params));
			}
			
			returnData.put("page", params);
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
	
	// 연결업무 협업업무 리스트 팝업
	@RequestMapping(value = "tf/goTFListLinkPopup.do", method = RequestMethod.GET)
	public ModelAndView goTFListLinkPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/tf/TFListLinkPopup");
	}
}
