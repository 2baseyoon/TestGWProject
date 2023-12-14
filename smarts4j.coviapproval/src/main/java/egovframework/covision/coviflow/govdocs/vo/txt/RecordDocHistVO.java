package egovframework.covision.coviflow.govdocs.vo.txt;

/*
 * 기록물등록대장변경이력정보
	1	처리과기관코드			처리과기관코드			C	7		1234567
	2	생산년도			생산년도			C	4		2002
	3	생산(접수)등록번호		생산(접수)등록번호		C	13		6050709000023(처리과기관코드+등록일련번호)
	4	분리등록번호			분리등록번호			C	2		01
	5	생산(접수)등록일자		변경 전				C	12		
	6					변경 후				C	12		
	7	제목				변경 전				C	500		
	8					변경 후				C	500		
	9	쪽수				변경 전				C	6		
	10					변경 후				C	6		
	11	결재권자(직위/직급)	변경 전				C	40		
	12					변경 후				C	40		
	13	기안자(업무담당자)		변경 전				C	40		
	14					변경 후				C	40		
	15	시행일자			변경 전				C	8		
	16					변경 후				C	8		
	17	수신자(발신자)		변경 전				C	100		
	18					변경 후				C	100		
	19	변경일자			변경일자			C	8		20020901(년+월+일)
	20	변경사유			변경사유			C	100		단위업무 소관 처리과 변경(행정과→수집과)에 따른 등록대장 수정
	21	변경자				변경자				C	40		홍길동
 */
public class RecordDocHistVO {

	private String recordDeptCode;
	private String productYear;
	private String productNum;
	private String attachNum;
	private String productDateBefore;
	private String productDateAfter;
	private String recordSubjectBefore;
	private String recordSubjectAfter;
	private String recordPageCountBefore;
	private String recordPageCountAfter;
	private String approvalNameBefore;
	private String approvalNameAfter;
	private String proposalNameBefore;
	private String proposalNameAfter;
	private String completeDateBefore;
	private String completeDateAfter;
	private String receiptNameBefore;
	private String receiptNameAfter;
	private String modifyDate;
	private String modifyReason;
	private String modifyName;
	
	
	public String getRecordDeptCode() {
		return recordDeptCode;
	}
	public void setRecordDeptCode(String recordDeptCode) {
		this.recordDeptCode = recordDeptCode;
	}
	public String getProductYear() {
		return productYear;
	}
	public void setProductYear(String productYear) {
		this.productYear = productYear;
	}
	public String getProductNum() {
		return productNum;
	}
	public void setProductNum(String productNum) {
		this.productNum = productNum;
	}
	public String getAttachNum() {
		return attachNum;
	}
	public void setAttachNum(String attachNum) {
		this.attachNum = attachNum;
	}
	public String getProductDateBefore() {
		return productDateBefore;
	}
	public void setProductDateBefore(String productDateBefore) {
		this.productDateBefore = productDateBefore;
	}
	public String getProductDateAfter() {
		return productDateAfter;
	}
	public void setProductDateAfter(String productDateAfter) {
		this.productDateAfter = productDateAfter;
	}
	public String getRecordSubjectBefore() {
		return recordSubjectBefore;
	}
	public void setRecordSubjectBefore(String recordSubjectBefore) {
		this.recordSubjectBefore = recordSubjectBefore;
	}
	public String getRecordSubjectAfter() {
		return recordSubjectAfter;
	}
	public void setRecordSubjectAfter(String recordSubjectAfter) {
		this.recordSubjectAfter = recordSubjectAfter;
	}
	public String getRecordPageCountBefore() {
		return recordPageCountBefore;
	}
	public void setRecordPageCountBefore(String recordPageCountBefore) {
		this.recordPageCountBefore = recordPageCountBefore;
	}
	public String getRecordPageCountAfter() {
		return recordPageCountAfter;
	}
	public void setRecordPageCountAfter(String recordPageCountAfter) {
		this.recordPageCountAfter = recordPageCountAfter;
	}
	public String getApprovalNameBefore() {
		return approvalNameBefore;
	}
	public void setApprovalNameBefore(String approvalNameBefore) {
		this.approvalNameBefore = approvalNameBefore;
	}
	public String getApprovalNameAfter() {
		return approvalNameAfter;
	}
	public void setApprovalNameAfter(String approvalNameAfter) {
		this.approvalNameAfter = approvalNameAfter;
	}
	public String getProposalNameBefore() {
		return proposalNameBefore;
	}
	public void setProposalNameBefore(String proposalNameBefore) {
		this.proposalNameBefore = proposalNameBefore;
	}
	public String getProposalNameAfter() {
		return proposalNameAfter;
	}
	public void setProposalNameAfter(String proposalNameAfter) {
		this.proposalNameAfter = proposalNameAfter;
	}
	public String getCompleteDateBefore() {
		return completeDateBefore;
	}
	public void setCompleteDateBefore(String completeDateBefore) {
		this.completeDateBefore = completeDateBefore;
	}
	public String getCompleteDateAfter() {
		return completeDateAfter;
	}
	public void setCompleteDateAfter(String completeDateAfter) {
		this.completeDateAfter = completeDateAfter;
	}
	public String getReceiptNameBefore() {
		return receiptNameBefore;
	}
	public void setReceiptNameBefore(String receiptNameBefore) {
		this.receiptNameBefore = receiptNameBefore;
	}
	public String getReceiptNameAfter() {
		return receiptNameAfter;
	}
	public void setReceiptNameAfter(String receiptNameAfter) {
		this.receiptNameAfter = receiptNameAfter;
	}
	public String getModifyDate() {
		return modifyDate;
	}
	public void setModifyDate(String modifyDate) {
		this.modifyDate = modifyDate;
	}
	public String getModifyReason() {
		return modifyReason;
	}
	public void setModifyReason(String modifyReason) {
		this.modifyReason = modifyReason;
	}
	public String getModifyName() {
		return modifyName;
	}
	public void setModifyName(String modifyName) {
		this.modifyName = modifyName;
	}
	
	
	
	
}	
	
