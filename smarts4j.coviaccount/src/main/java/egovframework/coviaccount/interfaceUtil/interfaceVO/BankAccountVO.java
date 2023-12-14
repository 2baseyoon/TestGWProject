package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class BankAccountVO  {
	
	private String bankID;			//은행ID
	private String vendorNo;		//거래처코드
	private String bankCode;		//은행코드
	private String bankName;		//은행명
	private String bankAccountNo;	//은행계좌
	private String bankAccountHolderName;	//예금주명
	private String bankCountryKey;	//국가


	
	public void setAll(CoviMap info) {
		this.bankID				= rtString(info.get("bankID"));				//은행ID
		this.vendorNo			= rtString(info.get("vendorNo"));			//거래처관리ID
		this.bankCode			= rtString(info.get("bankCode"));			//은행코드
		this.bankName			= rtString(info.get("bankName"));			//은행코드
		this.bankAccountNo		= rtString(info.get("bankAccountNo"));		//은행계좌
		this.bankAccountHolderName	= rtString(info.get("bankAccountHolderName"));	//예금주명
		this.bankCountryKey		= rtString(info.get("bankCountryKey"));		//국가
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getBankID() {
		return bankID;
	}

	public void setBankID(String bankID) {
		this.bankID = bankID;
	}
	
	public String getVendorNo() {
		return vendorNo;
	}

	public void setVendorNo(String vendorNo) {
		this.vendorNo = vendorNo;
	}

	public String getBankAccountNo() {
		return bankAccountNo;
	}

	public void setBankAccountNo(String bankAccountNo) {
		this.bankAccountNo = bankAccountNo;
	}
	
	public String getBankCode() {
		return bankCode;
	}

	public void setBankCode(String bankCode) {
		this.bankCode = bankCode;
	}
	
	public String getBankName() {
		return bankName;
	}

	public void setBankName(String bankName) {
		this.bankName = bankName;
	}

	public String getBankAccountHolderName() {
		return bankAccountHolderName;
	}

	public void setBankAccountHolderName(String bankAccountHolderName) {
		this.bankAccountHolderName = bankAccountHolderName;
	}

	public String getBankCountryKey() {
		return bankCountryKey;
	}

	public void setBankCountryKey(String bankCountryKey) {
		this.bankCountryKey = bankCountryKey;
	}

}
