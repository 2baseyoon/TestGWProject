package egovframework.covision.groupware.attend.user.service;

import java.util.ArrayList;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface AttendAdminSettingSvc {
	
	
	
	/**
	  * @Method Name : insertWorkInfo
	  * @작성일 : 2020. 3. 30.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자 설정 사용자 근로정보 추가
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int insertWorkInfo(CoviMap params) throws Exception;
	/**
	  * @Method Name : getWorkInfoList
	  * @작성일 : 2020. 3. 31.
	  * @작성자 : sjhan0418
	  * @변경이력 :  
	  * @Method 설명 : 관리자 설정  근로정보 리스트 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getWorkInfoList(CoviMap params) throws Exception;
	public CoviMap getWorkInfoDetail(CoviMap params) throws Exception;
	public int updateWorkInfo(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getAttendMngMst
	  * @작성일 : 2020. 3. 30.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사설정 기초정보 조회
	  * @return
	  * @throws Exception
	  */
	public CoviMap getAttendMngMst() throws Exception;
	
	/**
	  * @Method Name : setAttendMngMst
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 기본정보 수정
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int setAttendMngMst(CoviMap params) throws Exception;
	

	/**
	  * @Method Name : getCompanySetting
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사설정 기본정보 조회
	  * @return
	  * @throws Exception
	  */
	public CoviMap getCompanySetting() throws Exception;
	/**
	  * @Method Name : setCompanySetting
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  회사설정 기초설정 저장
	  * @param jo
	  * @throws Exception 
	  */
	public void setCompanySetting(CoviMap jo) throws Exception;

	/**
	 * @Method Name : setCompanySettingForVacations
	 * @작성일 : 2022. 7. 04.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 :  휴가설정용 기초설정 저장
	 * @param jo
	 * @throws Exception
	 */
	public void setCompanySettingForVacations(CoviMap jo) throws Exception;

	/**
	  * @Method Name : setIpMng
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : ip설정 저장
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int setIpMng(CoviMap params) throws Exception; 
	
	/**
	  * @Method Name : setRewardVac
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 보상휴가 정보 저장
	  * @param params
	  * @return
	  * @throws Excpetion
	  */
	public int setRewardVac(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : setRewardVac
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 보상휴가  정보 저장
	  * @param ja
	  * @return
	  * @throws Exception
	  */
	public int setRewardVac(CoviList ja) throws Exception;
	
	/**
	  * @Method Name : delRewardVac
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 보상휴가 삭제
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int delRewardVac(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : delRewardVac
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 보상휴가 삭제
	  * @return
	  * @throws Exception
	  */
	public int delRewardVac() throws Exception;
	
	
	
	
	/**
	  * @Method Name : checkExcelWorkInfoData
	  * @작성일 : 2020. 4. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 엑셀 등록 데이터 유효성 검사 
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap checkExcelWorkInfoData(ArrayList<ArrayList<Object>> params) throws Exception;
	
	/**
	  * @Method Name : insertWorkInfoExcel
	  * @작성일 : 2020. 4. 2.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 관리 엑셀 등록
	  * @param ja
	  * @return
	  * @throws Exception
	  */
	public int insertWorkInfoExcel(CoviList ja) throws Exception;
	
	/**
	  * @Method Name : checkInsertWorkInfoData
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 등록 데이터 유효성 검사
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap checkInsertWorkInfoData(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : deleteWorkInfo
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 삭제 ... 기능은 만들어 둔다만 DELETE를 쓰는게 맞는지....확인해보자
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int deleteWorkInfo(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getHolidayList
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 정보 리스트 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getHolidayList(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : createHoliday
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 등록
	  * @param params
	  * @throws Exception
	  */
	public void createHoliday(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : delHoliday
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 삭제
	  * @param params
	  * @throws Exception
	  */
	public int deleteHoliday(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : getOtherJobList
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무관리 리스트 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviMap getOtherJobList(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : setOtherJob
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 정보 등록
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int setOtherJob(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : delteOtherJob
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 정보 삭제
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public int delteOtherJob(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getIpList
	  * @작성일 : 2020. 4. 13.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  ip리스트 조회	 
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getIpList(CoviMap params) throws Exception;


	/**
	 * @Method Name : getWorkPlaceList
	 * @작성일 : 2021. 08. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정  근무지관리 리스트 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap getWorkPlaceList(CoviMap params) throws Exception;
	/**
	 * @Method Name : insertWorkPlace
	 * @작성일 : 2021. 08. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정  근무지 등록
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int insertWorkPlace(CoviMap params) throws Exception;

	/**
	 * @Method Name : updateWorkPlace
	 * @작성일 : 2021. 08. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정  근무지 등록
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int updateWorkPlace(CoviMap params) throws Exception;

	/**
	 * @Method Name : deleteWorkPlace
	 * @작성일 : 2021. 08. 12.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정  근무지  삭제
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int deleteWorkPlace(CoviMap params) throws Exception;

	/**
	 * @Method : selecAttendMaxBaseDatePop
	 * @Comment : attendance_daylist 테이블에 가장 큰 날짜값을 조회.
	 * @param params
	 * @return : Max(DayList, 날짜 최대값), DayName(요일)
	 * @throws Exception
	 */
	public CoviMap selecAttendMaxBaseDatePop(CoviMap params) throws Exception;
	
	/**
	 * @Method : insertAttendBaseDate
	 * @Comment : attendance_daylist 테이블에서 입력되어 있는 날에서 지정한 날까지 날짜 추가 insert.
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int insertAttendBaseDate(CoviMap params) throws Exception;
	
	public CoviMap getAttModifyHisList(CoviMap params) throws Exception;
	
	public CoviList getAttModifyHisExcelList(CoviMap params) throws Exception;
	
}