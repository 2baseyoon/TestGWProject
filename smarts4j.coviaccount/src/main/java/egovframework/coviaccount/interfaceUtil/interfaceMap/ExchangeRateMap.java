package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class ExchangeRateMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		map = new CoviMap();
		map.put("date",	"exchangeRateDate");	//환율정보날짜
		map.put("usd",	"usd");
		map.put("eur",	"eur");
		//map.put("",	"aed");
		map.put("aud",	"aud");
		//map.put("",	"brl");
		map.put("cad",	"cad");
		map.put("chf",	"chf");
		map.put("cny",	"cny");
		map.put("jpy",	"jpy");
		map.put("sgd",	"sgd");
		
		return map;
	}
}
