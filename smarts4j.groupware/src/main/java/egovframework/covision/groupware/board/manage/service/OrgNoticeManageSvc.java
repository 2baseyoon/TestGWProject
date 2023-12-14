package egovframework.covision.groupware.board.manage.service;


import egovframework.baseframework.data.CoviMap;

public interface OrgNoticeManageSvc {
	public CoviMap getOrgFolderPath(CoviMap params) throws Exception;
	public CoviMap getOrgNoticeList(CoviMap params) throws Exception;
	public int exportMessage(CoviMap params) throws Exception ;
	public CoviMap selectMenuList(CoviMap params) throws Exception ;
	public CoviMap getNoticeHistoryList(CoviMap params) throws Exception;
	public int checkSystemNotice(CoviMap params) throws Exception;	
}
