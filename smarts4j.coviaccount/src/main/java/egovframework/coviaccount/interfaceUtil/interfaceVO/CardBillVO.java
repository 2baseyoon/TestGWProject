package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class CardBillVO  {
	
	private String sendDate;			//연계일자
	private String itemNo;				//거래번호
	private String cardNo;				//청구번호
	private String infoIndex;			//정보구분#A;	//승인B;	//매입C;	//승인취소
	private String infoType;			//수신정보분류코드#Y;	//신규N;	//취소
	private String cardCompIndex;		//카드사구분
	private String cardRegType;			//카드등록형식
	private String cardType;			//카드종류
	private String bizPlaceNo;			//사업장번호
	private String dept;				//카드소유자의부서코드
	private String cardUserCode;		//카드소유자코드
	private String useDate;				//카드사용일자
	private String approveDate;			//카드승인일자
	private String approveTime;			//카드승인시각
	private String approveNo;			//카드승인번호
	private String withdrawDate;		//출금일자
	private String countryIndex;		//국내/해외구분#L;	//국내E;	//해외
	private String amountSign;			//청구원금
	private String amountCharge;		//수수료
	private String amountWon;			//총금액
	private String foreignCurrency;		//통화구분코드
	private String amountForeign;		//총외화금액
	private String storeRegNo;			//가맹점사업자번호
	private String storeName;			//가맹점명
	private String storeNo;				//가맹점번호
	private String storeRepresentative;	//가맹점대표자
	private String storeCondition;		//가맹점업태
	private String storeCategory;		//가맹점종목
	private String storeZipCode;		//가맹점우편번호
	private String storeAddress1;		//가맹점주소
	private String storeAddress2;		//가맹점상세주소
	private String storeTel;			//가맹점전화번호
	private String repAmount;			//공급가액
	private String taxAmount;			//부가세
	private String serviceAmount;		//봉사료
	private String paymentFlag;			//지급여부
	private String paymentDate;			//지급일자
	private String collNo;				//매입추심번호
	private String classCode;			//구분#A;	//정상B;	//취소
	
	public void setAll(CoviMap info) {
		this.sendDate				= rtString(info.get("sendDate"));
		this.itemNo					= rtString(info.get("itemNo"));
		this.cardNo					= rtString(info.get("cardNo"));
		this.infoIndex				= rtString(info.get("infoIndex"));
		this.infoType				= rtString(info.get("infoType"));
		this.cardCompIndex			= rtString(info.get("cardCompIndex"));
		this.cardRegType			= rtString(info.get("cardRegType"));
		this.cardType				= rtString(info.get("cardType"));
		this.bizPlaceNo				= rtString(info.get("bizPlaceNo"));
		this.dept					= rtString(info.get("dept"));
		this.cardUserCode			= rtString(info.get("cardUserCode"));
		this.useDate				= rtString(info.get("useDate"));
		this.approveDate			= rtString(info.get("approveDate"));
		this.approveTime			= rtString(info.get("approveTime"));
		this.approveNo				= rtString(info.get("approveNo"));
		this.withdrawDate			= rtString(info.get("withdrawDate"));
		this.countryIndex			= rtString(info.get("countryIndex"));
		this.amountSign				= rtString(info.get("amountSign"));
		this.amountCharge			= rtString(info.get("amountCharge"));
		this.amountWon				= rtString(info.get("amountWon"));
		this.foreignCurrency		= rtString(info.get("foreignCurrency"));
		this.amountForeign			= rtString(info.get("amountForeign"));
		this.storeRegNo				= rtString(info.get("storeRegNo"));
		this.storeName				= rtString(info.get("storeName"));
		this.storeNo				= rtString(info.get("storeNo"));
		this.storeRepresentative	= rtString(info.get("storeRepresentative"));
		this.storeCondition			= rtString(info.get("storeCondition"));
		this.storeCategory			= rtString(info.get("storeCategory"));
		this.storeZipCode			= rtString(info.get("storeZipCode"));
		this.storeAddress1			= rtString(info.get("storeAddress1"));
		this.storeAddress2			= rtString(info.get("storeAddress2"));
		this.storeTel				= rtString(info.get("storeTel"));
		this.repAmount				= rtString(info.get("repAmount"));
		this.taxAmount				= rtString(info.get("taxAmount"));
		this.serviceAmount			= rtString(info.get("serviceAmount"));
		this.paymentFlag			= rtString(info.get("paymentFlag"));
		this.paymentDate			= rtString(info.get("paymentDate"));
		this.collNo					= rtString(info.get("collNo"));
		this.classCode				= rtString(info.get("classCode"));
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getSendDate() {
		return sendDate;
	}

	public void setSendDate(String sendDate) {
		this.sendDate = sendDate;
	}

	public String getItemNo() {
		return itemNo;
	}

	public void setItemNo(String itemNo) {
		this.itemNo = itemNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getInfoIndex() {
		return infoIndex;
	}

	public void setInfoIndex(String infoIndex) {
		this.infoIndex = infoIndex;
	}

	public String getInfoType() {
		return infoType;
	}

	public void setInfoType(String infoType) {
		this.infoType = infoType;
	}

	public String getCardCompIndex() {
		return cardCompIndex;
	}

	public void setCardCompIndex(String cardCompIndex) {
		this.cardCompIndex = cardCompIndex;
	}

	public String getCardRegType() {
		return cardRegType;
	}

	public void setCardRegType(String cardRegType) {
		this.cardRegType = cardRegType;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getBizPlaceNo() {
		return bizPlaceNo;
	}

	public void setBizPlaceNo(String bizPlaceNo) {
		this.bizPlaceNo = bizPlaceNo;
	}

	public String getDept() {
		return dept;
	}

	public void setDept(String dept) {
		this.dept = dept;
	}

	public String getCardUserCode() {
		return cardUserCode;
	}

	public void setCardUserCode(String cardUserCode) {
		this.cardUserCode = cardUserCode;
	}

	public String getUseDate() {
		return useDate;
	}

	public void setUseDate(String useDate) {
		this.useDate = useDate;
	}

	public String getApproveDate() {
		return approveDate;
	}

	public void setApproveDate(String approveDate) {
		this.approveDate = approveDate;
	}

	public String getApproveTime() {
		return approveTime;
	}

	public void setApproveTime(String approveTime) {
		this.approveTime = approveTime;
	}

	public String getApproveNo() {
		return approveNo;
	}

	public void setApproveNo(String approveNo) {
		this.approveNo = approveNo;
	}

	public String getWithdrawDate() {
		return withdrawDate;
	}

	public void setWithdrawDate(String withdrawDate) {
		this.withdrawDate = withdrawDate;
	}

	public String getCountryIndex() {
		return countryIndex;
	}

	public void setCountryIndex(String countryIndex) {
		this.countryIndex = countryIndex;
	}

	public String getAmountSign() {
		return amountSign;
	}

	public void setAmountSign(String amountSign) {
		this.amountSign = amountSign;
	}

	public String getAmountCharge() {
		return amountCharge;
	}

	public void setAmountCharge(String amountCharge) {
		this.amountCharge = amountCharge;
	}

	public String getAmountWon() {
		return amountWon;
	}

	public void setAmountWon(String amountWon) {
		this.amountWon = amountWon;
	}

	public String getForeignCurrency() {
		return foreignCurrency;
	}

	public void setForeignCurrency(String foreignCurrency) {
		this.foreignCurrency = foreignCurrency;
	}

	public String getAmountForeign() {
		return amountForeign;
	}

	public void setAmountForeign(String amountForeign) {
		this.amountForeign = amountForeign;
	}

	public String getStoreRegNo() {
		return storeRegNo;
	}

	public void setStoreRegNo(String storeRegNo) {
		this.storeRegNo = storeRegNo;
	}

	public String getStoreName() {
		return storeName;
	}

	public void setStoreName(String storeName) {
		this.storeName = storeName;
	}

	public String getStoreNo() {
		return storeNo;
	}

	public void setStoreNo(String storeNo) {
		this.storeNo = storeNo;
	}

	public String getStoreRepresentative() {
		return storeRepresentative;
	}

	public void setStoreRepresentative(String storeRepresentative) {
		this.storeRepresentative = storeRepresentative;
	}

	public String getStoreCondition() {
		return storeCondition;
	}

	public void setStoreCondition(String storeCondition) {
		this.storeCondition = storeCondition;
	}

	public String getStoreCategory() {
		return storeCategory;
	}

	public void setStoreCategory(String storeCategory) {
		this.storeCategory = storeCategory;
	}

	public String getStoreZipCode() {
		return storeZipCode;
	}

	public void setStoreZipCode(String storeZipCode) {
		this.storeZipCode = storeZipCode;
	}

	public String getStoreAddress1() {
		return storeAddress1;
	}

	public void setStoreAddress1(String storeAddress1) {
		this.storeAddress1 = storeAddress1;
	}

	public String getStoreAddress2() {
		return storeAddress2;
	}

	public void setStoreAddress2(String storeAddress2) {
		this.storeAddress2 = storeAddress2;
	}

	public String getStoreTel() {
		return storeTel;
	}

	public void setStoreTel(String storeTel) {
		this.storeTel = storeTel;
	}

	public String getRepAmount() {
		return repAmount;
	}

	public void setRepAmount(String repAmount) {
		this.repAmount = repAmount;
	}

	public String getTaxAmount() {
		return taxAmount;
	}

	public void setTaxAmount(String taxAmount) {
		this.taxAmount = taxAmount;
	}

	public String getServiceAmount() {
		return serviceAmount;
	}

	public void setServiceAmount(String serviceAmount) {
		this.serviceAmount = serviceAmount;
	}

	public String getPaymentFlag() {
		return paymentFlag;
	}

	public void setPaymentFlag(String paymentFlag) {
		this.paymentFlag = paymentFlag;
	}

	public String getPaymentDate() {
		return paymentDate;
	}

	public void setPaymentDate(String paymentDate) {
		this.paymentDate = paymentDate;
	}

	public String getCollNo() {
		return collNo;
	}

	public void setCollNo(String collNo) {
		this.collNo = collNo;
	}

	public String getClassCode() {
		return classCode;
	}

	public void setClassCode(String classCode) {
		this.classCode = classCode;
	}
}
