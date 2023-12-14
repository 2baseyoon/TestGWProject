package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface SsoSamlSvc {
	
	public CoviMap checkAuthetication(String EMPNO, String CODE) throws Exception;
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception;
	public CoviMap selectTokenInForMation(String key) throws Exception;
	
	public String checkTokenKey(String EMPNO) throws Exception;
	public String checkSSO(String OpType) throws Exception;
	
	public int checkUserCnt(String EMPNO, String CODE) throws Exception;
	public int checkUserAuthetication(String id, String password) throws Exception;
	
	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id) throws Exception;
}
