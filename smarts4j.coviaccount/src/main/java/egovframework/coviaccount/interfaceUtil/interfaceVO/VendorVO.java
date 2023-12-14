package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class VendorVO  {
	
	private String vendorID;			//거래처관리ID
	private String companyCode;			//회사코드
	private String vendorType;			//거래처구분
	private String vendorNo;			//사업자등록번호
	private String corporateNo;			//법인번호
	private String vendorName;			//거래처명
	private String cEOName;				//대표자명
	private String industry;			//업태
	private String sector;				//업종
	private String address;				//주소
	private String bankName;			//은행명
	private String bankAccountNo;		//은행계좌
	private String bankAccountName;		//예금주명
	private String paymentCondition;	//지급조건#공통코드
	private String paymentMethod;		//지급방법#공통코드
	private String vendorStatus;		//거래처상태#공통코드
	private String incomTax;			//소득세유형
	private String localTax;			//지방세유형
	private String currencyCode;		//통화
	private String businessNumber;		//사업자번호

	
	public void setAll(CoviMap info) {
		this.vendorID			= rtString(info.get("vendorID"));			//거래처관리ID
		this.companyCode		= rtString(info.get("companyCode"));		//회사코드
		this.vendorType			= rtString(info.get("vendorType"));			//거래처구분
		this.vendorNo			= rtString(info.get("vendorNo"));			//사업자등록번호
		this.corporateNo		= rtString(info.get("corporateNo"));		//법인번호
		this.vendorName			= rtString(info.get("vendorName"));			//거래처명
		this.cEOName			= rtString(info.get("cEOName"));			//대표자명
		this.industry			= rtString(info.get("industry"));			//업태
		this.sector				= rtString(info.get("sector"));				//업종
		this.address			= rtString(info.get("address"));			//주소
		this.bankName			= rtString(info.get("bankName"));			//은행명
		this.bankAccountNo		= rtString(info.get("bankAccountNo"));		//은행계좌
		this.bankAccountName	= rtString(info.get("bankAccountName"));	//예금주명
		this.paymentCondition	= rtString(info.get("paymentCondition"));	//지급조건#공통코드
		this.paymentMethod		= rtString(info.get("paymentMethod"));		//지급방법#공통코드
		this.vendorStatus		= rtString(info.get("vendorStatus"));		//거래처상태#공통코드
		this.incomTax			= rtString(info.get("incomTax"));			//소득세유형
		this.localTax			= rtString(info.get("localTax"));			//지방세유형
		this.currencyCode		= rtString(info.get("currencyCode"));		//통화
		this.businessNumber		= rtString(info.get("businessNumber"));		//통화
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getVendorID() {
		return vendorID;
	}

	public void setVendorID(String vendorID) {
		this.vendorID = vendorID;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public String getVendorType() {
		return vendorType;
	}

	public void setVendorType(String vendorType) {
		this.vendorType = vendorType;
	}

	public String getVendorNo() {
		return vendorNo;
	}

	public void setVendorNo(String vendorNo) {
		this.vendorNo = vendorNo;
	}

	public String getCorporateNo() {
		return corporateNo;
	}

	public void setCorporateNo(String corporateNo) {
		this.corporateNo = corporateNo;
	}

	public String getVendorName() {
		return vendorName;
	}

	public void setVendorName(String vendorName) {
		this.vendorName = vendorName;
	}

	public String getcEOName() {
		return cEOName;
	}

	public void setcEOName(String cEOName) {
		this.cEOName = cEOName;
	}

	public String getIndustry() {
		return industry;
	}

	public void setIndustry(String industry) {
		this.industry = industry;
	}

	public String getSector() {
		return sector;
	}

	public void setSector(String sector) {
		this.sector = sector;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getBankName() {
		return bankName;
	}

	public void setBankName(String bankName) {
		this.bankName = bankName;
	}

	public String getBankAccountNo() {
		return bankAccountNo;
	}

	public void setBankAccountNo(String bankAccountNo) {
		this.bankAccountNo = bankAccountNo;
	}

	public String getBankAccountName() {
		return bankAccountName;
	}

	public void setBankAccountName(String bankAccountName) {
		this.bankAccountName = bankAccountName;
	}

	public String getPaymentCondition() {
		return paymentCondition;
	}

	public void setPaymentCondition(String paymentCondition) {
		this.paymentCondition = paymentCondition;
	}

	public String getPaymentMethod() {
		return paymentMethod;
	}

	public void setPaymentMethod(String paymentMethod) {
		this.paymentMethod = paymentMethod;
	}

	public String getVendorStatus() {
		return vendorStatus;
	}

	public void setVendorStatus(String vendorStatus) {
		this.vendorStatus = vendorStatus;
	}

	public String getIncomTax() {
		return incomTax;
	}

	public void setIncomTax(String incomTax) {
		this.incomTax = incomTax;
	}

	public String getLocalTax() {
		return localTax;
	}

	public void setLocalTax(String localTax) {
		this.localTax = localTax;
	}

	public String getCurrencyCode() {
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode) {
		this.currencyCode = currencyCode;
	}

	public String getBusinessNumber() {
		return businessNumber;
	}

	public void setBusinessNumber(String businessNumber) {
		this.businessNumber = businessNumber;
	}
	
}
