package egovframework.covision.groupware.vacation.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import java.util.List;


public interface VacationSvc {
	public CoviMap getVacationDayList(CoviMap params) throws Exception;	// 연차관리 조회
	
	public int insertNextVacation(CoviMap params) throws Exception;	// 내년도 휴가 등록

	public int insertExtraVacation(CoviMap params, List userCodeList) throws Exception;	// 기타 휴가 등록

	public CoviMap checkExtraVacation(CoviMap params, List userCodeList) throws Exception;	// 기타 휴가 체크

	public int updateVacDay(CoviMap params) throws Exception;	// 휴가 수정

	public int updateExtraVacDay(CoviMap params) throws Exception;	// 기타 휴가 수정
	
	public int updateVacationPeriod(CoviMap params) throws Exception;	// 연차기간 수정

	public CoviMap getMyVacationInfoList(CoviMap params) throws Exception;	// 나의휴가현황
	
	public CoviMap getMyVacationCreateInfoList(CoviMap params) throws Exception;	// 나의 휴가 발생 현황
	
	public CoviMap getVacationInfoList(CoviMap params) throws Exception;	// 휴가신청/취소 조회, 공동연차등록, 휴가취소처리

	public CoviMap getVacationInfoListV2(CoviMap params) throws Exception;	// 휴가신청/취소 조회, 공동연차등록, 나의휴가현황, 휴가취소처리

	public CoviMap getVacationCancelList(CoviMap params) throws Exception;	// 휴가신청/취소 조회

	public CoviMap getVacationCancelCheck(CoviMap params) throws Exception;	// 휴가신청/취소 이전 데이터 체크 조회

	public CoviMap getNextVacationListForExcel(CoviMap params) throws Exception;	// 연차관리 엑셀 템플릿 다운로드 
	
	public CoviMap getTargetUserListForExcel(CoviMap params) throws Exception;	// 공동연차등록 엑셀 템플릿 다운로드
	
	public CoviMap insertJointVacation(CoviMap params) throws Exception;	// 공동연차등록 (Web)
	
	public CoviMap insertVacationByExcel(CoviMap params) throws Exception;	// 공동연차등록 엑셀 업로드
	
	public CoviMap insertVacationCancelByExcel(CoviMap parmas) throws Exception;// 공동연차취소 엑셀 업로드
	
	public int insertVacationCancel(CoviMap params) throws Exception;	// 휴가취소

	public CoviMap getUserVacationInfo(CoviMap params) throws Exception;	// 나의휴가현황 > 사용휴가일수
	public CoviMap getUserVacationInfoV2(CoviMap params) throws Exception;	// 나의휴가현황 > 사용휴가일수 일반휴가용

	public CoviMap getVacationDayListByType(CoviMap params) throws Exception;	// 휴가현황 > 부서휴가유형별조회, 휴가관리 > 휴가유형별현황
	
	public int insertVacationPlan(CoviMap params) throws Exception;	// 연차관리 엑셀 업로드
	
	public int insertVacationMessageRead(CoviMap params) throws Exception;	// 읽음 테이블에 입력
	
	public CoviMap getVacationListByMonth(CoviMap params) throws Exception;	// 휴가현황 > 부서휴가월별현황, 휴가관리 > 휴가월별현황
	
	public CoviMap getVacationMessageReadList(CoviMap params) throws Exception;	// 연차촉진제 1차 조회내역, 연차촉진제 2차 조회내역, 사용시기 지정통보 조회내역
	
	public CoviMap getVacationUsePlan(CoviMap params) throws Exception;	// 연차사용시기 
	
	public int insertVacationUsePlan(CoviMap params) throws Exception;	// 연차사용시기 등록
	
	public CoviMap getVacationCancelDocList(CoviMap params) throws Exception;	// 휴가취소처리 > 문서연결
	
	public CoviMap getVacationUsePlanList(CoviMap params) throws Exception;	// 연차촉진제관리 > 미사용연차계획 저장내역 조회
	
	public CoviList getVacationData(CoviMap params) throws Exception;	// 휴가정보
	public CoviList getVacationInfo(CoviMap params) throws Exception;
	
	public CoviMap getVacationInfoForHome(CoviMap params) throws Exception;	// 휴가관리 홈
	
	public CoviMap getPromotionBtnVisible(CoviMap params) throws Exception;	// 나의휴가현황 > 버튼 visible
	
	public void autoIncreaseMonthlyVacation(CoviMap param) throws Exception;
	public void autoIncreaseMonthlyVacationV2(CoviMap param) throws Exception;
	public void autoUpdateAnnualVacation(CoviMap param) throws Exception;
	public void autoCreateAnnualVacation(CoviMap param) throws Exception;
	public int insertCreateAnnualVacationV2(CoviMap param) throws Exception;

	public void insertNewAnnualVacation(CoviMap param) throws Exception;
	public void insertNewAnnualVacationV2(CoviMap param) throws Exception;

	public String getVacationPolicy() throws Exception; // 휴가 규정 조회

	public CoviMap getDeptList(CoviMap params) throws Exception;	// 권한있는 부서 목록 조회
	
	void updateDeptInfo(CoviMap param) throws Exception;
	
	//public String getFullAttendance(String enterDate) throws Exception; //입사일 기준 만근일 조회
	public CoviMap getVacationTypeList(CoviMap params) throws Exception;
	public int updVacationType(CoviMap params) throws Exception;
	public int setVacationType(CoviMap params) throws Exception;
	public int delVacationType(CoviMap params) throws Exception;

	public CoviMap getJobWorkOnDays(CoviMap params);
	
	public CoviMap getVacTypeDomain() throws Exception;			// 사용자 도메인에 따른 휴가코드를 조회.

	public CoviMap getExtraVacKind(CoviMap params) throws Exception;
	public CoviMap selectVacationListByAll(CoviMap params) throws Exception;
	public CoviMap getVacationListByUse(CoviMap params) throws Exception;

	//2022.04.21 nkpark
	public CoviMap getVacationExtraList(CoviMap params) throws Exception;	//기타근무목록 조회
	public CoviMap getVacationManageList(CoviMap params) throws Exception;	//공통근무목록 조회
	
	public CoviMap getVacationListByKind(CoviMap params) throws Exception;	//휴가 유형별 휴가정보
	public CoviMap getVacationByCode(CoviMap params, List userCodeList) throws Exception;	//휴가 유형별 휴가정보 코드기준
	public int insertVmPlanHist(CoviMap params) throws Exception;	// 휴가 정보 등록/갱신 히스토리
	public int updateVmPlanHist(CoviMap params) throws Exception;	// 휴가 정보 등록/갱신 히스토리

	public CoviMap getVacationPlanHistList(CoviMap params) throws Exception;			//발생이력 목록 조회
	public CoviMap selectVacationFlagSelList(CoviMap params) throws Exception;			//발생이력 휴가유형 필터 조회
	public CoviMap getVacationPromotionDateList(CoviMap params) throws Exception;	//연차촉진 기간설정 목록 조회
	public CoviMap getVacationPromotionDate(CoviMap params) throws Exception;		//연차촉진 기간설정 조회
	public int updateVacationPromotionDate(CoviMap params) throws Exception;			//연차촉진 기간설정 수정
	public int initVacationPromotionDate(CoviMap params) throws Exception;	//연차촉진 기간설정

	public String getVacationConfigVal(CoviMap params) throws Exception;		//휴가생성 자동 규칙설정 조회(환경설정 조회용)
	public int initVacationConfig(CoviMap params) throws Exception;	//휴가생성 자동 규칙 초기설정
	public CoviList getVacationConfig(CoviMap params) throws Exception;		//휴가생성 자동 규칙설정 조회
	public int updateVacationConfig(CoviMap params) throws Exception;		//휴가생성 자동 규칙설정 수정
	public int updateVacationExpireDateRange(CoviMap params) throws Exception;	//휴가 유효기간 회계년도/입사일 기준으로 업데이트
	public int deleteVacationPlanHist(CoviMap params) throws Exception;	//휴가 생성 이력 일반 연차 지우기
	public int updateResetVacationDays(CoviMap params) throws Exception;	//휴가 유효기간 회계년도/입사일 기준으로 업데이트
	public CoviList getVacationPromotionTargetList(CoviMap params) throws Exception;	// 연차관리 조회
	public CoviList getVacationPromotionTargetUserInfo(CoviMap params) throws Exception;	// 연차관리 조회

	public CoviMap getVacationFacilitatingDateList(CoviMap params) throws Exception; 	//사용자별 연차촉진일 목록 조회
	public int updateVacPlanMigration(CoviMap param) throws Exception;	// 휴가사용계획 마이그레이션동 업데이트
	public CoviList getVacationUsePlanMigrationList(CoviMap params) throws Exception; //휴가사용계획 마이그레이션 대상

	public CoviMap getVacationPlanHist(CoviMap params) throws Exception;	// 휴가부여이력팝업 조회
	public void updateLastLongVacDay(CoviMap param) throws Exception; //근속연차,이월연차 재계산
	public void updateLastLongVacDayV2(CoviMap param) throws Exception; //근속연차,이월연차 재계산

	public CoviMap getVacationRewardList(CoviMap params) throws Exception;

	public CoviMap getRewardVacKind(CoviMap params) throws Exception;

	public int insertRewardVacation(CoviMap params, List userCodeList) throws Exception;

	public int updateRewardVacDay(CoviMap params) throws Exception;

	public int insertRewardVacationAPI(CoviList params) throws Exception;

	public int cancelRewardVacationAPI(CoviList params) throws Exception;

	public int updateBeforeAnnual(CoviMap params) throws Exception;

	public CoviList getUserDisplayName(CoviMap params) throws Exception;
}
