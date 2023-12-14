package egovframework.covision.groupware.attend.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

/**
 * @author bwkoo
 *
 */
public interface AttendLateStatusSvc {
	
	/**
	  * @Method Name : getLateAttendance
	  * @작성일 : 2021. 7. 23.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 개인별 지각현황
	  * @param params
	  * @return
	  */
	public CoviList getLateAttendance(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getLateAttendance
	  * @작성일 : 2021. 8. 3.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 월별 지각현황
	  * @param params
	  * @return
	  */
	public CoviList getMonthlyLateAttendance(CoviMap params) throws Exception;
	
}