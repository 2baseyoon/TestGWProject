package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class BusinessNumberMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		
		return map;
	}
	
	public CoviMap getSapMap() {
	
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map.put("BusinessPartner"	, "businessPartner");			//파트너 코드
		map.put("BPTaxType"			, "bPTaxType");					//사업자 번호 타입
		map.put("BPTaxNumber"		, "bPTaxNumber");				//사업자 번호

		return map;
	}
}
