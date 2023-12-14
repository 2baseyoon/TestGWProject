package egovframework.covision.coviflow.govdocs.service;



import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

public interface ApprovalGovDocSvc {
	
	public static final String OPENDOC_STATE_READY = "READY";
	public static final String OPENDOC_STATE_CONVPROGRESS = "CONVPROGRESS";
	public static final String OPENDOC_STATE_CONVERROR = "CONVERROR";
	public static final String OPENDOC_STATE_CONVCOMPLETE = "CONVCOMPLETE";
	
	public static final String OPENDOC_STATE_SENDPROGRESS = "SENDPROGRESS";//전송진행중
	public static final String OPENDOC_STATE_SENDERROR = "SENDERROR";
	public static final String OPENDOC_STATE_SENDCOMPLETE = "SENDCOMPLETE";
	
	public static final String OPENDOC_STATE_UPDATE = "UPDATE"; // 완료문서 문서수정됨.
	
	public String selectLog(Map<String, String> map) throws Exception;	
	public CoviMap selectGovApvHistory(CoviMap params) throws Exception;
	public CoviMap selectGovApvSend(CoviMap params) throws Exception;
	public CoviMap selectGovApvReceive(CoviMap params) throws Exception;
	public String selectGovAuthManage(CoviMap params) throws Exception;
	public CoviMap selectGovAuthManageList(CoviMap params) throws Exception;
	public CoviMap selectGovManager(CoviMap params) throws Exception;
	public CoviMap selectGovDocInOutManager(CoviMap params) throws Exception;
	public void insertGovDocUser(CoviMap params) throws Exception;
	public void deleteGovDocUser(CoviMap params) throws Exception;	
	public void insertGovDocInOutUser(CoviMap params) throws Exception;
	public void deleteGovDocInOutUser(CoviMap params) throws Exception;	
	public CoviMap selectGovHistory(CoviMap params) throws Exception;
	public void doSaveDocList(CoviMap pObj) throws Exception;
	//public int updateGovRecvStatus(CoviMap params)  throws Exception;
	public List<HashMap<String, String>> selectReceiveList(String uniqueId)  throws Exception;
	public int checkGovReceiveDoc(CoviMap params) throws Exception;
	public CoviMap selectGovDocListExcel(CoviMap params, String headerKey, String govDocs) throws Exception;
	
	//기록물대장
	public void executeRecordDocInsert(CoviMap spParams) throws Exception;
	public CoviMap selectRecordDocComboData(CoviMap params) throws Exception;
	public CoviMap selectRecordDocList(CoviMap params) throws Exception;
	public CoviMap selectRecordDocListExcel(CoviMap params, String headerKey) throws Exception;
	public void deleteRecordDoc(CoviMap params) throws Exception;	
	public void changeFileOfRecordDoc(CoviMap params) throws Exception;
	public CoviMap selectRecordDocInfo(CoviMap params) throws Exception;
	public void saveRecordDocInfo(CoviMap params) throws Exception;
	
	public void saveDocTempInfo(CoviMap params) throws Exception;
	public CoviMap selectDocTempInfo(CoviMap params) throws Exception;
	public void executeRecordDocInsert_KIC(CoviMap spParams) throws Exception;

	public CoviList selectExcelData(CoviMap params, String queryID) throws Exception;
	public CoviMap selectGovSendHistory(CoviMap params) throws Exception;
	public CoviMap selectTaskRecordInfo(CoviMap params) throws Exception;

	public String doRecordAttachFileSave(List<MultipartFile> mf_record, String strOrgFileInfo, String strDelFileInfo) throws Exception;
	public void updateReplyStatusInfo(CoviMap params) throws Exception;
	public void executeRecordDocSingleInsert(CoviMap spParams) throws Exception;
	public int updateRecordDocSeparation(CoviMap params)  throws Exception;
	public CoviMap selectGovSendInfoHistory(CoviMap params)throws Exception;

	public CoviMap selectGovSenderMasterList(CoviMap params) throws Exception;
	public CoviList selectGovSenderMaster(CoviMap params) throws Exception;
	public int insertSenderMasterData(CoviMap params) throws Exception;
	public int updateSenderMasterData(CoviMap params) throws Exception;
	public int deleteSenderMasterData(CoviMap params) throws Exception;
	//public int insertImgUploadData(CoviMap params) throws Exception;
	public int deleteImgUploadData(CoviMap params) throws Exception;
	public CoviList selectGovSenderMasterUpper(CoviMap params) throws Exception;
	int insertDocumentNumber(CoviMap params) throws Exception;
	public int selectRecordAdmin(CoviMap params) throws Exception;
	public int selectRecordDeptAdmin(CoviMap params) throws Exception;
	public int selectGovDocManager(CoviMap params) throws Exception;
}


