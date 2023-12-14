package egovframework.covision.groupware.portal.user.service;

import java.util.Set;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PortalSvc {
	public Object getWebpartData(CoviList webPart, CoviMap userDataObj) throws Exception;
	
	public Object getWebpartData(CoviList webPartArray, CoviMap userDataObj, String isMobile) throws Exception;
	
	public String getLayoutTemplate(CoviList webPart, CoviMap params) throws Exception;
	
	public String getJavascriptString(String lang, CoviList webPartList) throws Exception;
	public String getJavascriptString(String lang, CoviList webPartList, String sFunc) throws Exception;
	
	public CoviMap getPortalTheme(String portalID)throws Exception;
	
	public CoviList getWebpartList(CoviMap params) throws Exception;
	
	public int updateInitPortal(CoviMap params) throws Exception;
	
	public CoviMap getPortalInfo(CoviMap params)throws Exception;
	
	public String getIncResource(CoviList webpartList)throws Exception;
	
	public String setInitPortal(Set<String> authorizedObjectCodeSet, String userID) throws Exception;
	
	public CoviList getMyContentsWebpartList(CoviMap params) throws Exception;
	
	public void saveMyContentsSetting(CoviMap params) throws Exception;
	
	public CoviList getMyContentSetWebpartList(CoviMap params) throws Exception;
	
	public CoviList getMyContentWebpartList(CoviMap params) throws Exception;
		
	public CoviMap getEmployeesNoticeList(CoviMap params) throws Exception;
	
	public CoviMap exchFileList(CoviMap params) throws Exception;
	public CoviMap updateWebpartExtjson(CoviMap params) throws Exception;
	
	public void saveMyContents(CoviMap params) throws Exception;
	public void saveMyContentsOrder(CoviMap params) throws Exception;
	public void savePortalWebpart(CoviMap params) throws Exception;
	public void saveMyContentsWebpartColor(CoviMap params) throws Exception;
	public void resetPortalOption(CoviMap params) throws Exception;
	
	public CoviMap selectWebpartSettingKey(CoviMap params) throws Exception;
	public void updateWebpartSettingKey(CoviMap params) throws Exception;
	public CoviList selectBoardFolderByType(CoviMap params) throws Exception;
}
