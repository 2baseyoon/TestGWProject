package egovframework.covision.groupware.workreport.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WorkReportStatisticsService {
	CoviMap getPeroidProject(CoviMap params) throws Exception;
	CoviMap getProjectList(CoviMap params) throws Exception;
	CoviMap getStatisticsProject(CoviMap params) throws Exception;
	CoviMap getJobTypeList(CoviMap params) throws Exception;
	CoviMap getSumHourList(CoviMap params) throws Exception;
	CoviMap getTeamList(CoviMap params) throws Exception;
	public CoviList selectProjectTime(CoviMap params) throws Exception;
}
