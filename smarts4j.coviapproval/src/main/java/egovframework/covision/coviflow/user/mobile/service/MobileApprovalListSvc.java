package egovframework.covision.coviflow.user.mobile.service;


import egovframework.baseframework.data.CoviMap;

public interface MobileApprovalListSvc {
	public CoviMap selectMobileMenuList(CoviMap params) throws Exception;
	public CoviMap selectMobileApprovalList(CoviMap params) throws Exception;
	public CoviMap selectMobileDeptApprovalList(CoviMap params) throws Exception;
	public CoviMap selectMobileApprovalView(CoviMap params) throws Exception;
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception;
}
