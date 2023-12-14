package egovframework.covision.groupware.portal.admin.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface WebpartSettingSvc {

	CoviMap getLayoutList(CoviMap params) throws Exception;

	CoviMap getWebpartList(CoviMap params) throws Exception;

	CoviMap getPortalSettingData(CoviMap params) throws Exception;

	int setPortalData(CoviMap params)throws Exception;

	CoviList getPreviewWebpartList(CoviMap params)throws Exception;

	String getLayoutTemplate(CoviList webpartList, CoviMap params)throws Exception;
}
