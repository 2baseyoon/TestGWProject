package egovframework.covision.legacy.base.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.covision.legacy.base.service.FormCommonSvc;
import egovframework.covision.legacy.data.CoviMapperLegacyOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("FormCommonSvc")
public class FormCommonSvcImpl extends EgovAbstractServiceImpl implements FormCommonSvc{

	@Resource(name="CoviMapperLegacyOne")
	private CoviMapperLegacyOne legacyDB;

	@Override
	public void execWF_FORM_LEGACY_SAMPLE(CoviMap spParams) throws Exception {
		CoviMap cmap = new CoviMap();
		
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
		if(spParams.getString("apvMode").equals("COMPLETE")){
			cmap.put("value", bodyContext.getString("samplevalue"));
			legacyDB.insert("user.sample.insertSampleItem", cmap);
		}
	}
}
