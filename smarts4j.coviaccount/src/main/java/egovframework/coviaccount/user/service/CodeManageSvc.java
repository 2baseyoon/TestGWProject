package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface CodeManageSvc {
	public CoviMap getCodeSearchGroupList(CoviMap params) throws Exception;
	public CoviMap getCodeSearchList(CoviMap params) throws Exception;
	public CoviMap saveCodeManageInfo(CoviMap params) throws Exception;
}