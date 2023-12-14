package egovframework.core.properties.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PropertiesContextManageSvc {
	
	public CoviList selectCodeList(CoviMap params) throws Exception;
	
	public CoviList selectServerList() throws Exception;
	
	public CoviMap selectContextList(CoviMap params) throws Exception;
}