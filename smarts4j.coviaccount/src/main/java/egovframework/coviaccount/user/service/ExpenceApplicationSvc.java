package egovframework.coviaccount.user.service;

import java.util.List;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


/**
 * @Class Name : ExpenceApplicationSvc.java
 * @Description : 기준정보관리
 * @Modification Information 
 * @author Covision
 * @ 2018.05.29 최초생성
 */
public interface ExpenceApplicationSvc {
	
	public CoviMap getCardReceipt(CoviMap params) throws Exception;
	public CoviMap getTaxCodeCombo(CoviMap params) throws Exception;
	public CoviMap getBriefCombo(CoviMap params) throws Exception;
	public CoviMap getCashBillInfo(CoviMap params) throws Exception;
	public CoviMap getTaxBillInfo(CoviMap params) throws Exception;
	public CoviMap getApplicationListCopy(CoviMap params) throws Exception;
	public CoviMap getVdCheck(CoviMap params) throws Exception;
	
	public CoviMap insertCombineCostApplication(CoviMap params)throws Exception;
	public CoviMap updateCombineCostApplication(CoviMap params)throws Exception;
	
	public CoviMap searchExpenceApplicationList(CoviMap params) throws Exception;
	public CoviMap searchExpenceApplicationListExcel(CoviMap params) throws Exception;
	public CoviMap searchExpenceApplication(CoviMap params) throws Exception;
	public CoviMap searchExpenceApplicationFileList(CoviMap params) throws Exception;
	
	public CoviMap expenceApplicationDuplicateCheck(CoviMap params)throws Exception;
	public CoviMap insertExpenceApplication(CoviMap params)throws Exception;
	public CoviMap updateExpenceApplication(CoviMap params)throws Exception;
	public CoviMap duplCkExpenceApplicationList(CoviMap params)throws Exception;

	public CoviMap savePrivateDomainData(CoviMap params)throws Exception;

	public CoviMap getSimpCardInfoList(CoviMap params) throws Exception;
	public CoviMap getSimpReceiptInfoList(CoviMap params) throws Exception;
	
	public CoviMap getCardReceiptDetail(CoviMap params) throws Exception;
	public CoviMap deleteExpenceApplicationManList(CoviMap params, String deleteType) throws Exception;

	public CoviMap getMobileReceiptList(CoviMap params) throws Exception;
	public CoviMap getMobileReceipt(CoviMap params) throws Exception;
	public CoviMap deleteMobileReceipt(CoviMap params) throws Exception;
	public CoviMap insertMobileReceipt(CoviMap params) throws Exception;
	public CoviMap updateMobileReceipt(CoviMap params) throws Exception;
	public CoviMap updateCorpCardReceipt(CoviMap params) throws Exception;
	
	public CoviMap getUserCC(CoviMap params) throws Exception;
	
	public CoviMap searchExpenceApplicationReviewList(CoviMap params) throws Exception;
	public CoviMap makeSlip(CoviMap params) throws Exception;
	public CoviMap unMakeSlip(CoviMap params) throws Exception;
	public CoviMap makeSlipAuto(CoviMap params, CoviMap slipInfo) throws Exception;
	public CoviMap reverseExpApp(CoviMap params) throws Exception;

	public boolean expAppAprvStatCk(CoviMap params) throws Exception;
	public CoviMap statChangeExpenceApplicationManList(CoviMap params, String inputType) throws Exception;
	
	public CoviMap getExpenceApplicationSync();
	public CoviMap setExpenceApplicationSync(CoviMap params);
	public CoviMap expAppUpdateActive(CoviMap params) throws Exception;
	public CoviMap expAppUpdateApplicationStatus(CoviMap params) throws Exception;
	public CoviMap expAppUpdateEvidActive(CoviMap params) throws Exception;
	public CoviMap insertExpenceApplicationForReuse(CoviMap params) throws Exception;

	public CoviMap createCapitalReportInfo(CoviMap params) throws Exception;	
	public CoviMap searchCapitalSpendingStatus(CoviMap params) throws Exception;
	public CoviMap searchCapitalSpendingStatusExcel(CoviMap params) throws Exception;
	public CoviMap updateCapitalStatus(CoviMap params) throws Exception;
	public CoviMap searchCapitalEditData(CoviMap params) throws Exception;
	public CoviMap getCapitalSpendingList(CoviMap params) throws Exception;
	public CoviMap updateCapitalEditInfo(CoviMap params) throws Exception;
	public CoviMap searchCapitalSummary(CoviMap params) throws Exception;
	public CoviMap searchCapitalSummaryExcel(CoviMap jsonParams) throws Exception;
	
	public CoviMap getUserBankAccount(CoviMap params) throws Exception;
	
	public String insertActVendorForWrite(String vendorNo, String vendorName, String companyCode) throws Exception;
	public CoviMap checkActVendorIsRegistered(CoviMap params) throws Exception;
	
	public CoviMap searchMonthlyAccountHeaderData(CoviMap params) throws Exception;
	public CoviMap searchMonthlyAccountSummaryList(CoviMap params) throws Exception;
	public CoviMap searchMonthlyAccountSummaryListExcel(CoviMap params) throws Exception;
	
	public CoviMap searchMonthlyStandardBriefHeaderData(CoviMap params) throws Exception;
	public CoviMap searchMonthlyStandardBriefSummaryList(CoviMap params) throws Exception;
	public CoviMap searchMonthlyStandardBriefSummaryListExcel(CoviMap params) throws Exception;
	
	public CoviMap getFormData(CoviMap params) throws Exception;
	public CoviMap getCardList(CoviMap params) throws Exception;
	
	public CoviMap saveAuditReason(CoviMap params) throws Exception;
	public CoviMap selRecentVendorInfo(CoviMap params) throws Exception;
	
	public CoviMap getStoreCategoryCombo(CoviMap params) throws Exception;
	
	public CoviMap getStandardBriefCtrlCombo(CoviMap params) throws Exception;
	public CoviMap getCtrlCodeHeader(CoviMap params) throws Exception;
	public CoviMap getMajorAccountUsageHistory(CoviMap params) throws Exception;
	
	public CoviMap getExpenceApplicationListExcelDouzone(CoviMap params) throws Exception;

	public String selectUsingSignImageId(String userCode) throws Exception;
	public String selectFormInstanceIsArchived(CoviMap params) throws Exception;
	public CoviMap selectProcess(CoviMap params) throws Exception;
	public CoviMap selectProcessDes(CoviMap params) throws Exception;
	public CoviMap selectFormInstance(CoviMap params) throws Exception;
	public CoviMap selectFormInstanceStore(CoviMap params) throws Exception;
	public CoviMap selectDomainData(CoviMap params) throws Exception;
	public CoviMap selectFormSchema(CoviMap params) throws Exception;
	public CoviMap selectPravateDomainData(CoviMap params) throws Exception;
	public CoviMap selectForm(CoviMap params) throws Exception;
	public String getReadMode(String strReadMode, String strBusinessState, String strSubkind, String workitemState);
	public boolean isPerformer(CoviMap params);
	public boolean isJobFunctionManager(CoviMap params);
	public boolean isReceivedByDept(CoviMap params);
	public String selectFormPrefixData(CoviMap params);
	public boolean isContainedInManagedBizDoc(CoviMap params);
	public boolean isInTCInfo(CoviMap params);
	public boolean hasDocAuditAuth(CoviMap params);
	public boolean isLinkedDoc(CoviMap params);
	public boolean isLinkedExpenceDoc(CoviMap params);
	public boolean isDeletedDoc(CoviMap params);
	public List<CoviMap> selectManageDocTarget(CoviMap params);
	public int selectManageDocData(CoviMap params);
	public CoviMap selectChargeJob(CoviMap params) throws Exception;
	
	public CoviList selectSync() throws Exception;
	
	public void syncComplete(CoviMap params) throws Exception;
	public CoviMap getTaxBillItemInfo(CoviMap params) throws Exception;
	public CoviMap selectUserInfo(CoviMap params) throws Exception;
}