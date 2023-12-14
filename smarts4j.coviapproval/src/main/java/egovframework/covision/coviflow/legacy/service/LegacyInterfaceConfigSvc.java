package egovframework.covision.coviflow.legacy.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface LegacyInterfaceConfigSvc {
	public CoviList getLegacyIfConfig(CoviMap params) throws Exception;
	public void saveLegacyIfConfig(CoviMap parameters) throws Exception;
	public CoviMap extractRequestSoapTemplates(CoviMap parameters) throws Exception;
	public CoviList parseRequestInfoByCxf(CoviMap parameters) throws Exception;
	public int deleteConfig(CoviMap parameters) throws Exception;
	public int updateLegacyIfConfigUse(CoviMap parameters) throws Exception;
}
