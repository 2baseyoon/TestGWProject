package egovframework.covision.groupware.privacy.user.service;

import java.util.Set;


import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

public interface PrivacySvc {
	public CoviMap getUserPrivacySetting(CoviMap params) throws Exception;	// 개인환경 설정 > 기본정보
	public CoviMap getUserBaseGroupAll(CoviMap params) throws Exception;		// 메뉴 > 겸직변경 정보 조회
	public CoviMap getUseBaseGroup(CoviMap params) throws Exception;			// 겸직 단일 데이터 조회
	public CoviMap getUserGroupName(CoviMap params) throws Exception;	// 다국어 데이터 조회
	
	public int checkPasswordCnt(CoviMap params) throws Exception; // 개인환경 설정 진입 시 본인 비밀번호 확인
	
	public String selectUserAuthetication(CoviMap params) throws Exception; 
	
	public int updateUserInfo(CoviMap params) throws Exception;	// 개인환경 설정 > 기본정보 수정
	
	public int updateUserAbsense(CoviMap params) throws Exception;	// 개인환경 설정 > 부재설정 수정
	
	public int updateUserPush(CoviMap params) throws Exception;	// 개인환경 설정 > PUSH알림설정 수정
	
/*	public CoviMap getUserLoginPassword(CoviMap params) throws Exception;	// 개인환경설정 > 비밀번호 변경 > 기존 패스워드 조회
	
	public int updateUserPassword(CoviMap params,HttpServletRequest request, HttpServletResponse response) throws Exception;	// 개인환경설정 > 비밀번호 변경 > 변경	
	*/
	public CoviMap getUserMessagingSetting(CoviMap params) throws Exception;		// 개인환경설정 > 통합 메세징 설정 조회
	
	public int updateUserMessagingSetting(CoviMap params) throws Exception;	// 개인환경설정 > 통합 메세징 설정
	
	public int deleteUserMessagingSetting(CoviMap params) throws Exception;	// 개인환경설정 > 통합 메세징 설정 > 모두 초기화
	
	public CoviMap getConnectionLogList(CoviMap params) throws Exception;	// 개인환경설정 > 접속이력
	
	public int updateTopMenuManage(CoviMap params) throws Exception;	// 사이트맵 > 메인메뉴 설정 팝업
	
	public CoviMap getAnniversaryList(CoviMap params) throws Exception;	// 개인환경설정 > 기념일 관리
	
	public int insertAnniversary(CoviMap params) throws Exception;// 개인환경설정 > 기념일 관리 > 추가
	
	public int updateAnniversary(CoviMap params) throws Exception;	// 개인환경설정 > 기념일 관리 > 수정
	
	public int deleteAnniversary(CoviMap params) throws Exception;	// 개인환경설정 > 기념일 관리 > 삭제
	
	public int insertAnniversaryByExcel(CoviMap params) throws Exception;	// 개인환경설정 > 기념일 관리 > 기념일 가져오기 > 엑셀 업로드
	
	public CoviMap updateUserImage(CoviMap params) throws Exception;	// 개인환경설정 > 기본정보 > 이미지업로드
	
	public int updateThemeType(CoviMap params) throws Exception;	// 테마 변경

	public CoviList selectMyPortalList(Set<String> authorizedObjectCodeSet, String userID) throws Exception;	// 포탈목록
	
	public boolean removeGmail(CoviMap params)throws Exception;
	
	public boolean getTSSyncTF() throws Exception;
	
	public boolean getUsersyncexistuser(CoviMap params) throws Exception;
	
	public int setUserPhoto(CoviMap params) throws Exception;
	
}
