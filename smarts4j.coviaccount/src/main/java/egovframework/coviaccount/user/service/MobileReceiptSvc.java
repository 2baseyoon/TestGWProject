package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface MobileReceiptSvc {
	
	/**
	 * MobileReceipt
	 * */
	public CoviMap getMobileReceiptList(CoviMap params) throws Exception;
	public CoviMap getMobileReceiptExcelList(CoviMap params) throws Exception;
	/**
	 * MobileReceiptUser
	 * */
	public CoviMap getMobileReceiptUserList(CoviMap params) throws Exception;
	public CoviMap getMobileReceiptUserExcelList(CoviMap params) throws Exception;
	
	public CoviMap deleteMobileReceipt(CoviMap parmas) throws Exception;
	
	public CoviMap save(CoviMap params) throws Exception; 
}