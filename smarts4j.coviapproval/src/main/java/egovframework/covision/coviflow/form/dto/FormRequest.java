package egovframework.covision.coviflow.form.dto;

import egovframework.baseframework.data.CoviMap;

public class FormRequest {

	private String processID;
	private String workItemID;
	private String performerID;
	private String formID;
	private String formInstanceID;
	private String formTempInstanceID;
	private String processDescriptionID;		// ID
	private String readMode;
	private String readModeTemp;
	private String readtype;
	private String gLoct;
	private String userCode;
	private String subkind;
	private String formInstanceTableName;
	private String requestFormInstID;
	private String editMode;
	private String archived;
	private String adminType;
	private String isAuth;
	private String isReuse;
	private String isHistory;
	private String isUsisdocmanager;
	private String isTempSaveBtn;
	private String isSecDoc;				// 구분값
	private String formPrefix;
	private CoviMap docModifyApvLine;
	private String isMobile;
	private String isApvLineChanged;
	private String isLegacy;
	private String jsonBodyContext;
	private String htmlBodyContext;
	private String mobileBodyContext;
	private String legacyBodyContext;
	private String subject;
	private String legacyDataType;
	private String parentProcessID;
	private String bstored;
	private String formCompanyCode;
	private String menuKind;
	private String doclisttype;
	private String isFormInstArchived;
	
	private String ownerProcessId;
	
	private String expAppID;
	private String ownerExpAppID;

	private String isOpen;
	
	private String govState;
	private String govDocID;
	private String govRecordID;
	private String govRecordRowSeq;
	private String isGovDocReply;
	private String senderInfo;
	private String govFormInstID;
	private String legacyApprovalLine;

	private String cstfRevID; // 양식스토어 아이디
	
	public FormRequest() {
		// 기본 생성자
	}
	
	public String getProcessID() {
		return processID;
	}

	public void setProcessID(String processID) {
		this.processID = processID;
	}

	public String getWorkitemID() {
		return workItemID;
	}

	public void setWorkitemID(String workitemID) {
		this.workItemID = workitemID;
	}

	public String getPerformerID() {
		return performerID;
	}

	public void setPerformerID(String performerID) {
		this.performerID = performerID;
	}

	public String getFormId() {
		return formID;
	}

	public void setFormId(String formId) {
		this.formID = formId;
	}

	public String getFormInstanceID() {
		return formInstanceID;
	}

	public void setFormInstanceID(String formInstanceID) {
		this.formInstanceID = formInstanceID;
	}

	public String getFormTempInstanceID() {
		return formTempInstanceID;
	}

	public void setFormTempInstanceID(String formTempInstanceID) {
		this.formTempInstanceID = formTempInstanceID;
	}

	public String getProcessdescriptionID() {
		return processDescriptionID;
	}

	public void setProcessdescriptionID(String processdescriptionID) {
		this.processDescriptionID = processdescriptionID;
	}

	public String getReadMode() {
		return readMode;
	}

	public void setReadMode(String readMode) {
		this.readMode = readMode;
	}

	public String getReadModeTemp() {
		return readModeTemp;
	}

	public void setReadModeTemp(String readModeTemp) {
		this.readModeTemp = readModeTemp;
	}

	public String getReadtype() {
		return readtype;
	}

	public void setReadtype(String readtype) {
		this.readtype = readtype;
	}

	public String getGLoct() {
		return gLoct;
	}

	public void setGLoct(String gLoct) {
		this.gLoct = gLoct;
	}

	public String getUserCode() {
		return userCode;
	}

	public void setUserCode(String userCode) {
		this.userCode = userCode;
	}

	public String getSubkind() {
		return subkind;
	}

	public void setSubkind(String subkind) {
		this.subkind = subkind;
	}

	public String getFormInstanceTableName() {
		return formInstanceTableName;
	}

	public void setFormInstanceTableName(String formInstanceTableName) {
		this.formInstanceTableName = formInstanceTableName;
	}

	public String getRequestFormInstID() {
		return requestFormInstID;
	}

	public void setRequestFormInstID(String requestFormInstID) {
		this.requestFormInstID = requestFormInstID;
	}

	public String getEditMode() {
		return editMode;
	}

	public void setEditMode(String editMode) {
		this.editMode = editMode;
	}

	public String getArchived() {
		return archived;
	}

	public void setArchived(String archived) {
		this.archived = archived;
	}

	public String getAdmintype() {
		return adminType;
	}

	public void setAdmintype(String admintype) {
		this.adminType = admintype;
	}

	public String getIsAuth() {
		return isAuth;
	}

	public void setIsAuth(String isAuth) {
		this.isAuth = isAuth;
	}

	public String getIsReuse() {
		return isReuse;
	}

	public void setIsReuse(String isReuse) {
		this.isReuse = isReuse;
	}

	public String getIsHistory() {
		return isHistory;
	}

	public void setIsHistory(String isHistory) {
		this.isHistory = isHistory;
	}

	public String getIsUsisdocmanager() {
		return isUsisdocmanager;
	}

	public void setIsUsisdocmanager(String isUsisdocmanager) {
		this.isUsisdocmanager = isUsisdocmanager;
	}

	public String getIsSecdoc() {
		return isSecDoc;
	}

	public void setIsSecdoc(String isSecdoc) {
		this.isSecDoc = isSecdoc;
	}

	public String getFormPrefix() {
		return formPrefix;
	}

	public void setFormPrefix(String formPrefix) {
		this.formPrefix = formPrefix;
	}

	public CoviMap getDocModifyApvLine() {
		return docModifyApvLine;
	}

	public void setDocModifyApvLine(CoviMap docModifyApvLine) {
		this.docModifyApvLine = docModifyApvLine;
	}

	public String getIsMobile() {
		return isMobile;
	}

	public void setIsMobile(String isMobile) {
		this.isMobile = isMobile;
	}

	public String getIsApvLineChg() {
		return isApvLineChanged;
	}

	public void setIsApvLineChg(String isApvLineChg) {
		this.isApvLineChanged = isApvLineChg;
	}

	public String getIsLegacy() {
		return isLegacy;
	}

	public void setIsLegacy(String isLegacy) {
		this.isLegacy = isLegacy;
	}

	public String getJsonBodyContext() {
		return jsonBodyContext;
	}

	public void setJsonBodyContext(String jsonBodyContext) {
		this.jsonBodyContext = jsonBodyContext;
	}

	public String getHtmlBodyContext() {
		return htmlBodyContext;
	}

	public void setHtmlBodyContext(String htmlBodyContext) {
		this.htmlBodyContext = htmlBodyContext;
	}

	public String getLegacyBodyContext() {
		return legacyBodyContext;
	}

	public void setLegacyBodyContext(String legacyBodyContext) {
		this.legacyBodyContext = legacyBodyContext;
	}
    
	public String getSubject() {
		return subject;
	}

	public void setSubject(String subject) {
		// goFormLink.do 통해서 팝업 여는 경우 특수문자 변환되어 수정함.
		// &amp;amp; 치환하기 위하여 2번 replace
		this.subject = subject.replace("&amp;", "&");
	}

	public String getIsTempSaveBtn() {
		return isTempSaveBtn;
	}

	public void setIsTempSaveBtn(String isTempSaveBtn) {
		this.isTempSaveBtn = isTempSaveBtn;
	}

	public String getLegacyDataType() {
		return legacyDataType;
	}
		
	public void setLegacyDataType(String legacyDataType) {
		this.legacyDataType = legacyDataType;
	}
	
	public String getParentProcessID() {
		return parentProcessID;
	}
	
	public void setParentProcessID(String parentProcessID) {
		this.parentProcessID = parentProcessID;
	}
	
	public String getBstored() {
		return bstored;
	}

	public void setBstored(String bstored) {
		this.bstored = bstored;
	}

	public String getMenuKind() {
		return menuKind;
	}

	public void setMenuKind(String menuKind) {
		this.menuKind = menuKind;
	}

	public String getDoclisttype() {
		return doclisttype;
	}

	public void setDoclisttype(String doclisttype) {
		this.doclisttype = doclisttype;
	}

	public String getGovState() {
		return govState;
	}

	public void setGovState(String govState) {
		this.govState = govState;
	}

	public String getGovDocID() {
		return govDocID;
	}

	public void setGovDocID(String govDocID) {
		this.govDocID = govDocID;
	}

	public String getMobileBodyContext() {
		return mobileBodyContext;
	}

	public void setMobileBodyContext(String mobileBodyContext) {
		this.mobileBodyContext = mobileBodyContext;
	}

	public String getIsFormInstArchived() {
		return isFormInstArchived;
	}

	public void setIsFormInstArchived(String isFormInstArchived) {
		this.isFormInstArchived = isFormInstArchived;
	}

	public String getGovRecordID() {
		return govRecordID;
	}

	public void setGovRecordID(String govRecordID) {
		this.govRecordID = govRecordID;
	}
	
	public String getGovRecordRowSeq() {
		return govRecordRowSeq;
	}
	
	public void setGovRecordRowSeq(String govRecordRowSeq) {
		this.govRecordRowSeq = govRecordRowSeq;
	}

	public String getOwnerProcessId() {
		return ownerProcessId;
	}

	public void setOwnerProcessId(String ownerProcessId) {
		this.ownerProcessId = ownerProcessId;
	}

	public String getOwnerExpAppID() {
		return ownerExpAppID;
	}

	public void setOwnerExpAppID(String ownerExpAppID) {
		this.ownerExpAppID = ownerExpAppID;
	}

	public String getIsOpen() {
		return isOpen;
	}

	public void setIsOpen(String isOpen) {
		this.isOpen = isOpen;
	}

	public String getFormCompanyCode() {
		return formCompanyCode;
	}

	public void setFormCompanyCode(String formCompanyCode) {
		this.formCompanyCode = formCompanyCode;
	}
	
	public String getIsgovDocReply() {
		return isGovDocReply;
	}

	public void setIsgovDocReply(String isgovDocReply) {
		this.isGovDocReply = isgovDocReply;
	}
	
	public String getSenderInfo() {
		return senderInfo;
	}

	public void setSenderInfo(String senderInfo) {
		this.senderInfo = senderInfo;
	}

	public String getGovFormInstID() {
		return govFormInstID;
	}

	public void setGovFormInstID(String govFormInstID) {
		this.govFormInstID = govFormInstID;
	}

	public String getExpAppID() {
		return expAppID;
	}

	public void setExpAppID(String expAppID) {
		this.expAppID = expAppID;
	}
	
	public String getCstfRevID() {
		return cstfRevID;
	}
	public void setCstfRevID(String cstfRevID) {
		this.cstfRevID = cstfRevID;
	}

	public String getLegacyApprovalLine() {
		return legacyApprovalLine;
	}

	public void setLegacyApprovalLine(String legacyApprovalLine) {
		this.legacyApprovalLine = legacyApprovalLine;
	}
}
