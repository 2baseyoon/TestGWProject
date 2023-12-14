package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

public interface CollabAdminSvc {
	
	public void setSyncSetting(CoviMap jo) throws Exception; 
	public CoviMap  getCollabUserConf(CoviMap params)	throws Exception;
	public int saveCollabUserConf(CoviMap params) throws Exception;
	
}
