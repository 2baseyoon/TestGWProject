package egovframework.covision.groupware.workreport.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WorkReportOSManageService {
	
	CoviMap selectOutSourcing(CoviMap params) throws Exception;
	CoviMap selectOutSourcingManage(CoviMap params) throws Exception;
	CoviMap setOutSourcing(CoviMap params) throws Exception;
	CoviMap selectOSGrade(CoviMap params) throws Exception;
	CoviMap selectOurSourcingDetail(CoviMap params) throws Exception;
	int deleteOutSourcing(CoviMap params) throws Exception;
	CoviList selectOSCalendarInfo(CoviMap params) throws Exception;
}

