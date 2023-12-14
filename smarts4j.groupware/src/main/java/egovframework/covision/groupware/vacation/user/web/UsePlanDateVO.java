package egovframework.covision.groupware.vacation.user.web;

public class UsePlanDateVO {
	private String startDate;
	private String endDate;
	
	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	
	@Override
	public String toString() {
		return "{\"startDate\":\"" + startDate + "\",\"endDate\":\"" + endDate
				+ "\"}";
	}
}
