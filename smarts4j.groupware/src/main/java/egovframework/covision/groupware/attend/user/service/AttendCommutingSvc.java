package egovframework.covision.groupware.attend.user.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

/**
 * @author sjhan0418
 *
 */
public interface AttendCommutingSvc {

	/**
	  * @Method Name : getCommuteMstSeq
	  * @작성일 : 2020. 4. 13.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 mst 테이블 seq 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public String getCommuteMstSeq(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getCommuteMstData
	  * @작성일 : 2020. 4. 16.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 mst 테이블 data 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getCommuteMstData(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : setCommuteTime
	  * @작성일 : 2020. 4. 13.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 시간 저장
	  * @param params 
	  * @return
	  * @throws Exception
	  */
	public CoviMap setCommuteTime(CoviMap params) throws Exception;
	

	/**
	  * @Method Name : getMngJob
	  * @작성일 : 2020. 4. 16.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근무 일정 등록 정보 조회 
	  * @param userCode
	  * @param targetDate
	  * @param companyCode
	  * @return
	  * @throws Exception
	  */
	public CoviList getMngJob(String userCode , String targetDate, String companyCode, String startTime) throws Exception;
	
	/**
	  * @Method Name : chkCommuteAllowRadius
	  * @작성일 : 2020. 4. 16. 
	  * @작성자 : sjhan0418
	  * @변경이력 :  
	  * @Method 설명 : 근무일정 출퇴근 가능 거리 확인
	  * @param companyCode 
	  * @param userCode 사용자코드
	  * @param targetDate 대상일
	  * @param commuteType 출퇴근상태(S/E)
	  * @param commutePointX 출퇴근좌표X
	  * @param commutePointY 출퇴근좌표Y
	  * @return
	  * @throws Exception
	  */
	public CoviMap chkCommuteAllowRadius(String companyCode,String userCode , String targetDate, String commuteType,String commutePointX, String commutePointY) throws Exception;
	
	
	/**
	  * @Method Name : setCallingPreTargetDate
	  * @작성일 : 2020. 4. 22.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 해당일 이전 데이터 소명신청 대상 처리
	  * @param userCode
	  * @param targetDate
	  * @param companyCode
	  * @throws Exception
	  */
	public void setCallingPreTargetDate(String userCode , String targetDate,String companyCode) throws Exception;
	
	/**
	  * @Method Name : setCommuteMstProc
	  * @작성일 : 2020. 4. 23.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 ms 업데이트  procedure
	  * @param userCode
	  * @param targetDate
	  * @param companyCode
	  * @throws Exception
	  */
	public void setCommuteMstProc(String userCode,String targetDate,String companyCode) throws Exception;
	
	/**
	  * @Method Name : setCommuteMng
	  * @작성일 : 2020. 5. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태기록  추가/수정 
	  * @param params
	  * @throws Exception
	  */
	public void setCommuteMng(CoviMap params) throws Exception;
	
	

	/**
	  * @Method Name : setCommuteMng
	  * @작성일 : 2020. 5. 21.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태기록  추가 수정 I/F
	  * @param TargetDate	지정일	*
	  * @param UserCode		사용자코드 *
	  * @param RegUserCode	승인자코드
	  * @param StartDate	출근시간 ( yyyy-MM-dd HH:mm:ss )
	  * @param EndDate		퇴근시간 ( yyyy-MM-dd HH:mm:ss )
	  * @param Etc			비고
	  * @param CompanyCode	회사코드 *
	  * @return	status ( SUCCESS :성공 / FAIL :실패 ) message 
	  * @throws Exception
	  */
	public CoviMap setCommuteMng(String TargetDate,String UserCode,String RegUserCode,String StartDate,String EndDate,String Etc,String CompanyCode) throws Exception;

	/**
	 * @Method Name : getWorkPlaceList
	 * @작성일 : 2021. 10. 22.
	 * @작성자 : yhshin
	 * @변경이력 :
	 * @Method 설명 : 템플릿에 저장된 출/퇴근지 정보
	 * @param params
	 * @throws Exception
	 */
	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception;

}