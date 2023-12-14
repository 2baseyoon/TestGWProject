package egovframework.covision.coviflow.govdocs.vo.txt;

/*	배부대장정보
	1	접수사항	단위기관코드*			C	7		1234567
	2			접수년도			C	4		2002
	3			배부일련번호			C	6		1
	4			접수일자			C	8		09011530(월+일+시분)
	5			생산기관 등록번호		C	56		1234567000003(생산기관 처리과기관코드+기록물등록일련번호)
	6			제목				C	100		전자문서시스템 구축 설문공문
	7	배부사항	받은 처리과기관코드		C	7		1234567
	8			받은 처리과명			C	60		행정과
	9			배부일자			C	8		09011530(월+일+시분)
	10			인수자				C	40		홍길동

*/

public class RecordDistVO {

	private String recordDeptCode;
	private String productYear;
	private String distNum;
	private String productDate;
	private String recordSeq;
	private String recordSubject;
	
	private String recordDeptCode1;
	private String recordDeptName1;
	private String distDate;
	private String receiptName;
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
	public String getDistNum() {
		return distNum;
	}
	public void setDistNum(String distNum) {
		this.distNum = distNum;
	}
	public String getProductDate() {
		return productDate;
	}
	public void setProductDate(String productDate) {
		this.productDate = productDate;
	}
	public String getRecordSeq() {
		return recordSeq;
	}
	public void setRecordSeq(String recordSeq) {
		this.recordSeq = recordSeq;
	}
	public String getRecordSubject() {
		return recordSubject;
	}
	public void setRecordSubject(String recordSubject) {
		this.recordSubject = recordSubject;
	}
	public String getRecordDeptCode1() {
		return recordDeptCode1;
	}
	public void setRecordDeptCode1(String recordDeptCode1) {
		this.recordDeptCode1 = recordDeptCode1;
	}
	public String getRecordDeptName1() {
		return recordDeptName1;
	}
	public void setRecordDeptName1(String recordDeptName1) {
		this.recordDeptName1 = recordDeptName1;
	}
	public String getDistDate() {
		return distDate;
	}
	public void setDistDate(String distDate) {
		this.distDate = distDate;
	}
	public String getReceiptName() {
		return receiptName;
	}
	public void setReceiptName(String receiptName) {
		this.receiptName = receiptName;
	}
	
}	
	
