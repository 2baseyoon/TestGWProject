package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class ExpenceApplicationVO  {
	
	/**
	 * act_expence_application
	 * */
	private String form_inst_id;
	private String applicationTitle;			//신청제목
	private String applicationDate;				//신청일
	private String ur_code;						//결재행위자

	/**
	 * act_expence_application_list
	 * */
	private String evidence_index;
	private String proofDate;					//증빙일자
	private String proofCode;					//증빙타입
	private String cardUID;				//카드승인번호
	private String taxType;						//세금유형
	private String taxCode;						//세금코드
	private String payAdjustMethod;				//정산방법
	private String payMethod;					//지급방법
	private String vendorNo;					//거래처등록번호
	private String totalAmount;					//합계액
	private String docNo;						//전표번호

	/**
	 * act_expence_application_div
	 * */
	private String division_index;
	private String accountCode;					//계정과목
	private String costCenterCode;				//코스트센터코드
	private String amount;						//금액
	private String usageComment;				//사용내역
	
	public void setAll(CoviMap info) {
		/**
		 * act_expence_application
		 * */
		this.form_inst_id		= rtString(info.get("form_inst_id"));		//비용신청ID
		this.applicationTitle			= rtString(info.get("applicationTitle"));			//신청제목
		this.applicationDate			= rtString(info.get("applicationDate"));			//신청일
		this.ur_code					= rtString(info.get("ur_code"));					//결재행위자

		/**
		 * act_expence_application_list
		 * */
		this.evidence_index	= rtString(info.get("evidence_index"));	//비용신청목록ID
		this.proofDate					= rtString(info.get("proofDate"));					//증빙일자
		this.proofCode					= rtString(info.get("proofCode"));					//증빙타입
		this.cardUID				= rtString(info.get("cardUID"));				//카드승인번호
		this.taxType					= rtString(info.get("taxType"));					//세금유형
		this.taxCode					= rtString(info.get("taxCode"));					//세금코드
		this.payAdjustMethod			= rtString(info.get("payAdjustMethod"));			//정산방법
		this.payMethod					= rtString(info.get("payMethod"));					//지급방법
		this.vendorNo					= rtString(info.get("vendorNo"));					//거래처등록번호
		this.totalAmount				= rtString(info.get("totalAmount"));				//합계액
		this.docNo						= rtString(info.get("docNo"));						//전표번호

		/**
		 * act_expence_application_div
		 * */
		this.division_index	= rtString(info.get("division_index"));
		this.accountCode				= rtString(info.get("accountCode"));				//계정과목
		this.costCenterCode				= rtString(info.get("costCenterCode"));				//코스트센터코드
		this.amount						= rtString(info.get("amount"));						//금액
		this.usageComment				= rtString(info.get("usageComment"));				//사용내역
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getform_inst_id() {
		return form_inst_id;
	}

	public void setform_inst_id(String form_inst_id) {
		this.form_inst_id = form_inst_id;
	}

	public String getApplicationTitle() {
		return applicationTitle;
	}

	public void setApplicationTitle(String applicationTitle) {
		this.applicationTitle = applicationTitle;
	}

	public String getApplicationDate() {
		return applicationDate;
	}

	public void setApplicationDate(String applicationDate) {
		this.applicationDate = applicationDate;
	}

	public String getUr_code() {
		return ur_code;
	}

	public void setUr_code(String ur_code) {
		this.ur_code = ur_code;
	}

	public String getevidence_index() {
		return evidence_index;
	}

	public void setevidence_index(String evidence_index) {
		this.evidence_index = evidence_index;
	}

	public String getProofDate() {
		return proofDate;
	}

	public void setProofDate(String proofDate) {
		this.proofDate = proofDate;
	}

	public String getProofCode() {
		return proofCode;
	}

	public void setProofCode(String proofCode) {
		this.proofCode = proofCode;
	}

	public String getCardUID() {
		return cardUID;
	}

	public void setCardUID(String cardUID) {
		this.cardUID = cardUID;
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

	public String getPayAdjustMethod() {
		return payAdjustMethod;
	}

	public void setPayAdjustMethod(String payAdjustMethod) {
		this.payAdjustMethod = payAdjustMethod;
	}

	public String getPayMethod() {
		return payMethod;
	}

	public void setPayMethod(String payMethod) {
		this.payMethod = payMethod;
	}

	public String getVendorNo() {
		return vendorNo;
	}

	public void setVendorNo(String vendorNo) {
		this.vendorNo = vendorNo;
	}

	public String getTotalAmount() {
		return totalAmount;
	}

	public void setTotalAmount(String totalAmount) {
		this.totalAmount = totalAmount;
	}

	public String getDocNo() {
		return docNo;
	}

	public void setDocNo(String docNo) {
		this.docNo = docNo;
	}
	
	public String getdivision_index() {
		return division_index;
	}

	public void setdivision_index(String division_index) {
		this.division_index = division_index;
	}
	
	public String getAccountCode() {
		return accountCode;
	}

	public void setAccountCode(String accountCode) {
		this.accountCode = accountCode;
	}

	public String getCostCenterCode() {
		return costCenterCode;
	}

	public void setCostCenterCode(String costCenterCode) {
		this.costCenterCode = costCenterCode;
	}

	public String getAmount() {
		return amount;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}

	public String getUsageComment() {
		return usageComment;
	}

	public void setUsageComment(String usageComment) {
		this.usageComment = usageComment;
	}
}
