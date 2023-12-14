package egovframework.covision.coviflow.form.service;

import egovframework.baseframework.data.CoviMap;

public interface InstMgrSvc {
	//기안 회수/취소
	public void doAbort(CoviMap formObj) throws Exception;
	
	//승인 취소
	public void doCancel(CoviMap formObj) throws Exception;
	
	//전달
	public void doFoward(CoviMap formObj) throws Exception;
	
	//합의부서 삭제
	public void doDelConsent(CoviMap formObj) throws Exception;
	
	//강제합의
	public void doForcedConsent(CoviMap formObj) throws Exception;
	
}
