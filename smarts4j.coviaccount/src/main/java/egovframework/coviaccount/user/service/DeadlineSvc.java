package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface DeadlineSvc {
	public CoviMap getDeadlineInfo(CoviMap params) throws Exception;
	public CoviMap saveDeadlineInfo(CoviMap params) throws Exception;
}