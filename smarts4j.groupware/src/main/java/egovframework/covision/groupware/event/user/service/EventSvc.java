package egovframework.covision.groupware.event.user.service;

import java.util.Set;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface EventSvc {
	public String insertEvent(CoviMap params) throws Exception;
	public String insertEventRepeat(CoviMap params) throws Exception;
	public String insertEventDate(CoviMap params) throws Exception;
	public CoviList setEventRepeatDate(CoviMap repeatObj) throws Exception;
	public void insertEventResourceBooking(CoviMap params) throws Exception;
	public void insertEventRelation(CoviMap params) throws Exception;
	public void insertEventNotification(CoviMap params) throws Exception;
	public void deleteEventDateByDateID(CoviMap params) throws Exception;
	public void updateEventRepeat(CoviMap params) throws Exception;
	public CoviList selectResourceList(CoviMap params) throws Exception;
	public void deleteEventDateByEventID(CoviMap params) throws Exception;
	public void deleteEventResourceBooking(CoviMap params) throws Exception;
	public void deleteEventRelation(CoviMap params) throws Exception;
	public CoviMap selectNotificationByOne(CoviMap params) throws Exception;
	public void updateEvent(CoviMap params) throws Exception;
	public void deleteEventNotification(CoviMap params) throws Exception;
	public void updateEventNotification(CoviMap params) throws Exception;
	public void insertEventNotificationByRegister(CoviMap params) throws Exception;
	public  CoviMap selectEvent(CoviMap params) throws Exception;
	public  CoviMap selectEventDate(CoviMap params) throws Exception;
	public  CoviList selectEventDateAll(CoviMap params) throws Exception;
	public  CoviMap selectEventRepeat(CoviMap params) throws Exception;
	public  CoviList selectEventResource(CoviMap params) throws Exception;
	public  CoviMap selectEventNotification(CoviMap params) throws Exception;
	public CoviMap selectResourceData(CoviMap params) throws Exception;
	public String getACLFolderData(Set<String> authObjCodeSet, String aclValue) throws Exception;
	public String getACLFolderData(CoviMap userInfoObj, String serviceType, String aclValue) throws Exception;
	public CoviList selectNotificationComment(CoviMap params) throws Exception;
	public void sendNotificationMessage(CoviMap params) throws Exception;
	public void updateEachScheduleResource(CoviMap params) throws Exception;
	public void insertEachScheduleRelation(CoviMap params) throws Exception;
	public void deleteRelationByScheduleResourceID(CoviMap params) throws Exception;
	public void updateResourceRealEndDateTime(CoviMap params) throws Exception;
	public void updateEventRepeatDate(CoviMap params) throws Exception;
	public void updateMessagingCancelState(CoviMap params) throws Exception;
	public CoviList selectAnniversaryList(CoviMap params) throws Exception;
	public String[] getDateIDs(String eventID) throws Exception;
	public void updateArrMessagingCancelState(CoviMap params) throws Exception;
	public void deleteAllNotification(CoviMap params) throws Exception;
	public void modifyAllNotification(CoviMap params) throws Exception;
	public CoviList selectAttendee(CoviMap params) throws Exception;
	public CoviMap selectAttendRequest(CoviMap params) throws Exception;
}
