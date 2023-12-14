package egovframework.covision.groupware.attend.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import java.util.List;

public interface AttendReqSvc {
	
	public CoviMap requestOverTime(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap requestHolidayWork(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap requestJobStatus(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap getVacationInfo(CoviMap params) throws Exception;
	public CoviMap getVacationInfoV2(CoviMap params) throws Exception;
	public CoviMap requestVacation(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap requestCall(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap requestSchedule(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	public CoviMap requestScheduleRepeat(CoviMap params, List ReqData, String ReqStatus) throws Exception;
	
	public CoviMap addCustomSchedule(CoviMap params) throws Exception;
	
	public CoviMap approvalAttendRequest(CoviMap reqMap,List params) throws Exception;
	public CoviMap changeAttendRequestStatus(CoviMap reqMap,List params) throws Exception;
	public CoviMap deleteAttendRequest(CoviMap reqMap,List params) throws Exception;
	public CoviMap approvalAttendEApproval(CoviMap reqMap,List params) throws Exception;
	public CoviMap approvalAttendPApproval(CoviMap reqMap,List params) throws Exception;
	public CoviList getTargetUserList(List TargetData);
	public int getUsedVacationListCnt(CoviMap params) throws Exception;
	public CoviMap getUsedVacationList(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : requestCommute
	  * @작성일 : 2020. 5. 22.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근무지 외 출 퇴근 요청 관리
	  * @param params
	  * @param reqData
	  * @return
	  * @throws Exception
	  */
	public CoviMap requestCommute(CoviMap params, CoviMap reqData) throws Exception;
	
	/**
	  * @Method Name : saveCommute
	  * @작성일 : 2020. 5. 22.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근무지 외 출 퇴근 요청 저장
	  * @param reqType
	  * @param reqGubun
	  * @param coviData
	  * @param ReqData
	  * @return
	  * @throws Exception
	  */
	public CoviMap saveCommute(String reqType, String reqGubun, CoviMap coviData, List  ReqData) throws Exception;
}