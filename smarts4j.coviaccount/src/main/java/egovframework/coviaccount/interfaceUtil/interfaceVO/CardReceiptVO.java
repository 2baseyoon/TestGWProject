package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class CardReceiptVO {

	private String totalCount;
	private String receiptID;
	private String approveStatus;
	private String dataIndex;
	private String sendDate;
	private String itemNo;
	private String cardNo;
	private String infoIndex;
	private String infoType;
	private String cardCompIndex;
	private String cardRegType;
	private String cardType;
	private String bizPlaceNo;
	private String dept;
	private String cardUserCode;
	private String useDate;
	private String approveDate;
	private String approveTime;
	private String approveNo;
	private String withdrawDate;
	private String countryIndex;
	private String amountSign;
	private String amountWon;
	private String foreignCurrency;
	private String amountForeign;
	private String storeRegNo;
	private String storeName;
	private String storeNo;
	private String storeRepresentative;
	private String storeCondition;
	private String storeCategory;
	private String storeZipCode;
	private String storeAddress1;
	private String storeAddress2;
	private String storeTel;
	private String storeStatus;
	private String repAmount;
	private String taxAmount;
	private String serviceAmount;
	private String active;
	private String intDate;
	private String collNo;
	private String taxType;
	private String taxTypeDate;
	private String merchCessDate;
	private String class1;
	private String tossUserCode;
	private String tossSenderUserCode;
	private String tossDate;
	private String tossComment;
	private String isPersonalUse;
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	public void setAll(CoviMap info) {
		this.totalCount 	= rtString(info.get("totalCount"));
		this.receiptID 		= rtString(info.get("receiptID"));
		this.approveStatus 	= rtString(info.get("approveStatus"));
		this.dataIndex 		= rtString(info.get("dataIndex"));
		this.sendDate 		= rtString(info.get("sendDate"));
		this.itemNo 		= rtString(info.get("itemNo"));
		this.cardNo 		= rtString(info.get("cardNo"));
		this.infoIndex 		= rtString(info.get("infoIndex"));
		this.infoType 		= rtString(info.get("infoType"));
		this.cardCompIndex 	= rtString(info.get("cardCompIndex"));
		this.cardRegType 	= rtString(info.get("cardRegType"));
		this.cardType 		= rtString(info.get("cardType"));
		this.bizPlaceNo 	= rtString(info.get("bizPlaceNo"));
		this.dept 			= rtString(info.get("dept"));
		this.cardUserCode 	= rtString(info.get("cardUserCode"));
		this.useDate 		= rtString(info.get("useDate"));
		this.approveDate 	= rtString(info.get("approveDate"));
		this.approveTime 	= rtString(info.get("approveTime"));
		this.approveNo		= rtString(info.get("approveNo"));
		this.withdrawDate 	= rtString(info.get("withdrawDate"));
		this.countryIndex 	= rtString(info.get("countryIndex"));
		this.amountSign 	= rtString(info.get("amountSign"));
		this.amountWon 		= rtString(info.get("amountWon"));
		this.foreignCurrency = rtString(info.get("foreignCurrency"));
		this.amountForeign 	= rtString(info.get("amountForeign"));
		this.storeRegNo 	= rtString(info.get("storeRegNo"));
		this.storeName 		= rtString(info.get("storeName"));
		this.storeNo 		= rtString(info.get("storeNo"));
		this.storeRepresentative = rtString(info.get("storeRepresentative"));
		this.storeCondition = rtString(info.get("storeCondition"));
		this.storeCategory	= rtString(info.get("storeCategory"));
		this.storeZipCode 	= rtString(info.get("storeZipCode"));
		this.storeAddress1	= rtString(info.get("storeAddress1"));
		this.storeAddress2 	= rtString(info.get("storeAddress2"));
		this.storeTel 		= rtString(info.get("storeTel"));
		this.storeStatus 	= rtString(info.get("storeStatus"));
		this.repAmount 		= rtString(info.get("repAmount"));
		this.taxAmount 		= rtString(info.get("taxAmount"));
		this.serviceAmount 	= rtString(info.get("serviceAmount"));
		this.active 		= rtString(info.get("active"));
		this.intDate 		= rtString(info.get("intDate"));
		this.collNo 		= rtString(info.get("collNo"));
		this.taxType 		= rtString(info.get("taxType"));
		this.taxTypeDate 	= rtString(info.get("taxTypeDate"));
		this.merchCessDate 	= rtString(info.get("merchCessDate"));
		this.class1 		= rtString(info.get("class1"));
		this.tossUserCode 	= rtString(info.get("tossUserCode"));
		this.tossSenderUserCode = rtString(info.get("tossSenderUserCode"));
		this.tossDate 		= rtString(info.get("tossDate"));
		this.tossComment 	= rtString(info.get("tossComment"));
		this.isPersonalUse 	= rtString(info.get("isPersonalUse"));
		
	}
	
	public String getTotalCount() {
		return totalCount;
	}
	
	public void setTotalCount(String totalCount){
		this.totalCount = totalCount;
	}
	
	public String getReceiptID() {
		return receiptID;
	}
	
	public void setReceiptId(String receiptID){
		this.receiptID = receiptID;
	}
	
	public String getApproveStatus() {
		return approveStatus;
	}

	public void setApproveStatus(String approveStatus) {
		this.approveStatus = approveStatus;
	}

	public String getDataIndex() {
		return dataIndex;
	}

	public void setDataIndex(String dataIndex) {
		this.dataIndex = dataIndex;
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
	
	public String getStoreStatus() {
		return storeStatus;
	}

	public void setStoreStatus(String storeStatus) {
		this.storeStatus = storeStatus;
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

	public String getActive() {
		return active;
	}

	public void setActive(String active) {
		this.active = active;
	}

	public String getIntDate() {
		return intDate;
	}

	public void setIntDate(String intDate) {
		this.intDate = intDate;
	}

	public String getCollNo() {
		return collNo;
	}

	public void setCollNo(String collNo) {
		this.collNo = collNo;
	}

	public String getTaxType() {
		return taxType;
	}

	public void setTaxType(String taxType) {
		this.taxType = taxType;
	}

	public String getTaxTypeDate() {
		return taxTypeDate;
	}

	public void setTaxTypeDate(String taxTypeDate) {
		this.taxTypeDate = taxTypeDate;
	}

	public String getMerchCessDate() {
		return merchCessDate;
	}

	public void setMerchCessDate(String merchCessDate) {
		this.merchCessDate = merchCessDate;
	}

	public String getClass1() {
		return class1;
	}

	public void setClass(String class1) {
		this.class1 = class1;
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

	public String getTossComment() {
		return tossComment;
	}

	public void setTossComment(String tossComment) {
		this.tossComment = tossComment;
	}

	public String getIsPersonalUse() {
		return isPersonalUse;
	}

	public void setIsPersonalUse(String isPersonalUse) {
		this.isPersonalUse = isPersonalUse;
	}
	
}
