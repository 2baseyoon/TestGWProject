package egovframework.covision.coviflow.legacy.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface FormCmmFunctionSvc {

	CoviMap getFormInstAll(CoviMap params) throws Exception;
	
	CoviMap getFormInstData(CoviMap params) throws Exception;
	
	String getDomainID(CoviMap params) throws Exception;

	void execWF_FORM_DRAFT_License(CoviMap spParams) throws Exception;

	CoviMap getGovUsingStamp(CoviMap params)throws Exception;

	String getBodyContextData(CoviMap bCParams);
	
	CoviMap getVacationData(CoviMap params)throws Exception;
	
	void execWF_FORM_VACATION_REQUEST(CoviMap spParams) throws Exception;
	
	void execWF_FORM_VACATION_CANCEL(CoviMap spParams) throws Exception;

	CoviList getFormBaseOS(CoviMap params) throws Exception;	
	
	CoviList getVacationInfo(CoviMap params) throws Exception;
	CoviMap getVacationProcessInfo(CoviMap params) throws Exception;
	
	CoviMap setApvStatus(CoviMap params) throws Exception;

	CoviMap saveCapitalResolution(CoviMap params) throws Exception;
	
	CoviMap createCapitalReportInfo(CoviMap params) throws Exception;
	
	CoviMap saveBizTripRequestInfo(CoviMap params) throws Exception;
	
	void execWF_EXTERNAL_ACCESS_REQ(CoviMap spParams) throws Exception;
	
	CoviMap callOtherService(String params, String bodyContext, String DN_Code) throws Exception;
	
	void execAttendance(CoviMap spParams) throws Exception;
	
	void execCall(CoviMap spParams) throws Exception;
	
	CoviList attendanceHolidayCheck(CoviMap params) throws Exception; 
	
	CoviList attendanceWorkTimeCheck(CoviMap params) throws Exception; 
	
	CoviMap attendanceWorkTimeCheckOne(CoviMap params) throws Exception;
	
	String attendanceHolidayCheckOne(CoviMap params) throws Exception;
	
	void execBizUpdateStatus(CoviMap spParams) throws Exception;
	
	void execCrmUpdateStatus(CoviMap spParams) throws Exception;

	void execEAccountInsertProjectCode(CoviMap spParams) throws Exception;

	CoviMap execWF_FORM_BIZMNT_PROJECTCODE(CoviMap spParams) throws Exception; 
	
	String attendanceCommuteTime(CoviMap params) throws Exception; 
	
	CoviMap getBaseCodeList(CoviMap spParams) throws Exception;
	
	void execAttendRequest(CoviMap spParams) throws Exception;

	CoviList getProjectName(CoviMap params) throws Exception;

	int attendDayJobCheck(CoviMap params) throws Exception;

	CoviList attendanceRealWorkInfo(CoviMap params) throws Exception;
	
	CoviMap execHrManage(String params, String bodyContext) throws Exception;

}
