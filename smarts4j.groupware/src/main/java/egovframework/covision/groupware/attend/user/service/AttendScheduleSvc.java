package egovframework.covision.groupware.attend.user.service;


import egovframework.baseframework.data.CoviMap;

import java.util.List;

public interface AttendScheduleSvc {
	
	public CoviMap getAttendScheduleList(CoviMap params) throws Exception;
	public CoviMap getAttendScheduleDetail(CoviMap params) throws Exception;
	
	public int addAttendSchedule (CoviMap params) throws Exception;
	public int saveAttendSchedule  (CoviMap params) throws Exception;
	public int deleteAttendSchedule  (List paramsList) throws Exception;
	
	public int updateAttendScheduleBase  (CoviMap params) throws Exception;
	public int updateAttendScheduleValid  (CoviMap params) throws Exception;
	
	public CoviMap getSchMemberInfo(CoviMap params) throws Exception;
	public void setSchMemberInfo(CoviMap params)throws Exception;
	public void delSchMemberInfo(CoviMap params)throws Exception;
	
	public CoviMap getSchAllocInfo(CoviMap params) throws Exception;
	public int setSchAllocInfo(List params)throws Exception;
	public int delSchAllocInfo(List params)throws Exception;
	
	public CoviMap uploadExcel(CoviMap params) throws Exception;

	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception;
	public List<CoviMap> getAddWorkPlaceList(CoviMap params) throws Exception;
	public void insertAttSchWorkPlace(CoviMap params) throws Exception;
	public void deleteAttSchWorkPlace(CoviMap params) throws Exception;

}