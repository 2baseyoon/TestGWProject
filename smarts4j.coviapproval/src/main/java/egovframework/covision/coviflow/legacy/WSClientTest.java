package egovframework.covision.coviflow.legacy;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.reflect.Method;
import java.util.Hashtable;
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

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrSubstitutor;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.endpoint.Endpoint;
import org.apache.cxf.jaxws.endpoint.dynamic.JaxWsDynamicClientFactory;
import org.apache.cxf.service.model.BindingOperationInfo;
import org.apache.cxf.service.model.MessagePartInfo;
import org.apache.cxf.service.model.OperationInfo;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import com.predic8.wsdl.Binding;
import com.predic8.wsdl.BindingOperation;
import com.predic8.wsdl.Definitions;
import com.predic8.wsdl.Operation;
import com.predic8.wsdl.WSDLParser;
import com.predic8.wstool.creator.RequestTemplateCreator;
import com.predic8.wstool.creator.SOARequestCreator;

import egovframework.covision.coviflow.legacy.util.WSDLUtil;
import egovframework.covision.coviflow.legacy.web.LegacySampleCon;
import groovy.xml.MarkupBuilder;

public class WSClientTest {
	
	private static final Logger LOGGER = LogManager.getLogger(LegacySampleCon.class);
	private Settings setting;
	public WSClientTest (Settings setting) {
		this.setting = setting;
	}
	
	/**
	 * Raw XML 방식
	 * Request envelope XML 기준으로 파라미터만 변경하여 호출하는 방식
	 * 호출응답은 설정된 xpath 로 읽는다.
	 */
	public void processXml() {
		try {
			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
			builderFactory.setNamespaceAware(false);
			DocumentBuilder builder = builderFactory.newDocumentBuilder();
			
			
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			SOAPConnection soapConnection = soapConnectionFactory.createConnection();
			
			
			// Variables
			String wsdlURL = setting.getWSDL_URL();
			String soapEndpointURL = setting.getENDPOINT_URL();
			String soapAction = setting.getOPERATION_NAME(); // operation name
			Map<String, Object> payload = new Hashtable<String, Object>();
			
			SOAPMessage soapMessage = null;
			

			// 1) manually - 요방식은 설정값으로 dynamic 처리하기가 어려움 Skip.
			//SOAPBody body = soapMessage.getSOAPBody();
			//body.addChildElement(new QName("q0",soapAction)).addChildElement(new QName("q0","reqAnimal")).setTextContent("Lion");
			
			// 2) xml type (sample) - request 용 Envelope 을 얻어서 값만 바꾸는 방식 Envelope 얻기 위해 library 사용.
			// request xml 얻는 부분은 연동설정쪽에서 활용하여 관리자가 파라미터명을 셋팅하도록 가고
			String soapActionHeader = "";
			String requestXml = WSDLUtil.extractRequestSoapTemplates(wsdlURL, "", soapAction, "", soapActionHeader);
			
			// 2-1) 실제로는 Full Request Envelope XML 을 받아서 변수치환하여 전송하도록 한다.
			// 저장된 request 용 parameter
			// String reqxml = interfaceInfo.getWsdlRequestXml();
			// bind Parameters.
			requestXml = requestXml.replaceAll("\\?XXX\\?", "\\$\\{LegacyKey\\}"); // FIXME - Delete
			payload.put("LegacyKey", "ABCDE");
			requestXml = bindingParameters(payload, requestXml);
			
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
				LOGGER.debug("==================== FULL Response =======================");
				LOGGER.debug("\n");
				LOGGER.debug( xml);
				
				doc = builder.parse(new InputSource(new StringReader(xml)));
			}
	        
			javax.xml.xpath.XPath xpath = XPathFactory.newInstance().newXPath();
			org.w3c.dom.Node resultCodeNode = (org.w3c.dom.Node)xpath.compile(setting.getRES_CODE_XPATH()).evaluate(doc, XPathConstants.NODE);
			org.w3c.dom.Node resultMsgNode = (org.w3c.dom.Node)xpath.compile(setting.getRES_MSG_XPATH()).evaluate(doc, XPathConstants.NODE);
			
			
			String resultCode = resultCodeNode.getTextContent();
			String resultMessage = "";
			if(resultMsgNode != null) {
				resultMessage = resultMsgNode.getTextContent();
			}
			
			LOGGER.debug("Result Code[XPATH] : " + resultCode);
			LOGGER.debug("Result Message[XPATH] : " + resultMessage);
			
			
			LOGGER.debug("Process by xml : " + (System.currentTimeMillis() - startTime) + "ms");
		} catch(SOAPException e) {
			// FIXME Logger
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			// FIXME Logger
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
	}
	
	/**
	 * Apache Cxf 라이브러리고 간단한 WS 호출방식 Request, Response 구조가 복잡하면 사용하기 어려움.
	 * WSDL 기준으로 Response 가 VO객체인경우라도 deserialize 되어 dynamic class 가 로딩되므로 getter method 를 사용하여
	 * 값을 추출할 수 있음.
	 */
	public void processByWsdl() {
		Client client = null;
		try {
			String wsdlURL = setting.getWSDL_URL(); // TODO to be parameterize. 
			String operationName = setting.getOPERATION_NAME(); // operation name // TODO to be parameterize.
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
			
			for(int i = 0; i < argumentsSize; i++) {
				MessagePartInfo mpi = opInfo.getInput().getMessagePart(i);
				
				Class<?> type_ = String.class; // 요거 멤버변수 별로 타입지정 가능해야 할듯.
				
				if(mpi.getTypeClass() == String.class) {
					params[i] = "KeyValue_" + (i+1);
				}else if(mpi.getTypeClass() == Integer.class || mpi.getTypeClass() == int.class) {
					params[i] = (i+1);
				}else {
					Object inst = mpi.getTypeClass().newInstance();
					// TODO 여기서 설정항목만큼 loop 돌면서 처리
					mpi.getTypeClass().getMethod(setting.getREQ_KEY1_METHOD(), type_).invoke(inst, "KEY_____1");
					mpi.getTypeClass().getMethod(setting.getREQ_KEY2_METHOD(), type_).invoke(inst, "KEY_____2");
					mpi.getTypeClass().getMethod(setting.getREQ_KEY3_METHOD(), type_).invoke(inst, "KEY_____3");
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
							if(setting.getRESULT_CODE_IDX() == rstIndex) {
								code = o.toString();
							}
							if(setting.getRESULT_MSG_IDX() == rstIndex) {
								msg = o.toString();
							}
						}else {
							throw new Exception("Not supported Response Type [ "+ o.getClass() +" ]");
						}
						rstIndex ++;
					}
				}else {
					Method codeGetter = rst.getClass().getMethod(setting.getRES_CODE_METHOD(), null);
					code = (String)codeGetter.invoke(rst, null);
					
					Method msgGetter = rst.getClass().getMethod(setting.getRES_MSG_METHOD(), null);
					msg = (String)msgGetter.invoke(rst, null);
				}
			}
			LOGGER.debug("Result Code[Apache CXF] : " + code);
			LOGGER.debug("Result Msg[Apache CXF] : " + msg);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			// FIXME Logger
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if(client != null) {
				try {
					client.close();
				} catch(NullPointerException e){
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					// FIXME Logger
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
	public String bindingParameters(Map<String, Object> params, String originalXml) {
		String replacedXml = originalXml;
		for(Map.Entry<String, Object> entry : params.entrySet()) {
			entry.setValue("<![CDATA["+entry.getValue()+"]]>");
		}
		replacedXml = StrSubstitutor.replace(originalXml, params);
		
		LOGGER.debug("=========== Parameter replaced XML");
		LOGGER.debug(replacedXml);
		
		return replacedXml;
	}
	
	public static class Settings {
		private String WSDL_URL = "";
		private String ENDPOINT_URL = "";
		private String OPERATION_NAME = "";
		private String RES_CODE_XPATH = "";
		private String RES_MSG_XPATH = "";
		private String RES_CODE_METHOD = "";	
		private String RES_MSG_METHOD = "";
		private String REQ_KEY1_METHOD = "";	
		private String REQ_KEY2_METHOD = "";
		private String REQ_KEY3_METHOD = "";
		private int RESULT_CODE_IDX = -1;
		private int RESULT_MSG_IDX = -1;
		
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
	}
	
	/*
	public static void main(String [] args) throws Exception {
		Settings setting = new Settings();
		setting.setWSDL_URL("http://localhost:8081/wstest/services/TestWebService?wsdl");
		setting.setENDPOINT_URL("http://localhost:8081/wstest/services/TestWebService");
		
		int testType = 4;
		if(1 == testType) {
			// String input , Object output
			setting.setOPERATION_NAME("changeState1");
			setting.setRES_CODE_XPATH("//*[local-name()='changeState1Response']/return/code");
			setting.setRES_MSG_XPATH("//*[local-name()='changeState1Response']/return/msg");
			// for CXF
			setting.setRES_CODE_METHOD("getCode");
			setting.setRES_MSG_METHOD("getMsg");
		}else if(2 == testType) {
			// String input(multiple), String array output
			setting.setOPERATION_NAME("changeState2");
			setting.setRES_CODE_XPATH("//*[local-name()='changeState2Response']/return[1]");
			setting.setRES_MSG_XPATH("//*[local-name()='changeState2Response']/return[2]");
			// for CXF
			setting.setRES_CODE_METHOD("");
			setting.setRES_MSG_METHOD("");
			setting.setRESULT_CODE_IDX(0);
			setting.setRESULT_MSG_IDX(1);
		}else if(3 == testType) {
			// String input, String output
			setting.setOPERATION_NAME("changeState3");
			setting.setRES_CODE_XPATH("//*[local-name()='changeState3Response']/return");
			setting.setRES_MSG_XPATH("//*[local-name()='changeState3Response']/return");
			// for CXF
			setting.setRES_CODE_METHOD("");
			setting.setRES_MSG_METHOD("");
		}else if(4 == testType) {
			// Object input, String output
			setting.setOPERATION_NAME("changeState4");
			setting.setRES_CODE_XPATH("//*[local-name()='changeState4Response']/return");
			setting.setRES_MSG_XPATH("//*[local-name()='changeState4Response']/return");
			// for CXF
			setting.setREQ_KEY1_METHOD("setKey1");
			setting.setREQ_KEY2_METHOD("setKey2");
			setting.setREQ_KEY3_METHOD("setKey3");
			setting.setRES_CODE_METHOD("");
			setting.setRES_MSG_METHOD("");
		}else if(5 == testType) {
			// String array input, Object output 
			// array input fixme when CXF Call
			setting.setOPERATION_NAME("changeState5");
			setting.setRES_CODE_XPATH("//*[local-name()='changeState5Response']/return/code");
			setting.setRES_MSG_XPATH("//*[local-name()='changeState5Response']/return/msg");
			// for CXF
			setting.setRES_CODE_METHOD("getCode");
			setting.setRES_MSG_METHOD("getMsg");
		}
		
		WSClientTest client = new WSClientTest(setting);
		client.processXml();
		
		long startTime = System.currentTimeMillis();
		client.processByWsdl();
		System.err.println("Process by WSDL(Dynamic class loader) : " + (System.currentTimeMillis() - startTime) + "ms");
		
		// One more.
		startTime = System.currentTimeMillis();
		client.processByWsdl();
		System.err.println("Process by WSDL(Dynamic class loader) - cached? : " + (System.currentTimeMillis() - startTime) + "ms");
		
		System.out.println(">>>>>>>>>>>>>>>>>> Successfully end main method.");
	}
	*/
}
