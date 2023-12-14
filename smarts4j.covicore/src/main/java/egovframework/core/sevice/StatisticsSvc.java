package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface StatisticsSvc {

	//과금 예외자
	public CoviMap selectChargingException(CoviMap params) throws Exception;
	public Object insertChargingException(CoviMap params) throws Exception;
	public int deleteChargingException(CoviMap params) throws Exception;
	//사용량
	public CoviMap selectUsage(CoviMap params) throws Exception;
	//페이지 사용량
	public CoviMap selectPage(CoviMap params) throws Exception;
	public CoviMap selectSystem(CoviMap params) throws Exception;
	public CoviMap selectService(CoviMap params) throws Exception;
	//사용자 Login
	public CoviMap selectPerHour(CoviMap params) throws Exception;
	public CoviMap selectPerDays(CoviMap params) throws Exception;
	public CoviMap selectPerDay(CoviMap params) throws Exception;
	public CoviMap selectPerMonth(CoviMap params) throws Exception;
	//사용자 환경
	public CoviMap selectBrowser(CoviMap params) throws Exception;
	public CoviMap selectOS(CoviMap params) throws Exception;
	public CoviMap selectResolution(CoviMap params) throws Exception;
	public CoviMap selectRegion(CoviMap params) throws Exception;
	
}
