package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface ExchangeRateSvc {
	public CoviMap saveExchangeRateInfo(CoviMap params) throws Exception;
	
	public CoviMap getExchangeRatelist(CoviMap params) throws Exception;
	
	public CoviMap deleteExchangeRateInfo(CoviMap params) throws Exception;
	
	public CoviMap getExchangeRateExcelList(CoviMap params) throws Exception;
	
	public CoviMap getExchangeRatePopupInfo(CoviMap params) throws Exception;
	
	public CoviMap exchangeRateSync();
	
	public CoviMap exchangesList(CoviMap params) throws Exception;
	
	public CoviMap exchangesRegister(CoviMap params, CoviMap exchanges) throws Exception;
	
	public CoviMap exchangesModify(CoviMap params, CoviMap exchanges) throws Exception;
	
	public CoviMap exchangesRead(CoviMap params) throws Exception;
	
	public CoviMap exchangesRemove(CoviList params) throws Exception;
}