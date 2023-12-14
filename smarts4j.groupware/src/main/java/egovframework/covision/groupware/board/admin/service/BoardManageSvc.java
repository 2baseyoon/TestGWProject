package egovframework.covision.groupware.board.admin.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface BoardManageSvc {
	int pasteBoard(CoviMap params)throws Exception;				//붙여넣기
	int createBoard(CoviMap params)throws Exception;				//추가
	int createBoardConfig(CoviMap params)throws Exception;		//board_config 게시판 옵션 정보 저장
	int updateBoard(CoviMap params) throws Exception;			//게시판 기본정보 수정
	int updateBoardConfig(CoviMap params) throws Exception; 		//board_config 게시판 옵션 수정
	int deleteBoard(CoviMap params)throws Exception;				//삭제
	int deleteLowerBoard(CoviMap params)throws Exception;		//하위 게시판 삭제
	int updateFlag(CoviMap params)throws Exception;				//Use, Display 변경
	int updateDocNumberFlag(CoviMap params)throws Exception;	//문서번호 발번 Use 변경
	int restoreFolder(CoviMap params)throws Exception;			//폴더 복원
	int updateBoardSortKey(CoviMap params)throws Exception;		//폴더 SortKey 변경
	
	int updateOrginalFolder(CoviMap params)throws Exception;		//원본 폴더 메뉴ID, SortKey, SortPath, FolderPath, MemberOf 업데이트
	int updateLowerFolder(CoviMap params)throws Exception;		//원본폴더의 하위 폴더 정보 업데이트
	int updateExpiredDay(CoviMap params) throws Exception;		//만료일 일괄 수정
	
	CoviMap selectBoardDescription(CoviMap param) throws Exception;	//확장옵션: 게시판 설명 조회
	String selectContentsID(CoviMap param) throws Exception; // 게시판 contentsid 조회
	int createBoardDescription(CoviMap params)throws Exception;			//확장옵션: 게시판 설명 추가
	int updateBoardDescription(CoviMap params)throws Exception;			//확장옵션: 게시판 설명 수정
	int deleteBoardDescription(CoviMap params)throws Exception;			//확장옵션: 게시판 설명 삭제
	
	CoviMap selectBodyForm(CoviMap param) throws Exception;		//확장옵션: 본문양식 조회
	int createBodyForm(CoviMap params)throws Exception;				//확장옵션: 본문양식 생성
	int updateBodyFormInit(CoviMap params)throws Exception;			//확장옵션: 본문양식 초기양식 설정/IsInit
	int deleteBodyForm(CoviMap params)throws Exception;				//확장옵션: 본문양식 삭제
	
	CoviMap selectMenuByDomainID(CoviMap params) throws Exception;				//도메인에 해당하는 통합게시 MenuID조회
	CoviMap selectDocNumberInfo(CoviMap params) throws Exception;				//도메인에 해당하는 통합게시 MenuID조회
	int selectNextSortKey(CoviMap params) throws Exception;					//게시판 생성시 사용될 Sortkey
	
	int changeDocInfo(CoviMap params) throws Exception;
	int createDocNumber(CoviMap params) throws Exception;
	int updateDocNumber(CoviMap params) throws Exception;
	int deleteDocNumber(CoviMap params) throws Exception;
	
	int createCommunityTopMenu(CoviMap params) throws Exception; //커뮤니티 탑 메뉴 생성.
	
	CoviMap selectDomainList(CoviMap params) throws Exception;			//도메인/회사 조회
	CoviMap selectFolderTypeList(CoviMap params) throws Exception;		//폴더 타입 조회
	CoviMap selectSecurityLevelList(CoviMap params) throws Exception;	//보안등급 목록 조회
	CoviMap selectRequestStatusList(CoviMap params) throws Exception;	//처리상태 목록
	CoviMap selectAdmin_LeftBoardMenu(CoviMap params) throws Exception;	//관리자 Left Menu 조회
	CoviMap selectTreeFolderMenu(CoviMap params) throws Exception;		//폴더/게시판 트리 메뉴 조회
	CoviMap selectFolderGridList(CoviMap params) throws Exception;		//폴더 Grid 리스트 조회
	CoviMap selectPathInfo(CoviMap param) throws Exception;					//sortPath, folderPath 정보 조회
	CoviMap selectDefaultConfig(CoviMap param) throws Exception;			//폴더 타입별 기본설정 데이터 조회 : covi_smart4j.board_config_default
	CoviMap selectBoardConfig(CoviMap param) throws Exception;				//게시판별 설정된 옵션 조회 : covi_smart4j.board_config, sys_object_folder
	CoviMap selectBoardOwnerName(CoviMap param) throws Exception;		//게시판 담당자 이름 조회
	CoviMap selectTargetFolderSortKey(CoviMap params)throws Exception;	//붙여넣기: 폴더 정보 조회
	CoviMap selectTargetBoardSortKey(CoviMap params)throws Exception;	//순서 변경용: 게시판정보 조회
	CoviMap selectProcessPerformerList(CoviMap params) throws Exception;	//승인프로세스 조회
	CoviMap selectProcessTarget(CoviMap params) throws Exception;		//ProcessID 조회 sys_process_target
	CoviMap selectBaseCodeList(CoviMap params) throws Exception;
	CoviMap selectMenuList(CoviMap params) throws Exception;
	CoviMap selectCommunityList(CoviMap params) throws Exception;
	CoviMap selectCommunityFolderTypeList(CoviMap params, String type) throws Exception;
	CoviMap selectFieldLangInfos(CoviMap params) throws Exception;		//언어별 필드명 조회
	int updateFieldSeq(CoviMap params) throws Exception;					//우선순위 상위,하위로.
	
	CoviList selectInheritedACLList(CoviMap params) throws Exception; // 권한 상속 > 하위 폴더 목록 조회
	CoviMap selectPrevNextField(CoviMap params) throws Exception;
	
	int updateCategoryManager(CoviMap params) throws Exception;			// 확장옵션: 게시분류 담당자 수정
}