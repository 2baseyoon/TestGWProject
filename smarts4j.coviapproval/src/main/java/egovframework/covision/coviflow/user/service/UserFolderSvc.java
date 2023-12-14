package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface UserFolderSvc {
	public CoviMap selectUserFolderList(CoviMap params) throws Exception;
	public int insertFolderCopy(CoviMap params)throws Exception;
	public int insert(CoviMap params)throws Exception;
	int selectDuplicateFolderCnt(CoviMap params) throws Exception;
}
