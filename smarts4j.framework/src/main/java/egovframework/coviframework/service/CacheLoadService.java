package egovframework.coviframework.service;

import java.util.Map;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface CacheLoadService {

	public CoviList selectDicCache(CoviMap param) throws Exception;
	public CoviList selectAdminMenuCache(CoviMap param) throws Exception;
	public CoviList selectUserMenuCache(CoviMap param) throws Exception;
	public CoviMap getBaseConfig(CoviMap params) throws Exception;
	
	//수정된 캐쉬처리 시작
	public CoviList selectDic(CoviMap param) throws Exception;
	public CoviList selectBaseConfig(CoviMap param) throws Exception;
	public CoviList selectBaseCode(CoviMap params) throws Exception;
	
	// 신규 권한 sync 관련
	public Map<String, String> selectSyncType() throws Exception;
	public CoviList selectDomain(CoviMap param) throws Exception;

	public CoviList selectAuthMenu() throws Exception;
	public CoviList selectAuditUrl() throws Exception;

}
