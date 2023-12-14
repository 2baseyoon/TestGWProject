package egovframework.covision.coviflow.approvalline.util;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;



public abstract class AutoCommonApprover {
	final String lang = SessionHelper.getSession("lang");
	static final String PUBLIC_COMPANY = "ORGROOT";
	CoviList oApprovalWorkedApprovalLine;
	
	protected AutoCommonApprover(CoviMap formAutoApprovalData, String strSessionDNCode, String strSessionRegionCode) {
		oApprovalWorkedApprovalLine = new CoviList();
		CoviMap autoApprovers = getSettedApproversData(formAutoApprovalData, strSessionDNCode, strSessionRegionCode);
		
		if(autoApprovers != null){
			CoviList itemArr = autoApprovers.getJSONArray("item");
			
			for(int i=0; i<itemArr.size(); i++){
				oApprovalWorkedApprovalLine.add(getApprover(itemArr.getJSONObject(i)));
			}
		}
		
	}
	abstract CoviMap getApprover(CoviMap item);
	
	public CoviList getApproverLine() {
		return oApprovalWorkedApprovalLine;
	}

	private CoviMap getSettedApproversData(CoviMap settedApproversByType, String strSessionDNCode, String strSessionRegionCode) {
		CoviMap autoApprovers = null;
		
		// 계열사별
		if(settedApproversByType.optString("autoType").equals("E")){
			autoApprovers = getDocAutoApprovalForEnt(settedApproversByType.getJSONObject("DocAutoApprovalEnt"), strSessionDNCode);
		}
		// 사업장별
		else if(settedApproversByType.optString("autoType").equals("R")){
			autoApprovers = getDocAutoApprovalForReg(settedApproversByType.getJSONObject("DocAutoApprovalReg"), strSessionRegionCode); 
		}
		
		return autoApprovers;
	}

	private CoviMap getDocAutoApprovalForReg(CoviMap docAutoApprovalReg, String regionCode) {
		CoviMap autoApprovers = null;

		if(docAutoApprovalReg.has(regionCode)) {
			CoviMap autoApprovalDataForReg = docAutoApprovalReg.getJSONObject(regionCode);
			if(autoApprovalDataForReg.optString("isUse").equals("Y") && !autoApprovalDataForReg.getJSONArray("item").isEmpty()){
				autoApprovers = docAutoApprovalReg.getJSONObject(regionCode);
			}
		}
		
		return autoApprovers;
	}
	
	public CoviMap getDocAutoApprovalForEnt(CoviMap docAutoApprovalEnt, String entCode) {
		CoviMap autoApprovers = null;
		
		if(docAutoApprovalEnt.has(entCode)) {
			CoviMap autoApprovalDataForEnt = docAutoApprovalEnt.getJSONObject(entCode);
			if(autoApprovalDataForEnt.optString("isUse").equals("Y") && !autoApprovalDataForEnt.getJSONArray("item").isEmpty()){
				autoApprovers = docAutoApprovalEnt.getJSONObject(entCode);
			}
		}
	
		if(autoApprovers == null) {
			CoviMap publicApprovers = docAutoApprovalEnt.getJSONObject(PUBLIC_COMPANY);
			if(!publicApprovers.isNullObject() && publicApprovers.optString("isUse").equals("Y") 
				&& !publicApprovers.getJSONArray("item").isEmpty()){
				autoApprovers = docAutoApprovalEnt.getJSONObject(PUBLIC_COMPANY);
			}
		}
		
		return autoApprovers;
	}

	public CoviMap createPersonNode(CoviMap peopleObj) {
		CoviMap personObject = new CoviMap();
		String titleCode  = "";
		String titleName  = "";
		String levelCode  = "";
		String levelName  = "";
		String positionCode  = "";
		String positionName  = "";

		/* 공통 조직도에서 구분값이 & > | 로 변경되어 수정 (tl,lv,po 소문자는 구분자가 ; 로 전자결재에서 사용하는 값)
		// 직위,직급,직책 정보 없는 경우 대비하여 수정
		if(peopleObj.optString("TL").split("&").length > 1) {
			titleCode  = peopleObj.optString("TL").split("&")[0];
			titleName  = DicHelper.getDicInfo(peopleObj.optString("TL").split("&")[1], lang);
		}
		if(peopleObj.optString("LV").split("&").length > 1) {
			levelCode  = peopleObj.optString("LV").split("&")[0];
			levelName  = DicHelper.getDicInfo(peopleObj.optString("LV").split("&")[1], lang);
		}
		if(peopleObj.optString("PO").split("&").length > 1) {
			positionCode  = peopleObj.optString("PO").split("&")[0];
			positionName  = DicHelper.getDicInfo(peopleObj.optString("PO").split("&")[1], lang);
		}
		*/
		
		personObject.put("title", peopleObj.optString("tl"));				// 직책
		personObject.put("level", peopleObj.optString("lv"));				// 직급
		personObject.put("name", peopleObj.getString("DN"));
		personObject.put("oucode", peopleObj.getString("RG"));
		personObject.put("ouname", peopleObj.getString("RGNM"));
		personObject.put("code", peopleObj.getString("AN"));
		personObject.put("position", peopleObj.optString("po"));			// 직위
		personObject.put("sipaddress", peopleObj.getString("EM"));
		
		return personObject;
	}
}
