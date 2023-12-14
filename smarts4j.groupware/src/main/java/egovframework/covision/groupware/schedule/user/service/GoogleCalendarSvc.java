package egovframework.covision.groupware.schedule.user.service;

import com.google.api.client.http.HttpTransport;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface GoogleCalendarSvc {
	
	public void googleOauth() throws Exception;
	
	public String refreshAccessToken(String refreshToken, HttpTransport transport) throws Exception;
	
	public CoviList googleListAll() throws Exception;
	
	public void googleListSingle();
	 
	public void googleAdd(CoviMap eventObj) throws Exception;
	 
	public void googleDelete(CoviMap eventObj) throws Exception;
	 
	public void googleUpdate(CoviMap eventObj) throws Exception;
}
