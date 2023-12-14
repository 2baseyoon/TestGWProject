package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.workreport.service.WorkReportTeamProjectService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("WorkReportTeamProjectService")
public class WorkReportTeamProjectServiceImpl extends EgovAbstractServiceImpl implements WorkReportTeamProjectService{
	
	@Resource(name="coviMapperOne")
	public CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList getWorkReportTeamProject(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectTeamProject", params),
				"UR_Code,GR_Code,UR_Name,JobPositionName,MonthHour,TotalHour,JobName,JobID");
	}
	
	@Override
	public CoviList getWorkReportTeamProjectSummary(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectTeamProjectSummary", params),
				"MonthHour,TotalHour,JobName,JobID");
	}
}
