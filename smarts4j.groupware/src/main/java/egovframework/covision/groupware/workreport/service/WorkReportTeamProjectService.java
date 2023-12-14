package egovframework.covision.groupware.workreport.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WorkReportTeamProjectService {
	public CoviList getWorkReportTeamProject(CoviMap params) throws Exception;
	public CoviList getWorkReportTeamProjectSummary(CoviMap params) throws Exception;
}
