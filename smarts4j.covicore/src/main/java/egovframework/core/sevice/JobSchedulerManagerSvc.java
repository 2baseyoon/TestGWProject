package egovframework.core.sevice;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface JobSchedulerManagerSvc {
	
	// 스케줄링 작업 관리
	public CoviMap getJobSchedulerList(CoviMap params) throws Exception;
	public CoviMap getJobSchedulerData(CoviMap params) throws Exception;
	public CoviMap insertJobScheduler(CoviMap params) throws Exception;
	public int updateJobScheduler(CoviMap params) throws Exception;
	public int deleteJobScheduler(CoviMap params) throws Exception;
	public int changeIsUseJobScheduler(CoviMap params) throws Exception;
	
	// 스케쥴 템플릿 관리
	public CoviMap getJobSchedulerEventList(CoviMap params) throws Exception;
	public CoviMap getJobSchedulerEventData(CoviMap params) throws Exception;
	public CoviMap insertJobSchedulerEvent(CoviMap params) throws Exception;
	public int updateJobSchedulerEvent(CoviMap params) throws Exception;
	public CoviList getJobSchedulerEventJobList(CoviMap params) throws Exception;
	public int deleteJobSchedulerEvent(CoviMap params) throws Exception;
	
	public CoviMap getJobSchedulerEventJob(CoviMap params) throws Exception;
	public int insertJobSchedulerEventJob(CoviMap params) throws Exception;
	
	// 스케줄링 작업 로그
	public CoviMap getJobLogList(CoviMap params) throws Exception;
	public int deleteJobLog(CoviMap params) throws Exception;
	

	
	/* 서비스 Agent 관리	
	public CoviMap getJobAgentList(CoviMap params) throws Exception;
	public CoviMap getJobAgentData(CoviMap params) throws Exception;
	public int changeIsUseAgentServer(CoviMap params) throws Exception;
	public int changeIsClusterAgentServer(CoviMap params) throws Exception;
	public int insertAgentServer(CoviMap params) throws Exception;
	public int updateAgentServer(CoviMap params) throws Exception;
	public int deleteAgentServer(CoviMap params) throws Exception;
	
	// 작업 클러스터 관리
	public CoviMap getJobClusterList(CoviMap params) throws Exception;
	public CoviMap getJobClusterData(CoviMap params) throws Exception;
	public int insertJobCluster(CoviMap params) throws Exception;
	public int insertJobClustered(CoviMap params) throws Exception;
	public int updateJobCluster(CoviMap params) throws Exception;
	public int deleteJobCluster(CoviMap params) throws Exception;
	*/
	
}
