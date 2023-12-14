package egovframework.covision.coviflow.govdocs.vo.txt;

/*
 * 기록물철등록부변경이력정보
		1	처리과기관코드			처리과기관코드			C	7		1234567
		2	단위업무코드			단위업무코드			C	8		00890120
		3	생산년도			생산년도			C	4		2002
		4	기록물철등록 일련번호		기록물철등록 일련번호		C	6		"000001"
		5	권호수				권호수				C	3		001
		6	기록물철제목			변경 전				C	100		전자문서 표준규격 수립
		7					변경 후				C	100		전자문서시스템 규격수립
		8	기록물형태			변경 전				C	1		"1: 일반문서, 2: 도면류, 3: 사진·필름류 시청각기록물, 4: 녹음·동영상류 시청각기록물, 5: 카드류. (기록물관리법시행규칙 별지5호서식)"
		9					변경 후				C	1		"1: 일반문서, 2: 도면류, 3: 사진·필름류 시청각기록물, 4: 녹음·동영상류 시청각기록물, 5: 카드류. (기록물관리법시행규칙 별지5호서식)"
		10	변경일자			변경일자			C	8		20020901(년+월+일)
		11	변경사유			변경사유			C	100		단위업무 소관부서 변경에 따른 철 수정
		12	변경자				변경자				C	40		홍길동
 */
public class RecordGfileHistVO {

	private String recordDeptCode;
	private String seriesCode;
	private String productYear;
	private String recordSeq;
	private String recordCount;
	private String recordSubjectBefore;
	private String recordSubjectAfter;
	private String recordTypeBefore;
	private String recordTypeAfter;
	private String modifyDate;
	private String modifyReason;
	private String modifyName;
	
	
	
	public String getRecordDeptCode() {
		return recordDeptCode;
	}
	public void setRecordDeptCode(String recordDeptCode) {
		this.recordDeptCode = recordDeptCode;
	}
	public String getSeriesCode() {
		return seriesCode;
	}
	public void setSeriesCode(String seriesCode) {
		this.seriesCode = seriesCode;
	}
	public String getProductYear() {
		return productYear;
	}
	public void setProductYear(String productYear) {
		this.productYear = productYear;
	}
	public String getRecordSeq() {
		return recordSeq;
	}
	public void setRecordSeq(String recordSeq) {
		this.recordSeq = recordSeq;
	}
	public String getRecordCount() {
		return recordCount;
	}
	public void setRecordCount(String recordCount) {
		this.recordCount = recordCount;
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
	public String getRecordTypeBefore() {
		return recordTypeBefore;
	}
	public void setRecordTypeBefore(String recordTypeBefore) {
		this.recordTypeBefore = recordTypeBefore;
	}
	public String getRecordTypeAfter() {
		return recordTypeAfter;
	}
	public void setRecordTypeAfter(String recordTypeAfter) {
		this.recordTypeAfter = recordTypeAfter;
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
	
