package egovframework.covision.groupware.vacation.user.web;

public class VacationVO {
	private String urCode;
	private Float vacDay;
	private String year;
	private String comment;
	private String sdate;
	private String edate;
	private String vackind;
	
	public String getUrCode() {
		return urCode;
	}
	public void setUrCode(String urCode) {
		this.urCode = urCode;
	}
	public Float getVacDay() {
		return vacDay;
	}
	public void setVacDay(Float vacDay) {
		this.vacDay = vacDay;
	}
	public String getYear() {
		return year;
	}
	public void setYear(String year) {
		this.year = year;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public String getSdate() {
		return sdate;
	}
	public void setSdate(String sdate) {
		this.sdate = sdate;
	}
	public String getEdate() {
		return edate;
	}
	public void setEdate(String edate) {
		this.edate = edate;
	}
	public void setVackind(String vacKind) {
		this.vackind = vacKind;
	}
	public String getExtraVacKind() {
		return vackind;
	}
	
	@Override
	public String toString() {
		return "VacationVO [urCode=" + urCode + ", vacDay=" + vacDay + ", year=" + year + ", comment=" + comment + ", sdate=" + sdate + ", edate=" + edate + "]";
	}
}

