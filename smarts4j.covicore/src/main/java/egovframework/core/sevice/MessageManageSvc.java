package egovframework.core.sevice;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface MessageManageSvc {
	
	/*기본기능*/
	//통합 메세징 마스터 메시지 목록 조회
	CoviMap selectMasterMessageList(CoviMap params) throws Exception;
	
    //통합메세징 관련 서브 정보 조회
	CoviMap selectMessagingSubData(CoviMap params) throws Exception;

    //통합메세징 초기화
	int initMessagingData(CoviMap params) throws Exception;
	
	//통합메세징 관련 정보 수정
	int updateMessagingData(CoviMap params) throws Exception;

    //통합메세징 관련 정보 삭제
	int deleteMessagingData(CoviMap params) throws Exception;
	
	//통합메세징 관련 발송 승인 목록
	CoviMap selectMessagingApprovalList(CoviMap params) throws Exception;
		
	
	/*부가기능*/
	//통합메세징 발송전 처리사항
	public CoviMap sendMessagingBefore(CoviMap params) throws Exception;
	//단건 전송용(큐)
	public CoviMap sendMessagingBefore(String messagingID) throws Exception;
	
	public CoviMap getMessagingBefore(CoviMap params) throws Exception;
	
	//통합메세징(그룹대상) 발송후 처리사항
	public int sentMessagingGroup(CoviList params) throws Exception;
	
	//통합메세징 관련 발송 승인 요청 시 부분 승인
	int updateMessagingPartialApproval(CoviMap params) throws Exception;


	/*InternalWebService*/
	//통합 메세징 관련 서비스( 매체별 처리 : 송신 및 결과 처리를 각 매체별로 처리 )
	public CoviMap sendMessaging(CoviMap targetMsgObj) throws Exception;

	public CoviMap selectBaseCode() throws Exception;
	
	
	//메세지 유형 설정 저장
	int setMessagingType(CoviMap params)throws Exception;	;

	//Badge 개수 조회
	public String selectBadgeCount(String pUserID) throws Exception;	

	public CoviMap selectMessagingList(CoviMap params) throws Exception;	
	
	//메시지유형관리 삭제
	int deleteMessagingType(CoviMap params) throws Exception;
	
	public int updateMsgCnt (CoviMap params) throws Exception;
	public int updateMsgFailCompeleteStatus (CoviMap params) throws Exception;
	public int updateMsgSendType (CoviMap params) throws Exception;
	public int updateMsgThreadType (int messagingID) throws Exception;
}