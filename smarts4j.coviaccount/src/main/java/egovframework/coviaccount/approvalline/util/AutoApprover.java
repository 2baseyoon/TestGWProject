package egovframework.coviaccount.approvalline.util;

import egovframework.baseframework.data.CoviMap;

public class AutoApprover extends AutoCommonApprover {
	public AutoApprover(CoviMap formAutoApprovalData, String strSessionDNCode, String strSessionRegionCode) {
		super(formAutoApprovalData, strSessionDNCode, strSessionRegionCode);
	}

	@Override
	CoviMap getApprover(CoviMap peopleObj) {
		CoviMap oStep = new CoviMap();
		CoviMap oOU = new CoviMap();
		CoviMap oPerson = createPersonNode(peopleObj);
		CoviMap oTaskinfo = new CoviMap();
		
		oStep.put("name", "일반결재");
		oStep.put("unittype", "person");
		oStep.put("routetype", "approve");
		
		oOU.put("name", peopleObj.optString("RGNM"));
		oOU.put("code", peopleObj.optString("RG"));
											
		oTaskinfo.put("kind", "normal");
		oTaskinfo.put("result", "inactive");
		oTaskinfo.put("status", "inactive");
		
		oPerson.put("taskinfo", oTaskinfo);
		
		oOU.put("person", oPerson);
		
		oStep.put("ou", oOU);
		return oStep;
	}

}
