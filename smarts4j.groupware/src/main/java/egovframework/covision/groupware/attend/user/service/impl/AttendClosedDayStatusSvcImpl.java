package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.attend.user.service.AttendClosedDayStatusSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AttendClosedDayStatus")
public class AttendClosedDayStatusSvcImpl extends EgovAbstractServiceImpl implements AttendClosedDayStatusSvc {

	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList getClosedDayHeader(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getClosedDayHeader", params);		
		return resultList;
	}

	@Override
	public CoviList getClosedDayAttendance(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getClosedDayAttendance", params);		
		return resultList;
	}
	
	@Override
	public CoviList getClosedDayPlan(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getClosedDayPlan", params);
		
		for(int i = 0; i < resultList.size(); i++) {
			if(resultList.get(i) == null) resultList.remove(i);
		}
		
		return resultList;
	}
	
	@Override
	public CoviList getClosedDayPlanStatus(CoviMap params) throws Exception {		
		CoviList resultList = coviMapperOne.list("attend.status.getClosedDayPlanStatus", params);		
		return resultList;
	}

}
 