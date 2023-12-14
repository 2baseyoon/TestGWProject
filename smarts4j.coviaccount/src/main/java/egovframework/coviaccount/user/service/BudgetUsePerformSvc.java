package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

public interface BudgetUsePerformSvc {
	
	public CoviMap getBudgetUsePerformList(CoviMap params) throws Exception; 
	public CoviMap getBudgetUsePerformDetailList(CoviMap params) throws Exception; 
	public CoviList getBudgetUsePerformChart(CoviMap params) throws Exception; 
}