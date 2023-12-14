package egovframework.covision.groupware.biztask.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface BizTaskService {
	CoviList selectUserTFGridList(CoviMap params)throws Exception; //프로젝트 리스트 가져오기
	
	CoviMap getMyTaskList(CoviMap params)throws Exception; //나의 업무 가져오기
	
	CoviMap getGanttList(CoviMap params)throws Exception; //간트차트 가져오기
	
	CoviMap getMyTeams(CoviMap params)throws Exception; //부서장인 부서 목록 가져오기
	
	CoviMap getMyTeamProjectSummary(CoviMap params)throws Exception; //부서 기반 프로젝트/업무관리 요약정보 조회
	
	int selectMyTeamProjectSummaryListCNT(CoviMap params)throws Exception; //지연/진행 프로젝트 카운트 조회
	
	CoviMap selectMyTeamProjectSummaryList(CoviMap params)throws Exception; //지연/진행 프로젝트 목록 조회
	
	int selectMyPreTaskListCNT(CoviMap params)throws Exception; //예고업무 카운트 조회
	
	CoviMap selectMyPreTaskList(CoviMap params)throws Exception; //예고업무 목록 조회
	
	void setPreTaskSchedule(CoviMap params)throws Exception; //예고업무생성 스케쥴
	
	int deleteMyPreTask(CoviMap params)throws Exception; //예고업무삭제
	
	int deletePreTaskSchedule(CoviMap params)throws Exception; //예고업무삭제 스케쥴
	
	CoviMap getAllMyTaskList(CoviMap params) throws Exception;
	
	/*
	 * 통합업무관리 PORTAL
	 * */
	CoviMap selectPortalMyActivityList(CoviMap params) throws Exception;	//프로젝트 작업 리스트
	
	CoviMap selectPortalMyTaskList(CoviMap params) throws Exception;	//일반업무 리스트
	
	CoviMap selectPortalMyActivityGraph(CoviMap params) throws Exception;	//프로젝트 작업 그래프 데이터
	
	CoviMap selectPortalMyTaskGraph(CoviMap params) throws Exception;	//일반업무 리스트
	
	/*
	 * 통합업무관리 left메뉴 프로젝트 리스트 조회
	 * */
	CoviList selectUserTFLeftGridList(CoviMap params)throws Exception; //프로젝트 리스트 가져오기
}