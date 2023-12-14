package egovframework.coviframework.vo;

import java.io.Serializable;

public class Session implements Serializable {
	/*
	 * 	Session 항목에 대한 결정
	 * 
	- LanguageCode : 사용자 언어코드
	- LogonID		: 로그온 아이디
	- UR_Code		: 사용자 코드
	- UR_EmpNo		: 사용자 사번
	- UR_Name		: 사용자 이름
	- UR_CurrentName : 현재 세션에 설정된 언어의 사용자 이름
	- UR_ExName		: 사용자 다국어 이름(';'로 구분된 값)
	- UR_Mail		: 사용자 주 메일
	- UR_MailName		: 사용자 메일 발송 이름
	- UR_Tel		: 사용자 전화번호
	- UR_Mobile		: 사용자 모바일 번호
	- UR_Fax : 사용자 팩스번호
	- UR_SipAddress : 메신저 아이피
	- UR_JobPositionCode : 사용자 직위 코드
	- UR_JobPositionName : 사용자 다국어 직위명(';'로 구분된 값)
	- UR_JobPositionCurrentName : 현재 세션에 설정된 언어의 직위명
	- UR_JobTitleCode : 사용자 직책 코드
	- UR_JobTitleName : 사용자 다국어 직책명(';'로 구분된 값)
	- UR_JobTitleCurrentName : 현재 세션에 설정된 언어의 직책명
	- UR_JobLevelCode : 사용자 직급 코드
	- UR_JobLevelName : 사용자 다국어 직급명(';'로 구분된 값)
	- UR_JobLevelCurrentName : 현재 세션에 설정된 언어의 직급명
	- UR_InitPortal : 사용자 초기포탈 아이디
	- UR_RegionCode : 사용자 소속지역 코드
	- UR_RegionName : 사용자 소속지역 다국어명(';'로 구분된 값)
	- UR_RegionCurrentName : 현재 세션에 설정된 언어의 소속지역명
	- UR_TimeZoneCode : 사용자 타임존 코드
	- UR_TimeZone : 사용자 타임존
	- UR_ManagerCode : 부서장 코드
	- UR_IsManager : 부서장 여부(True|False)
	- UR_AddJobInfo : 겸직 정보 배열
	- UR_DisJobInfo : 파견 정보
	- DN_ID : 사용자 소속회사 도메인 아이디
	- DN_Code : 사용자 소속회사 코드
	- DN_DefaultCode : 사용자 원소속 회사 코드	
	- DN_DefaultID : 사용자 원 소속회사 도메인 아이디
	- DN_Name : 사용자 소속회사 이름
	- DN_CurrentName :  현재 세션에 설정된 언어의 소속회사 이름
	- DN_ExName : 사용자 소속회사 다국어 이름(';'로 구분된 값)
	- DN_DefaultExName : 사용자 원 소속회사 다국어 이름(';'로 구분된 값)
	- DN_DefaultCurrentName :  현재 세션에 설정된 언어의 원 소속회사 다국어 이름
	- DN_ShortName : 사용자 소속회사 약어 이름
	- DN_Theme : 도메인 테마 정보
	- GR_Code : 사용자 소속부서 코드
	- GR_DefaultCode : 사용자 원 소속부서 코드	
	- GR_Name : 사용자 소속부서 이름
	- GR_CurrentName :  현재 세션에 설정된 언어의 소속부서 이름
	- GR_ExName : 사용자 소속부서 다국어 이름(';'로 구분된 값)
	- GR_DefaultExName : 사용자 원 소속부서 다국어 이름
	- GR_DefaultCurrentName :  현재 세션에 설정된 언어의 소속부서 이름
	- GR_ShortName : 사용자 소속부서 약어 이름
	- GR_FullCode : 사용자 소속부서 전체경로 코드
	- GR_FullCodeArr : 사용자 소속부서 전체경로 코드 배열
	- GR_FullName : 사용자 소속부서 전체경로 이름
	- GR_FullNameArr : 사용자 소속부서 전체경로 이름 배열
	- AdminType : 관리자 유형
	- AdminInfo : 관리자 정보 배열
	- ApprovalFullCode : 결재자 풀 코드
	- ApprovalFullCodeArr : 결재자 풀 코드 배열
	- ApprovalParentGR_Code : 상위 부서 코드
	- ApprovalParentGR_Name : 상위 부서 이름
	- CommunityInfo : 커뮤니티 정보
	- CommunityInfoArr : 커뮤니티 정보 배열
		
	 * */
	/*
	 * HttpSession과 redis를 이중으로 사용하는 세션관리
	 * 
	 * case 1. HttpSession은 만료되었으나, redis Session이 남아 있는 경우 - Session 재생성
	 * case 2. HttpSession은 남아 있으나, redis Session이 만료된 경우 - Session 만료
	 * 
	 * 
	 * */

	private static final long serialVersionUID = -2792237489385597401L;

	private String id;
	private String name;
	private Integer age;

	public Session(){}
	
	public Session(String id, String name) {
		this.id = id;
		this.name = name;
	}
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getAge() {
		return age;
	}

	public void setAge(Integer age) {
		this.age = age;
	}

	public String toString() {
		return "Employee [" + getId() + ", " + getName() + "]";
	}
}