package egovframework.covision.coviflow.admin.dto;

import java.util.List;

import egovframework.baseframework.data.CoviList;

public class AddAggregationFieldsRequestDTO {
	String aggFormId;
	List<AggregationCommonField> commonFields;
	CoviList formFields;

	public String getAggFormId() {
		return aggFormId;
	}

	public void setAggFormId(String aggFormId) {
		this.aggFormId = aggFormId;
	}

	public List<AggregationCommonField> getCommonFields() {
		return commonFields;
	}

	public void setCommonFields(List<AggregationCommonField> commonFields) {
		this.commonFields = commonFields;
	}

	public CoviList getFormFields() {
		return formFields;
	}

	public void setFormFields(CoviList formFields) {
		this.formFields = formFields;
	}
}
