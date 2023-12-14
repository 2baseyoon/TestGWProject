package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class CostCenterMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getDBMap() {
		map = new CoviMap();
		map.put("",				"companyCode");		//회사코드
		map.put("gubun",			"costCenterType");	//CostCenter타입
		map.put("costCenter",		"costCenterCode");	//CostCenter코드
		map.put("costCenterName",	"costCenterName");	//CostCenter명
		//map.put("",				"nameCode");		//명칭코드
		map.put("valid_from",		"usePeriodStart");	//사용기간시작일
		map.put("valid_to",			"usePeriodFinish");	//사용기간종료일
		//map.put("",				"isPermanent");		//영구여부
		map.put("isUse",			"isUse");			//사용여부
		map.put("description",		"description");		//비고
		map.put("INSERTED",			"registDate");
		map.put("INSERTUSER",		"registerID");
		map.put("UPDATED",			"modifyDate");
		map.put("UPDATEUSER",		"modifierID");
		
		return map;
	}
	
	public CoviMap getSoapMap() {
		map = new CoviMap();
		map.put("",				"companyCode");		//회사코드
		map.put("gubun",			"costCenterType");	//CostCenter타입
		map.put("costCenter",		"costCenterCode");	//CostCenter코드
		map.put("costCenterName",	"costCenterName");	//CostCenter명
		//map.put("",				"nameCode");		//명칭코드
		map.put("valid_from",		"usePeriodStart");	//사용기간시작일
		map.put("valid_to",			"usePeriodFinish");	//사용기간종료일
		//map.put("",				"isPermanent");		//영구여부
		map.put("isUse",			"isUse");			//사용여부
		map.put("description",		"description");		//비고
		
		map.put("INSERTED",			"registDate");
		map.put("INSERTUSER",		"registerID");
		map.put("UPDATED",			"modifyDate");
		map.put("UPDATEUSER",		"modifierID");
		
		map.put("TOTAL_CNT",		"total");
		return map;
	}
	
	public CoviMap getSapMap() {
		map = new CoviMap();
		map.put("",				"companyCode");		//회사코드
		map.put("",				"costCenterType");	//CostCenter타입
		map.put("I_KOSTL",		"costCenterCode");	//CostCenter코드
		map.put("I_KTEXT",		"costCenterName");	//CostCenter명
		map.put("",				"nameCode");		//명칭코드
		map.put("",				"usePeriodStart");	//사용기간시작일
		map.put("",				"usePeriodFinish");	//사용기간종료일
		map.put("",				"isPermanent");		//영구여부
		map.put("",				"isUse");			//사용여부
		map.put("",				"description");		//비고
		map.put("",				"registDate");
		map.put("",				"registerID");
		map.put("",				"modifyDate");
		map.put("",				"modifierID");
		
		map.put("MSGTY",		"status");
		map.put("MSGTX",		"msg");
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map = new CoviMap();
		map.put("",				"companyCode");		//회사코드
		map.put("ControllingArea",				"costCenterType");	//CostCenter타입
		map.put("CostCenter",		"costCenterCode");	//CostCenter코드
		map.put("CostCenterName",		"costCenterName");	//CostCenter명
		map.put("",				"nameCode");		//명칭코드
		map.put("ValidityStartDate",				"usePeriodStart");	//사용기간시작일
		map.put("ValidityEndDate",				"usePeriodFinish");	//사용기간종료일
		map.put("",				"isPermanent");		//영구여부
		map.put("",				"isUse");			//사용여부
		map.put("CostCenterDescription",				"description");		//비고
		map.put("",				"registDate");
		map.put("",				"registerID");
		map.put("",				"modifyDate");
		map.put("",				"modifierID");
		
		map.put("__metadata",		"__metadata");
		map.put("to_CostCenter",		"to_CostCenter");
		map.put("Language",		"language");
		
		map.put("MSGTY",		"status");
		map.put("MSGTX",		"msg");
		return map;
	}
}
