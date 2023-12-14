package egovframework.core.properties.service.impl;

import java.io.StringReader;
import java.util.Comparator;

import javax.annotation.Resource;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXParseException;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.properties.service.PropertiesContextManageSvc;

@Service("PropertiesContextManageSvcImpl")
public class PropertiesContextManageSvcImpl extends EgovAbstractServiceImpl implements PropertiesContextManageSvc {

	private Logger LOGGER = LogManager.getLogger(PropertiesContextManageSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectCodeList(CoviMap params) {
		return coviMapperOne.list("properties.context.selectCodeList", params);
	}
	
	@Override
	public CoviList selectServerList() throws Exception {
		return coviMapperOne.list("properties.context.selectServerList", null);
	}
	
	@Override
	public CoviMap selectContextList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("properties.context.selectContextList", new CoviMap() {{
			this.put("dbType", params.getString("dbType"));
			this.put("wasType", params.getString("wasType"));
		}});
		
		try {
			InputSource inputSource = new InputSource(new StringReader(params.getString("context")));
	        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	        Document doc = dbFactory.newDocumentBuilder().parse(inputSource);
	        NodeList nodeList = doc.getElementsByTagName("Resource");
	        
	        for (int i = 0; i < nodeList.getLength(); i++) {
	        	Element element = (Element) nodeList.item(i);
	            String name = element.getAttribute("name");
	            
	            NamedNodeMap namedNodeMap = element.getAttributes();
	            for (int j = 0; j < namedNodeMap.getLength(); j++) {
	            	String key = namedNodeMap.item(j).getNodeName();
	            	String value = namedNodeMap.item(j).getNodeValue();
	            	
	            	for (Object object : list) {
	            		CoviMap map = (CoviMap) object;
	            		
						if (map.get("name").equals(name) && map.get("setkey").equals((key))) {
							map.put("inputvalue", value);
							break;
						}
					}
	            	
	            	boolean exists = list.stream()
	            		.anyMatch(map -> ((CoviMap) map).get("name").equals(name) && ((CoviMap) map).get("setkey").equals(key));
	            	
	            	if (!exists) {
	            		list.add(new CoviMap() {{
	            			this.put("name", name);
	                		this.put("setkey", key);
	                		this.put("inputvalue", value);
	                	}});
	            	}
	            }
	        }
		} catch (SAXParseException e) {
			return generateList(list);
		}
		
        list.sort(Comparator.comparing(map -> ((CoviMap) map).getString("name")).thenComparing(map -> ((CoviMap) map).getString("setkey")));
		return generateList(list);
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