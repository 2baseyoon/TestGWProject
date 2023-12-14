package egovframework.covision.groupware.webpart.service;

import egovframework.baseframework.data.CoviMap;

public interface OfficerAdminSvc {
	
	CoviMap getIsAdminUser(CoviMap params) throws Exception;
	CoviMap getOfficerList(CoviMap params) throws Exception;
	CoviMap getOfficerListAdmin(CoviMap params) throws Exception;
	CoviMap getOfficerTargetList(CoviMap params) throws Exception;
	int updateOfficerState(CoviMap params) throws Exception;
	int updateOfficerUse(CoviMap params) throws Exception;
	int deleteOfficer(CoviMap params) throws Exception;
	CoviMap moveofficersort(CoviMap params) throws Exception;
	CoviMap getIsDuplicate(CoviMap params) throws Exception;
	int addOfficer(CoviMap params) throws Exception;
	CoviMap getOfficerInfo(CoviMap params) throws Exception;
	int updateOfficerInfo(CoviMap params) throws Exception;
}
