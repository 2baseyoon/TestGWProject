package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.attend.user.service.AttendHolidayStatusSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AttendHolidayStatus")
public class AttendHolidayStatusSvcImpl extends EgovAbstractServiceImpl implements AttendHolidayStatusSvc {

	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviList getHolidayAttendance(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getHolidayAttendance", params);		
		return resultList;
	}
	
	@Override
	public String getUserDayOffDate(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("attend.status.getUserDayOff", params);
	}
}