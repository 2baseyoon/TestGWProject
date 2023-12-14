package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.JobSchedulerManagerSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("systemScheduleManagerService")
public class JobSchedulerManagerSvcImpl extends EgovAbstractServiceImpl implements JobSchedulerManagerSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	// 스케줄링 작업 관리
	@Override
	public CoviMap getJobSchedulerList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("jobscheduler.admin.selectJobSchedulerListcnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("jobscheduler.admin.selectJobSchedulerList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "JobID,JobTitle,Seq,ClusterID,JobType,IsUse,JobState,RepeatCnt,RepeatedCnt,AgentServer,ServiceAgent,LastState,LastRunTime,NextRunTime,RegistDate,RegisterCode,ScheduleID,ScheduleType,ScheduleTitle,ClusterName,Reserved1,Path,TimeOut,RetryCnt,Params,Method"));
		return resultList;
	}
	@Override
	public CoviMap getJobSchedulerData(CoviMap params) throws Exception {
		CoviMap data = coviMapperOne.select("jobscheduler.admin.selectJobSchedulerData", params);
		return data;
	}
	@Override
	public CoviMap insertJobScheduler(CoviMap params) throws Exception{
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			
			if(params.getString("StartDate").equals("0000-00-00 00:00:00")){
				params.put("StartDate", null);
			}
			
			if(params.getString("EndDate").equals("0000-00-00 00:00:00")){
				params.put("EndDate", null);
			}
		}	
		coviMapperOne.insert("jobscheduler.admin.insertJobScheduler", params);
		
		return params;
	}
		
	@Override
	public int updateJobScheduler(CoviMap params) throws Exception{
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			
			if(params.getString("StartDate").equals("0000-00-00 00:00:00"))
				params.put("StartDate", null);
			
			if(params.getString("EndDate").equals("0000-00-00 00:00:00"))
				params.put("EndDate", null);
		}

		return coviMapperOne.update("jobscheduler.admin.updateJobScheduler", params);
	}
	
	@Override
	public int deleteJobScheduler(CoviMap params) throws Exception{
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		return coviMapperOne.delete("jobscheduler.admin.deleteJobScheduler", params);
	}
	
	@Override
	public int changeIsUseJobScheduler(CoviMap params) throws Exception{
		return coviMapperOne.update("jobscheduler.admin.changeIsUseJobScheduler", params);
	}

	
	// 스케줄링 템플릿 작업 관리
	@Override
	public CoviMap getJobSchedulerEventList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("jobscheduler.admin.selectJobSchedulerEventListcnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("jobscheduler.admin.selectJobSchedulerEventList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		return resultList;
	}
	@Override
	public CoviMap getJobSchedulerEventData(CoviMap params) throws Exception {
		CoviMap cMap = coviMapperOne.selectOne ("jobscheduler.admin.selectJobSchedulerEventData", params);
		CoviMap resultList = new CoviMap();
		resultList.put("data", CoviSelectSet.coviSelectJSON(cMap));

		return resultList;
	}
	@Override
	public CoviMap insertJobSchedulerEvent(CoviMap params) throws Exception{
		coviMapperOne.insert("jobscheduler.admin.insertJobSchedulerEvent", params);
		
		return params;
	}
	@Override
	public int updateJobSchedulerEvent(CoviMap params) throws Exception{
		return coviMapperOne.update("jobscheduler.admin.updateJobSchedulerEvent", params);
	}	
		
	@Override
	public CoviList getJobSchedulerEventJobList(CoviMap params) throws Exception{
		return coviMapperOne.list("jobscheduler.admin.getJobSchedulerEventJobList", params);
	}	
	
	
	@Override
	public int deleteJobSchedulerEvent(CoviMap params) throws Exception{
		
		return coviMapperOne.delete("jobscheduler.admin.deleteJobSchedulerEvent", params);
	}
	
	@Override
	public int insertJobSchedulerEventJob(CoviMap params) throws Exception{
		return coviMapperOne.delete("jobscheduler.admin.insertJobSchedulerEventJob", params);
	}	
	
	// 작업 스케줄 로그 관리
	@Override
	public CoviMap getJobLogList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		//egovframework.baseframework.data.CoviMap page = new egovframework.baseframework.data.CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("jobscheduler.admin.selectJobLogListcnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("jobscheduler.admin.selectJobLogList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "HistoryID,JobID,JobTitle,ScheduleType,IsSuccess,RetryCnt,AgentServer,Message,ResultText,EventTime,EventDate"));
		resultList.put("page", page);
		return resultList;
	}
	@Override
	public int deleteJobLog(CoviMap params) throws Exception{
		return coviMapperOne.delete("jobscheduler.admin.delectJobLog", params);
	}
	
	// 스케줄링 작업 관리
	@Override
	public CoviMap getJobSchedulerEventJob(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("jobscheduler.admin.selectJobSchedulerEventJobcnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("jobscheduler.admin.selectJobSchedulerEventJob", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		return resultList;
	}
}
