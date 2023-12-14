package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class AccountManageVO  {
	
	private String accountID;
	private String companyCode;
	private String accountClass;
	private String accountCode;
	private String accountName;
	private String accountShortName;
	private String isUse;
	private String description;
	private String taxType;
	private String taxCode;
	private String registDate;
	private String registerID;
	private String modifyDate;
	private String modifierID;
	
	private String total;
	private String accountClassName;
	
	
	public void setAll(CoviMap info) {
		this.accountID			= rtString(info.get("accountID"));
		this.companyCode		= rtString(info.get("companyCode"));
		this.accountClass		= rtString(info.get("accountClass"));
		this.accountCode		= rtString(info.get("accountCode"));
		this.accountName		= rtString(info.get("accountName"));
		this.accountShortName	= rtString(info.get("accountShortName"));
		this.isUse				= rtString(info.get("isUse"));
		this.description		= rtString(info.get("description"));
		this.taxType			= rtString(info.get("taxType"));
		this.taxCode			= rtString(info.get("taxCode"));
		this.registDate			= rtString(info.get("registDate"));
		this.registerID			= rtString(info.get("registerID"));
		this.modifyDate			= rtString(info.get("modifyDate"));
		this.modifierID			= rtString(info.get("modifierID"));
		this.total				= rtString(info.get("total"));
		this.accountClassName	= rtString(info.get("accountClassName"));
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getAccountID() {
		return accountID;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public String getAccountClass() {
		return accountClass;
	}

	public void setAccountClass(String accountClass) {
		this.accountClass = accountClass;
	}

	public String getAccountCode() {
		return accountCode;
	}

	public void setAccountCode(String accountCode) {
		this.accountCode = accountCode;
	}

	public String getAccountName() {
		return accountName;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getAccountShortName() {
		return accountShortName;
	}

	public void setAccountShortName(String accountShortName) {
		this.accountShortName = accountShortName;
	}

	public String getIsUse() {
		return isUse;
	}

	public void setIsUse(String isUse) {
		this.isUse = isUse;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getTaxType() {
		return taxType;
	}

	public void setTaxType(String taxType) {
		this.taxType = taxType;
	}

	public String getTaxCode() {
		return taxCode;
	}

	public void setTaxCode(String taxCode) {
		this.taxCode = taxCode;
	}

	public String getRegistDate() {
		return registDate;
	}

	public void setRegistDate(String registDate) {
		this.registDate = registDate;
	}

	public String getRegisterID() {
		return registerID;
	}

	public void setRegisterID(String registerID) {
		this.registerID = registerID;
	}

	public String getModifyDate() {
		return modifyDate;
	}

	public void setModifyDate(String modifyDate) {
		this.modifyDate = modifyDate;
	}

	public String getModifierID() {
		return modifierID;
	}

	public void setModifierID(String modifierID) {
		this.modifierID = modifierID;
	}
	
	public String getTotal() {
		return total;
	}

	public void setTotal(String total) {
		this.total = total;
	}

	public String getAccountClassName() {
		return accountClassName;
	}

	public void setAccountClassName(String accountClassName) {
		this.accountClassName = accountClassName;
	}
}
