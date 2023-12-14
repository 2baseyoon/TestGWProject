package egovframework.covision.groupware.portal.admin.service;


import egovframework.baseframework.data.CoviMap;
public interface PortalManageSvc{

	CoviMap getPortalList(CoviMap params) throws Exception; //포탈 목록 조회

	// CoviMap getCompanyList() throws Exception; //회사 목록 조회
	
	CoviMap getLayoutList() throws Exception; //레이아웃 목록 조회
	
	CoviMap getPortalData(CoviMap params) throws Exception; //특정 포탈 정보 조회

	int insertPortalData(CoviMap params)throws Exception; //포탈 데이터 추가

	//int insertACLData(CoviMap params)throws Exception;  //포탈의 권한 설정 추가

	//int insertPortalDictionary(CoviMap params)throws Exception; //포탈의 다국어 데이터 추가

	int updatePortalData(CoviMap params)throws Exception; //포탈의 기본 데이터 수정

	//int updateACLData(CoviMap params)throws Exception; //포탈의 권한 데이터 수정

	int deletePortalData(CoviMap params)throws Exception; //포탈의 기본 데이터 삭제

	//int deleteACLData(CoviMap params)throws Exception; //포탈의 권한 데이터 삭제

	//int deletePortalDictionary(CoviMap params)throws Exception; //포탈의 다국어 데이터 삭제

	int chnagePortalIsUse(CoviMap params)throws Exception; //포탈의 사용여부 변경

	CoviMap getThemeList() throws Exception;  //테마 목록 조회

}
