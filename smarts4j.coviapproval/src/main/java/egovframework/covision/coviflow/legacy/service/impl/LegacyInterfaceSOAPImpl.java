package egovframework.covision.coviflow.legacy.service.impl;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang3.text.StrSubstitutor;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.endpoint.Endpoint;
import org.apache.cxf.jaxws.endpoint.dynamic.JaxWsDynamicClientFactory;
import org.apache.cxf.service.model.BindingOperationInfo;
import org.apache.cxf.service.model.MessagePartInfo;
import org.apache.cxf.service.model.OperationInfo;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceSvc;

@Service
public class LegacyInterfaceSOAPImpl extends LegacyInterfaceCommon implements LegacyInterfaceSvc {
	private static final Logger LOGGER = LogManager.getLogger(LegacyInterfaceSOAPImpl.class);
	
	//private Settings setting = new Settings();
	//private CoviMap parameters;
	
	private ThreadLocal<Settings> setting = new ThreadLocal<Settings>();
	private ThreadLocal<CoviMap> parameters = new ThreadLocal<CoviMap>();
	
	@Override
	public void call() throws Exception {
		setSetting(this.legacyInfo.get(), this.legacyParams.get());
		this.logParam.get().put("ActionValue", legacyInfo.get().getString("WSDLUrl") + "[" + legacyInfo.get().getString("OperationName") + "]");
		
		CoviMap returnMap = null;
		String soapActionType = legacyInfo.get().optString("SoapType",  "XML");
		try {
			if("XML".equals(soapActionType)) {
				returnMap = processXml();
			}else if("WSDL".equals(soapActionType)) {
				returnMap = processByWsdl();
			}else {
				throw new Exception("SoapType is not defined. Please Check Configuration. [" + soapActionType + "]");
			}
			
			if(returnMap != null) {
				String code = returnMap.optString("Code");
				String msg = returnMap.optString("Msg");
				
				this.logParam.get().put("ResultCode", code);
				this.logParam.get().put("ResultMessage", msg);
				
				// Success Code
	 			if("E".equals(setting.get().getRESPONSE_COMPARE_TYPE()) && !code.equals(setting.get().getRESPONSE_COMPARE_VALUE())) {
					throw new SOAPException("Return Code is " + code + ", Return Message is " + msg + ", Not matched with [" + setting.get().getRESPONSE_COMPARE_VALUE() + "]" );
				}
	 			// Fail Code
	 			else if("NE".equals(setting.get().getRESPONSE_COMPARE_TYPE()) && code.equals(setting.get().getRESPONSE_COMPARE_VALUE())) {
	 				throw new SOAPException("Return Code is " + code + ", Return Message is " + msg);
				}
			}
		}catch(SOAPException e) {
			throw new SOAPException(e);
		}finally {
			setting.remove();
			parameters.remove();
		}
	}
	
	private void setSetting(CoviMap legacyInfo, CoviMap parameters) {
		// 공통Parameters 및 BodyContent Parameters
		this.parameters.set(parameters);
				
		Settings _setting = new Settings();
		_setting.setWSDL_URL(legacyInfo.getString("WSDLUrl")); // WSDL URL
		_setting.setENDPOINT_URL(legacyInfo.getString("EndpointUrl")); // Endpoint URL
		
		_setting.setREQUEST_XML(legacyInfo.getString("WSRequestXML")); // 요청 Envelope XML
		_setting.setREQUEST_OBJECT_INFO(legacyInfo.getString("WSRequestObjectInfo")); // 요청 Skeleton Object Info
		_setting.setOPERATION_NAME(legacyInfo.getString("OperationName")); // Operation Name
		_setting.setRES_CODE_XPATH(legacyInfo.getString("ResponseCodeXpath")); // XPATH String for Response
		_setting.setRES_MSG_XPATH(legacyInfo.getString("ResponseMsgXpath")); // XPATH String for Response
		
		// Apache CXF
		_setting.setRES_CODE_METHOD(legacyInfo.getString("ResponseCodeMethod")); // getCode
		_setting.setRES_MSG_METHOD(legacyInfo.getString("ResponseMsgMethod")); // getMsg
		_setting.setRESULT_CODE_IDX(legacyInfo.getInt("ResponseCodeIndex"));
		_setting.setRESULT_MSG_IDX(legacyInfo.getInt("ResponseMsgIndex"));
		
		_setting.setERROR_ON_FAIL(legacyInfo.getString("ErrorOnFail"));
		_setting.setRESPONSE_COMPARE_TYPE(legacyInfo.getString("OutCompareType"));
		_setting.setRESPONSE_COMPARE_VALUE(legacyInfo.getString("OutCompareValue"));
		
		this.setting.set(_setting);
	}
	

	
	/**
	 * Raw XML 방식
	 * Request envelope XML 기준으로 파라미터만 변경하여 호출하는 방식
	 * 호출응답은 설정된 xpath 로 읽는다.
	 */
	private CoviMap processXml() throws Exception {
		CoviMap returnMap = new CoviMap();
		try {
			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
			builderFactory.setNamespaceAware(false);
			DocumentBuilder builder = builderFactory.newDocumentBuilder();
			
			
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			SOAPConnection soapConnection = soapConnectionFactory.createConnection();
			
			
			// Variables
			String soapEndpointURL = setting.get().getENDPOINT_URL();
			SOAPMessage soapMessage = null;

			// xml type (sample) - request 용 Envelope 을 얻어서 값만 바꾸는 방식 Envelope 얻기 위해 library 사용.
			// request xml 얻는 부분은 연동설정쪽에서 활용하여 관리자가 파라미터명을 셋팅하도록 가고
			String soapActionHeader = "";
			String requestXml = setting.get().getREQUEST_XML();
			
			// 실제로는 Full Request Envelope XML 을 받아서(설정) 변수치환하여 전송하도록 한다.
			requestXml = bindingParameters(parameters.get(), requestXml);
			
			long startTime = System.currentTimeMillis();
			
			try (InputStream is = new ByteArrayInputStream(requestXml.getBytes("UTF-8"));) {
				soapMessage = MessageFactory.newInstance().createMessage(null, is);
			}
			MimeHeaders headers = soapMessage.getMimeHeaders();
			headers.addHeader("SOAPAction", soapActionHeader);
			
			// send message
			soapMessage.saveChanges();
			
			// Call WS
			SOAPMessage soapResponse = soapConnection.call(soapMessage, soapEndpointURL);
			
			// Parse Response XML
			Document doc = null;
			try(ByteArrayOutputStream bao = new ByteArrayOutputStream();)
			{
				soapResponse.writeTo(bao);
				
				String xml = bao.toString("UTF-8");
				this.logParam.get().put("RawResponse", xml);
				LOGGER.debug("==================== FULL Response =======================");
				LOGGER.debug("\n");
				LOGGER.debug( xml);
				
				doc = builder.parse(new InputSource(new StringReader(xml)));
			}
	        
			javax.xml.xpath.XPath xpath = XPathFactory.newInstance().newXPath();
			org.w3c.dom.Node resultCodeNode = (org.w3c.dom.Node)xpath.compile(setting.get().getRES_CODE_XPATH()).evaluate(doc, XPathConstants.NODE);
			org.w3c.dom.Node resultMsgNode = (org.w3c.dom.Node)xpath.compile(setting.get().getRES_MSG_XPATH()).evaluate(doc, XPathConstants.NODE);
			
			if(resultCodeNode == null) {
				throw new Exception("Check Xpath for Result Code : " + setting.get().getRES_CODE_XPATH());
			}
			String resultCode = resultCodeNode.getTextContent();
			String resultMessage = "";
			if(resultMsgNode != null) {
				resultMessage = resultMsgNode.getTextContent();
			}
			
			LOGGER.debug("Result Code[XPATH] : " + resultCode);
			LOGGER.debug("Result Message[XPATH] : " + resultMessage);
			
			LOGGER.debug("Process by xml : " + (System.currentTimeMillis() - startTime) + "ms");
			
			returnMap.put("Code", resultCode);
			returnMap.put("Msg", resultMessage);
			return returnMap;
		} catch(SOAPException e) {
			throw e;
		} catch(Exception e) {
			// wrap
			throw new SOAPException(e);
		}
		
	}
	
	/**
	 * Apache Cxf 라이브러리고 간단한 WS 호출방식 Request, Response 구조가 복잡하면 사용하기 어려움.
	 * WSDL 기준으로 Response 가 VO객체인경우라도 deserialize 되어 dynamic class 가 로딩되므로 getter method 를 사용하여
	 * 값을 추출할 수 있음.
	 */
	private CoviMap processByWsdl() throws Exception {
		CoviMap returnMap = new CoviMap();
		Client client = null;
		try {
			String wsdlURL = setting.get().getWSDL_URL(); 
			String operationName = setting.get().getOPERATION_NAME(); // operation name
			JaxWsDynamicClientFactory dcf = JaxWsDynamicClientFactory.newInstance();
			
			client = dcf.createClient(wsdlURL);
			
			// ================== Input Type 이 Object 인 경우 Dynamic Setter 처리 
			Endpoint endpoint = client.getEndpoint();
			javax.xml.namespace.QName operation = new javax.xml.namespace.QName(endpoint.getService().getName().getNamespaceURI(), operationName);
			BindingOperationInfo op = endpoint.getEndpointInfo().getBinding().getOperation(operation);
			
	        if (op.isUnwrappedCapable()) {
	            op = op.getUnwrappedOperation();
	        }
			OperationInfo opInfo = op.getOperationInfo();
			int argumentsSize = opInfo.getInput().getMessageParts().size();
			Object[] params = new Object[argumentsSize];
			
			String requestInfoStr = setting.get().getREQUEST_OBJECT_INFO();
			requestInfoStr = bindingParameters(parameters.get(), requestInfoStr);
			
			CoviList argumentInfoList = new CoviList(requestInfoStr);
			
			for(int i = 0; i < argumentsSize; i++) {
				MessagePartInfo mpi = opInfo.getInput().getMessagePart(i);
				
				if(mpi.getTypeClass() == String.class) {
					params[i] = argumentInfoList.getJSONObject(i).optString("Value");
				}else if(mpi.getTypeClass() == Integer.class || mpi.getTypeClass() == int.class) {
					params[i] = argumentInfoList.getJSONObject(i).optInt("Value");
				}else {
					// Custom Object 는 de-serialize 처리한다.
					//Object inst = mpi.getTypeClass().newInstance();
					String typeClass = argumentInfoList.getJSONObject(i).optString("Type");
					CoviMap objectJson = argumentInfoList.getJSONObject(i).optJSONObject("Value");
					
					if(!mpi.getTypeClass().getName().equals(typeClass)) {
						throw new Exception ("Desired class is " + typeClass + ", but requested Type class is " + mpi.getTypeClass());
					}
					ObjectMapper objectMapper = new ObjectMapper();
					Object inst = objectMapper.readValue(objectJson.toString(), mpi.getTypeClass());
					
					params[i] = inst;
				}
			}
			
			// ================== Input Type 이 Object 인 경우 Dynamic Setter 처리 
			
			Object[] res = client.invoke(operationName, params);
			Object rst = res[0]; // WS 제공시스템 (Java기준) 에서 return type 을 Array 로 지정하여도 Object[0] 에 ArrayList 형태로 들어옴.
			String code = "";
			String msg = "";
			
			if(rst instanceof String) {
				code = (String)rst;
			}
			else if(rst instanceof Object) {
				if(rst instanceof java.util.ArrayList) {
					java.util.List rstList = (java.util.ArrayList)rst;
					int rstIndex = 0;
					for(Object o : rstList) {
						if(o instanceof String || o instanceof Integer) {
							if(setting.get().getRESULT_CODE_IDX() == rstIndex) {
								code = o.toString();
							}
							if(setting.get().getRESULT_MSG_IDX() == rstIndex) {
								msg = o.toString();
							}
						}else {
							throw new Exception("Not supported Response Type [ "+ o.getClass() +" ]");
						}
						rstIndex ++;
					}
				}else {
					Method codeGetter = rst.getClass().getMethod(setting.get().getRES_CODE_METHOD(), null);
					code = (String)codeGetter.invoke(rst, null);
					
					Method msgGetter = rst.getClass().getMethod(setting.get().getRES_MSG_METHOD(), null);
					msg = (String)msgGetter.invoke(rst, null);
				}
			}
			LOGGER.debug("Result Code[Apache CXF] : " + code);
			LOGGER.debug("Result Msg[Apache CXF] : " + msg);
			
			returnMap.put("Code", code);
			returnMap.put("Msg", msg);
			return returnMap;
		} catch (IllegalAccessException | IllegalArgumentException e) {
			throw new SOAPException(e);
		} catch (InvocationTargetException | NoSuchMethodException e) {
			throw new SOAPException(e);
		} catch (SecurityException e) {
			throw new SOAPException(e);
		} catch (Exception e) {
			throw new SOAPException(e);
		} finally {
			if(client != null) {
				try {
					client.close();
				} catch(NullPointerException e){	
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
	}
	
	/**
	 * apache.common.lang3 활용 keyword 치환.
	 * @param params
	 * @param XML
	 * @return
	 */
	public String bindingParameters(CoviMap params, String originalXml) {
		String replacedXml = originalXml;
		
		String soapActionType = legacyInfo.get().optString("SoapType",  "XML");
		
		if("XML".equals(soapActionType)) {
			for(Object entrySet : params.entrySet()) {
				Map.Entry<String, Object> entry = (Map.Entry<String, Object>)entrySet;
					entry.setValue("<![CDATA["+entry.getValue()+"]]>");
			}
		}
		replacedXml = StrSubstitutor.replace(originalXml, params);
		// replace null remain variables
		replacedXml = replacedXml.replaceAll("\\$\\{[a-zA-Z0-9]+\\}", "");
		
		LOGGER.debug("=========== Parameter replaced XML");
		LOGGER.debug(replacedXml);
		
		return replacedXml;
	}

	public static class Settings {
		private String WSDL_URL = "";
		private String ENDPOINT_URL = "";
		private String OPERATION_NAME = "";
		private String REQUEST_XML = "";
		private String REQUEST_OBJECT_INFO = "";
		private String RES_CODE_XPATH = "";
		private String RES_MSG_XPATH = "";
		private String RES_CODE_METHOD = "";	
		private String RES_MSG_METHOD = "";
		private String REQ_KEY1_METHOD = "";	
		private String REQ_KEY2_METHOD = "";
		private String REQ_KEY3_METHOD = "";
		private int RESULT_CODE_IDX = -1;
		private int RESULT_MSG_IDX = -1;
		private String ERROR_ON_FAIL = "N";
		private String RESPONSE_COMPARE_TYPE = "E"; //E, NE
		private String RESPONSE_COMPARE_VALUE = "";
		
		public String getWSDL_URL() {
			return WSDL_URL;
		}
		public void setWSDL_URL(String wSDL_URL) {
			WSDL_URL = wSDL_URL;
		}
		public String getENDPOINT_URL() {
			return ENDPOINT_URL;
		}
		public void setENDPOINT_URL(String eNDPOINT_URL) {
			ENDPOINT_URL = eNDPOINT_URL;
		}
		public String getOPERATION_NAME() {
			return OPERATION_NAME;
		}
		public void setOPERATION_NAME(String oPERATION_NAME) {
			OPERATION_NAME = oPERATION_NAME;
		}
		public String getREQUEST_XML() {
			return REQUEST_XML;
		}
		public void setREQUEST_XML(String rEQUEST_XML) {
			REQUEST_XML = rEQUEST_XML;
		}
		public String getREQUEST_OBJECT_INFO() {
			return REQUEST_OBJECT_INFO;
		}
		public void setREQUEST_OBJECT_INFO(String REQUEST_OBJECT_INFO) {
			this.REQUEST_OBJECT_INFO = REQUEST_OBJECT_INFO;
		}
		public String getRES_CODE_XPATH() {
			return RES_CODE_XPATH;
		}
		public void setRES_CODE_XPATH(String rES_CODE_XPATH) {
			RES_CODE_XPATH = rES_CODE_XPATH;
		}
		public String getRES_MSG_XPATH() {
			return RES_MSG_XPATH;
		}
		public void setRES_MSG_XPATH(String rES_MSG_XPATH) {
			RES_MSG_XPATH = rES_MSG_XPATH;
		}
		public String getRES_CODE_METHOD() {
			return RES_CODE_METHOD;
		}
		public void setRES_CODE_METHOD(String rES_CODE_METHOD) {
			RES_CODE_METHOD = rES_CODE_METHOD;
		}
		public String getRES_MSG_METHOD() {
			return RES_MSG_METHOD;
		}
		public void setRES_MSG_METHOD(String rES_MSG_METHOD) {
			RES_MSG_METHOD = rES_MSG_METHOD;
		}
		public String getREQ_KEY1_METHOD() {
			return REQ_KEY1_METHOD;
		}
		public void setREQ_KEY1_METHOD(String rEQ_KEY1_METHOD) {
			REQ_KEY1_METHOD = rEQ_KEY1_METHOD;
		}
		public String getREQ_KEY2_METHOD() {
			return REQ_KEY2_METHOD;
		}
		public void setREQ_KEY2_METHOD(String rEQ_KEY2_METHOD) {
			REQ_KEY2_METHOD = rEQ_KEY2_METHOD;
		}
		public String getREQ_KEY3_METHOD() {
			return REQ_KEY3_METHOD;
		}
		public void setREQ_KEY3_METHOD(String rEQ_KEY3_METHOD) {
			REQ_KEY3_METHOD = rEQ_KEY3_METHOD;
		}
		public int getRESULT_CODE_IDX() {
			return RESULT_CODE_IDX;
		}
		public void setRESULT_CODE_IDX(int rESULT_CODE_IDX) {
			RESULT_CODE_IDX = rESULT_CODE_IDX;
		}
		public int getRESULT_MSG_IDX() {
			return RESULT_MSG_IDX;
		}
		public void setRESULT_MSG_IDX(int rESULT_MSG_IDX) {
			RESULT_MSG_IDX = rESULT_MSG_IDX;
		}
		public String getERROR_ON_FAIL() {
			return ERROR_ON_FAIL;
		}
		public void setERROR_ON_FAIL(String eRROR_ON_FAIL) {
			ERROR_ON_FAIL = eRROR_ON_FAIL;
		}
		public String getRESPONSE_COMPARE_TYPE() {
			return RESPONSE_COMPARE_TYPE;
		}
		public void setRESPONSE_COMPARE_TYPE(String rESPONSE_COMPARE_TYPE) {
			RESPONSE_COMPARE_TYPE = rESPONSE_COMPARE_TYPE;
		}
		public String getRESPONSE_COMPARE_VALUE() {
			return RESPONSE_COMPARE_VALUE;
		}
		public void setRESPONSE_COMPARE_VALUE(String rESPONSE_COMPARE_VALUE) {
			RESPONSE_COMPARE_VALUE = rESPONSE_COMPARE_VALUE;
		}
	}
}
