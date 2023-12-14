package egovframework.covision.groupware.webpart.service;


import egovframework.baseframework.data.CoviMap;

public interface UserApprovalListSvc {

	CoviMap getUserApprovalList(CoviMap params) throws Exception;
	CoviMap getUserProcessList(CoviMap params) throws Exception;
	CoviMap getUserPreApprovalList(CoviMap params) throws Exception;
	CoviMap getUserTCInfoList(CoviMap params) throws Exception;
	
	int getApprovalListCnt(CoviMap params) throws Exception;
	int getProcessListCnt(CoviMap params) throws Exception;
	int getPreApprovalListCnt(CoviMap params) throws Exception;
	int getTCInfoListCnt(CoviMap params) throws Exception;
}
