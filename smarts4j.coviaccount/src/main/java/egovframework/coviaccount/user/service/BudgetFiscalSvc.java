package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

public interface BudgetFiscalSvc {
	
	public CoviMap getBudgetFiscalList(CoviMap params) throws Exception; 
	public CoviList getBudgetFiscalCode() throws Exception; 
	public CoviMap addBudgetFiscal(CoviMap params) throws Exception; 
	public CoviMap getFiscalYearByDate(CoviMap params) throws Exception;
}