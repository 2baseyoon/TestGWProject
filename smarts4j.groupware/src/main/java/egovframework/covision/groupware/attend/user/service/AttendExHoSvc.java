package egovframework.covision.groupware.attend.user.service;


import egovframework.baseframework.data.CoviMap;


public interface AttendExHoSvc {

	/**
	* @Method Name : getExHoInfoList
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 :  연장/휴일 승인현황 리스트 조회
	* @param params
	* @return
	* @throws Exception
	*/
public CoviMap getExHoInfoList(CoviMap params) throws Exception ;
/**
	* @Method Name : updExHoInfo
	* @작성일 : 2019. 7. 3.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 연장/휴일 승인 상태 업데이트
	* @param params
	* @throws Exception
	*/
public void updExHoInfo(CoviMap params) throws Exception ;

/**
	* @Method Name : getExHoInfoExcelList
	* @작성일 : 2019. 8. 8.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 연장/휴일 승인현황 엑셀리스트
	* @param params
	* @return
	* @throws Exception
	
public CoviMap getExHoInfoExcelList(CoviMap params) throws Exception ;*/


	/**
	* @Method Name : getCallingInfoList
	* @작성일 : 2019. 11. 22.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 :  소명신청서 리스트 조회
	* @param params 
	* @return
	* @throws Exception
	*/
public CoviMap getCallingInfoList(CoviMap params) throws Exception ;
public CoviMap getAttendExcelList(CoviMap params) throws Exception ;

	/**
	* @Method Name : getExHoTimeInfo
	* @작성일 : 2023. 04. 10.
	* @작성자 : sjhan0418
	* @Method 설명 : 연장/휴일 근무 현황에서의 근무신청 시간 조회
	* @param params 
	* @return
	* @throws Exception
	 */
	public CoviMap getExHoTimeInfo(CoviMap params) throws Exception;

/**
* @Method Name : getCallingInfoExcelList
* @작성일 : 2019. 11. 22.
* @작성자 : sjhan0418
* @변경이력 : 최초생성
* @Method 설명 :  소명신청서 엑셀 다운로드
* @param params
* @return
* @throws Exception

public CoviMap getCallingInfoExcelList(CoviMap params) throws Exception ;
*/

}
