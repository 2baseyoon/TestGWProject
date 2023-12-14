package egovframework.covision.coviflow.legacy.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import java.io.StringReader;

import org.apache.commons.lang3.text.StrSubstitutor;
import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.simple.JSONObject;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceSvc;

@Service
public class LegacyInterfaceHTTPImpl extends LegacyInterfaceCommon implements LegacyInterfaceSvc {

	@Override
	public void call() throws Exception {
		// TODO encoding 동작 확인 필요
		this.logParam.get().put("ActionValue", this.legacyInfo.get().getString("HttpUrl"));
		
		CoviMap result = executeHTTP(this.legacyInfo.get(), this.legacyParams.get());
	}

	private CoviMap executeHTTP(CoviMap legacyInfo, CoviMap parameter) throws Exception {
		CoviMap result = new CoviMap();
		
		Map<String, Object> responseMap;
		
		String sURL = legacyInfo.optString("HttpUrl"); // http://localhost:8082/approval/admin/legacySample/restTest_json.do
		String method = legacyInfo.optString("Method"); // GET/POST
		String encoding = legacyInfo.optString("Encoding"); // UTF-8/EUC-KR
		String bodyType = legacyInfo.optString("BodyType"); // JSON/XML
		String responseBodyType = legacyInfo.optString("ResponseBodyType"); // JSON/XML
		String bodyData = legacyInfo.optString("HttpBody"); // "{\"bodyparam1\":\"${InitiatorOUDisplay}\",\"bodyparam2\":\"${INITIATORUNITID}\"}"
		String params = legacyInfo.optString("HttpParams"); // "{\"param1\":\"${InitiatorDisplay}\",\"param2\":\"${INITIATORNAME}\",\"encoding\":\"" + legacyInfo.optString("encoding") + "\"}"
		String basicAuth = "";
		//basicAuth = "Basic " + Base64.encode(("id" + ":" + "pw").getBytes(StandardCharsets.UTF_8));
		
		String contentType;
		switch(bodyType) {
			case "JSON": contentType = "application/json"; break;
			case "XML": contentType = "application/xml"; break;
			default: contentType = "text/plain"; break;
		}
		
		// requset body 파라미터 매핑 ${xxx}
		bodyData = bindingParameters(parameter, bodyData, bodyType);
		
		// request parameter 파라미터 매핑
		params = bindingParameters(parameter, params, "JSON");
		List<NameValuePair> paramData;
		paramData = new ArrayList<NameValuePair>();
		Set<Map.Entry<String, Object>> set = new CoviMap(params).entrySet();
		for(Map.Entry<String, Object> entry : set) {
			paramData.add(new BasicNameValuePair(entry.getKey(), entry.getValue().toString()));
		}
		
		// 호출
		HttpsUtil httpsUtil = new HttpsUtil();
		responseMap = httpsUtil.httpsClientConnectResponse(sURL, method, bodyData, contentType, encoding, basicAuth, paramData);
		
		for(Map.Entry<String, Object> entry : responseMap.entrySet()) {
			result.put(entry.getKey(), entry.getValue());
		}
		
		String responseCode = result.optString("STATUSCODE");
		if(!responseCode.equals("200")) throw new Exception("Error - HTTP Response " + responseCode);
		
		// 리턴값 체크
		String outStatusKey = legacyInfo.optString("OutStatusKey");			// RESULT - out status 키
		String outCompareType = legacyInfo.optString("OutCompareType");		// E - out parameter 비교조건 - E : 같을때 성공 , NE : 다를떄 성공
		String outCompareValue = legacyInfo.optString("OutCompareValue");	// S - out parameter 비교값
		String outMsgKey = legacyInfo.optString("OutMsgKey");				// MESSAGE - out message 키
		String strResult = result.optString("MESSAGE");
		
		this.logParam.get().put("RawResponse", strResult);
		
		if(!strResult.isEmpty() && !outStatusKey.isEmpty()) {
			
			String rtnStatus = "";
			String rtnMessage = "";
			String errorMessage = "";
			
			if(responseBodyType.equals("JSON")) {
				Object resultCodeObj = JsonPath.read(strResult, outStatusKey); // parse
				if(resultCodeObj == null) ;
				else if(resultCodeObj instanceof String) rtnStatus = resultCodeObj.toString();
				else rtnStatus = ((List<String>)resultCodeObj).get(0);
				
				this.logParam.get().put("ResultCode", rtnStatus);
				
	 			errorMessage = "Error " + outStatusKey + "=" + rtnStatus;
	 			if(!outMsgKey.isEmpty()) {
	 				Object resultMsgObj = JsonPath.read(strResult, outMsgKey); // parse
	 				if(resultMsgObj == null) ;
	 				else if(resultMsgObj instanceof String) rtnMessage = resultMsgObj.toString();
	 				else rtnMessage = ((List<String>)resultMsgObj).get(0);
	 				
	 				this.logParam.get().put("ResultMessage", rtnMessage);
					errorMessage = errorMessage + " , " + outMsgKey + "=" + rtnMessage;
				}
	 			if(outCompareType.equalsIgnoreCase("E") && !rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}else if(outCompareType.equalsIgnoreCase("NE") && rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}
			}else if(responseBodyType.equals("XML")) {
				DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	 			DocumentBuilder builder = factory.newDocumentBuilder();
	 			Document doc = builder.parse(new InputSource(new StringReader(strResult)));
	 			XPath xpath = XPathFactory.newInstance().newXPath();
	 			Node resultCodeNode = (Node)xpath.compile(outStatusKey).evaluate(doc, XPathConstants.NODE);
	 			//NodeList resultCodeNodeList = (NodeList)xpath.compile("rootNode/statusList").evaluate(doc, XPathConstants.NODESET);
	 			if(resultCodeNode != null) {
	 				rtnStatus = resultCodeNode.getTextContent();
	 				this.logParam.get().put("ResultCode", rtnStatus);
	 			}
	 			errorMessage = "Error " + outStatusKey + "=" + rtnStatus;
	 			if(!outMsgKey.isEmpty()) {
	 				Node resultMsgNode = (Node)xpath.compile(outMsgKey).evaluate(doc, XPathConstants.NODE);
	 				if(resultMsgNode != null) {
	 					rtnMessage = resultMsgNode.getTextContent();
	 					this.logParam.get().put("ResultMessage", rtnMessage);
	 				}
					errorMessage = errorMessage + " , " + outMsgKey + "=" + rtnMessage;
				}
	 			if(outCompareType.equalsIgnoreCase("E") && !rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}else if(outCompareType.equalsIgnoreCase("NE") && rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}
			}
		}
		
		return result;
	}
	
	
	/**
	 * apache.common.lang3 활용 keyword 치환.
	 * @param params
	 * @param BodyData
	 * @param bodyType(JSON/XML)
	 * @return
	 * @throws Exception 
	 */
	public String bindingParameters(CoviMap parameter, String originalBodyData, String bodyType) throws Exception {
		Map<String, Object> parameterMap = new ObjectMapper().readValue(parameter.toString(), Map.class);
		String replacedBodyData = originalBodyData;
		for(Map.Entry<String, Object> entry : parameterMap.entrySet()) {
			if(bodyType.equals("JSON")) entry.setValue(JSONObject.escape(entry.getValue().toString()));
			else if(bodyType.equals("XML")) entry.setValue("<![CDATA["+entry.getValue()+"]]>");
		}
		replacedBodyData = StrSubstitutor.replace(originalBodyData, parameterMap);
		
		return replacedBodyData;
	}
	
}

