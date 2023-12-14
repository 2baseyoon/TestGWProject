package egovframework.coviaccount.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface BudgetUseSvc {
	
	public CoviMap getBudgetExecuteList(CoviMap params) throws Exception;
	public CoviList getBudgetAmount(CoviMap params) throws Exception;
	public CoviMap getBudgetCtrlInfo(CoviMap params) throws Exception;
	public CoviMap addExecuteRegist (CoviMap params) throws Exception;
	
	public int changeStatus(CoviMap params) throws Exception;
	
}