
package egovframework.covision.coviflow.form.service;



import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviMap;

public interface NonApvProcessSvc {
	
	//참조/회람현황 목록조회
	public CoviMap getCirculationReadListData(CoviMap params) throws Exception;
	
	//참조/회람현황 항목삭제
	public int deleteCirculationReadData(String circulationBoxID, String ModID) throws Exception;
	
	//참조/회람현황 목록조회(이관함)
	public CoviMap getCirculationReadListDataStore(CoviMap params) throws Exception;
	
	//참조/회람현황 항목삭제(이관함)
	public int deleteCirculationReadDataStore(String circulationBoxID, String ModID) throws Exception;
	
	//변경이력조회(history)편집이력목록조회
	public CoviMap getHistoryListData(String fiid) throws Exception;
	
	//변경내용조회(history)편집이력목록조회
	public CoviMap getHistoryModifiedData(CoviMap params) throws Exception;

	//수신현황 목록조회
	public CoviMap getReceiptReadListData(CoviMap params) throws Exception;
	//수신현황 키값 조회1
	public String getParentProcessID1(String processID, String fiid) throws Exception;
	//수신현황 키값 조회2
	public String getParentProcessID2(String processID, String fiid) throws Exception;
	
	public CoviMap getReceiptReadListDataExcel(String processID1, String processID2, String SelectKey) throws Exception;
	
	//회람 조회
	public CoviMap getExistingCirculationList(String fiid, String kind) throws Exception;
	
	//회람 조회(이관함)
	public CoviMap getExistingCirculationListStored(String fiid, String kind) throws Exception;

	//회람자지정
	public int setCirculationDescription(CoviMap CirculationDataObj) throws Exception;
	
	//회람자지정(이관함)
	public int setCirculationDescriptionStored(CoviMap CirculationDataObj) throws Exception;

	//회람자지정
	public int setCirculation(CoviMap CirculationDataObj) throws Exception;
	
	//회람자지정(이관함)
	public int setCirculationStored(CoviMap CirculationDataObj) throws Exception;
	
	//추가 의견 등록
	public int insertComment(CoviMap params)throws Exception;
	public void setCommentMessage(CoviMap formObj) throws Exception;
	public String doCommentAttachFileSave(List<MultipartFile> mf_comment) throws Exception;
	
	//단위업무 목록 조회
	public CoviMap getSeriesListData(CoviMap params) throws Exception;
	//기록물철 목록 조회
	public CoviMap getRecordListData(CoviMap params) throws Exception;
	//기록물철 즐겨찾기 조회
	public CoviMap getFavRecordListData(CoviMap params) throws Exception;
	//기록물철 즐겨찾기 추가/삭제
	public int toggleRecordFav(CoviMap params) throws Exception;

	public CoviMap getFormInfoListStore(String fiid) throws Exception;

	//이미 회람했는지 여부 조회
	public int getExistingCirculationCnt(CoviMap params) throws Exception;
	public int getExistingCirculationStoreCnt(CoviMap params) throws Exception;
	public int selectCirculationAuth(CoviMap params) throws Exception;	
	
	// 기록물 권한 조회
	public boolean getRecordDocAuthData(CoviMap params) throws Exception;
	// 기목물 읽음 처리
	public int insertRecordDocRead(CoviMap params) throws Exception;
	// 기록물 읽은 사용자 목록 조회
	public CoviMap getRecordDocReaderListData(CoviMap params) throws Exception;
	
	public String getOriginWorkItemID(CoviMap params) throws Exception;
	
	//문서유통 배부이력 확인을 위한 ProcessID 조회
	public List<Object> selectArrayProc(String formInstID) throws Exception;
	
	public int selectTotalSearch(CoviMap params) throws Exception;
}
