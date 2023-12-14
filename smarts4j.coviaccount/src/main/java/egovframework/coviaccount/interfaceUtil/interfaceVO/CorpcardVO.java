package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class CorpcardVO  {
	
	private String companyCode;		//회사코드
	private String cardNo;			//카드번호
	private String cardCompany;		//카드회사
	private String cardClass;		//카드유형#공통코드
	private String cardStatus;		//카드상태#공통코드
	private String ownerUserCode;	//소유자코드
	private String vendorNo;		//지급처등록번호
	private String issueDate;		//발급일자
	private String payDate;			//결제일자
	private String expirationDate;	//만료년월
	private String limitAmountType;	//한도금액타입
	private String limitAmount;		//한도금액
	private String note;			//비고
	private String searchUserUserCode;
	
	public void setAll(CoviMap info) {
		this.cardNo				= rtString(info.get("cardNo"));
		this.cardCompany		= rtString(info.get("cardCompany"));
		this.cardClass			= rtString(info.get("cardClass"));
		this.cardStatus			= rtString(info.get("cardStatus"));
		this.ownerUserCode		= rtString(info.get("ownerUserCode"));
		this.vendorNo			= rtString(info.get("vendorNo"));
		this.issueDate			= rtString(info.get("issueDate"));
		this.payDate			= rtString(info.get("payDate"));
		this.expirationDate		= rtString(info.get("expirationDate"));
		this.limitAmountType	= rtString(info.get("limitAmountType"));
		this.limitAmount		= rtString(info.get("limitAmount"));
		this.note				= rtString(info.get("note"));
		this.searchUserUserCode	= rtString(info.get("searchUserUserCode"));
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCardCompany() {
		return cardCompany;
	}

	public void setCardCompany(String cardCompany) {
		this.cardCompany = cardCompany;
	}

	public String getCardClass() {
		return cardClass;
	}

	public void setCardClass(String cardClass) {
		this.cardClass = cardClass;
	}

	public String getCardStatus() {
		return cardStatus;
	}

	public void setCardStatus(String cardStatus) {
		this.cardStatus = cardStatus;
	}

	public String getOwnerUserCode() {
		return ownerUserCode;
	}

	public void setOwnerUserCode(String ownerUserCode) {
		this.ownerUserCode = ownerUserCode;
	}

	public String getVendorNo() {
		return vendorNo;
	}

	public void setVendorNo(String vendorNo) {
		this.vendorNo = vendorNo;
	}

	public String getIssueDate() {
		return issueDate;
	}

	public void setIssueDate(String issueDate) {
		this.issueDate = issueDate;
	}

	public String getPayDate() {
		return payDate;
	}

	public void setPayDate(String payDate) {
		this.payDate = payDate;
	}

	public String getExpirationDate() {
		return expirationDate;
	}

	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}

	public String getLimitAmountType() {
		return limitAmountType;
	}

	public void setLimitAmountType(String limitAmountType) {
		this.limitAmountType = limitAmountType;
	}

	public String getLimitAmount() {
		return limitAmount;
	}

	public void setLimitAmount(String limitAmount) {
		this.limitAmount = limitAmount;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getSearchUserUserCode() {
		return searchUserUserCode;
	}

	public void setSearchUserUserCode(String searchUserUserCode) {
		this.searchUserUserCode = searchUserUserCode;
	}
}
