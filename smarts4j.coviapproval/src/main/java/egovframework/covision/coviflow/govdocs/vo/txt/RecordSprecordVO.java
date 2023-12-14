package egovframework.covision.coviflow.govdocs.vo.txt;

/*
	특수목록위치*		철/건구분									C	1		1 : 철, 2 : 건
	기록물철분류번호	기록물철분류번호-생산년도포함						C	28		처리과기관코드(7)+단위업무코드(8)+생산년도(4)+기록물철등록일련번호(6)+권호수(3)
	기록물건등록번호	"생산(접수)등록번호 -생산(접수)년도 및 분리등록번호 포함"		C	19		생산(접수)년도(4)+처리과기관코드(7)+등록일련번호(6)+분리등록번호(2)
	일련번호*		일련번호									C	3		005
	특수목록		특수목록#1									C	100		
				특수목록#2									C	100		
				특수목록#3									C	100
*/

public class RecordSprecordVO {

	private String docClass;
	private String recordClassNum;
	private String recordRegisteredNum;
	private String sprecordSeq;
	private String specialList1;
	private String specialList2;
	private String specialList3;
	
	
	public String getDocClass() {
		return docClass;
	}
	public void setDocClass(String docClass) {
		this.docClass = docClass;
	}
	public String getRecordClassNum() {
		return recordClassNum;
	}
	public void setRecordClassNum(String recordClassNum) {
		this.recordClassNum = recordClassNum;
	}
	public String getRecordRegisteredNum() {
		return recordRegisteredNum;
	}
	public void setRecordRegisteredNum(String recordRegisteredNum) {
		this.recordRegisteredNum = recordRegisteredNum;
	}
	public String getSprecordSeq() {
		return sprecordSeq;
	}
	public void setSprecordSeq(String sprecordSeq) {
		this.sprecordSeq = sprecordSeq;
	}
	public String getSpecialList1() {
		return specialList1;
	}
	public void setSpecialList1(String specialList1) {
		this.specialList1 = specialList1;
	}
	public String getSpecialList2() {
		return specialList2;
	}
	public void setSpecialList2(String specialList2) {
		this.specialList2 = specialList2;
	}
	public String getSpecialList3() {
		return specialList3;
	}
	public void setSpecialList3(String specialList3) {
		this.specialList3 = specialList3;
	}
	
	
	
}	
	
