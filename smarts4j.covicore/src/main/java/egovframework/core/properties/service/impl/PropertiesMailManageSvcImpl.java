package egovframework.core.properties.service.impl;


import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.properties.service.PropertiesMailManageSvc;

@Service("PropertiesMailManageSvcImpl")
public class PropertiesMailManageSvcImpl extends EgovAbstractServiceImpl implements PropertiesMailManageSvc {

	private static final Logger LOGGER = LogManager.getLogger(PropertiesMailManageSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectCodeList(CoviMap params) {
		return coviMapperOne.list("properties.mail.selectCodeList", params);
	}
	
	@Override
	public CoviList selectServerList() throws Exception {
		return coviMapperOne.list("properties.mail.selectServerList", null);
	}
	
	@Override
	public CoviMap selectMailList(CoviMap params) throws Exception { // 비교!
		CoviList list = coviMapperOne.list("properties.mail.selectMailList", new CoviMap() {{
			this.put("dbType", params.getString("dbType"));
			this.put("wasType", params.getString("wasType"));
			this.put("type", params.getString("context"));
			this.put("location", params.getString("location"));
		}});
		
		CoviList list1 = new CoviList();
		try {
			String inputTotal = params.getString("input");
			
        	for (Object object : list) {
        		CoviMap map = (CoviMap) object;
        		
        		String input1 = inputTotal.split((String) map.get("setkey") + "=")[1];
        		String input = input1.substring(0, ((String) map.get("referencevalue")).length());
        		
				if (map.get("referenceValueType").equals(inputTotal)) {
					map.put("inputvalue", input);
				}
				
				list1.add(new CoviMap() {{
					this.put("setkey", map.get("setkey"));
					this.put("referenceValueType", map.get("referenceValueType"));
					this.put("referencevalue", map.get("referencevalue"));
					this.put("inputvalue", input);
					this.put("description", map.get("description"));
					this.put("location", map.get("location"));
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