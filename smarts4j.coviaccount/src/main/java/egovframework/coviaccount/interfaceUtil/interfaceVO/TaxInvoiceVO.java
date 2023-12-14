package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class TaxInvoiceVO{
	//MAIN
	private String taxInvoiceID;			//세금계산서ID
	private String companyCode;				//회사코드
	//private String dataIndex;				//매입매출구분(AP:매입AR:매입)
	private String writeDate;				//작성일자
	private String issueDT;					//발행일시
	private String invoiceType;				//세금계산서종류
	private String taxType;					//과세형태
	private String taxTotal;				//세액합계
	private String supplyCostTotal;			//공급가액합계
	private String totalAmount;				//합계금액
	private String purposeType;				//영수청구구분
	private String serialNum;				//일련번호
	private String cash;					//현금
	private String chkBill;					//수표
	private String credit;					//외상
	private String note;					//어음
	private String remark1;					//비고
	private String remark2;					//비고
	private String remark3;					//비고
	private String nTSConfirmNum;			//국세청승인번호
	private String modifyCode;				//수정사유코드
	private String orgNTSConfirmNum;		//원본국세청승인번호
	private String invoicerCorpNum;			//공급자사업자번호
	private String invoicerMgtKey;			//공급자관리번호
	private String invoicerTaxRegID;		//공급자종사업장번호
	private String invoicerCorpName;		//공급자회사명
	private String invoicerCEOName;			//공급자대표자명
	private String invoicerAddr;			//공급자주소
	private String invoicerBizType;			//공급자업태
	private String invoicerBizClass;		//공급자업종
	private String invoicerContactName;		//공급자담당자이름
	private String invoicerDeptName;		//공급자담당자부서이름
	private String invoicerTel;				//공급자담당자연락처
	private String invoicerEmail;			//공급자담당자이메일
	private String invoiceeCorpNum;			//공급받는자사업자번호
	private String invoiceeType;			//공급받는자구분
	private String invoiceeMgtKey;			//공급받는자관리번호
	private String invoiceeTaxRegID;		//공급받는자종사업장번호
	private String invoiceeCorpName;		//공급받는자회사명
	private String invoiceeCEOName;			//공급받는자대표자명
	private String invoiceeAddr;			//공급받는자주소
	private String invoiceeBizType;			//공급받는자업태
	private String invoiceeBizClass;		//공급받는자업종
	private String invoiceeContactName1;	//공급받는자주)담당자이름
	private String invoiceeDeptName1;		//공급받는자주)담당자부서이름
	private String invoiceeTel1;			//공급받는자주)담당자연락처
	private String invoiceeEmail1;			//공급받는자주)담당자이메일
	private String invoiceeContactName2;	//공급받는자부)담당자이름
	private String invoiceDeptName2;		//공급받는자부)담당자부서이름
	private String invoiceTel2;				//공급받는자부)담당자연락처
	private String invoiceEmail2;			//공급받는자부)담당자이메일
	private String trusteeCorpNum;			//수탁자사업자번호
	private String trusteeMgtKey;			//수탁자관리번호
	private String trusteeTaxRegID;			//수탁자종사업장번호
	private String trusteeCorpName;			//수탁자회사명
	private String trusteeCEOName;			//수탁자대표자명
	private String trusteeAddr;				//수탁자주소
	private String trusteeBizType;			//수탁자업태
	private String trusteeBizClass;			//수탁자업종
	private String trusteeContactName;		//수탁자담당자이름
	private String trusteeDeptName;			//수탁자담당자부서이름
	private String trusteeTel;				//수탁자담당자연락처
	private String trusteeEmail;			//수탁자이메일
	private String tossUserCode;			//전달받은사용자코드
	private String tossSenderUserCode;		//전달자사용자코드
	private String tossDate;				//전달일시
	private String toss;					//증빙전달시코멘트항목
	private String registDate_main;			//등록일
	private String intDate;					//인터페이스시각
	private String isOffset;				//상계처리여부
	private String cONVERSATION_ID;			//CONVERSATION_ID(세금계산서IF용)
	private String sUPBUY_TYPE;				//매입매출구분(세금계산서IF용)
	private String dIRECTION;				//정/역구분(세금계산서IF용)
	
	//ITEM
	private String taxInvoiceItemID;		//세금계산서품목ID       
	private String purchaseDT;				//거래일자            
	private String itemName;				//품명              
	private String spec;					//규격              
	private String qty;						//수량              
	private String unitCost;				//단가              
	private String supplyCost;				//공급가액            
	private String tax;						//세액              
	private String remark;					//비고              
	private String registDate_item;			//등록일시            

	private String total;
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	public void setAll(CoviMap info) {
		this.taxInvoiceID			= rtString(info.get("taxInvoiceID"));
		this.companyCode			= rtString(info.get("companyCode"));
		//this.dataIndex				= rtString(info.get("dataIndex"));
		this.writeDate				= rtString(info.get("writeDate"));
		this.issueDT				= rtString(info.get("issueDT"));
		this.invoiceType			= rtString(info.get("invoiceType"));
		this.taxType				= rtString(info.get("taxType"));
		this.taxTotal				= rtString(info.get("taxTotal"));
		this.supplyCostTotal		= rtString(info.get("supplyCostTotal"));
		this.totalAmount			= rtString(info.get("totalAmount"));
		this.purposeType			= rtString(info.get("purposeType"));
		this.serialNum				= rtString(info.get("serialNum"));
		this.cash					= rtString(info.get("cash"));
		this.chkBill				= rtString(info.get("chkBill"));
		this.credit					= rtString(info.get("credit"));
		this.note					= rtString(info.get("note"));
		this.remark1				= rtString(info.get("remark1"));
		this.remark2				= rtString(info.get("remark2"));
		this.remark3				= rtString(info.get("remark3"));
		this.nTSConfirmNum			= rtString(info.get("nTSConfirmNum"));
		this.modifyCode				= rtString(info.get("modifyCode"));
		this.orgNTSConfirmNum		= rtString(info.get("orgNTSConfirmNum"));
		this.invoicerCorpNum		= rtString(info.get("invoicerCorpNum"));
		this.invoicerMgtKey			= rtString(info.get("invoicerMgtKey"));
		this.invoicerTaxRegID		= rtString(info.get("invoicerTaxRegID"));
		this.invoicerCorpName		= rtString(info.get("invoicerCorpName"));
		this.invoicerCEOName		= rtString(info.get("invoicerCEOName"));
		this.invoicerAddr			= rtString(info.get("invoicerAddr"));
		this.invoicerBizType		= rtString(info.get("invoicerBizType"));
		this.invoicerBizClass		= rtString(info.get("invoicerBizClass"));
		this.invoicerContactName	= rtString(info.get("invoicerContactName"));
		this.invoicerDeptName		= rtString(info.get("invoicerDeptName"));
		this.invoicerTel			= rtString(info.get("invoicerTel"));
		this.invoicerEmail			= rtString(info.get("invoicerEmail"));
		this.invoiceeCorpNum		= rtString(info.get("invoiceeCorpNum"));
		this.invoiceeType			= rtString(info.get("invoiceeType"));
		this.invoiceeMgtKey			= rtString(info.get("invoiceeMgtKey"));
		this.invoiceeTaxRegID		= rtString(info.get("invoiceeTaxRegID"));
		this.invoiceeCorpName		= rtString(info.get("invoiceeCorpName"));
		this.invoiceeCEOName		= rtString(info.get("invoiceeCEOName"));
		this.invoiceeAddr			= rtString(info.get("invoiceeAddr"));
		this.invoiceeBizType		= rtString(info.get("invoiceeBizType"));
		this.invoiceeBizClass		= rtString(info.get("invoiceeBizClass"));
		this.invoiceeContactName1	= rtString(info.get("invoiceeContactName1"));
		this.invoiceeDeptName1		= rtString(info.get("invoiceeDeptName1"));
		this.invoiceeTel1			= rtString(info.get("invoiceeTel1"));
		this.invoiceeEmail1			= rtString(info.get("invoiceeEmail1"));
		this.invoiceeContactName2	= rtString(info.get("invoiceeContactName2"));
		this.invoiceDeptName2		= rtString(info.get("invoiceDeptName2"));
		this.invoiceTel2			= rtString(info.get("invoiceTel2"));
		this.invoiceEmail2			= rtString(info.get("invoiceEmail2"));
		this.trusteeCorpNum			= rtString(info.get("trusteeCorpNum"));
		this.trusteeMgtKey			= rtString(info.get("trusteeMgtKey"));
		this.trusteeTaxRegID		= rtString(info.get("trusteeTaxRegID"));
		this.trusteeCorpName		= rtString(info.get("trusteeCorpName"));
		this.trusteeCEOName			= rtString(info.get("trusteeCEOName"));
		this.trusteeAddr			= rtString(info.get("trusteeAddr"));
		this.trusteeBizType			= rtString(info.get("trusteeBizType"));
		this.trusteeBizClass		= rtString(info.get("trusteeBizClass"));
		this.trusteeContactName		= rtString(info.get("trusteeContactName"));
		this.trusteeDeptName		= rtString(info.get("trusteeDeptName"));
		this.trusteeTel				= rtString(info.get("trusteeTel"));
		this.trusteeEmail			= rtString(info.get("trusteeEmail"));
		this.tossUserCode			= rtString(info.get("tossUserCode"));
		this.tossSenderUserCode		= rtString(info.get("tossSenderUserCode"));
		this.tossDate				= rtString(info.get("tossDate"));
		this.toss					= rtString(info.get("toss"));
		this.registDate_main		= rtString(info.get("registDate_main"));
		this.intDate				= rtString(info.get("intDate"));
		this.isOffset				= rtString(info.get("isOffset"));
		this.cONVERSATION_ID		= rtString(info.get("cONVERSATION_ID"));
		this.sUPBUY_TYPE			= rtString(info.get("sUPBUY_TYPE"));
		this.dIRECTION				= rtString(info.get("dIRECTION"));
		this.total					= rtString(info.get("total"));
		this.taxInvoiceItemID		= rtString(info.get("taxInvoiceItemID"));
		this.purchaseDT				= rtString(info.get("purchaseDT"));
		this.itemName				= rtString(info.get("itemName"));
		this.spec					= rtString(info.get("spec"));
		this.qty					= rtString(info.get("qty"));
		this.unitCost				= rtString(info.get("unitCost"));
		this.supplyCost				= rtString(info.get("supplyCost"));
		this.tax					= rtString(info.get("tax"));
		this.remark					= rtString(info.get("remark"));
		this.registDate_item		= rtString(info.get("registDate_item"));
	}

	public String getTaxInvoiceID() {
		return taxInvoiceID;
	}

	public void setTaxInvoiceID(String taxInvoiceID) {
		this.taxInvoiceID = taxInvoiceID;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	/*
	public String getDataIndex() {
		return dataIndex;
	}

	public void setDataIndex(String dataIndex) {
		this.dataIndex = dataIndex;
	}
	*/
	
	public String getWriteDate() {
		return writeDate;
	}

	public void setWriteDate(String writeDate) {
		this.writeDate = writeDate;
	}

	public String getIssueDT() {
		return issueDT;
	}

	public void setIssueDT(String issueDT) {
		this.issueDT = issueDT;
	}

	public String getInvoiceType() {
		return invoiceType;
	}

	public void setInvoiceType(String invoiceType) {
		this.invoiceType = invoiceType;
	}

	public String getTaxType() {
		return taxType;
	}

	public void setTaxType(String taxType) {
		this.taxType = taxType;
	}

	public String getTaxTotal() {
		return taxTotal;
	}

	public void setTaxTotal(String taxTotal) {
		this.taxTotal = taxTotal;
	}

	public String getSupplyCostTotal() {
		return supplyCostTotal;
	}

	public void setSupplyCostTotal(String supplyCostTotal) {
		this.supplyCostTotal = supplyCostTotal;
	}

	public String getTotalAmount() {
		return totalAmount;
	}

	public void setTotalAmount(String totalAmount) {
		this.totalAmount = totalAmount;
	}

	public String getPurposeType() {
		return purposeType;
	}

	public void setPurposeType(String purposeType) {
		this.purposeType = purposeType;
	}

	public String getSerialNum() {
		return serialNum;
	}

	public void setSerialNum(String serialNum) {
		this.serialNum = serialNum;
	}

	public String getCash() {
		return cash;
	}

	public void setCash(String cash) {
		this.cash = cash;
	}

	public String getChkBill() {
		return chkBill;
	}

	public void setChkBill(String chkBill) {
		this.chkBill = chkBill;
	}

	public String getCredit() {
		return credit;
	}

	public void setCredit(String credit) {
		this.credit = credit;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getRemark1() {
		return remark1;
	}

	public void setRemark1(String remark1) {
		this.remark1 = remark1;
	}

	public String getRemark2() {
		return remark2;
	}

	public void setRemark2(String remark2) {
		this.remark2 = remark2;
	}

	public String getRemark3() {
		return remark3;
	}

	public void setRemark3(String remark3) {
		this.remark3 = remark3;
	}

	public String getnTSConfirmNum() {
		return nTSConfirmNum;
	}

	public void setnTSConfirmNum(String nTSConfirmNum) {
		this.nTSConfirmNum = nTSConfirmNum;
	}

	public String getModifyCode() {
		return modifyCode;
	}

	public void setModifyCode(String modifyCode) {
		this.modifyCode = modifyCode;
	}

	public String getOrgNTSConfirmNum() {
		return orgNTSConfirmNum;
	}

	public void setOrgNTSConfirmNum(String orgNTSConfirmNum) {
		this.orgNTSConfirmNum = orgNTSConfirmNum;
	}

	public String getInvoicerCorpNum() {
		return invoicerCorpNum;
	}

	public void setInvoicerCorpNum(String invoicerCorpNum) {
		this.invoicerCorpNum = invoicerCorpNum;
	}

	public String getInvoicerMgtKey() {
		return invoicerMgtKey;
	}

	public void setInvoicerMgtKey(String invoicerMgtKey) {
		this.invoicerMgtKey = invoicerMgtKey;
	}

	public String getInvoicerTaxRegID() {
		return invoicerTaxRegID;
	}

	public void setInvoicerTaxRegID(String invoicerTaxRegID) {
		this.invoicerTaxRegID = invoicerTaxRegID;
	}

	public String getInvoicerCorpName() {
		return invoicerCorpName;
	}

	public void setInvoicerCorpName(String invoicerCorpName) {
		this.invoicerCorpName = invoicerCorpName;
	}

	public String getInvoicerCEOName() {
		return invoicerCEOName;
	}

	public void setInvoicerCEOName(String invoicerCEOName) {
		this.invoicerCEOName = invoicerCEOName;
	}

	public String getInvoicerAddr() {
		return invoicerAddr;
	}

	public void setInvoicerAddr(String invoicerAddr) {
		this.invoicerAddr = invoicerAddr;
	}

	public String getInvoicerBizType() {
		return invoicerBizType;
	}

	public void setInvoicerBizType(String invoicerBizType) {
		this.invoicerBizType = invoicerBizType;
	}

	public String getInvoicerBizClass() {
		return invoicerBizClass;
	}

	public void setInvoicerBizClass(String invoicerBizClass) {
		this.invoicerBizClass = invoicerBizClass;
	}

	public String getInvoicerContactName() {
		return invoicerContactName;
	}

	public void setInvoicerContactName(String invoicerContactName) {
		this.invoicerContactName = invoicerContactName;
	}

	public String getInvoicerDeptName() {
		return invoicerDeptName;
	}

	public void setInvoicerDeptName(String invoicerDeptName) {
		this.invoicerDeptName = invoicerDeptName;
	}

	public String getInvoicerTel() {
		return invoicerTel;
	}

	public void setInvoicerTel(String invoicerTel) {
		this.invoicerTel = invoicerTel;
	}

	public String getInvoicerEmail() {
		return invoicerEmail;
	}

	public void setInvoicerEmail(String invoicerEmail) {
		this.invoicerEmail = invoicerEmail;
	}

	public String getInvoiceeCorpNum() {
		return invoiceeCorpNum;
	}

	public void setInvoiceeCorpNum(String invoiceeCorpNum) {
		this.invoiceeCorpNum = invoiceeCorpNum;
	}

	public String getInvoiceeType() {
		return invoiceeType;
	}

	public void setInvoiceeType(String invoiceeType) {
		this.invoiceeType = invoiceeType;
	}

	public String getInvoiceeMgtKey() {
		return invoiceeMgtKey;
	}

	public void setInvoiceeMgtKey(String invoiceeMgtKey) {
		this.invoiceeMgtKey = invoiceeMgtKey;
	}

	public String getInvoiceeTaxRegID() {
		return invoiceeTaxRegID;
	}

	public void setInvoiceeTaxRegID(String invoiceeTaxRegID) {
		this.invoiceeTaxRegID = invoiceeTaxRegID;
	}

	public String getInvoiceeCorpName() {
		return invoiceeCorpName;
	}

	public void setInvoiceeCorpName(String invoiceeCorpName) {
		this.invoiceeCorpName = invoiceeCorpName;
	}

	public String getInvoiceeCEOName() {
		return invoiceeCEOName;
	}

	public void setInvoiceeCEOName(String invoiceeCEOName) {
		this.invoiceeCEOName = invoiceeCEOName;
	}

	public String getInvoiceeAddr() {
		return invoiceeAddr;
	}

	public void setInvoiceeAddr(String invoiceeAddr) {
		this.invoiceeAddr = invoiceeAddr;
	}

	public String getInvoiceeBizType() {
		return invoiceeBizType;
	}

	public void setInvoiceeBizType(String invoiceeBizType) {
		this.invoiceeBizType = invoiceeBizType;
	}

	public String getInvoiceeBizClass() {
		return invoiceeBizClass;
	}

	public void setInvoiceeBizClass(String invoiceeBizClass) {
		this.invoiceeBizClass = invoiceeBizClass;
	}

	public String getInvoiceeContactName1() {
		return invoiceeContactName1;
	}

	public void setInvoiceeContactName1(String invoiceeContactName1) {
		this.invoiceeContactName1 = invoiceeContactName1;
	}

	public String getInvoiceeDeptName1() {
		return invoiceeDeptName1;
	}

	public void setInvoiceeDeptName1(String invoiceeDeptName1) {
		this.invoiceeDeptName1 = invoiceeDeptName1;
	}

	public String getInvoiceeTel1() {
		return invoiceeTel1;
	}

	public void setInvoiceeTel1(String invoiceeTel1) {
		this.invoiceeTel1 = invoiceeTel1;
	}

	public String getInvoiceeEmail1() {
		return invoiceeEmail1;
	}

	public void setInvoiceeEmail1(String invoiceeEmail1) {
		this.invoiceeEmail1 = invoiceeEmail1;
	}

	public String getInvoiceeContactName2() {
		return invoiceeContactName2;
	}

	public void setInvoiceeContactName2(String invoiceeContactName2) {
		this.invoiceeContactName2 = invoiceeContactName2;
	}

	public String getInvoiceDeptName2() {
		return invoiceDeptName2;
	}

	public void setInvoiceDeptName2(String invoiceDeptName2) {
		this.invoiceDeptName2 = invoiceDeptName2;
	}

	public String getInvoiceTel2() {
		return invoiceTel2;
	}

	public void setInvoiceTel2(String invoiceTel2) {
		this.invoiceTel2 = invoiceTel2;
	}

	public String getInvoiceEmail2() {
		return invoiceEmail2;
	}

	public void setInvoiceEmail2(String invoiceEmail2) {
		this.invoiceEmail2 = invoiceEmail2;
	}

	public String getTrusteeCorpNum() {
		return trusteeCorpNum;
	}

	public void setTrusteeCorpNum(String trusteeCorpNum) {
		this.trusteeCorpNum = trusteeCorpNum;
	}

	public String getTrusteeMgtKey() {
		return trusteeMgtKey;
	}

	public void setTrusteeMgtKey(String trusteeMgtKey) {
		this.trusteeMgtKey = trusteeMgtKey;
	}

	public String getTrusteeTaxRegID() {
		return trusteeTaxRegID;
	}

	public void setTrusteeTaxRegID(String trusteeTaxRegID) {
		this.trusteeTaxRegID = trusteeTaxRegID;
	}

	public String getTrusteeCorpName() {
		return trusteeCorpName;
	}

	public void setTrusteeCorpName(String trusteeCorpName) {
		this.trusteeCorpName = trusteeCorpName;
	}

	public String getTrusteeCEOName() {
		return trusteeCEOName;
	}

	public void setTrusteeCEOName(String trusteeCEOName) {
		this.trusteeCEOName = trusteeCEOName;
	}

	public String getTrusteeAddr() {
		return trusteeAddr;
	}

	public void setTrusteeAddr(String trusteeAddr) {
		this.trusteeAddr = trusteeAddr;
	}

	public String getTrusteeBizType() {
		return trusteeBizType;
	}

	public void setTrusteeBizType(String trusteeBizType) {
		this.trusteeBizType = trusteeBizType;
	}

	public String getTrusteeBizClass() {
		return trusteeBizClass;
	}

	public void setTrusteeBizClass(String trusteeBizClass) {
		this.trusteeBizClass = trusteeBizClass;
	}

	public String getTrusteeContactName() {
		return trusteeContactName;
	}

	public void setTrusteeContactName(String trusteeContactName) {
		this.trusteeContactName = trusteeContactName;
	}

	public String getTrusteeDeptName() {
		return trusteeDeptName;
	}

	public void setTrusteeDeptName(String trusteeDeptName) {
		this.trusteeDeptName = trusteeDeptName;
	}

	public String getTrusteeTel() {
		return trusteeTel;
	}

	public void setTrusteeTel(String trusteeTel) {
		this.trusteeTel = trusteeTel;
	}

	public String getTrusteeEmail() {
		return trusteeEmail;
	}

	public void setTrusteeEmail(String trusteeEmail) {
		this.trusteeEmail = trusteeEmail;
	}

	public String getTossUserCode() {
		return tossUserCode;
	}

	public void setTossUserCode(String tossUserCode) {
		this.tossUserCode = tossUserCode;
	}

	public String getTossSenderUserCode() {
		return tossSenderUserCode;
	}

	public void setTossSenderUserCode(String tossSenderUserCode) {
		this.tossSenderUserCode = tossSenderUserCode;
	}

	public String getTossDate() {
		return tossDate;
	}

	public void setTossDate(String tossDate) {
		this.tossDate = tossDate;
	}

	public String getToss() {
		return toss;
	}

	public void setToss(String toss) {
		this.toss = toss;
	}

	public String getRegistDate_main() {
		return registDate_main;
	}

	public void setRegistDate_main(String registDate_main) {
		this.registDate_main = registDate_main;
	}

	public String getIntDate() {
		return intDate;
	}

	public void setIntDate(String intDate) {
		this.intDate = intDate;
	}

	public String getIsOffset() {
		return isOffset;
	}

	public void setIsOffset(String isOffset) {
		this.isOffset = isOffset;
	}

	public String getcONVERSATION_ID() {
		return cONVERSATION_ID;
	}

	public void setcONVERSATION_ID(String cONVERSATION_ID) {
		this.cONVERSATION_ID = cONVERSATION_ID;
	}

	public String getsUPBUY_TYPE() {
		return sUPBUY_TYPE;
	}

	public void setsUPBUY_TYPE(String sUPBUY_TYPE) {
		this.sUPBUY_TYPE = sUPBUY_TYPE;
	}

	public String getdIRECTION() {
		return dIRECTION;
	}

	public void setdIRECTION(String dIRECTION) {
		this.dIRECTION = dIRECTION;
	}

	public String getTotal() {
		return total;
	}

	public void setTotal(String total) {
		this.total = total;
	}

	public String getTaxInvoiceItemID() {
		return taxInvoiceItemID;
	}

	public void setTaxInvoiceItemID(String taxInvoiceItemID) {
		this.taxInvoiceItemID = taxInvoiceItemID;
	}

	public String getPurchaseDT() {
		return purchaseDT;
	}

	public void setPurchaseDT(String purchaseDT) {
		this.purchaseDT = purchaseDT;
	}

	public String getItemName() {
		return itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName;
	}

	public String getSpec() {
		return spec;
	}

	public void setSpec(String spec) {
		this.spec = spec;
	}

	public String getQty() {
		return qty;
	}

	public void setQty(String qty) {
		this.qty = qty;
	}

	public String getUnitCost() {
		return unitCost;
	}

	public void setUnitCost(String unitCost) {
		this.unitCost = unitCost;
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

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getRegistDate_item() {
		return registDate_item;
	}

	public void setRegistDate_item(String registDate_item) {
		this.registDate_item = registDate_item;
	}
}
