package egovframework.covision.groupware.workreport.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WorkReportProjectCostService {
	public CoviList selectManageProject(CoviMap params) throws Exception;
	public CoviList selectProjectCost(CoviMap params) throws Exception;
	public CoviList selectProjectCostOS(CoviMap params) throws Exception;
}
