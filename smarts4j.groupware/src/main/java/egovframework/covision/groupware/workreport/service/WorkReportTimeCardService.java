package egovframework.covision.groupware.workreport.service;

import java.util.ArrayList;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WorkReportTimeCardService {
	public int chkDuplicateCalendar(CoviMap params) throws Exception;
	public int insertCalendar(CoviMap params) throws Exception;
	public CoviMap selectCalendarInfo(CoviMap params) throws Exception;
	public CoviMap selectCalendarBeforeAndNextInfo(CoviMap params) throws Exception;
	public CoviMap selectCalendarDateInfo(CoviMap params) throws Exception;
	public CoviMap getGrade(CoviMap params) throws Exception;
	public int insertWorkReport(CoviMap base, ArrayList<CoviMap> timesheets) throws Exception;
	public CoviMap getBaseReport(CoviMap params) throws Exception;
	public CoviList getTimeSheetReport(CoviMap params) throws Exception;
	public CoviMap getWorkReportIdAndStateByCalAndUser(CoviMap params) throws Exception;
	public void updateWorkReport(CoviMap base, ArrayList<CoviMap> timesheets, ArrayList<CoviMap> reducesheets) throws Exception;
	public void initApprovalWorkreport(CoviMap obj) throws Exception;
	public CoviList getManageUsers(CoviMap params) throws Exception;
	public int chkIsManagerByUserCode(CoviMap params) throws Exception;
	public CoviMap selectWorkReportMyList(CoviMap params) throws Exception;
	public int reportWorkReport(CoviMap params) throws Exception;
	public int collectWorkReport(CoviMap params) throws Exception;
	public CoviList getTeamMembers(CoviMap params) throws Exception;
	public CoviList getApprovalTargets(CoviMap params) throws Exception;	
	public CoviMap selectWorkReportTeamList(CoviMap params) throws Exception;
	public CoviMap approvalWorkReport(CoviMap params) throws Exception;
	public CoviMap rejectWorkReport(CoviMap params) throws Exception;
	public String selectTeamManagerByUid(CoviMap params) throws Exception;
	public CoviMap getLastWeekPlan(CoviMap parmas) throws Exception;
}
