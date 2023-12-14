package egovframework.covision.groupware.attend.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface AttendClosedDayStatusSvc {
	
	/**
	  * @Method Name : getClosedDayHeader
	  * @작성일 : 2021. 7. 27.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무자 현황 해더
	  * @param params
	  * @return
	  */
	public CoviList getClosedDayHeader(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getClosedDayAttendance
	  * @작성일 : 2021. 7. 27.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무자 현황
	  * @param params
	  * @return
	  */
	public CoviList getClosedDayAttendance(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getClosedDayPlan
	  * @작성일 : 2021. 7. 29.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무계획
	  * @param params
	  * @return
	  */
	public CoviList getClosedDayPlan(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getClosedDayPlanStatus
	  * @작성일 : 2021. 7. 29.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 휴무일 근무계획 (월 휴무계획 집계)
	  * @param params
	  * @return
	  */
	public CoviList getClosedDayPlanStatus(CoviMap params) throws Exception;
	
}