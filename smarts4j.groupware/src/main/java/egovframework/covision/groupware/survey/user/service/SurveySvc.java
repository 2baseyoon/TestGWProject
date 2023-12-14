package egovframework.covision.groupware.survey.user.service;



import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface SurveySvc {
	public int insertSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;	// 설문 등록
	
	public int insertCollabSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;	// 설문 등록(협업 스페이스)
	
	public CoviMap getSurveyQuestionItemList(CoviMap params) throws Exception;	// 설문 조회(문항, 보기 포함)
	
	public int updateSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;	// 설문 수정
	
	public int updateCollabSurvey(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;	// 설문 수정(협업 스페이스)
	
	public int insertQuestionItemAnswer(CoviMap params) throws Exception;	// 설문 참여 등록
	
	public CoviMap getQuestionItemAnswerList(CoviMap params) throws Exception;	// 설문 참여 결과 조회
	
	public CoviMap getSurveyList(CoviMap params) throws Exception;	// 설문 조회
	
	public int deleteSurvey(CoviMap params)throws Exception;	// 설문 삭제
	
	public int updateSurveyState(CoviMap params) throws Exception;	// 설문 상태 수정
	
	public CoviMap getAnswerListForChart(CoviMap params) throws Exception;	// 차트 데이터 조회
	
	public CoviMap getTargetRespondentList(CoviMap params) throws Exception;	// 설문 대상 조회 ( 참여자 통계와 같이 사용 )
	
	public CoviMap getTargetResultviewList(CoviMap params) throws Exception;	// 결과공개 대상 조회
	
	public CoviMap getSurveyManageList(CoviMap params) throws Exception;	// 설문관리(관리자) 조회
	
	public CoviMap getSurveyReportList(CoviMap params) throws Exception;	// 설문 통계보기 조회
	
	public int updateSurveyTargetRead(CoviMap params) throws Exception;	// 설문 읽음 업데이트
	
	public CoviMap getWebpartSurveyList(CoviMap params) throws Exception;	// 웹파트 설문 데이터 조회
	
	public CoviMap selectSurveyRawDataExcelList(CoviMap params) throws Exception; 	// 엑셀저장 : 설문자료 저장 
	
	public CoviMap selectSurveyStatisticsExcelList(CoviMap params) throws Exception; // 엑셀저장 : 설문통계 저장 
	
	public void sendNotAttendanceAlarm(CoviMap param) throws Exception;	// 웹파트 미참여자 알림
	
	public CoviMap selectSurveyInfoData(CoviMap param); // 설문 정보 조회

	int deleteQuestionItemAnswer(CoviMap params) throws Exception; // 설문 결과 삭제
	
	int deleteSurveyEtcOpinion(CoviMap params) throws Exception; // 설문 의견 삭제
	
	int updateSurveyInfo(CoviMap params, CoviMap fileInfos, List<MultipartFile> mf) throws Exception; //설문 정보 업데이트
	
	CoviMap getCollabSurveyInfo(CoviMap params) throws Exception;
	
	String getSurveyTargetViewRead(CoviMap params) throws Exception; //설문대상 여부
	CoviList selectAttendanceCodeList(CoviMap params) throws Exception; // 참여자 코드 조회

	public CoviMap getWebpartSurveyData(CoviMap params) throws Exception;	// 웹파트 설문 데이터 조회

	public CoviMap getSurveyRespondent(CoviMap params) throws Exception;
	
	public CoviMap getSurveyApprover(CoviMap params) throws Exception;
	
	public CoviMap getGroupFullPath(CoviList paramsList) throws Exception;

}
