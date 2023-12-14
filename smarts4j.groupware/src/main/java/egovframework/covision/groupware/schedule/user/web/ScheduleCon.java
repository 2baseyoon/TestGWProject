package egovframework.covision.groupware.schedule.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import egovframework.baseframework.util.json.JSONSerializer;
import net.sf.jxls.transformer.XLSTransformer;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
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
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.exception.ResourceDuplicationException;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.schedule.admin.service.ScheduleManageSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;

@Controller
public class ScheduleCon {
	private Logger LOGGER = LogManager.getLogger(ScheduleCon.class);
	
	private final String FILE_SERVICE_TYPE = "Schedule";
	
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
	
	@Autowired
	private CollabTaskSvc collabTaskSvc;

	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 간단 등록 보기 창
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/getSimpleWriteView.do", method = RequestMethod.GET)
	public ModelAndView getSimpleWriteView(Locale locale, Model model) {
		String returnURL = "user/schedule/SimpleWrite";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 간단 조회 보기 창
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/getSimpleViewView.do", method = RequestMethod.GET)
	public ModelAndView getSimpleViewView(Locale locale, Model model) {
		String returnURL = "user/schedule/SimpleView";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 월간보기 일정 더보기
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/getMoreListPopup.do", method = RequestMethod.GET)
	public ModelAndView getMoreListPopup(Locale locale, Model model) {
		String returnURL = "user/schedule/MoreList";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 테마 일정 목록
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/goThemeList.do", method = RequestMethod.GET)
	public ModelAndView goThemeList(Locale locale, Model model) {
		String returnURL = "user/schedule/ThemeList";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 테마 일정 보기
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/goThemeOne.do", method = RequestMethod.GET)
	public ModelAndView goThemeOne(Locale locale, Model model) {
		String returnURL = "user/schedule/ThemeOne";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 개인 공유 팝업 보기
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/goShareMineList.do", method = RequestMethod.GET)
	public ModelAndView goShareMineList(Locale locale, Model model) {
		String returnURL = "user/schedule/ShareMineList";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 반복 설정 팝업 보기 - 자원과 일정 함께 사용
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/goRepeat.do", method = RequestMethod.GET)
	public ModelAndView goRepeat(Locale locale, Model model) {
		String returnURL = "user/schedule/Repeat";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "schedule/goAttendanceSchedulePopup.do", method = RequestMethod.GET)
	public ModelAndView goAttandaceSchedulePopup(Locale locale, Model model) {
		String returnURL = "user/schedule/AttendanceSchedulePopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 참석요청 팝업보기
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "schedule/goAttendRequestPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttendRequestPopup(Locale locale, Model model) {
		String returnURL = "user/schedule/AttendRequestPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 *  왼쪽 메뉴, 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getACLLeftFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLLeftFolder(HttpServletRequest request,
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			params.put("ScheduleTotalID", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
			params.put("ScheduleThemeFolderID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			//View
			//String objectInStr = eventSvc.getACLScheduleFolderData("View", "V");
			params.put("FolderIDs", folderIDs);
			String[] folderIDArr =  folderIDs.replaceAll("\\(", "").replaceAll("\\)", "").split(",");
			//공유일정폴더 추가
			String[] folderIDArr2 = new String[folderIDArr.length + 1];
		    for(int index = 0; index < folderIDArr.length; index++) {
		    	folderIDArr2[index] = folderIDArr[index];
		    }
		    folderIDArr2[folderIDArr.length] = RedisDataUtil.getBaseConfig("ShareScheduleFolderID");

			params.put("FolderIDArr", folderIDArr2);
			returnObj.put("totalFolder", scheduleSvc.selectTreeMenuTotal(params));
			returnObj.put("listFolder", scheduleSvc.selectTreeMenu(params));
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 * 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getACLFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLFolder(HttpServletRequest request) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		
		CoviList createObj = new CoviList();
		CoviList deleteObj = new CoviList();
		CoviList modifyObj = new CoviList();
		CoviList viewObj = new CoviList();
		CoviList readObj = new CoviList();
		
		boolean isCommunity = Boolean.parseBoolean(request.getParameter("isCommunity"));
		
		try {
			String createStr = "";
			String deleteStr = "";
			String modifyStr = "";
			String viewStr = "";
			String readStr = "";
			
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
				case "V":
					viewObj.add(folder);
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
			returnObj.put("view", viewObj);
			returnObj.put("read", readObj);
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 * 특정 사용자의 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getUserACLFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserACLFolder(HttpServletRequest request) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		
		CoviList createObj = new CoviList();
		CoviList deleteObj = new CoviList();
		CoviList modifyObj = new CoviList();
		CoviList viewObj = new CoviList();
		CoviList readObj = new CoviList();
		
		boolean isCommunity = Boolean.parseBoolean(request.getParameter("isCommunity"));
		String userData = "{";
		userData += "\"USERID\": \""+request.getParameter("USERID")+"\", ";
		userData += "\"URBG_ID\": \""+request.getParameter("URBG_ID")+"\", ";
		userData += "\"DN_ID\": \""+request.getParameter("DN_ID")+"\", ";
		userData += "\"DEPTID\": \""+request.getParameter("DEPTID")+"\", ";
		userData += "\"DN_Code\": \""+request.getParameter("DN_Code")+"\"";
		userData += "}";
		
		try {
			String createStr = "";
			String deleteStr = "";
			String modifyStr = "";
			String viewStr = "";
			String readStr = "";
			
			CoviMap params = new CoviMap();
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			params.put("ScheduleTotalID", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
			params.put("ScheduleThemeID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));
			params.put("ScheduleCafeID", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap userInfoObj = CoviMap.fromObject(JSONSerializer.toJSON(userData));
			
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
				case "V":
					viewObj.add(folder);
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
			returnObj.put("view", viewObj);
			returnObj.put("read", readObj);
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 *  특정 폴더의 하위 폴더 데이터 가져오기
	 * @param request
	 * @param folderID
	 * @param aclColName
	 * @param aclValue
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getACLSubFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLSubFolder(HttpServletRequest request,
			@RequestParam(value = "FolderID", required = true, defaultValue = "") String folderID,
			@RequestParam(value = "ACLColName", required = true, defaultValue = "") String aclColName,
			@RequestParam(value = "ACLValue", required = true, defaultValue = "") String aclValue
			) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		try {
			String objectInStr = eventSvc.getACLFolderData(SessionHelper.getSession(), "Schedule", aclValue);
			
			// FolderData 조회
			CoviMap params = new CoviMap();
			params.put("MemberOf", folderID);
			params.put("FolderIDs", objectInStr);
			params.put("FolderIDArr", objectInStr.replaceAll("\\(", "").replaceAll("\\)", "").split(","));
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnObj.put("list", scheduleSvc.selectTreeSubMenu(params));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
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
	@RequestMapping(value = "schedule/getView.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getView(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
			@RequestParam(value = "IsShareCheck", required = true, defaultValue = "") String isShareCheck,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "ImportanceState", required = true, defaultValue = "") String importanceState,
			@RequestParam(value = "IsMobile", required = false, defaultValue = "N") String isMobile,
			@RequestParam(value = "hasAnniversary", required = false, defaultValue = "N") String hasAnniversary 
			) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			// FolderIDs 의 값이 없을 경우 오류
			if(folderIDs == null || "".equals(folderIDs)) {				
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
			CoviList scheduleList = null;
			CoviList anniversaryList = new CoviList();
			
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("lang", lang);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("ImportanceState", importanceState);		// 중요일정
			params.put("IsMobile", isMobile);
			
			params.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID"));			// 공유 일정 ID
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));		// 개인 일정 ID
			
			scheduleList = scheduleSvc.selectView(params);
			
			if(hasAnniversary.equalsIgnoreCase("Y")){
				anniversaryList = eventSvc.selectAnniversaryList(params);
			}
			
			returnList.put("anniversaryList", anniversaryList);
			returnList.put("list", scheduleList);
			returnList.put("result", "ok");
			
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
	
	/**
	 * 일정 등록
	 * @param request
	 * @param mode
	 * @param eventStr
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setOne(MultipartHttpServletRequest request) throws Exception
	{
		String mode = Objects.toString(request.getParameter("mode"), "");
		String eventStr = Objects.toString(request.getParameter("eventObj"), "");
		String isChangeDate = Objects.toString(request.getParameter("isChangeDate"), "false");
		String isChangeRes = Objects.toString(request.getParameter("isChangeRes"), "false");
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap eventObj = CoviMap.fromObject(eventStr);
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
						
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", (request.getParameter("fileCnt") == null) ? 0 : request.getParameter("fileCnt"));
			
			if(mode.equals("I"))
				resultObj = scheduleSvc.insertSchedule(eventObj, filesParams, mf);
			else if(mode.equals("U"))
				resultObj = scheduleSvc.updateSchedule(eventObj, filesParams, mf);
			else if(mode.equals("RU")) {
				if(RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y") && request.getParameter("prjMap") != null && !request.getParameter("prjMap").equals("")){
					CoviList prjArr =  CoviList.fromObject(request.getParameter("prjMap"));
					
					if(prjArr.size() > 0)
						eventObj.put("prjMap", prjArr.getJSONObject(0));
				}
				
				resultObj = scheduleSvc.setEachSchedule(eventObj, filesParams, mf, isChangeDate, isChangeRes, true);
			}
			
			if(RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y") && request.getParameter("prjMap") != null && !request.getParameter("prjMap").equals("") && !mode.equals("RU")){
				CoviMap reqMap = new CoviMap();	
				CoviMap trgMap = new CoviMap();
				
				CoviList ja =  CoviList.fromObject(request.getParameter("prjMap"));
				if (ja.size()>0){
					CoviMap map =  ja.getJSONObject(0);
					CoviMap dateObj = eventObj.getJSONObject("Date");
					
					List trgMember = new ArrayList();
					trgMap.put("userCode", SessionHelper.getSession("USERID"));
					trgMember.add(trgMap);
					
					reqMap.put("startDate", dateObj.getString("StartDate").replaceAll("-", ""));
					reqMap.put("endDate", dateObj.getString("EndDate").replaceAll("-", ""));
					
					reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					reqMap.put("USERID", SessionHelper.getSession("USERID"));
					reqMap.put("prjSeq", map.get("prjSeq"));
					reqMap.put("prjType",  map.get("prjType"));
					reqMap.put("sectionSeq",  map.get("sectionSeq"));
					reqMap.put("taskName", CoviMap.fromObject(eventObj.get("Event")).getString("Subject"));
					reqMap.put("taskStatus", "W");
					reqMap.put("progRate", "0");
					reqMap.put("parentKey", "0");
					reqMap.put("topParentKey", "0");
					reqMap.put("objectType", "EVENT");
					reqMap.put("objectID", eventObj.get("EventID"));
					
					if(!mode.equals("I")){
						CoviMap delMap = new CoviMap();
						delMap.put("objectID", eventObj.get("EventID"));
						delMap.put("objectType", "EVENT");
						reqMap.put("objectID", eventObj.get("EventID"));
						
						collabTaskSvc.deleteTaskList(delMap);
					}
					
					CoviMap result = collabTaskSvc.addTask(reqMap, trgMember);
				}	
			}
				
			returnList.put("result", resultObj.getString("retType")); //OK or DUPLICATION
			returnList.put("status", Return.SUCCESS);
			returnList.put("message",resultObj.getString("retMsg"));
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ResourceDuplicationException e) {
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "RESOURCE_DUPLICATION");
			returnList.put("message", e.getMessage());
		}
		catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "schedule/setNotification.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setNotification(HttpServletRequest request, 
			@RequestParam(value = "UpdateType", required = true, defaultValue = "") String updateType,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
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
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
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
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "schedule/goOne.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public @ResponseBody CoviMap goOne(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
			@RequestParam(value = "FolderID", required = true, defaultValue = "") String folderID,
			@RequestParam(value = "IsRepeat", required = true, defaultValue = "") String isRepeat
			) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang", lang);
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("IsRepeat", isRepeat);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			if(mode.equals("D") || mode.equals("DU"))
				resultList = scheduleSvc.getOneDetail(params);
			else if(mode.equals("S"))
				resultList = scheduleSvc.getOneSimple(params);
			
			
			if(resultList == null) {
				returnObj.put("status", "EMPTY");
			} else {
				CoviMap filesParams = new CoviMap();
				filesParams.put("ServiceType", FILE_SERVICE_TYPE);
				filesParams.put("ObjectID", folderID);
				filesParams.put("ObjectType", "FD");
				filesParams.put("MessageID", eventID);
				filesParams.put("Version", "0");
				resultList.put("fileList", fileSvc.selectAttachAll(filesParams));
				
				returnObj.put("data", resultList);
				returnObj.put("result", "ok");
				returnObj.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "schedule/remove.do", method=RequestMethod.POST)
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
			
			if (RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y")) {
				CoviMap tParmas = new CoviMap();
				tParmas.put("eventID", eventID);
				tParmas.put("dateID", dateID);
				tParmas.put("lang", SessionHelper.getSession("lang"));
				
				CoviMap taskMap = collabTaskSvc.getTaskMapBySchedule(tParmas);
				
				if(taskMap != null && taskMap.size() != 0) {
					CoviMap delMap = new CoviMap();
					delMap.put("taskSeq", taskMap.get("TaskSeq"));
					delMap.put("isTopTask", "Y");
					
					collabTaskSvc.deleteTask(delMap);
				}
			}
			
			if(mode.equalsIgnoreCase("RU")){
				// 반복일정 중 개별 삭제
				scheduleSvc.deleteEventRepeatByDate(params);
			}else{
				scheduleSvc.deleteEvent(params);
			}
			
			returnList.put("result", "ok");
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
	@RequestMapping(value = "schedule/getList.do", method=RequestMethod.POST)
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
			@RequestParam(value = "IsMobile", required = false, defaultValue = "N") String isMobile,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
		String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
		
		try {
			// FolderIDs 의 값이 없을 경우 오류
			if(folderIDs == null || "".equals(folderIDs)) {				
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			//params.put("EndDate", endDate);
			params.put("UserCode", userCode);
			params.put("lang", lang);
			params.put("ImportanceState", importanceState);
			params.put("Subject", subject);
			params.put("PlaceName", placeName);
			params.put("RegisterName", registerName);
			params.put("IsMobile", isMobile);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID"));			// 공유 일정 ID
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));		// 개인 일정 ID
			
			int cnt = scheduleSvc.selectViewCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			resultList = scheduleSvc.selectView(params);
			
			returnList.put("page", params);
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
	
	/**
	 * 일정 목록 상세 조회
	 * @param request
	 * @param eventID
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getListDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getListDetail(HttpServletRequest request, 
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("lang", lang);
			
			resultList = scheduleSvc.getListViewDetail(params);
			
			returnList.put("EventJson", resultList);
			returnList.put("result", "ok");
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
	
	/**
	 * * 삭제될 컨트롤러. 사용하고자 한다면 쿼리를 추가적으로 수정해야 함
	 * 오늘의 일정 조회
	 * @param request
	 * @param folderIDs
	 * @param userCode
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getToday.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getToday(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList scheduleList = null;
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);				// TODO 조회 권한 있는 Folder 조회
			params.put("UserCode", userCode);
			params.put("lang", lang);
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));		// 개인 일정 ID
			
			scheduleList = scheduleSvc.selectToday(params);
			
			returnList.put("list", scheduleList);
			returnList.put("result", "ok");
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
	
	/**
	 * * 삭제될 컨트롤러. 사용하고자 한다면 쿼리를 추가적으로 수정해야 함
	 * 이달의 일정 조회
	 * @param request
	 * @param folderIDs
	 * @param userCode
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getThisMonth.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getThisMonth(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList scheduleList = null;
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);				// TODO 조회 권한 있는 Folder 조회
			params.put("UserCode", userCode);
			params.put("lang", lang);
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));		// 개인 일정 ID
			
			scheduleList = scheduleSvc.selectThisMonth(params);
			
			returnList.put("list", scheduleList);
			returnList.put("result", "ok");
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
	
	/**
	 * 참석 요청 중인 일정
	 * @param request
	 * @param folderIDs
	 * @param userCode
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getAttendList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAttendList(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = null;
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);				// TODO 조회 권한 있는 Folder 조회
			params.put("UserCode", userCode);
			params.put("lang", lang);
			
			resultList = scheduleSvc.selectAttendList(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
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
	@RequestMapping(value = "schedule/approve.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap approve(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "UserMultiName", required = true, defaultValue = "") String userMultiName) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("PersonalFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));			// 개인일정 ID
			params.put("EventID", eventID);
			params.put("UserCode", userCode);
			params.put("UserName", userMultiName);
			
			scheduleSvc.approve(mode, params);
			
			returnList.put("result", "ok");
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
	
	/**
	 * 팀즈 참석자 승인/거부
	 * @param request
	 * @param mode
	 * @param personalFolderID
	 * @param eventID
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/teamsApprove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap teamsApprove(@RequestBody CoviMap params) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			params.put("PersonalFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID"));			// 개인일정 ID

			scheduleSvc.approve(params.getString("mode"), params);
			
			returnList.put("result", "ok");
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
	
	/**
	 * 참석자 
	 * @param request
	 * @param eventID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/checkAttendeeAuth.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkAttendeeAuth(HttpServletRequest request, 
			@RequestParam(value = "EventID", required = true) String eventID) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			
			String result = scheduleSvc.checkAttendeeAuth(params);
			
			returnList.put("attendeeAuth", result);
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
	
	/**
	 * 자주 쓰는 일정 목록 조회
	 * @param request
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getTemplateList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTemplateList(HttpServletRequest request, 
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			resultList = scheduleSvc.selectTemplateList(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
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
	
	/**
	 * 자주 쓰는 일정 각 버튼에서 추가하기
	 * @param request
	 * @param eventID
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/addTemplate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addTemplate(HttpServletRequest request, 
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("EventID", eventID);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("UserName", SessionHelper.getSession("USERNAME"));			//TODO
			
			scheduleSvc.insertTemplateByEventID(params);
			
			returnList.put("result", "ok");
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
	
	/**
	 * 테마일정 목록 조회
	 * @param request
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getThemeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getThemeList(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("FolderID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));		// 테마일정 폴더 ID
			params.put("DefaultColor", RedisDataUtil.getBaseConfig("FolderDefaultColor"));			// 기본 설정 색
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("UR_Code"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			
			resultList = scheduleSvc.selectThemeList(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
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
	
	/**
	 * 테마일정 조회
	 * @param request
	 * @param folderID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getThemeOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getThemeOne(HttpServletRequest request, 
			@RequestParam(value = "FolderID", required = true, defaultValue = "") String folderID) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("objectType", "FD");
			params.put("objectID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviList aclArray = authSvc.selectACL(params);
			
			resultList = scheduleSvc.selectThemeOne(params);
			
			returnList.put("aclData", aclArray);
			returnList.put("data", resultList);
			
			returnList.put("result", "ok");
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
	
	/**
	 * 테마일정 등록
	 * @param request
	 * @param mode
	 * @param folderDataStr
	 * @param aclDataStr
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setTheme.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setTheme(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "folderData", required = true, defaultValue = "") String folderDataStr,
			@RequestParam(value = "aclIsChange", required = true, defaultValue = "N") String aclIsChange,			
			@RequestParam(value = "aclData", required = true, defaultValue = "") String aclDataStr,
			@RequestParam(value = "aclActionData", required = true, defaultValue = "") String aclActionDataStr) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap folderDataObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(folderDataStr));
			CoviList aclDataObj = new CoviList();
			CoviList aclActionDataObj = new CoviList();
			
			if(!aclDataStr.equals("[]")){
				aclDataObj = CoviList.fromObject(StringEscapeUtils.unescapeHtml(aclDataStr));
			}
			
			if(!aclActionDataStr.equals("[]")){
				aclActionDataObj = CoviList.fromObject(StringEscapeUtils.unescapeHtml(aclActionDataStr));				
			}
			
			// 꼭 필요한 폴더 데이터에 대해서 세팅
			if(!mode.equals("U")) folderDataObj.put("FolderID", "");
			folderDataObj.put("FolderType", "Schedule");
			folderDataObj.put("MemberOf", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));					// 테마일정
			folderDataObj.put("SortKey", "0");			//TODO
			folderDataObj.put("SecurityLevel", RedisDataUtil.getBaseConfig("DefaultSecurityLevel"));				// 보안등급 기본값
			folderDataObj.put("IsShared", "N");
			folderDataObj.put("LinkFolderID", "");
			folderDataObj.put("PersonLinkCode", "");
			folderDataObj.put("IsUse", "Y");
			folderDataObj.put("IsDisplay", "Y");
			folderDataObj.put("IsURL", "N");
			folderDataObj.put("IsAdminSubMenu", "N");
			folderDataObj.put("URL", "");
			folderDataObj.put("Description", "");
			
			CoviMap params = new CoviMap();
			params.put("FolderData", folderDataObj);
			params.put("aclIsChange", aclIsChange);			
			params.put("ACLData", aclDataObj);
			
			if(mode.equals("U")){
				scheduleManageSvc.updateFolderData(params);
			}else{
				scheduleManageSvc.insertFolderData(params);
			}
			
			if(mode.equals("U")){
				if(aclActionDataObj.size() > 0) {
					authSvc.syncActionACL(aclActionDataObj, "FD_SCHEDULE");
				}
			} else {
				if(aclDataObj.size() > 0) {
					authSvc.syncActionACL(aclDataObj, "FD_SCHEDULE");
				}
			}
			
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
	
	/**
	 * 테마일정 삭제
	 * @param request
	 * @param folderIDs
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/removeTheme.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap removeTheme(HttpServletRequest request, 
			@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderIDs", folderIDs);
			
			scheduleSvc.deleteTheme(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
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
	
	/**
	 * 개인일정 공유 등록
	 * @param request
	 * @param mode
	 * @param targetDataArrStr
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setShareMine.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setShareMine(HttpServletRequest request, 
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "TargetDataArr", required = true, defaultValue = "") String targetDataArrStr) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		String specifierCode = SessionHelper.getSession("USERID");
		String specifierName = SessionHelper.getSession("USERNAME");
		String registerCode = specifierCode;
		
		try {
			if(mode.equals("U")){
				CoviMap param = new CoviMap();
				param.put("SpecifierCode", specifierCode);
				
				scheduleManageSvc.deleteShareData(param);
			}
			
			CoviList targetDataArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(targetDataArrStr));
			
			CoviList paramsList = new CoviList();
			for(Object obj : targetDataArr){
				CoviMap targetDataObj = (CoviMap)obj;
				
				CoviMap params = new CoviMap();
				
				params.putAll((Map)targetDataObj); 
				params.put("SpecifierCode", specifierCode);
				params.put("SpecifierName", specifierName);
				params.put("RegisterCode", registerCode);
				
				paramsList.add(params);
			}
			scheduleManageSvc.insertShareData(paramsList);
			
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
	
	/**
	 * 개인일정 공유 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getShareMine.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getShareMine(HttpServletRequest request) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("SpecifierCode", SessionHelper.getSession("USERID"));
			resultList = scheduleManageSvc.selectOneShareScheduleData(params);
			
			returnList.put("list", resultList.get("list"));
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
	
	/**
	 * 내 일정 공유 수정
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/modifyShareMine.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyShareMine(HttpServletRequest request,
			@RequestParam(value = "TargetCode", required = true, defaultValue = "") String targetCode,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("SpecifierCode", SessionHelper.getSession("USERID"));
			params.put("TargetCode", targetCode);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("StartTime", "00:00");
			params.put("EndTime", "00:00");
			
			scheduleSvc.updateShareMine(params);
			
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
	
	@RequestMapping(value = "schedule/removeShareMine.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap removeShareMine(HttpServletRequest request,
			@RequestParam(value = "ShareIDs", required = true, defaultValue = "") String shareIDs) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("ShareIDs", shareIDs);
			
			scheduleSvc.deleteShareMine(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
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
	
	
	/**
	 * 드래그 앤 드롭으로 날짜 및 시간 수정
	 * @param request
	 * @param eventID
	 * @param dateID
	 * @param startDate
	 * @param startTime
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setDateDataByDragDrop.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setDateDataByDragDrop(HttpServletRequest request,
			@RequestParam(value = "setType", required = true, defaultValue = "") String setType,
			@RequestParam(value = "Subject", required = true, defaultValue = "") String Subject,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
			@RequestParam(value = "RepeatID", required = true, defaultValue = "") String repeatID,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "StartTime", required = true, defaultValue = "00:00") String startTime) throws Exception
	{
		CoviMap returnList = null;
		
		try {
			CoviMap params = new CoviMap();
			
			String startDateTime = ComUtils.TransServerTime(startDate + " " + startTime, ComUtils.ServerDateFormat);
			
			params.put("setType", setType);
			params.put("Subject", Subject);
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("RepeatID", repeatID);
			params.put("StartDate", startDateTime.split(" ")[0]);
			params.put("StartTime", startDateTime.split(" ")[1]);
			params.put("StartDateTime", startDateTime);
			params.put("ModifierCode", SessionHelper.getSession("USERID"));			// TODO
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnList = scheduleSvc.updateDateDataByDragDrop(params);
		} catch (NullPointerException e) {
			returnList = new CoviMap();
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList = new CoviMap();
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * Resize 할 경우, 종료시간 Update
	 * @param request
	 * @param eventID
	 * @param dateID
	 * @param endDateTime
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setDateDataByResize.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setDateDataByResize(HttpServletRequest request,			
			@RequestParam(value = "SetType", required = true, defaultValue = "") String setType,
			@RequestParam(value = "Subject", required = true, defaultValue = "") String Subject,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "DateID", required = true, defaultValue = "") String dateID,
			@RequestParam(value = "RepeatID", required = true, defaultValue = "") String repeatID,
			@RequestParam(value = "EndDateTime", required = true, defaultValue = "") String endDateTime,
			@RequestParam(value = "StartDateTime", required = true, defaultValue = "") String startDateTime) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("setType", setType);
			params.put("Subject", Subject);
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("RepeatID", repeatID);
			params.put("EndDateTime", endDateTime);
			params.put("StartDateTime", startDateTime);
			params.put("ModifierCode", SessionHelper.getSession("USERID")); 			//TODO
			
			returnList = scheduleSvc.updateDateDataByResize(params);			
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
	
	/**
	 * 자주 쓰는 일정, 드래그 앤 드롭으로 등록
	 * @param request
	 * @param eventID
	 * @param startDate
	 * @param startTime
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/setEventByTemplateDragDrop.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setEventByTemplateDragDrop(HttpServletRequest request,
			@RequestParam(value = "IsCommunity", required = false, defaultValue = "false") boolean isCommunity,
			@RequestParam(value = "FolderID", required = false, defaultValue = "") String folderID,
			@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "StartTime", required = true, defaultValue = "") String startTime,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
			@RequestParam(value = "EndTime", required = true, defaultValue = "") String endTime) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			if(isCommunity && StringUtil.isNotNull(folderID)) {
				params.put("FolderID", folderID);
			}
			
			params.put("EventID", eventID);
			params.put("StartDate", startDate);
			params.put("StartTime", startTime);
			params.put("StartDateTime", startDate + " " + startTime);
			params.put("EndDate", endDate);
			params.put("EndTime", endTime);
			params.put("EndDateTime", endDate + " " + endTime);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("UserName", SessionHelper.getSession("USERNAME")); //TODO
			
			returnList = scheduleSvc.insertEventByTemplateDragDrop(params);
			
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
	
	/**
	 * 사용자의 구글 연동 여부 확인
	 * @param request
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/checkIsConnectGoogle.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkIsConnectGoogle(HttpServletRequest request,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UserCode", userCode);
			
			resultList = scheduleSvc.selectGoogleInfo(params);
			
			returnList.put("data", resultList);
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
	
	/**
	 * 구글 연동 목록 조회
	 * @param request
	 * @param startDate
	 * @param endDate
	 * @param userCode
	 * @param subject
	 * @param placeName
	 * @param registerName
	 * @param paramJSON
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getGoogleList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGoogleList(HttpServletRequest request,
			@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
			@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
			@RequestParam(value = "Subject", required = true, defaultValue = "") String subject,
			@RequestParam(value = "PlaceName", required = true, defaultValue = "") String placeName,
			@RequestParam(value = "RegisterName", required = true, defaultValue = "") String registerName,
			@RequestParam(value = "paramJSON", required = true, defaultValue = "") String paramJSON) throws Exception
	{
		HttpsUtil httpsUtil = new HttpsUtil();
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("url", "https://www.googleapis.com/calendar/v3/calendars/primary/events");
			params.put("type", "GET");
			params.put("params", paramJSON);
			params.put("userCode", userCode);
			
			String domain = PropertiesUtil.getGlobalProperties().getProperty("covicore.legacy.path");
			String strResult = httpsUtil.httpsClientWithRequest(domain+"/oauth2/client/callGoogleRestAPI.do", "POST", params, "UTF-8", null);
			CoviList tempResult = CoviMap.fromObject(strResult).getJSONObject("data").getJSONArray("items");
			
			String folderID = RedisDataUtil.getBaseConfig("ScheduleGoogleFolderID");
			String color = "#ac725e";					// TODO
			String folderName = "구글 일정";		// TODO
			
			for(Object obj : tempResult){
				CoviMap tempObj = (CoviMap)obj;
				CoviMap eventObj = new CoviMap();
				
				eventObj.put("EventID", tempObj.getString("id"));
				eventObj.put("FolderID", folderID);
				eventObj.put("Color", color);
				eventObj.put("FolderName", folderName);
				eventObj.put("Subject", tempObj.has("summary") ? tempObj.getString("summary") : DicHelper.getDic("lbl_NoSubject"));
				eventObj.put("ImportanceState", "N");
				eventObj.put("IsRepeat", tempObj.has("recurringEventId") ? "Y" : "N");
				eventObj.put("IsAllDay", tempObj.getJSONObject("start").has("date") ? "Y" : "N");
				eventObj.put("StartDateTime", tempObj.getJSONObject("start").has("date") ? tempObj.getJSONObject("start").getString("date") : tempObj.getJSONObject("start").getString("dateTime"));
				eventObj.put("EndDateTime", tempObj.getJSONObject("end").has("date") ? tempObj.getJSONObject("end").getString("date") : tempObj.getJSONObject("end").getString("dateTime"));
				eventObj.put("MultiRegisterName", tempObj.getJSONObject("creator").getString("email"));
				
				resultList.add(eventObj);
			}			
			
			// TODO 구글 데이터 검색 결과 Filter
			resultList = filterGoogleEventData(subject, placeName, registerName, resultList);
			
			returnList.put("list", resultList);
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
	
	/**
	 * 구독 버튼
	 * @param request
	 * @param userCode
	 * @param folderID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getSubscriptionFolderList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSubscriptionFolderList(HttpServletRequest request,
			@RequestParam(value = "FolderID", required = false, defaultValue = "") String folderID,
			@RequestParam(value = "FolderIDs", required = false, defaultValue = "") String folderIDs
			) throws Exception
	{
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("MenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID"));
			
			if(!folderID.equalsIgnoreCase("")){
				params.put("ScheduleCafeID", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
				params.put("FolderID", folderID);
				params.put("lang", SessionHelper.getSession("lang"));
			}else{
				params.put("ScheduleTotalID", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
				params.put("ScheduleThemeID", RedisDataUtil.getBaseConfig("ScheduleThemeFolderID"));
				params.put("ScheduleCafeID", RedisDataUtil.getBaseConfig("ScheduleCafeFolderID"));
				params.put("lang", SessionHelper.getSession("lang"));
			}
			
			params.put("FolderIDs", folderIDs);
			params.put("FolderIDArr", folderIDs.replaceAll("\\(", "").replaceAll("\\)", "").split(","));
			resultList = scheduleSvc.selectSubscriptionFolderList(params);
			
			returnList.put("list", resultList);
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
	
	/**
	 * 사용자 프로필 공유일정 데이터 조회
	 * @param request
	 * @param response
	 * @param targetCode
	 * @param startDate
	 * @param endDate
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getMyInfoProfileScheduleData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyInfoProfileScheduleData(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "userCode", required = true, defaultValue = "") String targetCode,
			@RequestParam(value = "StartDate", required = false, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = false, defaultValue = "") String endDate) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("targetID", targetCode);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			
			returnList = scheduleSvc.selectMyInfoProfileScheduleData(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}
	
	@RequestMapping(value = "schedule/getMyScheduleData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyScheduleData(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "StartDate", required = false, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = false, defaultValue = "") String endDate,
			@RequestParam(value = "FolderIDs", required = false, defaultValue = "") String folderIDs) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("StartDate", startDate);
			params.put("EndDate", DateHelper.getAddDate(endDate, "yyyy-MM-dd", 1, Calendar.DATE));
			params.put("FolderIDs", folderIDs);
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID", SessionHelper.getSession("DN_ID")));		// 개인 일정 ID
			
			returnList = scheduleSvc.selectMyScheduleData(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}
	
	/**
	 * 왼쪽 상단 메뉴 일정 표시
	 * @param request
	 * @param response
	 * @param startDate
	 * @param endDate
	 * @param folderIDs
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getLeftCalendarEvent.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLeftCalendarEvent(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "StartDate", required = false, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = false, defaultValue = "") String endDate,
			@RequestParam(value = "FolderIDs", required = false, defaultValue = "") String folderIDs) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UserCode", userDataObj.getString("USERID"));
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("FolderIDs", folderIDs);
			params.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID", userDataObj.getString("DN_ID")));			// 공유 일정 ID
			params.put("SchedulePersonFolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID", userDataObj.getString("DN_ID")));		// 개인 일정 ID
			params.put("UR_TimeZone", userDataObj.getString("UR_TimeZone"));
			returnList = scheduleSvc.selectLeftCalendarEvent(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}
	
	/**
	 * 웹파트 일정
	 * @param request
	 * @return JSONObject
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getWebpartScheduleList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWebpartScheduleList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userInfoObj = SessionHelper.getSession(isMobile);
			String userId = userInfoObj.getString("USERID");
			
			String aclDataStr = eventSvc.getACLFolderData(userInfoObj, "Schedule", "V");
			
			params.put("lang", userInfoObj.getString("lang"));
			params.put("userCode", userId);
			params.put("aclData", aclDataStr);
			params.put("aclDataArr", aclDataStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
            params.put("jobSeq", userInfoObj.get("URBG_ID"));
            params.put("objectType", "FD");
			params.put("StartDate", request.getParameter("StartDate"));
			params.put("EndDate", request.getParameter("EndDate"));
			params.put("Idx", request.getParameter("Idx"));
			
			resultList = scheduleSvc.getWebpartScheduleList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	
	// 구글 검색
	private CoviList filterGoogleEventData(String subject, String placeName, String registerName, CoviList data) {
		CoviList returnList = new CoviList();
		
		for(Object obj : data){
			CoviMap tempObj = (CoviMap)obj;
			
			// 제목
			if(subject != null && !subject.equals("")){
				String eSubject = tempObj.getString("Subject");
				if(eSubject.matches(".*"+subject+".*")){
					returnList.add(tempObj);
				}else{
					break;
				}
			}
			// 장소
			if(placeName != null && !placeName.equals("")){
				String ePlaceName = tempObj.getString("PlaceName");
				if(ePlaceName.matches(".*"+placeName+".*")){
					returnList.add(tempObj);
				}else{
					break;
				}
			}
			// 작성자
			if(registerName != null && !registerName.equals("")){
				String eRegisterName = tempObj.getString("RegisterName");
				if(eRegisterName.matches(".*"+registerName+".*")){
					returnList.add(tempObj);
				}else{
					break;
				}
			}
			
			if(subject.equals("") && placeName.equals("") && registerName.equals("")){
				returnList.add(tempObj);
			}
		}
		
		return returnList;
	}
	
	// 웹파트 일정 상세 팝업
	@RequestMapping(value = "schedule/goScheduleDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goScheduleDetailPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/schedule/ScheduleDetailPopup");
	}
	
	// 웹파트 일정 상세
	@RequestMapping(value = "schedule/detailView.do", method = RequestMethod.GET)
	public ModelAndView detailView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/schedule/DetailView");
	}
	
	// 일정 등록 팝업창 (메일)
	@RequestMapping(value = "schedule/goDetailWrite.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goDetailWrite(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "user/schedule/DetailWritePopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("bizSection", request.getParameter("bizSection"));
		mav.addObject("subject", request.getParameter("subject"));
		mav.addObject("contents", request.getParameter("contents"));
		
		return mav;
	}
	
	// 엑셀 다운로드(목록보기)
	@RequestMapping(value = "schedule/excelDownload.do")
	public void excelDownload(HttpServletRequest request, HttpServletResponse response,
		@RequestParam(value = "FolderIDs", required = true, defaultValue = "") String folderIDs,
		@RequestParam(value = "StartDate", required = true, defaultValue = "") String startDate,
		@RequestParam(value = "EndDate", required = true, defaultValue = "") String endDate,
		@RequestParam(value = "UserCode", required = true, defaultValue = "") String userCode,
		@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
		@RequestParam(value = "ImportanceState", required = true, defaultValue = "") String importanceState,
		@RequestParam(value = "Subject", required = true, defaultValue = "") String subject,
		@RequestParam(value = "PlaceName", required = true, defaultValue = "") String placeName,
		@RequestParam(value = "RegisterName", required = true, defaultValue = "") String registerName,
		@RequestParam(value = "IsMobile", required = false, defaultValue = "N") String isMobile,
		@RequestParam(value = "paramJSON", required = true, defaultValue = "") String paramJSON,
		@RequestParam(value = "includeGoogleYn", required = true, defaultValue = "N") String includeGoogleYn) {
		CoviList resultList = null;
		CoviMap paramMap = null;
		
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			// 1. 일정 데이터 조회
			paramMap = new CoviMap();
			paramMap.put("FolderIDs", folderIDs);
			paramMap.put("StartDate", startDate);
			paramMap.put("EndDate", endDate);
			paramMap.put("UserCode", userCode);
			paramMap.put("lang", lang);
			paramMap.put("ImportanceState", importanceState);
			paramMap.put("Subject", subject);
			paramMap.put("PlaceName", placeName);
			paramMap.put("RegisterName", registerName);
			paramMap.put("IsMobile", isMobile);
			paramMap.put("ShareScheduleFolderID", RedisDataUtil.getBaseConfig("ShareScheduleFolderID"));			// 공유 일정 ID
			
			resultList = new CoviList();
			resultList = scheduleSvc.selectView(paramMap);
			
			paramMap = new CoviMap();
			paramMap.put("list", resultList);
			
			// 2. 구글 일정 데이터 조회
			if (includeGoogleYn.equals("Y")) {
				resultList = new CoviList();
				HttpsUtil httpsUtil = new HttpsUtil();
				
				CoviMap params = new CoviMap();
				params.put("url", "https://www.googleapis.com/calendar/v3/calendars/primary/events");
				params.put("type", "GET");
				params.put("params", paramJSON);
				params.put("userCode", userCode);
				
				
				String domain = PropertiesUtil.getGlobalProperties().getProperty("covicore.legacy.path");
				String strResult = httpsUtil.httpsClientWithRequest(domain+"/oauth2/client/callGoogleRestAPI.do", "POST", params, "UTF-8", null);				
				CoviList tempResult = CoviMap.fromObject(strResult).getJSONObject("data").getJSONArray("items");
				String folderID = RedisDataUtil.getBaseConfig("ScheduleGoogleFolderID");
				String color = "#ac725e";					// TODO
				String folderName = "구글 일정";		// TODO
				
				for(Object obj : tempResult){
					CoviMap tempObj = (CoviMap)obj;
					CoviMap eventObj = new CoviMap();
					
					eventObj.put("EventID", tempObj.getString("id"));
					eventObj.put("FolderID", folderID);
					eventObj.put("Color", color);
					eventObj.put("FolderName", folderName);
					eventObj.put("Subject", tempObj.has("summary") ? tempObj.getString("summary") : DicHelper.getDic("lbl_NoSubject"));
					eventObj.put("ImportanceState", "N");
					eventObj.put("IsRepeat", tempObj.has("recurringEventId") ? "Y" : "N");
					eventObj.put("IsAllDay", tempObj.getJSONObject("start").has("date") ? "Y" : "N");
					eventObj.put("StartDateTime", tempObj.getJSONObject("start").has("date") ? tempObj.getJSONObject("start").getString("date") : tempObj.getJSONObject("start").getString("dateTime"));
					eventObj.put("EndDateTime", tempObj.getJSONObject("end").has("date") ? tempObj.getJSONObject("end").getString("date") : tempObj.getJSONObject("end").getString("dateTime"));
					
					String startDateTime = tempObj.getJSONObject("start").has("date") ? tempObj.getJSONObject("start").getString("date") : tempObj.getJSONObject("start").getString("dateTime");
					String endDateTime = tempObj.getJSONObject("end").has("date") ? tempObj.getJSONObject("end").getString("date") : tempObj.getJSONObject("end").getString("dateTime");
					if (startDateTime.indexOf("T") > -1) {
						eventObj.put("StartDate", startDateTime.split("T")[0]);
						eventObj.put("StartTime", (startDateTime.split("T")[1]).substring(0,5));
					} else {
						eventObj.put("StartDate", startDateTime);
						eventObj.put("StartTime", "00:00");
					}
					if (endDateTime.indexOf("T") > -1) {
						eventObj.put("EndDate", endDateTime.split("T")[0]);
						eventObj.put("EndTime", (endDateTime.split("T")[1]).substring(0,5));
					} else {
						eventObj.put("EndDate", endDateTime);
						eventObj.put("EndTime", "00:00");
					}
					
					eventObj.put("MultiRegisterName", tempObj.getJSONObject("creator").getString("displayName"));
					
					resultList.add(eventObj);
				}			
				
				// TODO 구글 데이터 검색 결과 Filter
				resultList = filterGoogleEventData(subject, placeName, registerName, resultList);
				
				paramMap.put("googlList", resultList);
			} else {
				paramMap.put("googlList", new CoviList());
			}
	        
			// 3. 엑셀 생성
			String FileName = new SimpleDateFormat("yyyy_MM_dd").format(new Date()) + "_Schedule.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Schedule_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, paramMap);
			
			if (includeGoogleYn.equals("N")) resultWorkbook.setSheetHidden(1, Workbook.SHEET_STATE_VERY_HIDDEN);	// 구글 일정이 포함되지 않을때 구글 일정 시트 숨김
			
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (FileNotFoundException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	/**
	 * 체크한 항목 Redis에 저장
	 * @param checkList
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/saveChkFolderListRedis.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveChkFolderListRedis(@RequestParam(value = "checkList", required = true) String checkList) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			RedisShardsUtil.getInstance().save("ScheduleCheckBox_" + SessionHelper.getSession("USERID"), checkList);
			
			returnList.put("result", "ok");
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
	
	/**
	 * 일정관리 체크된 항목이 아무것도 없을 경우 기본 데이터 조회.
	 * @param domainID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "schedule/getMainScheduleMenuList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMainScheduleMenuList(@RequestParam(value = "domainID", required = false) String domainID) throws Exception {
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
		
			String checkStr = RedisShardsUtil.getInstance().get("ScheduleCheckBox_" + SessionHelper.getSession("USERID"));
			
			returnList.put("list", resultList);
			returnList.put("redisData", checkStr);
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
	
	
	//일정 인쇄
	@RequestMapping(value = "schedule/printView.do", method = RequestMethod.GET) 
	public ModelAndView goPrint(HttpServletRequest request, Locale locale, Model model)
	{
			ModelAndView mav = new ModelAndView("user/schedule/SchedulePrint");
			return mav;
	}
	
	
	// 반복일정 모두보기에서 알림 모두 변경
	@RequestMapping(value = "schedule/modifyAllNoti.do", method = RequestMethod.POST) 
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
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch(Exception ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		
		return returnObj;
	}
	
	// 반복일정 모두보기에서 알림 모두 끄기
	@RequestMapping(value = "schedule/deleteAllNoti.do", method = RequestMethod.POST) 
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
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch(Exception ex) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		
		return returnObj;
	}
	
	/**
	 * 일정 dateID 가져오기
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "schedule/getScheduleDateID.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getScheduleDateID(HttpServletRequest request){
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("eventID", request.getParameter("eventID"));
			params.put("sDate", request.getParameter("sDate"));
			params.put("eDate", request.getParameter("eDate"));
			
			String dateID = scheduleSvc.getScheduleDateID(params);
			
			returnObj.put("dateID", dateID);
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 * 참석요청 목록 가져오기
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "schedule/selectAttendRequest.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectAttendRequest(HttpServletRequest request){
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnObj = eventSvc.selectAttendRequest(params);
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "");
		}
		catch(NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
}
