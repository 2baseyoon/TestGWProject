package egovframework.covision.groupware.contents.user.service;

import java.io.File;
import java.util.List;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface ContentsUserSvc {
	public CoviMap selectContentsList(CoviMap params) throws Exception;				//컨텐츠 앱 목록 조회
	public int addContentsFavorite(CoviMap params) throws Exception;				//즐겨찾기
	public int deleteContentsFavorite(CoviMap params) throws Exception;				//즐겨찾기 해제
	public CoviMap selectContentsName(CoviMap params) throws Exception;				//컨텐츠 앱 이름변경 조회
	public int updateContentsNameChange(CoviMap params) throws Exception;			//컨텐츠 앱 이름변경 처리
	public int selectUserFormKey(CoviMap params) throws Exception;					//사용자 정의 폼 추가 UserFormID 조회
	public CoviMap selectUserFormData(CoviMap params) throws Exception;				//사용자 정의 폼 현재 UserFormData 조회
	public int updateUserDefField(CoviMap params, List formList)throws Exception;	//사용자 정의 필드 추가 및 수정
	public int updateUserformGotoLink(CoviMap params) throws Exception;				//연결링크 수정
	public int insertFolderChart(CoviMap params)  throws Exception ;				//차트 저장
	public int updateFolderChart(CoviMap params)  throws Exception ;				//차트 수정
	public int deleteFolderChart(CoviMap params)  throws Exception ;				//차트 삭제
	public CoviList getFolderChartList(CoviMap params) throws Exception;
	public CoviList getChartData(CoviMap params) throws Exception;
	public CoviMap selectBoardConfigIcon(CoviMap params) throws Exception;			//아이콘 조회
	public int updateBoardConfigIcon(CoviMap params) throws Exception;				//아이콘 수정
	public int updateBoardConfigBody(CoviMap params) throws Exception;				//본문사용
	public CoviMap selectContentsFolderMenu(CoviMap params) throws Exception;		//컨텐츠 앱 폴더 메뉴 조회 
	public CoviMap selectTargetFolder(CoviMap params) throws Exception;				//이동할 폴더 조회
	public int updateTargetFolder(CoviMap params) throws Exception;					//컨텐츠 앱 폴더 이동 처리
	public int updateBoardConfigSort(CoviMap params) throws Exception ;				//목록 리스트 저장
	public CoviMap selectUserFormImageData(CoviMap params) throws Exception;		//사용자 정의 폼 삭제전 image 유무 조회
	public CoviMap selectUserDefFieldGridList(CoviMap params) throws Exception;		//사용자 정의 필드 Grid 데이터 조회
	public int insertSaveFolder(CoviMap params)  throws Exception;					//대상 폴더 테이블의 데이터로 추가
	public int insertBoardConfig(CoviMap params)  throws Exception;					//대상 게시판 설정 테이블의 데이터로 추가	
	public boolean copy(File sourceFile, File targetFile) throws Exception;							//파일 복사 

}
