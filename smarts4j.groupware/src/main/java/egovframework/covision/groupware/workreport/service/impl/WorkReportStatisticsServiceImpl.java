package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.workreport.service.WorkReportStatisticsService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WorkReportStatisticsService")
public class WorkReportStatisticsServiceImpl extends EgovAbstractServiceImpl implements WorkReportStatisticsService{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getPeroidProject(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.selectPeroidProject", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "YEAR,MONTH,WorkDay"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getProjectList(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.selectProjectList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "JobID,JobName,StartDate,EndDate"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getStatisticsProject(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.selectStatisticsProject", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ORDERNO,GradeKind,GradeSeq,UR_Code,DeptName,DeptCode,MemberType,UserName,JobPositionCode,JobPositionName,WorkReportID,InputDate,SUMMM,"+params.getString("smonths")));
		
		return resultList;
	}

	@Override
	public CoviMap getJobTypeList(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.selectTypeByTeam", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "TypeCode,DisplayName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getSumHourList(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.selectHourByTeam", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	@Override
	public CoviMap getTeamList(CoviMap params) throws Exception {	
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		list = coviMapperOne.list("groupware.admin.workreport.selectTeamList", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	@Override
	public CoviList selectProjectTime(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectProjectTime", params)
				,"YearMonth,UR_Code,UR_Name,GradeKind,MonthPrice,MemberType,JobID,WorkTime,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31");
	}

}

