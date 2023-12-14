package egovframework.coviaccount.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface BudgetRegistSvc {
	
	public CoviMap getBudgetRegistList(CoviMap params) throws Exception;
	public CoviMap getBudgetRegistInfo(CoviMap params) throws Exception;
	public CoviMap getBudgetRegistItem (CoviMap params) throws Exception;

	public int changeControl(CoviMap params) throws Exception;
	public int changeUse(CoviMap params) throws Exception;
	
	public CoviMap addBudgetRegist (CoviMap params, CoviList paramsList) throws Exception;
	public int saveBudgetRegist (CoviMap params, CoviList periodInfo) throws Exception;
	public int deleteBudgetRegist (CoviList paramsList) throws Exception;
	
	public CoviMap uploadExcel(CoviMap params) throws Exception;
}