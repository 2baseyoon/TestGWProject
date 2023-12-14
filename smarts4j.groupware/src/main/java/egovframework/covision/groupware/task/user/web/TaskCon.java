package egovframework.covision.groupware.task.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
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
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.task.user.service.TaskSvc;
import egovframework.covision.groupware.util.BoardUtils;



/**
 * @Class Name : TaskCon.java
 * @Description : 업무관리 사용자 요청 처리
 * @Modification Information 
 * @ 2017.09.28 최초생성
 *
 * @author 코비젼 연구1팀
 * @since  2017.09.28 
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class TaskCon {
	private static final String FILE_SERVICE_TYPE = "Task";
	
	@Autowired
	private TaskSvc taskSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * goFolderSetPopup - 폴더 설정 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "task/goFolderSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goFolderSetPopup() {
		String returnURL = "user/task/FolderSetPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goTaskSetPopup - 업무 설정 팝업
	 * @param mode
	 * @param taskID
	 * @param userID
	 * @return ModelAndView
	 * @throws Exception 
	 */
	@RequestMapping(value = "task/goTaskSetPopup.do",method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goTaskSetPopup(	@RequestParam(value = "mode", required=false) String mode,
			@RequestParam(value = "taskID", required=false) String taskID, 
			@RequestParam(value = "userID", required=false) String userID) throws Exception {
		if(mode.equalsIgnoreCase("MODIFY")){
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("TaskID", taskID);
			params.put("UserID", userID);
			
			taskSvc.checkTaskReadData(params);
		}
		
		String returnURL = "user/task/TaskSetPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goFolderTreePopup - 이동/복사 시 사용하는 폴더 트리 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "task/goFolderTreePopup.do", method = RequestMethod.GET )
	public ModelAndView goFolderTreePopup() {
		String returnURL = "user/task/FolderTreePopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goShareUserListPopup - 해당 폴더를 볼 수 있는 공유자 목록
	 * @return ModelAndView
	 */
	@RequestMapping(value = "task/goShareUserListPopup.do", method = RequestMethod.GET)
	public ModelAndView goShareUserList() {
		String returnURL = "user/task/ShareUserListPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * checkAuthority - 권한 확인
	 * @param folderID
	 * @param userID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/checkAuthority.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap checkAuthority(
			@RequestParam(value = "FolderID", required=true) String folderID) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			
			returnObj.put("haveAuthority", taskSvc.checkAuthority(params) );
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getFolderList - 공유 또는 개인 폴더 목록 조회(트리용)
	 * @param type(All- 개인,공유 폴더 모두 조회 / Person-개인 폴더 조회 / Share - 공유 폴더 조회)
	 * @param userID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getFolderList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderList(
			@RequestParam(value = "type", required=false, defaultValue="All") String type,
			@RequestParam(value = "userID", required=false) String userID) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			if( type.equalsIgnoreCase("All") ){
				returnObj.put("PersonList", taskSvc.getPersonalFolderList(params) );
				returnObj.put("ShareList", taskSvc.getShareFolderList(params));
			}else if( type.equalsIgnoreCase("Person") ){
				returnObj.put("PersonList", taskSvc.getPersonalFolderList(params) );
			}else if( type.equalsIgnoreCase("Share") ){
				returnObj.put("ShareList", taskSvc.getShareFolderList(params));
			}
			
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getSearchAll - 전체 검색 ( 쿼리가 복잡하고 다른 항목들과 매개변수가 다른 관계로 별도 con 사용)
	 * @param type
	 * @param sortColumn
	 * @param sortDirection
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getSearchAll.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getSearchAll(
			@RequestParam(value = "searchWord", required=false) String searchWord,
			@RequestParam(value = "stateCode", required=false) String stateCode,
			@RequestParam(value = "sortColumn", required=false) String sortColumn,
			@RequestParam(value = "sortDirection", required=false) String sortDirection) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("searchWord", ComUtils.RemoveSQLInjection(URLDecoder.decode(searchWord,"UTF-8"), 100));
			params.put("stateCode", stateCode);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultObj = taskSvc.getSearchAll(params);
			
			returnObj.put("FolderList", resultObj.get("FolderList") );
			returnObj.put("TaskList", resultObj.get("TaskList") );
			returnObj.put("TempTaskList", resultObj.get("TempTaskList") );
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 *  getFolderItemList - 폴더 별 항목 조회
	 * @param folderID
	 * @param userID
	 * @param state
	 * @param searchType
	 * @param searchWord
	 * @param sortColumn
	 * @param sortDirection
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getFolderItemList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderItemList(
			@RequestParam(value = "folderID", required=true) String folderID,
			@RequestParam(value = "isMine", required=true) String isMine,
			@RequestParam(value = "stateCode", required=false) String stateCode,
			@RequestParam(value = "searchType", required=false) String searchType,
			@RequestParam(value = "searchWord", required=false) String searchWord,
			@RequestParam(value = "sortColumn", required=false) String sortColumn,
			@RequestParam(value = "sortDirection", required=false) String sortDirection) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("isMine", isMine);
			params.put("stateCode", stateCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultObj = taskSvc.getFolderItemList(params);
			
			returnObj.put("FolderInfo", resultObj.get("FolderInfo"));
			returnObj.put("FolderList", resultObj.get("FolderList"));
			returnObj.put("TaskList", resultObj.get("TaskList"));
			returnObj.put("TempTaskList", resultObj.get("TempTaskList"));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "task/getFolderData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderData(
			@RequestParam(value = "FolderID", required=true) String folderID) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnObj.put("folderInfo", taskSvc.getFolderData(params));
			returnObj.put("shareMemberList",taskSvc.getFolderShareMember(params));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getTaskData - 업무 정보 조회
	 * @param taskID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getTaskData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getTaskData(
			@RequestParam(value = "TaskID", required=true) String taskID,
			@RequestParam(value = "FolderID", required=true) String folderID) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("TaskID", taskID);
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnObj.put("taskInfo", taskSvc.getTaskData(params));
			returnObj.put("performerList",taskSvc.getTaskPerformer(params));
			
			// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", folderID);
			filesParams.put("ObjectType", "TKFD");
			filesParams.put("MessageID", taskID);
			filesParams.put("Version", "0");
			
			returnObj.put("fileList", fileSvc.selectAttachAll(filesParams));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * saveFolderData - 폴더 추가 및 수정
	 * @param mode (Detail / Summary)
	 * @param evnetID
	 * @param dateID
	 * @param repeatID
	 * @param folderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/saveFolderData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveFolderData(
			@RequestParam(value = "mode", required = false, defaultValue="I") String mode,
			@RequestParam(value = "folderStr", required = true) String folderStr) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap folderObj = new CoviMap();
		
		try {
			String folderObjStr = StringEscapeUtils.unescapeHtml(folderStr);
			folderObj = CoviMap.fromObject(folderObjStr);
			
			String originName = folderObj.getString("DisplayName");
			String originID = folderObj.has("FolderID") ?  folderObj.getString("FolderID")  : "";
			String targetFolderID = folderObj.has("ParentFolderID") ?  folderObj.getString("ParentFolderID")  : "";
			String isModify = mode.equalsIgnoreCase("I") ?  "N" : "Y";
			
			resultObj = taskSvc.isDuplicationSaveName("Folder", originName, originID, targetFolderID, isModify);
			
			folderObj.put("DisplayName", resultObj.getString("saveName"));
			
			if(mode.equalsIgnoreCase("I")){
				taskSvc.saveFolderData(folderObj);
			}else if(mode.equalsIgnoreCase("U")){
				taskSvc.modifyFolderData(folderObj);
			}
			
			returnList.put("chkDuplilcation", resultObj);
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
	 * deleteFolderData - 폴더 삭제
	 * @param FolderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/deleteFolderData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteFolderData(
			 @RequestParam(value = "FolderID", required = true) String FolderID) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", FolderID);
			
			taskSvc.deleteFolderData(params);
			
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
	 * deleteTaskData - 업무 삭제
	 * @param TaskID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/deleteTaskData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteTaskData(
			@RequestParam(value = "TaskID", required = true) String TaskID) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("TaskID", TaskID);
			
			taskSvc.deleteTaskData(params);
			
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
	 * saveTaskData - 업무 정보 저장
	 * @param mode (I/U)
	 * @param taskStr
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/saveTaskData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveTaskData(MultipartHttpServletRequest request) throws Exception {
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
			
			String originName = taskObj.getString("Subject");
			String originID = taskObj.has("TaskID") ?  taskObj.getString("TaskID")  : "";
			String targetFolderID = taskObj.has("FolderID") ?  taskObj.getString("FolderID")  : "";
			String isModify = mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT") ?  "N" : "Y"; // I: 등록, T:임시저장, U:수정
			
			resultObj = taskSvc.isDuplicationSaveName("Task", originName, originID, targetFolderID, isModify);
			taskObj.put("Subject", resultObj.getString("saveName"));
			taskObj.put("Mode", mode); // 임시저장 처리를 위해 추가
			
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
				taskSvc.saveTaskData(taskObj, filesParams, mf);
			}else if(mode.equalsIgnoreCase("U") || mode.equalsIgnoreCase("UT")) {
				taskSvc.modifyTaskData(taskObj, filesParams, mf);
			}
			
			returnList.put("chkDuplilcation", resultObj);
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
	 * saveTaskDataAddFile - 연관문서 등록 - 업무 정보 저장
	 * @param mode (I/U)
	 * @param taskStr
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/saveTaskDataAddFile.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveTaskDataOtherFile(MultipartHttpServletRequest request) throws Exception {
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
			
			String originName = taskObj.getString("Subject");
			String originID = taskObj.has("TaskID") ?  taskObj.getString("TaskID")  : "";
			String targetFolderID = taskObj.has("FolderID") ?  taskObj.getString("FolderID")  : "";
			String isModify = mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT") ?  "N" : "Y"; // I: 등록, T:임시저장, U:수정
			
			resultObj = taskSvc.isDuplicationSaveName("Task", originName, originID, targetFolderID, isModify);
			taskObj.put("Subject", resultObj.getString("saveName"));
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
							try( FileInputStream ins = new FileInputStream(file); ){
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
				mf = request.getFiles("files"); // [Added][FileUpload]
			
				if(!FileUtil.isEnableExtention(mf)){
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return returnList;
				}
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(mode.equalsIgnoreCase("I") || mode.equalsIgnoreCase("IT")){
				taskSvc.saveTaskData(taskObj, filesParams, mf);
			}else if(mode.equalsIgnoreCase("U") || mode.equalsIgnoreCase("UT")) {
				taskSvc.modifyTaskData(taskObj, filesParams, mf);
			}
			
			returnList.put("chkDuplilcation", resultObj);
			returnList.put("status", Return.SUCCESS);
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
	 * copyTask - 업무복사 - 내 업무 내에서만 가능
	 * @param taskID
	 * @param targetFolderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/copyTask.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap copyTask(
			@RequestParam(value = "TaskID", required = true) String taskID,
			@RequestParam(value = "targetFolderID", required = true) String targetFolderID) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String userID = SessionHelper.getSession("USERID");
			CoviMap params = new CoviMap();
			params.put("originTaskID", taskID);
			params.put("targetFolderID",targetFolderID);
			params.put("OwnerCode", userID);
			params.put("RegisterCode", userID);
			
			resultObj = taskSvc.isDuplicationName("Task", taskID, targetFolderID, "Y"); 
			params.put("saveName", resultObj.getString("saveName"));
			
			taskSvc.copyTask(params);
			
			returnList.put("chkDuplilcation", resultObj);
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
	 * moveTask - 업무 이동
	 * @param TaskID
	 * @param targetFolderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/moveTask.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap moveTask(
			@RequestParam(value = "TaskID", required = true) String taskID,
			@RequestParam(value = "targetFolderID", required = true) String targetFolderID) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			resultObj = taskSvc.isDuplicationName("Task", taskID, targetFolderID, "N"); 
			
			CoviMap params = new CoviMap();
			params.put("originTaskID", taskID);
			params.put("targetFolderID",targetFolderID);
			params.put("saveName", resultObj.getString("saveName"));
			
			taskSvc.moveTask(params); 
			
			returnList.put("chkDuplilcation", resultObj);
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
	 * moveFolder - 폴더 이동
	 * @param FolderID
	 * @param targetFolderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/moveFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap moveFolder(
			@RequestParam(value = "FolderID", required = true) String folderID,
			@RequestParam(value = "targetFolderID", required = true) String targetFolderID) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String isHaveShareChild = taskSvc.isHaveShareChild(folderID);
			
			if(!isHaveShareChild.equalsIgnoreCase("Y")){
				resultObj = taskSvc.isDuplicationName("Folder", folderID, targetFolderID, "N");
				
				CoviMap params = new CoviMap();
				params.put("originFolderID", folderID);
				if(!targetFolderID.equals("0")){
					params.put("targetFolderID",targetFolderID);
				}
				params.put("saveName", resultObj.getString("saveName"));
				
				taskSvc.moveFolder(params);
			}
			
			returnList.put("isHaveShareChild", isHaveShareChild);
			returnList.put("chkDuplilcation", resultObj);
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
	 * getFolderShareMember - 폴더의 공유멤버 조회
	 * @param FolderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getFolderShareMember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderShareMember(
			@RequestParam(value = "FolderID", required = true) String folderID) throws Exception {
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID",folderID);
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = taskSvc.getFolderShareMember(params); 
			
			returnList.put("list", resultList);
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
	 * getParentFolderData - 상위 폴더 정보 및 공유 멤버 조회(공유 멤버는 상위에 속하는 모든 폴더의 공유자 정보 조회)
	 * @param parentFolderID
	 * @param isMine
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getParentFolderData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getParentFolderData(
			@RequestParam(value = "ParentFolderID", required = true) String parentFolderID,
			@RequestParam(value = "isMine", required = true, defaultValue="Y") String isMine) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("ParentFolderID", parentFolderID);
			params.put("FolderID", parentFolderID);
			params.put("isMine", "Y");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			returnList.put("folderData", taskSvc.getFolderData(params));
			returnList.put("shareMemberList", taskSvc.getParentFolderShareMember(params));
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
	 *  getShareUseList - 해당 폴더에 접근 권한이 있는 모든 사용자 조회 (자동완성 및 목록 조회 화면에서 사용)
	 * @param taskID
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param searchWord
	 * @param keyword - 자동완성일 경우만 값이 넘어옴
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getShareUseList.do", method={RequestMethod.POST , RequestMethod.GET})
	public @ResponseBody CoviMap getShareUseList(
			@RequestParam(value = "FolderID", required = true) String folderID,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "searchWord", required = false) String searchWord,
			@RequestParam(value = "keyword", required = false) String keyword) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		try {
			int pageOffset = (pageNo - 1) * pageSize;
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("FolderID",folderID);
			params.put("userCode",SessionHelper.getSession("UR_Code"));
			params.put("KeyWord", keyword); 
			params.put("lang", SessionHelper.getSession("lang"));
			
			if(keyword == null){
				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
				params.put("pageOffset", pageOffset);
				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("rowStart", pageOffset);	 // rowStart: Oracle 페이징처리용
				params.put("rowEnd", pageOffset+pageSize); // rowEnd: Oracle 페이징처리용
			}
			
			resultObj = taskSvc.getShareUseList(params);
			
			if(keyword == null){
				CoviMap pageParam  = new CoviMap();
				pageParam.addAll(ComUtils.setPagingData(params,resultObj.getInt("cnt"))); // 페이징 parameter set
				returnList.put("page",pageParam) ;
			}
			
			returnList.put("list", resultObj.get("list"));
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
	 * goTaskSearchPopup - 업무 검색 팝업
	 * @param mode
	 * @param taskID
	 * @param userID
	 * @return ModelAndView
	 * @throws Exception 
	 */
	@RequestMapping(value = "task/goTaskSearchPopup.do",method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goTaskSearchPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "user/task/TaskSearchPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * selectTaskSearchList - 업무 검색 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "task/selectTaskSearchList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectTaskSearchList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap params = new CoviMap();
			params.put("userID", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			BoardUtils.setRequestParam(request, params);
			params.put("searchWord", ComUtils.RemoveSQLInjection(request.getParameter("searchWord"), 100));
			
			if(params.get("sortBy") != null){
				params.put("sortColumn", params.get("sortBy").toString().split(" ")[0]);
				params.put("sortDirection", params.get("sortBy").toString().split(" ")[1]);
			}
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			CoviMap page = new CoviMap();
			
			if(params.containsKey("pageNo")) {
				int cnt = taskSvc.selectTaskSearchListCnt(params);
			 	page = ComUtils.setPagingData(params,cnt);
			 	params.addAll(page);
			 	returnData.put("page", page);
			}
			
			resultList = taskSvc.selectTaskSearchList(params);
			
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
}
