package egovframework.core.sevice;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface LoginSvc {
	/**
	 * checkAuthetication 메소드.
	 * 
	 * @param exception 실제로 발생한 Exception 
	 * @param packageName Exception 발생한 클래스 패키지정보
	 */
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception;
	public int saveLoginInfo(CoviMap account) throws Exception;
	public CoviMap selectSamlUser(String id) throws Exception;
	//public CoviMap selectPasswordPolicy(CoviMap params) throws Exception;
	public CoviMap selectDomainPasswordPolicy(CoviMap params) throws Exception;
	
	public String checkSSO(String OpType) throws Exception;
	public String selectUserAuthetication(String id, String password) throws Exception;
	public String selectUserMailAddress(String id) throws Exception;
	public String selectUserLanguageCode(String id) throws Exception;
	public String selectUserDomainUrl(CoviMap params) throws Exception;
	public CoviMap selectBaseCheckInfo(String id, String pw) throws Exception;
	
	public int checkUserAuthetication(String id, String password) throws Exception;
	public int checkSSOUserAuthetication(String id) throws Exception;
	public int checkPasswordCnt(CoviMap params)throws Exception;
	public int checkPasswordLogCnt(CoviMap params)throws Exception;
	//public int selectPasswordPolicyCount(CoviMap params)throws Exception;
	public int selectAccountLock(String id)throws Exception;
	public CoviMap selectUserFailCount(String id)throws Exception;
	public int selectOTPCheck(CoviMap params)throws Exception;
	public int selectOTPFailCount(CoviMap params)throws Exception;
	
	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id) throws Exception;
	public boolean updateUserFailCount(String id)throws Exception;
	public boolean updateUserLock(String id, String lock)throws Exception;
	public boolean deleteUserFailCount(String id)throws Exception;
	public boolean updateUserInitialConection(String id)throws Exception;
	public boolean updateUserPasswordClear(String id)throws Exception;
	public boolean updateLogoutTime(CoviMap params) throws Exception;

	public CoviMap selectTokenInForMation(String key) throws Exception;
	public CoviMap getMyInfo(String key) throws Exception;
	
	public CoviMap getUserLoginPassword(CoviMap params) throws Exception;	// 개인환경설정 > 비밀번호 변경 > 기존 패스워드 조회
	
	public String updateUserPassword(CoviMap params,HttpServletRequest request, HttpServletResponse response) throws Exception;	// 개인환경설정 > 비밀번호 변경 > 변경	
	public void mailTrashClear(CoviMap params) throws Exception;	//로그아웃 시 지운 편지함 지우기
	public boolean checkIPScope(String currentIP, String userStartIP, String userEndIP)throws Exception;	//IP 범위 체크

	public String selectVacationCreateMethod(CoviMap params) throws Exception;

	public CoviMap selectM365UserInfo(String userCode, String upn, String aadObjectId) throws Exception;
	public CoviMap selectM365AppInfo(String dnid, String scope) throws Exception;
	public CoviList getAddJobList(String key) throws Exception;
	
}
