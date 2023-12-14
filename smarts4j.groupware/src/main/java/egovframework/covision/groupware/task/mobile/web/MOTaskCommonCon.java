package egovframework.covision.groupware.task.mobile.web;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.survey.user.service.SurveySvc;
import egovframework.covision.groupware.survey.user.web.SurveyVO;
import egovframework.covision.groupware.task.user.service.TaskSvc;

//모바일 설문
@Controller
@RequestMapping("/mobile/task")
public class MOTaskCommonCon {

	private static final String FILE_SERVICE_TYPE = "Task";
	
	@Autowired
	private TaskSvc taskSvc;

	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	// 공유 또는 개인 폴더 목록 조회(트리용)
	@RequestMapping(value = "/getFolderList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		String type = request.getParameter("type");
		String userID = request.getParameter("userID");
				
		try {
			if(type == null){
				type = "All";
			}
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);

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
			returnObj.put("message",isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message",isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 폴더 별 항목 조회
	@RequestMapping(value = "/getFolderItemList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderItemList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		String folderID = request.getParameter("folderID");
		String isMine = request.getParameter("isMine");
		String userID = StringUtil.replaceNull(request.getParameter("userID"), "");
		String stateCode = StringUtil.replaceNull(request.getParameter("stateCode"), "");
		String searchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String searchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String sortColumn = StringUtil.replaceNull(request.getParameter("sortColumn"), "");
		String sortDirection = StringUtil.replaceNull(request.getParameter("sortDirection"), "");
		
		try {
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("isMine", isMine);
			params.put("userID", userID);
			params.put("stateCode", stateCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultObj = taskSvc.getFolderItemList(params);
			
			returnObj.put("FolderInfo", resultObj.get("FolderInfo"));
			returnObj.put("FolderList", resultObj.get("FolderList"));
			returnObj.put("TaskList", resultObj.get("TaskList"));
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

	// 폴더 삭제
	@RequestMapping(value = "/deleteFolderData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteFolderData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnList = new CoviMap();
		String FolderID = request.getParameter("FolderID");
		
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
	
	// 업무 삭제
	@RequestMapping(value = "/deleteTaskData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteTaskData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnList = new CoviMap();
		String TaskID = request.getParameter("TaskID");
		
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

	// 폴더 정보 조회
	@RequestMapping(value = "/getFolderData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getFolderData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String folderID = request.getParameter("FolderID");
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
	
	// 상위 폴더 정보 및 공유 멤버 조회(공유 멤버는 상위에 속하는 모든 폴더의 공유자 정보 조회)
	@RequestMapping(value = "/getParentFolderData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getParentFolderData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String parentFolderID = request.getParameter("ParentFolderID");
		String isMine = request.getParameter("isMine"); //TODO : 필요한 값인가?
		
		CoviMap returnList = new CoviMap();
		
		try {
			if(isMine == null){
				isMine = "Y";
			}
			
			CoviMap params = new CoviMap();
			params.put("ParentFolderID",parentFolderID);
			params.put("FolderID", parentFolderID);
			params.put("isMine","Y");
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			
			returnList.put("folderData",  taskSvc.getFolderData(params));
			returnList.put("shareMemberList",  taskSvc.getParentFolderShareMember(params));
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
	
	// 폴더 추가 및 수정
	@RequestMapping(value = "/saveFolderData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap saveFolderData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String mode = request.getParameter("mode");
		String folderStr = request.getParameter("folderStr");
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap folderObj = new CoviMap();
		
		try {
			if(mode == null){
				mode = "I";
			}
			
			String folderObjStr = StringEscapeUtils.unescapeHtml(folderStr);
			folderObj = CoviMap.fromObject(folderObjStr);
			
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
	

	// 업무 추가 및 수정
	@RequestMapping(value = "/saveTaskData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap saveTaskData(MultipartHttpServletRequest request) throws Exception {
		
		String mode = request.getParameter("mode");
		String taskStr = request.getParameter("taskStr");
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap taskObj = new CoviMap();
		
		try {
			if(mode == null){
				mode = "I";
			}
			
			String taskObjStr = StringEscapeUtils.unescapeHtml(taskStr);
			taskObj = CoviMap.fromObject(taskObjStr);
			
			String originName = taskObj.getString("Subject");
			String originID = taskObj.has("TaskID") ?  taskObj.getString("TaskID")  : "";
			String targetFolderID = taskObj.has("FolderID") ?  taskObj.getString("FolderID")  : "";
			String isModify = mode.equalsIgnoreCase("I") ?  "N" : "Y";			// I: 등록, U:수정
			
			resultObj = taskSvc.isDuplicationSaveName("Task", originName, originID, targetFolderID, isModify);
			taskObj.put("Subject", resultObj.getString("saveName"));
			taskObj.put("Mode", mode);		

			List<MultipartFile> mf = request.getFiles("files");		// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(mode.equalsIgnoreCase("I")){
				taskSvc.saveTaskDataMobile(taskObj, filesParams, mf);
			}else if(mode.equalsIgnoreCase("U")){
				taskSvc.modifyTaskDataMobile(taskObj, filesParams, mf);
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
	
	// 폴더 이동
	@RequestMapping(value = "/moveFolder.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap moveFolder(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String folderID = request.getParameter("FolderID");
		String targetFolderID = StringUtil.replaceNull(request.getParameter("targetFolderID"), ""); //TODO : 필요한 값인가?
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String isHaveShareChild = taskSvc.isHaveShareChild(folderID);
			
			if(! isHaveShareChild.equalsIgnoreCase("Y")){
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
	

	// 업무 이동
	@RequestMapping(value = "/moveTask.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap moveTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String  taskID = request.getParameter("TaskID");
		String targetFolderID = request.getParameter("targetFolderID"); 
		
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

	// 업무 복사
	@RequestMapping(value = "/copyTask.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap copyTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String  taskID = request.getParameter("TaskID");
		String targetFolderID = request.getParameter("targetFolderID"); 
		
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
	
	// 업무 복사
	@RequestMapping(value = "/getTaskData.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getTaskData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String taskID = request.getParameter("TaskID");
		String folderID = request.getParameter("FolderID");
		
		CoviMap returnObj = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();
			params.put("TaskID", taskID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserID", SessionHelper.getSession("USERID"));
			
			//조회 표시
			taskSvc.checkTaskReadData(params);
			
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
	@RequestMapping(value = "/getShareUseList.do", method={RequestMethod.POST , RequestMethod.GET})
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
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("FolderID",folderID);
			params.put("KeyWord", keyword); 
			params.put("lang", SessionHelper.getSession("lang")); 
			
			if(keyword == null || "".equals(keyword)){
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));				
				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
			}
			
			resultObj = taskSvc.getShareUseList(params);
			
			returnList.put("list", resultObj.get("list"));
			
			if(resultObj.containsKey("page")) {
				returnList.put("page", resultObj.get("page"));
			}
			
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
}
