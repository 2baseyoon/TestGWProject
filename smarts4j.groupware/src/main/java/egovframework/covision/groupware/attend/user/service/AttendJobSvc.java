package egovframework.covision.groupware.attend.user.service;

import egovframework.baseframework.data.CoviMap;

import java.util.List;

public interface AttendJobSvc {
	
	public CoviMap createAttendScheduleJob(CoviMap params, List objList) throws Exception;
	public CoviMap createAttendScheduleJobDiv(CoviMap params, List trgUsers, List trgDates) throws Exception;
	public CoviMap copyAttendScheduleJob(CoviMap params, List trgUsers, List trgDates) throws Exception;
	public CoviMap reapplyAttendScheduleJob(CoviMap params) throws Exception;
	public CoviMap reapplyAttendHolidayJob(CoviMap params) throws Exception;
	
	public CoviMap getAttendJobDay(CoviMap params) throws Exception;
	public CoviMap getAttendJobWeek(CoviMap params) throws Exception;
	public CoviMap getAttendJobMonth(CoviMap params) throws Exception;
	public CoviMap getAttendJobList(CoviMap params) throws Exception;
	
	public CoviMap getAttendDetail(CoviMap params) throws Exception;
	public int saveAttendJob(CoviMap params) throws Exception;
	public int delAttendJob(List params) throws Exception;
	public int confirmAttendJob(List params, String confirmYn) throws Exception;
	
	public CoviMap uploadExcel(CoviMap params) throws Exception;

	public CoviMap getAttendJobViewDay(CoviMap params) throws Exception;
	public CoviMap getAttendJobViewWeek(CoviMap params) throws Exception;
	public CoviMap getAttendJobViewMonth(CoviMap params) throws Exception;
	public CoviMap getAttendJobViewMonthlyInfo(CoviMap params) throws Exception;

	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception;

}