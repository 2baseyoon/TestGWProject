package egovframework.coviaccount.common.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface CommonSvc {
	public String getCompanyCodeOfUser() throws Exception;
	public String getCompanyCodeOfUser(String SessionUser) throws Exception;
	public CoviList getBaseCodeCombo(CoviMap params) throws Exception;
	public CoviList getBaseCodeComboMulti(CoviMap params) throws Exception;
	public CoviList getBaseCodeData(CoviMap params) throws Exception;
	public CoviList getBaseCodeDataAll(CoviMap params) throws Exception;
	public CoviList getBaseGrpCodeCombo(CoviMap params) throws Exception;
	public CoviMap getBankCodeList(CoviMap params) throws Exception;
	public CoviMap getAccountCommonPopupList(CoviMap params) throws Exception;
	public CoviMap getVendorPopupList(CoviMap params) throws Exception;
	public CoviMap getCopyPopupList(CoviMap params) throws Exception;
	public CoviList getBaseCodeSubSet(CoviMap params) throws Exception;
	public CoviMap getBaseCodeSearchCommPopupList(CoviMap params) throws Exception;
	public CoviMap getCashBillPopupList(CoviMap params) throws Exception;
	public CoviMap getLeftMenuList(CoviMap params) throws Exception;
	public CoviMap getExpAppDocList(CoviMap params) throws Exception;
	public CoviMap getMobileReceipt(CoviMap params) throws Exception;
	public CoviMap getPrivateCardPopupList(CoviMap params) throws Exception;
	public CoviMap getCorpCardAndReceiptList(CoviMap params) throws Exception;
	public boolean getManagerCk() throws Exception;
	
	public CoviMap getAccountSearchPopupList(CoviMap params) throws Exception;
	public CoviMap getFavoriteAccountSearchPopupList(CoviMap params) throws Exception;
	public int setFavoriteAccountSearchPopupList(CoviMap params)throws Exception;
	public CoviMap getCardReceiptPopupInfo(CoviMap params) throws Exception;
	public CoviMap getCardReceiptSearchPopupList(CoviMap params) throws Exception;
	public CoviMap getCostCenterSearchPopupList(CoviMap params) throws Exception;
	public CoviMap getFavoriteCCSearchPopupList(CoviMap params) throws Exception;
	public int setFavoriteCCSearchPopupList(CoviMap params)throws Exception;
	public CoviMap getStandardBriefSearchPopupList(CoviMap params) throws Exception;
	public CoviMap getFavoriteStandardBriefSearchPopupList(CoviMap params) throws Exception;
	public int setFavoriteStandardBriefSearchPopupList(CoviMap params)throws Exception;
	public CoviMap getTaxInvoicePopupInfo(CoviMap params) throws Exception;
	public CoviMap getTaxinvoiceSearchPopupList(CoviMap params) throws Exception;
	public CoviMap getInterfaceLogViewList(CoviMap params) throws Exception;
	
	public CoviMap getTaxInvoiceXmlInfo(CoviMap params) throws Exception;
	
	public CoviMap getApplicationStatus(CoviMap params) throws Exception;
	
	public CoviMap searchUsageTextData(CoviMap params) throws Exception;
	public int saveUsageTextData(CoviMap params) throws Exception;
	public void saveKakaoApprovalList(CoviMap params) throws Exception;
	public String getApprovalNoData(CoviMap params) throws Exception;
	
	public CoviMap getEntinfoListData(CoviMap params) throws Exception;
}