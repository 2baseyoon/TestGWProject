package egovframework.covision.coviflow.admin.dto;

import java.time.LocalDateTime;

public class AggregationCommonField {
	private int aggFieldId;
	private String fieldName;
	private String fieldId;
	private int sortKey;
	private String dataFormat;
	private String entCode;
	private String createdDate;
	private String deletedDate;

	public AggregationCommonField() {

	}

	public AggregationCommonField(int aggFieldId, String fieldName, String fieldId, int sortKey, String dataFormat,
			String entCode, String createDate) {
		this.aggFieldId = aggFieldId;
		this.fieldName = fieldName;
		this.fieldId = fieldId;
		this.sortKey = sortKey;
		this.dataFormat = dataFormat;
		this.entCode = entCode;
		this.createdDate = createDate;
	}

	public int getAggFieldId() {
		return aggFieldId;
	}

	public String getFieldName() {
		return fieldName;
	}

	public String getFieldId() {
		return fieldId;
	}

	public int getSortKey() {
		return sortKey;
	}

	public String getDataFormat() {
		return dataFormat;
	}

	public String getEntCode() {
		return entCode;
	}

	public String getCreatedDate() {
		return createdDate;
	}

	public String getDeletedDate() {
		return deletedDate;
	}

	public void setAggFieldId(int aggFieldId) {
		this.aggFieldId = aggFieldId;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	public void setFieldId(String fieldId) {
		this.fieldId = fieldId;
	}

	public void setSortKey(int sortKey) {
		this.sortKey = sortKey;
	}

	public void setDataFormat(String dataFormat) {
		this.dataFormat = dataFormat;
	}

	public void setEntCode(String entCode) {
		this.entCode = entCode;
	}

	public void setCreatedDate(String createdDate) {
		this.createdDate = createdDate;
	}

	public void setDeletedDate(String deletedDate) {
		this.deletedDate = deletedDate;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("{\"aggFieldId\":\"").append(aggFieldId).append("\"");
		if (fieldName != null)
			builder.append(", \"fieldName\":\"").append(fieldName).append("\"");
		if (fieldId != null)
			builder.append(", \"fieldId\":\"").append(fieldId).append("\"");
		builder.append(", \"sortKey\":\"").append(sortKey).append("\"");
		if (dataFormat != null)
			builder.append(", \"dataFormat\":\"").append(dataFormat).append("\"");
		if (entCode != null)
			builder.append(", \"entCode\":\"").append(entCode).append("\"");
		if (createdDate != null)
			builder.append(", \"createdDate\":\"").append(createdDate).append("\"");
		if (deletedDate != null)
			builder.append(", \"deletedDate\":\"").append(deletedDate).append("\"");
		builder.append("}");
		return builder.toString();
	}
}
