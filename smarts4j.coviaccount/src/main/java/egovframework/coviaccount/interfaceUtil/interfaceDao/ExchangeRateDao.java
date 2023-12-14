package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.ExchangeRateVO;

public class ExchangeRateDao{

	private ArrayList<ExchangeRateVO> exchangeRateList = new ArrayList<ExchangeRateVO>();

	public ArrayList<ExchangeRateVO> getExchangeRateList() {
		return exchangeRateList;
	}

	public void setExchangeRateList(ArrayList<ExchangeRateVO> exchangeRateList) {
		this.exchangeRateList = exchangeRateList;
	}
}
