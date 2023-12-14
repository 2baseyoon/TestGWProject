package egovframework.covision.groupware.attend.user.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.springframework.web.multipart.MultipartFile;



import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

/**
 * @author sjhan0418
 *
 */
public interface AttendCommonSvc {
	
	/**
	  * @Method Name : getVacationDayList
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태관리 사용자 권한 확인
	  * @return
	  * @throws Exception
	  */
	public String getUserAuthType() throws Exception;
	
	/**
	  * @Method Name : getUserJobAuthType
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태관리 사용자  직책 권한 확인
	  * @return
	  * @throws Exception
	  */
	public String getUserJobAuthType() throws Exception;
	
	/**
	  * @Method Name : getDeptListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 권한 별 접근 가능 부서 리스트 
	  * @return
	  * @throws Exception
	  */
	public CoviMap getDeptListByAuth() throws Exception;
	public CoviList getDeptListByAuthCoviList() throws Exception;
	
	/**
	  * @Method Name : getSubDeptListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 권한별 부서 리스트 조회 
	  * @param AttendAuth
	  * @param jobType
	  * @return
	  * @throws Exception
	  */
	public CoviList getSubDeptListByAuth(String AttendAuth,String jobType) throws Exception;
	public CoviList getSubDeptListByAuthCoviList(String AttendAuth,String jobType) throws Exception;

	
	/**
	  * @Method Name : getUserListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 로그인 사용자 권한별 조회 가능한 사용자 리스트
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserListByAuth() throws Exception;
	public CoviList getUserListByAuthCoviList() throws Exception;
	
	/**
	  * @Method Name : getUserListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 권한별 조회 가능한 사용자 리스트
	  * @param attendAuth
	  * @param jobType
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserListByAuth(String attendAuth,String jobType) throws Exception;
	public CoviList getUserListByAuthCoviList(String attendAuth,String jobType) throws Exception;
	/**
	  * @Method Name : getUserListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 특정 부서 (리스트) 사용자 리스트
	  * @param deptList
	  * @param attendAuth
	  * @param jobType
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserListByAuth(CoviList deptList,String attendAuth,String jobType) throws Exception;
	public CoviList getUserListByAuthCoviList(CoviList deptList,String attendAuth,String jobType) throws Exception;
	public CoviList getUserListByAuthCoviList(String deptList,String attendAuth,String jobType) throws Exception;
	
	/**
	  * @Method Name : getUserListByAuth
	  * @작성일 : 2020. 3. 27.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  로그인 사용자 권한별 조회 가능한 사용자 리스트
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getUserListByAuth(CoviMap params) throws Exception;
	public CoviList getUserListByAuthCoviList(CoviMap params) throws Exception;
	public int getUserListByAuthCoviListCnt(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : extractionExcelData
	  * @작성일 : 2020. 4. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 엑셀파일 데이터 리드
	  * @param params
	  * @param headerCnt
	  * @return
	  * @throws Exception
	  */
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception;
	
	/**
	  * @Method Name : prepareAttachment
	  * @작성일 : 2020. 4. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 임시파일생성
	  * @param mFile
	  * @return
	  * @throws IOException
	  */
	public File prepareAttachment(final MultipartFile mFile) throws IOException;
	
	

	/**
	* @Method Name : chkAttendanceBaseInfoYn
	* @작성일 : 2019. 7. 4.
	* @작성자 : sjhan0418 
	* @변경이력 : 최초생성
	* @Method 설명 : 근무마스터 
	* @param params
	* @return
	* @throws Exception 
	*/

	public int chkAttendanceBaseInfoYn(CoviMap params)  throws Exception;
	

	public CoviList getScheduleList(CoviMap params) throws Exception;
	public CoviMap getAttendJobCalendar(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getDayScope
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기준일 별 날짜 범위 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public String getDayScope(CoviMap params) throws Exception;
	/**
	  * @Method Name : getHolidaySchedule
	  * @작성일 : 2020. 4. 29.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴무일 조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getHolidaySchedule(CoviMap params) throws Exception;
	
	
	/**
	  * @Method Name : getOtherJobList
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 리스트조회
	  * @param params
	  * @return
	  * @throws Exception
	  */
	public CoviList getOtherJobList(CoviMap params) throws Exception;
	
	/**
	  * @Method Name : getUserNowDateTime
	  * @작성일 : 2020. 5. 22.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 사용자  Timezone 적용 시간
	  * @param params
	  * UserCode 사용자명 / DateFormat dateFormat
	  * @return
	  * @throws Excpetion
	  */
	public String getUserNowDateTime(CoviMap params) throws Exception;
	public CoviList getAttendUserGroupAutoTagList(CoviMap params) throws Exception;
	public CoviMap getMyManagerName(String userCode) throws Exception;
	public CoviList getAssList() throws Exception;

	public int getMonthlyMaxWorkTime(String targetDate) throws Exception;

	public CoviMap getRewardTimeInfo(CoviMap params) throws Exception;
	public CoviMap getDeptListJobType() throws Exception;

}