package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface TaxInvoiceSvc {
	public CoviMap getTaxInvoiceList(CoviMap params) throws Exception;
	CoviMap taxInvoiceExcelDownload(CoviMap params) throws Exception;
	public CoviMap saveIsOffset(CoviMap params) throws Exception;
	public CoviMap saveTaxInvoiceTossUser(CoviMap params) throws Exception;
	public CoviMap taxInvoiceSync(CoviMap params);
	public CoviMap cashBillSync(CoviMap params);
	public CoviMap saveExpence(CoviMap params) throws Exception;
	public boolean chkDupTaxInvoice(String conversationID) throws Exception;
}