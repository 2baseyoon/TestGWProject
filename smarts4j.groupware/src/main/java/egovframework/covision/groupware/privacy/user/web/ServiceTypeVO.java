package egovframework.covision.groupware.privacy.user.web;

import egovframework.baseframework.util.SessionHelper;

public class ServiceTypeVO {
	private String userCode = SessionHelper.getSession("USERID");
	private String serviceType;
	private String mediaType;
	
	public String getUserCode() {
		return userCode;
	}
	public void setUserCode(String userCode) {
		this.userCode = userCode;
	}
	public String getServiceType() {
		return serviceType;
	}
	public void setServiceType(String serviceType) {
		this.serviceType = serviceType;
	}
	public String getMediaType() {
		return mediaType;
	}
	public void setMediaType(String mediaType) {
		this.mediaType = mediaType;
	}
	
	@Override
	public String toString() {
		return "ServiceTypeVO [userCode=" + userCode + ", serviceType="
				+ serviceType + ", mediaType=" + mediaType + "]";
	}
}
