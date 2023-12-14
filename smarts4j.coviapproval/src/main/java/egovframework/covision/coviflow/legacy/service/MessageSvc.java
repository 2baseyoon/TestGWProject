package egovframework.covision.coviflow.legacy.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface MessageSvc {
	public void callMessagingProcedure(CoviMap paramMap) throws Exception;	
	public CoviMap selectDomainData(CoviMap params) throws Exception;
	public String getSubjectData(CoviMap param) throws Exception;
	public CoviMap getTargetList(CoviMap params) throws Exception;
	public CoviMap getDistributionTargetList(CoviMap params) throws Exception;
	public CoviMap getFormData(CoviMap params) throws Exception;
	public int insertTimeLineData(CoviList params) throws Exception;
	public CoviMap getAlarmList(CoviMap params) throws Exception;
	public CoviMap getUser(CoviMap params) throws Exception;
	public void getApprovalList(CoviMap params) throws Exception;
	public Boolean checkHasSubProcess(String processId) throws Exception;
	public void sendAccessRequestMessage() throws Exception;
	CoviMap selectProcessDes(CoviMap params) throws Exception;
	String getTaskID(CoviMap param) throws Exception;
	public CoviMap getDicInfo(CoviMap params) throws Exception;
}
