package egovframework.covision.groupware.workreport.service;


import egovframework.baseframework.data.CoviMap;

public interface WorkDaySettingService {
	
	// 리스트 조회
	public CoviMap selectList(CoviMap params) throws Exception;
	
	// 단일 조회
	public CoviMap selectOne(CoviMap params) throws Exception;
	
	// 삽입
	public CoviMap insert(CoviMap params) throws Exception;
	
	// 삭제
	public int delete(CoviMap params) throws Exception;
	
	// 수정
	public int update(CoviMap params) throws Exception;
	
}
