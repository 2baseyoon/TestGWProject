package egovframework.covision.groupware.mobile;

import egovframework.baseframework.data.CoviMap;


public interface MobileSvc {
	
	public CoviMap getPhoneNumberList() throws Exception;
	public CoviMap getPhoneNumberSearch(String phoneNumber) throws Exception;
	public CoviMap getQuickMenuCount(CoviMap params, CoviMap userDataObj) throws Exception;
}
