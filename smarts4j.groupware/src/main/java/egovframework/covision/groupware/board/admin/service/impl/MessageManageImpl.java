package egovframework.covision.groupware.board.admin.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.board.admin.service.MessageManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("MessageManageSvc")
public class MessageManageImpl extends EgovAbstractServiceImpl implements MessageManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int selectMessageGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectMessageGridCount", params);
	}
	/**
	 * 게시 관리자 게시물 Grid 조회
	 * @param params DomainID, MenuID, FolderID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectMessageGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,FolderName,CategoryID,Subject,ExpiredDate,MsgState,RegistDate,DeleteDate,FileCnt,FileExtension,CreatorCode,CreatorName,ReportID,ReportUserCode,ReportUserName,ReportDate,ReportComment,LockDate,RequestID,RequestMessage,RequestorCode,RequestorName,RequestDate,AnswererCode,AnswererName,AnswerContent,AnswerDate,RequestStatus,Seq,Step,Depth,OwnerCode,OwnerName,RegistDept,RegistDeptName,IsCheckOut,RevisionDate,Number,MsgStateDetail"));
		return resultList;
	}
	
	/**
	 * 게시 관리자 게시물 엑셀 데이터 조회 - 수정요청 게시물 관리 기준
	 * @param params DomainID, MenuID, FolderID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageExcelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectMessageGridList",params);
		int cnt = (int) coviMapperOne.getNumber("admin.message.selectMessageGridCount", params);
		
		if(params.get("boardType").equals("OwnerManage")){
			resultList.put("list",CoviSelectSet.coviSelectJSON(list, "Version,FolderName,Subject,IsCheckOut,RegistDeptName,OwnerName,RevisionDate"));
		}else{
			resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,FolderName,Subject,RequestorName,RequestDate,RequestMessage,AnswerContent,RequestStatus"));
		}
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * 게시 관리자 통계 게시물 Count
	 * @param params DomainID, MenuID, FolderID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectMessageStatsGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectMessageStatsGridCount", params);
	}	
	
	/**
	 * 게시 관리자 통계 게시물 Grid 조회
	 * @param params DomainID, MenuID, FolderID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageStatsGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectMessageStatsGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,FolderName,Subject,DeleteDate,FileCnt,CreatorCode,CreatorName,CreateDate,ReadCnt,CommentCnt,EmpNo,RegistDate,RecommendPoint"));
		return resultList;
	}
	
	/**
	 * 게시글 통계 목록 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageStatsExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectMessageStatsGridList",params);
		int cnt = (int) coviMapperOne.getNumber("admin.message.selectMessageStatsGridCount", params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,CreatorName,CreatorCode,EmpNo,FolderName,Subject,RegistDate,ReadCnt,CommentCnt,RecommendPoint"));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * 게시글 조회자 Grid Count
	 * @param params MessageID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectMessageViewerGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectMessageViewerGridCount", params);
	}	
	/**
	 * 게시글 조회자 Grid 조회
	 * @param params MessageID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageViewerGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.message.selectMessageViewerGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,ReaderCode,DisplayName,JobPositionName,DeptName,ReadDate"));
		return resultList;
	}
	
	/**
	 * 게시글 처리이력 Grid 조회
	 * @param params MessageID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectMessageHistoryGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectMessageHistoryGridCount", params);
	}
	
	/**
	 * 게시글 처리이력 Grid 조회
	 * @param params MessageID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageHistoryGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectMessageHistoryGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,HistoryType,Comment,RegistIP,RegistDate,RegisterCode,DisplayName,DeptName"));
		return resultList;
	}
	
	/**
	 * 문서번호 현황 관리 목록
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectDocNumberGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectDocNumberGridCount", params);
	}
	
	/**
	 * 문서번호 발번 관리 목록
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDocNumberGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectDocNumberGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "DomainID,DomainName,ManagerID,Seq,FieldType,FieldLength,LanguageCode,Separator,IsUse,CreateDate"));
		return resultList;
	}
	
	/**
	 * 문서번호 현황 관리 목록
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectDocNumberStatsGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.message.selectDocNumberStatsGridCount", params);
	}
	
	/**
	 * 문서번호 현황 관리 목록
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDocNumberStatsGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.message.selectDocNumberStatsGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "DomainID,DomainName,Prefix,Number,CreateDate"));
		return resultList;
	}
	

	/**
	 * 처리 이력 추가
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int createHistory(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.message.createHistory", params);			//게시글 삭제/복원/잠금/잠금해제시 처리사유로 입력항 정보 추가
	}
	
	/**
	 * 처리 이력 삭제
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int deleteMessage(CoviMap params) throws Exception {
		
		// 예약게시 알림 삭제를 위해 bizSection 추가
		params.put("bizSection", "Board");
		
		// 예약 게시인지 체크 등록일 > 현재시간
		int reservationDateCheckCnt = (int) coviMapperOne.getNumber("admin.message.selectReservationDateCheckCnt", params);
		
		// 등록일 > 현재시간인 경우 알림 취소
		if(reservationDateCheckCnt > 0) {
			coviMapperOne.update("framework.messaging.updateCancelMsgbyBoard", params);
		}
		
		coviMapperOne.update("admin.message.updateCurrentFileSizeByMessage", params);	//게시글 삭제게시글 점유용량 수정
		return coviMapperOne.update("admin.message.deleteMessage", params);				//게시글 삭제
	}

	/**
	 * 하위 게시글 삭제
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int deleteLowerMessage(CoviMap params) throws Exception {
		int cnt = 0;
		//하위 게시글 검색
		params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
		params.put("messageIDArr", params.getString("messageIDs").split(","));
		if(params.get("messageIDs")!=null){
			cnt += coviMapperOne.update("admin.message.deleteLowerMessage", params);
		}
		return cnt;
	}

	/**
	 * 게시글 잠금
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int lockMessage(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.message.lockMessage", params);			//게시글 잠금
	}

	/**
	 * 하위 게시글 잠금
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int lockLowerMessage(CoviMap params) throws Exception {
		int cnt = 0;
		//하위 게시글 검색
		params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
		params.put("messageIDArr", params.getString("messageIDs").split(","));
		if(params.get("messageIDs")!=null){
			cnt = coviMapperOne.update("admin.message.lockLowerMessage", params);
		}
		return cnt;
	}

	/**
	 * 게시글 잠금 해제
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int unlockMessage(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.message.unlockMessage", params);			//게시글 잠금해제
	}

	/**
	 * 하위 게시글 잠금 해제
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int unlockLowerMessage(CoviMap params) throws Exception {
		int cnt = 0;
		//하위 게시글 검색
		params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
		params.put("messageIDArr", params.getString("messageIDs").split(","));
		if(params.get("messageIDs")!=null){
			cnt += coviMapperOne.update("admin.message.unlockLowerMessage", params);
		}
		return cnt;
	}

	/**
	 * 게시글 복원
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int restoreMessage(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.message.restoreMessage", params);			//게시글 복원
	}

	/**
	 * 하위 게시글 복원
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int restoreLowerMessage(CoviMap params) throws Exception {
		int cnt = 0;
		//하위 게시글 검색
		params.put("messageIDs", coviMapperOne.select("admin.message.selectLowerMessageID", params).get("messageIDs"));
		params.put("messageIDArr", params.getString("messageIDs").split(","));
		if(params.get("messageIDs")!=null){
			cnt += coviMapperOne.update("admin.message.restoreLowerMessage", params);
		}
		return cnt;
	}
	
	/**
	 * 수정요청 상태 변경
	 * @param params DomainID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int updateRequestStatus(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.message.updateRequestStatus", params);
	}
}
