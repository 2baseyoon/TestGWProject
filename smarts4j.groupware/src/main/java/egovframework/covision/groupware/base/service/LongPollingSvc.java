package egovframework.covision.groupware.base.service;

import egovframework.baseframework.data.CoviMap;


public interface LongPollingSvc {

	public CoviMap getQuickMenuCount(CoviMap params, CoviMap userDataObj) throws Exception;
	
}
