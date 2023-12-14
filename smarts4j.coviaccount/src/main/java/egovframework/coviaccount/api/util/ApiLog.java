package egovframework.coviaccount.api.util;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;

public class ApiLog {
	private String apiType;		//Api대상종류(전표동기화..)
	private String apiRecvType; //Api 전송방향(S:전송, R:수신)
	private String callUrl;		//호출url
	private String reqParam;	//Api 호출param
	private Return apiStatus;	//Api 상태(SUCCESS:성공, FAIL:실패)
	private String errorLog;	//에러로그
	
	public ApiLog() {
		super();
	}

	public ApiLog(String apiType, String apiRecvType, String callUrl, String reqParam) {
		this.apiType = apiType;
		this.apiRecvType = apiRecvType;
		this.callUrl = callUrl;
		this.reqParam = reqParam;
		this.apiStatus = null;
		this.errorLog = "";
	}
	
	public ApiLog(String apiType, String apiRecvType, String callUrl, CoviMap reqParam) {
		this.apiType = apiType;
		this.apiRecvType = apiRecvType;
		this.callUrl = callUrl;
		this.reqParam = reqParam.toString();
		this.apiStatus = null;
		this.errorLog = "";
	}
	
	public String getApiType() {
		return apiType;
	}
	public void setApiType(String apiType) {
		this.apiType = apiType;
	}
	public String getApiRecvType() {
		return apiRecvType;
	}
	public void setApiRecvType(String apiRecvType) {
		this.apiRecvType = apiRecvType;
	}
	public String getCallUrl() {
		return callUrl;
	}
	public void setCallUrl(String callUrl) {
		this.callUrl = callUrl;
	}
	public String getReqParam() {
		return reqParam;
	}
	public void setReqParam(String reqParam) {
		this.reqParam = reqParam;
	}
	public Return getApiStatus() {
		return apiStatus;
	}
	public void setApiStatus(Return apiStatus) {
		this.apiStatus = apiStatus;
	}
	public String getErrorLog() {
		return errorLog;
	}
	public void setErrorLog(String errorLog) {
		this.errorLog = errorLog;
	}

	public void setApiFail(Return apiStatus, String errorLog) {
		this.apiStatus = apiStatus;
		this.errorLog = errorLog;
	}
}
