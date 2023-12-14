package egovframework.covision.groupware.schedule.user.service.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.exception.ResourceDuplicationException;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("scheduleService")
public class ScheduleSvcImpl extends EgovAbstractServiceImpl implements ScheduleSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private ResourceSvc resourceSvc;
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private CollabTaskSvc collabTaskSvc;
	
	@Autowired
	private MessageService messageSvc;

	// 일정 폴더 조회 - 통합일정 포함
	@Override
	public CoviList selectTreeMenuTotal(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		
		CoviList list = coviMapperOne.list("user.schedule.selectTreeMenuTotal", params);
		CoviList totalList = CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Color,Reserved3,Reserved4,Reserved5,SubCount");
		
		// 하위 폴더 조회
		for(Object obj : totalList){
			CoviMap totalObj = (CoviMap)obj;
			
			params.put("folderID", totalObj.getString("FolderID"));
			CoviList childList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.schedule.selectChildFolder", params), "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Color,Reserved3,Reserved4,Reserved5");
			
			totalObj.put("child", childList);
			returnArr.add(totalObj);
		}
		
		return returnArr;
	}

	// 일정 폴더 조회 - 통합일정 제외
	@Override
	public CoviList selectTreeMenu(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		
		CoviList list = coviMapperOne.list("user.schedule.selectTreeMenu", params);
		CoviList menuList = CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Color,Reserved3,Reserved4,Reserved5,SubCount");
		
		// 하위 폴더 조회
		for(Object obj : menuList){
			CoviMap menuObj = (CoviMap)obj;
			
			params.put("folderID", menuObj.getString("FolderID"));
			CoviList childList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.schedule.selectChildFolder", params), "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Color,Reserved3,Reserved4,Reserved5");
			
			menuObj.put("child", childList);
			returnArr.add(menuObj);
		}
		
		return returnArr;
	}
	
	@Override
	public Object selectTreeSubMenu(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectTreeSubMenu", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,FolderType,ParentObjectID,ParentObjectType,LinkFolderID,DisplayName,MultiDisplayName,MemberOf,FolderPath,SortKey,SecurityLevel,SortPath,IsInherited,IsShared,IsUse,IsDisplay,IsURL,URL,IsMobileSupport,IsAdminNotice,ManageCompany,IsMsgSecurity,Description,OwnerCode,RegisterCode,RegistDate,ModifierCode,ModifyDate,DeleteDate,Reserved1,Color,Reserved3,Reserved4,Reserved5");
	}
	
	// 일정 조회
	@Override
	public CoviList selectView(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectView", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,EventID,LinkEventID,Subject,Place,ImportanceState,OwnerCode,DateID,RepeatID,StartDate,StartTime,EndDate,EndTime,IsAllDay,IsRepeat,Color,OneMore,IsShare,RegisterCode,MultiRegisterName,MailAddress,StartDateTime,EndDateTime");
	}

	// 일정 조회 개수
	@Override
	public int selectViewCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.schedule.selectViewCount", params);
	}

	// 일정 목록 조회 - 상세 보기
	@Override
	public CoviMap getListViewDetail(CoviMap params) throws Exception {
		CoviMap detailObj = new CoviMap();
		
		// Event
		CoviMap eventObj = eventSvc.selectEvent(params);
		
		// Attendant
		CoviList attendantObj = selectEventAttendant(params);
		
		// Resource
		CoviList resourceObj = eventSvc.selectEventResource(params);
		
		detailObj.put("Event", eventObj);
		detailObj.put("Resource", resourceObj);
		detailObj.put("Attendee", attendantObj);
		
		return detailObj;
	}

	// 일정 추가
	@Override
	public CoviMap insertSchedule(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", DicHelper.getDic("msg_117")); // 성공적으로 저장하였습니다.
		
		String isNewProcess = dataObj.getString("isNewProcess");
		if ("Y".equals(isNewProcess)) {
			returnObj = saveSchedule("insert", dataObj, fileInfos, mf, returnObj);
			return returnObj;
		}
		
		CoviMap params = null;
		
		CoviMap eventObj = dataObj.getJSONObject("Event");				// 이벤트 마스터 정보
		CoviMap eventDateObj = dataObj.getJSONObject("Date");
		CoviList resourceArr = dataObj.getJSONArray("Resource");						// 자원 예약 정보
		CoviMap repeatObj = dataObj.getJSONObject("Repeat");						// 반복 정보
		CoviList attendantArr = dataObj.getJSONArray("Attendee");					// 참석자 정보
		CoviMap notificationObj = dataObj.getJSONObject("Notification");		// 알림 정보
		String eventID = "";
		String repeatID = "";
		String dateID = "";
		
		for(Object obj : resourceArr){
			CoviMap resourceObj = (CoviMap)obj;
			
			CoviMap duplicationObj = resourceSvc.checkDuplicateTime(resourceObj.getString("FolderID"), null, null,eventDateObj, repeatObj);
			
			if( duplicationObj.getInt("IsDuplication") == 1 ){
				returnObj.put("retType", "DUPLICATION");
				returnObj.put("retMsg", "["+resourceObj.getString("ResourceName")+"]&nbsp;" + duplicationObj.getString("Message"));
				
				return returnObj;
			}
		}
		
		// 이벤트 추가
		params = new CoviMap();
		params.put("FolderID", eventObj.getString("FolderID"));
		params.put("FolderType", eventObj.getString("FolderType"));
		params.put("EventType", eventObj.getString("EventType"));
		params.put("LinkEventID", eventObj.getString("LinkEventID").equals("") ? null : eventObj.getString("LinkEventID"));
		params.put("MasterEventID", eventObj.getString("MasterEventID").equals("") ? null : eventObj.getString("MasterEventID"));				// 반복일정 중 개별일정 수정 시 원본 이벤트 ID
		params.put("Subject", eventObj.getString("Subject"));
		params.put("Place", eventObj.getString("Place"));
		params.put("IsPublic", eventObj.getString("IsPublic"));
		params.put("IsDisplay", eventObj.getString("IsDisplay"));
		params.put("IsInviteOther", eventObj.getString("IsInviteOther"));
		params.put("ImportanceState", eventObj.getString("ImportanceState"));
		params.put("OwnerCode", SessionHelper.getSession("USERID"));
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("MultiRegisterName", SessionHelper.getSession("UR_MultiName"));
		params.put("ModifierCode", SessionHelper.getSession("USERID"));
		params.put("DeleteDate", null);
		
		CoviMap linkFolderInfo = coviMapperOne.selectOne("user.schedule.selectLinkFolderInfo", params);
		
		if (linkFolderInfo != null && !linkFolderInfo.isEmpty()) {
			params.put("FolderID", linkFolderInfo.getString("LinkFolderID"));
			params.put("FolderType", linkFolderInfo.getString("FolderType"));
		}
		
		//Editor 처리
		if(eventObj.containsKey("Description") && !"".equals(eventObj.getString("Description"))) {
			CoviMap editorParam = new CoviMap();
			editorParam.put("serviceType", "Schedule");  //BizSection
			editorParam.put("imgInfo", eventObj.getString("InlineImage")); 
			editorParam.put("objectID", eventObj.getString("FolderID"));     
			editorParam.put("objectType", "FD");   
			editorParam.put("messageID", "0");  
			editorParam.put("bodyHtml",eventObj.getString("Description"));   
			
			CoviMap editorInfo = editorService.getContent(editorParam); 
			
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
            
			params.put("Description", editorInfo.getString("BodyHtml"));
			
			eventID = eventSvc.insertEvent(params);
			
			//에디터 파일 messageID Update
			editorParam.put("messageID", eventID); 
			editorParam.addAll(editorInfo);
			editorService.updateFileMessageID(editorParam);
		
		// 자원예약 "일정연동" 일경우, Editor 가 없으므로
		} else {
			params.put("Description", "");
			eventID = eventSvc.insertEvent(params);
		}
		
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", eventID);
			filesParams.put("ObjectID", eventObj.getString("FolderID"));
			filesParams.put("ObjectType", "FD");
			insertScheduleSysFile(filesParams, mf);
		}
		
		// 반복 데이터 추가
		params = new CoviMap();
		
		// 반복 일정 및 Date 추가
		CoviList dateList = new CoviList();
		
		// 자주 쓰는 일정일 때 일정(event_date) 값 따로 지정 필요
		if(eventObj.getString("EventType").equals("F")){
			dateList = null;
			
			// 알림 데이터 - 등록자
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("RepeatID", 0);
			params.put("IsNotification", notificationObj.getString("IsNotification"));
			params.put("IsReminder", notificationObj.getString("IsReminder"));
			params.put("ReminderTime", notificationObj.getString("ReminderTime"));
			params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
			params.put("MediumKind", notificationObj.getString("MediumKind"));

			dateID = insertEventDateByTemp(params);
			
			eventSvc.insertEventNotificationByRegister(params);
			
		} else if(!repeatObj.isEmpty()){
			eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
			eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
			
			// 반복 정보 repeatID 생성
			repeatObj.put("EventID", eventID);
			repeatID = eventSvc.insertEventRepeat(repeatObj);
			
			// 반복 정보 dateList 생성
			dateList = eventSvc.setEventRepeatDate(repeatObj);
		} else{
			params.put("EventID", eventID);
			params.put("AppointmentStartTime", eventDateObj.getString("StartTime"));
			params.put("AppointmentEndTime", eventDateObj.getString("EndTime"));
			params.put("RepeatType", "");
			params.put("RepeatStartDate", eventDateObj.getString("StartDate"));
			params.put("RepeatEndType", "");
			params.put("RepeatEndDate", eventDateObj.getString("EndDate"));
			repeatID = eventSvc.insertEventRepeat(params);
			
			CoviMap dateObj = new CoviMap();
			dateObj.put("StartDate", eventDateObj.getString("StartDate"));
			dateObj.put("EndDate", eventDateObj.getString("EndDate"));
			
			dateList.add(dateObj);
		}
		
		/*// 반복일정을 별도로 새로 저장시
		if(eventObj.getString("EventType").equals("M")){
			// 기존 반복일정으로 저장된 Date 데이터 삭제
			params = new CoviMap();
			params.put("DateID", dataObj.getString("DateID"));
			
			eventSvc.deleteEventDateByDateID(params);
		}*/
		
		//일정 등록 알림 메세지 상세 등록
		String sReceiverText = "§lbl_date§ : " + eventDateObj.getString("StartDate") + " " + eventDateObj.getString("StartTime") + "~" + eventDateObj.getString("EndDate") + " " + eventDateObj.getString("EndTime")+ "&lt;br&gt;";
		sReceiverText += (eventObj.getString("Place") != null) ? "§lbl_Place§ : " + eventObj.getString("Place") + " &lt;br&gt;" : "";
		ArrayList<String> dicFolderList = new ArrayList<String>();
		if(resourceArr.size() != 0 && dataObj.get("ResourceName") == null) {
			int resourcelength = resourceArr.size();
			sReceiverText += "§lbl_Resources§ : ";
			for(Object resourceobj : resourceArr) {
				CoviMap Arrobj = (CoviMap)resourceobj;
				String resourceID = Arrobj.getString("FolderID");
				sReceiverText += "§FD@@"+resourceID+"§";
				if(resourcelength != 1) {
					sReceiverText += ", ";
					resourcelength--;
				}
				dicFolderList.add("FD@@"+resourceID);
			}
			sReceiverText += "&lt;br&gt;";
		}
		
		CoviMap dicMap = new CoviMap();
		CoviMap dicParams = new CoviMap();
		String[] dicArr = {"lbl_Place", "lbl_date", "lbl_Resources"};
		dicParams.put("dicArr", dicArr);
		dicParams.put("folderArr", dicFolderList.toArray());

		dicMap = messageSvc.getDicInfo(dicParams);
		
		if(dateList != null && dateList.size() > 0) {
			for(Object obj : dateList){
				CoviMap dateMap = (CoviMap)obj;
				
				params = new CoviMap();
				
				String startDate = dateMap.getString("StartDate");
				String startTime = eventDateObj.getString("StartTime");
				String endDate = dateMap.getString("EndDate");
				String endTime = eventDateObj.getString("EndTime");
				
				params.put("EventID", eventID);
				params.put("RepeatID", repeatID);
				params.put("StartDateTime", startDate + " " + startTime);
				params.put("StartDate", startDate);
				params.put("StartTime", startTime);
				params.put("EndDateTime", endDate + " " + endTime);
				params.put("EndDate", endDate);
				params.put("EndTime", endTime);
				params.put("IsAllDay", eventDateObj.getString("IsAllDay"));
				params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
				
				dateID = eventSvc.insertEventDate(params);
				
				// 알림 데이터 - 등록자
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("DateID", dateID);
				params.put("IsNotification", notificationObj.getString("IsNotification"));
				params.put("IsReminder", notificationObj.getString("IsReminder"));
				params.put("ReminderTime", notificationObj.getString("ReminderTime"));
				params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
				params.put("MediumKind", notificationObj.getString("MediumKind"));
				
				eventSvc.insertEventNotificationByRegister(params);
				
				for(Object obj_2 : resourceArr){
					CoviMap resourceObj = (CoviMap) obj_2;
				
					if(!resourceObj.containsKey("BookingState")) { //반복일 경우 자원정보가 여러번 조회되는 현상 방지
						String bookingState = "ApprovalRequest";
						
						params = new CoviMap();
						params.put("FolderID", resourceObj.getString("FolderID")); 
						
						CoviMap resourceDataObj = eventSvc.selectResourceData(params);
						
						if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
							bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
						}
						resourceObj.put("BookingState", bookingState);
					}
					
					params = new CoviMap();
					params.put("DateID", dateID);
					params.put("EventID", eventID);
					params.put("ResourceID", resourceObj.getString("FolderID"));						// 자원 ID
					params.put("ApprovalDate", null);
					params.put("ApprovalState", resourceObj.getString("BookingState"));
					params.put("RealEndDateTime", endDate + " " + endTime);
				
					// Resource Booking 데이터
					eventSvc.insertEventResourceBooking(params);
					
				}
				
				// 자주쓰는 일정(템플릿) 일경우 알림제외
				if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equalsIgnoreCase("Y") && !eventObj.getString("EventType").equals("F")){
					// 등록자 미리알림
					params = new CoviMap();
					params.put("dateID", dateID);
					params.put("eventID", eventID);
					params.put("notificationObj", notificationObj);
					params.put("RegisterCode", SessionHelper.getSession("USERID"));
					params.put("Subject", eventObj.getString("Subject"));
					params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
					params.put("FolderID", eventObj.getString("FolderID"));
					params.put("startDate", startDate);
					params.put("startTime", startTime);
					
					sendReminderAlarm(params);
					
					// 참석자는 일정 참석요청 승인 시 일정의 미리알림에 따라 미리알림 생성하므로 제외함.
				}
			}
			
			for(Object obj_2 : resourceArr){
				CoviMap resourceObj = (CoviMap) obj_2;
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", eventObj.getString("Subject"));
				notiParam.put("ReceiverText", eventObj.getString("Subject"));
				notiParam.put("MessageContext", sReceiverText);
				notiParam.put("EventID", eventID);
				notiParam.put("DateID", dateID);
				notiParam.put("RepeatID", repeatID);
				notiParam.put("IsRepeat", eventDateObj.getString("IsRepeat"));
				notiParam.put("IsRepeatAll", eventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
				notiParam.put("ResourceID", resourceObj.getString("FolderID"));
				notiParam.put("ReservedStr4", CoviMap.toJSONString(dicMap));
				
				if(resourceObj.getString("BookingState").equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
					notiParam.put("SenderCode", SessionHelper.getSession("USERID"));
					notiParam.put("ReceiversCode", SessionHelper.getSession("USERID"));
					resourceSvc.sendMessage(notiParam, "BookingComplete");
				}else{ //담당자 승인일 경우 승인요청 알림 보내기
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceObj.getString("FolderID"));
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode", SessionHelper.getSession("USERID"));
					notiParam.put("ReceiversCode", managerCode);
					resourceSvc.sendMessage(notiParam, "ApprovalRequest");
				}
			}
			
			
		}
		
		// 참석자, 알림
		// 참석자 데이터
		for(Object obj : attendantArr){
			CoviMap attendantObj = (CoviMap) obj;
			
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("AttenderCode", attendantObj.getString("UserCode"));
			params.put("MultiAttenderName", attendantObj.getString("UserName"));
			params.put("IsOutsider", attendantObj.getString("IsOutsider"));
			params.put("IsAllow", "");
			
			insertEventAttendant(params);
			
			// 알림 데이터
			// 참석자를 포함한 조회자들은 상세 조회화면에서 알림 켰을 때만 INSERT
			/*if(!eventObj.getString("RegisterCode").equals(attendantObj.getString("UserCode"))){
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("RegisterCode", attendantObj.getString("UserCode"));
				params.put("RegisterKind", "A");
				params.put("IsNotification", notificationObj.getString("IsNotification"));
				params.put("IsReminder", notificationObj.getString("IsReminder"));
				params.put("ReminderTime", notificationObj.getString("ReminderTime"));
				params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
				params.put("MediumKind", notificationObj.getString("MediumKind"));
			
				eventSvc.insertEventNotification(params);
			}*/
			
			// 참석요청 알림
			// 자주쓰는 일정(템플릿) 일경우 알림제외
			if(!eventObj.getString("EventType").equals("F")) {
				CoviMap notiParams = new CoviMap();
				String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+ "&eventID=" + eventID
						+ "&dateID=" + dateID
						+ "&isRepeat=" + eventDateObj.getString("IsRepeat")
						+ "&folderID=" + eventObj.getString("FolderID")
						+ "&isAttendee=Y";
				
				String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
						+ "&isrepeat=" + eventDateObj.getString("IsRepeat") + "&folderid=" + eventObj.getString("FolderID");
				
				notiParams.put("SenderCode", SessionHelper.getSession("USERID"));
				notiParams.put("RegisterCode", SessionHelper.getSession("USERID"));
				notiParams.put("ReceiversCode", attendantObj.getString("UserCode"));
				notiParams.put("MessagingSubject", eventObj.getString("Subject"));
				notiParams.put("ReceiverText", eventObj.getString("Subject"));
				notiParams.put("MessageContext", sReceiverText);
				notiParams.put("ServiceType", "Schedule");
				notiParams.put("MsgType", "ScheduleAttendance");
				notiParams.put("GotoURL", alarmUrl);
				notiParams.put("PopupURL", alarmUrl);
				notiParams.put("MobileURL", mobileAlarmUrl);
				notiParams.put("ReservedStr4", CoviMap.toJSONString(dicMap));
				
				eventSvc.sendNotificationMessage(notiParams);
			}
		}
		
		// 연관 이벤트 데이터
		for(Object obj : resourceArr){
			CoviMap resourceObj = (CoviMap) obj;
			
			params = new CoviMap();
			params.put("ScheduleID", eventID);
			params.put("ResourceID", resourceObj.getString("FolderID"));
			params.put("Reserved1", null);
			params.put("Reserved2", null);
			
			eventSvc.insertEventRelation(params);
		}
		
		// 자원예약 : 일정이 정상등록되었는지 검증용으로 사용하기 위해 넣어줌(ResourceSvcImpl.saveBookingData())
		dataObj.put("eventID", eventID);
		dataObj.put("repeatID", repeatID);
		dataObj.put("dateID", dateID);
		
		return returnObj;
	}


	@Override
	public CoviMap updateSchedule(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", DicHelper.getDic("msg_117")); //성공적으로 저장하였습니다.
		
		String isNewProcess = dataObj.getString("isNewProcess");
		if ("Y".equals(isNewProcess)) {
			returnObj = saveSchedule("update", dataObj, fileInfos, mf, returnObj);
			return returnObj;
		}
		
		CoviMap params = new CoviMap();
		
		CoviMap eventObj = null; 				// 이벤트 마스터 정보
		CoviMap eventDateObj = null;			// Date 정보
		CoviList resourceArr = null;				// 자원 예약 정보
		CoviMap repeatObj =null ;				// 반복 정보
		CoviList attendantArr = null;				// 참석자 정보
		CoviMap notificationObj = null;			// 알림 정보
		
		String eventID = dataObj.getString("EventID");
		String repeatID = dataObj.getString("RepeatID");
		String dateID = dataObj.getString("DateID");
		String registerCode = SessionHelper.getSession("USERID");
		
		String dateIDs[] = null; 
		
		if(dataObj.has("Event")) {
			eventObj = dataObj.getJSONObject("Event");
			
			// 자주 쓰는 일정일 때 일정(event_date) 저장하지 않음
			if(!eventObj.getString("EventType").equals("F"))
				dateIDs = eventSvc.getDateIDs(eventID);
		}
		
		// 미리알림을 위한 데이터
		String subject = dataObj.getString("Subject");
		String folderID = dataObj.getString("FolderID");
		
		 if(dataObj.has("Notification")){
			notificationObj = dataObj.getJSONObject("Notification");
		 }
		
		CoviList dateList = new CoviList();
		
		if(dataObj.has("Event")){
			eventObj = dataObj.getJSONObject("Event");
			
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("FolderID", eventObj.getString("FolderID"));
			params.put("FolderType", eventObj.getString("FolderType"));
			params.put("EventType", eventObj.getString("EventType"));
			params.put("LinkEventID", eventObj.getString("LinkEventID").equals("") ? null : eventObj.getString("LinkEventID"));
			params.put("MasterEventID", eventObj.getString("MasterEventID").equals("") ? null : eventObj.getString("MasterEventID"));				// 반복일정 중 개별일정 수정 시 원본 이벤트 ID
			params.put("Subject", eventObj.getString("Subject"));
			params.put("Place", eventObj.has("Place") ? eventObj.getString("Place") : null);
			params.put("IsPublic", eventObj.getString("IsPublic"));
			params.put("IsInviteOther", eventObj.getString("IsInviteOther"));
			params.put("ImportanceState", eventObj.getString("ImportanceState"));
			params.put("OwnerCode", SessionHelper.getSession("USERID"));
			params.put("ModifierCode", SessionHelper.getSession("USERID"));
			
			CoviMap linkFolderInfo = coviMapperOne.selectOne("user.schedule.selectLinkFolderInfo", params);
			
			if (linkFolderInfo != null && !linkFolderInfo.isEmpty()) {
				params.put("FolderID", linkFolderInfo.getString("LinkFolderID"));
				params.put("FolderType", linkFolderInfo.getString("FolderType"));
			}
			
			//Editor 처리
			if(eventObj.containsKey("Description") && !"".equals(eventObj.getString("Description"))) {
			    CoviMap editorParam = new CoviMap();
			    editorParam.put("serviceType", "Schedule");  //BizSection
			    editorParam.put("imgInfo", (eventObj.containsKey("InlineImage") ? eventObj.getString("InlineImage") : "")); 
			    editorParam.put("objectID", eventObj.getString("FolderID"));     
			    editorParam.put("objectType", "FD");   
			    editorParam.put("messageID", eventID);  
			    editorParam.put("bodyHtml",eventObj.getString("Description"));   
				
			    CoviMap editorInfo = editorService.getContent(editorParam); 
			    
	            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
	            	throw new Exception("InlineImage move BackStorage Error");
	            }
			    
			    params.put("Description", editorInfo.getString("BodyHtml"));
			}else {
				params.put("Description", "");
			}

			eventSvc.updateEvent(params);

		}
		
		// 반복, 자원, 날짜 변경시
		if(dataObj.has("Date")){
			eventDateObj = dataObj.getJSONObject("Date");
		}
		
		//첨부파일 처리 
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("fileCnt", fileInfos.getString("fileCnt"));
			filesParams.put("MessageID", eventID);
			filesParams.put("ObjectID", eventObj.getString("FolderID"));
			filesParams.put("ObjectType", "FD");
			updateScheduleSysFile(filesParams, mf);
		}
		
		// 반복 변경되었을 경우
		if(dataObj.has("Repeat") && !repeatID.equals("undefined")){
			repeatObj = dataObj.getJSONObject("Repeat");
			
			// 반복이 설정되어 있다가 삭제된 경우
			if(repeatObj.isEmpty() && eventDateObj != null && !eventDateObj.isEmpty() && eventDateObj.getString("IsRepeat").equals("N")){
				params = new CoviMap();
				
				params.put("RepeatID", repeatID);
				params.put("EventID", eventID);
				params.put("AppointmentStartTime", eventDateObj.getString("StartTime"));
				params.put("AppointmentEndTime", eventDateObj.getString("EndTime"));
				params.put("RepeatType", "");
				params.put("RepeatStartDate", eventDateObj.getString("StartDate"));
				params.put("RepeatEndType", "");
				params.put("RepeatEndDate", eventDateObj.getString("EndDate"));
				
				eventSvc.updateEventRepeat(params);
				
				// Date 다시 저장
				CoviMap dateObj = new CoviMap();
				dateObj.put("StartDate", eventDateObj.getString("StartDate"));
				dateObj.put("EndDate", eventDateObj.getString("EndDate"));
				
				dateList.add(dateObj);
			}
			// 반복이 변경되었을 경우
			else if(!repeatObj.isEmpty()){
				repeatObj.put("RepeatID", repeatID);
				eventSvc.updateEventRepeat(repeatObj);
				
				// Date 다시 저장
				dateList = eventSvc.setEventRepeatDate(repeatObj);
				
				if(eventDateObj == null || eventDateObj.isEmpty()){
					eventDateObj = new CoviMap();
					
					eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
					eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
					eventDateObj.put("IsAllDay", "N");
					eventDateObj.put("IsRepeat", "Y");
				}
				
				if(eventDateObj.getString("StartTime").equals("")){
					eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
				}
				if(eventDateObj.getString("EndTime").equals("")){
					eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
				}
			}
		}
		// Date 만 수정한 경우 (반복 X)
		else{
			if(eventDateObj != null && !repeatID.equalsIgnoreCase("undefined")){		// 자주쓰는 일정등록 bugfix (dateID:undefined, repeatID:undefined)
				CoviMap dateObj = new CoviMap();
				dateObj.put("StartDate", eventDateObj.getString("StartDate"));
				dateObj.put("EndDate", eventDateObj.getString("EndDate"));
				dateObj.put("StartTime", eventDateObj.getString("StartTime"));
				dateObj.put("EndTime", eventDateObj.getString("EndTime"));
				
				dateList.add(dateObj);
				
				// 반복 데이터 시작일, 종료일 수정
				dateObj.put("RepeatID", repeatID);
				eventSvc.updateEventRepeatDate(dateObj);
			}
		}
		
		// 자원이 변경되었을 경우
		// 자원이 변경되었는데 날짜데이터가 넘어오지 않았을 경우, 반복 및 날짜 데이터 조회필요
		if(eventDateObj == null && !dateID.equalsIgnoreCase("undefined")){
			params = new CoviMap(); 
			
			params.put("DateID", dateID);
			eventDateObj = eventSvc.selectEventDate(params);
		}
		if(repeatObj == null && !repeatID.equals("") && !repeatID.equalsIgnoreCase("undefined")){
			params = new CoviMap(); 
			
			params.put("RepeatID", repeatID);
			repeatObj = eventSvc.selectEventRepeat(params);
		}
		
		// 자원을 모두 삭제했을 경우
		if(dataObj.has("Resource") && dataObj.get("Resource").toString().equalsIgnoreCase("{}")){
			params = new CoviMap();
			params.put("EventID", eventID);
			eventSvc.deleteEventRelation(params);
			eventSvc.deleteEventResourceBooking(params);
		}else{
			// 반복일정 시 DateID값이 1개만 넘어가는 내용 수정
			String chkDateIDs = "";
			if(dateIDs != null && dateIDs.length > 0) {
				// jdk1.7 미호환
				// chkDateIDs = String.join(";", dateIDs);
				int appendIdx = 0;
				StringBuffer buf = new StringBuffer();
				for (String id : dateIDs) {
					if(++appendIdx == dateIDs.length)
						 buf.append(id);
					else
						 buf.append(id).append(";");
				}
				chkDateIDs = buf.toString();
			} else {
				chkDateIDs = dateID;
			}
			
			if(dataObj.has("Resource")){
				resourceArr = dataObj.getJSONArray("Resource");
				
				for(Object obj : resourceArr){
					CoviMap resourceObj = (CoviMap)obj;
					
					if(resourceObj.has("ResourceName") && !chkDateIDs.equalsIgnoreCase("undefined")){			// 자주쓰는 일정수정 bugfix : Template 은 중복비교 의미가 없으므로 (dateID:undefined, repeatID:undefined)
						
						
						
						CoviMap duplicationObj = resourceSvc.checkDuplicateTime(resourceObj.getString("FolderID"), chkDateIDs, eventID, eventDateObj, repeatObj);
						
						if( duplicationObj.getInt("IsDuplication") == 1 ){
							returnObj.put("retType", "DUPLICATION");
							returnObj.put("retMsg", "["+resourceObj.getString("ResourceName")+"]&nbsp;" + duplicationObj.getString("Message"));
							
							return returnObj;
						}
					}
				}
			}
			// 반복 및 날짜가 변경되고, 자원이 변경되지 않았을 경우 기존 FolderID 조회
			else if(dataObj.has("Repeat") || dataObj.has("Date")){
				params = new CoviMap();
				params.put("EventID", eventID);
				resourceArr = eventSvc.selectResourceList(params);
				
				// 자원이 변경되지 않을경우 중복체크 추가
				for(Object obj : resourceArr){
					CoviMap resourceObj = (CoviMap)obj;
					
					if(resourceObj.has("ResourceName") && !chkDateIDs.equalsIgnoreCase("undefined")){			// 자주쓰는 일정수정 bugfix : Template 은 중복비교 의미가 없으므로 (dateID:undefined, repeatID:undefined)
						
						CoviMap duplicationObj = resourceSvc.checkDuplicateTime(resourceObj.getString("FolderID"), chkDateIDs, eventID, eventDateObj, repeatObj);
						
						if( duplicationObj.getInt("IsDuplication") == 1 ){
							returnObj.put("retType", "DUPLICATION");
							returnObj.put("retMsg", "["+resourceObj.getString("ResourceName")+"]&nbsp;" + duplicationObj.getString("Message"));
							
							return returnObj;
						}
					}
				}
			}
		}
		
		// 날짜 변경되었을 경우, 알림 설정 및 미리알림 모두 삭제
		if(dateList !=null && !dateList.isEmpty()){
			params = new CoviMap();
			params.put("EventID", eventID);
			eventSvc.deleteEventNotification(params);
			
			params = new CoviMap();
			CoviList oldDateIDs  = new CoviList(Arrays.asList(eventSvc.getDateIDs(eventID)));
			params.put("SearchType", "LIKE");
			params.put("ServiceType", "Schedule");
			params.put("ObjectType", "reminder_%");
			params.put("arrObjectID", oldDateIDs);
			eventSvc.updateArrMessagingCancelState(params);
		}
		
		if(resourceArr !=null && !resourceArr.isEmpty()){
			/*if(notificationObj == null){
				params.clear();
				params.put("RegisterCode", registerCode);
				notificationObj = eventSvc.selectEventNotification(params);
			}*/
			
			if(dateList !=null && !dateList.isEmpty()){
				// 기존 Date 삭제 후 다시 Insert
				params = new CoviMap();
				params.put("EventID", eventID);
				eventSvc.deleteEventDateByEventID(params);
				
				eventSvc.deleteEventRelation(params);
				eventSvc.deleteEventResourceBooking(params);
				
				// 연관 이벤트 데이터
				for(Object obj : resourceArr){
					CoviMap resourceObj = (CoviMap) obj;
					
					params = new CoviMap();
					params.put("ScheduleID", eventID);
					params.put("ResourceID", resourceObj.getString("FolderID"));
					params.put("Reserved1", null);
					params.put("Reserved2", null);
					
					eventSvc.insertEventRelation(params);
				}
				
				for(Object obj : dateList){
					CoviMap dateMap = (CoviMap)obj;
					
					params = new CoviMap();
					String startDate = dateMap.getString("StartDate");
					String startTime = eventDateObj.getString("StartTime");
					String endDate = dateMap.getString("EndDate");
					String endTime = eventDateObj.getString("EndTime");
					String startDateTime = (startDate != null && startTime != null && !"".equalsIgnoreCase(startDate) && !"".equalsIgnoreCase(startTime)) ? startDate + " " + startTime : null;
					String endDateTime = (endDate != null && endTime != null && !"".equalsIgnoreCase(endDate) && !"".equalsIgnoreCase(endTime)) ? endDate + " " + endTime : null;
					
					params.put("EventID", eventID);
					params.put("RepeatID", repeatID.equalsIgnoreCase("undefined") ? null : repeatID);			// 자주쓰는 일정수정 bugfix (dateID:undefined, repeatID:undefined)
					params.put("StartDateTime", startDateTime);
					params.put("StartDate", startDate);
					params.put("StartTime", startTime);
					params.put("EndDateTime", endDateTime);
					params.put("EndDate", endDate);
					params.put("EndTime", endTime);
					params.put("IsAllDay", eventDateObj.getString("IsAllDay"));
					params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
					
					dateID = eventSvc.insertEventDate(params);
					
					// 등록자 설정 INSERT
					params = new CoviMap();
					params.put("EventID", eventID);
					params.put("DateID", dateID);
					params.put("IsNotification", "N");
					params.put("IsReminder", "N");
					params.put("ReminderTime", "10");
					params.put("IsCommentNotification", "N");
					params.put("MediumKind", "");
					eventSvc.insertEventNotificationByRegister(params);
					
					for(Object obj_2 : resourceArr){
						CoviMap resourceObj = (CoviMap) obj_2;
						
						if(!resourceObj.containsKey("BookingState")) { //반복일 경우 자원정보가 여러번 조회되는 현상 방지
							String bookingState = "ApprovalRequest";
							
							params = new CoviMap();
							params.put("FolderID", resourceObj.getString("FolderID")); 
							
							CoviMap resourceDataObj = eventSvc.selectResourceData(params);
							
							if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
								bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
							}
							resourceObj.put("BookingState", bookingState);
						}
						
						params = new CoviMap();
						params.put("DateID", dateID);
						params.put("EventID", eventID);
						params.put("ResourceID", resourceObj.getString("FolderID"));						// 자원 ID
						params.put("ApprovalDate", null);
						params.put("ApprovalState", resourceObj.getString("BookingState"));
						params.put("RealEndDateTime", endDateTime);
						
						// Resource Booking 데이터
						eventSvc.insertEventResourceBooking(params);
						
						/*
						// 자원알림은 작성자에게만 전송
						if(bookingState.equalsIgnoreCase("Approval") && notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){		
							params = new CoviMap();
							params.put("dateID", dateID);
							params.put("eventID", eventID);
							params.put("notificationObj", notificationObj);
							params.put("RegisterCode", registerCode);
							params.put("Subject", subject);
							params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
							params.put("FolderID",  resourceObj.getString("FolderID"));
							params.put("startDate", startDate);
							params.put("startTime", startTime);
							sendResourceReminderAlarm(params);
						}
						*/
					}
				}
				
				for(Object obj_2 : resourceArr){
					CoviMap resourceObj = (CoviMap) obj_2;
					
					CoviMap notiParam = new CoviMap();
					notiParam.put("Subject", subject);
					notiParam.put("EventID", eventID);
					notiParam.put("DateID", dateID);
					notiParam.put("RepeatID", repeatID);
					notiParam.put("IsRepeat", eventDateObj.getString("IsRepeat"));
					notiParam.put("IsRepeatAll", eventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
					notiParam.put("ResourceID", resourceObj.getString("FolderID"));
					
					if(resourceObj.getString("BookingState").equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
						notiParam.put("SenderCode", registerCode);
						notiParam.put("ReceiversCode", registerCode);
						resourceSvc.sendMessage(notiParam, "BookingComplete");
					}else{ //담당자 승인일 경우 승인요청 알림 보내기
						CoviMap manageParma = new CoviMap();
						manageParma.put("FolderID", resourceObj.getString("FolderID"));
						manageParma.put("ObjectType", "FD");
						String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
						
						notiParam.put("SenderCode" , registerCode);
						notiParam.put("ReceiversCode", managerCode);
						resourceSvc.sendMessage(notiParam, "ApprovalRequest");
					}
				}
				
			}else{
				// 날짜는 수정되지 않고 자원만 수정되었을 경우
				params = new CoviMap();
				params.put("EventID", eventID);
				eventSvc.deleteEventRelation(params);
				eventSvc.deleteEventResourceBooking(params);
				
				// 연관 이벤트 데이터
				for(Object obj : resourceArr){
					CoviMap resourceObj = (CoviMap) obj;
					
					String isSendAlarm = "Y";
					if(resourceObj.has("IsNew"))
						isSendAlarm = resourceObj.getString("IsNew");
					
					params = new CoviMap();
					params.put("ScheduleID", eventID);
					params.put("ResourceID", resourceObj.getString("FolderID"));
					params.put("Reserved1", null);
					params.put("Reserved2", null);
					
					eventSvc.insertEventRelation(params);
					
					// 자주쓰는 일정이 아닌경우에만 Booking Data 및 알림데이터 업데이트
					if(!eventObj.getString("EventType").equals("F")) {
						if(dateIDs != null) {  //반복 예약이었을 경우 
							for(int i=0; i<dateIDs.length; i++){
								// params = new CoviMap();
								// params.put("DateID", dateIDs[i]);
								// CoviMap dateMap = eventSvc.selectEventDate(params);
								
								if(!resourceObj.containsKey("BookingState")) { //반복일 경우 자원정보가 여러번 조회되는 현상 방지
									String bookingState = "ApprovalRequest";
									
									params = new CoviMap();
									params.put("FolderID", resourceObj.getString("FolderID")); 
									
									CoviMap resourceDataObj = eventSvc.selectResourceData(params);
									
									if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
										bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
									}
									resourceObj.put("BookingState", bookingState);
								}
								
								params = new CoviMap();
								params.put("DateID", dateIDs[i]);
								params.put("EventID", eventID);
								params.put("ResourceID", resourceObj.getString("FolderID"));						// 자원 ID
								params.put("ApprovalDate", null);
								params.put("ApprovalState", resourceObj.getString("BookingState"));
								params.put("RealEndDateTime", null);
							
								// Resource Booking 데이터
								eventSvc.insertEventResourceBooking(params);
								
								
								/* 일정 연동 시 자원 알림 제외
								 // 자원알림은 작성자에게만 전송
								 if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){		
									params = new CoviMap();
									params.put("dateID", dateID);
									params.put("eventID", eventID);
									params.put("notificationObj", notificationObj);
									params.put("RegisterCode", registerCode);
									params.put("Subject", subject);
									params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
									params.put("FolderID",  resourceObj.getString("FolderID"));
									params.put("startDate", dateMap.getString("StartDate"));
									params.put("startTime", dateMap.getString("StartTime"));
									sendReminderAlarm(params);
								}*/
							}
							
							// 새로 추가된 자원에 대해서만 알림 발송
							if("Y".equals(isSendAlarm)) {
								CoviMap notiParam = new CoviMap();
								notiParam.put("Subject", subject);
								notiParam.put("EventID", eventID);
								notiParam.put("DateID", dateIDs[dateIDs.length - 1]);
								notiParam.put("RepeatID", repeatID);
								notiParam.put("IsRepeat", eventDateObj.getString("IsRepeat"));
								notiParam.put("IsRepeatAll", eventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
								notiParam.put("ResourceID", resourceObj.getString("FolderID"));
								
								if(resourceObj.getString("BookingState").equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
									notiParam.put("SenderCode", registerCode);
									notiParam.put("ReceiversCode", registerCode);
									resourceSvc.sendMessage(notiParam, "BookingComplete");
								}else{ //담당자 승인일 경우 승인요청 알림 보내기
									CoviMap manageParma = new CoviMap();
									manageParma.put("FolderID", resourceObj.getString("FolderID"));
									manageParma.put("ObjectType", "FD");
									String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
									
									notiParam.put("SenderCode" , registerCode);
									notiParam.put("ReceiversCode", managerCode);
									resourceSvc.sendMessage(notiParam, "ApprovalRequest");
								}
							}
							
						}/*일정 연동 시 자원 알림 제외
						else{ //반복 아닐 경우
							params = new CoviMap();
							params.put("DateID", dateID);
							CoviMap dateMap = eventSvc.selectEventDate(params);
							
							// 자원알림은 작성자에게만 전송
							if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){		
								params = new CoviMap();
								params.put("dateID", dateID);
								params.put("eventID", eventID);
								params.put("notificationObj", notificationObj);
								params.put("RegisterCode", registerCode);
								params.put("Subject", subject);
								params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
								params.put("FolderID",  resourceObj.getString("FolderID"));
								params.put("startDate", dateMap.getString("StartDate"));
								params.put("startTime", dateMap.getString("StartTime"));
								sendReminderAlarm(params);
							}
						}*/
						
						
						
					}
				}
			}
		}else{
			// 자주쓰는 일정(템플릿) 일경우 알림 및 일정(event_date) 등록하지 않음
			if(!eventObj.getString("EventType").equals("F")) {
				if(dataObj.has("Date") || dateList.size() > 0){
					params = new CoviMap();
					params.put("EventID", eventID);
					eventSvc.deleteEventDateByEventID(params);
					
					for(Object obj : dateList){
						CoviMap dateMap = (CoviMap)obj;
						params = new CoviMap();
						String startDate = dateMap.getString("StartDate");
						String startTime = eventDateObj.getString("StartTime");
						String endDate = dateMap.getString("EndDate");
						String endTime = eventDateObj.getString("EndTime");
						
						params.put("EventID", eventID);
						params.put("RepeatID", repeatID.equalsIgnoreCase("undefined") ? null : repeatID);				// 자주쓰는 일정수정 bugfix (dateID:undefined, repeatID:undefined)
						params.put("StartDateTime", startDate + " " + startTime);
						params.put("StartDate", startDate);
						params.put("StartTime", startTime);
						params.put("EndDateTime", endDate + " " + endTime);
						params.put("EndDate", endDate);
						params.put("EndTime", endTime);
						params.put("IsAllDay", eventDateObj.getString("IsAllDay"));
						params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
						
						dateID = eventSvc.insertEventDate(params);
						
						// 등록자 설정 INSERT
						params = new CoviMap();
						params.put("EventID", eventID);
						params.put("DateID", dateID);
						params.put("IsNotification", "N");
						params.put("IsReminder", "N");
						params.put("ReminderTime", "10");
						params.put("IsCommentNotification", "N");
						params.put("MediumKind", "");
						eventSvc.insertEventNotificationByRegister(params);
						
						/*
						// 미리알림 재전송
						// 참석자의 각 알림에 맞는 미리알림 세팅. 참석자 변경되었을 경우 아래에서 별도 처리
						if(!dataObj.has("Attendee")){
							// 이전 미리알림 취소 처리
							params = new CoviMap();
							params.put("SearchType", "LIKE");
							params.put("ServiceType", "Schedule");
							params.put("ObjectType", "reminder_%");			// 참석자까지 모두 삭제
							params.put("ObjectID", dateID);
							eventSvc.updateMessagingCancelState(params);
							
							params = new CoviMap();
							params.put("EventID", eventID);
							CoviList notificationArr = selectEventNotificationList(params);
							
							for(Object nofi : notificationArr){
								CoviMap nofiObj = (CoviMap)nofi;
								
								if(nofiObj.getString("IsReminder").equalsIgnoreCase("Y") && !nofiObj.getString("UserCode").equals(SessionHelper.getSession("USERID"))){			// 수정자는 아래 변경된 알림 데이터로 별도 변경
									params = new CoviMap();
									params.put("dateID", dateID);
									params.put("eventID", eventID);
									params.put("notificationObj", nofiObj);
									params.put("RegisterCode", nofiObj.getString("UserCode"));
									params.put("Subject", subject);
									params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
									params.put("FolderID", folderID);
									params.put("startDate", startDate);
									params.put("startTime", startTime);
									sendReminderAlarm(params);
								}
							}
						}*/
					}
				}
			}
		}
		
		// 참석자가 변경되었을 경우
		if(dataObj.has("Attendee")){
			attendantArr = dataObj.getJSONArray("Attendee");
			
			if(!attendantArr.isEmpty()){
				// 참석자 데이터
				params = new CoviMap();
				params.put("EventID", eventID);
				deleteEventAttendant(params);
				
				for(Object obj : attendantArr){
					CoviMap attendantObj = (CoviMap) obj;
					
					// 삭제된 일정 중에 이미 개인일정으로 추가되었을 경우 삭제
					// TODO 알림
					if(attendantObj.getString("dataType").equals("DEL") && attendantObj.getString("IsAllow").equals("Y")){
						params = new CoviMap();
						params.put("EventID", eventID);
						params.put("AttenderCode", attendantObj.getString("UserCode"));
						
						deleteEventByAttendeeData(params);
					}else if(!attendantObj.getString("dataType").equals("DEL")){
						params = new CoviMap();
						params.put("EventID", eventID);
						params.put("AttenderCode", attendantObj.getString("UserCode"));
						params.put("MultiAttenderName", attendantObj.getString("UserName"));
						params.put("IsOutsider", attendantObj.getString("IsOutsider"));
						params.put("IsAllow", attendantObj.getString("IsAllow"));
						
						insertEventAttendant(params);
					}
					
					// 자주쓰는 일정(템플릿) 일경우 알림 및 일정(event_date) 등록하지 않음
					if(!eventObj.getString("EventType").equals("F")) {
						// 알림 데이터
						/*if(!registerCode.equals(attendantObj.getString("UserCode"))){
							params = new CoviMap();
							params.put("EventID", eventID);
							params.put("RegisterCode", attendantObj.getString("UserCode"));
							params.put("RegisterKind", "A");
							params.put("IsNotification", notificationObj.getString("IsNotification"));
							params.put("IsReminder", notificationObj.getString("IsReminder"));
							params.put("ReminderTime", notificationObj.getString("ReminderTime"));
							params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
							params.put("MediumKind", notificationObj.getString("MediumKind"));
							
							eventSvc.insertEventNotification(params);
							
							//참석자 날짜별 미리알림 데이터
							for(Object date : dateList){
								CoviMap dateObj = CoviMap.fromObject(date);
								
								params = new CoviMap();
								params.put("dateID", dateID);
								params.put("eventID", eventID);
								params.put("notificationObj", notificationObj);
								params.put("RegisterCode", attendantObj.getString("UserCode"));
								params.put("Subject", subject);
								params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
								params.put("FolderID", folderID);
								params.put("startDate", dateObj.getString("StartDate"));
								params.put("startTime", eventDateObj.getString("StartTime"));
								sendReminderAlarm(params);
							}
						}*/
						
						// 참석요청 알림
						// 자주쓰는 일정(템플릿) 일경우 알림제외
						if(attendantObj.getString("dataType").equals("NEW")) {
							CoviMap notiParams = new CoviMap();
							String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
									+ "&eventID=" + eventID
									+ "&dateID=" + dateID
									+ "&isRepeat=" + eventDateObj.getString("IsRepeat")
									+ "&folderID=" + eventObj.getString("FolderID")
									+ "&isAttendee=Y";
							
							String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
									+ "&isrepeat=" + eventDateObj.getString("IsRepeat") + "&folderid=" + eventObj.getString("FolderID");
							
							notiParams.put("SenderCode", SessionHelper.getSession("USERID"));
							notiParams.put("RegisterCode", SessionHelper.getSession("USERID"));
							notiParams.put("ReceiversCode", attendantObj.getString("UserCode"));
							notiParams.put("MessagingSubject", eventObj.getString("Subject"));
							notiParams.put("ReceiverText", eventObj.getString("Subject"));
							notiParams.put("ServiceType", "Schedule");
							notiParams.put("MsgType", "ScheduleAttendance");
							notiParams.put("GotoURL", alarmUrl);
							notiParams.put("PopupURL", alarmUrl);
							notiParams.put("MobileURL", mobileAlarmUrl);
							
							eventSvc.sendNotificationMessage(notiParams);
						}
					}
				}
			}
		}
		
		// 알림이 변경되었을 경우
		if(dataObj.has("Notification") && !eventObj.getString("EventType").equals("F")){
			notificationObj = dataObj.getJSONObject("Notification");
			
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("IsNotification", notificationObj.getString("IsNotification"));
			params.put("IsReminder", notificationObj.getString("IsReminder"));
			params.put("ReminderTime", notificationObj.getString("ReminderTime"));
			params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
			params.put("MediumKind", notificationObj.getString("MediumKind"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			eventSvc.updateEventNotification(params);
			
			// 수정화면에서 알림 제외
			/*if(!eventObj.getString("EventType").equals("F") && dateIDs != null) {
				// 미리알림 재전송
				// 이전 미리알림 취소 처리
				for(int i=0; i<dateIDs.length; i++){
					params = new CoviMap();
					params.put("SearchType", "EQ");
					params.put("ServiceType", "Schedule");
					params.put("ObjectType", "reminder_"+SessionHelper.getSession("USERID"));
					params.put("ObjectID", dateIDs[i]);
					eventSvc.updateMessagingCancelState(params);
					params.put("ServiceType", "Resource");
					eventSvc.updateMessagingCancelState(params);
				}
					
				if(notificationObj.getString("IsReminder").equalsIgnoreCase("Y")){
	
					if(dateList.size() == 0){
						params = new CoviMap();
						params.put("EventID", eventID);
						dateList.addAll(eventSvc.selectEventDateAll(params));
					}
	
					//2019.04 반복일정 알림설정 시 오류처리 -  반복일정이 추가되었을 경우 dateIDs 추가됨. 사용 전에 다시 호출 함
					dateIDs = eventSvc.getDateIDs(eventID);	
					
					int i = 0;
					for(Object date : dateList){
						CoviMap dateObj = CoviMap.fromObject(date);
						params = new CoviMap();
						params.put("dateID", dateIDs[i]);
						params.put("eventID", eventID);
						params.put("notificationObj", notificationObj);
						params.put("RegisterCode", SessionHelper.getSession("USERID"));
						params.put("Subject", subject);
						params.put("IsRepeat", eventDateObj.getString("IsRepeat"));
						params.put("FolderID", folderID);
						params.put("startDate", dateObj.containsKey("StartDate")? dateObj.getString("StartDate"):eventDateObj.getString("StartDate"));//2019.04 반복일정 알림설정 시 오류처리
						params.put("startTime", dateObj.containsKey("StartTime")? dateObj.getString("StartTime"):eventDateObj.getString("StartTime"));//2019.04 반복일정 알림설정 시 오류처리
						sendReminderAlarm(params);
						
						++i;
					}
				}
			}*/
		}
		
		return returnObj;
	}

	@Override
	public CoviMap setEachSchedule(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf, String isChangeDate, String isChangeRes, Boolean IsSchedule) throws Exception {
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", DicHelper.getDic("msg_117")); //성공적으로 저장하였습니다.
		
		CoviMap params = null;
		
		CoviMap eventObj = dataObj.getJSONObject("Event");					// 이벤트 마스터 정보
		CoviMap eventDateObj = dataObj.getJSONObject("Date");
		CoviList resourceArr = dataObj.getJSONArray("Resource");				// 자원 예약 정보
	//	CoviMap repeatObj = dataObj.getJSONObject("Repeat").getJSONObject("ResourceRepeat");		// 반복 정보
		CoviList attendantArr = dataObj.getJSONArray("Attendee");				// 참석자 정보
		CoviMap notificationObj = dataObj.getJSONObject("Notification");		// 알림 정보
		CoviMap prjMap = RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y") ? dataObj.getJSONObject("prjMap") : null;	// [협업 스페이스] 프로젝트 정보
		
		String oldEventID = dataObj.getString("EventID");
		String oldDateID = dataObj.getString("DateID");
		
		String eventID = "";
		String repeatID = "";
		String dateID = "";
		
		String resourceAct = "INSERT";
		
		params = new CoviMap();
		params.put("DateID", oldDateID);
		
		// 자원 비교 및 새로 예약
		if(resourceArr.size()>0){
			eventSvc.deleteEventResourceBooking(params);
			
			// 자원예약이 변경되지 않았을 경우
			if(isChangeDate.equalsIgnoreCase("FALSE") && isChangeRes.equalsIgnoreCase("FALSE")){
				resourceAct = "UPDATE";
			}else{
				for(Object obj : resourceArr){
					CoviMap resourceObj = (CoviMap)obj;
					
					CoviMap duplicationObj = resourceSvc.checkDuplicateTime(resourceObj.getString("FolderID"), eventDateObj);
					
					if( duplicationObj.getInt("IsDuplication") == 1 ){
						returnObj.put("retType", "DUPLICATION");
						returnObj.put("retMsg", "["+resourceObj.getString("ResourceName")+"]&nbsp;" + duplicationObj.getString("Message"));
						
						return returnObj;
					}else{
						resourceAct = "INSERT";
					}
				}
			}
		}
		
		// 기존 Date 데이터 지우기
		eventSvc.deleteEventDateByDateID(params);
		
		params = new CoviMap();
		// 이벤트 추가
		params.put("FolderID", eventObj.getString("FolderID"));
		params.put("FolderType", eventObj.getString("FolderType"));
		params.put("EventType", eventObj.getString("EventType"));
		params.put("LinkEventID", eventObj.getString("LinkEventID").equals("") ? null : eventObj.getString("LinkEventID"));
		params.put("MasterEventID", eventObj.getString("MasterEventID").equals("") ? null : eventObj.getString("MasterEventID"));				// 반복일정 중 개별일정 수정 시 원본 이벤트 ID
		params.put("Subject", eventObj.getString("Subject"));
		params.put("Place", eventObj.getString("Place"));
		params.put("IsPublic", eventObj.getString("IsPublic"));
		params.put("IsDisplay", "Y");
		params.put("IsInviteOther", eventObj.getString("IsInviteOther"));
		params.put("ImportanceState", eventObj.getString("ImportanceState"));
		params.put("OwnerCode", SessionHelper.getSession("USERID"));
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("MultiRegisterName", SessionHelper.getSession("UR_MultiName"));
		params.put("ModifierCode", SessionHelper.getSession("USERID"));
		params.put("DeleteDate", null);
		
		CoviMap linkFolderInfo = coviMapperOne.selectOne("user.schedule.selectLinkFolderInfo", params);
		
		if (linkFolderInfo != null && !linkFolderInfo.isEmpty()) {
			params.put("FolderID", linkFolderInfo.getString("LinkFolderID"));
			params.put("FolderType", linkFolderInfo.getString("FolderType"));
		}
		
		if(eventObj.containsKey("Description") && !"".equals(eventObj.getString("Description"))){
			//Editor 처리
		    CoviMap editorParam = new CoviMap();
		    editorParam.put("serviceType", "Schedule");  //BizSection
		    editorParam.put("imgInfo", eventObj.containsKey("InlineImage") ? eventObj.getString("InlineImage") : "" ); 
		    editorParam.put("objectID", eventObj.getString("FolderID"));     
		    editorParam.put("objectType", "FD");   
		    editorParam.put("messageID", "0");  
		    editorParam.put("bodyHtml",eventObj.getString("Description"));   
			
		    CoviMap editorInfo = editorService.getContent(editorParam); 
		    
            if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
            	throw new Exception("InlineImage move BackStorage Error");
            }
            
		    params.put("Description", editorInfo.getString("BodyHtml"));
		    
		    eventID = eventSvc.insertEvent(params);
			
			editorParam.put("messageID", eventID);
			editorParam.addAll(editorInfo);
			
			editorService.updateFileMessageID(editorParam);
		}else{
			params.put("Description", "");
			eventID = eventSvc.insertEvent(params);
		}
		
		if(fileInfos != null) {
			String objectID = "";
			
			if(fileInfos.getString("ServiceType").indexOf("Resource") > -1) {
				objectID = resourceArr.getJSONObject(0).getString("FolderID");
			}else {
				objectID = eventObj.getString("FolderID");
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", eventID);
			filesParams.put("ObjectID", objectID);
			filesParams.put("ObjectType", "FD");
			insertScheduleSysFile(filesParams, mf);
		}
		
		// 반복 데이터 추가
		params = new CoviMap();
		params.put("EventID", eventID);
		params.put("AppointmentStartTime", eventDateObj.getString("StartTime"));
		params.put("AppointmentEndTime", eventDateObj.getString("EndTime"));
		params.put("RepeatType", "");
		params.put("RepeatStartDate", eventDateObj.getString("StartDate"));
		params.put("RepeatEndType", "");
		params.put("RepeatEndDate", eventDateObj.getString("EndDate"));
		repeatID = eventSvc.insertEventRepeat(params);
		
		CoviMap dateObj = new CoviMap();
		dateObj.put("StartDate", eventDateObj.getString("StartDate"));
		dateObj.put("EndDate", eventDateObj.getString("EndDate"));
		
		
		//  Date 데이터 추가
		params = new CoviMap();
		String startDate = dateObj.getString("StartDate");
		String startTime = eventDateObj.getString("StartTime");
		String endDate = dateObj.getString("EndDate");
		String endTime = eventDateObj.getString("EndTime");
		
		params.put("EventID", eventID);
		params.put("RepeatID", repeatID);
		params.put("StartDateTime", startDate + " " + startTime);
		params.put("StartDate", startDate);
		params.put("StartTime", startTime);
		params.put("EndDateTime", endDate + " " + endTime);
		params.put("EndDate", endDate);
		params.put("EndTime", endTime);
		params.put("IsAllDay", eventDateObj.getString("IsAllDay"));
		params.put("IsRepeat", "N");
		
		dateID = eventSvc.insertEventDate(params);
		
		// 협업 스페이스
		if(prjMap != null && prjMap.size() > 0){
			CoviMap reqMap = new CoviMap();	
			CoviMap trgMap = new CoviMap();
			
			List trgMember = new ArrayList();
			trgMap.put("userCode", SessionHelper.getSession("USERID"));
			trgMember.add(trgMap);
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("prjSeq", prjMap.get("prjSeq"));
			reqMap.put("prjType",  prjMap.get("prjType"));
			reqMap.put("sectionSeq", prjMap.get("sectionSeq"));
			reqMap.put("taskName", eventObj.getString("Subject"));
			reqMap.put("startDate", startDate);
			reqMap.put("endDate", endDate);
			reqMap.put("taskStatus", "W");
			reqMap.put("progRate", "0");
			reqMap.put("parentKey", "0");
			reqMap.put("topParentKey", "0");
			reqMap.put("objectType", "EVENT");
			reqMap.put("objectID", eventID);
			
			CoviMap delMap = new CoviMap();
			delMap.put("taskSeq", prjMap.get("taskSeq"));
			delMap.put("isTopTask", "Y");
			
			collabTaskSvc.deleteTask(delMap);
			collabTaskSvc.addTask(reqMap, trgMember);
		}
		
		// 알림 데이터 - 등록자
		params = new CoviMap();
		params.put("EventID", eventID);
		params.put("DateID", dateID);
		if(notificationObj != null && !notificationObj.isEmpty()) {
			params.put("IsNotification", notificationObj.getString("IsNotification"));
			params.put("IsReminder",  notificationObj.getString("IsReminder"));
			params.put("ReminderTime",  notificationObj.getString("ReminderTime"));
			params.put("IsCommentNotification",  notificationObj.getString("IsCommentNotification"));
			params.put("MediumKind",  notificationObj.getString("MediumKind"));
		} else {
			params.put("IsNotification", "N");
			params.put("IsReminder", "N");
			params.put("ReminderTime", "10");
			params.put("IsCommentNotification", "N");
			params.put("MediumKind", "");
		}

		
		eventSvc.insertEventNotificationByRegister(params);
		
		params = new CoviMap();
		params.put("EventID", eventID);
		params.put("DateID", oldDateID);
		eventSvc.deleteEventNotification(params);
		
		// 미리 알림 보내기
		// 이전 미리알림 취소 처리
		params = new CoviMap();
		params.put("SearchType", "LIKE");
		params.put("ServiceType", "Schedule");
		params.put("ObjectType", "reminder_%");			// 참석자까지 모두 삭제
		params.put("ObjectID", oldDateID);
		eventSvc.updateMessagingCancelState(params);
		//params.put("ServiceType", "Resource");
		//eventSvc.updateMessagingCancelState(params);
		
		// 반복일정을 별도로 새로 저장시
		/*if(eventObj.getString("EventType").equals("M")){
			// 기존 반복일정으로 저장된 Date 데이터 삭제
			params = new CoviMap();
			params.put("DateID", dataObj.getString("DateID"));
			
			eventSvc.deleteEventDateByDateID(params);
		}*/
		
		// 자원 예약(Insert) 및 Update
		if(resourceAct.equalsIgnoreCase("INSERT")){
			for(Object obj_2 : resourceArr){
				CoviMap resourceObj = (CoviMap) obj_2;
			
				String bookingState = "ApprovalRequest";
				
				params = new CoviMap();
				params.put("FolderID", resourceObj.getString("FolderID")); 
				
				CoviMap resourceDataObj = eventSvc.selectResourceData(params);
				
				if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
					bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
				}
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", eventObj.getString("Subject"));
				notiParam.put("EventID", eventID);
				notiParam.put("DateID", dateID);
				notiParam.put("RepeatID", repeatID);
				notiParam.put("IsRepeat", "N");	// 반복일정 개별등록이기 때문에 N
				notiParam.put("ResourceID", resourceObj.getString("FolderID"));
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
					notiParam.put("SenderCode", SessionHelper.getSession("USERID"));
					notiParam.put("ReceiversCode", SessionHelper.getSession("USERID"));
					resourceSvc.sendMessage(notiParam, "BookingComplete");
				}else{ //담당자 승인일 경우 승인요청 알림 보내기
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceObj.getString("FolderID"));
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode", SessionHelper.getSession("USERID"));
					notiParam.put("ReceiversCode", managerCode);
					resourceSvc.sendMessage(notiParam, "ApprovalRequest");
				}
				
				
				params = new CoviMap();
				params.put("DateID", dateID);
				params.put("EventID", eventID);
				params.put("ResourceID", resourceObj.getString("FolderID"));						// 자원 ID
				params.put("ApprovalDate", null);
				params.put("ApprovalState", bookingState);
				params.put("RealEndDateTime", endDate + " " + endTime);
			
				// Resource Booking 데이터
				eventSvc.insertEventResourceBooking(params);
				
				params = new CoviMap();
				params.put("ScheduleID", eventID);
				params.put("ResourceID", resourceObj.getString("FolderID"));
				eventSvc.insertEventRelation(params);
			}
		}else if(resourceAct.equalsIgnoreCase("UPDATE")){
			params = new CoviMap();
			
			params.put("oldEventID", oldEventID);
			params.put("oldDateID", oldDateID);
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			
			eventSvc.updateEachScheduleResource(params);		// resource booking 데이터 업데이트
			eventSvc.insertEachScheduleRelation(params);			// relation 데이터 INSERT
		}
		
		/*params = new CoviMap();
		params.put("dateID", dateID);
		params.put("eventID", eventID);
		params.put("notificationObj", notificationObj);
		params.put("RegisterCode", eventObj.getString("RegisterCode"));
		params.put("Subject", eventObj.getString("Subject"));
		params.put("IsRepeat", "N");
		params.put("FolderID", eventObj.getString("FolderID"));
		params.put("startDate", startDate);
		params.put("startTime", startTime);
		sendReminderAlarm(params);*/
		
		// 참석자, 알림
		// 참석자 데이터
		if(attendantArr.size() > 0){
			for(Object obj : attendantArr){
				CoviMap attendantObj = (CoviMap) obj;
				
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("AttenderCode", attendantObj.getString("UserCode"));
				params.put("MultiAttenderName", attendantObj.getString("UserName"));
				params.put("IsOutsider", attendantObj.getString("IsOutsider"));
				params.put("IsAllow", "");
				
				insertEventAttendant(params);
				
				/*// 알림 데이터
				if(!eventObj.getString("RegisterCode").equals(attendantObj.getString("UserCode"))){
					params = new CoviMap();
					params.put("EventID", eventID);
					params.put("RegisterCode", attendantObj.getString("UserCode"));
					params.put("RegisterKind", "A");
					params.put("IsNotification", notificationObj.getString("IsNotification"));
					params.put("IsReminder", notificationObj.getString("IsReminder"));
					params.put("ReminderTime", notificationObj.getString("ReminderTime"));
					params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
					params.put("MediumKind", notificationObj.getString("MediumKind"));
				
					eventSvc.insertEventNotification(params);
					
					//미리알림
					params = new CoviMap();
					params.put("dateID", dateID);
					params.put("eventID", eventID);
					params.put("notificationObj", notificationObj);
					params.put("RegisterCode", attendantObj.getString("UserCode"));
					params.put("Subject", eventObj.getString("Subject"));
					params.put("IsRepeat", "N");
					params.put("FolderID", eventObj.getString("FolderID"));
					params.put("startDate", startDate);
					params.put("startTime", startTime);
					sendReminderAlarm(params);
				}*/
				
				// 참석요청 알림
				CoviMap notiParams = new CoviMap();
				String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+ "&eventID=" + eventID
						+ "&dateID=" + dateID
						+ "&isRepeat=" + "N"
						+ "&folderID=" + eventObj.getString("FolderID")
						+ "&isAttendee=Y";
				
				String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
						+ "&isrepeat=" + "N" + "&folderid=" + eventObj.getString("FolderID");
				
				notiParams.put("SenderCode", SessionHelper.getSession("USERID"));
				notiParams.put("RegisterCode", SessionHelper.getSession("USERID"));
				notiParams.put("ReceiversCode", attendantObj.getString("UserCode"));
				notiParams.put("MessagingSubject", eventObj.getString("Subject"));
				notiParams.put("ReceiverText", eventObj.getString("Subject"));
				notiParams.put("ServiceType", "Schedule");
				notiParams.put("GotoURL", alarmUrl);
				notiParams.put("PopupURL", alarmUrl);
				notiParams.put("MobileURL", mobileAlarmUrl);
				notiParams.put("MsgType", "ScheduleAttendance");
				
				eventSvc.sendNotificationMessage(notiParams);
			}
		}
		
		// 자원의 확장필드 정보 추가
		if(!IsSchedule){
			CoviList userformArr = dataObj.getJSONArray("UserForm");
			
			//Userform 데이터
			for(Object obj : userformArr){
				CoviMap userformObj = (CoviMap) obj;
				
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("UserFormID", userformObj.getString("UserFormID"));
				params.put("FolderID", userformObj.getString("FolderID"));
				params.put("FieldValue", userformObj.getString("FieldValue"));
				
				coviMapperOne.insert("user.resource.insertUserformValue",params);
			}
		}
		
		return returnObj;
	}


	// 일정 상세 조회
	@Override
	public CoviMap getOneDetail(CoviMap params) throws Exception {
		CoviMap detailObj = new CoviMap();
		
		// Event
		CoviMap eventObj = eventSvc.selectEvent(params);
		
		// eventObj가 빈 오브젝트일 경우 존재하지 않는 일정 Key 또는 삭제된 일정
		if(eventObj.isEmpty())
			return null;
		
		// Date
		CoviMap dateObj = eventSvc.selectEventDate(params);
		
		if(dateObj.isEmpty()) {
			String alarmType = params.getString("IsAlarm");
			// Alarm Type이 R인경우 DateID가 변경된 경우 EMPTY Return
			if("R".equals(alarmType)) {
				return null;
			} 
			// Alaram Type이 A인경우 변경된 DateID에 대한 방어코드 추가 (최신 DateID 값 유지)								
			else if ("A".equals(alarmType)) {
				CoviMap tempParam = new CoviMap();
				tempParam.put("EventID", params.getString("EventID"));
				dateObj = eventSvc.selectEventDate(tempParam);
			}
		}
		
		
		// Repeat
		CoviMap repeatObj = eventSvc.selectEventRepeat(params);
		
		// Attendant
		CoviList attendantObj = selectEventAttendant(params);
		
		// Resource
		CoviList resourceObj = eventSvc.selectEventResource(params);
		
		// Notification
		params.put("RegisterCode", params.getString("UserCode"));
		CoviMap notificationObj = eventSvc.selectEventNotification(params);
		
		// 댓글 알림을 보내기 위한 JSONObject
		CoviList notiCommentObj = eventSvc.selectNotificationComment(params);
		
		CoviMap collabParams = new CoviMap();
		collabParams.put("objectID", params.getString("EventID"));
		collabParams.put("objectType", "EVENT");
		collabParams.put("lang", SessionHelper.getSession("lang"));
		CoviMap collabObj = coviMapperOne.select("collab.task.getPrjInfoFromObjectTypeObjectID", collabParams);
		
		detailObj.put("Event", eventObj);
		detailObj.put("Date", dateObj);
		detailObj.put("Resource", resourceObj);
		detailObj.put("Repeat", repeatObj);
		detailObj.put("Attendee", attendantObj);
		detailObj.put("Notification", notificationObj);
		detailObj.put("NotiComment", notiCommentObj);
		detailObj.put("CollabPrj", collabObj);
		
		return detailObj;
	}


	// 일정 간단 조회
	@Override
	public CoviMap getOneSimple(CoviMap params) throws Exception {
		CoviMap simpleObj = new CoviMap();
		
		// Event
		CoviMap eventObj = eventSvc.selectEvent(params);
		
		// Date
		CoviMap dateObj = eventSvc.selectEventDate(params);
		
		// Resource
		CoviList resourceObj = eventSvc.selectEventResource(params);
		
		// Attendant
		CoviList attendantObj = selectEventAttendant(params);
		
		simpleObj.put("Event", eventObj);
		simpleObj.put("Date", dateObj);
		simpleObj.put("Resource", resourceObj);
		simpleObj.put("Attendee", attendantObj);
		
		return simpleObj;
	}
	
	// Event Attendant 조회
	@Override
	public  CoviList selectEventAttendant(CoviMap params) throws Exception{
		CoviList  list = coviMapperOne.list("user.schedule.selectEventAttendant", params);
		
		return CoviSelectSet.coviSelectJSON(list, "UserCode,UserName,DeptCode,DeptName,IsOutsider,IsAllow,DomainID");
	}

	// 일정 삭제
	@Override
	public void deleteEvent(CoviMap params) throws Exception {
		
		// 연결된 자원 여부 및 자원 개수 조회
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList list = coviMapperOne.list("user.event.selectEventResource", params);
		
		String eventID = params.getString("EventID");
		
		// 자원과 일정 관계를 끊기
		CoviMap paramMap = new CoviMap();
		int listCnt = list.size();
		if(listCnt > 0){
			// 일정과 자원이 1:n, 1:1
			paramMap = new CoviMap();
			paramMap.put("EventID", eventID);
			coviMapperOne.update("user.schedule.updateEventDeleted", paramMap);
			
			for(Object obj : list){
				String resourceID = ((CoviMap)obj).getString("FolderID");
				
				// 1. Event 데이터 조회 후 삽입
				paramMap.put("ResourceID", resourceID);
				coviMapperOne.insert("user.schedule.insertSelectEvent", paramMap);
				
				String newEventID = paramMap.getString("EventID");
				String oldEventID = eventID;
				
				paramMap.put("newEventID", newEventID);
				paramMap.put("oldEventID", oldEventID);
				
				// 2. Event_Repeat 데이터 조회 후 삽입
				coviMapperOne.insert("user.schedule.insertSelectEventRepeat", paramMap);
				
				// 3. Event_Date 데이터 조회 후 삽입
				coviMapperOne.insert("user.schedule.insertSelectEventDate", paramMap);
				
				String newDateIDs = paramMap.getString("newDateIDs");
				String oldDateIDs = paramMap.getString("oldDateIDs");
				
				// 4. Event_Resource_Booking의 EventID, DateID, 데이터 수정
				String[]  newDateIDArr = newDateIDs.split(",");
				String[]  oldDateIDArr = oldDateIDs.split(",");
				
				paramMap.put("ResourceID", resourceID);
				for(int i=0; i<newDateIDArr.length; i++){
					paramMap.put("newDateID", newDateIDArr[i]);
					paramMap.put("oldDateID", oldDateIDArr[i]);
					coviMapperOne.update("user.schedule.updateBookingEventDateID", paramMap);	
					
					// 5. Event_Notification 데이터 조회 후 삽입 (등록자 데이터만)
					// 알림 데이터 다시 INSERT 필요
					//coviMapperOne.insert("user.schedule.insertSelectEventNotificationR", paramMap);
					
					params = new CoviMap();
					params.put("EventID", newEventID);
					params.put("DateID", newDateIDArr[i]);
					params.put("IsNotification", "N");
					params.put("IsReminder", "N");
					params.put("ReminderTime", "10");
					params.put("IsCommentNotification", "N");
					params.put("MediumKind", "");
					eventSvc.insertEventNotificationByRegister(params);
				}
			}
		}
		// 연결된 자원이 없는 일정
		else{
			coviMapperOne.update("user.schedule.updateEventDeleted", params);
		}
		
		CoviList oldDateIDs  = new CoviList(Arrays.asList(eventSvc.getDateIDs(eventID)));
		
		//일정 미리 알림 삭제
		params.put("SearchType", "LIKE");
		params.put("ServiceType", "Schedule");
		params.put("ObjectType", "reminder_%"); 
		params.put("arrObjectID", oldDateIDs);
		eventSvc.updateArrMessagingCancelState(params);
		
		//coviMapperOne.update("user.schedule.updateEventDeleted", params);
		//coviMapperOne.update("user.schedule.updateEventResourceBookingDeleted", params);
		
		// 참석자 개인일정 삭제 후 알림
	}
	
	// 참석자 데이터 추가
	@Override
	public void insertEventAttendant(CoviMap params) throws Exception {
		coviMapperOne.insert("user.schedule.insertEventAttendant", params);
	}
	
	// 참석자 조회
	@Override
	public CoviList selectAttendee(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectAttendee", params);
		
		return CoviSelectSet.coviSelectJSON(list, "UserCode,UserName,IsOutsider");
	}

	//삭제된 참석자가 개인일정으로 별도 등록했을 경우 삭제 
	@Override
	public void deleteEventByAttendeeData(CoviMap params) throws Exception {
		coviMapperOne.delete("user.schedule.deleteEventByAttendeeData", params);
	}

	// 참석자 삭제
	@Override
	public void deleteEventAttendant(CoviMap params) throws Exception {
		coviMapperOne.delete("user.schedule.deleteEventAttendant", params);
	}

	// 오늘의 일정 조회
	@Override
	public CoviList selectToday(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectToday", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,Color,EventID,Subject,ImportanceState,RegisterCode,MultiRegisterName,DateID,StartDateTime,StartDate,StartTime,EndDateTime,EndDate,EndTime");
	}
	
	// 이달의 일정 조회
	@Override
	public CoviList selectThisMonth(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectThisMonth", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,Color,EventID,Subject,ImportanceState,RegisterCode,MultiRegisterName,DateID,StartDateTime,StartDate,StartTime,EndDateTime,EndDate,EndTime");
	}

	// 참석 요청중인 일정
	@Override
	public CoviList selectAttendList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectAttendList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "EventID,DateID,MasterEventID,FolderID,FolderName,Color,ImportanceState,RepeatStartDate,RepeatEndDate,Subject,RegisterCode,MultiRegisterName,IsRepeat");
	}

	// 참석자 승인 / 거부
	@Transactional
	@Override
	public void approve(String mode, CoviMap params) throws Exception {
		if(mode.equals("APPROVAL")){
			params.put("IsAllow", "Y");
			
			/* event_attendant 테이블을 보도록 변경
			// 개인 일정 추가 여부
			int cnt = selectAttendeePersonalSchedule(params);
			
			// 개인 일정 추가
			if(cnt == 0)
				insertAttendeePersonalSchedule(params);
			*/
			
			CoviList notiArr = coviMapperOne.list("user.schedule.selectEventNotificationAll", params);
			CoviMap notiObj = notiArr.getMap(0);
			
			if ("Y".equals(notiObj.getString("IsNotification")) && "Y".equals(notiObj.getString("IsReminder"))){
				CoviMap eventObj = eventSvc.selectEvent(params);
				CoviList resourceArr = eventSvc.selectEventResource(params);
				CoviList dateArr = coviMapperOne.list("user.event.selectEventDate", params);
				
				insertReminderMessage(eventObj, resourceArr, params.getString("UserCode"), notiObj, dateArr, true);
			}
			
		}else if(mode.equals("REJECT")){
			params.put("IsAllow", "N");
		}
		
		// 참석자 상태 Update
		updateAttendeeAllow(params);
	}
	
	@Override
	public String checkAttendeeAuth(CoviMap params) throws Exception {
		String strResult = "N";
		
		CoviList attendeeList = selectAttendee(params);
		
		for(Object obj : attendeeList) {
			CoviMap attendee = (CoviMap)obj;
			
			if(attendee.getString("UserCode").equals(params.getString("UserCode"))){
				strResult = "Y";
				break;
			}
		}
		
		return strResult;
	}
	
	// 참석자 승인 시 개인 일정 추가하기 전에 이미 추가되어 있는지 확인 필요
	@Override
	public int selectAttendeePersonalSchedule(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.selectOne("user.schedule.selectAttendeePersonalSchedule", params);
		
		return cnt;
	}

	// 참석자 승인 시 개인 일정 추가
	@Override
	public void insertAttendeePersonalSchedule(CoviMap params) throws Exception {
		coviMapperOne.insert("user.schedule.insertAttendeePersonalSchedule", params);
	}
	
	// 참석자 승인/거부 상태 Update
	@Override
	public void updateAttendeeAllow(CoviMap params) throws Exception {
		coviMapperOne.update("user.schedule.updateAttendeeAllow", params);
	}

	// 자주 쓰는 일정 조회
	@Override
	public CoviList selectTemplateList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectTemplateList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "EventID,FolderID,FolderType,Subject,Place");
	}

	// 테마 일정 목록 조회
	@Override
	public CoviList selectThemeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectThemeList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,FolderType,MultiDisplayName,SortKey,IsUse,OwnerCode,Color");
	}
	
	// 테마 일정 조회
	@Override
	public CoviMap selectThemeOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.schedule.selectThemeOne", params);
		
		return CoviSelectSet.coviSelectJSON(map, "FolderID,DomainID,MenuID,FolderType,DisplayName,MultiDisplayName,SortKey,IsUse,OwnerCode,Color").getJSONObject(0);
	}

	// 테마 일정 삭제
	@Override
	public void deleteTheme(CoviMap params) throws Exception {
		coviMapperOne.update("user.schedule.deleteTheme", params);
		
		coviMapperOne.delete("user.schedule.deleteThemeACL", params);
	}

	// 드래그 및 드롭할 경우, Date 수정
	@Override
	public CoviMap updateDateDataByDragDrop(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String startDate = params.getString("StartDate");
		String startTime = params.getString("StartTime");
		String setType = params.getString("setType");
		
		String diffStartTime = "";
		String diffEndTime = "";
		int diifDate = 0;
		int diifTime = 0;
		
		if(!startDate.equals("") && !startDate.equals("undefined")){
			diifDate = selectDiffDate(params);
			params.put("diffDate", diifDate);
			
		}
		
		if(!startTime.equals("") && !startTime.equals("undefined")){
			diifTime = selectDiffTime(params);
			params.put("diffTime", diifTime);
			diffStartTime = startTime;
		} else {
			// 시작시간은 월간일정에서는 조회할 수 없음
			CoviMap startEndTime = getStartEndTime(params);
			diffStartTime = startEndTime.getString("StartTime");
			diffEndTime = startEndTime.getString("EndTime");
		}
		
		// 중복체크
		CoviMap eventDateObj = new CoviMap();
		eventDateObj.put("StartDate", startDate);
		eventDateObj.put("StartTime", diffStartTime);
		
		// EndDate 구하기
		String diffEndDate = DateHelper.getAddDate(startDate, "yyyy-MM-dd", diifDate, Calendar.DATE);
		eventDateObj.put("EndDate", diffEndDate);
		
		if(StringUtil.isEmpty(diffEndTime)) {
			String endDateTime = DateHelper.getAddDate(diffEndDate + " " + diffStartTime, "yyyy-MM-dd HH:mm", diifTime, Calendar.MINUTE);
			eventDateObj.put("EndTime", endDateTime.split(" ")[1]);
		} else {
			eventDateObj.put("EndTime", diffEndTime);			
		}
		
		
		CoviList eventResObj = eventSvc.selectEventResource(params);
		
		if(eventResObj.size() > 0){
			for(Object obj : eventResObj){
				CoviMap paramRes = new CoviMap();
				paramRes.put("DateID", params.getString("DateID"));
				paramRes.put("EventID", params.getString("EventID"));
				paramRes.put("ResourceID", ((CoviMap)obj).getString("FolderID"));
				
				// 중복체크
				CoviMap checkObj = resourceSvc.checkDuplicateTime(((CoviMap)obj).getString("FolderID"), params.getString("DateID"), params.getString("EventID"), eventDateObj, null);
				
				if(checkObj.getString("IsDuplication").equals("1")) {
					checkObj.put("status", "DUPLICATION");
					return checkObj;
				}
			}
		}
		
		// 협업 스페이스 - event_date 변경 전 작업 필요
		CoviMap tMap = new CoviMap();
		tMap.put("lang", SessionHelper.getSession("lang"));
		tMap.put("eventID", params.getString("EventID"));
		tMap.put("dateID", params.getString("DateID"));
		
		CoviMap taskMap = RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y") ? collabTaskSvc.getTaskMapBySchedule(tMap) : null;
		
		if(taskMap != null && taskMap.size() > 0 && !setType.equalsIgnoreCase("RU")
			&& !startDate.equals("") && !startDate.equals("undefined")){			
			CoviMap updateParam = new CoviMap();
			
			updateParam.put("taskSeq", taskMap.getString("taskSeq"));
			updateParam.put("startDate", startDate);
			updateParam.put("diffDate", params.getString("diffDate"));
			
			collabTaskSvc.updateTaskDateBySchedule(updateParam);
		}
		
		if(!startDate.equals("") && !startDate.equals("undefined")){			
			updateEventDateForDate(params);
		}
		if(!startTime.equals("") && !startTime.equals("undefined")){
			updateEventDateForTime(params);
		}
		updateEventDateForDateTime(params);
		
		
		if(eventResObj.size() > 0){
			for(Object obj : eventResObj){
				CoviMap resourceObj = (CoviMap) obj;
				
				
				CoviMap paramRes = new CoviMap();
				paramRes.put("DateID", params.getString("DateID"));
				paramRes.put("EventID", params.getString("EventID"));
				paramRes.put("ResourceID", resourceObj.getString("FolderID"));
				
				// 자원이 있을 경우 자원 RealEndDateTime 수정
				eventSvc.updateResourceRealEndDateTime(paramRes);
				
				String bookingState = "ApprovalRequest";
				CoviMap paramsResNoti = new CoviMap();
				paramsResNoti.put("FolderID", resourceObj.getString("FolderID")); 
				
				CoviMap resourceDataObj = eventSvc.selectResourceData(paramsResNoti);
				
				if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
					bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
				}
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", params.getString("Subject"));
				notiParam.put("EventID", params.getString("EventID"));
				notiParam.put("DateID", params.getString("DateID"));
				notiParam.put("RepeatID", params.getString("RepeatID"));
				notiParam.put("IsRepeat", "N");	// 반복일정은 DrogNDrop으로 수정 불가
				notiParam.put("ResourceID", resourceObj.getString("FolderID"));
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
					notiParam.put("SenderCode", params.getString("ModifierCode"));
					notiParam.put("ReceiversCode", params.getString("ModifierCode"));
					resourceSvc.sendMessage(notiParam, "BookingComplete");
				}else{ //담당자 승인일 경우 승인요청 알림 보내기
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceObj.getString("FolderID"));
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode" , params.getString("ModifierCode"));
					notiParam.put("ReceiversCode", managerCode);
					resourceSvc.sendMessage(notiParam, "ApprovalRequest");
				}
				
				
			}
		}
		
		// 반복 예약 개별 수정 시
		if(setType.equalsIgnoreCase("RU")){
			// 날짜 정보 조회해서 데이터 생성
			CoviMap dateObj = eventSvc.selectEventDate(params);
			
			CoviMap oldObj = getOneDetail(params);
			oldObj.put("Date", dateObj);
			
			oldObj.getJSONObject("Event").put("MasterEventID", params.getString("EventID"));
			oldObj.getJSONObject("Event").put("EventType", "M");
			oldObj.getJSONObject("Date").put("IsRepeat", "N");
			
			oldObj.put("EventID", params.getString("EventID"));
			oldObj.put("DateID", params.getString("DateID"));
			
			if(taskMap != null && taskMap.size() > 0) {
				oldObj.put("prjMap", taskMap);
			}
			
			setEachSchedule(oldObj, null, null, "true", "false", true);
		} else {
			String eventID = params.getString("EventID");
			String dateID = params.getString("DateID");
			
			//JSONObject dataObj = getOneDetail(params);
			
			//JSONObject eventObj = dataObj.getJSONObject("Event");				// 이벤트 마스터 정보
			//JSONObject dateObj = dataObj.getJSONObject("Date");
			//CoviList resourceArr = dataObj.getJSONArray("Resource");						// 자원 예약 정보
			//JSONObject repeatObj = dataObj.getJSONObject("Repeat").getJSONObject("ResourceRepeat");						// 반복 정보
			//CoviList attendantArr = dataObj.getJSONArray("Attendee");					// 참석자 정보
			//JSONObject notificationObj = dataObj.getJSONObject("Notification");		// 알림 정보
			
			// 변경된 자원 예약정보 알림 (?)
			
			// 미리알림 취소 및 재처리
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			eventSvc.deleteEventNotification(params);
			
			// 미리 알림 보내기
			// 이전 미리알림 취소 처리
			CoviMap notiParams = new CoviMap();
			notiParams.put("SearchType", "LIKE");
			notiParams.put("ServiceType", "Schedule");
			notiParams.put("ObjectType", "reminder_%");			// 참석자까지 모두 삭제
			notiParams.put("ObjectID", dateID);
			eventSvc.updateMessagingCancelState(notiParams);
			//params.put("ServiceType", "Resource");
			//eventSvc.updateMessagingCancelState(notiParams);
			
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("IsNotification", "N");
			params.put("IsReminder", "N");
			params.put("ReminderTime", "10");
			params.put("IsCommentNotification", "N");
			params.put("MediumKind", "");
			
			eventSvc.insertEventNotificationByRegister(params);
			
			/* 날짜 변경 시 알림 초기화
			notiParams = new CoviMap();
			notiParams.put("dateID", dateID);
			notiParams.put("eventID", eventID);
			notiParams.put("notificationObj", notificationObj);
			notiParams.put("RegisterCode", eventObj.getString("RegisterCode"));
			notiParams.put("Subject", eventObj.getString("Subject"));
			notiParams.put("IsRepeat", "N");
			notiParams.put("FolderID", eventObj.getString("FolderID"));
			notiParams.put("startDate", startDate);
			notiParams.put("startTime", diffStartTime);
			sendReminderAlarm(notiParams);*/
			
			
			// 참석자에게 참석변경 알림 발송
			// 참석자, 알림
			// 참석자 데이터
			/*if(attendantArr.size() > 0){
				CoviMap attParams = null;
				for(Object obj : attendantArr){
					CoviMap attendantObj = (CoviMap) obj;
					
					// 알림 데이터
					if(!eventObj.getString("RegisterCode").equals(attendantObj.getString("UserCode"))){
						//미리알림
						attParams = new CoviMap();
						attParams.put("dateID", dateID);
						attParams.put("eventID", eventID);
						attParams.put("notificationObj", notificationObj);
						attParams.put("RegisterCode", attendantObj.getString("UserCode"));
						attParams.put("Subject", eventObj.getString("Subject"));
						attParams.put("IsRepeat", "N");
						attParams.put("FolderID", eventObj.getString("FolderID"));
						attParams.put("startDate", startDate);
						attParams.put("startTime", diffStartTime);
						sendReminderAlarm(attParams);
					}
					
					// 참석변경 알림
					notiParams = new CoviMap();
					String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
							+ "&eventID=" + eventID
							+ "&dateID=" + dateID
							+ "&isRepeat=" + "N"
							+ "&folderID=" + eventObj.getString("FolderID");
					
					String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
							+ "&isrepeat=" + "N" + "&folderid=" + eventObj.getString("FolderID");
					
					notiParams.put("SenderCode", eventObj.getString("RegisterCode"));
					notiParams.put("RegisterCode", eventObj.getString("RegisterCode"));
					notiParams.put("ReceiversCode", attendantObj.getString("UserCode"));
					notiParams.put("MessagingSubject", eventObj.getString("Subject"));
					notiParams.put("ReceiverText", eventObj.getString("Subject"));
					notiParams.put("ServiceType", "Schedule");
					notiParams.put("GotoURL", alarmUrl);
					notiParams.put("PopupURL", alarmUrl);
					notiParams.put("MobileURL", mobileAlarmUrl);
					notiParams.put("MsgType", "ScheduleAttChange");
					
					eventSvc.sendNotificationMessage(notiParams);
				}
			}*/

		}
		
		//TODO 미리알림 변경 필요
		returnObj.put("status", "SUCCESS");
		
		return returnObj;
	}

	//시작일과 종료일 차이
	@Override
	public int selectDiffDate(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.schedule.selectDiffDate", params);
	}
	
	//시작 시간과 종료시간 차이
	@Override
	public int selectDiffTime(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.schedule.selectDiffTime", params);
	}
	
	//시작일 및 종료일 Update
	@Override
	public void updateEventDateForDate(CoviMap params) throws Exception {
		coviMapperOne.update("user.schedule.updateEventDateForDate", params);
		
		//TODO 미리알림 변경 필요
	}
	
	//시작시간 및 종료시간 Update
	@Override
	public void updateEventDateForTime(CoviMap params) throws Exception {
		coviMapperOne.update("user.schedule.updateEventDateForTime", params);
		
		//TODO 미리알림 변경 필요
	}
	
	//시작일시 및 종료일시 Update
	@Override
	public void updateEventDateForDateTime(CoviMap params) throws Exception {
		coviMapperOne.update("user.schedule.updateEventDateForDateTime", params);
		
		//TODO 미리알림 변경 필요
	}
	
	@Override
	public CoviMap getStartEndTime(CoviMap params) throws Exception {
		return coviMapperOne.select("user.schedule.selectStartEndTime", params);
	}
	
	

	// Resize 할 경우, 종료시간 Update
	@Override
	public CoviMap updateDateDataByResize(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		// 자원 중복체크
		CoviList eventResObj = eventSvc.selectEventResource(params);
		
		String startDate = params.getString("StartDateTime").split(" ")[0];
		String startTime = params.getString("StartDateTime").split(" ")[1];
		String endDate = params.getString("EndDateTime").split(" ")[0];
		String endTime = params.getString("EndDateTime").split(" ")[1];

		params.put("EndTime", endTime);
		
		// 자원이 있을경우 자원 중복검사
		if(eventResObj.size() > 0){			
			CoviMap eventDateObj = new CoviMap();
			eventDateObj.put("StartDate", startDate);
			eventDateObj.put("StartTime", startTime);
			eventDateObj.put("EndDate", endDate);
			eventDateObj.put("EndTime", endTime);
			
			for(Object obj : eventResObj){
				CoviMap paramRes = new CoviMap();
				paramRes.put("DateID", params.getString("DateID"));
				paramRes.put("EventID", params.getString("EventID"));
				paramRes.put("ResourceID", ((CoviMap)obj).getString("FolderID"));
				
				// 중복체크
				CoviMap checkObj = resourceSvc.checkDuplicateTime(((CoviMap)obj).getString("FolderID"), params.getString("DateID"), params.getString("EventID"), eventDateObj, null);
				
				if(checkObj.getString("IsDuplication").equals("1")) {
					checkObj.put("status", "DUPLICATION");
					return checkObj;
				}
			}
		}	
		
		coviMapperOne.update("user.schedule.updateEventEndDate", params);
		

		// 자원이 있을 경우 자원 RealEndDateTime 수정
		if(eventResObj.size() > 0){
			for(Object obj : eventResObj){
				CoviMap resourceObj = (CoviMap) obj;
				
				CoviMap paramRes = new CoviMap();
				paramRes.put("DateID", params.getString("DateID"));
				paramRes.put("EventID", params.getString("EventID"));
				paramRes.put("ResourceID", resourceObj.getString("FolderID"));
				
				eventSvc.updateResourceRealEndDateTime(paramRes);
				
				

				String bookingState = "ApprovalRequest";
				CoviMap paramsResNoti = new CoviMap();
				paramsResNoti.put("FolderID", resourceObj.getString("FolderID")); 
				
				CoviMap resourceDataObj = eventSvc.selectResourceData(paramsResNoti);
				
				if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
					bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
				}
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", params.getString("Subject"));
				notiParam.put("EventID", params.getString("EventID"));
				notiParam.put("DateID", params.getString("DateID"));
				notiParam.put("RepeatID", params.getString("RepeatID"));
				notiParam.put("IsRepeat", "N");	// 반복일정은 DrogNDrop으로 수정 불가
				notiParam.put("ResourceID", resourceObj.getString("FolderID"));
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
					notiParam.put("SenderCode", params.getString("ModifierCode"));
					notiParam.put("ReceiversCode", params.getString("ModifierCode"));
					resourceSvc.sendMessage(notiParam, "BookingComplete");
				}else{ //담당자 승인일 경우 승인요청 알림 보내기
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceObj.getString("FolderID"));
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode" , params.getString("ModifierCode"));
					notiParam.put("ReceiversCode", managerCode);
					resourceSvc.sendMessage(notiParam, "ApprovalRequest");
				}
				
			}
		}
		
		// 반복 예약 개별 수정 시
		String setType = params.getString("setType");
		if(setType.equalsIgnoreCase("RU")){
			// 날짜 정보 조회해서 데이터 생성
			CoviMap dateObj = eventSvc.selectEventDate(params);
			
			CoviMap oldObj = getOneDetail(params);
			oldObj.put("Date", dateObj);
			
			oldObj.getJSONObject("Event").put("MasterEventID", params.getString("EventID"));
			oldObj.getJSONObject("Event").put("EventType", "M");
			oldObj.getJSONObject("Date").put("IsRepeat", "N");
			
			oldObj.put("EventID", params.getString("EventID"));
			oldObj.put("DateID", params.getString("DateID"));
			
			setEachSchedule(oldObj, null, null, "true", "false", true);
		}  else {
			// 리사이즈는 시작시간이 변경되지 않으므로 아래 로직 보류여부 확인필요
			String eventID = params.getString("EventID");
			String dateID = params.getString("DateID");
			
			CoviMap dataObj = getOneDetail(params);
			
			CoviMap eventObj = dataObj.getJSONObject("Event");				// 이벤트 마스터 정보
			CoviMap dateObj = dataObj.getJSONObject("Date");
			CoviList resourceArr = dataObj.getJSONArray("Resource");						// 자원 예약 정보
			//JSONObject repeatObj = dataObj.getJSONObject("Repeat").getJSONObject("ResourceRepeat");						// 반복 정보
			CoviList attendantArr = dataObj.getJSONArray("Attendee");					// 참석자 정보
			CoviMap notificationObj = dataObj.getJSONObject("Notification");		// 알림 정보
			
			// 알림설정 삭제
			params = new CoviMap();
			params.put("EventID", eventID);
			eventSvc.deleteEventNotification(params);
			
			// 미리알림 취소
			params = new CoviMap();
			params.put("SearchType", "LIKE");
			params.put("ServiceType", "Schedule");
			params.put("ObjectType", "reminder_%");			// 참석자까지 모두 삭제
			params.put("ObjectID", dateID);
			eventSvc.updateMessagingCancelState(params);
			
			
			// 알림 데이터 - 등록자 ( Date 변경시에도 등록자의 알림세팅은 Default 값으로 입력 )
			params = new CoviMap();
			params.put("EventID", eventID);
			params.put("DateID", dateID);
			params.put("IsNotification", "N");
			params.put("IsReminder", "N");
			params.put("ReminderTime", "10");
			params.put("IsCommentNotification", "N");
			params.put("MediumKind", "");
			
			eventSvc.insertEventNotificationByRegister(params);
			
			// 참석자에게 참석변경 알림 발송
			// 참석자, 알림
			// 참석자 데이터
			
			/*if(attendantArr.size() > 0){
				CoviMap attParams = null;
				for(Object obj : attendantArr){
					CoviMap attendantObj = (CoviMap) obj;
					
					// 참석변경 알림
					attParams = new CoviMap();
					String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
							+ "&eventID=" + eventID
							+ "&dateID=" + dateID
							+ "&isRepeat=" + "N"
							+ "&folderID=" + eventObj.getString("FolderID");
					
					String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
							+ "&isrepeat=" + "N" + "&folderid=" + eventObj.getString("FolderID");
					
					attParams.put("SenderCode", eventObj.getString("RegisterCode"));
					attParams.put("RegisterCode", eventObj.getString("RegisterCode"));
					attParams.put("ReceiversCode", attendantObj.getString("UserCode"));
					attParams.put("MessagingSubject", eventObj.getString("Subject"));
					attParams.put("ReceiverText", eventObj.getString("Subject"));
					attParams.put("ServiceType", "Schedule");
					attParams.put("GotoURL", alarmUrl);
					attParams.put("PopupURL", alarmUrl);
					attParams.put("MobileURL", mobileAlarmUrl);
					attParams.put("MsgType", "ScheduleAttChange");
					
					eventSvc.sendNotificationMessage(attParams);
				}
			}*/
		}

		
		
		
		//TODO 미리알림 변경 필요
		
		
		returnObj.put("status", "SUCCESS");
		
		return returnObj;
	}

	@Override
	public CoviList selectACLData(CoviMap params) throws Exception {
		//if(params.getString("FolderIDs") != null && !params.getString("FolderIDs").equalsIgnoreCase("")){
			CoviList list = coviMapperOne.list("user.schedule.selectACLData", params);
			
			return CoviSelectSet.coviSelectJSON(list, "type,FolderID,FolderType,MultiDisplayName,Color");	
		//}else{
		//	return new CoviList();
		//}
	}

	// 자주 쓰는 일정 등록 (EventID로)
	@Override
	public void insertTemplateByEventID(CoviMap params) throws Exception {
		String oldEventID = params.getString("EventID");
		
		// Event
		insertTempEvent(params);
		
		params.put("oldEventID", oldEventID);
		
		// Date
		String dateID = insertTempEventDate(params);
		
		params.put("DateID", dateID);
		
		// Attendant
		insertSelectEventAttendant(params);
		
		// Resource
		insertSelectEventRelation(params);
		insertTempEventResourceBooking(params);
		
		// Notification
		// 자주 쓰는 일정으로 등록 시 알림 초기화
		CoviMap notiParam = new CoviMap();
		notiParam.put("EventID", params.get("EventID"));
		notiParam.put("DateID", params.get("DateID"));
		notiParam.put("RegisterCode", params.get("UserCode"));
		notiParam.put("RegisterKind", "R");
		notiParam.put("IsNotification", "N");
		notiParam.put("IsReminder", "N");
		notiParam.put("ReminderTime", "10");
		notiParam.put("IsCommentNotification", "N");
		notiParam.put("MediumKind", "");
		eventSvc.insertEventNotification(notiParam);
	}

	@Override
	public String insertTempEvent(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertTempEvent", params);
		
		return params.getString("EventID");
	}

	@Override
	public String insertTempEventDate(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertTempEventDate", params);
		
		return params.getString("DateID");
	}

	@Override
	public void insertSelectEventAttendant(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertSelectEventAttendant", params);
	}

	@Override
	public void insertSelectEventRelation(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertSelectEventRelation", params);
	}
	
	@Override
	public void insertTempEventResourceBooking(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertTempEventResourceBooking", params);
	}
	
	@Override
	public void insertSelectEventNotification(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertSelectEventNotification", params);
	}

	@Override
	public void insertSelectEventNotificationA(CoviMap params) throws Exception{
		coviMapperOne.insert("user.schedule.insertSelectEventNotificationA", params);
	}
	
	@Override
	public void updateShareMine(CoviMap params) throws Exception {
		params = ComUtils.TransServerTimeCoviMapDate(params, "");
		params.put("StartDate", params.getString("StartDateTime"));
		params.put("EndDate", params.getString("EndDateTime"));
		coviMapperOne.update("user.schedule.updateShareMine", params);
	}

	@Override
	public void deleteShareMine(CoviMap params) throws Exception {
		coviMapperOne.delete("user.schedule.deleteShareMine", params);
	}

	@Override
	public CoviMap insertEventByTemplateDragDrop(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		params.put("oldEventID", params.getString("EventID"));
		
		CoviMap oldEventInfo = eventSvc.selectEvent(params);
		
		CoviList eventResObj = eventSvc.selectEventResource(params);
		
		String startDate = params.getString("StartDate");
		String startTime = params.getString("StartTime");
		
		String endDate = params.getString("EndDate");
		String endTime = params.getString("EndTime");
		
		
		
		if(eventResObj.size() > 0){
			
			CoviMap eventDateObj = new CoviMap();
			eventDateObj.put("StartDate", startDate);
			eventDateObj.put("StartTime", startTime);
			eventDateObj.put("EndDate", endDate);
			eventDateObj.put("EndTime", endTime);
			
			for(Object obj : eventResObj){
				CoviMap resourceObj = (CoviMap)obj;
				String resourceID = resourceObj.getString("FolderID");
				
				CoviMap paramRes = new CoviMap();
				paramRes.put("DateID", params.getString("DateID"));
				paramRes.put("EventID", params.getString("EventID"));
				paramRes.put("ResourceID", ((CoviMap)obj).getString("FolderID"));
				
				// 중복체크
				CoviMap checkObj = resourceSvc.checkDuplicateTime(resourceID, eventDateObj);
				
				if(checkObj.getString("IsDuplication").equals("1")) {
					checkObj.put("status", "DUPLICATION");
					checkObj.put("Message",  DicHelper.getDic("msg_ReservationWrite_06") + startDate + " " + startTime + "~" + endDate + " " + endTime);
					return checkObj;
				}
			}
		}
		
		
		
		// Event
		String newEventID = insertEventByTemp(params);
		
		// Repeat
		params.put("EventID", newEventID);
		params.put("AppointmentStartTime", params.getString("StartTime"));
		params.put("AppointmentEndTime", params.getString("EndTime"));
		params.put("RepeatType", "");
		params.put("RepeatStartDate", params.getString("StartDate"));
		params.put("RepeatEndType", "");
		params.put("RepeatEndDate", params.getString("EndDate"));
		
		String RepeatID= eventSvc.insertEventRepeat(params);
		params.put("RepeatID", RepeatID);
		
		// Date
		String dateID = insertEventDateByTemp(params);
		
		params.put("DateID", dateID);
		
		// Attendant
		insertSelectEventAttendant(params);
		
		// Resource
		insertSelectEventRelation(params);
		insertEventResourceBookingByTemp(params);
		
		if(eventResObj.size() > 0){
			for(Object obj : eventResObj){
				CoviMap resourceObj = (CoviMap) obj;
				
				String bookingState = "ApprovalRequest";
				CoviMap paramsResNoti = new CoviMap();
				paramsResNoti.put("FolderID", resourceObj.getString("FolderID")); 
				
				CoviMap resourceDataObj = eventSvc.selectResourceData(paramsResNoti);
				
				if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
					bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
				}
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", oldEventInfo.getString("Subject"));
				notiParam.put("EventID", params.getString("EventID"));
				notiParam.put("DateID", params.getString("DateID"));
				notiParam.put("RepeatID", params.getString("RepeatID"));
				notiParam.put("IsRepeat", "N");	// 반복일정은 DrogNDrop으로 수정 불가
				notiParam.put("ResourceID", resourceObj.getString("FolderID"));
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
					notiParam.put("SenderCode", oldEventInfo.getString("RegisterCode"));
					notiParam.put("ReceiversCode", oldEventInfo.getString("RegisterCode"));
					resourceSvc.sendMessage(notiParam, "BookingComplete");
				}else{ //담당자 승인일 경우 승인요청 알림 보내기
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceObj.getString("FolderID"));
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode" , oldEventInfo.getString("RegisterCode"));
					notiParam.put("ReceiversCode", managerCode);
					resourceSvc.sendMessage(notiParam, "ApprovalRequest");
				}
				
			}
		}
		
		
		// Notification: 등록자
		params.put("RegisterCode", params.get("UserCode"));
		insertSelectEventNotification(params);
		
		String isRepeat = "N";											// Template 은 일정데이터를 저장하지 않으므로
		
		CoviMap registerParams = new CoviMap();
		registerParams.put("EventID", params.getString("EventID"));
		registerParams.put("RegisterCode", params.get("UserCode"));
		CoviMap notificationObj = eventSvc.selectNotificationByOne(registerParams);
		
		// Notification : 참석자
		/*CoviMap delParams = new CoviMap();
		delParams.put("EventID", newEventID);
		deleteEventNotificationA(delParams);*/							// 참석자 알림 정보삭제
		
		/*CoviMap attendantParams = new CoviMap();
		attendantParams.put("newEventID", newEventID);
		attendantParams.put("oldEventID", params.getString("oldEventID"));
		attendantParams.put("IsNotification", notificationObj.getString("IsNotification"));
		attendantParams.put("IsReminder", notificationObj.getString("IsReminder"));
		attendantParams.put("ReminderTime", notificationObj.getString("ReminderTime"));
		attendantParams.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
		attendantParams.put("MediumKind", notificationObj.getString("MediumKind"));
		insertSelectEventNotificationA(attendantParams);*/				// 참석자 알림 정보추가 (설정은 등록자 기준)
		
		// Alarm
		if(notificationObj.getString("IsNotification").equalsIgnoreCase("Y") && notificationObj.getString("IsReminder").equalsIgnoreCase("Y")) {
			CoviMap eventParams = new CoviMap();
			eventParams.put("EventID", newEventID);
			
			CoviMap eventObj = eventSvc.selectEvent(eventParams);
			CoviList attendantArr = selectAttendee(eventParams);
			
			// 등록자 : 미리알림
			CoviMap alarmParams = new CoviMap();
			alarmParams.put("dateID", dateID);
			alarmParams.put("eventID", newEventID);
			alarmParams.put("notificationObj", notificationObj);
			alarmParams.put("RegisterCode", eventObj.getString("RegisterCode"));
			alarmParams.put("Subject", eventObj.getString("Subject"));
			alarmParams.put("IsRepeat", isRepeat);
			alarmParams.put("FolderID", eventObj.getString("FolderID"));
			alarmParams.put("startDate", startDate);
			alarmParams.put("startTime", startTime);
			sendReminderAlarm(alarmParams);
			
			for(Object attObj : attendantArr){
				CoviMap attendantObj = (CoviMap) attObj;
				
				if(!eventObj.getString("RegisterCode").equals(attendantObj.getString("UserCode"))){
					
					// 참석자 : 미리알림
					/*alarmParams = new CoviMap();
					alarmParams.put("dateID", dateID);
					alarmParams.put("eventID", newEventID);
					alarmParams.put("notificationObj", notificationObj);
					alarmParams.put("RegisterCode", attendantObj.getString("UserCode"));
					alarmParams.put("Subject", eventObj.getString("Subject"));
					alarmParams.put("IsRepeat", isRepeat);
					alarmParams.put("FolderID", eventObj.getString("FolderID"));
					alarmParams.put("startDate", startDate);
					alarmParams.put("startTime", startTime);
					sendReminderAlarm(alarmParams);*/
					
					// 참석자 : 참석요청 알림 발송
					CoviMap notiParams = new CoviMap();
					String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
							+ "&eventID=" + newEventID
							+ "&dateID=" + dateID
							+ "&isRepeat=" + isRepeat
							+ "&folderID=" + eventObj.getString("FolderID")
							+ "&isAttendee=Y";
					
					String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + newEventID + "&dateid=" + dateID + "&isrepeat=" + isRepeat + "&folderid=" +  eventObj.getString("FolderID");
					
					notiParams.put("SenderCode", eventObj.getString("RegisterCode"));
					notiParams.put("RegisterCode", eventObj.getString("RegisterCode"));
					notiParams.put("ReceiversCode", attendantObj.getString("UserCode"));
					notiParams.put("MessagingSubject", eventObj.getString("Subject"));
					notiParams.put("ReceiverText", eventObj.getString("Subject"));
					notiParams.put("ServiceType", "Schedule");
					notiParams.put("MsgType", "ScheduleAttendance");
					notiParams.put("GotoURL", alarmUrl);
					notiParams.put("PopupURL", alarmUrl);
					notiParams.put("MobileURL", mobileAlarmUrl);
					
					eventSvc.sendNotificationMessage(notiParams);
				}
			}
		}
		
		returnObj.put("status", Return.SUCCESS);
		
		return returnObj;
	}

	@Override
	public  String insertEventByTemp(CoviMap params) throws Exception {
		coviMapperOne.insert("user.schedule.insertEventByTemp", params);
		
		return params.getString("EventID");
	}

	@Override
	public String insertEventDateByTemp(CoviMap params) throws Exception {
		coviMapperOne.insert("user.schedule.insertEventDateByTemp", params);
		
		return params.getString("DateID");
	}

	@Override
	public void insertEventResourceBookingByTemp(CoviMap params) throws Exception {
		coviMapperOne.insert("user.schedule.insertEventResourceBookingByTemp", params);
	}

	@Override
	public CoviMap selectGoogleInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.schedule.selectGoogleInfo", params);
		CoviMap returnObj = CoviSelectSet.coviSelectJSON(map, "UserCode,Mail").getJSONObject(0);
		
		if(!returnObj.isEmpty()){
			returnObj.put("isConnect", true);
		}else{
			returnObj.put("isConnect", false);
		}
		
		return returnObj;
	}

	// 참석자의 Notification 테이블 데이터 삭제
	@Override
	public void deleteEventNotificationA(CoviMap params) throws Exception {
		coviMapperOne.delete("user.schedule.deleteEventNotificationA", params);
	}
	
	@Override
	public CoviList selectSubscriptionFolderList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectSubscriptionFolderList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,MultiDisplayName,Color");
	}

	@Override
	public CoviList selectMyInfoProfileScheduleData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectMyInfoProfileScheduleData", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,EventID,LinkEventID,Subject,Place,ImportanceState,OwnerCode,DateID,StartDate,StartTime,EndDate,EndTime,IsAllDay,IsRepeat,Color,OneMore,IsShare,RegisterCode,MultiRegisterName,StartDateTime,EndDateTime");
	}

	@Override
	public CoviList selectMyScheduleData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectMyScheduleData", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,EventID,LinkEventID,Subject,Place,ImportanceState,OwnerCode,DateID,StartDate,StartTime,EndDate,EndTime,IsAllDay,IsRepeat,Color,OneMore,IsShare,RegisterCode,MultiRegisterName,StartDateTime,EndDateTime");
	}

	@Override
	public CoviList selectLeftCalendarEvent(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.schedule.selectLeftCalendarEvent", params);
		
		return CoviSelectSet.coviSelectJSON(list, "StartEndDate,EventIDs,StartDateTime,EndDateTime");
	}
	
	// 웹파트 일정 데이터 조회
	@Override
	public CoviMap getWebpartScheduleList(CoviMap params) throws Exception {
		CoviList list = null; 
			
		list = coviMapperOne.list("webpart.schedule.getSchedule", params);
				
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,FolderName,EventID,Subject,ImportanceState,RegisterCode,MultiRegisterName,DateID,StartDateTime,StartDate,StartTime,EndDateTime,EndDate,EndTime,IsRepeat,RepeatID"));
		
		return resultList;
	}
	
	// 반복예약에서 개별일정 삭제
	@Override
	public void deleteEventRepeatByDate(CoviMap params) throws Exception{
		eventSvc.deleteEventDateByDateID(params);
		
		// 알림 설정 삭제
		eventSvc.deleteEventNotification(params);
		
		//일정 미리 알림 삭제
		params.put("SearchType", "LIKE");
		params.put("ServiceType", "Schedule");
		params.put("ObjectType", "reminder_%"); 
		params.put("ObjectID", params.getString("DateID"));
		eventSvc.updateMessagingCancelState(params);
		
		// 참석자 반복일정 개별일정 삭제 알림
		
	}
	
	@Override
	public  CoviList selectEventNotificationList(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("user.schedule.selectEventNotificationAll", params);
		
		return CoviSelectSet.coviSelectJSON(list, "IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind,UserCode");
	}

	@Override
	public void updateEachNotification(CoviMap params) throws Exception {
		String[] dateIDs = null;
		String dateID = params.getString("DateID");
		
		if(dateID != null && !dateID.equalsIgnoreCase("undefined") && !dateID.equals("")){
			dateIDs = new String[]{dateID};
		}else{
			dateIDs = eventSvc.getDateIDs(params.getString("EventID"));
		}
		
		//기존 알림 데이터 취소처리
		if( params.getString("UpdateType").equalsIgnoreCase("ALL") || params.getString("UpdateType").equalsIgnoreCase("REMINDER") ){
			
			for(int i = 0; i<dateIDs.length; i++){
				CoviMap delParams = new CoviMap();
				delParams.put("SearchType", "EQ");
				delParams.put("ServiceType", "Schedule");
				delParams.put("ObjectType", "reminder_"+params.getString("RegisterCode"));			// 참석자까지 모두 삭제
				delParams.put("ObjectID", dateIDs[i]);
				eventSvc.updateMessagingCancelState(delParams);
				
				delParams.put("ServiceType", "Resource");															// 자원 미리 알림도 삭제 
				eventSvc.updateMessagingCancelState(delParams);
			}
		}
	
		
		// 미리 알림 재등록
		if( 	(params.getString("UpdateType").equalsIgnoreCase("REMINDER") && params.getString("IsReminder").equalsIgnoreCase("Y") )
			|| (params.getString("UpdateType").equalsIgnoreCase("ALL") && params.getString("IsNotification").equalsIgnoreCase("Y") && params.getString("IsReminder").equalsIgnoreCase("Y") )	){
			
			for(int i = 0; i<dateIDs.length; i++){
				CoviMap dateParam = new CoviMap();
				dateParam.put("DateID", dateIDs[i]);
				CoviMap dateObj = eventSvc.selectEventDate(dateParam);
				
				if(params.getString("FolderType").equalsIgnoreCase("RESOURCE")){
					CoviMap resourceParam = new CoviMap();
					resourceParam.put("dateID", dateIDs[i]);
					resourceParam.put("eventID", params.getString("EventID"));
					resourceParam.put("repeatID", dateObj.getString("RepeatID"));
					resourceParam.put("notificationObj",  CoviSelectSet.coviSelectJSON(params, "EventID,RegisterCode,IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind").getJSONObject(0));
					resourceParam.put("RegisterCode",  params.getString("RegisterCode"));
					resourceParam.put("Subject",  params.getString("Subject"));
					resourceParam.put("IsRepeat", dateObj.getString("IsRepeat"));
					resourceParam.put("FolderID", params.getString("FolderID"));
					resourceParam.put("startDate", dateObj.getString("StartDate"));
					resourceParam.put("startTime", dateObj.getString("StartTime"));
					
					sendResourceReminderAlarm(resourceParam);
				}else{
					 
					CoviMap mesParm = new CoviMap();
					mesParm.put("dateID", dateIDs[i]);
					mesParm.put("eventID", params.getString("EventID"));
					mesParm.put("notificationObj", CoviSelectSet.coviSelectJSON(params, "EventID,RegisterCode,IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind").getJSONObject(0));
					mesParm.put("RegisterCode", params.getString("RegisterCode"));
					mesParm.put("Subject", params.getString("Subject"));
					mesParm.put("IsRepeat", dateObj.getString("IsRepeat"));
					mesParm.put("FolderID", params.getString("FolderID"));
					mesParm.put("startDate", dateObj.getString("StartDate"));
					mesParm.put("startTime", dateObj.getString("StartTime"));
					
					sendReminderAlarm(mesParm);
					/*
					CoviList resourceArr = eventSvc.selectResourceList(params);
					
					for(Object obj_2 : resourceArr){  //자원이 있을 경우 자원 미리알림 (자원예약의 알람 대상은 등록자만 존재)
						CoviMap resourceObj = (CoviMap) obj_2;
					
						CoviMap resourceParam = new CoviMap();
						resourceParam.put("dateID", dateIDs[i]);
						resourceParam.put("eventID", params.getString("EventID"));
						resourceParam.put("repeatID", dateObj.getString("RepeatID"));
						resourceParam.put("notificationObj",  CoviSelectSet.coviSelectJSON(params, "EventID,RegisterCode,IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind").getJSONObject(0));
						resourceParam.put("RegisterCode",  params.getString("RegisterCode"));
						resourceParam.put("Subject",  params.getString("Subject"));
						resourceParam.put("IsRepeat", dateObj.getString("IsRepeat"));
						resourceParam.put("FolderID", resourceObj.getString("FolderID"));
						resourceParam.put("startDate", dateObj.getString("StartDate"));
						resourceParam.put("startTime", dateObj.getString("StartTime"));
						
						sendResourceReminderAlarm(resourceParam);
					}
					*/
				}
		
			}
		}
		
		// event_notification table update
		eventSvc.updateEventNotification(params);
	}
	
	// 미리 알림 보내기
	private void sendReminderAlarm(CoviMap params) throws Exception{
		CoviMap notificationObj = CoviMap.fromObject(params.getString("notificationObj"));
		
		String startDate = params.getString("startDate");
		String startTime = params.getString("startTime");
		
		int remiderTime = notificationObj.getInt("ReminderTime");
		
		String reservedDate = ComUtils.TransServerTime(DateHelper.getAddDate(startDate + " " + startTime, "yyyy-MM-dd HH:mm", (-1*remiderTime), Calendar.MINUTE), "yyyy-MM-dd HH:mm");
		
		if(DateHelper.diffMinute(reservedDate, ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm"),"yyyy-MM-dd HH:mm")) >=0){ //발송 시간이 지나지 않은 항목만 발송
			String dateID = params.getString("dateID");
			String eventID = params.getString("eventID");
			String registerCode = params.getString("RegisterCode");
			String subject = params.getString("Subject");
			String isRepeat = params.getString("IsRepeat");
			String folderID = params.getString("FolderID");
			
			if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){
				CoviMap notiParams = new CoviMap();
				String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+ "&eventID=" + eventID + "&dateID=" + dateID + "&isRepeat=" + isRepeat + "&folderID=" + folderID;
				
				String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID + "&isrepeat=" +isRepeat + "&folderid=" + folderID;
				
				String sReceiveText = "§lbl_Schedule§ : " +  subject + "&lt;br&gt;";
				sReceiveText += "§lbl_date§ : " + startDate + " " + startTime;
				
				notiParams.put("ObjectType", "reminder_"+registerCode);
				notiParams.put("ObjectID", dateID);
				notiParams.put("SenderCode", registerCode);
				notiParams.put("RegisterCode", registerCode);
				notiParams.put("ReceiversCode", registerCode);
				notiParams.put("MessagingSubject", subject);
				notiParams.put("ReceiverText", subject);
				notiParams.put("ServiceType", "Schedule");
				notiParams.put("MsgType", "ScheduleReminder");
				notiParams.put("IsDelay", "Y");
				notiParams.put("ReservedDate", reservedDate);
				notiParams.put("GotoURL", alarmUrl);
				notiParams.put("PopupURL", alarmUrl);
				notiParams.put("MobileURL", mobileAlarmUrl);
				notiParams.put("MessageContext", sReceiveText);
				
				CoviMap dicMap = new CoviMap();
				CoviMap dicParams = new CoviMap();
				String[] dicArr = {"lbl_date", "lbl_Schedule"};
				dicParams.put("dicArr", dicArr);
				
				dicMap = messageSvc.getDicInfo(dicParams);
				notiParams.put("ReservedStr4", CoviMap.toJSONString(dicMap));
				
				eventSvc.sendNotificationMessage(notiParams);
			}
		}
		
	}

	// 자원미리 알림 보내기
	private void sendResourceReminderAlarm(CoviMap params) throws Exception{
		//DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm"))
		CoviMap notificationObj = CoviMap.fromObject(params.getString("notificationObj"));
		String startDate = params.getString("startDate");
		String startTime = params.getString("startTime");
		
		int remiderTime = notificationObj.getInt("ReminderTime");
		
		String reservedDate = ComUtils.TransServerTime(DateHelper.getAddDate(startDate + " " + startTime, "yyyy-MM-dd HH:mm", (-1*remiderTime), Calendar.MINUTE),"yyyy-MM-dd HH:mm");
				
		if(DateHelper.diffMinute(reservedDate, ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm"),"yyyy-MM-dd HH:mm")) >=0){ //발송 시간이 지나지 않은 항목만 발송
			String dateID = params.getString("dateID");
			String eventID = params.getString("eventID");
			String repeatID = params.getString("repeatID");
			String registerCode = params.getString("RegisterCode");
			String subject = params.getString("Subject");
			String isRepeat = params.getString("IsRepeat");
			String folderID = params.getString("FolderID");
			
			if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){
				CoviMap notiParams = new CoviMap();
				
				String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
						+ "&eventID=" + eventID + "&dateID=" + dateID + "&repeatID=" + repeatID + "&isRepeat=" + isRepeat + "&resourceID=" + folderID;
				
				String mobileAlarmUrl = "/groupware/mobile/resource/view.do?" + "?eventid=" + eventID + "&dateid=" + dateID + "&repeatid=" + repeatID + "&isrepeat=" + isRepeat + "&resourceid=" + folderID;
				


				
				notiParams.put("ObjectType", "reminder_"+registerCode);
				notiParams.put("ObjectID", dateID);
				notiParams.put("SenderCode", registerCode);
				notiParams.put("RegisterCode", registerCode);
				notiParams.put("ReceiversCode", registerCode);
				notiParams.put("MessagingSubject", subject);
				notiParams.put("ReceiverText", subject);
				notiParams.put("ServiceType", "Resource");
				notiParams.put("MsgType", "ResourceReminder");
				notiParams.put("IsDelay", "Y");
				notiParams.put("ReservedDate", reservedDate);
				notiParams.put("GotoURL", alarmUrl);
				notiParams.put("PopupURL", alarmUrl);
				notiParams.put("MobileURL", mobileAlarmUrl);
				
				eventSvc.sendNotificationMessage(notiParams);
			}
		}
	}
	
	// 상세일정등록시 파일첨부에 사용
	public void insertScheduleSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		String uploadPath = params.getString("ServiceType") + File.separator;
		String orgPath = params.getString("ServiceType") + File.separator;

		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath, params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
	}
	
	// 일정수정시 파일정보 수정
	public void updateScheduleSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		// 파일을 모두 삭제후 수정누를 경우 삭제처리
		if("0".equals(params.get("fileCnt"))){
			fileSvc.deleteFileDbAll(params);
		} else {
			String uploadPath = params.getString("ServiceType") + File.separator;
			CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
			
			CoviMap filesParams = new CoviMap();
			CoviList fileObj = fileSvc.uploadToBack(fileInfos, mf, uploadPath , params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
		}
	}
	
	@Override
	public CoviMap selectSchUserFolderSetting(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.schedule.selectSchUserFolderSetting", params);
		CoviMap returnObj = CoviSelectSet.coviSelectJSON(map, "UserCode,FolderID").getJSONObject(0);
		
		if(!returnObj.isEmpty()){
			returnObj.put("isSchUserFDExist", true);
			returnObj.put("schUserFD", returnObj.getString("FolderID"));
		}else{
			returnObj.put("isSchUserFDExist", false);
			returnObj.put("schUserFD", "");
		}
		
		return returnObj;
	}

	// 일정 추가
	@Override
	public CoviMap saveSchUserFolderSetting(CoviMap params) throws Exception {
		
		int iCnt = 0;
		CoviMap dateChkObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", DicHelper.getDic("msg_FailProcess")); // 처리에 실패했습니다.
		
		
		dateChkObj = selectSchUserFolderSetting(params);
		
		if(dateChkObj.get("isSchUserFDExist") != null && (boolean) dateChkObj.get("isSchUserFDExist")) {
			iCnt = coviMapperOne.update("user.schedule.updateSchUserFolder", params);
		} else {
			iCnt = coviMapperOne.insert("user.schedule.insertSchUserFolder", params);
		}
		
		if(iCnt > 0) {
			returnObj.put("retMsg", DicHelper.getDic("msg_117")); // 성공적으로 저장하였습니다.
		}
		
		return returnObj;
	}
	
	@Override
	public String getScheduleDateID(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.schedule.selectScheduleDateID", params);
	}
	
	private CoviMap saveSchedule(String pOperationType, CoviMap pDataObj, CoviMap pFileObj, List<MultipartFile> pMultipartFileData, CoviMap pReturnObj) throws Exception {
		
		CoviMap changes = pDataObj.getJSONObject("changes");	// 변경 내역
		CoviMap changeEvent = changes.getJSONObject("event");	// 일정 변경 내역
		CoviMap changeDate = changes.getJSONObject("date");		// 일시 변경 내역
		CoviMap changeRepeat = changes.getJSONObject("repeat");	// 반복 변경 내역
		CoviMap changeResource = changes.getJSONObject("resource");	// 자원 변경 내역
		CoviMap changeAttendee = changes.getJSONObject("attendee");	// 참석자 변경 내역
		CoviMap changeNotification = changes.getJSONObject("notification");	// 참석자 변경 내역
		
		CoviMap event = pDataObj.getJSONObject("Event");		// 일정 데이터
		CoviMap	eventDate = pDataObj.getJSONObject("Date");	// 일시 데이터
		CoviMap repeat = pDataObj.getJSONObject("Repeat");	// 반복 데이터
		CoviList resources = pDataObj.getJSONArray("Resource");	// 자원 데이터
		CoviList attendant = pDataObj.getJSONArray("Attendee");	// 참석자 데이터

		String eventID = ("F".equalsIgnoreCase(pDataObj.getString("EventType"))) ? "" : pDataObj.getString("EventID");		// 일정ID
		String repeatID = pDataObj.getString("RepeatID");	// 반복ID
		
		String changeTypes = "";   // 수정된 항목을 미리알림에 전달하기 위한 변수
		
		if ("".equals(eventID)) {		// 요청 파라미터에 eventID가 없으면 이벤트 정보로 ID 조회
			eventID = eventSvc.insertEvent(event);
			pDataObj.put("EventID", eventID);
		}
		
		if ("true".equalsIgnoreCase(changeEvent.getString("changed"))) {	// 일정이 변경된 경우 일정 업데이트
			updateEventData(event, eventID);
		}
		
		CoviList oldDateIDs  = new CoviList(Arrays.asList(eventSvc.getDateIDs(eventID)));
		
		if (repeat.size() > 0) {
			Iterator repeatIter = repeat.values().iterator();
			while(repeatIter.hasNext()) {
				Object repeatItem = repeatIter.next();
				if ("".equals(repeatItem)) {
					repeatIter.remove();
				}
			}
		}
		
		if ("".equals(repeatID)) {
			repeatID = eventSvc.selectEventDate(pDataObj).getString("RepeatID");
			if ("".equals(repeatID)) {
				if (repeat.size() == 0) {
					repeat.put("AppointmentStartTime", eventDate.getString("StartTime"));
					repeat.put("AppointmentEndTime", eventDate.getString("EndTime"));
					repeat.put("RepeatStartDate", eventDate.getString("StartDate"));
					repeat.put("RepeatEndDate", eventDate.getString("EndDate"));
				}
				
				repeat.put("EventID", eventID);
				
				repeatID = eventSvc.insertEventRepeat(repeat);
			}
		}
		
		boolean isChangedRepeat = false;
		boolean isDeleteDate = false;
		
		if ("true".equalsIgnoreCase(changeRepeat.getString("changed"))) {
			// 반복 정보가 추가되거나 변경된 경우, 기존 일시정보 전부 삭제
			if("del".equalsIgnoreCase(changeRepeat.getString("type"))) {
				eventSvc.deleteEventDateByEventID(pDataObj);
				
				repeat.put("EventID", eventID);
				repeat.put("AppointmentStartTime", eventDate.getString("StartTime"));
				repeat.put("AppointmentEndTime", eventDate.getString("EndTime"));
				repeat.put("RepeatStartDate", eventDate.getString("StartDate"));
				repeat.put("RepeatEndDate", eventDate.getString("EndDate"));
				
				isDeleteDate = true;

			} else if ("add".equalsIgnoreCase(changeRepeat.getString("type")) || "modify".equalsIgnoreCase(changeRepeat.getString("type"))) {
				eventSvc.deleteEventDateByEventID(pDataObj);
				isChangedRepeat = true;
				isDeleteDate = true;
			}
			
			if(!"add".equalsIgnoreCase(changeRepeat.getString("type")) || "update".equalsIgnoreCase(pOperationType)) {
				repeat.put("RepeatID", repeatID);
				eventSvc.updateEventRepeat(repeat);	// 반복 정보 갱신
			}
		}
		
		if (!isDeleteDate && ("true".equalsIgnoreCase(changeDate.getString("changed")) || "true".equalsIgnoreCase(changeResource.getString("changed")))) {
			// 일시정보가 변경되면 기존 일시정보를 삭제하고, 반복정보를 갱신한 후 신규 일시정보를 생성한다.
			eventSvc.deleteEventDateByEventID(pDataObj);
			
			CoviMap tempRepeat = new CoviMap(eventDate);
			tempRepeat.put("RepeatID", repeatID);
			eventSvc.updateEventRepeatDate(tempRepeat);
			
			if ("true".equalsIgnoreCase(changeDate.getString("changed")) && changeTypes.indexOf("Date") == -1) {
				changeTypes += "Date;";
			}
			if ("true".equalsIgnoreCase(changeResource.getString("changed")) && changeTypes.indexOf("Resource") == -1) {
				changeTypes += "Resource;";
			}
			
			isDeleteDate = true;
		}

		CoviList dateList = new CoviList();
		String isRepeat = pDataObj.getString("IsRepeat");
		repeat.put("IsRepeat", isRepeat);
		
		if (isChangedRepeat) {	// 반복이 변경된 경우, 반복조건에 따라 일시정보를 생성하여 배열에 저장
			dateList = eventSvc.setEventRepeatDate(repeat);
			if (changeTypes.indexOf("Date") == -1) changeTypes += "Date;";
		} else if (isDeleteDate) {	// 일시/자원이 변경되어 일시정보가 재등록된 경우, 배열에 일시정보 저장
			dateList.add(eventDate);
		} else {
			// 아닌 경우 날짜 객체를 배열에 저장
		}
		
		if (isDeleteDate) {		// 반복변경, 날짜 변경에 의해 날짜 정보가 삭제된 경우,
			// 기존 자원 예약 정보를 삭제
			for (int i = 0; i < resources.size(); i++) {
				CoviMap resourceObj = new CoviMap();
				resourceObj.put("EventID", eventID);
				eventSvc.deleteEventRelation(resourceObj);
				eventSvc.deleteEventResourceBooking(resourceObj);
			}
			
			// 알림 설정 및 미리알림 모두 삭제
			CoviMap deleteParam = new CoviMap();
			deleteParam.put("EventID", eventID);
			eventSvc.deleteEventNotification(deleteParam);
			
			CoviMap cancelParam = new CoviMap();
			cancelParam.put("SearchType", "LIKE");
			cancelParam.put("ServiceType", "Schedule");
			cancelParam.put("ObjectType", "reminder_%");
			cancelParam.put("arrObjectID", oldDateIDs);
			eventSvc.updateArrMessagingCancelState(cancelParam);
		}
		
		String dateID = pDataObj.getString("DateID");
		CoviMap notification = pDataObj.getJSONObject("Notification");
		
		for (int i = 0; i < dateList.size(); i++) {		// 날짜 수만큼 데이터 반복 처리
			CoviMap date = dateList.getMap(i);
			
			// 자원이 있는 경우, 해당 시간대의 자원에 중복이 있는지 확인
			if (resources.size() > 0) {
				for (int j = 0; j < resources.size(); j++) {
					CoviMap resourceObj = resources.getMap(j);
					if ( "".equals(date.getString("StartTime"))) date.put("StartTime", repeat.getString("AppointmentStartTime"));
					if ( "".equals(date.getString("EndTime"))) date.put("EndTime", repeat.getString("AppointmentEndTime"));
					if (checkResourceDuplication(resourceObj, date)) {
						throw new ResourceDuplicationException(DicHelper.getDic("msg_ReservationWrite_06") + date.getString("StartDate") + " " + date.getString("StartTime") + "~" + date.getString("EndDate") + " " + date.getString("EndTime"));
					}
				}
			}
			
			if (dateList.size() > 1) {		// 날짜가 1개 이상인 경우, 반복조건을 이용
				String IsAllDay = ("00:00".equals(repeat.getString("AppointmentStartTime")) && "23:59".equals(repeat.getString("AppointmentEndTime"))) ? "Y" : "N";
				date.put("StartTime", repeat.getString("AppointmentStartTime"));
				date.put("StartDateTime", eventDate.getString("StartDate") + " " + repeat.getString("AppointmentStartTime"));
				date.put("EndTime", repeat.getString("AppointmentEndTime"));
				date.put("EndDateTime", eventDate.getString("EndDate") + " " + repeat.getString("AppointmentEndTime"));
				date.put("IsAllDay", IsAllDay);
				date.put("IsRepeat", repeat.getString("IsRepeat"));
				dateID = insertDateData(date, eventID, repeatID);
				date.put("DateID", dateID);
			} else {
				// 반복조건이 Y인 경우, 반복조건을 이용
				if ("Y".equals(isRepeat)) {
					String IsAllDay = ("00:00".equals(repeat.getString("AppointmentStartTime")) && "23:59".equals(repeat.getString("AppointmentEndTime"))) ? "Y" : "N";
					date.put("StartTime", repeat.getString("AppointmentStartTime"));
					date.put("EndTime", repeat.getString("AppointmentEndTime"));
					date.put("IsAllDay", IsAllDay);
					date.put("IsRepeat", isRepeat);
				}
				dateID = insertDateData(dateList.getMap(0), eventID, repeatID);
				date.put("DateID", dateID);
			}
			
			if (resources.size() > 0) {	// 자원 목록이 있는 경우, 예약정보를 생성함.
				for (int j = 0; j < resources.size(); j++) {
					CoviMap resourceObj = resources.getMap(j);
					
					insertResourceData(resourceObj, eventID, dateID);
				}
			}
			
			// 미리알림 설정 일시별 저장
			insertNovificationData(notification, eventID, dateID);
		}
		
		if ("true".equalsIgnoreCase(changeNotification.getString("changed")) && dateList.size() == 0) {	// 일정 변경이 없고 알림 설정이 변경되면 알림정보 업데이트
			updateNovificationData(notification, eventID, dateID);
		}
		
		// 참석자 정보가 변경된 경우, 참석자 변경
		if ("true".equalsIgnoreCase(changeAttendee.getString("changed"))) {
			updateAttendantData(pDataObj.getJSONArray("Attendee"), eventID);
		}
		
		// 파일이 있는 경우 파일 처리
		if(pFileObj != null) {
			pFileObj.put("MessageID", eventID);
			pFileObj.put("ObjectID", event.getString("FolderID"));
			pFileObj.put("ObjectType", "FD");
			updateScheduleSysFile(pFileObj, pMultipartFileData);
		}
		
		// 알림 처리를 위한 데이터 셋팅 및 알림 처리
		event.put("EventID", eventID);
		event.put("IsRepeatAll", (dateList.size() > 1) ? "Y" : "N");
		event.put("strRepeat", pDataObj.getString("strRepeat"));
		eventDate.put("DateID", (dateList.size() > 0) ? dateList.getMap(0).getString("DateID") : dateID);
		
		if (dateList.size() == 0) {
			CoviMap dateParam = new CoviMap();
			dateParam.put("EventID", eventID);
			dateParam.put("DateID", eventDate.getString("DateID"));
			dateList = eventSvc.selectEventDateAll(dateParam);
			for(int i = 0; i < dateList.size(); i++) {
				CoviMap tempDate = dateList.getMap(i);
				String localStartDateTime = ComUtils.TransLocalTime(tempDate.getString("StartDate")+" "+tempDate.getString("StartTime"), ComUtils.ServerDateFormat);
				tempDate.put("StartDate", localStartDateTime.split(" ")[0]);
				tempDate.put("StartTime", localStartDateTime.split(" ")[1]);
				String localEndDateTime = ComUtils.TransLocalTime(tempDate.getString("EndDate")+" "+tempDate.getString("EndTime"), ComUtils.ServerDateFormat);
				tempDate.put("EndDate", localEndDateTime.split(" ")[0]);
				tempDate.put("EndTime", localEndDateTime.split(" ")[1]);
				dateList.set(i,tempDate);
			}
		}
		
		sendNotification(changeTypes, event, eventDate, resources, attendant, notification, dateList);

		return pReturnObj;
	}
	
	// 자원 사용가능여부 체크
	private boolean checkResourceDuplication(CoviMap pResource, CoviMap pDate) throws Exception {
		CoviMap checkObj = resourceSvc.checkDuplicateTime(pResource.getString("FolderID"), pDate);
		return "1".equals(checkObj.getString("IsDuplication"));
	}
	
	// 반복 정보 수정
	private void updateRepeatData(CoviMap pRepeat, String pRepeatID) throws Exception {
		CoviMap params = new CoviMap(pRepeat);
		params.put("RepeatID", pRepeatID);
		eventSvc.updateEventRepeat(params);
	}
	
	// 이벤트 정보 수정
	private void updateEventData(CoviMap pEvent, String pEventID) throws Exception {
		CoviMap params = new CoviMap(pEvent);
		params.put("EventID", pEventID);
		params.put("OwnerCode", SessionHelper.getSession("USERID"));
		params.put("ModifierCode", SessionHelper.getSession("USERID"));
		
		CoviMap linkFolderInfo = coviMapperOne.selectOne("user.schedule.selectLinkFolderInfo", params);
		if (linkFolderInfo != null && !linkFolderInfo.isEmpty()) {
			params.put("FolderID", linkFolderInfo.getString("LinkFolderID"));
			params.put("FolderType", linkFolderInfo.getString("FolderType"));
		}
		
		//Editor 처리
		if(params.containsKey("Description") && !"".equals(params.getString("Description"))) {
		    String description = getEditorContent(params);
		    params.put("Description", description);
		}

		eventSvc.updateEvent(params);
	}
	
	// 일시 정보 등록
	private String insertDateData(CoviMap pDate, String pEventID, String pRepeatID) throws Exception {
		CoviMap params = new CoviMap(pDate);
		params.put("EventID", pEventID);
		params.put("RepeatID", pRepeatID);
		params.put("StartDateTime", pDate.getString("StartDate") + " " + pDate.getString("StartTime"));
		params.put("EndDateTime", pDate.getString("EndDate") + " " + pDate.getString("EndTime"));
		
		String dateID = eventSvc.insertEventDate(params);
		
		return dateID;
	}
	
	// 참석자 정보 수정
	private void updateAttendantData(CoviList pAttendant, String pEventID) throws Exception {
		CoviList attendantArr = new CoviList(pAttendant);
		
		// 기존 참석자 일괄 삭제
		CoviMap params = new CoviMap();
		params.put("EventID", pEventID);
		deleteEventAttendant(params);
		
		for(Object obj : attendantArr){
			CoviMap attendantObj = (CoviMap) obj;
			
			attendantObj.put("EventID", pEventID);
			attendantObj.put("AttenderCode", attendantObj.getString("UserCode"));
			
			/* event_attendant 테이블을 사용하도록 변경 개인일정 삭제할 필요 없음.
			if("del".equals(attendantObj.getString("opType")) && "Y".equals(attendantObj.getString("IsAllow"))){
				// 삭제된 참석자 중에 이미 개인일정으로 추가되었을 경우 삭제
				// 참석자 테이블을 바라보게 변경할 경우, 처리하지 않아도 됨.
				deleteEventByAttendeeData(attendantObj);	
			} else
			*/  
			if(!"del".equals(attendantObj.getString("opType"))){
				attendantObj.put("MultiAttenderName", attendantObj.getString("UserName"));
				attendantObj.put("IsOutsider", attendantObj.getString("IsOutsider"));
				attendantObj.put("IsAllow", attendantObj.getString("IsAllow"));
				
				insertEventAttendant(attendantObj);
			}
		}
	}
	
	// 자원예약 정보 등록
	private void insertResourceData(CoviMap pResource, String pEventID, String pDateID) throws Exception {
		CoviMap params = new CoviMap(pResource);
		if (!"del".equals(pResource.getString("opType"))) {
			params.put("EventID", pEventID);
			params.put("ScheduleID", pEventID);
			params.put("DateID", pDateID);
			params.put("ResourceID", params.getString("FolderID"));
			
			CoviMap resourceDataObj = eventSvc.selectResourceData(params);
			String bookingState = "ApprovalRequest";
			if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
				bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
			}
			params.put("ApprovalDate", null);
			params.put("ApprovalState", bookingState);
			
			eventSvc.insertEventRelation(params);
			eventSvc.insertEventResourceBooking(params);
		}
	}
	
	// 알림 설정 등록
	private void insertNovificationData(CoviMap pNotification, String pEventID, String pDateID) throws Exception {
		CoviMap params = new CoviMap(pNotification);
		params.put("EventID", pEventID);
		params.put("DateID", pDateID);
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("RegisterKind", "R");	// 알림 설정을 참석자들이 변경 가능할 경우, 변경 가능하도록 처리
		eventSvc.insertEventNotification(params);
	}
	
	// 알림 설정 등록
	private void updateNovificationData(CoviMap pNotification, String pEventID, String pDateID) throws Exception {
		CoviMap params = new CoviMap(pNotification);
		params.put("EventID", pEventID);
		params.put("DateID", pDateID);
		params.put("RegisterCode", SessionHelper.getSession("USERID"));
		params.put("RegisterKind", "R");
		eventSvc.updateEventNotification(params);
	}
	
	// 알림 발송
	private void sendNotification(String pChangeTypes, CoviMap pEvent, CoviMap pDate, CoviList pResources, CoviList pAttendant, CoviMap pNotification, CoviList pDateList) throws Exception {
		String isNotification = pNotification.getString("IsNotification");
		String isReminder = pNotification.getString("IsReminder");
		
		for(Object obj : pAttendant){
			CoviMap attendantObj = (CoviMap) obj;
			if("new".equals(attendantObj.getString("opType"))){
				// 추가된 참석자에게 초대메일 발송 (messageType: ScheduleAttendance)
				messageSvc.insertMessagingData(generateNotiParams(pEvent, pDate, pResources, attendantObj.getString("UserCode"),attendantObj.getString("DomainID"), true, "ScheduleAttendance"));
			} else if ("none".equals(attendantObj.getString("opType"))){
				if (pChangeTypes.indexOf("Date") > -1 || pChangeTypes.indexOf("Resource") > -1) {
					// 기존 사용자에게는 변경메일 발송 (messageType: ScheduleChangeAttendance)
					messageSvc.insertMessagingData(generateNotiParams(pEvent, pDate, pResources, attendantObj.getString("UserCode"),attendantObj.getString("DomainID"), true, "ScheduleChangeAttendance"));
				}
				
				// 참석 승인자이고, 알림을 사용하며, 미리알림이 설정되어 있으면, 미리알림 메시지 에약 발송
				if ("Y".equals(attendantObj.getString("IsAllow")) && "Y".equals(isNotification) && "Y".equals(isReminder)){
					insertReminderMessage(pEvent, pResources, attendantObj.getString("UserCode"), pNotification, pDateList, true);
				}
			} else if ("del".equals(attendantObj.getString("opType"))){
				// 삭제된 참석자에게 취소메일 발송 가능
			} 
		}
		
		// 알림을 사용하며, 미리알림이 설정되어 있으면, 작성자에게 미리알림 메시지 에약 발송
		if ("Y".equals(isNotification) && "Y".equals(isReminder)){
			insertReminderMessage(pEvent, pResources, SessionHelper.getSession("UR_Code"), pNotification, pDateList, false);
		}
	}
	
	private String getEditorContent(CoviMap pParams) throws Exception {
		CoviMap editorParam = new CoviMap();
	    editorParam.put("serviceType", "Schedule");  //BizSection
	    editorParam.put("imgInfo", (pParams.containsKey("InlineImage") ? pParams.getString("InlineImage") : "")); 
	    editorParam.put("objectID", pParams.getString("FolderID"));     
	    editorParam.put("objectType", "FD");   
	    editorParam.put("messageID", pParams.getString("EventID"));  
	    editorParam.put("bodyHtml",pParams.getString("Description"));   
		
	    CoviMap editorInfo = editorService.getContent(editorParam); 
	    
        if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
        	throw new Exception("InlineImage move BackStorage Error");
        }
		return editorInfo.getString("BodyHtml");
	}
	
	// 알림 메시지 양식 생성
	@SuppressWarnings("unchecked")
	private CoviMap generateNotiParams(CoviMap pEvent, CoviMap pDate, CoviList pResources, String pReceiversCode, String pDomainID, boolean pIsAttendant, String pMsgType) throws Exception{
		String isRepeat = (!"".equals(pDate.getString("IsRepeat"))) ? pDate.getString("IsRepeat") : pEvent.getString("IsRepeat");
		String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
				+ "&eventID=" + pEvent.getString("EventID")
				+ "&dateID=" + pDate.getString("DateID")
				+ "&isRepeat=" + isRepeat
				+ "&folderID=" + pEvent.getString("FolderID");
		
		String mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + pEvent.getString("EventID") + "&dateid=" + pDate.getString("DateID") 
				+ "&isrepeat=" + isRepeat + "&folderid=" + pEvent.getString("FolderID");
		
		if (pIsAttendant) {
			alarmUrl += "&isAttendee=Y";
			mobileAlarmUrl += "&isattendee=Y";
		}
		
		if ("Y".equals(pEvent.getString("IsRepeatAll"))) {
			alarmUrl += "&isRepeatAll=Y";
			mobileAlarmUrl += "&isrepeatall=Y";
		}
		
		String sReceiverText = "";
		if ("Y".equals(pEvent.getString("IsRepeatAll"))) {
			// 반복 일정의 경우, 반복조건 문자열을 날짜에 표시. 수신자에 맞춰 다국어를 처리할 시, 반복조건을 해석하는 함수를 서버에 구현 필요
			sReceiverText += "&middot; §lbl_date§ : " + pEvent.getString("strRepeat") + "&lt;br&gt;";
		} else {
			sReceiverText += "&middot; §lbl_date§ : " + pDate.getString("StartDate") + " " + pDate.getString("StartTime") + "~" + pDate.getString("EndDate") + " " + pDate.getString("EndTime")+ "&lt;br&gt;";
		}
		
		if (pEvent.get("Place") != null && !"".equals(pEvent.get("Place"))) sReceiverText+= "&middot; §lbl_Place§ : "+pEvent.getString("Place") + "&lt;br&gt;";
		ArrayList<String> dicFolderList = new ArrayList<String>();
		if (pResources.size() != 0) {
			int resourcelength = pResources.size();
			sReceiverText += "&middot; §lbl_Resources§ : ";
			for(Object resourceobj : pResources) {
				CoviMap Arrobj = (CoviMap)resourceobj;
				String resourceID = Arrobj.getString("FolderID");
				sReceiverText += "§FD@@"+resourceID+"§";
				if(resourcelength != 1) {
					sReceiverText += ", ";
					resourcelength--;
				}
				dicFolderList.add("FD@@"+resourceID);
			}
			sReceiverText += "&lt;br&gt;";
		}
		sReceiverText += "&lt;br&gt;" +  pEvent.getString("Description");
		
		CoviMap notiParams = new CoviMap();
		notiParams.put("SenderCode", SessionHelper.getSession("USERID"));
		notiParams.put("RegisterCode", SessionHelper.getSession("USERID"));
		notiParams.put("ReceiversCode", pReceiversCode);
		notiParams.put("MessagingSubject", pEvent.getString("Subject"));
		notiParams.put("ReceiverText", pEvent.getString("Subject"));
		notiParams.put("MessageContext", sReceiverText);
		notiParams.put("ServiceType", "Schedule");
		notiParams.put("MsgType", pMsgType);
		notiParams.put("GotoURL", alarmUrl);
		notiParams.put("PopupURL", alarmUrl);
		notiParams.put("MobileURL", mobileAlarmUrl);
		notiParams.put("IsUse", "Y");
		notiParams.put("IsDelay", "N");
		notiParams.put("ApprovalState", "P");
		notiParams.put("DomainID", pDomainID);
		
		CoviMap dicMap = new CoviMap();
		CoviMap dicParams = new CoviMap();
		String[] dicArr = {"lbl_Place", "lbl_date", "lbl_Resources"};
		dicParams.put("dicArr", dicArr);
		
		dicParams.put("folderArr", dicFolderList.toArray());

		dicMap = messageSvc.getDicInfo(dicParams);
		
		notiParams.put("ReservedStr4", CoviMap.toJSONString(dicMap));
		
		return notiParams;
	}
	
	// 미리알리 메시지 등록
	private void insertReminderMessage(CoviMap pEvent, CoviList pResources, String pReceiversCode, CoviMap pNotification, CoviList pDateList, boolean pIsAttendant) throws Exception {
		int reminderTime = Integer.parseInt(pNotification.getString("ReminderTime"));
		
		for (int i = 0; i < pDateList.size(); i++) {		// 일시 배열 수만큼 데이터 반복 처리
			String startDate = pDateList.getMap(i).getString("StartDate");
			String startTime = pDateList.getMap(i).getString("StartTime");
			String reservedDate = DateHelper.getAddDate(startDate + " " + startTime, "yyyy-MM-dd HH:mm", (-1*reminderTime), Calendar.MINUTE);
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm"), "yyyy-MM-dd HH:mm");
			// 발송 시간이 지나지 않은 항목만 발송
			if(DateHelper.diffMinute(reservedDate, nowTime) >= 0) {
				CoviMap notiParam = generateNotiParams(pEvent, pDateList.getMap(i), pResources, pReceiversCode,SessionHelper.getSession("DN_ID"), pIsAttendant, "ScheduleReminder");
				notiParam.put("ObjectType", "reminder_"+pReceiversCode);
				notiParam.put("ObjectID", pDateList.getMap(i).getString("DateID"));
				notiParam.put("IsDelay", "Y");
				notiParam.put("ReservedDate", reservedDate);
				messageSvc.insertMessagingData(notiParam);
			}
		}
	}
}
