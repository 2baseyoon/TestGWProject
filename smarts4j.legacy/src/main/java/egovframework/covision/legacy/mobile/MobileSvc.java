package egovframework.covision.legacy.mobile;

import egovframework.baseframework.data.CoviMap;

public interface MobileSvc {
	
	public CoviMap getPhoneNumberList() throws Exception;
	public CoviMap getPhoneNumberSearch(String phoneNumber) throws Exception;
	
}
