package egovframework.covision.groupware.schedule.user.service;




import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ScheduleSvc {


	public Object selectTreeSubMenu(CoviMap params) throws Exception;

	public CoviList selectTreeMenuTotal(CoviMap params) throws Exception;

	public CoviList selectTreeMenu(CoviMap params) throws Exception;
	
	public CoviList selectView(CoviMap params) throws Exception;
	
	public int selectViewCount(CoviMap params) throws Exception;

	public CoviMap getListViewDetail(CoviMap params) throws Exception;
	
	public CoviMap insertSchedule(CoviMap eventObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;

	public CoviMap updateSchedule(CoviMap eventObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;

	public CoviMap setEachSchedule(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf, String isChangeDate, String isChangeRes, Boolean isSchedule) throws Exception;

	public CoviMap getOneDetail(CoviMap dataObj) throws Exception;

	public CoviMap getOneSimple(CoviMap dataObj) throws Exception;

	public void deleteEvent(CoviMap params) throws Exception;
	
	public void insertEventAttendant(CoviMap params) throws Exception;
	
	public CoviList selectAttendee(CoviMap params) throws Exception;
	
	public void deleteEventAttendant(CoviMap params) throws Exception;
	
	public void deleteEventByAttendeeData(CoviMap params) throws Exception;
	
	public  CoviList selectEventAttendant(CoviMap params) throws Exception;

	public CoviList selectToday(CoviMap params) throws Exception;
	
	public CoviList selectThisMonth(CoviMap params) throws Exception;

	public CoviList selectAttendList(CoviMap params) throws Exception;

	public void approve(String mode, CoviMap params) throws Exception;
	
	public String checkAttendeeAuth(CoviMap params) throws Exception;
	
	public void updateAttendeeAllow(CoviMap params) throws Exception;
	
	public void insertAttendeePersonalSchedule(CoviMap params) throws Exception ;
	
	public int selectAttendeePersonalSchedule(CoviMap params) throws Exception;

	public CoviList selectTemplateList(CoviMap params) throws Exception;

	public CoviList selectThemeList(CoviMap params) throws Exception;

	public void deleteTheme(CoviMap params) throws Exception;

	public CoviMap updateDateDataByDragDrop(CoviMap params) throws Exception;
	
	public int selectDiffDate(CoviMap params) throws Exception;
	
	public int selectDiffTime(CoviMap params) throws Exception;
	
	public void updateEventDateForDate(CoviMap params) throws Exception;
	
	public void updateEventDateForTime(CoviMap params) throws Exception;
	
	public void updateEventDateForDateTime(CoviMap params) throws Exception;
	
	public CoviMap getStartEndTime(CoviMap params) throws Exception;

	public CoviMap updateDateDataByResize(CoviMap params) throws Exception;

	public CoviList selectACLData(CoviMap params) throws Exception;

	public void insertTemplateByEventID(CoviMap params) throws Exception;
	
	public String insertTempEvent(CoviMap params) throws Exception;
	
	public String insertTempEventDate(CoviMap params) throws Exception;
	
	public void insertSelectEventAttendant(CoviMap params) throws Exception;
	
	public void insertSelectEventRelation(CoviMap params) throws Exception;
	
	public void insertTempEventResourceBooking(CoviMap params) throws Exception;
	
	public void insertSelectEventNotification(CoviMap params) throws Exception;
	
	public void insertSelectEventNotificationA(CoviMap params) throws Exception;
	
	public CoviMap selectThemeOne(CoviMap params) throws Exception;

	public void updateShareMine(CoviMap params) throws Exception;

	public void deleteShareMine(CoviMap params) throws Exception;

	public CoviMap insertEventByTemplateDragDrop(CoviMap params) throws Exception;
	
	public String insertEventByTemp(CoviMap params) throws Exception;

	public String insertEventDateByTemp(CoviMap params) throws Exception;
	
	public void insertEventResourceBookingByTemp(CoviMap params) throws Exception;

	public void deleteEventNotificationA(CoviMap params) throws Exception;
	
	public CoviMap selectGoogleInfo(CoviMap params) throws Exception;

	public CoviList selectSubscriptionFolderList(CoviMap params) throws Exception;

	public CoviList selectMyInfoProfileScheduleData(CoviMap params) throws Exception;

	public CoviList selectMyScheduleData(CoviMap params) throws Exception;

	public CoviList selectLeftCalendarEvent(CoviMap params) throws Exception;
	
	public CoviMap getWebpartScheduleList(CoviMap params) throws Exception;

	void deleteEventRepeatByDate(CoviMap params) throws Exception;

	public  CoviList selectEventNotificationList(CoviMap params) throws Exception;

	public void updateEachNotification(CoviMap params) throws Exception;
	
	public CoviMap selectSchUserFolderSetting(CoviMap params) throws Exception;
	
	public CoviMap saveSchUserFolderSetting(CoviMap params) throws Exception;
	
	public String getScheduleDateID(CoviMap params) throws Exception;
}
