package egovframework.covision.groupware.board.admin.service;

import egovframework.baseframework.data.CoviMap;



public interface UserDefFieldManageSvc {
	public CoviMap selectUserDefFieldGridList(CoviMap param) throws Exception;	//사용자 정의 필드 Grid  조회
	public int selectUserDefFieldGridCount(CoviMap params)throws Exception;
	public CoviMap selectUserDefFieldOptionList(CoviMap param) throws Exception;
	public CoviMap selectTargetUserDefFieldSortKey(CoviMap param) throws Exception;			//변경해야하는 sortkey값 조회
	public int createUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 추가
	public int updateUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 수정
	public int deleteUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 삭제
	public int createUserDefOption(CoviMap params)throws Exception;					//필드 옵션 추가
	public int deleteUserDefFieldOption(CoviMap params)throws Exception;			//필드 옵션 삭제
	public int deleteBoardMessageUserFormValue(CoviMap params)throws Exception;		//게시글에 반영된 필드 관련 데이터 삭제
	public int updateUserDefFieldSortKey(CoviMap params)throws Exception;						//순서 수정
	public int restoreUserDefFieldValue(CoviMap params)throws Exception;						//board_message_userform_value 테이블 재저장
	public int exchangeUserDefFieldSortKey(CoviMap params, CoviMap targetParams) throws Exception;						// 순서 변경
}
