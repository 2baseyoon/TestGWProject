package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface TaxInvoiceTaxTotalSvc {
	public CoviMap getTaxInvoiceTaxTotalList(CoviMap params) throws Exception;
	CoviMap taxInvoiceTaxTotalExcelDownload(CoviMap params) throws Exception;
}