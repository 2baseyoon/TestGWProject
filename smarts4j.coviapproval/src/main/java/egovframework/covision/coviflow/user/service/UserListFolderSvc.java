package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface UserListFolderSvc {
	public CoviMap selectUserFolderList(CoviMap params) throws Exception;
	public CoviMap selectUserFolderDataList(CoviMap params) throws Exception;
	public int update(CoviMap params) throws Exception;
	public int updateUserFolderMove(CoviMap params) throws Exception;
	public int deleteUserFolderList(CoviMap params) throws Exception;
	public int selectUserFolderAuth(CoviMap params) throws Exception;
}
