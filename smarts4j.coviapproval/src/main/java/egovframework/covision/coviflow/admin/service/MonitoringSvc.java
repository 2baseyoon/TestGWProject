package egovframework.covision.coviflow.admin.service;




import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface MonitoringSvc {
	public CoviList getFormInstance(String fiid) throws Exception;
	public int setFormInstance(CoviMap param) throws Exception;
	public int setDomainData(CoviMap param) throws Exception;
	public int setProcessStep(CoviMap param) throws Exception;
	public int setWorkitemData(CoviMap param) throws Exception;
	public int setDescriptionData(CoviMap param) throws Exception;
	public CoviMap getSuperAdminData(CoviMap param) throws Exception;
	public CoviList getProcessList(String fiid) throws Exception;
	public CoviMap getActivitiProcessDefinition() throws Exception;
	public CoviMap getActivitiProcessList(String processId) throws Exception;
	public CoviMap getActivitiTasks(String processId) throws Exception;
	public CoviList getActivitiVariables(String taskId) throws Exception;
	public CoviMap getActivitiVariable(String taskId, String name) throws Exception;
	public int setActivitiVariables(String taskId, CoviMap domainData) throws Exception;
	public int setActivitiVariable(String taskId, String name, String value) throws Exception;
	public CoviList getProcessDesc(String pdescId) throws Exception;
	public CoviList getWorkitem(String processId) throws Exception;
	public CoviList getDomaindata(String processId) throws Exception;
	public void updateFormInstDocNumber(String FormInstID) throws Exception;
	public void doAction(String taskId, CoviMap param) throws Exception;
	public CoviMap selectAbortInfo(CoviMap params) throws Exception;
	public CoviMap makeFormObj(String pFormInstID) throws Exception;
	public void abortProcessFormData(String pFormInstID, CoviMap pAppvLine, CoviList commentArray) throws Exception;
	public String getFormSchema(String pFormInstID) throws Exception;
	public int setIsComment(CoviMap param) throws Exception;
}
