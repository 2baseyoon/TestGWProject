package egovframework.core.properties.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PropertiesEumtalkSvc {
	
	public void init() throws Exception;
	
	public CoviList selectPropertiesList(CoviMap params) throws Exception;

	public CoviList selectCodeList(CoviMap params);

	public CoviMap selectEumtalkList(CoviMap coviMap) throws Exception;
}