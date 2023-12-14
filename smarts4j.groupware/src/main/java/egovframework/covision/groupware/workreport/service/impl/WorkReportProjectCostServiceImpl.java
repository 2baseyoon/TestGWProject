package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.workreport.service.WorkReportProjectCostService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("WorkReportProjectCostService")
public class WorkReportProjectCostServiceImpl extends EgovAbstractServiceImpl implements WorkReportProjectCostService{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectManageProject(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectManageProject", params)
				, "JobID,JobName,StartDate,EndDate");
	}
	
	
	@Override
	public CoviList selectProjectCost(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectProjectCost", params)
				, "YearMonth,UR_Code,UR_Name,GradeKind,MonthPrice,MemberType,JobID,SumStandardHour,WorkDay,ManMonth,ManPrice,OverTime,OverTimeManMonth,OverTimeManHour,OverTimeManPrice,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31");
	}
	
	@Override
	public CoviList selectProjectCostOS(CoviMap params) throws Exception {
		return  CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectProjectCostOS", params)
				, "YearMonth,UR_Code,Name,GradeKind,MonthPrice,MemberType,JobID,SumStandardHour,WorkDay,ManMonth,ManPrice");
	}
}
