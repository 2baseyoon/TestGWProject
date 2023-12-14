package egovframework.covision.groupware.board.user.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;




public interface MessageSvc {
	//boardType: 나의 게시 하위 메뉴 게시판 항목
	int selectMessageGridCount(CoviMap params) throws Exception;
	CoviMap selectMessageGridList(CoviMap params) throws Exception;		//게시물 Grid 리스트 조회
	CoviMap selectMessageExcelList(CoviMap params) throws Exception;		//게시물 엑셀 리스트 조회
	CoviMap selectMessageDetail(CoviMap params) throws Exception;		//게시물 상세보기 내용 조회
	
	//boardType: 문서배포 메뉴데이터 조회
	int selectDistributeGridCount(CoviMap params) throws Exception;
	CoviMap selectDistributeGridList(CoviMap params) throws Exception;
	CoviMap selectDistributeGridExcelList(CoviMap params) throws Exception;
	
	//boardType: Normal인 게시판 항목(Tree 메뉴 하위 게시판)
	int selectNormalMessageGridCount(CoviMap params) throws Exception;
	CoviMap selectNormalMessageGridList(CoviMap params) throws Exception;	//게시물 통계 Grid 리스트 조회
	CoviMap selectNormalMessageExcelList(CoviMap params) throws Exception;	//엑셀다운로드용 조회
	CoviMap selectPrevNextMessage(CoviMap params) throws Exception;			//이전글/다음글 조회
	
	int selectSearchMessageGridCount(CoviMap params) throws Exception;			//바인더/연결용 게시글 조회목록
	CoviMap selectSearchMessageGridList(CoviMap params) throws Exception;	
	
	int selectDocInOutHistoryGridCount(CoviMap params) throws Exception;		//문서 관리 개정이력 조회
	CoviMap selectDocInOutHistoryGridList(CoviMap params) throws Exception;	//문서 관리 개정이력 조회
	
	CoviMap selectNoticeMessageList(CoviMap params) throws Exception;		//웹파트용 공지 게시글 조회
	CoviMap selectLatestMessageList(CoviMap params) throws Exception;		//웹파트용 최근 게시, 문서글 조회
	CoviMap selectPopupNoticeList(CoviMap params) throws Exception;			//웹파트용 팝업 게시 조회
	CoviMap selectSystemLinkBoardList(CoviMap params) throws Exception;		//웹파트용 링크사이트 게시글 조회
	
	CoviList selectTypeList(CoviMap params) throws Exception;		//게시 분류 목록 조회
	
	CoviMap selectMessageTagList(CoviMap params) throws Exception;		//태그 목록 조회	
	CoviMap selectMessageLinkList(CoviMap params) throws Exception;		//링크 목록 조회
	CoviMap selectLinkedMessageList(CoviMap params) throws Exception;	//연결글, 바인더 목록 조회
	CoviMap selectLinkedFeedMessageList(CoviMap params) throws Exception;	//피드 연결글 목록 조회
	CoviMap selectProcessActivityList(CoviMap params) throws Exception;	//승인프로세스 목록 조회
	List<CoviMap> selectProcessActorList(CoviMap params) throws Exception;	//승인프로세스 승인자 목록 조회
	CoviMap selectRevisionHistory(CoviMap params) throws Exception;		//문서 관리 개정 처리이력 조회 
	CoviMap selectUserDefFieldValue(CoviMap params) throws Exception;	//사용자정의 필드 설정 값 조회
	CoviMap selectBodyFormData(CoviMap params) throws Exception;			//본문양식 파일 경로 조회
	CoviMap selectContentMessage(CoviMap params) throws Exception;			//콘텐츠 타입 게시글 조회
	CoviMap selectMessageOwner(CoviMap params) throws Exception;			//게시판 담당자 조회
	String selectBoardGroupName(CoviMap params) throws Exception;			//게시판 그룹명 조회
	String selectMultiFolderName(CoviMap params) throws Exception;			//다중분류 폴더명 조회
	
	int createMessage(CoviMap params, List<MultipartFile> mf) throws Exception;		//게시글 작성
	int createSimpleMessage(CoviMap params) throws Exception;		//게시글 작성
	int updateMessage(CoviMap params, List<MultipartFile> mf) throws Exception;		//게시글 수정
	int deleteMessage(CoviMap params) throws Exception;		//게시글 삭제
	int deleteTempMessage(CoviMap params) throws Exception;	//임시 저장 게시물 삭제
	int moveMessage(CoviMap params) throws Exception;		//게시글 이동
	int copyMessage(CoviMap params) throws Exception;		//게시글 복사
	int scrapMessage(CoviMap params) throws Exception;		//게시글 복사
	int checkExistReport(CoviMap params) throws Exception;	//신고 중복체크
	int reportMessage(CoviMap params) throws Exception;		//게시글 신고
	int acceptMessage(CoviMap params) throws Exception;		//게시글 승인
	int rejectMessage(CoviMap params) throws Exception;		//게시글 거부
	int requestModifyMessage(CoviMap params) throws Exception;		//게시글 수정요청
	int distributeDoc(CoviMap params) throws Exception;		//문서글 배포
	
	int selectMessageCheckOutStatus(CoviMap params) throws Exception;	//게시글 체크아웃 상태변경 가능 여부 확인
	int updateCheckOutState(CoviMap params) throws Exception;			//게시글 체크아웃 상태변경

	//mobile
	CoviMap selectMessageDetailSimple(CoviMap params) throws Exception;
	CoviMap selectMessageViewerGridList(CoviMap params) throws Exception;		//게시물 조회자 목록 조회
	int selectMessageViewerGridCount(CoviMap params) throws Exception;
	int createSCCMessage(CoviMap params) throws Exception;   //[본사운영] 품질관리 - SCC 연동: 게시 등록 API
	
	int createMailToMessage(CoviMap params, List<MultipartFile> mf) throws Exception;		//메일로 게시판 작성
	CoviMap updateUserDefFieldValueOne(CoviMap params) throws Exception;	//사용자정의 필드 설정 값 변경
	
	CoviMap selectRequestAuthMessageInfo(CoviMap params) throws Exception;	//문서 권한요청을 위한 기본적인 메세지 정보 조회 (제목, 소유자)
	CoviMap selectMovieBoardList(CoviMap params) throws Exception;	// 웹파트 추천영상 데이터 조회
	
	CoviMap getMessageInfo(CoviMap pParams) throws Exception;
	
	void createFileDownloadToMessageReader(CoviMap params) throws Exception;	// 게시 목록에서 파일 다운로드 및 미리보기 시도 시 조회자 추가
	
}
