package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface CorpCardSvc {
	public CoviMap getCorpCardList(CoviMap params) throws Exception;
	public CoviMap getCardNoChk(CoviMap params) throws Exception;
	public CoviMap saveCorpCardInfo(CoviMap params) throws Exception;
	public CoviMap updateCorpCardNo(CoviMap params) throws Exception;
	public CoviMap getCorpCardDetail(CoviMap params) throws Exception;
	public CoviMap deleteCorpCard(CoviMap params) throws Exception;
	CoviMap corpCardExcelDownload(CoviMap params) throws Exception;
	public CoviMap corpCardExcelUpload(CoviMap params) throws Exception;
	public CoviMap corpCardSync();
	public CoviMap getCorpCardHistoryList(CoviMap params) throws Exception;
	public CoviMap saveCorpCardReturnInfo(CoviMap params) throws Exception;
	public CoviMap updateCorpCardReturnInfo(CoviMap params) throws Exception;
	public CoviMap updateCorpCardReturnStatus(CoviMap params) throws Exception;
	public CoviMap getReleaseUserInfo(CoviMap params) throws Exception;
	public CoviMap deleteCorpCardReturnYN(CoviMap params) throws Exception;
}