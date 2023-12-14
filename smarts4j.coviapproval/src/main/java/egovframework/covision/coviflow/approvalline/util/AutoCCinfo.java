package egovframework.covision.coviflow.approvalline.util;

import egovframework.baseframework.data.CoviMap;

public class AutoCCinfo extends AutoCommonApprover {

	public AutoCCinfo(CoviMap formAutoApprovalData, String strSessionDNCode, String strSessionRegionCode) {
		super(formAutoApprovalData, strSessionDNCode, strSessionRegionCode);
	}

	@Override
	CoviMap getApprover(CoviMap peopleObj) {
		CoviMap oCCinfo = new CoviMap();
		oCCinfo.put("belongto", "sender");
		
		CoviMap oOU = new CoviMap();		
		if(peopleObj.optString("itemType").equals("user")) {
			CoviMap oPerson = createPersonNode(peopleObj);
			oOU.put("name", peopleObj.optString("RGNM"));
			oOU.put("code", peopleObj.optString("RG"));
			oOU.put("person", oPerson);
		} else {
			oOU.put("name", peopleObj.optString("DN"));
			oOU.put("code", peopleObj.optString("AN"));
		}
		oCCinfo.put("ou", oOU);
		
		return oCCinfo;
	}

}
