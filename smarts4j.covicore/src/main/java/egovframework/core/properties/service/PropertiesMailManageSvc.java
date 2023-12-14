package egovframework.core.properties.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PropertiesMailManageSvc {
	
	public CoviList selectCodeList(CoviMap params) throws Exception;
	
	public CoviList selectServerList() throws Exception;

	CoviMap selectMailList(CoviMap params) throws Exception;
	
}