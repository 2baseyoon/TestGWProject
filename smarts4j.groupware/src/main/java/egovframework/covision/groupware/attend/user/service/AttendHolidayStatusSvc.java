package egovframework.covision.groupware.attend.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

/**
 * @author bwkoo
 *
 */
public interface AttendHolidayStatusSvc {
	
	/**
	  * @Method Name : getHolidayAttendance
	  * @작성일 : 2021. 7. 21.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴일 근무자 현황
	  * @param params
	  * @return
	  */
	public CoviList getHolidayAttendance(CoviMap params) throws Exception;
	public String getUserDayOffDate(CoviMap params) throws Exception; // user에 설정된 휴일 조회
}