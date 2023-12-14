package egovframework.covision.coviflow.admin.dto;

public class AggregationField {
	private int aggFieldId;
	private String fieldName;
	private String fieldId;
	private char isCommon;
	private char displayYN;
	private int sortKey;
	private int aggFormId;
	private int fieldWidth;
	private String fieldAlign;

	public int getAggFieldId() {
		return aggFieldId;
	}
	public void setAggFieldId(int aggFieldId) {
		this.aggFieldId = aggFieldId;
	}
	public String getFieldName() {
		return fieldName;
	}
	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	public String getFieldId() {
		return fieldId;
	}

	public void setFieldId(String fieldId) {
		this.fieldId = fieldId;
	}
	public char getIsCommon() {
		return isCommon;
	}
	public void setIsCommon(char isCommon) {
		this.isCommon = isCommon;
	}
	public char getDisplayYN() {
		return displayYN;
	}
	public void setDisplayYN(char displayYN) {
		this.displayYN = displayYN;
	}
	public int getSortKey() {
		return sortKey;
	}
	public void setSortKey(int sortKey) {
		this.sortKey = sortKey;
	}
	public int getAggFormId() {
		return aggFormId;
	}
	public void setAggFormId(int aggFormId) {
		this.aggFormId = aggFormId;
	}
	public int getFieldWidth() {
		return fieldWidth;
	}
	public void setFieldWidth(int fieldWidth) {
		this.fieldWidth = fieldWidth;
	}
	public String getFieldAlign() {
		return fieldAlign == null || fieldAlign.isEmpty() ? "center" : fieldAlign;
	}
	public void setFieldAlign(String fieldAlign) {
		this.fieldAlign = fieldAlign;
	}

}
