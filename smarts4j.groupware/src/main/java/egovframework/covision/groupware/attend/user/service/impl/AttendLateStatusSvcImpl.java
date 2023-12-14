package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.attend.user.service.AttendLateStatusSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AttendLateStatus")
public class AttendLateStatusSvcImpl extends EgovAbstractServiceImpl implements AttendLateStatusSvc {

	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	  * @Method Name : getLateAttendance
	  * @작성일 : 2021. 7. 23.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 개인별 지각현황
	  * @param params
	  * @return
	  */
	@Override
	public CoviList getLateAttendance(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getLateAttendance", params);		
		return resultList;
	}
	
	/**
	  * @Method Name : getLateAttendance
	  * @작성일 : 2021. 8. 3.
	  * @작성자 : bwkoo
	  * @변경이력 : 
	  * @Method 설명 : 관리자 근태관리 - 월별 지각현황
	  * @param params
	  * @return
	  */
	@Override
	public CoviList getMonthlyLateAttendance(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getMonthlyLateAttendance", params);		
		return resultList;
	}

}
 