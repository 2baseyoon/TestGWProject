package egovframework.covision.groupware.board.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface BoardCommonSvc {
	CoviMap selectTreeFolderMenu(CoviMap params) throws Exception;		//폴더/게시판 트리 메뉴 조회
	CoviMap selectFolderPath(CoviMap params) throws Exception;			//상위 폴더 경로 조회
	
	int selectFavoriteGridCount(CoviMap params) throws Exception;			//즐겨찾기: 공통으로 분리되므로 작업 중지
	CoviMap selectFavoriteGridList(CoviMap params) throws Exception;		//
	
	CoviMap selectUserDefFieldList(CoviMap params) throws Exception;
	CoviMap selectUserDefFieldOptionList(CoviMap params) throws Exception;
	CoviMap selectBoardList(CoviMap params) throws Exception;			//CHECK: 게시판 목록 조회, 메소드이름이 크흠...
	CoviMap selectSimpleBoardList(CoviMap params) throws Exception;		//간편등록 전용 게시판 목록 조회
	CoviMap selectCategoryList(CoviMap params) throws Exception;			//Category SelectBox 조회
	CoviMap selectBodyFormList(CoviMap params) throws Exception;			//본문양식  SelectBox 조회
	CoviMap selectRegistDeptList(CoviMap params) throws Exception;		//사용자 부서 정보 검색
	CoviMap selectProgressStateList(CoviMap params) throws Exception;	//처리상태 목록 조회
	int updateMessageCheckOut(CoviMap params) throws Exception;				//문서게시글 수정진행시 체크아웃
	
	CoviMap selectMyInfoProfileBoardData(CoviMap params) throws Exception;
	CoviMap selectBoardIsMobileSupport(CoviMap params) throws Exception;
	
	public CoviList selectUserBoardTreeData(CoviMap params) throws Exception; // 이관 게시판 목록 조회(전자결재 완료문서에서 사용)
}
