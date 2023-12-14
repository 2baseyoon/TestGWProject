package egovframework.covision.groupware.vacation.user.web;

import java.util.List;

public class UsePlanVO {
	private String urCode;
	private String year;
	private List<UsePlanMonthVO> months;
	private List<UsePlanMonthVO> months2;
	private List<UsePlanMonthVO> months3;

	public String getUrCode() {
		return urCode;
	}

	public void setUrCode(String urCode) {
		this.urCode = urCode;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public List<UsePlanMonthVO> getMonths() {
		return months;
	}

	public void setMonths(List<UsePlanMonthVO> months) {
		this.months = months;
	}

	public List<UsePlanMonthVO> getMonths2() {
		return months2;
	}
	
	public void setMonths2(List<UsePlanMonthVO> months2) {
		this.months2 = months2;
	}

	public List<UsePlanMonthVO> getMonths3() {
		return months3;
	}
	
	public void setMonths3(List<UsePlanMonthVO> months3) {
		this.months3 = months3;
	}

	@Override
	public String toString() {
		return "{\"urCode\":\"" + urCode + "\",\"year\":\"" + year + "\",\"months\":"
				+ months + ",\"months2\": "+ months2 + ",\"months3\": "+ months3 +"}";
	}
}
