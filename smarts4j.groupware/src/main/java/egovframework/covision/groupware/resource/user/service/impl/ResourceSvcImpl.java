package egovframework.covision.groupware.resource.user.service.impl;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("resourceService")
public class ResourceSvcImpl extends EgovAbstractServiceImpl implements ResourceSvc{

	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
	@Autowired
	private FileUtilService fileSvc;
	// 첨부파일 관련 코드 추가 끝
	
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private ScheduleSvc scheduleSvc;
	
	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private AuthorityService authorityService;
	
	@Autowired
	private MessageService messageSvc;
	
	// thread-safe patch
	//private int loopCnt = 0;
	ThreadLocal<AtomicInteger> loopCnt = new ThreadLocal<AtomicInteger>();
	
	@Override
	public CoviList selectACLData(CoviMap params) throws Exception {
		//if(params.getString("FolderIDs") != null && !params.getString("FolderIDs").equals("")){
			CoviList list = coviMapperOne.list("user.resource.selectACLData", params);
			
			return CoviSelectSet.coviSelectJSON(list, "type,FolderID,FolderType,MultiDisplayName,SecurityLevel");
		//}else{
		//	return new CoviList();
		//}
	}
	
	@Override
	public CoviMap getBookingList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.resource.selectBookingList", params);
		long cnt = coviMapperOne.getNumber("user.resource.selectBookingListCnt", params);
		
		CoviList bookingList =  coviSelectJSONForResourceList(list, "EventID,DateID,FolderID,FolderType,ResourceID,RepeatID,ResourceName,Subject,StartDateTime,EndDateTime,IsRepeat,ApprovalState,ApprovalStateCode,BookingType,ReturnType,ReturnTypeCode,LeastRentalTime,RegisterCode,RegisterName,RegistDate");

		returnObj.put("bookingList",bookingList);
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}

	@Override
	public CoviMap getBookingPeriodList(CoviMap params) throws Exception {
		CoviList bookingListObj = new CoviList();
		CoviList folderListObj = new CoviList();
		CoviMap returnObj = new CoviMap();
		
		CoviMap dayParams = new CoviMap(params);

        dayParams.put("DomainID", SessionHelper.getSession("DN_ID"));
        dayParams.put("isSaaS", isSaaS);
		
		CoviList bookingList = coviMapperOne.list("user.resource.selectBookingPeriodList", dayParams);
		bookingListObj = coviSelectJSONForResourceList(bookingList, "EventID,DateID,FolderID,ResourceID,FolderName,RepeatID,IsRepeat,Subject,StartDate,StartTime,EndDate,EndTime,StartDateTime,EndDateTime,ApprovalState,RegisterCode,RegisterName,IntegratedID");
		
		if(params.getString("mode").equalsIgnoreCase("M")){
			returnObj.put("bookingList", bookingListObj);
		}
		else{
			CoviList folderList = coviMapperOne.list("user.resource.selectResourceListData", dayParams);
			folderListObj = CoviSelectSet.coviSelectJSON(folderList, "FolderID,DisplayName,MultiDisplayName,FolderType,LeastRentalTime,LeastPartRentalTime,BookingType,ParentFolderName,FolderPathName");
			
			CoviList tempFolderList = new CoviList();
			// 폴더에 대한 데이터 바인딩
			for(Object obj1 : folderListObj){
				CoviMap folderObj = (CoviMap)obj1;
				String folderID = folderObj.getString("FolderID");
				CoviList folderSBooking = new CoviList();
				
				for(Object obj2 : bookingListObj){
					CoviMap bookingObj = (CoviMap)obj2;
					String resourceID = bookingObj.getString("IntegratedID"); 	// 공유 자원 ID 포함 조회.
					
					if(folderID.equals(resourceID)){
						folderSBooking.add(bookingObj);
					}
				}
				
				folderObj.put("bookingList", folderSBooking);
				tempFolderList.add(folderObj);
			}
			returnObj.put("folderList", tempFolderList);
		}
		
		return returnObj;
	}
	
	@Override
	public CoviMap getBookingData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		if(params.getString("EventID").isEmpty()) { //1개 이상 데이터 조회 시 
			CoviList bookingData = coviMapperOne.list("user.resource.selectBookingData", params);
			returnObj.put("arrayBookingData", coviSelectJSONForResourceList(bookingData, "EventID,DateID,FolderID,FolderType,ResourceName,ResourceID,RepeatID,IsRepeat,IsAllDay,Subject,Description,StartDateTime,EndDateTime,ApprovalState,ApprovalStateCode,BookingType,BookingTypeCode,ReturnType,ReturnTypeCode,RegisterCode,RegisterPhoto,OwnerCode,RegisterName,LinkScheduleID,UserPositionName,UserDeptName"));
		} else { 
			CoviList bookingList = coviMapperOne.list("user.resource.selectBookingData", params);
			
			// 반복 예약일 경우 여러 건이 조회 되어 처음 조회된 한 건만 가지고옴.
			if(bookingList != null && bookingList.size() > 0) {
				CoviMap bookingData = (CoviMap) bookingList.get(0);
				
				//Attendant
				CoviList attendantObj = selectResEventAttendant(params);
				returnObj.put("bookAtdData", attendantObj);
				returnObj.put("bookingData", coviSelectJSONForResourceList(bookingData, "EventID,DateID,FolderID,FolderType,ResourceName,ResourceID,RepeatID,IsRepeat,IsAllDay,Subject,Description,StartDateTime,EndDateTime,ApprovalState,ApprovalStateCode,BookingType,BookingTypeCode,ReturnType,ReturnTypeCode,RegisterCode,RegisterPhoto,OwnerCode,RegisterName,LinkScheduleID,UserPositionName,UserDeptName,UserLevelName,UserTitleName"));
			}
		}
		
		if(!params.getString("mode").equals("S")){
			CoviList userDefValue = coviMapperOne.list("user.resource.selectUserDefValueList", params); //사용자 정의 필드 값
			CoviList notiCommentObj = eventSvc.selectNotificationComment(params);

			returnObj.put("repeat", eventSvc.selectEventRepeat(params));
			
			params.put("RegisterCode", params.getString("UserCode"));
			returnObj.put("notification", eventSvc.selectEventNotification(params)); //등록자의 알림 설정 정보 조회
			
			returnObj.put("userDefValue", CoviSelectSet.coviSelectJSON(userDefValue, "UserFormID,FieldValue,FieldText,SortKey,FieldName,FieldType"));
			returnObj.put("notiComment", notiCommentObj);
		}
		
		return returnObj;
	}
	
	//ResEvent Attendant 조회
		@Override
		public  CoviList selectResEventAttendant(CoviMap params) throws Exception{
		
			CoviList  list = coviMapperOne.list("user.resource.selectResEventAttendant", params);
			return CoviSelectSet.coviSelectJSON(list, "UserCode,UserName,DeptCode,DeptName,IsOutsider,IsAllow");
		}

	@SuppressWarnings("unchecked")
	public CoviList coviSelectJSONForResourceList(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap resourceDic = getResourceDic();

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("ApprovalState")) {
									newObject.put(cols[j], Objects.toString(resourceDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));
							} else if (ar.equals("BookingType") || ar.equals("ReturnType")) {
								newObject.put(cols[j], Objects.toString(resourceDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));	
							}else {
								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
							}
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}

	@SuppressWarnings("unchecked")
	public  CoviMap coviSelectJSONForResourceList(CoviMap obj, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap resourceDic = getResourceDic();
		
		CoviMap newObject = new CoviMap();
		for(int j=0; j<cols.length; j++){
			Set<String> set = obj.keySet();
			Iterator<String> iter = set.iterator();
			
			while(iter.hasNext()){   
				String ar = (String)iter.next();
				if(ar.equals(cols[j].trim())){
					if (ar.equals("ApprovalState")) {
						newObject.put(cols[j], Objects.toString(resourceDic.getString(obj.getString(cols[j])), obj.getString(cols[j]) ));
					} else if (ar.equals("BookingType") || ar.equals("ReturnType")) {
						newObject.put(cols[j], Objects.toString(resourceDic.getString(obj.getString(cols[j])),obj.getString(cols[j]) ));	
					}else {
						newObject.put(cols[j], obj.getString(cols[j]));
					}
				}
			}
		}
		
		return newObject;
	}
	
	// 자원에서 사용하는 다국어 값 세팅
	public CoviMap getResourceDic() throws Exception {
		CoviMap resourceDicObj = new CoviMap();
		
		resourceDicObj.put("ChargeApproval", "lbl_ChargeApproval"); // 담당승인
		resourceDicObj.put("DirectApproval", "lbl_DirectApproval"); // 바로승인
		resourceDicObj.put("ApprovalProhibit", "lbl_NotBooking"); // 예약불가
		resourceDicObj.put("ChargeConfirm", "lbl_adminconfirm"); // 담당확인
		resourceDicObj.put("AutoReturn", "lbl_AutoReturn"); // 자동반납
		
		resourceDicObj.put("ApprovalRequest", "lbl_ApprovalReq"); // 승인요청
		resourceDicObj.put("Reject", "lbl_Deny"); // 거부
		resourceDicObj.put("Approval", "lbl_Approved"); // 승인
		resourceDicObj.put("ReturnRequest", "btn_Returnrequest"); // 반납요청
		resourceDicObj.put("ReturnComplete", "lbl_res_ReturnComplete"); // 반납완료
		resourceDicObj.put("ApprovalCancel", "lbl_ApplicationWithdrawn"); // 신청철회
		resourceDicObj.put("ApprovalDeny", "lbl_CancelApproval"); // 승인취소
		resourceDicObj.put("AutoCancel", "lbl_AutoCancel"); // 자동 취소
		
		resourceDicObj.put("", "");
		
		String dicCode = "";
		StringBuffer buf = new StringBuffer();
		for (Iterator<String> keys = resourceDicObj.keys(); keys.hasNext();) {
			buf.append(resourceDicObj.getString(keys.next())).append(";");
		}
		dicCode = buf.toString();
		CoviList dicobj = DicHelper.getDicAll(dicCode);

		for (int i = 0; i < resourceDicObj.size(); i++) {
			Iterator<String> keys1 = resourceDicObj.keys();
			String key1 = keys1.next();

			for (Iterator<String> keys2 = dicobj.getJSONObject(0).keys(); keys2	.hasNext();) {
				String key2 = keys2.next();
				if (resourceDicObj.getString(key1).equals(key2)) {
					resourceDicObj.remove(key1);
					resourceDicObj.put(key1, dicobj.getJSONObject(0).getString(key2));
					break;
				}
			}
		}

		return resourceDicObj;
	}

	@Override
	public CoviMap getResourceData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap folderData = coviMapperOne.select("user.resource.selectFolderData", params);
		CoviMap resourceData = coviMapperOne.select("user.event.selectResourceData", params);
		CoviList equipmentList = coviMapperOne.list("user.resource.selectEquipmentList", params);
		CoviList attributeList = coviMapperOne.list("user.resource.selectAttributeList", params);
		
		CoviMap mngParams = new CoviMap();
		mngParams.put("FolderID", params.getString("FolderID"));
		mngParams.put("ObjectType", "FD");
		
		CoviList managerList = coviMapperOne.list("user.resource.selectManagerList", mngParams);
		
		returnObj.put("folderData", coviSelectJSONForResourceList(folderData, "FolderID,ResourceName,ParentFolderName,PlaceOfBusiness,Description,ResourceImage"));
		returnObj.put("resourceData", coviSelectJSONForResourceList(resourceData, "IconPath,BookingType,ReturnType,BookingTypeCode,ReturnTypeCode,NotificationState,NotificationKind,LeastRentalTime,LeastPartRentalTime,DescriptionURL"));
		returnObj.put("equipmentList", CoviSelectSet.coviSelectJSON(equipmentList, "EquipmentID,EquipmentName,IconPath"));
		returnObj.put("attributeList", CoviSelectSet.coviSelectJSON(attributeList, "AttributeID,AttributeName,AttributeValue"));
		returnObj.put("managerList", CoviSelectSet.coviSelectJSON(managerList, "AclID,ObjectID,ObjectType,SubjectCode,SubjectName,UserType,UserPositionName,UserDeptName,PhotoPath"));

		return returnObj;
	}
	
	@Override
	public CoviMap modifyBookingState(CoviMap params) throws Exception {
		CoviMap retObj = new CoviMap();
		StringUtil func = new StringUtil();
		
		String retType = "SUCCESS";
		String retMsg = DicHelper.getDic("msg_Common_36");  //처리 되었습니다.
		
		CoviMap bookingData =  coviMapperOne.select("user.resource.selectBookingStateData", params);
		String sEventID = bookingData.getString("EventID");
		String sFolderID = bookingData.getString("FolderID");
		String isSchedule = bookingData.getString("IsSchedule");
		String sCurrentState = bookingData.getString("ApprovalState").toUpperCase();
		String sStartDateTime = bookingData.getString("StartDateTime");
		String sEndDateTime = bookingData.getString("EndDateTime");
		String sReturnType = bookingData.getString("ReturnType").toUpperCase();
		String sBookingType = bookingData.getString("BookingType").toUpperCase();
		String sSubject =  bookingData.getString("Subject");
		String sDateID = params.getString("DateID");
		String sRepeatID = bookingData.getString("RepeatID");
		String sIsRepeat = bookingData.getString("IsRepeat");
		String sRegisterCode = bookingData.getString("RegisterCode");
		String sUserCode = SessionHelper.getSession("UR_Code");
		
		String sTitle = "";
		String reminderTimeText = "";
		
		SimpleDateFormat dateFormat= new SimpleDateFormat("yyyy-MM-dd HH:mm");
		Date dCurrentDate = new Date();
		Date dStartDateTime = dateFormat.parse(sStartDateTime);
		Date dEndDateTime = dateFormat.parse(sEndDateTime);
		
		params.put("StartDateTime", sStartDateTime);
		params.put("EndDateTime", sEndDateTime);
		
		String sReceiverText = "§lbl_date§ : " + sStartDateTime + " ~ " + sEndDateTime + "&lt;br&gt;";
		sReceiverText += "§lbl_executive_place§ : §FD@@" + sFolderID + "§ &lt;br&gt;";
		sReceiverText += "§lbl_Purpose§ : " + sSubject;
		
		CoviMap notiParam = new CoviMap();
		notiParam.put("Subject", sSubject);
		notiParam.put("EventID", sEventID);
		notiParam.put("DateID", sDateID);
		notiParam.put("RepeatID", sRepeatID);
		notiParam.put("IsRepeat", sIsRepeat);
		notiParam.put("ResourceID", sFolderID);
		
		CoviMap dicMap = new CoviMap();
		CoviMap dicParams = new CoviMap();
		String[] dicArr = {"lbl_date", "lbl_executive_place","lbl_Purpose"};
		dicParams.put("dicArr", dicArr);
		String[] folderArr = {"FD@@" + sFolderID};
		dicParams.put("folderArr", folderArr);
		
		dicMap = messageSvc.getDicInfo(dicParams);
		notiParam.put("MessageContext", sReceiverText);
		notiParam.put("ReservedStr4", CoviMap.toJSONString(dicMap));
		
		switch(params.getString("ApprovalState").toUpperCase()){

		case "APPROVAL" :  //승인
			if(sCurrentState.equals("APPROVALREQUEST")){
				sTitle = "승인";
				reminderTimeText = "자원 예약 승인 하였습니다.";
				
				params.put("FolderID", sFolderID);
				
				long duplicateCnt = coviMapperOne.getNumber("user.resource.selectDuplicateTime",params); ///동일 시간 대 선예약 정보 조회
				
				if(duplicateCnt>=1){
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_01");     //이미 다른 자원의 신청을 승인한 상태입니다.
				}else{
					coviMapperOne.update("user.resource.updateBookingState",params);
					
					//예약완료 알림 발송 (승인자 -> 예약자)
					notiParam.put("SenderCode", sUserCode);
					notiParam.put("ReceiversCode", sRegisterCode);
					sendMessage(notiParam, "BookingComplete");
					
					
					params.put("EventID", sEventID);
					params.put("DateID", sDateID);
					params.put("RegisterCode", sRegisterCode);
					CoviMap notificationObj = eventSvc.selectEventNotification(params);
					
					
					CoviList attendeeList = eventSvc.selectAttendee(params);
					
	 				for(Object aObj : attendeeList) {
						
						CoviMap attendee = (CoviMap)aObj;
					
						//참석안내 알림
						CoviMap notiParams2 = new CoviMap();
						String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
																						+ "&eventID="     + sEventID
																						+ "&dateID=" 	  + sDateID
																						+ "&repeatID=" 	  + sRepeatID
																						+ "&isRepeat=" 	  + sIsRepeat 
																						+ "&resourceID="  + sFolderID
																						+ "&isAttendee=Y";
						
						String mobileAlarmUrl =   "/groupware/mobile/resource/view.do"  + "?eventid=" + sEventID + "&dateid=" + sDateID 
												+ "&repeatid="   + sRepeatID
												+ "&isrepeat="   + sIsRepeat
												+ "&resourceid=" + sFolderID;
						
						notiParams2.put("ServiceType", 	   "Resource");
						notiParams2.put("MessagingSubject", sSubject);
						notiParams2.put("SenderCode",   	   sRegisterCode);
						notiParams2.put("RegisterCode", 	   sRegisterCode);
						notiParams2.put("ReceiversCode",    attendee.getString("UserCode"));
						notiParams2.put("GotoURL", 		   alarmUrl);
						notiParams2.put("PopupURL", 		   alarmUrl);
						notiParams2.put("MobileURL", 	   mobileAlarmUrl);
						notiParams2.put("MsgType", 		   "ScheduleAttendance");
						
						CoviMap dicMap2 = new CoviMap();
						CoviMap dicParams2 = new CoviMap(dicParams);
						String[] dicArr2 = {"lbl_date", "lbl_executive_place","lbl_Purpose","msg_BookingAttendant"};
						dicParams2.put("dicArr", dicArr2);

						String sReceiverText2 = "§msg_BookingAttendant§" + "&lt;br&gt;" + sReceiverText;	// 자원 예약의 참석자로 지정되었습니다.
						dicMap2 = messageSvc.getDicInfo(dicParams2);
						notiParams2.put("MessageContext", sReceiverText2);
						notiParams2.put("ReceiverText", sReceiverText2);		
						notiParams2.put("ReservedStr4", CoviMap.toJSONString(dicMap2));
						
						eventSvc.sendNotificationMessage(notiParams2);
	 				}
					
					// 미리 알림 보내기
					if(isSchedule.equalsIgnoreCase("N") && notificationObj != null && !notificationObj.isEmpty()){
						CoviMap resourceParam = new CoviMap();
						resourceParam.put("dateID", sDateID);
						resourceParam.put("eventID", sEventID);
						resourceParam.put("repeatID", sRepeatID);
						resourceParam.put("notificationObj", notificationObj);
						resourceParam.put("RegisterCode", sRegisterCode);
						resourceParam.put("Subject",  sSubject);
						resourceParam.put("IsRepeat", sIsRepeat);
						resourceParam.put("FolderID", sFolderID);
						resourceParam.put("startDate", sStartDateTime.split(" ")[0]);
						resourceParam.put("startTime", sStartDateTime.split(" ")[1]);
						
						sendResourceReminderAlarm(resourceParam);
					}
					
				}
				
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_02");     //승인할 수 없는 상태입니다.
			}
			
			break;
		case "RETURNREQUEST": //반납요청
			sTitle = "반납요청";
			reminderTimeText = "자원 예약 반납요청 하였습니다.";
			if(sCurrentState.equals("APPROVAL") ){
				if(dCurrentDate.after(dStartDateTime) && dCurrentDate.before(dEndDateTime) ) { //현재 진행중일 때
					coviMapperOne.update("user.resource.updateReturnBookingState",params);
				}else{
					coviMapperOne.update("user.resource.updateBookingState",params);
				}
				
				//	반납요청 알림 발송 (예약자 -> 담당자)
				if(sReturnType.equals("CHARGECONFIRM")){ //담당확인일 경우
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", sFolderID);
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode", sUserCode);
					notiParam.put("ReceiversCode", managerCode);
					sendMessage(notiParam, "ReturnRequest");
				}
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_04");     //반납요청 할 수 없는 상태입니다.
			}
			
			if(sReturnType.equals("AUTORETURN")){ //자동반납일 경우
				params.put("ApprovalState", "ReturnComplete");
				modifyBookingState(params);  //반납완료 상태로 재호출
			}
			
			break;
		case "APPROVALDENY": //승인취소
			sTitle = "승인취소";
			reminderTimeText = "자원 예약 승인취소 하였습니다.";
			if(sCurrentState.equals("APPROVAL")){
				coviMapperOne.update("user.resource.updateBookingState",params);
				// 예약 취소 알림 발송 (담당자 -> 예약자)
				notiParam.put("SenderCode", sUserCode);
				notiParam.put("ReceiversCode", sRegisterCode);
				sendMessage(notiParam, "BookingCancel");
				
				// 일정과 연동되어 있을 경우 일정관리에 있는 데이터를 삭제
				CoviMap paramsMap = new CoviMap(); 
				paramsMap.put("EventID", sEventID);
				coviMapperOne.update("user.schedule.updateEventDeleted", paramsMap);
				
				//TODO 미리 알림 삭제
				params.put("SearchType", "EQ");
				params.put("ServiceType", "Resource");
				params.put("ObjectType", "reminder_"+ sRegisterCode);			// 자원예약일 경우 참석자에게만 감. 
				params.put("ObjectID", sDateID);
				eventSvc.updateMessagingCancelState(params);
				
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_05");     //승인취소 할 수 없는 상태입니다.
			}
			
			break;
		case "RETURNCOMPLETE": //반납완료
			sTitle = "반납완료";
			reminderTimeText = "자원 예약 반납완료 하였습니다.";
			if(sCurrentState.equals("RETURNREQUEST") ){
				if(dCurrentDate.after(dStartDateTime) && dCurrentDate.before(dEndDateTime) ) { //현재 진행중일 때
					coviMapperOne.update("user.resource.updateReturnBookingState",params);
				}else{
					coviMapperOne.update("user.resource.updateBookingState",params);
				}
				
				//	반납완료 알림 발송 (담당자 -> 예약자)
				notiParam.put("SenderCode", sUserCode);
				notiParam.put("ReceiversCode", sRegisterCode);
				sendMessage(notiParam, "ReturnComplete");
				
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_06");     //반납완료 할 수 없는 상태입니다.
			}
			
			break;
		case "APPROVALCANCEL": //신청 철회
			sTitle = "신청 철회";
			reminderTimeText = "자원 예약 신청 철회 하였습니다.";
			if( (sCurrentState.equalsIgnoreCase("APPROVAL") && dCurrentDate.before(dStartDateTime)) 
					|| sCurrentState.equalsIgnoreCase("APPROVALREQUEST")) { //승인, 승인요청
				coviMapperOne.update("user.resource.updateBookingState",params);
				
				// 일정과 연동되어 있을 경우 일정관리에 있는 데이터를 삭제
				scheduleSvc.deleteEventRepeatByDate(params);
				
				//	자동승인이 아닐 경우 신청철회 알림 발송 (예약자 -> 담당자)
				if(!sBookingType.equalsIgnoreCase("DIRECTAPPROVAL")){
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", sFolderID);
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode", sUserCode);
					notiParam.put("ReceiversCode", managerCode);
					sendMessage(notiParam, "ApprovalCancel");
				}
				
				if(sCurrentState.equalsIgnoreCase("APPROVAL")){
					params.put("SearchType", "EQ");
					params.put("ServiceType", "Resource");
					params.put("ObjectType", "reminder_"+ sRegisterCode);			// 자원예약일 경우 참석자에게만 감. 
					params.put("ObjectID", sDateID);
					eventSvc.updateMessagingCancelState(params);
				}
				
				//참석자들에게 알림
				params.put("EventID", sEventID);
				CoviList attendeeList = eventSvc.selectAttendee(params);
				
 				for(Object aObj : attendeeList) {
					
					CoviMap attendee = (CoviMap)aObj;
				
					CoviMap attNotiParam = new CoviMap();
							attNotiParam.put("Subject", 	  sSubject);
							attNotiParam.put("EventID", 	  sEventID);
							attNotiParam.put("DateID", 		  sDateID);
							attNotiParam.put("RepeatID",  	  sRepeatID);
							attNotiParam.put("IsRepeat", 	  sIsRepeat);
							attNotiParam.put("ResourceID", 	  sFolderID);
							attNotiParam.put("IsRepeatAll",   sIsRepeat.equals("Y") ? "Y" : "N");
							attNotiParam.put("SenderCode",    sRegisterCode);
							attNotiParam.put("ReceiversCode", attendee.getString("UserCode"));
							
							CoviMap dicMap2 = new CoviMap();
							CoviMap dicParams2 = new CoviMap(dicParams);
							String[] dicArr2 = {"lbl_date", "lbl_executive_place","lbl_Purpose","msg_CancelBookingAttendant"};
							dicParams2.put("dicArr", dicArr2);

							String sReceiverText2 = "§msg_CancelBookingAttendant§" + "&lt;br&gt;" + sReceiverText;
							dicMap2 = messageSvc.getDicInfo(dicParams2);
							attNotiParam.put("MessageContext", sReceiverText2);
							attNotiParam.put("ReceiverText", sReceiverText2);		// 참석자로 지정된 예약이 취소되었습니다.
							attNotiParam.put("ReservedStr4", CoviMap.toJSONString(dicMap2));
							
					sendMessage(attNotiParam, "BookingCancel");
				}
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_07");     //신청철회 할 수 없는 상태입니다.
			}
			
			break;
		case "REJECT": //거부
			sTitle = "거부";
			reminderTimeText = "자원 예약 거부 하였습니다.";
			if(sCurrentState.equals("APPROVALREQUEST")) {
				coviMapperOne.update("user.resource.updateBookingState", params);
				params.put("EventID", sEventID);
				
				if(eventSvc.selectResourceList(params).size() != 0){
					coviMapperOne.update("user.schedule.updateEventDeleted", params);
				}
				
				//예약거부 알림 발송 (담당자 -> 예약자)
				notiParam.put("SenderCode", sUserCode);
				notiParam.put("ReceiversCode", sRegisterCode);
				sendMessage(notiParam, "BookingReject");
				
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_03");     //거부할 수 없는 상태입니다.
			}
			break;
		case "AUTOCANCEL": //자동취소
			sTitle = "자동취소";
			reminderTimeText = "자원 예약 자동취소 하였습니다.";
			if(sCurrentState.equals("APPROVAL")) {
				coviMapperOne.update("user.resource.updateBookingState",params);
			}else{
				retType = "FAIL";
				retMsg = DicHelper.getDic("msg_ChangeApprovalState_08");     //자동취소 할 수 없는 상태입니다.
			}
			break;
		default :
			retMsg = "";
			break;
		}
		

		retObj.put("retType", retType);
		retObj.put("retMsg", retMsg);
		
		return retObj;
	}

	
	@Override
	public CoviMap modifyAllBookingState(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		Date currentDate = new Date();
		SimpleDateFormat dateFormat= new SimpleDateFormat("yyyy-MM-dd HH:mm");
		
		CoviMap notiBookingData = null; //notiBookingData는 성공항목 중 마지막 bookingData
		CoviMap bookingData = null;
		CoviList bookingList =  CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectBookingStateData", params)
								,"EventID,DateID,FolderID,IsSchedule,ApprovalState,RepeatID,IsRepeat,StartDateTime,EndDateTime,ReturnType,BookingType,Subject,RegisterCode");
		
		int successCnt = 0;
		int failCnt = 0;
		
		for(Object obj : bookingList) {
			bookingData = (CoviMap) obj;
			
			params.put("DateID", bookingData.getString("DateID"));
			
			Date dStartDateTime = dateFormat.parse(bookingData.getString("StartDateTime"));
			Date dEndDateTime = dateFormat.parse(bookingData.getString("EndDateTime"));
			
			String retMsg = "";		
			String retType = "SUCCESS";
			String currentState = bookingData.getString("ApprovalState");
			
			switch(params.getString("ApprovalState").toUpperCase()){
			case "APPROVAL" :  //승인
				if(currentState.equalsIgnoreCase("APPROVALREQUEST")){
					params.put("FolderID", bookingData.getString("FolderID"));
					
					long duplicateCnt = coviMapperOne.getNumber("user.resource.selectDuplicateTime",params); ///동일 시간 대 선예약 정보 조회
					if(duplicateCnt >= 1){
						retType = "FAIL";
						retMsg = DicHelper.getDic("msg_ChangeApprovalState_01");     //이미 다른 자원의 신청을 승인한 상태입니다.
					}else{
						coviMapperOne.update("user.resource.updateBookingState",params);
						params.put("RegisterCode", bookingData.getString("RegisterCode"));
						
						CoviMap notificationObj = eventSvc.selectEventNotification(params);
						
						// 미리 알림 보내기
						if(bookingData.getString("IsSchedule").equalsIgnoreCase("N") && notificationObj != null && !notificationObj.isEmpty()){
							CoviMap resourceParam = new CoviMap();
							resourceParam.put("dateID", bookingData.getString("DateID"));
							resourceParam.put("eventID", bookingData.getString("EventID"));
							resourceParam.put("repeatID", bookingData.getString("RepeatID"));
							resourceParam.put("RegisterCode", bookingData.getString("RegisterCode"));
							resourceParam.put("Subject",  bookingData.getString("Subject"));
							resourceParam.put("IsRepeat", bookingData.getString("IsRepeat"));
							resourceParam.put("FolderID", bookingData.getString("FolderID"));
							resourceParam.put("startDate", bookingData.getString("StartDateTime").split(" ")[0]);
							resourceParam.put("startTime", bookingData.getString("StartDateTime").split(" ")[1]);
							resourceParam.put("notificationObj", notificationObj);
							
							sendResourceReminderAlarm(resourceParam);
						}
					}
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_02");     //승인할 수 없는 상태입니다.
				}
				
				break;
			case "RETURNREQUEST": //반납요청
				if(currentState.equalsIgnoreCase("APPROVAL") && currentDate.after(dStartDateTime)){
					if(currentDate.after(dStartDateTime) && currentDate.before(dEndDateTime) ) { //현재 진행중일 때
						coviMapperOne.update("user.resource.updateReturnBookingState",params);
					}else{
						coviMapperOne.update("user.resource.updateBookingState",params);
					}
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_04");     //반납요청 할 수 없는 상태입니다.
				}
				
				if(bookingData.getString("ReturnType").equalsIgnoreCase("AUTORETURN")){ //자동반납일 경우
					params.put("approvalState", "ReturnComplete");
					modifyBookingState(params);  //반납완료 상태로 재호출
				}
				
				break;
			case "APPROVALDENY": //승인취소
				if(currentState.equalsIgnoreCase("APPROVAL")){
					coviMapperOne.update("user.resource.updateBookingState",params);
										
					// 미리 알림 삭제
					params.put("SearchType", "EQ");
					params.put("ServiceType", "Resource");
					params.put("ObjectType", "reminder_"+ bookingData.getString("RegisterCode"));			// 자원예약일 경우 참석자에게만 감. 
					params.put("ObjectID", bookingData.getString("DateID"));
					eventSvc.updateMessagingCancelState(params);
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_05");     //승인취소 할 수 없는 상태입니다.
				}
				
				break;
			case "RETURNCOMPLETE": //반납완료
				if(currentState.equalsIgnoreCase("RETURNREQUEST") ){
					if(currentDate.after(dStartDateTime) && currentDate.before(dEndDateTime) ) { //현재 진행중일 때
						coviMapperOne.update("user.resource.updateReturnBookingState",params);
					}else{
						coviMapperOne.update("user.resource.updateBookingState",params);
					}
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_06");     //반납완료 할 수 없는 상태입니다.
				}
				
				break;
			case "APPROVALCANCEL": //신청 철회
				if( (currentState.equalsIgnoreCase("APPROVAL") && currentDate.before(dStartDateTime)) 
						|| currentState.equalsIgnoreCase("APPROVALREQUEST")) { //승인, 승인요청
					coviMapperOne.update("user.resource.updateBookingState",params);
					
					eventSvc.deleteEventDateByEventID(params);
					
					if(currentState.equalsIgnoreCase("APPROVAL")){
						params.put("SearchType", "EQ");
						params.put("ServiceType", "Resource");
						params.put("ObjectType", "reminder_"+ bookingData.getString("RegisterCode"));			// 자원예약일 경우 참석자에게만 감. 
						params.put("ObjectID",  bookingData.getString("DateID"));
						eventSvc.updateMessagingCancelState(params);
					}
				}else if(currentState.equalsIgnoreCase("ApprovalCancel")){
					retType = "SUCCESS"; // 이미 취소된 예약의 경우 패스
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_07");     //신청철회 할 수 없는 상태입니다.
				}
				
				break;
			case "REJECT": //거부
				if(currentState.equalsIgnoreCase("APPROVALREQUEST")) {
					coviMapperOne.update("user.resource.updateBookingState",params);
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_03");     //거부할 수 없는 상태입니다.
				}
				break;
			case "AUTOCANCEL": //자동취소
				if(currentState.equalsIgnoreCase("APPROVAL")) {
					coviMapperOne.update("user.resource.updateBookingState",params);
				}else{
					retType = "FAIL";
					retMsg = DicHelper.getDic("msg_ChangeApprovalState_08");     //자동취소 할 수 없는 상태입니다.
				}
				break;
			default :
				break;
			}
			
			bookingData.put("retType", retType);
			bookingData.put("retMsg", retMsg);
			
			if(retType.equalsIgnoreCase("FAIL")){
				failCnt++;
			}else {
				successCnt++;
				notiBookingData = bookingData;
			}
		}
		
		if(successCnt > 0) {
			CoviMap notiParam = new CoviMap();
			notiParam.put("Subject", notiBookingData.getString("Subject"));
			notiParam.put("EventID", notiBookingData.getString("EventID"));
			notiParam.put("DateID", notiBookingData.getString("DateID"));
			notiParam.put("RepeatID", notiBookingData.getString("RepeatID"));
			notiParam.put("IsRepeat", notiBookingData.getString("IsRepeat"));
			notiParam.put("IsRepeatAll", notiBookingData.getString("IsRepeat").equals("Y") ? "Y" : "N");
			notiParam.put("ResourceID", notiBookingData.getString("FolderID"));
			notiParam.put("SenderCode", SessionHelper.getSession("UR_Code"));
			
			CoviMap manageParma = new CoviMap();
			manageParma.put("FolderID", notiBookingData.getString("FolderID"));
			manageParma.put("ObjectType", "FD");
			
			if(params.getString("ApprovalState").equalsIgnoreCase("APPROVAL")) { //승인
				//예약완료 알림 발송 (승인자 -> 예약자)
				notiParam.put("ReceiversCode", notiBookingData.getString("RegisterCode"));
				
				sendMessage(notiParam, "BookingComplete");
			}else if(params.getString("ApprovalState").equalsIgnoreCase("RETURNREQUEST") 
					&& notiBookingData.getString("ReturnType").equalsIgnoreCase("CHARGECONFIRM")) {	//반납요청
				//반납요청 알림 발송 (예약자 -> 담당자)
				String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
				notiParam.put("ReceiversCode", managerCode);
				
				sendMessage(notiParam, "ReturnRequest");
			}else if(params.getString("ApprovalState").equalsIgnoreCase("APPROVALDENY")) { //승인 취소
				//예약 취소 알림 발송 (담당자 -> 예약자)
				notiParam.put("ReceiversCode", notiBookingData.getString("RegisterCode"));
				
				sendMessage(notiParam, "BookingCancel");
			}else if(params.getString("ApprovalState").equalsIgnoreCase("RETURNCOMPLETE")) { //반납완료
				//반납완료 알림 발송 (담당자 -> 예약자)
				notiParam.put("ReceiversCode", notiBookingData.getString("RegisterCode"));
				
				sendMessage(notiParam, "ReturnComplete");
			}else if(params.getString("ApprovalState").equalsIgnoreCase("APPROVALCANCEL")
					&& !notiBookingData.getString("BookingType").equalsIgnoreCase("DIRECTAPPROVAL")) { //신청 철회
				//신청철회 알림 발송 (예약자 -> 담당자)
				String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
				notiParam.put("ReceiversCode", managerCode);
				
				sendMessage(notiParam, "ApprovalCancel");
			}else if(params.getString("ApprovalState").equalsIgnoreCase("REJECT")) { //반납완료
				//예약거부 알림 발송 (담당자 -> 예약자)
				notiParam.put("ReceiversCode", notiBookingData.getString("RegisterCode"));
				
				sendMessage(notiParam, "BookingReject");
			}
		}
		
		returnObj.put("SuccessCnt", successCnt);
		returnObj.put("FailCnt", failCnt);
		returnObj.put("bookingArray", bookingList);
		
		return returnObj;
	}
	
	@Override
	public CoviMap checkDuplicateTime(String folderID, String dateID, String eventID, CoviMap eventDateObj , CoviMap repeatObj) throws Exception{
		CoviMap returnObj = new CoviMap();
		returnObj.put("IsDuplication", 0); //1: 겹침, 0: 겹치지 않음
		returnObj.put("Message", DicHelper.getDic("msg_DeonRegist")); //등록 되었습니다.
		
		CoviList dateList = new CoviList();
		
		if(repeatObj != null && eventDateObj != null && !repeatObj.isEmpty() && !eventDateObj.getString("IsRepeat").equals("N")){
			dateList = eventSvc.setEventRepeatDate(repeatObj);
		}else if(eventDateObj != null){
			CoviMap dateObj = new CoviMap();
			dateObj.put("StartDate", eventDateObj.getString("StartDate"));
			dateObj.put("EndDate", eventDateObj.getString("EndDate"));			
			dateList.add(dateObj);
		}
		
		if(repeatObj != null && !repeatObj.isEmpty()){
			eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
			eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
		}
	
		for(Object obj : dateList){
			CoviMap dateMap = (CoviMap)obj;
			CoviMap params = new CoviMap();
			
			params.put("FolderID", folderID);						// 자원 ID
			if(dateID!=null &&dateID.split(";").length >1){
				params.put("EventID", eventID);						// 자원 ID
			}
			params.put("DateID", dateID);						// 자원 ID
			
			if(repeatObj != null && !repeatObj.isEmpty()){
				params.put("RepeatID", repeatObj.getString("RepeatID"));
			}
			params.put("StartDateTime", dateMap.getString("StartDate") + " " + eventDateObj.getString("StartTime"));
			params.put("EndDateTime", dateMap.getString("EndDate") + " " + eventDateObj.getString("EndTime"));
		
			// Resource Booking 데이터
			if(coviMapperOne.getNumber("user.resource.selectDuplicateTime", params) >= 1){
				returnObj.put("IsDuplication", 1);
				returnObj.put("Message",  DicHelper.getDic("msg_ReservationWrite_06")+params.getString("StartDateTime") + "~" + params.getString("EndDateTime"));
				break;
			}
		}
		
		return returnObj;
	}
	
	@Override
	public CoviMap checkRedisDuplicateTime(String folderID, CoviMap eventDateObj , CoviMap repeatObj) throws Exception{
		CoviMap returnObj = new CoviMap();
		returnObj.put("IsDuplication", 0); //1: 겹침, 0: 겹치지 않음
		returnObj.put("Message", DicHelper.getDic("msg_DeonRegist")); //등록 되었습니다.
		
		CoviList dateList = new CoviList();
		
		if(repeatObj != null && eventDateObj != null && !repeatObj.isEmpty() && !eventDateObj.getString("IsRepeat").equals("N")){
			dateList = eventSvc.setEventRepeatDate(repeatObj);
		}else if(eventDateObj != null){
			CoviMap dateObj = new CoviMap();
			dateObj.put("StartDate", eventDateObj.getString("StartDate"));
			dateObj.put("EndDate", eventDateObj.getString("EndDate"));			
			dateList.add(dateObj);
		}
		
		if (repeatObj != null && !repeatObj.isEmpty()) {
			eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
			eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
		}		
	
		for(Object obj : dateList){
			CoviMap dateMap = (CoviMap)obj;
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("StartDateTime", dateMap.getString("StartDate") + " " + eventDateObj.getString("StartTime"));
			params.put("EndDateTime", dateMap.getString("EndDate") + " " + eventDateObj.getString("EndTime"));
			
			// Resource Booking 데이터 Redis 검색
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			Set<String> names = instance.keys("ResourceBooking_" + folderID, "ResourceBooking_" + folderID + "*");
			Iterator<String> it = names.iterator();
			while (it.hasNext()) {
				String resourceBookingStr = instance.get(it.next());
				
				if(resourceBookingStr != null && !resourceBookingStr.isEmpty()) {
					ObjectMapper mapperObj = new ObjectMapper();
					CoviMap resourceBookingMap = mapperObj.readValue(resourceBookingStr, CoviMap.class);
					
					SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");        
					Date bStartDateTime = formatter.parse(resourceBookingMap.get("StartDateTime").toString());
					Date bEndDateTime = formatter.parse(resourceBookingMap.get("EndDateTime").toString());
					
					Date pStartDateTime = formatter.parse(params.get("StartDateTime").toString());
					Date pEndDateTime = formatter.parse(params.get("EndDateTime").toString());
					
					if(((pStartDateTime.equals(bStartDateTime) || pStartDateTime.before(bStartDateTime)) && (bEndDateTime.equals(pEndDateTime) || bEndDateTime.before(pEndDateTime))) ||
						(pStartDateTime.before(bStartDateTime) && bStartDateTime.before(pEndDateTime) && (pEndDateTime.equals(bEndDateTime) || pEndDateTime.before(bEndDateTime))) ||
						((bStartDateTime.equals(pStartDateTime) || bStartDateTime.before(pStartDateTime)) && pStartDateTime.before(bEndDateTime) && (bEndDateTime.equals(pEndDateTime) || bEndDateTime.before(pEndDateTime))) ||
						((bStartDateTime.equals(pStartDateTime) || bStartDateTime.before(pStartDateTime)) && (pEndDateTime.equals(bEndDateTime) || pEndDateTime.before(bEndDateTime)))) {
						
						returnObj.put("IsDuplication", 1);
						returnObj.put("Message",  DicHelper.getDic("msg_ReservationWrite_06") + params.getString("StartDateTime") + "~" + params.getString("EndDateTime"));
						break;
					}
				}
			}
			
			// Redis 에서 중복이 없으면 예약 정보를 추가한다.
			if(returnObj.getInt("IsDuplication") == 0) {
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(params);				
				instance.save("ResourceBooking_" + folderID + "_" + SessionHelper.getSession("USERID"), jsonResp);
			}
		}
		
		return returnObj;
	}
	
	// 자원 예약 가능 여부 확인 (일정 간단 등록)
	@Override
	public int checkResourceApv(String folderID) throws Exception{
		CoviMap params = new CoviMap();
		params.put("FolderID", folderID);
		
		int result = (int) coviMapperOne.getNumber("user.resource.selectCheckResourceApv", params);
		
		return result;
	}
	
	@Override
	public CoviMap saveBookingData(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", DicHelper.getDic("msg_DeonRegist"));
		
		String resourceID = dataObj.getString("ResourceID"); 				//등록 자원 ID
		String isSchedule = dataObj.getString("IsSchedule"); 				// 일정 등록 여부
		CoviMap eventObj = dataObj.getJSONObject("Event");					// 이벤트 마스터 정보
		CoviMap eventDateObj = dataObj.getJSONObject("Date");
		CoviMap repeatObj = dataObj.getJSONObject("Repeat");				// 반복 정보
		CoviMap notificationObj = dataObj.getJSONObject("Notification");	// 알림 정보
		CoviList userformArr = dataObj.getJSONArray("UserForm");			// 확장 필드 정보
		
		//참석자
		CoviList attendeeArr = null;
		if(dataObj.has("Attendee")) { attendeeArr =  dataObj.getJSONArray("Attendee"); };	
		
		CoviMap params = null;
		
		String eventID = "";
		String repeatID = "";
		String dateID = "";
		String bookingState = "ApprovalRequest";
		
		// 자동 승인 여부 자원 조회
		CoviMap resourceParams = new CoviMap();		
		resourceParams.put("FolderID", eventObj.getString("FolderID"));
		
		CoviMap resourceDataObj = eventSvc.selectResourceData(resourceParams);
		
		if(resourceDataObj != null && !(resourceDataObj.isEmpty())){
			bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
		}
		
		if(isSchedule.equals("Y")){
			CoviMap scheduleObj = dataObj;
			CoviMap scEventObj = new CoviMap(); //일정 등록에 매개변수로 넘길 event 데이터
			scEventObj.put("FolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID")); // 개인일정 Config 값 
			scEventObj.put("FolderType","Schedule.Person"); //개인 일정 고정값
			scEventObj.put("EventType", "");
			scEventObj.put("LinkEventID","");
			scEventObj.put("MasterEventID","");
			scEventObj.put("Subject", eventObj.getString("Subject").length() > 100 ? (eventObj.getString("Subject")).substring(0,100) : eventObj.getString("Subject"));
			scEventObj.put("Place", "");
			scEventObj.put("Description", eventObj.getString("Subject"));
			scEventObj.put("IsPublic", "Y");
			scEventObj.put("IsDisplay", "Y");
			scEventObj.put("IsInviteOther", "N");
			scEventObj.put("ImportanceState", "N");
			scEventObj.put("OwnerCode",		   eventObj.getString("RegisterCode"));
			scEventObj.put("RegisterCode",	   eventObj.getString("RegisterCode"));
			scEventObj.put("MultiRegisterName", eventObj.getString("MultiRegisterName"));
			scEventObj.put("ModifierCode",	   eventObj.getString("RegisterCode"));
			scEventObj.put("SecurityLevel",	   eventObj.getString("SecurityLevel"));
			
			CoviList scResource = new CoviList();
			CoviMap scResourceObj = new CoviMap();
			scResourceObj.put("FolderID", resourceID);
			scResource.add( scResourceObj );  //ResourceName은 Insert에는 필요하지 않으므로 넘기지 않음.
			
			scheduleObj.put("Event", scEventObj);
			scheduleObj.put("Resource", scResource);
			//scheduleObj.put("Attendee", new CoviList());				//자원 등록 시, 참석자 정보 없음. 
			scheduleObj.remove("Userform"); 							//일정 등록 시 확장 필드 정보는 삭제.
			
			scheduleObj.put("Attendee", attendeeArr);
			scheduleSvc.insertSchedule(scheduleObj, null, null);
			
			eventID  = scheduleObj.getString("eventID");
			repeatID = scheduleObj.getString("repeatID");
			dateID   = scheduleObj.getString("dateID");
		}else{
			CoviList dateList = new CoviList();
			
			//Event 데이터 삽입
			params = new CoviMap();
			params.put("FolderID", eventObj.getString("FolderID"));
			params.put("FolderType", eventObj.getString("FolderType"));
			params.put("EventType", "");
			params.put("LinkEventID",null);
			params.put("MasterEventID",null);
			params.put("Subject", eventObj.getString("Subject"));
			params.put("Place", "");
			params.put("Description", eventObj.getString("Description"));
			params.put("IsPublic", "Y");
			params.put("IsDisplay", "Y");
			params.put("IsInviteOther", "N");
			params.put("ImportanceState","N");
			params.put("IsDisplay", "Y");
			params.put("OwnerCode", 	  	eventObj.getString("RegisterCode"));
			params.put("RegisterCode", 	  	eventObj.getString("RegisterCode"));
			params.put("MultiRegisterName", eventObj.getString("MultiRegisterName"));
			params.put("ModifierCode", 		eventObj.getString("RegisterCode"));
			params.put("DeleteDate", null);

			eventID = eventSvc.insertEvent(params);
			
			//Repeat 삽입
			if(!repeatObj.isEmpty()){
				eventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
				eventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
				
				// 반복 정보 repeatID 생성
				repeatObj.put("EventID", eventID);
				repeatID = eventSvc.insertEventRepeat(repeatObj);
				
				// 반복 정보 dateList 생성
				dateList = eventSvc.setEventRepeatDate(repeatObj);
			}
			else{
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
			
			CoviMap duplicationRedisObj = null;
			
			// 자동 승인 자원일 경우 Redis 에서 중복 자원예약 현황 조회
			if(bookingState.equalsIgnoreCase("APPROVAL")) {	
				duplicationRedisObj = checkRedisDuplicateTime(resourceID, eventDateObj, repeatObj);
			}
			
			if(duplicationRedisObj != null && duplicationRedisObj.getInt("IsDuplication") == 1){
				returnObj.put("retType", "DUPLICATION");
				returnObj.put("retMsg", duplicationRedisObj.getString("Message"));			
				return returnObj;
			}
			
			CoviMap duplicationObj = null;
			
			// 중복 자원예약 현황 조회 (DB)
			duplicationObj = checkDuplicateTime(resourceID, null, null, eventDateObj, repeatObj);
			
			if(duplicationObj.getInt("IsDuplication") == 1){
				returnObj.put("retType", "DUPLICATION");
				returnObj.put("retMsg", duplicationObj.getString("Message"));			
				return returnObj;
			}
			
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
				
				// 자동 승인일 경우 미리 알림 보내기
				if(bookingState.equalsIgnoreCase("APPROVAL")){
					String reminderTimeText = "";
					int remiderTime = notificationObj.getInt("ReminderTime");
					switch (remiderTime) {
					case 1: case 10: case 20: case 30:	reminderTimeText = remiderTime + " 분"; break;
					case 180: case 360: case 720:			reminderTimeText = (remiderTime/60) + " 시간"; break;
					case 1440: case 2880: case 4320:	reminderTimeText = (remiderTime/60/24) + " 일"; break;
					default: break;
					}
					
					if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){
						CoviMap resourceParam = new CoviMap();
						resourceParam.put("dateID", dateID);
						resourceParam.put("eventID", eventID);
						resourceParam.put("repeatID", repeatID);
						resourceParam.put("notificationObj", notificationObj);
						resourceParam.put("RegisterCode", eventObj.getString("RegisterCode"));
						resourceParam.put("Subject",  eventObj.getString("Subject"));
						resourceParam.put("IsRepeat", eventDateObj.getString("IsRepeat"));
						resourceParam.put("FolderID", eventObj.getString("FolderID"));
						resourceParam.put("startDate", startDate);
						resourceParam.put("startTime", startTime);
						
						sendResourceReminderAlarm(resourceParam);
					}
				}				
				
				params = new CoviMap();				
				params.put("DateID", dateID);
				params.put("EventID", eventID);
				params.put("ResourceID", eventObj.getString("FolderID"));						// 자원 ID
				params.put("ApprovalDate", null);
				params.put("ApprovalState", bookingState);
				params.put("RealEndDateTime", startDate + " " + startTime);
			
				// Resource Booking 데이터
				eventSvc.insertEventResourceBooking(params);
				
				//Notification 삽입 (자원예약의 알람 대상은 등록자만 존재)
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("DateID", dateID);
				params.put("IsNotification", notificationObj.getString("IsNotification"));
				params.put("IsReminder", notificationObj.getString("IsReminder"));
				params.put("ReminderTime", notificationObj.getString("ReminderTime"));
				params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
				params.put("MediumKind", notificationObj.getString("MediumKind"));
				
				eventSvc.insertEventNotificationByRegister(params);
			}
			
			//메세지 상세 등록
			String sReceiverText = "§lbl_date§ : " + eventDateObj.getString("StartDate") + " " + eventDateObj.getString("StartTime") + "~" + eventDateObj.getString("EndDate") + " " + eventDateObj.getString("EndTime")+ "&lt;br&gt;";
			sReceiverText += (dataObj.get("ResourceName") != null) ? "§lbl_executive_place§ : §FD@@" + eventObj.getString("FolderID") + "§ &lt;br&gt;" : "";
			sReceiverText += "§lbl_Purpose§ : " + eventObj.getString("Subject");
			//알림 보내기 
			CoviMap notiParam = new CoviMap();
			notiParam.put("Subject", eventObj.getString("Subject"));
			notiParam.put("ReceiverText", eventObj.getString("Subject"));
			notiParam.put("EventID", eventID);
			notiParam.put("DateID", dateID);
			notiParam.put("RepeatID", repeatID);
			notiParam.put("IsRepeat", eventDateObj.getString("IsRepeat"));
			notiParam.put("IsRepeatAll", eventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
			notiParam.put("ResourceID", eventObj.getString("FolderID"));
			notiParam.put("MessageContext", sReceiverText);
			
			CoviMap dicMap = new CoviMap();
			CoviMap dicParams = new CoviMap();
			String[] dicArr = {"lbl_date", "lbl_executive_place","lbl_Purpose"};
			dicParams.put("dicArr", dicArr);
			String[] folderArr = {"FD@@"+eventObj.getString("FolderID")};
			dicParams.put("folderArr", folderArr);
			dicMap = messageSvc.getDicInfo(dicParams);
			notiParam.put("ReservedStr4", CoviMap.toJSONString(dicMap));
			
			if(bookingState.equalsIgnoreCase("Approval")){//자동승인일 경우 예약완료 알림 보내기
				notiParam.put("SenderCode", eventObj.getString("RegisterCode"));
				notiParam.put("ReceiversCode", eventObj.getString("RegisterCode"));
				sendMessage(notiParam, "BookingComplete");
				
				//참석자 데이터(참석자, 알림) 추가.
				if(attendeeArr != null) {

					//전달 소스의 1367 라인
					for(Object obj : attendeeArr){
						
						CoviMap attendantObj = (CoviMap) obj;
						
						params = new CoviMap();
						params.put("EventID", 			eventID);
						params.put("AttenderCode", 		attendantObj.getString("UserCode"));
						params.put("MultiAttenderName", attendantObj.getString("UserName"));
						params.put("IsOutsider", 		attendantObj.getString("IsOutsider"));
						params.put("IsAllow",			"");
						
	 					insertResEventAttendant(params);	//1.참석자 명단 데이터를 저장.
						
						//참석안내 알림
						CoviMap notiParams = new CoviMap();
						String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
																						+ "&eventID="     + eventID
																						+ "&dateID=" 	  + dateID
																						+ "&repeatID=" 	  + repeatID
																						+ "&isRepeat=" 	  + eventDateObj.getString("IsRepeat") 
																						+ "&resourceID="  + resourceID
																						+ "&isRepeatAll=" + ( eventDateObj.containsKey("IsRepeatAll") ? eventDateObj.getString("IsRepeatAll") : "N" )
																						+ "&isAttendee=Y";
						
						String mobileAlarmUrl =   "/groupware/mobile/resource/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
												+ "&repeatid="   + repeatID
												+ "&isrepeat="   + eventDateObj.getString("IsRepeat") 
												+ "&resourceid=" + resourceID;
						
						notiParams.put("ServiceType", 	   "Resource");
						notiParams.put("MessagingSubject", eventObj.getString("Subject"));
						notiParams.put("SenderCode",   	   eventObj.getString("RegisterCode"));
						notiParams.put("RegisterCode", 	   eventObj.getString("RegisterCode"));
						notiParams.put("ReceiversCode",    attendantObj.getString("UserCode"));
						notiParams.put("GotoURL", 		   alarmUrl);
						notiParams.put("PopupURL", 		   alarmUrl);
						notiParams.put("MobileURL", 	   mobileAlarmUrl);
						notiParams.put("MsgType", 		   "ScheduleAttendance");
						
						CoviMap dicMap2 = new CoviMap();
						CoviMap dicParams2 = new CoviMap(dicParams);
						String[] dicArr2 = {"lbl_date", "lbl_executive_place","lbl_Purpose","msg_BookingAttendant"};
						dicParams2.put("dicArr", dicArr2);

						String sReceiverText2 = "§msg_BookingAttendant§" + "&lt;br&gt;" + sReceiverText;	// 자원 예약의 참석자로 지정되었습니다.
						dicMap2 = messageSvc.getDicInfo(dicParams2);
						notiParams.put("MessageContext", sReceiverText2);
						notiParams.put("ReceiverText", sReceiverText2);
						notiParams.put("ReservedStr4", CoviMap.toJSONString(dicMap2));
						
						eventSvc.sendNotificationMessage(notiParams);					
					}
				}
				
			}else{ //담당승인 경우 승인요청 알림 보내기
				CoviMap manageParma = new CoviMap();
				manageParma.put("FolderID", eventObj.getString("FolderID"));
				manageParma.put("ObjectType", "FD");
				String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
				
				notiParam.put("SenderCode", eventObj.getString("RegisterCode"));
				notiParam.put("ReceiversCode", managerCode);
				sendMessage(notiParam, "ApprovalRequest");
				
				//참석자 데이터(참석자, 알림) 추가.
				if(attendeeArr != null) {

					//전달 소스의 1367 라인
					for(Object obj : attendeeArr){
						
						CoviMap attendantObj = (CoviMap) obj;
						
						params = new CoviMap();
						params.put("EventID", 			eventID);
						params.put("AttenderCode", 		attendantObj.getString("UserCode"));
						params.put("MultiAttenderName", attendantObj.getString("UserName"));
						params.put("IsOutsider", 		attendantObj.getString("IsOutsider"));
						params.put("IsAllow",			"");
						
	 					insertResEventAttendant(params);	//1.참석자 명단 데이터를 저장.
					}
				}
			}
			
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
		
		//첨부파일 처리 
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", eventID);
			filesParams.put("ObjectID", resourceID);
			filesParams.put("ObjectType", "FD");
			
			insertResourceSysFile(filesParams, mf);
		}
	
		dataObj.put("eventID", eventID);
		dataObj.put("dateID", dateID);
		dataObj.put("repeatID", repeatID);
		
		return returnObj;
	}
	
	//자원에약
	@Override
	public void insertResEventAttendant(CoviMap params) throws Exception {

		coviMapperOne.insert("user.resource.insertResEventAttendant", params);
	}

	@Override
	public CoviMap modifyBookingData(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception {
		CoviMap returnObj = new CoviMap();
		returnObj.put("retType","OK");
		returnObj.put("retMsg", "성공적으로 저장하였습니다."); //TODO 성공적으로 저장하였습니다.
		
		CoviMap eventObj = null; 				// 이벤트 마스터 정보
		CoviMap eventDateObj = null;			// Date 정보
		CoviMap repeatObj =null ;				// 반복 정보
		CoviMap notificationObj = null;			// 알림 정보
		CoviList userformArr = null;			// 확장필드 정보
		CoviList attendantArr = null;			//참석자 정보
		
		String isSchedule = dataObj.getString("IsSchedule"); // 일정 등록 여부
		String eventID = dataObj.getString("EventID");
		String repeatID = dataObj.getString("RepeatID");
		String dateID = dataObj.getString("DateID");
		String resourceID = dataObj.getString("ResourceID");
		String oldResourceID = dataObj.getString("oldResourceID");
		
		Boolean isChgFolderID = false;
		
		CoviMap params = new CoviMap();
		CoviList dateList = new CoviList();
		
		// 미리알림을 위한 데이터
		String registerCode = dataObj.getString("RegisterCode");
		String subject = dataObj.getString("Subject");
		
		CoviMap pEventDateObj = null, pRepeatObj = null;
		
		// 폴더가 변경되었는지 체크
		if(!resourceID.equalsIgnoreCase(oldResourceID))
			isChgFolderID = true;
		
		if(dataObj.has("Date")){
			pEventDateObj = dataObj.getJSONObject("Date");
		}else{
			params.clear();
			params.put("DateID", dateID.split(";")[0]);
			pEventDateObj = eventSvc.selectEventDate(params);
		}
		
		if(dataObj.has("Repeat")){
			pRepeatObj = dataObj.getJSONObject("Repeat");
		}else{
			params.clear();
			params.put("RepeatID", repeatID);
			pRepeatObj = eventSvc.selectEventRepeat(params);
		}		
		
		if(dataObj.has("Notification")){
			notificationObj = dataObj.getJSONObject("Notification");
		}else{
			params.clear();
			params.put("EventID", eventID);
			params.put("RegisterCode", registerCode);
			notificationObj  =  eventSvc.selectEventNotification(params);
		}		 
		
		// 날짜나 반복, FolderID가 변경되었을 때만 중복 체크 진행
		if(((dataObj.has("Date") && dataObj.getJSONObject("Date").getString("IsRepeat").equalsIgnoreCase("N")) && (dataObj.has("Date") && dataObj.has("Repeat") || !(dataObj.has("Date") && dataObj.getJSONObject("Date").getString("IsRepeat").equalsIgnoreCase("Y") && !dataObj.has("Repeat")))) || isChgFolderID){			
			String bookingState = "ApprovalRequest";
			
			// 자동 승인 여부 자원 조회
			CoviMap resourceParams = new CoviMap();		
			resourceParams.put("FolderID", resourceID);			
			
			CoviMap resourceDataObj = eventSvc.selectResourceData(resourceParams);
			
			if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
				bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
			}
		}
		
		if(isSchedule.equals("Y")){
			CoviMap scheduleObj = dataObj;
			CoviList scResource = new CoviList();

			params.clear();
			params.put("EventID", eventID);
			
			CoviList relationArr = eventSvc.selectResourceList(params);
			
			for(Object obj : relationArr){
				CoviMap relation = (CoviMap)obj;
				
				if(relation.getString("FolderID").equals(oldResourceID)){
					continue;
				}
				
				scResource.add(relation);
			}
			scResource.add( new CoviMap().fromObject("{\"FolderID\":"+resourceID+"}")); 
			
			scheduleObj.put("Resource", scResource);
			
			if(dataObj.has("Event")){
				eventObj = dataObj.getJSONObject("Event");
				
				CoviMap scEventObj = new CoviMap(); //일정 등록에 매개변수로 넘길 event 데이터
				scEventObj.put("FolderID", (eventObj.getString("FolderType").equals("Resource") ? RedisDataUtil.getBaseConfig("SchedulePersonFolderID") : eventObj.getString("FolderID")));
				scEventObj.put("FolderType", (eventObj.getString("FolderType").equals("Resource") ? "Schedule.Person" : eventObj.getString("FolderType")));
				scEventObj.put("EventType", "");				//TODO
				scEventObj.put("LinkEventID","");			//TODO
				scEventObj.put("MasterEventID","");			//TODO
				scEventObj.put("Subject", eventObj.getString("Subject"));
				scEventObj.put("Description", eventObj.getString("Description"));
				scEventObj.put("IsPublic", "Y");				//TODO
				scEventObj.put("IsDisplay", "Y");				//TODO
				scEventObj.put("IsInviteOther", "N");		//TODO
				scEventObj.put("ImportanceState", "N");	//TODO
				scEventObj.put("IsDisplay", "Y");
				scEventObj.put("OwnerCode", eventObj.getString("RegisterCode"));
				scEventObj.put("ModifierCode", eventObj.getString("RegisterCode"));
				
				scheduleObj.put("Event", scEventObj);
			}else{
				CoviMap scEventObj = new CoviMap(); //일정 등록에 매개변수로 넘길 event 데이터
				scEventObj = eventSvc.selectEvent(params);
				scEventObj.put("FolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID")); // 개인일정 Config 값
				scEventObj.put("FolderType","Schedule.Person"); //개인 일정 고정값
				
				scheduleObj.put("Event", scEventObj);
			}
			
			
			//scheduleObj.put("Attendee", new CoviList()); //자원 등록 시, 참석자 정보 없음. 
			//scheduleObj.remove("Userform"); //일정 등록 시 확장 필드 정보는 삭제.
			
			scheduleSvc.updateSchedule(scheduleObj, null, null);
			
		}else{
			CoviList oldDateIDs  = new CoviList(Arrays.asList(eventSvc.getDateIDs(eventID)));
			String bookingState = "ApprovalRequest";
			params.put("FolderID", resourceID); 
			CoviMap resourceDataObj = eventSvc.selectResourceData(params);
			if(resourceDataObj != null && !(resourceDataObj.isEmpty()) ){
				bookingState = resourceDataObj.getString("BookingType").equals("DirectApproval") ? "Approval" : "ApprovalRequest"; //자동 승인일 경우
			}
			
			if(isChgFolderID){	// 자원 수정 했을 경우
				params = new CoviMap();
				params.put("ResourceID", resourceID);
				params.put("oldResourceID", oldResourceID);
				params.put("EventID", eventID);
				params.put("DateID", dateID);
				updateEventResourceBookingResID(params);
				eventSvc.updateResourceRealEndDateTime(params);
				
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", subject);
				notiParam.put("EventID", eventID);
				notiParam.put("DateID", dateID);
				notiParam.put("RepeatID", repeatID);
				notiParam.put("IsRepeat", pEventDateObj.getString("IsRepeat"));
				notiParam.put("IsRepeatAll", pEventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
				notiParam.put("ResourceID", resourceID);
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동 승인 - 예약완료 알림
					notiParam.put("SenderCode", registerCode);
					notiParam.put("ReceiversCode", registerCode);
					sendMessage(notiParam, "BookingComplete");
				}else{		 //담당자 승인 - 승인요청 알림
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceID);
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode" ,registerCode);
					notiParam.put("ReceiversCode", managerCode);
					sendMessage(notiParam, "ApprovalRequest");
				}
			}
			
			if(dataObj.has("Event")){
				eventObj = dataObj.getJSONObject("Event");
				
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("FolderID", eventObj.getString("FolderID"));
				params.put("FolderType", eventObj.getString("FolderType"));
				params.put("EventType", "");
				params.put("LinkEventID",null);
				params.put("MasterEventID",null);
				params.put("Subject", eventObj.getString("Subject"));
				params.put("Description", eventObj.getString("Description"));
				params.put("IsPublic", "Y");
				params.put("IsDisplay", "Y");
				params.put("IsInviteOther", "N");
				params.put("ImportanceState","N");
				params.put("IsDisplay", "Y");
				params.put("OwnerCode", eventObj.getString("RegisterCode"));
				params.put("RegisterCode", eventObj.getString("RegisterCode"));
				params.put("MultiRegisterName", eventObj.getString("MultiRegisterName"));
				params.put("ModifierCode", eventObj.getString("RegisterCode"));

				eventSvc.updateEvent(params);
			}
			
			// 반복, 자원, 날짜 변경시
			if(dataObj.has("Date")){
				eventDateObj = dataObj.getJSONObject("Date");
			}
			
			// 반복 변경되었을 경우
			if(dataObj.has("Repeat")){
				repeatObj = dataObj.getJSONObject("Repeat");
				
				// 반복이 설정되어 있다가 삭제된 경우
				if(repeatObj.isEmpty() && eventDateObj != null && eventDateObj.has("IsRepeat") && eventDateObj.getString("IsRepeat").equals("N")){
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
					pEventDateObj.put("StartTime", repeatObj.getString("AppointmentStartTime"));
					pEventDateObj.put("EndTime", repeatObj.getString("AppointmentEndTime"));
					
					repeatObj.put("RepeatID", repeatID);
					eventSvc.updateEventRepeat(repeatObj);
					
					// Date 다시 저장
					dateList = eventSvc.setEventRepeatDate(repeatObj);
				}
			}
			// Date 만 수정한 경우 (반복 X)
			else{
				if(eventDateObj != null){
					CoviMap dateObj = new CoviMap();
					dateObj.put("StartDate", eventDateObj.getString("StartDate"));
					dateObj.put("EndDate", eventDateObj.getString("EndDate"));
					
					dateList.add(dateObj);
				}
			}
			
			CoviMap duplicationRedisObj = null;

			// 자동 승인 자원일 경우 Redis 에서 중복 자원예약 현황 조회
			if(bookingState.equalsIgnoreCase("APPROVAL")) {	
				duplicationRedisObj = checkRedisDuplicateTime(resourceID, pEventDateObj, pRepeatObj);
			}
			
			if(duplicationRedisObj != null && duplicationRedisObj.getInt("IsDuplication") == 1){
				returnObj.put("retType", "DUPLICATION");
				returnObj.put("retMsg", duplicationRedisObj.getString("Message"));			
				return returnObj;
			}
			
			CoviMap duplicationObj = checkDuplicateTime(resourceID, dateID, eventID, pEventDateObj, pRepeatObj);			
			if( duplicationObj.getInt("IsDuplication") == 1 ){
				returnObj.put("retType", "DUPLICATION");
				returnObj.put("retMsg", duplicationObj.getString("Message"));				
				return returnObj;
			}
		
			if(dateList !=null && !dateList.isEmpty()){
				// 기존 Date 삭제 후 다시 Insert
				params = new CoviMap();
				params.put("EventID", eventID);
				eventSvc.deleteEventDateByEventID(params);
				eventSvc.deleteEventResourceBooking(params);
				
				eventSvc.deleteEventNotification(params);
				
				params.put("SearchType", "EQ");
				params.put("ServiceType", "Resource");
				params.put("ObjectType", "reminder_"+ registerCode);			// 자원예약일 경우 참석자에게만 감. 
				params.put("arrObjectID", oldDateIDs);
				eventSvc.updateArrMessagingCancelState(params);
				
				for(Object obj : dateList){
					CoviMap dateMap = (CoviMap)obj;
					
					params = new CoviMap();
					String startDate = dateMap.getString("StartDate");
					String startTime = pEventDateObj.getString("StartTime");
					String endDate = dateMap.getString("EndDate");
					String endTime = pEventDateObj.getString("EndTime");
					
					params.put("EventID", eventID);
					params.put("RepeatID", repeatID);
					params.put("StartDateTime", startDate + " " + startTime);
					params.put("StartDate", startDate);
					params.put("StartTime", startTime);
					params.put("EndDateTime", endDate + " " + endTime);
					params.put("EndDate", endDate);
					params.put("EndTime", endTime);
					params.put("IsAllDay", pEventDateObj.getString("IsAllDay"));
					params.put("IsRepeat", pEventDateObj.getString("IsRepeat"));
					
					dateID = eventSvc.insertEventDate(params);
					
					params.clear();

					// 자동 승인일 경우 미리 알림 보내기 start
					/*if(bookingState.equalsIgnoreCase("APPROVAL")){
						String reminderTimeText = "";
						int remiderTime = notificationObj.getInt("ReminderTime");
						switch (remiderTime) {
						case 1: case 10: case 20: case 30:	reminderTimeText = remiderTime + " 분"; break;
						case 180: case 360: case 720:			reminderTimeText = (remiderTime/60) + " 시간"; break;
						case 1440: case 2880: case 4320:	reminderTimeText = (remiderTime/60/24) + " 일"; break;
						default: break;
						}
						
						if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y")){
							CoviMap resourceParam = new CoviMap();
							resourceParam.put("dateID", dateID);
							resourceParam.put("eventID", eventID);
							resourceParam.put("repeatID", repeatID);
							resourceParam.put("notificationObj", notificationObj);
							resourceParam.put("RegisterCode", registerCode);
							resourceParam.put("Subject",  subject);
							resourceParam.put("IsRepeat", pEventDateObj.getString("IsRepeat"));
							resourceParam.put("FolderID", resourceID);
							resourceParam.put("startDate", startDate);
							resourceParam.put("startTime", startTime);
							
							sendResourceReminderAlarm(resourceParam);
						}
					}*/
					// 자동 승인일 경우 미리 알림 보내기 end

					
					params = new CoviMap();
					params.put("DateID", dateID);
					params.put("EventID", eventID);
					params.put("ResourceID", resourceID);						// 자원 ID
					params.put("ApprovalDate", null);
					params.put("ApprovalState", bookingState );
					params.put("RealEndDateTime", startDate + " " + startTime);
					
					// Resource Booking 데이터
					eventSvc.insertEventResourceBooking(params);
						
					params = new CoviMap();
					params.put("EventID", eventID);
					params.put("DateID", dateID);
					params.put("IsNotification", "N");
					params.put("IsReminder", "N");
					params.put("ReminderTime", "10");
					params.put("IsCommentNotification", "N");
					params.put("MediumKind", "");
					eventSvc.insertEventNotificationByRegister(params);
				}
				
				// bookingState에 따라 예약 완료 알림 or 승인요청 알림 보내기 start
				CoviMap notiParam = new CoviMap();
				notiParam.put("Subject", subject);
				notiParam.put("EventID", eventID);
				notiParam.put("DateID", dateID);
				notiParam.put("RepeatID", repeatID);
				notiParam.put("IsRepeat", pEventDateObj.getString("IsRepeat"));
				notiParam.put("IsRepeatAll", pEventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N");
				notiParam.put("ResourceID", resourceID);
				
				if(bookingState.equalsIgnoreCase("Approval")){//자동 승인 - 예약완료 알림
					notiParam.put("SenderCode", registerCode);
					notiParam.put("ReceiversCode", registerCode);
					sendMessage(notiParam, "BookingComplete");
				}else{		 //담당자 승인 - 승인요청 알림
					CoviMap manageParma = new CoviMap();
					manageParma.put("FolderID", resourceID);
					manageParma.put("ObjectType", "FD");
					String managerCode = coviMapperOne.getString("user.resource.selectManagerCodes", manageParma);
					
					notiParam.put("SenderCode" ,registerCode);
					notiParam.put("ReceiversCode", managerCode);
					sendMessage(notiParam, "ApprovalRequest");
				}
				// bookingState에 따라 예약 완료 알림 or 승인요청 알림 보내기 end
			}
			
			// 참석자가 변경되었을 경우
			if(dataObj.has("Attendee")){
				
				attendantArr = dataObj.getJSONArray("Attendee");
				
				if(!attendantArr.isEmpty()){
					
					//참석자 데이터
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
							params.put("EventID", 	   		eventID);
							params.put("AttenderCode",		attendantObj.getString("UserCode"));
							params.put("MultiAttenderName", attendantObj.getString("UserName"));
							params.put("IsOutsider", 		attendantObj.getString("IsOutsider"));
							params.put("IsAllow", 			attendantObj.getString("IsAllow"));
							
							insertEventAttendant(params);
						}
							
							// 참석요청 알림
							// 자주쓰는 일정(템플릿) 일경우 알림제외
						
							// dateID가 변경되었을 경우 담당자에게 다시 메세지 발송 처리
							if(attendantObj.getString("dataType").equals("NEW")) {
								
								CoviMap notiParams = new CoviMap();
								String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
																								+ "&eventID="     + eventID
																								+ "&dateID=" 	  + dateID
																								+ "&repeatID=" 	  + repeatID
																								+ "&isRepeat=" 	  + pEventDateObj.getString("IsRepeat") 
																								+ "&resourceID="  + resourceID
																								+ "&isRepeatAll=" + ( pEventDateObj.getString("IsRepeat").equals("Y") ? "Y" : "N" )
																								+ "&isAttendee=Y";
								
								String mobileAlarmUrl =   "/groupware/mobile/resource/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID 
														+ "&repeatid="   + repeatID
														+ "&isrepeat="   + pEventDateObj.getString("IsRepeat") 
														+ "&resourceid=" + resourceID;
								
								
								String sStartDateTime = pEventDateObj.getString("StartDate") + " " + pEventDateObj.getString("StartTime");
								String sEndDateTime = pEventDateObj.getString("EndDate") + " " + pEventDateObj.getString("EndTime");
								
								notiParams.put("ServiceType", 	   "Resource");
								notiParams.put("MessagingSubject", subject);
								notiParams.put("SenderCode",   	   registerCode);
								notiParams.put("RegisterCode", 	   registerCode);
								notiParams.put("ReceiversCode",    attendantObj.getString("UserCode"));
								notiParams.put("GotoURL", 		   alarmUrl);
								notiParams.put("PopupURL", 		   alarmUrl);
								notiParams.put("MobileURL", 	   mobileAlarmUrl);
								notiParams.put("MsgType", 		   "ScheduleAttendance");
								
								String sReceiverText = "§msg_BookingAttendant§" + "&lt;br&gt;";			// 자원 예약의 참석자로 지정되었습니다.
								sReceiverText += "§lbl_date§ : " + sStartDateTime + " ~ " + sEndDateTime + "&lt;br&gt;";
								sReceiverText += "§lbl_executive_place§ : §FD@@" + resourceID + "§ &lt;br&gt;";
								sReceiverText += "§lbl_Purpose§ : " + subject;

								CoviMap dicMap = new CoviMap();
								CoviMap dicParams = new CoviMap();
								String[] dicArr = {"lbl_date", "lbl_executive_place","lbl_Purpose","msg_BookingAttendant"};
								dicParams.put("dicArr", dicArr);
								String[] folderArr = {"FD@@" + resourceID};
								dicParams.put("folderArr", folderArr);
								dicMap = messageSvc.getDicInfo(dicParams);
								
								notiParams.put("MessageContext", sReceiverText);
								notiParams.put("ReceiverText", sReceiverText);
								notiParams.put("ReservedStr4", CoviMap.toJSONString(dicMap));
								
								eventSvc.sendNotificationMessage(notiParams);
							}
					}
				}
			}
			
			// 알림 정보 수정
			 if(dataObj.has("Notification")){
				notificationObj = dataObj.getJSONObject("Notification");
				params = new CoviMap();
				params.put("EventID", eventID);
				params.put("IsNotification", notificationObj.getString("IsNotification"));
				params.put("IsReminder", notificationObj.getString("IsReminder"));
				params.put("ReminderTime", notificationObj.getString("ReminderTime"));
				params.put("IsCommentNotification", notificationObj.getString("IsCommentNotification"));
				params.put("MediumKind", notificationObj.getString("MediumKind"));
				
				eventSvc.updateEventNotification(params);
				if(dateList == null || dateList.isEmpty() ){
					if(notificationObj.getString("IsNotification").equals("Y") && notificationObj.getString("IsReminder").equals("Y") && bookingState.equalsIgnoreCase("APPROVAL")){
						CoviList dateIDs = new CoviList();
						dateIDs.addAll(Arrays.asList(eventSvc.getDateIDs(eventID)));
						
						for(int i = 0 ; i<dateIDs.size(); i++){
							CoviMap resourceParam = new CoviMap();
							resourceParam.put("dateID", dateIDs.get(i));
							resourceParam.put("eventID", eventID);
							resourceParam.put("repeatID", repeatID);
							resourceParam.put("notificationObj", notificationObj);
							resourceParam.put("RegisterCode", registerCode);
							resourceParam.put("Subject",  subject);
							resourceParam.put("IsRepeat", pEventDateObj.getString("IsRepeat"));
							resourceParam.put("FolderID", resourceID);
							resourceParam.put("startDate", pEventDateObj.getString("StartDate"));
							resourceParam.put("startTime", pEventDateObj.getString("StartTime"));
						
							sendResourceReminderAlarm(resourceParam);
						}
					}
				}
				 
			}
			 
			//확장 필드 정보 수정 
			if(dataObj.has("UserForm")){
				userformArr = dataObj.getJSONArray("UserForm");
				
				params = new CoviMap();
				params.put("EventID", eventID);
				
				coviMapperOne.delete("user.resource.deleteUserformValue",params);
				
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
			
		}
		
		//첨부파일 처리 
		if(fileInfos != null) {
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", fileInfos.getString("ServiceType"));
			filesParams.put("fileInfos", fileInfos.getString("fileInfos"));
			filesParams.put("MessageID", eventID);
			filesParams.put("ObjectID", resourceID);
			filesParams.put("ObjectType", "FD");
			
			updateResourceSysFile(filesParams, mf);
		}
		
		return returnObj;
	}
	
	//기존의 참석자 삭제
	@Override
	public void deleteEventAttendant(CoviMap params) throws Exception {
		
		coviMapperOne.delete("user.resource.deleteEventAttendant", params);
	}

	//삭제된 참석자가 개인일정으로 별도 등록했을 경우 삭제 
	@Override
	public void deleteEventByAttendeeData(CoviMap params) throws Exception {
		
		coviMapperOne.delete("user.resource.deleteEventByAttendeeData", params);
	}
	
	// 참석자 데이터 추가
	@Override
	public void insertEventAttendant(CoviMap params) throws Exception {
		
		coviMapperOne.insert("user.resource.insertEventAttendant", params);
	}

	@Override
	public CoviMap setEachSchedule(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf, String isChangeDate, String isChangeRes) throws Exception {
		String resourceID = dataObj.getString("ResourceID"); //등록 자원 ID
		Boolean isSchedule = dataObj.getString("IsSchedule").equalsIgnoreCase("Y"); // 일정 등록 여부
		CoviMap eventObj = dataObj.getJSONObject("Event");				// 이벤트 마스터 정보
		CoviList AttendeeObj = dataObj.getJSONArray("Attendee");	// 참석자 정보
		
		CoviMap scheduleObj = dataObj;
	
		CoviMap scEventObj = new CoviMap(); //일정 등록에 매개변수로 넘길 event 데이터
		
		if(isSchedule){
			scEventObj.put("FolderID", RedisDataUtil.getBaseConfig("SchedulePersonFolderID")); // 개인일정 Config 값 
			scEventObj.put("FolderType","Schedule.Person"); //개인 일정 고정값
		}else{
			scEventObj.put("FolderID", eventObj.getString("FolderID"));
			scEventObj.put("FolderType", eventObj.getString("FolderType"));
		}
		
		scEventObj.put("EventType", "M");
		scEventObj.put("LinkEventID","");
		scEventObj.put("MasterEventID",dataObj.getString("EventID"));
		scEventObj.put("Subject", eventObj.getString("Subject"));
		scEventObj.put("Place", "");
		scEventObj.put("Description", "");
		scEventObj.put("InlineImage", "");
		scEventObj.put("IsPublic", "Y");
		scEventObj.put("IsDisplay", "Y");
		scEventObj.put("IsInviteOther", "N");
		scEventObj.put("ImportanceState", "N");
		scEventObj.put("OwnerCode",eventObj.getString("RegisterCode"));
		scEventObj.put("RegisterCode",eventObj.getString("RegisterCode"));
		scEventObj.put("MultiRegisterName",eventObj.getString("MultiRegisterName"));
		scEventObj.put("ModifierCode",eventObj.getString("RegisterCode"));
		
		CoviList scResource = new CoviList();
		CoviMap scResourceObj = new CoviMap();
		scResourceObj.put("FolderID", resourceID);
		scResource.add( scResourceObj );  //ResourceName은 Insert에는 필요하지 않으므로 넘기지 않음.
		
		scheduleObj.put("Event", scEventObj);
		scheduleObj.put("Resource", scResource);
		scheduleObj.put("Attendee", AttendeeObj);
		scheduleObj.remove("Userform"); //일정 등록 시 확장 필드 정보는 삭제.
		
		
		//반복된 자원예약 개별 등록 시 날짜나 자원 변경 없이도 event_resource_booking에 insert되어야하기 떄문에 isChangeDate 또는 isChangeRes 중 하나는 true 여야함
		CoviMap returnObj = scheduleSvc.setEachSchedule(scheduleObj, fileInfos, mf, isChangeDate, "true", isSchedule);
		
		return returnObj;
	}
	
	// 자원 예약 가능 여부 확인 (일정 간단 등록)
	@Override
	public CoviMap checkDuplicateTime(String folderID, CoviMap eventDateObj) throws Exception{
		CoviMap returnObj = new CoviMap();
		returnObj.put("IsDuplication", 0); //1: 겹침, 0: 겹치지 않음
		returnObj.put("Message", DicHelper.getDic("msg_CanReserveRS"));					// 이 자원을 예약할 수 있습니다

		CoviMap tempEventDateObj = new CoviMap(eventDateObj);
		tempEventDateObj = ComUtils.TransServerTimeCoviMapDate(tempEventDateObj, "");
		CoviMap params = new CoviMap();
		params.put("FolderID", folderID);						// 자원 ID
		params.put("StartDateTime", tempEventDateObj.getString("StartDateTime"));
		params.put("EndDateTime", tempEventDateObj.getString("EndDateTime"));
	
		// Resource Booking 데이터
		if(coviMapperOne.getNumber("user.resource.selectDuplicateTime", params) >= 1){
			returnObj.put("IsDuplication", 1);
			returnObj.put("Message",  DicHelper.getDic("msg_CannotReserveRS"));		// 선택하신 시간에 예약을 할 수 없습니다.\n아래 등록 가능한 자원 및 시간을 추천합니다.
		}
		
		return returnObj;
	}
	
	
	
	// 자원 예약 가능 여부 체크
	@Override
	public CoviMap check(CoviMap dataObj) throws Exception {
		
		String folderID = dataObj.getString("FolderID");
		String resourceType = dataObj.getString("ResourceType");
		String startDate = dataObj.getString("StartDate");
		String endDate = dataObj.getString("EndDate");
		
		String msgSDate = "";
		String msgEDate = "";
		
		CoviMap eventDateObj = new CoviMap();
		
		eventDateObj.put("StartDate", startDate);
		eventDateObj.put("StartTime", dataObj.getString("StartTime"));
		eventDateObj.put("EndDate", endDate);
		eventDateObj.put("EndTime", dataObj.getString("EndTime"));
		
		String startDateTime = startDate + " " +dataObj.getString("StartTime");
		String endDateTime = endDate + " " +dataObj.getString("EndTime");
		
		// 자원 예약 여부 확인
		// 자원 예약이 불가능할 경우 추천 시간 확인
		CoviMap returnObj = checkDuplicateTime(folderID, eventDateObj);
		if(returnObj.getInt("IsDuplication") == 1 ){
			//이 자원의 유사한 시간대 추천
			
			int resourceCheckDay = RedisDataUtil.getBaseConfig("ResourceCheckDay") == null || Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckDay")) < 1 ? 1 : Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckDay"));
			int resourceCheckHour  = RedisDataUtil.getBaseConfig("ResourceCheckHour") == null || Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckHour")) < 5 ? 5 : Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckHour"));
			
			int resourceCheck = resourceCheckHour;
			int diifMinute = DateHelper.diffMinute(endDateTime, startDateTime);
			
			if(diifMinute >= (24*60)){
				resourceCheck = resourceCheckDay * 60;
			}
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("StartDateTime", startDateTime);
			params.put("EndDateTime", endDateTime);
			params.put("FolderType", resourceType);
			CoviList reserveList = getCheckedList(params);		// 그 시간대에 예약되어 있는 Array 가져오기
			
			int i = 1;
			int tempResourceCheck = resourceCheck;
			
			while(diifMinute >= tempResourceCheck){
				String tempStart2 = "";
				String tempEnd2 = "";
				msgSDate = "";
				msgEDate = "";
				
				tempResourceCheck = i * resourceCheck;
				
				// 앞으로
				tempStart2 = DateHelper.getAddDate(startDateTime, "yyyy-MM-dd HH:mm", -tempResourceCheck, Calendar.MINUTE);
				tempEnd2 = DateHelper.getAddDate(endDateTime, "yyyy-MM-dd HH:mm", -tempResourceCheck, Calendar.MINUTE);
				
				// 자원에 대해서 지난 날짜는 예약 할 수 없음
				if(DateHelper.diffDate(tempStart2, DateHelper.getCurrentDay("yyyy-MM-dd")) >= 0 && checkedReservedArray(tempStart2, tempEnd2, reserveList) == 0 ){
					// 종료일이 현재 시각보다 이전이면, 시작일에 대한 조건문 추가 하지 않음
					// 종료일이 현재 시각보다 이후이면, 시작일이 현재시각 보다 이후이도록 조건문 추가
					if(DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) < 0 ||
							(DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) >= 0 && DateHelper.diffMinute(tempStart2, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) >= 0)){
						// 날짜가 같으면 제외
						if(!tempStart2.split(" ")[0].equals(tempEnd2.split(" ")[0]) || !tempStart2.split(" ")[0].equals(startDate) || !tempEnd2.split(" ")[0].equals(endDate)){
							msgSDate = tempStart2;
							msgEDate = tempEnd2;
						}else{
							msgSDate = tempStart2.split(" ")[1];
							msgEDate = tempEnd2.split(" ")[1];
						}
						break;
					}
				}
				
				// 뒤로
				tempStart2 = DateHelper.getAddDate(startDateTime, "yyyy-MM-dd HH:mm", tempResourceCheck, Calendar.MINUTE);
				tempEnd2 = DateHelper.getAddDate(endDateTime, "yyyy-MM-dd HH:mm", tempResourceCheck, Calendar.MINUTE);
				
				if(DateHelper.diffDate(tempStart2, DateHelper.getCurrentDay("yyyy-MM-dd")) >= 0 && checkedReservedArray(tempStart2, tempEnd2, reserveList) == 0){
					// 날짜가 같으면 제외
					if(!tempStart2.split(" ")[0].equals(tempEnd2.split(" ")[0]) || !tempStart2.split(" ")[0].equals(startDate) || !tempEnd2.split(" ")[0].equals(endDate)){
						msgSDate = tempStart2;
						msgEDate = tempEnd2;
					}else{
						msgSDate = tempStart2.split(" ")[1];
						msgEDate = tempEnd2.split(" ")[1];
					}
					break;
				}
				
				i++;
			}
		}
		
		returnObj.put("StartDateTime", msgSDate);
		returnObj.put("EndDateTime", msgEDate);
		
		return returnObj;
	}
	
	//시간으로 가능한 다른 자원 체크
	@Override
	public CoviList checkTime(CoviMap dataObj) throws Exception {
		String folderID = dataObj.getString("FolderID");
		String startDateTime = dataObj.getString("StartDate")+ " " + dataObj.getString("StartTime");
		String endDateTime = dataObj.getString("EndDate")+ " " + dataObj.getString("EndTime");
		String resourceType = dataObj.getString("ResourceType");
		
		CoviList resultArr = null;
		
		CoviMap params = new CoviMap();
		params.put("FolderIDs", dataObj.get("FolderIDs"));
		params.put("FolderID", folderID);
		params.put("StartDateTime", startDateTime);
		params.put("EndDateTime", endDateTime);
		params.put("FolderType", resourceType);
		resultArr = getCheckTime(params);
		
		return resultArr;
	}

	public int checkedReservedArray(String targetStart, String targetEnd, CoviList timeArr) throws Exception{
		int isInclude = 0; //1: 포함, 0: 불 포함
		
		for(Object obj : timeArr){
			String oStart = ( (CoviMap)obj ).getString("StartDateTime"); //objectStart  (Format: yyyy-MM-dd HH:mm)
			String oEnd = ( (CoviMap)obj ).getString("EndDateTime"); //objectEnd (Format: yyyy-MM-dd HH:mm)
			
			//왼쪽(기준)이 클 떄 양수
			//오른쪽(비교대상 or 매개변수) 이 클 때 음수
			if( DateHelper.diffMinute(targetStart, oStart) <= 0 && DateHelper.diffMinute(targetEnd, oEnd) >= 0 ){ //기준 시간 안에 비교대상이 포함되어 있을 때 
				isInclude = 1;
				break;
			}else if( DateHelper.diffMinute(targetStart, oStart) < 0 && DateHelper.diffMinute(targetEnd, oStart) > 0 && DateHelper.diffMinute(targetEnd, oEnd) <= 0  ){ // 기준 시간 안에 비교대상의 시작점은 포함되엉 있고, 종료점은 넘어가지 않을 때 
				isInclude = 1;
				break;
			}else if( DateHelper.diffMinute(targetStart, oStart) >= 0 && DateHelper.diffMinute(targetStart,oEnd) < 0 && DateHelper.diffMinute(targetEnd, oEnd) >= 0 ){ // 기준 시간 안에 비교대상의 종료점은 포함되엉 있고, 시작점은 넘어가지 않을 때
				isInclude = 1;
				break;
			}else if( DateHelper.diffMinute(targetStart, oStart) >= 0 && DateHelper.diffMinute(targetEnd,oEnd) <= 0 ){ //기준 시간이 비교대상에 포함되어 있을 때 
				isInclude = 1;
				break;
			}
			/*
			
			//왼쪽(기준)이 클 떄 양수
			//오른쪽(비교대상 or 매개변수) 이 클 때 음수
			
			if(targetStart.compareTo(oStart)<=0 && targetEnd.compareTo(oEnd) >= 0 ){ 
				isInclude = 1;
				break;
			}else if(targetStart.compareTo(oStart) < 0  && targetEnd.compareTo(oStart) > 0  &&  targetEnd.compareTo(oEnd) <= 0  ){
				isInclude = 1;
				break;
			}else if(targetStart.compareTo(oStart) >= 0  &&  targetStart.compareTo(oEnd) < 0 && targetEnd.compareTo(oEnd) >= 0 ){
				isInclude = 1;
				break;
			}else if(targetStart.compareTo(oStart) >= 0  && targetEnd.compareTo(oEnd) <= 0) 
				isInclude = 1; 
				break;
			}
			
			*/
			
		}
		
		return isInclude;
	}

	
	@Override
	public CoviList getCheckTime(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectCheckTime", params), "FolderID,FolderName");
	}

	@Override
	public CoviList getCheckedList(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectCheckList", params), "StartDateTime,EndDateTime");
	}

	//이 자원의 다른 시간 대 추천
	@Override
	public CoviMap checkResource(CoviMap dataObj) throws Exception {
			CoviMap returnObj = new CoviMap();
			
			String folderID = dataObj.getString("FolderID");
			String folderType = dataObj.getString("ResourceType");
			String startDate = dataObj.getString("StartDate");
			String endDate = dataObj.getString("EndDate");
			String startTime = dataObj.getString("StartTime");
			String endTime = dataObj.getString("EndTime");
			
			String msgSDate = "";
			String msgEDate = "";
			
			String startDateTime = startDate + " " +startTime;
			String endDateTime = endDate + " " +endTime;
			
			int resourceCheck =  RedisDataUtil.getBaseConfig("ResourceCheckHour") == null || Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckHour")) < 5 ? 5 : Integer.parseInt(RedisDataUtil.getBaseConfig("ResourceCheckHour"));
			int diifMinute = DateHelper.diffMinute(endDateTime, startDateTime); 
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("FolderType", folderType);
			params.put("StartDateTime", startDate);
			params.put("EndDateTime",DateHelper.getAddDate(endDate,"yyyy-MM-dd",1,Calendar.DATE));
			
			CoviList reserveList = getCheckedList(params);		// 시작날짜와 끝 날짜 사이의 모든 예약 정보 조회
			
			//앞으로(시작 시간과 종료 시간 차 만큼의 앞/뒤 범위는 해 당자원의 비어있는 유사 시간대에서 체크하므로 제외)
			String frontStartDate = DateHelper.getAddDate(startDateTime, "yyyy-MM-dd HH:mm", -(diifMinute), Calendar.MINUTE);
			String frontEndDate = DateHelper.getAddDate(endDateTime, "yyyy-MM-dd HH:mm", -(diifMinute), Calendar.MINUTE);
			//뒤로
			String backStartDate = DateHelper.getAddDate(startDateTime, "yyyy-MM-dd HH:mm", (diifMinute), Calendar.MINUTE);
			String backEndDate = DateHelper.getAddDate(endDateTime, "yyyy-MM-dd HH:mm", (diifMinute), Calendar.MINUTE);
			
			int i = 1;
			int tmepResourceCheck = resourceCheck;
			
			boolean front = false, back = false;
			
			do{
				String tempStart = "";
				String tempEnd = "";
				msgSDate = "";
				msgEDate = "";
				
				tmepResourceCheck = i * resourceCheck;
				
				front = DateHelper.convertDateFormat( DateHelper.getAddDate(frontStartDate, "yyyy-MM-dd HH:mm", -tmepResourceCheck, Calendar.MINUTE), "yyyy-MM-dd HH:mm", "yyyy-MM-dd").equals(dataObj.getString("StartDate")); // 날짜가 같은지 비교
				back = DateHelper.convertDateFormat( DateHelper.getAddDate(backEndDate, "yyyy-MM-dd HH:mm", tmepResourceCheck, Calendar.MINUTE), "yyyy-MM-dd HH:mm", "yyyy-MM-dd").equals(dataObj.getString("EndDate"));
				
				// 앞으로
				if(front){
					tempStart = DateHelper.getAddDate(frontStartDate, "yyyy-MM-dd HH:mm", -tmepResourceCheck, Calendar.MINUTE);
					tempEnd = DateHelper.getAddDate(frontEndDate, "yyyy-MM-dd HH:mm", -tmepResourceCheck, Calendar.MINUTE);
					
					// 종료일이 현재 시각보다 이전이면, 시작일에 대한 조건문 추가 하지 않음
					// 종료일이 현재 시각보다 이후이면, 시작일이 현재시각 보다 이후이도록 조건문 추가
					if(DateHelper.diffDate(tempStart, DateHelper.getCurrentDay("yyyy-MM-dd")) >= 0 && checkedReservedArray(tempStart, tempEnd, reserveList) == 0){
						if(DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) < 0 ||
								(DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) >= 0 && DateHelper.diffMinute(tempStart, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) >= 0)){ 			
							//날짜 같으면 날짜 표시 하지 않음.
							if(!tempStart.split(" ")[0].equals(tempEnd.split(" ")[0]) || !tempStart.split(" ")[0].equals(startDate) || !tempEnd.split(" ")[0].equals(endDate)){
								msgSDate = tempStart;
								msgEDate = tempEnd;
							}else{
								msgSDate = tempStart.split(" ")[1];
								msgEDate = tempEnd.split(" ")[1];
							}
							break;
						}
					}
				}
				
				// 뒤로
				if(back){
					tempStart = DateHelper.getAddDate(backStartDate, "yyyy-MM-dd HH:mm", tmepResourceCheck, Calendar.MINUTE);
					tempEnd = DateHelper.getAddDate(backEndDate, "yyyy-MM-dd HH:mm", tmepResourceCheck, Calendar.MINUTE);
					
					if(DateHelper.diffDate(tempStart, DateHelper.getCurrentDay("yyyy-MM-dd")) >= 0 && checkedReservedArray(tempStart, tempEnd, reserveList) == 0){
						
						if(!tempStart.split(" ")[0].equals(tempEnd.split(" ")[0]) || !tempStart.split(" ")[0].equals(startDate) || !tempEnd.split(" ")[0].equals(endDate)){
							msgSDate = tempStart;
							msgEDate = tempEnd;
						}else{
							msgSDate = tempStart.split(" ")[1];
							msgEDate = tempEnd.split(" ")[1];
						}
						break;
					}
				}
				
				i++;
				
			}while(front || back);
			
			returnObj.put("StartDateTime", msgSDate);
			returnObj.put("EndDateTime", msgEDate);
			
			return returnObj;
	}

	@Override
	public CoviList getResourceList(CoviMap params) throws Exception {
		String objectInStr = eventSvc.getACLFolderData(SessionHelper.getSession(), "Resource", "V");	//View
		params.put("aclFolderIDs", objectInStr);
		params.put("isSaaS", isSaaS);
		params.put("aclFolderIDArr", objectInStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
		
		CoviList retArr = coviSelectJSONForResourceList(  coviMapperOne.list("user.resource.selectResourceList", params) , "FolderID,FolderType,TypeCode,TypeName,UpperFolderName,FolderName,PlaceOfBusiness,LeastRentalTime");
		
		return retArr;
	}

	@Override
	public CoviList getFolderTreeData(CoviMap params) throws Exception {
		try {
			loopCnt.set(new AtomicInteger(0));
			
			CoviList returnArr = new CoviList();
			CoviList resourceList = new CoviList();
			CoviList rootFolderIDArr = new CoviList();
			
			int rootID;
			
			params.put("DomainID", SessionHelper.getSession("DN_ID"));
			rootFolderIDArr = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectRootFolderID", params), "FolderID,DomainID,FolderType,FolderName");
			if (rootFolderIDArr != null && rootFolderIDArr.size()> 0){
				params.put("rootFolderIDArr",rootFolderIDArr);
			}else{
				params.put("folderID",-1);
			}
			
			if(isSaaS.equalsIgnoreCase("Y")){
				for (int i=0; i < rootFolderIDArr.size(); i++){
					CoviMap root = (CoviMap)rootFolderIDArr.get(i);
					if (!root.getString("DomainID").equals(SessionHelper.getSession("DN_ID"))){
						rootFolderIDArr.remove(i);
					}
				}
				resourceList.addAll(CoviSelectSet.coviSelectJSON( coviMapperOne.list("user.resource.selectChildResource", params), "FolderID,FolderType,FolderName"));	
			}else {
				resourceList.addAll(rootFolderIDArr);	
			}
			
			
			
			addChildFolder(resourceList, params);
			
			return resourceList;
		}finally {
			if(loopCnt != null) {
				loopCnt.remove();
			}
		}
	}
	
	private void addChildFolder(CoviList resourceList, CoviMap pParams) throws Exception {		
		CoviMap params = pParams;
		
		for(Object obj : resourceList){
			if(loopCnt.get().get() > 10000) {
				return;
			}
			
			CoviMap resourceObj = (CoviMap)obj;
			
			if ("Folder".equals(resourceObj.getString("FolderType"))) {
				params.put("DomainID", SessionHelper.getSession("DN_ID"));
				params.put("folderID",resourceObj.getString("FolderID"));

				CoviList childList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectChildResource", params), "FolderID,FolderType,FolderName") ;
				
				if(childList.size() > 0) {
					//loopCnt = loopCnt + 1;
					loopCnt.get().incrementAndGet();
					
					addChildFolder(childList, pParams);
					resourceObj.put("child", childList);
				}
			}
		}		
	}

	@Override
	public CoviMap getManageInfo() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		/*String subjectInStr = "";
		
		CoviMap subjectParams = new CoviMap();
		subjectParams.put("userCode", params.getString("userID"));
		Set<String> assignedSubjectCodeSet = authorityService.getAssignedSubject(subjectParams);
		assignedSubjectCodeSet.add(params.getString("userID"));
		
		//3. subject코드를 in절에 들어갈 string으로 변환
		String[] subjectArray = assignedSubjectCodeSet.toArray(new String[assignedSubjectCodeSet.size()]);
		
		if(subjectArray.length > 0){
			
			subjectInStr = "(" + ACLHelper.join(subjectArray, ",") + ")";
		}*/
		
		CoviMap userInfoObj = SessionHelper.getSession();
		CoviMap params = new CoviMap();
		
		params.put("userID", userInfoObj.getString("USERID"));
		params.put("groupPath", userInfoObj.getString("GR_GroupPath"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		String[] subjectInArr =  authorityService.getAssignedSubject(userInfoObj);
		
		params.put("subjectInArr", subjectInArr);
		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.resource.selectManageInfo", params),"FolderID"));
		returnObj.put("cnt",coviMapperOne.getNumber("user.resource.selectManageInfoCnt", params));
		
		return returnObj;
	}

	@Override
	public CoviList getMainResourceMenuList(CoviMap params) throws Exception {
		String objectInStr = eventSvc.getACLFolderData(SessionHelper.getSession(), "Resource", "V");	//View
		params.put("FolderIDs", objectInStr);
		params.put("FolderIDArr", objectInStr.replaceAll("\'", "").replaceAll("\\(", "").replaceAll("\\)", "").split(","));
		
		CoviList list = coviMapperOne.list("user.resource.selectMainResourceList", params);
		CoviList mainResourceList = CoviSelectSet.coviSelectJSON(list, "FolderID");
		
		return mainResourceList;
	}
	
	// 자원 데이터 트리 구조에 맞는 데이터 조회
	@Override
	public CoviList getResourceTreeList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		CoviList returnList = new CoviList();
		
		String objectInStr = eventSvc.getACLFolderData(SessionHelper.getSession(), "Resource", "V");	//View
		
		params.put("FolderIDs", objectInStr);
		params.put("FolderIDArr", objectInStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
		params.put("isSaaS", isSaaS);
		
		CoviList list = coviMapperOne.list("user.resource.selectResourceTreeList", params);
		
		String rootFolderIDs = ";";
		for (int i=0; i < list.size(); i++){
			CoviMap root = (CoviMap)list.get(i);
			if (root.getString("FolderType").equals("Root")){
				rootFolderIDs += root.getString("FolderID")+";";		
				list.remove(i);
			}
		}
		
		CoviList resourceList = CoviSelectSet.coviSelectJSON(list, "FolderID,FolderType,DomainID,MultiDisplayName,MemberOf,SortPath,BookingType,SecurityLevel");
		
		for(Object resource : resourceList){
			CoviMap resourceObj = (CoviMap) resource;
			String memberOf = (rootFolderIDs.indexOf(resourceObj.getString("MemberOf")) > -1) ? "0" : resourceObj.getString("MemberOf");
			// 트리를 그리기 위한 데이터
			//resourceObj.put("no", StringUtil.getSortNo(resourceObj.getString("SortPath")));
			resourceObj.put("no", resourceObj.getString("FolderID"));
			resourceObj.put("nodeName", DicHelper.getDicInfo(resourceObj.getString("MultiDisplayName"),lang));
			resourceObj.put("nodeValue", resourceObj.get("FolderID"));
			//resourceObj.put("pno", StringUtil.getParentSortNo(resourceObj.getString("SortPath")));
			//resourceObj.put("pno", resourceObj.getString("MemberOf"));
			resourceObj.put("pno", memberOf);
			
			if(resourceObj.getString("FolderType").startsWith("Resource")){
				resourceObj.put("rdo", "Y");
			}else{
				resourceObj.put("type", "folder");
				resourceObj.put("rdo", "N");
			}
			
			resourceObj.put("chk", "N");
			resourceObj.put("url", "#");
			
			returnList.add(resourceObj);
		}
		
		return returnList;
	}
	
	@Override
	public CoviList getUserFormOptionData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.resource.selectUserFormData", params);
		
		CoviList returnArr = new CoviList();
		CoviList userFormArr =  coviSelectJSONForResourceList(list, "UserFormID,FolderID,SortKey,MultiFieldName,FieldType,FieldInputLimit,IsList,IsOption");
		
		for(Object obj : userFormArr){
			CoviMap userFormObj = (CoviMap) obj;
			
			if(userFormObj.getString("IsOption").equalsIgnoreCase("Y")){
				params.put("userFormID", userFormObj.getString("UserFormID"));
				
				CoviList list2 = coviMapperOne.list("admin.resource.selectUserDefFieldOptionList", params);
				CoviList userFormOptionArr =  coviSelectJSONForResourceList(list2, "OptionID,UserFormID,FolderID,SortKey,MultiOptionName,OptionValue");
				
				userFormObj.put("OptionList", userFormOptionArr);
			}
			returnArr.add(userFormObj);
		}
		
		return returnArr;
	}

	@Override
	public CoviList selectLeftCalendarEvent(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.resource.selectLeftCalendarEvent", params);
		
		return CoviSelectSet.coviSelectJSON(list, "StartEndDate,EventIDs");
	}
	
	@Override
	public void updateEventResourceBookingResID(CoviMap params) throws Exception{
		coviMapperOne.update("user.resource.updateEventResourceBookingResID", params);
	}
	
	public String createMessageUrl(CoviMap params){
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();
		  
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");	
		}
		
		returnUrl += String.format("/%s/%s/%s?","groupware", "layout", "resource_View.do");	// {Domain}/groupware/layout/resource_View.do
		returnUrl += "?CLSYS=resource&CLMD=user&CLBIZ=resource&viewType=D";
		return returnUrl;
	}	
	
	// 자원미리 알림 보내기
	private void sendResourceReminderAlarm(CoviMap params) throws Exception{
		//DateHelper.diffMinute(endDateTime, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm"))
		CoviMap notificationObj = CoviMap.fromObject(params.getString("notificationObj"));
		String startDate = params.getString("startDate");
		String startTime = params.getString("startTime");
		
		int remiderTime = notificationObj.getInt("ReminderTime");
		
		String reservedDate = DateHelper.getAddDate(startDate + " " + startTime, "yyyy-MM-dd HH:mm", (-1*remiderTime), Calendar.MINUTE);
				
		if(DateHelper.diffMinute(reservedDate, DateHelper.getCurrentDay("yyyy-MM-dd HH:mm")) >=0){ //발송 시간이 지나지 않은 항목만 발송
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
				
				String mobileAlarmUrl = "/groupware/mobile/resource/view.do" 
						+ "?eventid=" + eventID	+ "&dateid=" + dateID	+ "&repeatid=" + repeatID	+ "&isrepeat=" + isRepeat	+ "&resourceid=" + folderID;
				
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
	@Override
	public void sendMessage(CoviMap resourceParam , String type) throws Exception{
		String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
				+ "&eventID=" +  resourceParam.getString("EventID") 
				+ "&dateID=" + resourceParam.getString("DateID") 
				+ "&repeatID=" + resourceParam.getString("RepeatID") 
				+ "&isRepeat=" + resourceParam.getString("IsRepeat") 
				+ "&resourceID=" + resourceParam.getString("ResourceID")
				+ "&isRepeatAll=" + ( resourceParam.containsKey("IsRepeatAll") ? resourceParam.getString("IsRepeatAll") : "N" );
		
		String mobileAlarmUrl = "/groupware/mobile/resource/view.do" 
				+ "?eventid=" + resourceParam.getString("EventID")
				+ "&dateid=" + resourceParam.getString("DateID") 
				+ "&repeatid=" + resourceParam.getString("RepeatID") 
				+ "&isrepeat=" + resourceParam.getString("IsRepeat") 
				+ "&resourceid=" + resourceParam.getString("ResourceID");
				
		CoviMap notiParams = new CoviMap();
		notiParams.put("ServiceType", "Resource"); 
		notiParams.put("ReceiverText",(resourceParam.get("ReceiverText") == null?resourceParam.getString("Subject"):resourceParam.getString("ReceiverText")));
		notiParams.put("MessagingSubject", resourceParam.getString("Subject"));
		notiParams.put("SenderCode", resourceParam.getString("SenderCode"));
		notiParams.put("RegisterCode", resourceParam.getString("SenderCode"));
		notiParams.put("ReceiversCode", resourceParam.getString("ReceiversCode"));
		notiParams.put("GotoURL",  alarmUrl);
		notiParams.put("PopupURL",  alarmUrl);
		notiParams.put("MobileURL",  mobileAlarmUrl);
		notiParams.put("MsgType", type+"_Resource");
		notiParams.put("MessageContext", resourceParam.getString("MessageContext"));
		notiParams.put("ReservedStr4", resourceParam.getString("ReservedStr4"));
		
		/*
		switch(type){
		case "BookingCancel": // 예약취소
			notiParams.put("MsgType", "BookingCancel_Resource");
			break;
		case "BookingReject": // 예약거부
			notiParams.put("MsgType", "BookingReject_Resource");
			break;
		case "ReturnRequest": //반납요청
			notiParams.put("MsgType", "ReturnRequest_Resource");
			break;
		case "ApprovalCancel": //신청철회
			notiParams.put("MsgType", "ApprovalCancel_Resource");
			break;
		case "BookingRequest": //예약신청
			notiParams.put("MsgType", "BookingRequest_Resource");
			break;
		case "ReturnComplete": //반납완료
			notiParams.put("MsgType", "ReturnComplete_Resource");
			break;
		case "ApprovalRequest": //승인요청
			notiParams.put("MsgType", "ApprovalRequest_Resource");
			break;
		case "BookingComplete": //예약완료
			notiParams.put("MsgType", "BookingComplete_Resource");
			break;

		}*/
		
		eventSvc.sendNotificationMessage(notiParams);
	}
	
	// 예약시 파일첨부에 사용
	public void insertResourceSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		String uploadPath = params.getString("ServiceType") + File.separator;
		String orgPath = params.getString("ServiceType") + File.separator;

		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath, params.getString("ServiceType"), params.getString("ObjectID"), params.getString("ObjectType"), params.getString("MessageID"), "0");
	}
	
	// 예약수정 파일정보 수정
	public void updateResourceSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
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
	
	// 공용자원ID 검색.
    @Override
    public CoviList selectLinkFolderID(CoviMap params) throws Exception {
          CoviList list = coviMapperOne.list("user.resource.selectLinkFolderList", params);
          return CoviSelectSet.coviSelectJSON(list, "FolderID");
    }
    
    @Override
    public CoviList webpartSelectMeetingRoom(CoviMap params) throws Exception {
    	CoviList list = coviMapperOne.list("webpart.meeting.selectMeetingReservation", params);
    	
    	return CoviSelectSet.coviSelectJSON(list, "StartDate,StartTime,EndDate,EndTime");
    }
    
}
