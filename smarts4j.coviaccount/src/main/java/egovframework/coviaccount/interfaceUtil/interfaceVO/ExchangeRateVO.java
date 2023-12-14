package egovframework.coviaccount.interfaceUtil.interfaceVO;

import egovframework.baseframework.data.CoviMap;

public class ExchangeRateVO  {
	
	private String exchangeRateDate;
	private String usd;
	private String eur;
	private String aed;
	private String aud;
	private String brl;
	private String cad;
	private String chf;
	private String cny;
	private String jpy;
	private String sgd;
	
	public void setAll(CoviMap info) {
		this.exchangeRateDate = rtString(info.get("exchangeRateDate"));
		this.usd = rtString(info.get("usd"));
		this.eur = rtString(info.get("eur"));
		this.aed = rtString(info.get("aed"));
		this.aud = rtString(info.get("aud"));
		this.brl = rtString(info.get("brl"));
		this.cad = rtString(info.get("cad"));
		this.chf = rtString(info.get("chf"));
		this.cny = rtString(info.get("cny"));
		this.jpy = rtString(info.get("jpy"));
		this.sgd = rtString(info.get("sgd"));
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

	public String getExchangeRateDate() {
		return exchangeRateDate;
	}

	public void setExchangeRateDate(String exchangeRateDate) {
		this.exchangeRateDate = exchangeRateDate;
	}

	public String getUsd() {
		return usd;
	}

	public void setUsd(String usd) {
		this.usd = usd;
	}

	public String getEur() {
		return eur;
	}

	public void setEur(String eur) {
		this.eur = eur;
	}

	public String getAed() {
		return aed;
	}

	public void setAed(String aed) {
		this.aed = aed;
	}

	public String getAud() {
		return aud;
	}

	public void setAud(String aud) {
		this.aud = aud;
	}

	public String getBrl() {
		return brl;
	}

	public void setBrl(String brl) {
		this.brl = brl;
	}

	public String getCad() {
		return cad;
	}

	public void setCad(String cad) {
		this.cad = cad;
	}

	public String getChf() {
		return chf;
	}

	public void setChf(String chf) {
		this.chf = chf;
	}

	public String getCny() {
		return cny;
	}

	public void setCny(String cny) {
		this.cny = cny;
	}

	public String getJpy() {
		return jpy;
	}

	public void setJpy(String jpy) {
		this.jpy = jpy;
	}

	public String getSgd() {
		return sgd;
	}

	public void setSgd(String sgd) {
		this.sgd = sgd;
	}
}
