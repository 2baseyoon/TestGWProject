package egovframework.covision.groupware.portal.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface WebpartManageSvc {

	CoviMap getWebpartList(CoviMap params) throws Exception; //웹파트 목록 조회

	//JSONObject getCompanyList() throws Exception; //소유 회사 selectbox에 바인딩 될 데이터 조회

	int insertWebpartData(CoviMap params)throws Exception; //웹파트 정보 추가

	int chnageWebpartIsUse(CoviMap params) throws Exception; //웹파트 사용여부 변경

	int deleteWebpartData(CoviMap delParam)throws Exception; //웹파트 삭제

	CoviMap getWebpartData(CoviMap params) throws Exception; //특정 웹파트 정보 조회

	int updateWebpartData(CoviMap params)throws Exception; //웹파트 정보 수정

	int selectDuplJsModuleName(CoviMap params)throws Exception; //웹파트 모듈명 중복 체크
}
