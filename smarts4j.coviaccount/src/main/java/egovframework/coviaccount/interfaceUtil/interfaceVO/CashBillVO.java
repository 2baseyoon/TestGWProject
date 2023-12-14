package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class CashBillVO{
	
	private String cashBillID;			//현금영수증 ID
	private String companyCode;			//현금영수증 승인번호
	private String nTSConfirmNum;		//현금영수증승인번호
	private String tradeDT;				//거래일시
	private String tradeUsage;			//현금영수증 거래유형#지출증빙용,소득공제용
	private String tradeType;			//거래구분#승인거래,취소거래
	private String supplyCost;			//공급가액
	private String tax;					//세금
	private String serviceFree;			//서비스금액
	private String totalAmount;			//거래금액
	private String invoiceType;			//현금영수증유형#매입,매출
	private String franchiseCorpNum;	//발행자 사업자 번호
	private String franchiseCorpName;	//발행자 명
	private String franchiseCorpType;	//발생자 구분
	private String registDate;			//등록일시
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	public void setAll(CoviMap info) {
		this.cashBillID			= rtString(info.get("cashBillID"));
		this.companyCode		= rtString(info.get("companyCode"));
		this.nTSConfirmNum		= rtString(info.get("nTSConfirmNum"));
		this.tradeDT			= rtString(info.get("tradeDT"));
		this.tradeUsage			= rtString(info.get("tradeUsage"));
		this.tradeType			= rtString(info.get("tradeType"));
		this.supplyCost			= rtString(info.get("supplyCost"));
		this.tax				= rtString(info.get("tax"));
		this.serviceFree		= rtString(info.get("serviceFree"));
		this.totalAmount		= rtString(info.get("totalAmount"));
		this.invoiceType		= rtString(info.get("invoiceType"));
		this.franchiseCorpNum	= rtString(info.get("franchiseCorpNum"));
		this.franchiseCorpName	= rtString(info.get("franchiseCorpName"));
		this.franchiseCorpType	= rtString(info.get("franchiseCorpType"));
		this.registDate			= rtString(info.get("registDate"));
	}

	public String getCashBillID() {
		return cashBillID;
	}

	public void setCashBillID(String cashBillID) {
		this.cashBillID = cashBillID;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public String getnTSConfirmNum() {
		return nTSConfirmNum;
	}

	public void setnTSConfirmNum(String nTSConfirmNum) {
		this.nTSConfirmNum = nTSConfirmNum;
	}

	public String getTradeDT() {
		return tradeDT;
	}

	public void setTradeDT(String tradeDT) {
		this.tradeDT = tradeDT;
	}

	public String getTradeUsage() {
		return tradeUsage;
	}

	public void setTradeUsage(String tradeUsage) {
		this.tradeUsage = tradeUsage;
	}

	public String getTradeType() {
		return tradeType;
	}

	public void setTradeType(String tradeType) {
		this.tradeType = tradeType;
	}

	public String getSupplyCost() {
		return supplyCost;
	}

	public void setSupplyCost(String supplyCost) {
		this.supplyCost = supplyCost;
	}

	public String getTax() {
		return tax;
	}

	public void setTax(String tax) {
		this.tax = tax;
	}

	public String getServiceFree() {
		return serviceFree;
	}

	public void setServiceFree(String serviceFree) {
		this.serviceFree = serviceFree;
	}

	public String getTotalAmount() {
		return totalAmount;
	}

	public void setTotalAmount(String totalAmount) {
		this.totalAmount = totalAmount;
	}

	public String getInvoiceType() {
		return invoiceType;
	}

	public void setInvoiceType(String invoiceType) {
		this.invoiceType = invoiceType;
	}

	public String getFranchiseCorpNum() {
		return franchiseCorpNum;
	}

	public void setFranchiseCorpNum(String franchiseCorpNum) {
		this.franchiseCorpNum = franchiseCorpNum;
	}

	public String getFranchiseCorpName() {
		return franchiseCorpName;
	}

	public void setFranchiseCorpName(String franchiseCorpName) {
		this.franchiseCorpName = franchiseCorpName;
	}

	public String getFranchiseCorpType() {
		return franchiseCorpType;
	}

	public void setFranchiseCorpType(String franchiseCorpType) {
		this.franchiseCorpType = franchiseCorpType;
	}

	public String getRegistDate() {
		return registDate;
	}

	public void setRegistDate(String registDate) {
		this.registDate = registDate;
	}
}
