package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface SysAccessURLSvc {
	
	/**
	 * 익명 접근 URL 목록 조회
	 * @param params
	 * @return JSONObject
	 * @throws Exception
	 */
	public CoviMap getList(CoviMap params) throws Exception;
	
	/**
	 * 특정 익명 접근 URL 정보 조회
	 * @param params
	 * @return CoviMap
	 * @throws Exception
	 */
	public CoviMap getInfo(CoviMap params) throws Exception;
	
	/**
	 * 익명 접근 URL 추가
	 * @param params
	 * @return <code>true</code>: 성공, <code>false</code>: 실패
	 * @throws Exception
	 */
	public boolean add(CoviMap params) throws Exception;
	
	/**
	 * 익명 접근 URL 수정
	 * @param params
	 * @return <code>true</code>: 성공, <code>false</code>: 실패
	 * @throws Exception
	 */
	public boolean modify(CoviMap params) throws Exception;
	
	/**
	 * 익명 접근 URL 사용여부 수정
	 * @param params
	 * @return <code>true</code>: 성공, <code>false</code>: 실패
	 * @throws Exception
	 */
	public boolean modifyIsUse(CoviMap params) throws Exception;
	public boolean modifyIsAdmin(CoviMap params) throws Exception;
	
	/**
	 * 익명 접근 URL 삭제
	 * @param params
	 * @return <code>true</code>: 성공, <code>false</code>: 실패
	 * @throws Exception
	 */
	public boolean delete(CoviMap params) throws Exception;
	
}
