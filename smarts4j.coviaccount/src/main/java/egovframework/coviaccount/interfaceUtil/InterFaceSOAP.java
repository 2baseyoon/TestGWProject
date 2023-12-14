package egovframework.coviaccount.interfaceUtil;

import java.io.ByteArrayInputStream;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;

import javax.annotation.Resource;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.Node;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.common.util.AccountUtil;

@Component("InterFaceSOAP")
public class InterFaceSOAP {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public CoviMap getInterFaceSOAP(CoviMap param){
		CoviMap rtObject		= new CoviMap();
		try{
			String soapEndpointURL	= accountUtil.getPropertyInfo("account.soap.soapEndpointURL");
			String soapAction		= rtString(param.get("soapAction"));
			ArrayList returnList = callSoapWebService(soapEndpointURL,soapAction,param);
			
			rtObject.put("IfCnt",	returnList.size());
			rtObject.put("list",	returnList);
			rtObject.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return rtObject;
	}
	
	private ArrayList callSoapWebService(String soapEndpointURL, String soapAction, CoviMap param){
		
		ArrayList returnList = new ArrayList(); 
		String chkStr = "";
		try {
			// create SOAP Connection
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			SOAPConnection soapConnection = soapConnectionFactory.createConnection();
			
			// Send SOAP Message to SOAP Server
			SOAPMessage soapResponse = soapConnection.call(createSOAPRequest(soapAction,param), soapEndpointURL);
			/**	Print the SOAP Response
				System.out.println("Response SOAP Message : ");
				soapResponse.writeTo(System.out);
				System.out.println();
			 */
			String daoClassName			= accountUtil.getPropertyInfo("account.interface.dao")	+ rtString(param.get("daoClassName"));
			String voClassName			= accountUtil.getPropertyInfo("account.interface.vo")	+ rtString(param.get("voClassName"));
			String mapClassName			= accountUtil.getPropertyInfo("account.interface.map")	+ rtString(param.get("mapClassName"));
			String daoSetFunctionName	= rtString(param.get("daoSetFunctionName"));
			String daoGetFunctionName	= rtString(param.get("daoGetFunctionName"));
			String voFunctionName		= rtString(param.get("voFunctionName"));
			String mapFunctionName		= rtString(param.get("mapFunctionName"));
			
			ArrayList rtList	= new ArrayList();
			
			Class	mapCls	= Class.forName(mapClassName);
			Object	mapObj	= mapCls.newInstance();
			Method	mapMth	= mapCls.getMethod(mapFunctionName);
			CoviMap map		= (CoviMap) mapMth.invoke(mapObj);
			
			Class[]	voTyp	= new Class[] {CoviMap.class};
			Class	voCls	= Class.forName(voClassName);
			Method	voMth	= voCls.getMethod(voFunctionName,voTyp);
			
			Class[]	daoTyp	= new Class[] {ArrayList.class};
			Class	daoCls	= Class.forName(daoClassName);
			Object	daoObj	= daoCls.newInstance();
			Method	daoSetMth	= daoCls.getMethod(daoSetFunctionName, daoTyp);
			Method	daoGetMth	= daoCls.getMethod(daoGetFunctionName);
			
			SOAPBody soapBody = soapResponse.getSOAPBody();
			Iterator iterator = soapBody.getChildElements();
			
			Node	node	= (Node) iterator.next();
			String	value	= node.getChildNodes().item(0).getChildNodes().item(0).getNodeValue();
					/**	node value
						System.out.println(value);
					 */
					value	= value.replace("<NewDataSet>", "").replace("</NewDataSet>", "").replace("</Table>", "").trim();
					
			String[] valueArr = value.split("<Table>");
			for(int arr=0; arr<valueArr.length; arr++){
				String nowStr	= valueArr[arr];
				CoviMap addObj	= new CoviMap();
				Object	voObj	= voCls.newInstance();
				
				while(true){
					nowStr = nowStr.trim();
					
					if(nowStr.length() == 0){
						break;
					}
					
					String itemName		= nowStr.substring(nowStr.indexOf("<")+1,nowStr.indexOf(">")).replace("/", "").trim();
					String itemNameS	= "<"	+ itemName + ">";
					String itemNameE	= "</"	+ itemName + ">";
					String itemNameD	= "<"	+ itemName + " />";
					
					if(nowStr.indexOf(itemNameD) > -1){
						nowStr = nowStr.replace(itemNameD, "");
					}else{
						nowStr = nowStr.replace(itemNameS, "");
						
						String itemValue = nowStr.substring(0,nowStr.indexOf(itemNameE)).trim();
						
						String key = "";
						String val = itemValue;
						
						Map<String, Object> allMap = map;
						for(Map.Entry<String, Object> entry : allMap.entrySet()){
							String allMapKey = rtString(entry.getKey());
							if((allMapKey.toUpperCase()).equals(itemName.toUpperCase())){
								key = rtString(map.get(allMapKey));
							}
						}
						
						addObj.put(key, val);
						
						chkStr = chkStr + "[KEY, OLD_KEY] ::: [" + key+","+ itemName + "], --- " + val; 
						//System.out.println(chkStr);
						chkStr = "";
						
						nowStr = nowStr.replace(itemValue+itemNameE, "");
					}
				}
				
				voMth.invoke(voObj, addObj);
				rtList.add(voObj);
			}
			daoSetMth.invoke(daoObj, rtList);
			
			returnList = (ArrayList) daoGetMth.invoke(daoObj);
			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	private SOAPMessage createSOAPRequest(String soapAction,CoviMap param) throws Exception{
		
		MessageFactory messageFactory = MessageFactory.newInstance();
		SOAPMessage soapMessage = messageFactory.createMessage();
		
		MimeHeaders headers = soapMessage.getMimeHeaders();
		headers.addHeader("SOAPAction", soapAction);
		
		createSoapEnvelope(soapMessage,param);
		soapMessage.saveChanges();
		/**	Print the SOAP Response
			System.out.println("Request SOAP Message : ");
			soapMessage.writeTo(System.out);
			System.out.println();
		 */
		return soapMessage;
	}

	private void createSoapEnvelope(SOAPMessage soapMessage, CoviMap param) throws SOAPException{
		
		Map<String, Object> xmlParam	= (Map<String, Object>) param.get("xmlParam");
		SOAPPart soapPart				= soapMessage.getSOAPPart();
		int pPageSizeChk		= 0;
		int ppPageCurrentChk	= 0;
		String xmlParamStr	= "";
		
		StringBuffer buf = new StringBuffer();
		for(Map.Entry<String, Object> entry : xmlParam.entrySet()){
			String allMapKey = rtString(entry.getKey());
			String allMapVal = rtString(entry.getValue());
			
			if((allMapKey.length() + allMapVal.length()) > 1){
				//xmlParamStr += "<"+allMapKey+">"+allMapVal+"</"+allMapKey+">";
				buf.append("<").append(allMapKey).append(">").append(allMapVal).append("</").append(allMapKey).append(">");
			}
				
			if(allMapKey.equals("pPageSize")){
				pPageSizeChk = 1;
			}
			
			if(allMapKey.equals("pPageCurrent")){
				ppPageCurrentChk = 1;
			}
		}
		xmlParamStr = buf.toString();
		
		if(pPageSizeChk == 0){
			xmlParamStr += "<pPageSize>999999999</pPageSize>";
		}
		
		if(ppPageCurrentChk == 0){
			xmlParamStr += "<pPageCurrent>1</pPageCurrent>";
		}
		
		String xmlStr	= "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
						+ "<soap:Envelope	xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
						+ "					xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
						+ "					xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
						+ "	<soap:Body>"
						+ "		<"+rtString(param.get("soapName"))+" xmlns=\"http://tempuri.org/\">"
						+			xmlParamStr
						+ "		</"+rtString(param.get("soapName"))+">"
						+ "	</soap:Body>"
						+ "</soap:Envelope>";
		
		//System.out.println(xmlStr);
		byte[] buffer = xmlStr.getBytes(StandardCharsets.UTF_8);
		ByteArrayInputStream stream = new ByteArrayInputStream(buffer);
		StreamSource source = new StreamSource(stream);
		
		soapPart.setContent(source);
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().replace("{", "").replace("}", "").trim();
		return rtStr;
	}
}
