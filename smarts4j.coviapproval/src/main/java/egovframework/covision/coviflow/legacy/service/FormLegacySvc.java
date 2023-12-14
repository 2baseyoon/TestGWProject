package egovframework.covision.coviflow.legacy.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface FormLegacySvc {
	
	public CoviList getActivitiVariables(String taskId) throws Exception;
	public CoviMap convertNullJSON(CoviMap paramObj) throws Exception;
	public CoviList convertNullJSON(CoviList paramArr) throws Exception;
	public CoviMap doAction(CoviMap params) throws Exception;
	public void writeLog(CoviMap logMap) throws Exception;
	
}
