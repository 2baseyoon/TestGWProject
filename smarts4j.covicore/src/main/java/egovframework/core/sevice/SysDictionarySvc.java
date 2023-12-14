package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SysDictionarySvc {

	public CoviMap selectGrid(CoviMap params) throws Exception;				// 그리드에 사용할 데이터 Select
	public Object insert(CoviMap params)throws Exception;  							// 추가 시 데이터 Insert
	public CoviMap selectOne(CoviMap params) throws Exception;				// 수정 및 조회를 위한 단일 건 조회
	String selectOneString(CoviMap params) throws Exception;						// redis cache를 위한 단일건 문자열 조회
	CoviMap selectOneObject(CoviMap params) throws Exception;					// redis cache를 위한 단일건 Map 조회
	public int update(CoviMap params)throws Exception;								// 수정 시 데이터 update
	public int updateIsUse(CoviMap params)throws Exception;						// 사용유무 update
	public int delete(CoviMap params)throws Exception;								// 데이터 삭제
	public CoviMap selectExcel(CoviMap params) throws Exception;					// 엑셀 다운로드 데이터 조회
	public String translate(String sourceLang, String targetLang, String text) throws Exception;			// 네이버 번역 API
}
