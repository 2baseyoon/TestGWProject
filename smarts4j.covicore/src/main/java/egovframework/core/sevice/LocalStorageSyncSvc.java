package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;


public interface LocalStorageSyncSvc {
	
	/**
	 * 동기화 대상 목록 조회
	 * @param params
	 * @return JSONObject
	 * @throws Exception
	 * @author dyjo
	 * @since 2019.04.16
	 */
	public CoviMap getSyncTargetList(CoviMap params, CoviMap userDataObj) throws Exception;

}
