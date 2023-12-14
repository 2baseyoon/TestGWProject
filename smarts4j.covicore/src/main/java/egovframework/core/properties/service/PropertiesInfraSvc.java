package egovframework.core.properties.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PropertiesInfraSvc {

	public void init() throws Exception;
	
	public CoviList selectPropertiesList(CoviMap params) throws Exception;

	public CoviList selectCodeList(CoviMap params);

	public CoviMap selectInfraList(CoviMap coviMap) throws Exception;

}