package egovframework.covision.coviflow.legacy.service.impl;

import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceConfigSvc;
import egovframework.covision.coviflow.legacy.util.WSDLUtil;

@Service
public class LegacyInterfaceConfigSvcImpl extends EgovAbstractServiceImpl implements LegacyInterfaceConfigSvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * SchemaID
	 */
	@Override
	public CoviList getLegacyIfConfig(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("legacy.interface.config.selectConfig", params));
	}

	@Override
	public void saveLegacyIfConfig(CoviMap parameters) throws Exception {
		for(Object entrySet : parameters.entrySet()) {
			Map.Entry<String, Object> entry = (Map.Entry<String, Object>)entrySet;
			entry.setValue(entry.getValue().toString());
		}
		if(!StringUtil.isEmpty(parameters.getString("LegacyConfigID"))) {
			coviMapperOne.update("legacy.interface.config.updateConfig", parameters);			
		}else {
			coviMapperOne.insert("legacy.interface.config.insertConfig", parameters);
		}
	}

	@Override
	public CoviMap extractRequestSoapTemplates(CoviMap parameters) throws Exception {
		
		String xml = WSDLUtil.extractRequestSoapTemplates(parameters.optString("WSDLUrl"), null, parameters.optString("OperationName"), null, null);
		CoviMap returnData = new CoviMap();
		returnData.put("TemplateXML", xml);
		return returnData;
	}
	
	@Override
	public CoviList parseRequestInfoByCxf(CoviMap parameters) throws Exception {
		return WSDLUtil.parseRequestInfoByCxf(parameters.optString("WSDLUrl"), parameters.optString("OperationName"));
	}
	
	@Override
	public int deleteConfig(CoviMap parameters) throws Exception {
		return coviMapperOne.update("legacy.interface.config.deleteConfig", parameters);
	}
	
	@Override
	public int updateLegacyIfConfigUse(CoviMap parameters) throws Exception {
		return coviMapperOne.update("legacy.interface.config.updateConfigUse", parameters);
	}
}
