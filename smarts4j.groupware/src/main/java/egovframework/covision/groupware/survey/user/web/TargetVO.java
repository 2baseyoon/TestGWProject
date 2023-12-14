package egovframework.covision.groupware.survey.user.web;

public class TargetVO {
	private String targetType;
	private String targetCode;
	//private String targetDeptCode;
	
	public String getTargetType() {
		return targetType;
	}
	public void setTargetType(String targetType) {
		this.targetType = targetType;
	}
	public String getTargetCode() {
		return targetCode;
	}
	public void setTargetCode(String targetCode) {
		this.targetCode = targetCode;
	}
	
	@Override
	public String toString() {
		return "TargetVO [targetType=" + targetType + ", targetCode="
				+ targetCode + "]";
	}
}
