package egovframework.covision.coviflow.form.service;

import java.util.List;

import egovframework.baseframework.data.CoviMap;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;


public interface FormSvc {
	public void init() throws Exception;
	public void cacheFormExtInfo(String formID, String companyCode, String formPrefix, CoviMap extInfo) throws Exception;
	public CoviMap getCachedFormExtInfo(String formID, String FormPrefix) throws Exception;
	
	public CoviMap selectForm(CoviMap params) throws Exception;
	public CoviMap selectProcess(CoviMap params) throws Exception;
	public CoviMap selectProcessDes(CoviMap params) throws Exception;
	public CoviMap selectFormInstance(CoviMap params) throws Exception;
	public CoviMap selectDomainData(CoviMap params) throws Exception;
	public CoviMap selectFormSchema(CoviMap params) throws Exception;
	public CoviMap selectPravateDomainData(CoviMap params) throws Exception;
	public CoviMap selectFiles(CoviMap params) throws Exception;
	
	public void confirmRead(FormRequest formRequest, UserInfo userInfo, String strReadMode, CoviMap processObj) throws Exception;
	public int insertDocReadHistory(CoviMap params) throws Exception;
	public int insertTCInfoDocReadHistory(CoviMap params) throws Exception;
	public int updateTCInfoDocReadHistory(CoviMap params) throws Exception;
	
	public void confirmReadStore(FormRequest formRequest, UserInfo userInfo) throws Exception;
	public int insertTCInfoDocReadHistoryStore(CoviMap params) throws Exception; // 20210126 이관문서 참조/회람 문서 읽음처리  
	public int updateTCInfoDocReadHistoryStore(CoviMap params) throws Exception; // 20210126 이관문서 참조/회람 문서 읽음처리  
	
	public CoviMap getBodyData(CoviMap subtableInfo, CoviMap extInfo, String strFormInstanceID) throws Exception;
	public CoviMap selectSubTableData(CoviMap params) throws Exception;
	public String selectUsingSignImageName(String userCode);
	public String selectFormInstanceIsArchived(CoviMap paramID) throws Exception;
	public String selectFormInstanceID(CoviMap params) throws Exception;
	public boolean isPerformer(CoviMap params);
	public boolean isJobFunctionManager(CoviMap params);
	public boolean isReceivedByDept(CoviMap params);
	public String selectFormPrefixData(CoviMap params);
	public boolean isContainedInManagedBizDoc(CoviMap params);
	public boolean isInTCInfo(CoviMap params);
	public CoviMap selectFormAfterDomainData(CoviMap params) throws Exception;
	public CoviMap selectComment(CoviMap params) throws Exception;
	
	public CoviMap selectFormInstanceStore(CoviMap params) throws Exception;
	public CoviMap selectStoreFiles(CoviMap params) throws Exception;
	public String selectFormInstanceIsBStored(CoviMap paramID) throws Exception;
	public boolean hasDocAuditAuth(CoviMap params);
	public boolean hasStoreDocAuditAuth(CoviMap params);
	
	public CoviMap selectParentDept(CoviMap params) throws Exception;
	public List<CoviMap> selectManageDocTarget(CoviMap params);
	public int selectManageDocData(CoviMap params);
	public boolean isLinkedDoc(CoviMap params);
	public boolean isLinkedStoreDoc(CoviMap params);
	public String selectPerformerDataGov(CoviMap params) throws Exception;
	public boolean isLinkedExpenceDoc(CoviMap params);
	public boolean isLinkedStoreExpenceDoc(CoviMap params);
	public String selectFormCompanyCode(CoviMap params) throws Exception;
	
	public String selectDeptName(String pDeptCode) throws Exception;
	public String selectGov24SenderInfo(String receiveid) throws Exception;
	public CoviMap selectgov24DocLink(String formInstId) throws Exception;
	public String selectCheckReplyDoc(String formInstId) throws Exception;
	public String getReadMode(String strReadMode, String strBusinessState, String strSubkind, String workitemState, String processState);
	String selectUsingSignImageId(String userCode);
	public CoviMap selectCstfInfo(CoviMap params) throws Exception;
	public String selectGovRecordRowSeq(String govRecordId) throws Exception;
	public int updateDocHWP(String formInstID, String bodyContext) throws Exception;
	public CoviMap selectUserInfo(CoviMap params) throws Exception;
	public String docsTransform(CoviMap params) throws Exception;
	public String saveFilePath(String fileId);
}
