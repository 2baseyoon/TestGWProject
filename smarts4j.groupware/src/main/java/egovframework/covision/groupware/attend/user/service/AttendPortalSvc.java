package egovframework.covision.groupware.attend.user.service;



import egovframework.baseframework.data.CoviMap;

import java.util.List;
import java.util.Map;

public interface AttendPortalSvc {
	CoviMap getUserPortal(CoviMap params) throws Exception;
	CoviMap getUserPortalDay(CoviMap params) throws Exception;
	CoviMap getManagerPortalDay(CoviMap params, boolean bCompanyToday, boolean bCompanyDay, boolean bDeptDay, boolean bUserDay) throws Exception;
	CoviMap getDeptUserAttendList(CoviMap params) throws Exception;
	CoviMap getCallingTarget(CoviMap params) throws Exception;
	CoviMap sendCallingTarget(CoviMap params) throws Exception;
	CoviMap getUserStatus(CoviMap params) throws Exception;	
	CoviMap getAttendDataWebpart(CoviMap params) throws Exception;
	CoviMap getDeptAttStatusWebpart(CoviMap params) throws Exception;	
}