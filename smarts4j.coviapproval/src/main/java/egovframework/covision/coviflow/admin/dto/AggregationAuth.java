package egovframework.covision.coviflow.admin.dto;

public class AggregationAuth {
	private int aggAuthId;
	private char authType;
	private String authTarget;
	private int aggFormId;
	private String entCode;

	public int getAggAuthId() {
		return aggAuthId;
	}

	public void setAggAuthId(int aggAuthId) {
		this.aggAuthId = aggAuthId;
	}
	public char getAuthType() {
		return authType;
	}

	public void setAuthType(char authType) {
		this.authType = authType;
	}
	public String getAuthTarget() {
		return authTarget;
	}

	public void setAuthTarget(String authTarget) {
		this.authTarget = authTarget;
	}
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

}
