package egovframework.covision.groupware.board.admin.service;

import egovframework.baseframework.data.CoviMap;



public interface ProgressStateManageSvc {
	public int createProgressState(CoviMap params)throws Exception;				//확장 옵션 탭: Category 생성
	public int updateProgressState(CoviMap params)throws Exception;				//확장 옵션 탭: Category Display Name 수정
	public int deleteProgressState(CoviMap params)throws Exception;				//확장 옵션 탭: Category 삭제
	public int initMessageCategoryID(CoviMap params)throws Exception;		//삭제된 CategoryID를 사용하는 게시글 CategoryID를 NULL로 수정
	public CoviMap selectProgressStateList(CoviMap param) throws Exception;	//확장옵션 탭: 카테고리 사용 - 대분류/소분류 
}
