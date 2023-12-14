package egovframework.covision.groupware.vacation.user.web;

import java.util.List;

public class UsePlanMonthVO {
	private String month;
	private List<UsePlanDateVO> vacPlan;
	
	public String getMonth() {
		return month;
	}
	public void setMonth(String month) {
		this.month = month;
	}
	public List<UsePlanDateVO> getVacPlan() {
		return vacPlan;
	}
	public void setVacPlan(List<UsePlanDateVO> vacPlan) {
		this.vacPlan = vacPlan;
	}
	@Override
	public String toString() {
		return "{\"month\":\"" + month + "\",\"vacPlan\":" + vacPlan + "}";
	}
}
