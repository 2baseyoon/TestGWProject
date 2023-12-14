package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.TaxInvoiceVO;

public class TaxInvoiceDao{

	private ArrayList<TaxInvoiceVO> taxInvoiceList = new ArrayList<TaxInvoiceVO>();

	public ArrayList<TaxInvoiceVO> getTaxInvoiceList() {
		return taxInvoiceList;
	}

	public void setTaxInvoiceList(ArrayList<TaxInvoiceVO> taxInvoiceList) {
		this.taxInvoiceList = taxInvoiceList;
	}
}
