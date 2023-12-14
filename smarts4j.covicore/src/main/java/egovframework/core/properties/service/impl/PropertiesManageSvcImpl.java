package egovframework.core.properties.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.InetAddress;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesManageSvc;
import egovframework.coviframework.base.PropertiesWatcher;

@Service("PropertiesManageSvcImpl")
public class PropertiesManageSvcImpl extends EgovAbstractServiceImpl implements PropertiesManageSvc {

	private static final Logger LOGGER = LogManager.getLogger(PropertiesManageSvcImpl.class);
	
	private static final String DEPLOY_PATH = System.getProperty("DEPLOY_PATH");
	
	private static final String PROPERTIES_MANAGE_YN = PropertiesUtil.getGlobalProperties().getProperty("properties.manage.yn");
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@PostConstruct
	@Override
	/**
	 * Properties DB 화 
	 */
	public void init() throws Exception {		
		try {
			if("Y".equalsIgnoreCase(PROPERTIES_MANAGE_YN)) {
				// Properties Delete
				String[] deleteServer = {"Framework", InetAddress.getLocalHost().getHostAddress()};
				coviMapperOne.delete("properties.manager.deletePropertiesData", deleteServer);
				
				CoviMap params = new CoviMap();
				params.put("codeGroup", "property_standardtype");
				params.put("reserved1", "Y");
				
				CoviList propertiesFiles = selectCodeList(params);
				
				if(propertiesFiles.size() > 0) {
					for(int i = 0; i < propertiesFiles.size(); i++) {
						CoviMap propertiesInfo = propertiesFiles.getJSONObject(i);
						
						// Framework Properties Load
						if(PropertiesWatcher.class.getResource("/property/" + propertiesInfo.getString("CodeName")) != null) {
							Properties properties = new Properties();
							
							try (InputStream is = PropertiesWatcher.class.getResourceAsStream("/property/" + propertiesInfo.getString("CodeName"));
									Reader isr = new InputStreamReader(is, Charset.forName("UTF-8"));
									){
								properties.load(isr);
							}
							
							
							ArrayList<CoviMap> dataList = new ArrayList<>();
							
							for (String key : properties.stringPropertyNames()) {
								if(!key.contains("#")) {
									CoviMap propertiesItem = new CoviMap();
									propertiesItem.put("server_ip", "Framework");
									propertiesItem.put("standardtype", propertiesInfo.getString("Code"));
									propertiesItem.put("setkey", key);
									propertiesItem.put("setvalue", properties.getProperty(key));		
									
									dataList.add(propertiesItem);
									
									LOGGER.info("server_ip : {}, standardtype : {}, setkey : {}, setvalue : {}", "Framework", propertiesInfo.getString("CodeName"), key, properties.getProperty(key));
								}
							}
							
							CoviMap frameworkMap = new CoviMap();
							frameworkMap.put("dataList", dataList);
							
							coviMapperOne.insert("properties.manager.insertPropertiesData", frameworkMap);
						}
						
						// Server Properties Load
						String deployPropertiesPath = DEPLOY_PATH + File.separator + "covi_property" + File.separator + propertiesInfo.getString("CodeName");
						
						if(new File(deployPropertiesPath).exists()) {
							try ( InputStream fi = new FileInputStream(deployPropertiesPath); InputStreamReader isr = new InputStreamReader(fi, Charset.forName("UTF-8")); ) {
								Properties properties = new Properties();
								properties.load(isr);
								
								ArrayList<CoviMap> dataList = new ArrayList<>();
								
								for (String key : properties.stringPropertyNames()) {
									if(!key.contains("#")) {
										CoviMap propertiesItem = new CoviMap();
										propertiesItem.put("server_ip", InetAddress.getLocalHost().getHostAddress());
										propertiesItem.put("standardtype", propertiesInfo.getString("Code"));
										propertiesItem.put("setkey", key);
										propertiesItem.put("setvalue", properties.getProperty(key));		
										
										dataList.add(propertiesItem);
										
										LOGGER.info("server_ip : {}, standardtype : {}, setkey : {}, setvalue : {}", InetAddress.getLocalHost().getHostAddress(), propertiesInfo.getString("CodeName"), key, properties.getProperty(key));
									}
								}
								
								CoviMap frameworkMap = new CoviMap();
								frameworkMap.put("dataList", dataList);
								
								coviMapperOne.insert("properties.manager.insertPropertiesData", frameworkMap);
							}						
				        }
					}
				}
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), e);
		}
	}
	
	@Override
	public CoviList selectCodeList(CoviMap params) {
		return coviMapperOne.list("properties.manager.selectCodeList", params);
	}
	
	@Override
	public CoviList selectServerList() throws Exception {
		return coviMapperOne.list("properties.manager.selectServerList", null);
	}
	
	@Override
	public CoviList selectPropertiesList(CoviMap params) throws Exception {
		CoviList resultList = new CoviList();		
		
		CoviList list = coviMapperOne.list("properties.manager.selectPropertiesList", params);
		resultList = CoviSelectSet.coviSelectJSON(list);
		
		return resultList;
	}
}