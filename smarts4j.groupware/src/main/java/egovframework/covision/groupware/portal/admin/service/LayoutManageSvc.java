package egovframework.covision.groupware.portal.admin.service;

import egovframework.baseframework.data.CoviMap;


public interface LayoutManageSvc {

	CoviMap getLayoutList(CoviMap params) throws Exception; //레이아웃 목록 조회

	int changeLayoutIsDefault(CoviMap params) throws Exception; //레이아웃 기본 여부 변경

	int insertLayoutData(CoviMap params) throws Exception; //레이아웃 데이터 추가

	CoviMap getLayoutData(CoviMap params) throws Exception; //특정 레이아웃 정보 조회

	int deleteLayoutData(CoviMap delParam)throws Exception; //레이아웃 삭제

	int checkUsing(CoviMap params)throws Exception; //포탈에서 레이아웃을 사용하는 지 여부 체크

	int updateLayoutData(CoviMap params)throws Exception; //레이아웃 정보 수정
}
