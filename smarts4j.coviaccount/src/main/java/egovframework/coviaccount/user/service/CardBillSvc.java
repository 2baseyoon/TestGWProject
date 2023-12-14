package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface CardBillSvc {
	
	/**
	 * CardBill
	 * */
	public CoviMap getCardBillList(CoviMap params) throws Exception;
	CoviMap getCardBillExcelList(CoviMap params) throws Exception;
	public CoviMap getCardBillmmSumAmountWon(CoviMap params) throws Exception;
	public CoviMap cardBillSync();
	/**
	 * CardBillUser
	 * */
	public CoviMap getCardBillUserList(CoviMap params) throws Exception;
	CoviMap getCardBillUserExcelList(CoviMap params) throws Exception;
	public CoviMap getCardBillmmSumAmountWonUser(CoviMap params) throws Exception;
}