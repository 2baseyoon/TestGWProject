package egovframework.covision.coviflow.govdocs.vo.txt;

/*
 * 	첨부파일정보
		처리과기관코드		처리과기관코드			C	7		1234567
		생산년도		생산년도			C	4		2002
		생산(접수)등록번호	생산(접수)등록번호		C	13		6050709000023(처리과기관코드+등록일련번호)
		첨부파일일련번호	첨부파일일련번호		C	2		5
		첨부파일쪽수		첨부파일쪽수			C	3		123
*/

public class RecordPageVO {

	private String recordDeptCode;
	private String productYear;
	private String productNum;
	private String fileSeq;
	private String filePageCount;
	
	
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
	public String getFileSeq() {
		return fileSeq;
	}
	public void setFileSeq(String fileSeq) {
		this.fileSeq = fileSeq;
	}
	public String getFilePageCount() {
		return filePageCount;
	}
	public void setFilePageCount(String filePageCount) {
		this.filePageCount = filePageCount;
	}
	
	
	
}	
	
