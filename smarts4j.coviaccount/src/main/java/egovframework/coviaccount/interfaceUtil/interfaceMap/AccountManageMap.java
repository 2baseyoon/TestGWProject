package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class AccountManageMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getDBMap() {
		map = new CoviMap();
		map.put("",	"companyCode");
		map.put("glAccountClass",		"accountClass");
		map.put("glAccountCode",		"accountCode");
		map.put("glAccountName",		"accountName");
		map.put("glAccountShortName",	"accountShortName");
		map.put("isUse",				"isUse");
		map.put("description",			"description");
		//map.put("",	"taxType");
		//map.put("",	"taxCode");
		map.put("INSERTED",				"registDate");
		map.put("INSERTUSER",			"registerID");
		map.put("UPDATED",				"modifyDate");
		map.put("UPDATEUSER",			"modifierID");
		return map;
	}
	
	public CoviMap getSoapMap() {
		map = new CoviMap();
		map.put("",	"companyCode");
		map.put("glAccountClass",		"accountClass");
		map.put("glAccountCode",		"accountCode");
		map.put("glAccountName",		"accountName");
		map.put("glAccountShortName",	"accountShortName");
		map.put("isUse",				"isUse");
		map.put("description",			"description");
		//map.put("",	"taxType");
		//map.put("",	"taxCode");
		map.put("INSERTED",				"registDate");
		map.put("INSERTUSER",			"registerID");
		map.put("UPDATED",				"modifyDate");
		map.put("UPDATEUSER",			"modifierID");
		
		map.put("GLAccountClassNm",		"accountClassName");
		map.put("TOTAL_CNT",			"total");
		return map;
	}
	
	public CoviMap getSapMap() {
		map = new CoviMap();
		map.put("",						"companyCode");
		map.put("",						"accountClass");
		map.put("SAKNR",				"accountCode");
		map.put("TXT20",				"accountName");
		map.put("",						"accountShortName");
		map.put("",						"isUse");
		map.put("TXT50",				"description");
		map.put("",						"taxType");
		map.put("",						"taxCode");
		map.put("",						"registDate");
		map.put("",						"registerID");
		map.put("",						"modifyDate");
		map.put("",						"modifierID");
		
		map.put("MSGTY",		"status");
		map.put("MSGTX",		"msg");
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map = new CoviMap();
		map.put("",						"companyCode");
		map.put("ChartOfAccounts",		"accountClass");
		map.put("GLAccount",			"accountCode");
		map.put("GLAccountLongName",	"accountName");
		//map.put("GLAccountLongName",	"accountLongName");
		map.put("GLAccountName",		"accountShortName");
		map.put("",						"isUse");
		map.put("",						"description");
		map.put("",						"taxType");
		map.put("",						"taxCode");
		map.put("",						"registDate");
		map.put("",						"registerID");
		map.put("",						"modifyDate");
		map.put("",						"modifierID");
		
		map.put("Language",				"language");
		map.put("LastChangeDateTime",	"lastChangeDateTime");
		map.put("to_GLAccountInChartOfAccounts", "to_GLAccountInChartOfAccounts");
		
		map.put("MSGTY",				"status");
		map.put("MSGTX",				"msg");
		return map;
	}
}
