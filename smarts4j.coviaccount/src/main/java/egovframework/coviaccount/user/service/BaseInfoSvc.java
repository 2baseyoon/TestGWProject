package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;


/**
 * @Class Name : BaseInfoSvc.java
 * @Description : 기준정보관리
 * @Modification Information 
 * @author Covision
 * @ 2018.05.14 최초생성
 */
public interface BaseInfoSvc {
	

	//거래처 관리
	public CoviMap searchVendorList(CoviMap params) throws Exception;
	public CoviMap excelDownloadVenderList(CoviMap params) throws Exception;
	public CoviMap excelUploadVenderList(CoviMap params) throws Exception;
	public int deleteVendorList(CoviMap params)throws Exception;
	public CoviMap searchVendorDetail(CoviMap params) throws Exception;
	public CoviMap checkVendorDuplicate(CoviMap params) throws Exception;
	public CoviMap insertVendor(CoviMap params)throws Exception;
	public CoviMap updateVendor(CoviMap params)throws Exception;
	public CoviMap vendorSync()throws Exception ;
	public CoviMap vendorBankSync()throws Exception;	
	public CoviMap vendorBusinessNumberSync()throws Exception;	
	
	
	//==============================거래처신청관리======================================
	public CoviMap searchVendorRequestList(CoviMap params) throws Exception;
	public CoviMap insertVendorRequest(CoviMap params)throws Exception;
	public CoviMap updateVendorRequest(CoviMap params)throws Exception;
	public CoviMap searchVendorRequestDetail(CoviMap params) throws Exception;
	public int deleteVendorRequestList(CoviMap params)throws Exception;
	public CoviMap excelDownloadVendorRequest(CoviMap params) throws Exception;
	public boolean vendAprvStatCk(CoviMap params) throws Exception;
	public CoviMap vendAprvStatChange(CoviMap params) throws Exception;
	

	//=============================카드신청======================================
	public int ckPrivateCardDuplCnt(CoviMap params)throws Exception;
	public CoviMap searchCardApplicationList(CoviMap params) throws Exception;
	public CoviMap searchCardApplicationDetail(CoviMap params) throws Exception;
	public CoviMap getCompanyCardComboList(CoviMap params) throws Exception;
	public CoviMap insertCardApplication(CoviMap params)throws Exception;
	public CoviMap updateCardApplication(CoviMap params)throws Exception;
	public int deleteCardApplicationList(CoviMap params)throws Exception;
	public CoviMap excelDownloadCardApplication(CoviMap params) throws Exception;
	
	//==============================개인카드======================================
	public CoviMap searchPrivateCardViewList(CoviMap params) throws Exception;
	public CoviMap updatePrivateCardUseYN(CoviMap params)throws Exception;
	public CoviMap excelDownloadPriCard(CoviMap params) throws Exception;
	public boolean cardAprvStatCk(CoviMap params) throws Exception;
	public CoviMap cardAprvStatChange(CoviMap params) throws Exception;
	

	
}