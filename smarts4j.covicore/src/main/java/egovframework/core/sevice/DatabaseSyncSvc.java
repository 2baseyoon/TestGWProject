package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;

public interface DatabaseSyncSvc {
	public CoviMap selectTargetList(CoviMap params) throws Exception;
	public CoviMap selectTarget(CoviMap params) throws Exception;
	public int insertTarget(CoviMap params) throws Exception;
	public int updateTarget(CoviMap params) throws Exception;
	public int updateUse(CoviMap params) throws Exception;
	public int deleteTarget(CoviMap params) throws Exception;
	public int updateTargetResult(CoviMap params) throws Exception;
}
