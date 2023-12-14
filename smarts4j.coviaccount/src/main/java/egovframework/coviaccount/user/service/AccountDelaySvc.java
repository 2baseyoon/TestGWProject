package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface AccountDelaySvc {
	public CoviMap getSendFlag(CoviMap params)  throws Exception;
	public CoviMap doDelayAlam(CoviMap params) throws Exception;
	public CoviMap doManualDelayAlamCorpCard(CoviMap dataList, String sendMailType) throws Exception;
	public CoviMap doManualDelayAlam(CoviMap dataList, String sendMailType) throws Exception;
}