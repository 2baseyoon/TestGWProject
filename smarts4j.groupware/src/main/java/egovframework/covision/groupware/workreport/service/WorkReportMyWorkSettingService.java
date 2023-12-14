package egovframework.covision.groupware.workreport.service;


import egovframework.baseframework.data.CoviMap;

public interface WorkReportMyWorkSettingService {
	String setMyWorkList(CoviMap params) throws Exception;
	CoviMap selectMyWorkDivision(CoviMap params) throws Exception;
	//int deleteOutSourcingGrade(CoviMap params) throws Exception;
	CoviMap selectMyWorkProject(CoviMap params) throws Exception;
	CoviMap selectMyWorkMyJob(CoviMap params) throws Exception;
	CoviMap setMyJob(CoviMap params) throws Exception; 
	CoviMap selectCategory(CoviMap params) throws Exception;
	
}
