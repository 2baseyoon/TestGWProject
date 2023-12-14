package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface RuleManagementSvc {
	public CoviMap getMasterManagementList(CoviMap params) throws Exception;
	
	public int insertMasterManagement(CoviMap params)throws Exception;
	
	public int updateMasterManagement(CoviMap params)throws Exception;
	
	public int deleteMasterManagement(CoviMap params)throws Exception;
	
	public CoviMap getMappingList(CoviMap params) throws Exception;
	
	public int insertMapping(CoviMap params)throws Exception;
	
	public int deleteMapping(CoviMap params)throws Exception;
	
	public CoviMap getRankList(CoviMap params) throws Exception;
	
	public CoviMap getRuleTreeList(CoviMap params) throws Exception;
	
	public int insertRuleTree(CoviMap params)throws Exception;
	
	public int updateRuleTree(CoviMap params)throws Exception;
	
	public int deleteRuleTree(CoviMap params)throws Exception;
	
	public CoviMap getRuleGridList(CoviMap params) throws Exception;

	public CoviMap selectRuleManagement(CoviMap params) throws Exception;
	
	public int insertRuleManagement(CoviMap params)throws Exception;
	
	public int updateRuleManagement(CoviMap params)throws Exception;
	
	public int deleteRuleManagement(CoviMap params)throws Exception;
	
	public CoviMap getRuleForSelBox(CoviMap params) throws Exception;
	
	public CoviMap getRuleForForm(CoviMap params) throws Exception;
	
	public CoviMap getApvRuleList(CoviMap params) throws Exception;
	
	public CoviMap getApvRuleListForForm(CoviMap params) throws Exception;
	
	public CoviMap getItemMoreInfo(CoviMap params) throws Exception;

	public CoviList insertRuleManageData(CoviMap params) throws Exception;

	public CoviMap geRulManageExcel(CoviMap params) throws Exception;

	public CoviMap getRulHistoryList(CoviMap params) throws Exception;

	public CoviMap getRulHistoryData(CoviMap params) throws Exception;

	public int updateRulHistoryData(CoviMap params) throws Exception;

	public int getRuleCount(CoviMap params) throws Exception;

	public CoviMap getNextItemCode(CoviMap params) throws Exception;

 
}
