package egovframework.covision.groupware.resource.user.service;




import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface ResourceSvc {
	
	public CoviList selectACLData(CoviMap params) throws Exception;

	public CoviMap getBookingList(CoviMap params) throws Exception;

	public CoviMap getBookingPeriodList(CoviMap params) throws Exception;

	public CoviMap getBookingData(CoviMap params) throws Exception;

	public CoviMap getResourceData(CoviMap params) throws Exception;

	public CoviMap modifyBookingState(CoviMap params) throws Exception; //단일 업데이트 dateID 기준

	public CoviMap modifyAllBookingState(CoviMap params) throws Exception; //다중 업데이트 eventID, resourceID 기준

	public CoviMap saveBookingData(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;

	public CoviMap modifyBookingData(CoviMap dataObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;

	public CoviMap check(CoviMap dataObj) throws Exception;

	public CoviList checkTime(CoviMap dataObj) throws Exception;
	
	public CoviList getCheckTime(CoviMap params) throws Exception;
	
	public CoviList getCheckedList(CoviMap params) throws Exception;

	public CoviMap checkResource(CoviMap params) throws Exception;
	
	public CoviList getResourceList(CoviMap params) throws Exception;

	public CoviList getFolderTreeData(CoviMap params) throws Exception;

	public CoviMap getManageInfo() throws Exception;

	public CoviList getMainResourceMenuList(CoviMap params) throws Exception;

	public CoviList getResourceTreeList(CoviMap params) throws Exception;
	
	public CoviList getUserFormOptionData(CoviMap params) throws Exception;
	
	public CoviMap checkDuplicateTime(String folderID, CoviMap eventDateObj) throws Exception;
	
	public CoviMap checkDuplicateTime(String folderID, String dateID, String eventID, CoviMap eventDateObj , CoviMap repeatObj) throws Exception;
	
	public CoviMap checkRedisDuplicateTime(String folderID, CoviMap eventDateObj , CoviMap repeatObj) throws Exception;
	
	public int checkResourceApv(String folderID) throws Exception;

	public CoviList selectLeftCalendarEvent(CoviMap params) throws Exception;

	public CoviMap setEachSchedule(CoviMap eventObj, CoviMap fileInfos, List<MultipartFile> mf, String isChangeDate, String isChangeRes) throws Exception;

	void updateEventResourceBookingResID(CoviMap params) throws Exception;

	void sendMessage(CoviMap resourceParam, String type) throws Exception;
	
	void insertResEventAttendant(CoviMap params) throws Exception;				//참석자 추가 로직 추가.

	public CoviList selectResEventAttendant(CoviMap params) throws Exception;	//참석자 조회 로직 추가.

	void deleteEventAttendant(CoviMap params) throws Exception;			//자원예약에서 참석자 정보 수정되었을 경우 기존 저장 데이터 삭제.

	void deleteEventByAttendeeData(CoviMap params) throws Exception;	//자원예약에서 참석자 정보 수정되었을 경우 기존 저장 데이터 삭제.

	void insertEventAttendant(CoviMap params) throws Exception;			//자원예약에서 참석자 정보 수정되었을 경우 기존 저장 데이터 삭제.
	
	public CoviList selectLinkFolderID(CoviMap params) throws Exception; 		// 공유자원 검색
	
	public CoviList webpartSelectMeetingRoom(CoviMap params) throws Exception;
}