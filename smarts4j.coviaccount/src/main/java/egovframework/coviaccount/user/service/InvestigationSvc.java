package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;


public interface InvestigationSvc {
	public CoviMap getInvestigationList(CoviMap params) throws Exception;
	public CoviMap getInvestigationListExcel(CoviMap params) throws Exception;
	public CoviMap getInvestigationInfo(CoviMap params) throws Exception;
	
	public CoviMap saveInvestInfo(CoviMap params) throws Exception;
	public CoviMap deleteInvestInfo(CoviMap params) throws Exception;
	
	public CoviMap getInvestItemCombo(CoviMap params) throws Exception;
	public CoviMap getInvestTargetCombo(CoviMap params) throws Exception;
	
	public Object getInvestCrtr() throws Exception;

	public CoviMap getInvestigationUseList(CoviMap params) throws Exception;
	public CoviMap getInvestigationUseListExcel(CoviMap params) throws Exception;	
}