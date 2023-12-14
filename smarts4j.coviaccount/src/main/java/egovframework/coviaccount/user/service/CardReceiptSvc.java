package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface CardReceiptSvc {
	
	/**
	 * CardReceipt
	 * */
	public CoviMap getCardReceiptList(CoviMap params) throws Exception;
	public CoviMap saveCardReceiptTossUser(CoviMap params) throws Exception;
	CoviMap getCardReceiptExcelList(CoviMap params) throws Exception;
	public CoviMap cardReceiptSync(CoviMap params);
	public CoviMap cardReceiptExcelUpload(CoviMap params) throws Exception;
	
	/**
	 * CardReceiptCancel
	 * */
	public CoviMap getCardReceiptCancelList(CoviMap params) throws Exception;
	CoviMap getCardReceiptCancelExcelList(CoviMap params) throws Exception;
	
	/**
	 * CardReceiptUser
	 * */
	public CoviMap getCardReceiptUserList(CoviMap params) throws Exception;
	CoviMap getCardReceiptUserExcelList(CoviMap params) throws Exception;
	public CoviMap saveCardReceiptPersonal(CoviMap params) throws Exception;
	
	
	/**
	 * CardReceiptUserPersonalUse
	 * */
	public CoviMap getCardReceiptUserPersonalUseList(CoviMap params) throws Exception;
	
	/**
	 * 
	 * SendDelayCorpCard
	 */
	public CoviMap getSendDelayCorpCardList(CoviMap params) throws Exception;
	
	/**
	 * 
	 * getCardCompare
	 */
	public CoviMap getCardCompare(CoviMap params) throws Exception;
	
}