package egovframework.covision.groupware.bizreport.user.service;

import egovframework.baseframework.data.CoviMap;


public interface BizReportService {
	//업무보고
	public CoviMap getMyProject(CoviMap params) throws Exception; //업무보고목록 프로젝트 셀렉트박스by userCd-사용
	//public int updateTaskReport(CoviMap params) throws Exception; //업무보고팝업 업무수정
	//public boolean deleteTaskReport(CoviMap params)throws Exception; //업무보고 업무삭제
	public int insertTaskReportDaily(CoviMap params) throws Exception; //업무보고 일일보고 멀티 등록-사용
	public CoviMap getTaskReportDailyList(CoviMap params) throws Exception; //업무보고 일일목록조회-사용
	public CoviMap getTaskReportDailyListAll(CoviMap params) throws Exception; //업무보고 일일목록조회-팀장조회-사용
	
	//주간보고등록
	public CoviMap getTaskReportWeeklyList(CoviMap params) throws Exception; //주간보고등록 > 항목 조회-사용
	public int insertProjectTaskReportWeekly(CoviMap params) throws Exception; //주간보고등록 > 등록-사용
	public int updateProjectTaskReportWeekly(CoviMap params) throws Exception; //주간보고등록 > 수정-사용
	public CoviMap checkReportWeeklyRegistered(CoviMap params) throws Exception; //주간보고등록 > 등록 조회-사용
	
	//주간보고현황
	public CoviMap getTaskReportWeeklyListAll(CoviMap params) throws Exception; //주간보고현황 > 리스트 조회-사용
	public CoviMap getTaskReportWeeklyView(CoviMap params) throws Exception; //주간보고현황 > 주간보고 조회
	public CoviMap getMyTeamMembers(CoviMap params) throws Exception; //팀 및 팀멤버 조회-사용
}