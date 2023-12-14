package egovframework.covision.groupware.vacation.user.web;

import java.util.List;

public class VacationListVO {
	private List<VacationVO> vacations;

	public List<VacationVO> getVacations() {
		return vacations;
	}
	public void setVacations(List<VacationVO> vacations) {
		this.vacations = vacations;
	}

	@Override
	public String toString() {
		return "VacationListVO [vacations=" + vacations + "]";
	}
}
