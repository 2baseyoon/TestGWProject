package egovframework.core.properties.service.impl;

import javax.annotation.Resource;

import javax.annotation.PostConstruct;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesInfraSvc;

@Service("PropertiesInfraSvcImpl")
public class PropertiesInfraSvcImpl extends EgovAbstractServiceImpl implements PropertiesInfraSvc {

	private Logger LOGGER = LogManager.getLogger(PropertiesInfraSvcImpl.class);
	
	
	private static final String DEPLOY_PATH = System.getProperty("DEPLOY_PATH");
	
	private static final String PROPERTIES_MANAGE_YN = PropertiesUtil.getGlobalProperties().getProperty("properties.manage.yn");
	
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; // properties.infra
	
	@PostConstruct
	@Override
	/**
	 * Properties DB 화 
	 */
	public void init() throws Exception {		
	}
	
	@Override
	public CoviList selectCodeList(CoviMap params) {
		return coviMapperOne.list("properties.infra.selectInfraCodeList", params);
	}
	
	@Override
	public CoviList selectPropertiesList(CoviMap params) throws Exception {
		CoviList resultList = new CoviList();		
		
		CoviList list = coviMapperOne.list("properties.infra.selectInfraPropertiesList", params);
		resultList = CoviSelectSet.coviSelectJSON(list);
		
		return resultList;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public CoviMap selectInfraList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("properties.infra.selectInfraList", new CoviMap() {{
			this.put("dbType", params.getString("dbType"));
			this.put("wasType", params.getString("wasType"));
			this.put("fileType",params.getString("fileType"));
		}});
		
		try {
			CoviList list1 = new CoviList();
			
        	for (Object object : list) {
        		CoviMap map = (CoviMap) object;        		
        		CoviMap resultObj = new CoviMap();
        		String input1;
        		String input;
        		
        		String inputContext = params.getString("context");
        		
        		if(inputContext.equals("") || !inputContext.contains((String) map.get("setkey"))){
        			input1 = "";
        			input = "";
        		}else{
        			int idx = 0;
        			input1 = inputContext.split((String) map.get("setkey"))[1];
        			
        			if(input1.contains("\n")) {
        				idx = input1.indexOf("\n");
        			}else if(input1.contains("\t")) {
        				idx = input1.indexOf("\t");
        			} 
        			
        			input  = input1.substring(0, idx).replaceAll("=", "").replaceAll("\"", "").trim();
        			
        			
        		}
				
				list1.add(new CoviMap() {{
					this.put("standardtype", params.getString("fileName"));
					this.put("setkey", map.get("setkey"));
					this.put("referenceValueType", map.get("referenceValueType"));
					this.put("referencevalue", map.get("referencevalue"));
					this.put("inputvalue", input);
					this.put("description", map.get("description"));
            	}});
				
				
        	}
			return generateList(list1);
		} catch (NullPointerException e) {
			LOGGER.warn(e.getLocalizedMessage(), e);
			return generateList(list);
		} catch (Exception e) {
			LOGGER.warn(e.getLocalizedMessage(), e);
			return generateList(list);
		}
	}
	
	private CoviMap generateList(CoviList coviList) {
		return new CoviMap() {{
			this.put("list", coviList);
			this.put("page", new CoviMap() {{
				this.put("listCount", coviList.size());
			}});
		}};
	}
	
}