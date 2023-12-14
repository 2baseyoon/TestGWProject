package egovframework.coviaccount.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface AccountPortalHomeSvc {

	public int getExecutiveCheck(CoviMap params) throws Exception;
	public CoviMap getDeadline(CoviMap params) throws Exception;
	public CoviMap getTotalSummery(CoviMap params) throws Exception;
	public CoviMap getAccountPortalUser(CoviMap params) throws Exception;
	public CoviMap getAccountPortalManager(CoviMap params) throws Exception;
	public CoviMap getPortalProof(CoviMap map) throws Exception;
	public CoviMap getPortalAccount(CoviMap map) throws Exception;	
	public CoviMap getProofDeptCode(CoviMap map) throws Exception;	
	public CoviMap getAccountCode(CoviMap map) throws Exception;
	public CoviMap getTopCategory(CoviMap map) throws Exception;
	public CoviMap getAccountMonth(CoviMap map) throws Exception;
	public CoviMap getBudgetMonthSum(CoviMap map) throws Exception;
	public CoviMap getBudgetTotal(CoviMap map) throws Exception;
	public int getAuditList(String reportType,CoviMap map) throws Exception;
	public CoviMap getAccountUserMonth(CoviMap map) throws Exception;
	public CoviMap getReportDetailList(CoviMap params) throws Exception;		
	public CoviMap reportTransferExcelDownload(CoviMap params) throws Exception;
	public CoviMap employeeExpenceExcelDownload(CoviMap params) throws Exception;
	public CoviMap vendorExpenceExcelDownload(CoviMap params) throws Exception;
	
	public int updatePortalListTabSort(CoviMap params) throws Exception;
	public CoviList selectPortalSectionSort(CoviMap params)throws Exception;
}