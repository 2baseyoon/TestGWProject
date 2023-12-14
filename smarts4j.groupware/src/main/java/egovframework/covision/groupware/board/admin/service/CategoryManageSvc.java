package egovframework.covision.groupware.board.admin.service;

import egovframework.baseframework.data.CoviMap;



public interface CategoryManageSvc {
	public int createCategory(CoviMap params)throws Exception;				//확장 옵션 탭: Category 생성
	public int updateCategory(CoviMap params)throws Exception;				//확장 옵션 탭: Category Display Name 수정
	public int updateCategoryPath(CoviMap params)throws Exception;			//확장 옵션 탭: SortPath, CategoryPath 수정
	public int deleteCategory(CoviMap params)throws Exception;				//확장 옵션 탭: Category 삭제
	public int initMessageCategoryID(CoviMap params)throws Exception;		//삭제된 CategoryID를 사용하는 게시글 CategoryID를 NULL로 수정
	public CoviMap selectCategoryList(CoviMap param) throws Exception;	//확장옵션 탭: 카테고리 사용 - 대분류/소분류 
}
