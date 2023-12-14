package egovframework.covision.groupware.workreport.service;

import java.util.List;


import egovframework.baseframework.data.CoviMap;

public interface WorkReportGradeService {
	String insertOutSourcingGrade(CoviMap params) throws Exception;
	CoviMap selectOutSourcingGrade(CoviMap params) throws Exception;
	int deleteOutSourcingGrade(CoviMap params) throws Exception;
	int modifyOutSourcingGrade(List<CoviMap> paramList) throws Exception;
	int reuseOutSourcingGrade(CoviMap params) throws Exception;
	
	String insertRegularGrade(CoviMap params) throws Exception;
	CoviMap selectRegularGrade(CoviMap params) throws Exception;
	int reuseRegularGrade(CoviMap params) throws Exception;
	int deleteRegularGrade(CoviMap params) throws Exception;
	int modifyRegularGrade(List<CoviMap> paramList) throws Exception;
		
}

