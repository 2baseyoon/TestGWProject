package egovframework.covision.groupware.schedule.mobile.web;

import java.util.Calendar;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

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
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.schedule.admin.service.ScheduleManageSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;

@Controller
@RequestMapping("/mobile/schedule")
public class MOScheduleCommonCon {
	
	//private final String FILE_SERVICE_TYPE = "Schedule";

	@Autowired
	private ScheduleSvc scheduleSvc;
	
	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	@Autowired
	private ScheduleManageSvc scheduleManageSvc;
	
	@Autowired
	private FileUtilService fileSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 일정 보기 (월간보기, 주간보기, 일간보기, 중요일정)
	 * @param request
	 * @param folderIDs
	 * @param startDate
	 * @param endDate
	 * @param userCode
	 * @param lang
	 * @param importanceState
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getView.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getView(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "IsShareCheck", required = true, defaultValue = "") String isShareCheck,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "ImportanceState", required = true, defaultValue = "") String importanceState,
			@RequestParam(value = "IsMobile", required = false, defaultValue = "Y") String isMobile ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList scheduleList = null;
			
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("UserCode", userCode);
			params.put("lang", lang);
			params.put("ImportanceState", importanceState);		// 중요일정
			params.put("IsMobile", isMobile);
			
			params.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID"));			// 공유 일정 ID
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));		// 개인 일정 ID
			
			scheduleList = scheduleSvc.selectView(params);
			
			returnList.put("list", scheduleList);
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
	 * 일정 목록 조회
	 * @param request
	 * @param folderIDs
	 * @param startDate
	 * @param endDate
	 * @param userCode
	 * @param lang
	 * @param importanceState
	 * @param subject
	 * @param placeName
	 * @param registerName
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "ImportanceState", required = true, defaultValue = "") String importanceState,
			@RequestParam(value = "Subject", required = true, defaultValue = "") String subject,
			@RequestParam(value = "PlaceName", required = true, defaultValue = "") String placeName,
			@RequestParam(value = "RegisterName", required = true, defaultValue = "") String registerName,
			@RequestParam(value = "IsMobile", required = false, defaultValue = "Y") String isMobile ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("UserCode", userCode);
			params.put("lang", lang);
			params.put("ImportanceState", importanceState);
			params.put("Subject", subject);
			params.put("PlaceName", placeName);
			params.put("RegisterName", registerName);
			params.put("IsMobile", isMobile);
			
			params.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID"));			// 공유 일정 ID
			
			int cnt = scheduleSvc.selectViewCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = scheduleSvc.selectView(params);
			
			returnList.put("page", params);
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
	 * 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getACLFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLFolder(HttpServletRequest request) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		
		CoviList createObj = new CoviList();
		CoviList deleteObj = new CoviList();
		CoviList modifyObj = new CoviList();
		CoviList readObj = new CoviList();
		
		boolean isCommunity = Boolean.parseBoolean(request.getParameter("isCommunity"));
		
		try {
			String createStr = "";
			String deleteStr = "";
			String modifyStr = "";
			String readStr = "";
			String viewStr = "";
			
			CoviMap params = new CoviMap();
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			params.put("ScheduleTotalID", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
			params.put("ScheduleThemeID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));
			params.put("ScheduleCafeID", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap userInfoObj = SessionHelper.getSession();
			
			ACLMapper aclMapSchedule;
			ACLMapper aclMapCommunity = ACLHelper.getACLMapper(userInfoObj, "FD", "Community");
			
			Set<String> createSet = aclMapCommunity.getACLInfo("C");
			Set<String> deleteSet = aclMapCommunity.getACLInfo("D");
			Set<String> modifySet = aclMapCommunity.getACLInfo("M");
			Set<String> viewSet = aclMapCommunity.getACLInfo("V");
			Set<String> readSet = aclMapCommunity.getACLInfo("R");
			
			if(!isCommunity){
				aclMapSchedule = ACLHelper.getACLMapper(userInfoObj, "FD", "Schedule");
				
				createSet.addAll(aclMapSchedule.getACLInfo("C"));
				deleteSet.addAll(aclMapSchedule.getACLInfo("D"));
				modifySet.addAll(aclMapSchedule.getACLInfo("M"));
				viewSet.addAll(aclMapSchedule.getACLInfo("V"));
				readSet.addAll(aclMapSchedule.getACLInfo("R"));
			}
			
			createStr = eventSvc.getACLFolderData(createSet, "C");
			deleteStr = eventSvc.getACLFolderData(deleteSet, "D");
			modifyStr = eventSvc.getACLFolderData(modifySet, "M");
			viewStr = eventSvc.getACLFolderData(viewSet, "V");
			readStr = eventSvc.getACLFolderData(readSet, "R");
			
			params.put("C_FolderIDs", createStr);
			params.put("D_FolderIDs", deleteStr);
			params.put("M_FolderIDs", modifyStr);
			params.put("V_FolderIDs", viewStr);
			params.put("R_FolderIDs", readStr);
			
			params.put("C_FolderIDArr", createStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("D_FolderIDArr", deleteStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("M_FolderIDArr", modifyStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("V_FolderIDArr", viewStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("R_FolderIDArr", readStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));

			CoviList folderData = scheduleSvc.selectACLData(params);
			for(Object obj : folderData){
				CoviMap folder = (CoviMap) obj;
				String type = folder.getString("type");
				
				switch (type) {
				case "C":
					createObj.add(folder);
					break;
				case "D":
					deleteObj.add(folder);
					break;
				case "M":
					modifyObj.add(folder);
					break;
				case "R":
					readObj.add(folder);
					break;
				default :
					break;
				}
			}
			
			returnObj.put("create", createObj);
			returnObj.put("delete", deleteObj);
			returnObj.put("modify", modifyObj);
			returnObj.put("read", readObj);
			
			returnObj.put("result", "ok");
			
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
	 *  왼쪽 메뉴, 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getACLLeftFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLLeftFolder(HttpServletRequest request) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			params.put("ScheduleTotalID", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
			params.put("ScheduleThemeID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));
			params.put("ScheduleCafeID", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap userDataObj = SessionHelper.getSession();
			
			//View
			String objectInStr = eventSvc.getACLFolderData(userDataObj, "Schedule", "V");
			String objectInStrCommunity = eventSvc.getACLFolderData(userDataObj, "Community", "V");
			
			if(!objectInStrCommunity.equals(""))
				objectInStr = objectInStr.replace(")", ",") + objectInStrCommunity.replace("(", "");
			
			params.put("FolderIDs", objectInStr);
			params.put("FolderIDArr", objectInStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			
			returnObj.put("totalFolder", scheduleSvc.selectTreeMenuTotal(params));
			returnObj.put("listFolder", scheduleSvc.selectTreeMenu(params));
			
			returnObj.put("result", "ok");
			
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
	 * 일정 등록
	 * @param request
	 * @param mode
	 * @param eventStr
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/setOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setOne(HttpServletRequest request) throws Exception {
		
		String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
		String eventStr = request.getParameter("eventObj");
		String isChangeDate = StringUtil.replaceNull(request.getParameter("isChangeDate"), "");
		String isChangeRes = StringUtil.replaceNull(request.getParameter("isChangeRes"), "");
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap eventObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(eventStr));
		
		try {			
			if(mode.equals("I"))
				resultObj = scheduleSvc.insertSchedule(eventObj, null, null);
			else if(mode.equals("U"))
				resultObj = scheduleSvc.updateSchedule(eventObj, null, null);
			else if(mode.equals("RU"))
				resultObj = scheduleSvc.setEachSchedule(eventObj, null, null, isChangeDate, isChangeRes, true);
			
			returnList.put("result", resultObj.getString("retType")); //OK or DUPLICATION
			returnList.put("status", Return.SUCCESS);
			returnList.put("message",resultObj.getString("retMsg"));
			
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
	 * 일정 조회
	 * @param request
	 * @param mode
	 * @param lang
	 * @param eventID
	 * @param dateID
	 * @param isRepeat
	 * @param userCode
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/goOne.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public @ResponseBody CoviMap goOne(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
			@RequestParam(value = "IsRepeat", required = true, defaultValue = "") String isRepeat,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "FolderID", required = true, defaultValue = "") String folderID) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang", lang);
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("IsRepeat", isRepeat);
			params.put("UserCode", userCode);
			
			if(mode.equals("D") || mode.equals("DU"))
				resultList = scheduleSvc.getOneDetail(params);
			else if(mode.equals("S"))
				resultList = scheduleSvc.getOneSimple(params);
			
		/*	// [Added][FileUpload]
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("ObjectID", folderID);
			filesParams.put("ObjectType", "FD");
			filesParams.put("MessageID", eventID);
			filesParams.put("Version", "0");
			resultList.put("fileList", fileSvc.selectAttachAll(filesParams));
			*/
			returnObj.put("data", resultList);
			returnObj.put("result", "ok");
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
	 * 일정 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap remove(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			
			if(mode.equalsIgnoreCase("RU")){
				eventSvc.deleteEventDateByDateID(params);
			}else{
				scheduleSvc.deleteEvent(params);
			}
			
			// TODO 참석자 개인일정 삭제 후 알림
			
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
	 * 일정 알림 개별 수정
	 * @param request
	 * @param eventID
	 * @param registerCode
	 * @param isNotification
	 * @param isReminder
	 * @param reminderTime
	 * @param isCommentNotification
	 * @param mediumKind
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/setNotification.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setNotification(HttpServletRequest request, 
			@RequestParam(value = "UpdateType", required = true, defaultValue = "") String updateType,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
			@RequestParam(value = "RegisterCode", required = true, defaultValue = "") String registerCode,
			@RequestParam(value = "IsNotification", required = true, defaultValue = "") String isNotification,
			@RequestParam(value = "IsReminder", required = true, defaultValue = "") String isReminder,
			@RequestParam(value = "ReminderTime", required = true, defaultValue = "") String reminderTime,
			@RequestParam(value = "IsCommentNotification", required = true, defaultValue = "") String isCommentNotification,
			@RequestParam(value = "MediumKind", required = true, defaultValue = "") String mediumKind,
			@RequestParam(value = "Subject", required = true, defaultValue = "") String subject,
			@RequestParam(value = "FolderType", required = true, defaultValue = "") String folderType,
			@RequestParam(value = "FolderID", required = true, defaultValue = "") String folderID) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();			

			params.put("UpdateType", updateType);  //All or Comment or Reminder
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("RegisterCode", registerCode);
			params.put("IsNotification", isNotification);
			params.put("IsReminder", isReminder);
			params.put("ReminderTime", reminderTime);
			params.put("IsCommentNotification", isCommentNotification);
			params.put("MediumKind", mediumKind);
			params.put("Subject", subject);
			params.put("FolderType", folderType);
			params.put("FolderID", folderID);
			
			scheduleSvc.updateEachNotification(params);
			
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
	 * 참석자 승인/거부
	 * @param request
	 * @param mode
	 * @param personalFolderID
	 * @param eventID
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/approve.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap approve(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("PersonalFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));			// 개인일정 ID
			params.put("EventID", eventID);
			params.put("UserCode", userCode);
			
			scheduleSvc.approve(mode, params);
			
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
	 * 사용자의 일정 폴더 설정 값 조회
	 * @param request
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getSchUserFolderSetting.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getSchUserFolderSetting(HttpServletRequest request,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UserCode", userCode);
			
			resultList = scheduleSvc.selectSchUserFolderSetting(params);
			
			returnList.put("data", resultList);
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
	 * 사용자 설정 값 저장
	 * @param request
	 * @param schUserFolder
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/saveSchUserFolderSetting.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap saveSchUserFolderSetting(HttpServletRequest request, 
			@RequestParam(value = "schUserFolder", required = true, defaultValue = "") String strSchUserFolder,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("SchUserFolder", strSchUserFolder);
			params.put("UserCode", userCode);
			
			scheduleSvc.saveSchUserFolderSetting(params);
			
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
	
	// 반복일정 모두보기에서 알림 모두 변경
	@RequestMapping(value = "/modifyAllNoti.do", method = RequestMethod.POST) 
	public @ResponseBody CoviMap modifyAllNoti(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "NotiInfo", required = true, defaultValue = "") String notiInfo)
	{
		CoviMap returnObj = new CoviMap();
		try {
			String notiStr = StringEscapeUtils.unescapeHtml(notiInfo);
			CoviMap notiInfoObj = CoviMap.fromObject(notiStr);
			
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("ServiceType", "Schedule");
			params.put("IsReminder", notiInfoObj.getString("reminder"));
			params.put("ReminderTime", notiInfoObj.getString("reminderTime"));
			params.put("IsCommentNotification", notiInfoObj.getString("comment"));
			
			eventSvc.modifyAllNotification(params);
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch(Exception ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));			
		}
		
		return returnObj;
	}
	
	// 반복일정 모두보기에서 알림 모두 끄기
	@RequestMapping(value = "/deleteAllNoti.do", method = RequestMethod.POST) 
	public @ResponseBody CoviMap deleteAllNoti(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID)
	{
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("ServiceType", "Schedule");
			params.put("UserCode", SessionHelper.getSession("USERID"));
			eventSvc.deleteAllNotification(params);
			
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));			
		} catch(Exception ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));			
		}
		
		return returnObj;
	}
	
}
