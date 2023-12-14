package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface ListAdminSvc {
	public CoviMap getEntinfototalListData(CoviMap params) throws Exception;
	public CoviMap selectListAdminData(CoviMap params) throws Exception;
	public CoviMap selectDocumentInfo(CoviMap params) throws Exception;
	CoviMap selectListAdminData_Store(CoviMap params) throws Exception;
}
