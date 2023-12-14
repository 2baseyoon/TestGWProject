package egovframework.covision.groupware.privacy.user.web;

import java.util.List;

import egovframework.baseframework.util.SessionHelper;

public class SettingVO {
	private String reqTr;
	private String userCode = SessionHelper.getSession("USERID");
	private String serviceType;
	private List<ServiceTypeVO> serviceTypes;
	
	public String getReqTr() {
		return reqTr;
	}
	public void setReqTr(String reqTr) {
		this.reqTr = reqTr;
	}
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
	public List<ServiceTypeVO> getServiceTypes() {
		return serviceTypes;
	}
	public void setServiceTypes(List<ServiceTypeVO> serviceTypes) {
		this.serviceTypes = serviceTypes;
	}
	
	@Override
	public String toString() {
		return "SettingVO [reqTr=" + reqTr + ", userCode=" + userCode
				+ ", serviceType=" + serviceType + ", serviceTypes="
				+ serviceTypes + "]";
	}
}
