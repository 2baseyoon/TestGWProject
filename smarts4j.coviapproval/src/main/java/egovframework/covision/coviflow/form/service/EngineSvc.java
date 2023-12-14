package egovframework.covision.coviflow.form.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface EngineSvc {
	//결재 / 승인 요청
	public void requestComplete(String taskId, CoviList params) throws Exception;
	
	//기안 요청
	public int requestStart(String pdef, CoviList params) throws Exception;
	
	//취소 요청
	public void requestAbort(CoviMap formObj) throws Exception;
	
	//업데이트 요청
	public void requestUpdate() throws Exception;

	// 전역변수 업데이트 요청
	public void requestUpdateValue(String processID, String variableName, CoviMap params) throws Exception;
	
	// 전역변수 전체 조회
	public CoviList requestGetActivitiVariables(String taskID) throws Exception;
	// 전역변수 개별값 조회
	public String requestGetActivitiVariables(String taskID, String variableName) throws Exception;
}
