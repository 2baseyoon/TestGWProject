package egovframework.covision.groupware.board.manage.service;

import egovframework.baseframework.data.CoviMap;

public interface MessageVManageSvc {
	public CoviMap selectMessageGridList(CoviMap params) throws Exception;		//게시물 Grid 리스트 조회
	public CoviMap selectMessageExcelList(CoviMap params) throws Exception;		//게시물 엑셀 리스트 조회
	public CoviMap selectMessageManageExcelList(CoviMap params) throws Exception;		//게시물 엑셀 리스트 조회
	public CoviMap selectMessageStatsGridList(CoviMap params) throws Exception;		//게시물 통계 Grid 리스트 조회
	public CoviMap selectMessageStatsExcelList(CoviMap params) throws Exception;		//통계용 엑셀용 조회
	public CoviMap selectMessageViewerGridList(CoviMap params) throws Exception;		//게시물 조회자 목록 조회
	public CoviMap selectMessageHistoryGridList(CoviMap params) throws Exception;	//게시물 처리 이력 조회
	public int selectMessageGridCount(CoviMap params) throws Exception;
	public int selectMessageStatsGridCount(CoviMap params) throws Exception;
	public int selectMessageViewerGridCount(CoviMap params) throws Exception;
	public int selectMessageHistoryGridCount(CoviMap params) throws Exception;
	
	public CoviMap selectDocNumberGridList(CoviMap params) throws Exception;	//문서관리 번호 조회
	public int selectDocNumberGridCount(CoviMap params) throws Exception;
	public CoviMap selectDocNumberStatsGridList(CoviMap params) throws Exception;	//문서관리 통계 조회
	public int selectDocNumberStatsGridCount(CoviMap params) throws Exception;
	
	public int createHistory(CoviMap params)throws Exception;
	
	public int deleteMessage(CoviMap params)throws Exception;		//삭제
	public int deleteLowerMessage(CoviMap params)throws Exception;	//하위 게시판 삭제
	
	public int lockMessage(CoviMap params)throws Exception;			//잠금
	public int lockLowerMessage(CoviMap params)throws Exception;	//하위 게시판 잠금
	
	public int unlockMessage(CoviMap params)throws Exception;		//잠금해제
	public int unlockLowerMessage(CoviMap params)throws Exception;	//하위 게시판 잠금해제
	
	public int restoreMessage(CoviMap params)throws Exception;		//복원
	public int restoreLowerMessage(CoviMap params)throws Exception;	//하위 게시판 복원
	
	public int updateRequestStatus(CoviMap params)throws Exception;	//수정요청 게시물 상태 변경
}
