package egovframework.core.manage.service;

import java.util.List;

import egovframework.baseframework.data.CoviMap;

public interface UserLockManageSvc {
	public CoviMap getUserLock(CoviMap params) throws Exception;
	public int insertUserLockHistory(CoviMap reqMap) throws Exception; 
	public CoviMap getUserLockHistory(CoviMap params) throws Exception;
}
