package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

public interface CollabAlarmSvc {
	
	public CoviMap doAutoSummDayAlam(CoviMap reqParams) throws Exception; 
	public CoviMap doAutoTaskCloseAlam(CoviMap reqParams) throws Exception; 
	
}
