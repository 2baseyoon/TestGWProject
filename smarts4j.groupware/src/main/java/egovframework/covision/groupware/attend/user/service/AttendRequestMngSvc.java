package egovframework.covision.groupware.attend.user.service;



import egovframework.baseframework.data.CoviMap;

public interface AttendRequestMngSvc {
	
	public CoviMap getAttendRequestList(CoviMap params) throws Exception;
	public CoviMap getAttendRequestDetail(CoviMap params) throws Exception;
	

}