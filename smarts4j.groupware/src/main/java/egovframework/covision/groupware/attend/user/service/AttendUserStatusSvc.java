package egovframework.covision.groupware.attend.user.service;

import java.util.List;
import java.util.Map;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

/**
 * @author sjhan0418
 *
 */
/**
 * @author sjhan0418
 *
 */
public interface AttendUserStatusSvc {
	
	/**
	  * @Method Name : getDayScope
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 검색일 조회
	  * @param dayTerm
	  * @param targetDate
	  * @param companyCode
	  * @return
	  * @throws Exception
	  */
	public String getDayScope(String dayTerm,String targetDate,String companyCode) throws Exception;

	/**
	  * @Method Name : getUserAttStatus
	  * @작성일 : 2020. 6. 4.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  근태현황 조회
	  * @param userCodeList
	  * @param companyCode
	  * @param startDate
	  * @param endDate
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserAttStatus(CoviList userCodeList,String companyCode,String startDate,String endDate) throws Exception;
	public CoviList getUserAttStatusV2(CoviList userCodeList,String companyCode,String startDate,String endDate) throws Exception;
	public CoviList getUserAttStatusWeekly(CoviList userCodeList,String companyCode,List<Map<String, String>> listRangeFronToDate, List WeeksNum, String weeklyWorkType, String weeklyWorkValue) throws Exception;
	public CoviList getUserAttStatusDaily(CoviList userCodeList,String companyCode,List<Map<String, String>> listRangeFronToDate, List WeeksNum, String weeklyWorkType, String weeklyWorkValue) throws Exception;


	/**
	  * @Method Name : getMyAttStatus
	  * @작성일 : 2020. 4. 24.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 내 근태현황 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getMyAttStatus(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : setDayParams
	  * @작성일 : 2020. 5. 12.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 날짜 범위 조회
	  * @param dateTerm
	  * @param targetDate
	  * @param companyCode
	  * @return
	  * @throws Exception
	  */
	public CoviMap setDayParams(String dateTerm,String targetDate,String companyCode) throws Exception;
	public CoviMap setDayParamsWithoutDaylist(String dateTerm,String targetDate,String companyCode) throws Exception;
	
	/**
	  * @Method Name : getUserJobHistory
	  * @작성일 : 2020. 4. 24.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자 근무 상태 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserJobHistory(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getUserAttendance
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 매니저 근태현황 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getUserAttendance(CoviMap params) throws Exception;
	public CoviMap getUserAttendanceV2(CoviMap params) throws Exception;
	public CoviMap getUserAttendanceV2Month(CoviMap params) throws Exception;
	public CoviMap getUserAttendanceV2Range(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getUserAttWorkTime
	  * @작성일 : 2020. 5. 4.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기간별 근무시간 합계
	  * @param userCode
	  * @param companyCode
	  * @param startDate
	  * @param endDate
	  * @return
	  * @throws Exception
	  */
	public CoviMap getUserAttWorkTime(String userCode,String companyCode,String startDate,String endDate) throws Exception;
	
	/**
	  * @Method Name : getUserAttData
	  * @작성일 : 2020. 5. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자 근태기록 조회
	  * @param userCode 
	  * @param companyCode
	  * @param targetDate  
	  * @return
	  * @throws Exception
	  */
	public CoviMap  getUserAttData(String userCode,String companyCode ,String targetDate) throws Exception;
	public CoviMap  getUserAttWorkTimeProc(String userCode,String companyCode,String startDate,String endDate) throws Exception;
	
	/**
	  * @Method Name : getUserAttJobSts
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 기록 상태 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getUserAttJobSts(CoviMap params)throws Exception;
	
	/**
	  * @Method Name : getUserExtentionInfo
	  * @작성일 : 2020. 5. 11.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 연장근무 일정 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserExtentionInfo(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getUserAttendanceList
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 매니저 근태현황 목록형 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getUserAttendanceList(CoviMap params) throws Exception;
	

	/**
	  * @Method Name : setExHoData
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  연장 휴일근무 수정
	  * @param params
	  * @param reqData
	  * @throws Exception
	  */
	public void setExHoData(CoviMap params,List reqData) throws Exception;
	

	/**
	  * @Method Name : setJobHisData
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무기록 수정
	  * @param params
	  * @param reqData
	  * @return
	  * @throws Exception
	  */
	public CoviMap setJobHisData(CoviMap params,List reqData) throws Exception;
	
	/**
	  * @Method Name : getMngAttStatusExcelList
	  * @작성일 : 2020. 5. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 매니저 근태현황 엑셀 리스트
	  * @param userCodeList
	  * @param companyCode
	  * @param targetDate
	  * @param dateTerm
	  * @return
	  */
	public CoviMap getMngAttStatusExcelList(CoviList userCodeList,
			String companyCode, String targetDate, String dateTerm) throws Exception;
	
	
	/**
	  * @Method Name : setUserEtc
	  * @작성일 : 2020. 6. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자 비고 등록
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int setUserEtc(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : getMyAttExcelInfo
	  * @작성일 : 2020. 6. 3.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 내 근태현황 엑셀 다운로드 데이타 리스트  조회
	  *  - from - to 조회 기능 요청 대비 시작일/종료일 조회
	  * @param userCode
	  * @param deptCode
	  * @param companyCode
	  * @param companyId
	  * @param startDate
	  * @param endDate
	  * @return
	  * @throws Exception
	  */
	public CoviMap getMyAttExcelInfo(String userCode ,String deptCode,String companyCode, String companyId, String startDate, String endDate) throws Exception;
	public CoviMap getMyAttExcelInfoV2(String userCode ,String deptCode,String companyCode, String companyId, String startDate, String endDate) throws Exception;
	public CoviMap getUserAttExcelInfoV2(String groupPath,String companyCode, String companyId, String startDate, String endDate, String attStatus, String outputNumtype) throws Exception;

	/**
	  * @Method Name : getMngAttExcelInfo
	  * @작성일 : 2020. 6. 3.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 매니저 근태현황 엑셀 다운로드 데이타 리스트 조회
	  * @param userCodeList
	  * @param companyCode
	  * @param startDate
	  * @param endDate
	  * @return
	  * @throws Exception
	  */
	public CoviList getMngAttExcelInfo(CoviList userCodeList ,String companyCode, String startDate, String endDate) throws Exception;
	public CoviList getUserApprovalList(CoviMap params) throws Exception ;

	/**
	 * @Method Name : getUserAttendanceWeeklyViewer
	 * @작성일 : 2021. 8. 24.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 매니저 근태현황 조회2
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap getUserAttendanceWeeklyViewer(CoviMap params) throws Exception;

	/**
	 * @Method Name : getUserAttStatusInfo
	 * @작성일 : 2021. 8. 25.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 :  근태현황 조회2
	 * @param reqparam
	 * @param userCodeList
	 * @param companyCode
	 * @param WeeksNum
	 * @return
	 * @throws Exception
	 */
	public CoviList getUserAttStatusInfo(CoviMap reqparam, CoviList userCodeList, String companyCode, List WeeksNum);


	/**
	 * @Method Name : getUserAttendanceViewerExcelData
	 * @작성일 : 2021. 8. 24.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 매니저 근태현황 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap getUserAttendanceViewerExcelData(CoviMap params) throws Exception;
	public CoviMap getUserAttWorkWithDayAndNightTimeProc(String userCode,String companyCode,String startDate,String endDate) throws Exception;
	/**
	 * @Method Name : getUserAttendanceDailyViewer
	 * @작성일 : 2021. 8. 31.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 매니저 근태현황 월별 장표용
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap getUserAttendanceDailyViewer(CoviMap params) throws Exception;
	public CoviMap getUserAttendanceDailyViewerExcelData(CoviMap params) throws Exception;
	public CoviMap getUserAttendanceDailyViewerExcelDataDetail(CoviMap params) throws Exception;


	public CoviMap getRangeFronToDate(String TargetDate, boolean incld_weeks) throws Exception;
	
	public CoviMap setAllCommute(CoviMap params, List ReqData, CoviList TargetUserList) throws Exception;
	public CoviList getTargetUserList(List TargetData);
	public int setAllCommuteByExcel(CoviMap params) throws Exception;
	
	public CoviMap getUserAttendanceExcelList(CoviMap params) throws Exception;
	
	public int updateAttConfirm(CoviMap params) throws Exception;
}