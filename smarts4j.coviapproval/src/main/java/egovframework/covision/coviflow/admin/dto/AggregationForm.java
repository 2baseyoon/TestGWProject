package egovframework.covision.coviflow.admin.dto;

import java.util.List;

public class AggregationForm {
	private int aggFormId;
	private String entCode;
	private String formName;
	private String formPrefix;
	private char displayYN;
	private String userCode;
	private List<AggregationField> aggregationFields;
	private List<AggregationAuth> aggregationAuths;
	public int getAggFormId() {
		return aggFormId;
	}

	public void setAggFormId(int aggFormId) {
		this.aggFormId = aggFormId;
	}
	public String getEntCode() {
		return entCode;
	}

	public void setEntCode(String entCode) {
		this.entCode = entCode;
	}
	public String getFormName() {
		return formName;
	}
	public void setFormName(String formName) {
		this.formName = formName;
	}
	public String getFormPrefix() {
		return formPrefix;
	}

	public void setFormPrefix(String formPrefix) {
		this.formPrefix = formPrefix;
	}
	public char getDisplayYN() {
		return displayYN;
	}
	public String getUserCode() {
		return userCode;
	}
	public void setUserCode(String userCode) {
		this.userCode = userCode;
	}

	public void setDisplayYN(char displayYN) {
		this.displayYN = displayYN;
	}
	public List<AggregationField> getAggregationFields() {
		return aggregationFields;
	}
	public void setAggregationFields(List<AggregationField> aggregationFields) {
		this.aggregationFields = aggregationFields;
	}
	public List<AggregationAuth> getAggregationAuths() {
		return aggregationAuths;
	}
	public void setAggregationAuths(List<AggregationAuth> aggregationAuths) {
		this.aggregationAuths = aggregationAuths;
	}

}
