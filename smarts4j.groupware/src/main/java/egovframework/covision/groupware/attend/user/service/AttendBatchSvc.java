package egovframework.covision.groupware.attend.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



/**
 * @author sjhan0418
 *
 */
public interface AttendBatchSvc {
	
	/**
	  * @Method Name : getDomainIdList
	  * @작성일 : 2020. 4. 20.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 외부시스템 연동 코드 리스트 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getDomainIdList(CoviMap params) throws Exception; 
	
	/**
	  * @Method Name : setAbsentData
	  * @작성일 : 2020. 4. 17.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 결근처리
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap setAbsentData(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getCommuteDataByOtherSystem
	  * @작성일 : 2020. 4. 20.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 외부 출퇴근 시스템 (secom /adt ) 출퇴근 기록 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getCommuteDataByOtherSystem(CoviMap params) throws Exception;
	public CoviMap autoCreateScheduleJob(CoviMap params) throws Exception;
	public CoviList excuteAttendNotifyPush(CoviMap params) throws Exception;
	public int attendAlarmSendMessages(CoviMap params) throws Exception;

	public int setRewardVacationData(CoviMap params) throws Exception;

		
}