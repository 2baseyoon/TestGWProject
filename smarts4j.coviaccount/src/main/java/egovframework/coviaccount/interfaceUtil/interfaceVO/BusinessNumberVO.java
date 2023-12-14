package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class BusinessNumberVO  {
	
	private String businessPartner;			//vendor code
	private String bPTaxType;				//사업자코드 타입
	private String bPTaxNumber;				//사업자 번호


	
	public void setAll(CoviMap info) {
		this.businessPartner			= rtString(info.get("businessPartner"));		//vendor code
		this.bPTaxType					= rtString(info.get("bPTaxType"));					//사업자코드 타입
		this.bPTaxNumber				= rtString(info.get("bPTaxNumber"));				//사업자 번호
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getBusinessPartner() {
		return businessPartner;
	}

	public void setBusinessPartner(String businessPartner) {
		this.businessPartner = businessPartner;
	}

	public String getbPTaxType() {
		return bPTaxType;
	}

	public void setbPTaxType(String bPTaxType) {
		this.bPTaxType = bPTaxType;
	}

	public String getbPTaxNumber() {
		return bPTaxNumber;
	}

	public void setbPTaxNumber(String bPTaxNumber) {
		this.bPTaxNumber = bPTaxNumber;
	}

}
