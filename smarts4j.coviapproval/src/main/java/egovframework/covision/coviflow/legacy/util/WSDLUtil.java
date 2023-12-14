package egovframework.covision.coviflow.legacy.util;

import java.io.StringWriter;

import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.endpoint.Endpoint;
import org.apache.cxf.jaxws.endpoint.dynamic.JaxWsDynamicClientFactory;
import org.apache.cxf.service.model.BindingOperationInfo;
import org.apache.cxf.service.model.MessagePartInfo;
import org.apache.cxf.service.model.OperationInfo;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.predic8.wsdl.Binding;
import com.predic8.wsdl.BindingOperation;
import com.predic8.wsdl.Definitions;
import com.predic8.wsdl.WSDLParser;
import com.predic8.wstool.creator.RequestTemplateCreator;
import com.predic8.wstool.creator.SOARequestCreator;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import groovy.xml.MarkupBuilder;

public class WSDLUtil {
	private final static Logger LOGGER = LogManager.getLogger();
	/**
	 * WSDL URL 로 Request 용 Envelope 템플릿 구하기. (com.predic8.wsdl) - License : Apache 2.0
	 * https://mvnrepository.com/artifact/com.predic8/soa-model-core
	 * 
	 * SOAP 연동 설정화면에서 Envelope XML 설정할 수 있도록 Template XML 을 조회한다.
	 * @param wsdlUrl
	 * @param portTypeName
	 * @param operationName
	 * @param bindingName
	 * @return
	 */
	public static String extractRequestSoapTemplates(String wsdlUrl, String portTypeName, String operationName, String bindingName, String soapActionHeader) {
		LOGGER.debug("================== Request Envelope template from WSDL Start ==================");
		long startTime = System.currentTimeMillis();
		
		// using package "com.predic8.wsdl"
	    WSDLParser parser = new WSDLParser();
	    Definitions wsdl = parser.parse(wsdlUrl);
	     
	    StringWriter writer = new StringWriter();
	     
	    //SOAPRequestCreator constructor: SOARequestCreator(Definitions, Creator, MarkupBuilder)
	    SOARequestCreator creator = new SOARequestCreator(wsdl, new RequestTemplateCreator(), new MarkupBuilder(writer));

	    // portType
	    String rPortType = portTypeName;
	    if(StringUtils.isEmpty(rPortType)) {
	    	rPortType = wsdl.getPortTypes().get(0).getName();
	    }
	    // Binding
	    String rBindingName = bindingName;
	    if(StringUtils.isEmpty(rBindingName)) {
	    	rBindingName = wsdl.getBindings().get(0).getName();
	    }
	    creator.createRequest(rPortType, operationName, rBindingName);
	 
	    Binding binding = wsdl.getBinding(rBindingName);
	    BindingOperation op = binding.getOperation(operationName);
	    
	    // BindingOperation 중 soapAction 값을 명시하지 않아야 하는 스펙이 있을 수 있음. 명세서대로 셋팅.
	    soapActionHeader = op.getOperation().getSoapAction(); 
	    
	    LOGGER.debug("================== Request Envelope template from WSDL End ==================");
	    LOGGER.debug(writer);
	    LOGGER.info("Get request envelope from WSDL URL : " + (System.currentTimeMillis() - startTime) + "ms");
	    
	    return writer.toString();
	    
	}
	
	/**
	 * apache CXF 방식 사용시 Request Object 에 대한 Template 제공
	 * @return
	 */
	public static CoviList parseRequestInfoByCxf(String wsdlURL, String operationName) {
		Client client = null;
		try {
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
			CoviList arguments = new CoviList();
			
			for(int i = 0; i < argumentsSize; i++) {
				MessagePartInfo mpi = opInfo.getInput().getMessagePart(i);
				
				CoviMap argumentInfo = new CoviMap();
				argumentInfo.put("Type", mpi.getTypeClass().getName()); // java.lang.String, java.lang.Integer.....
				argumentInfo.put("Value",  "");
				if(!mpi.getTypeClass().getName().startsWith("java.") && !mpi.getTypeClass().isPrimitive()) {
					Object inst = mpi.getTypeClass().newInstance();
					String result = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT).writeValueAsString(inst); // Object to JSON (jackson)
					argumentInfo.put("Value",  result);
				}
				arguments.add(argumentInfo);
			}
			
			return arguments;
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		}catch(Throwable t) {
			LOGGER.error(t.getLocalizedMessage(), t);
			return null;
		}finally {
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
}
