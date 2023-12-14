package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface SettingListSvc {
	public CoviMap getSettingListData(CoviMap params) throws Exception;
	public void synchronizeSetting() throws Exception;
}
