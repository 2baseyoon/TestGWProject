package egovframework.covision.coviflow.legacy.web;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.CDATASection;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.InputSource;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

@Controller
@RequestMapping("admin/legacySample")
public class LegacySampleCon {

	private static final Logger LOGGER = LogManager.getLogger(LegacySampleCon.class);
	
	@RequestMapping(value = "/restTest_json.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody ResponseEntity<CoviMap> restTestJson(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(value = "encoding", required = false) String encoding
			, @RequestParam(value = "erroryn", required = false) String erroryn
			, @RequestParam(value = "param1", required = false) String param1
			, @RequestParam(value = "param2", required = false) String str_param2
			, @RequestParam(defaultValue = "param3_default") String param3
			, @RequestParam(required = false) Map<String, String> paramMap
			, @RequestBody(required = false)  Map<String, String> paramBody) {
		CoviMap returnObj = new CoviMap();
		CoviMap statusObj = new CoviMap();
		CoviMap statusObj2 = new CoviMap();
		CoviList statusListObj = new CoviList();
		HttpHeaders httpHeaders= new HttpHeaders();
		String charset = "UTF-8";
		try {
			returnObj.put("encoding", encoding);
			returnObj.put("erroryn", erroryn);
			returnObj.put("param1", param1);
			returnObj.put("param2", str_param2);
			returnObj.put("param3", param3);
			returnObj.put("paramMap", paramMap);
			returnObj.put("paramBody", paramBody);
			
			if(encoding != null && !encoding.isEmpty()) {
				charset = encoding;
			}
			httpHeaders.setContentType(MediaType.valueOf("application/json;charset=" + charset));
			
			if(erroryn != null && erroryn.equals("Y")) throw new Exception("erroryn Error");
			
			// status
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "성공");
			// status obj
			statusObj.put("status", Return.SUCCESS);
			statusObj.put("message", "성공obj");
			returnObj.put("statusObj", statusObj);
			// status list
			statusObj.put("status", Return.SUCCESS);
			statusObj.put("message", "성공list");
			statusListObj.add(statusObj);
			statusObj2.put("status", Return.SUCCESS);
			statusObj2.put("message", "성공list2");
			statusListObj.add(statusObj2);
			returnObj.put("statusList", statusListObj);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			
			// status
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getMessage());
			// status obj
			statusObj.put("status", Return.FAIL);
			statusObj.put("message", "obj" + e.getMessage());
			returnObj.put("statusObj", statusObj);
			// status list
			statusObj.put("status", Return.FAIL);
			statusObj.put("message", "list" + e.getMessage());
			statusListObj.add(statusObj);
			statusObj2.put("status", Return.FAIL);
			statusObj2.put("message", "list2" + e.getMessage());
			statusListObj.add(statusObj2);
			returnObj.put("statusList", statusListObj);
			
			//return ResponseEntity.badRequest().body(returnObj); // 400
			return new ResponseEntity<CoviMap>(returnObj, httpHeaders, HttpStatus.INTERNAL_SERVER_ERROR); // 500 // BAD_REQUEST 400
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			
			// status
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getMessage());
			// status obj
			statusObj.put("status", Return.FAIL);
			statusObj.put("message", "obj" + e.getMessage());
			returnObj.put("statusObj", statusObj);
			// status list
			statusObj.put("status", Return.FAIL);
			statusObj.put("message", "list" + e.getMessage());
			statusListObj.add(statusObj);
			statusObj2.put("status", Return.FAIL);
			statusObj2.put("message", "list2" + e.getMessage());
			statusListObj.add(statusObj2);
			returnObj.put("statusList", statusListObj);
			
			//return ResponseEntity.badRequest().body(returnObj); // 400
			return new ResponseEntity<CoviMap>(returnObj, httpHeaders, HttpStatus.INTERNAL_SERVER_ERROR); // 500 // BAD_REQUEST 400
		}
		//return ResponseEntity.ok(returnObj); // 200
		return new ResponseEntity<CoviMap>(returnObj, httpHeaders, HttpStatus.OK); // 200
	}
	
	@RequestMapping(value = "/restTest_xml.do", method = { RequestMethod.GET,RequestMethod.POST }) // produces = "text/xml;charset=UTF-8"
	//public @ResponseBody ResponseEntity<Document> restTestXml(HttpServletRequest request, HttpServletResponse response
	//public @ResponseBody ResponseEntity<String> restTestXml(HttpServletRequest request, HttpServletResponse response
	//public @ResponseBody String restTestXml(HttpServletRequest request, HttpServletResponse response
	public void restTestXml(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(value = "encoding", required = false) String encoding
			, @RequestParam(value = "erroryn", required = false) String erroryn
			, @RequestParam(value = "param1", required = false) String param1
			, @RequestParam(value = "param2", required = false) String str_param2
			, @RequestParam(defaultValue = "param3_default") String param3
			, @RequestParam(required = false) Map<String, String> paramMap) throws Exception { 
			// , @RequestBody(required = false)  Object paramBody
		Document document = null;
		//HttpHeaders httpHeaders= new HttpHeaders();
		String charset = "UTF-8";
		String paramBody = "";
		BufferedReader br = null;
		try {
			StringBuilder stringBuilder = new StringBuilder();
	        String line = "";
	        InputStream inputStream = request.getInputStream();
            if (inputStream != null) {
                br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8));
                while ((line = br.readLine()) != null) {
                    stringBuilder.append(line);
                }
            }
            paramBody = stringBuilder.toString();

            // xml 파싱 빌드업
 			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
 			DocumentBuilder builder = factory.newDocumentBuilder();
 			
 			// document(xml) 생성
 			document = builder.newDocument();
 			
 			// root 생성 및 추가
 			Element root = document.createElement("rootNode");
 			root.setAttribute("rootAttr", "attr1");
 			document.appendChild(root);
 			
 			// 자식 노드 생성 및 추가(CDATA)
 			Element elm_encoding = document.createElement("encoding");
 			elm_encoding.setAttribute("encodingAttr", "attr2");
 			if(encoding != null) {
	 			//elm_encoding.setTextContent(encoding);
	 			CDATASection cdt_encoding = document.createCDATASection(encoding);
	 			elm_encoding.appendChild(cdt_encoding);
 			}
 			root.appendChild(elm_encoding);
 			
 			root.appendChild(makeNode(document, "erroryn", erroryn, true));
 			root.appendChild(makeNode(document, "param1", param1, true));
 			root.appendChild(makeNode(document, "param2", str_param2, true));
 			root.appendChild(makeNode(document, "param3", param3, true));
 			root.appendChild(makeNode(document, "paramMap", paramMap.toString(), true));
 			root.appendChild(makeNode(document, "paramBody", paramBody, false));
 			
 			if(encoding != null && !encoding.isEmpty()) {
 				charset = encoding;
 			}
 			//httpHeaders.setContentType(MediaType.valueOf("text/plain;charset=" + charset)); // application/xml , application/json , text/plain , text/html , text/xml
 			response.setContentType("application/xml;charset=" + charset.replaceAll("\r", "").replaceAll("\n", ""));
 			
 			if(erroryn != null && erroryn.equals("Y")) throw new Exception("erroryn Error");
 			
			// status
 			root.appendChild(makeNode(document, "status", Return.SUCCESS.toString(), false));
 			root.appendChild(makeNode(document, "message", "성공", false));
 			// status cdata
 			root.appendChild(makeNode(document, "statusC", Return.SUCCESS.toString(), true));
 			root.appendChild(makeNode(document, "messageC", "성공Cdata", true));
 			// status child
 			Element elm_child = document.createElement("statusChild");
 			elm_child.appendChild(makeNode(document, "status", Return.SUCCESS.toString(), false));
 			elm_child.appendChild(makeNode(document, "message", "성공child", false));
 			// status child cdata
 			elm_child.appendChild(makeNode(document, "statusC", Return.SUCCESS.toString(), true));
 			elm_child.appendChild(makeNode(document, "messageC", "성공childCdata", true));
 			root.appendChild(elm_child);
 			// status list
 			root.appendChild(makeNode(document, "statusList", Return.SUCCESS.toString(), false));
 			root.appendChild(makeNode(document, "messageList", "성공1", false));
 			root.appendChild(makeNode(document, "statusList", Return.SUCCESS.toString(), false));
 			root.appendChild(makeNode(document, "messageList", "성공2", false));
 			// status list cdata
 			root.appendChild(makeNode(document, "statusListC", Return.SUCCESS.toString(), true));
 			root.appendChild(makeNode(document, "messageListC", "성공3Cdata", true));
 			root.appendChild(makeNode(document, "statusListC", Return.SUCCESS.toString(), true));
 			root.appendChild(makeNode(document, "messageListC", "성공4Cdata", true));
 			
 			response.getWriter().write(convertDocumentToString(document));
		} catch(NullPointerException e){
			writeErrorResponse(e, document, response);
		} catch (Exception e) {
			writeErrorResponse(e, document, response);
		}finally {
			if(br != null) {
				br.close();
			}
		}
	}
	
	private void writeErrorResponse(Exception e, Document document, HttpServletResponse response) throws Exception {
		LOGGER.error(e.getLocalizedMessage(), e);

		// status
		document.getDocumentElement().appendChild(makeNode(document, "status", Return.FAIL.toString(), false));
		document.getDocumentElement().appendChild(makeNode(document, "message", e.getMessage(), false));
		// status cdata
		document.getDocumentElement().appendChild(makeNode(document, "statusC", Return.FAIL.toString(), true));
		document.getDocumentElement().appendChild(makeNode(document, "messageC", "Cdata"+e.getMessage(), true));
		// status child
		Element elm_child = document.createElement("statusChild");
		elm_child.appendChild(makeNode(document, "status", Return.FAIL.toString(), false));
		elm_child.appendChild(makeNode(document, "message", "child"+e.getMessage(), false));
		// status child cdata
		elm_child.appendChild(makeNode(document, "statusC", Return.FAIL.toString(), true));
		elm_child.appendChild(makeNode(document, "messageC", "childCdata"+e.getMessage(), true));
		document.getDocumentElement().appendChild(elm_child);
		// status list
		document.getDocumentElement().appendChild(makeNode(document, "statusList", Return.FAIL.toString(), false));
		document.getDocumentElement().appendChild(makeNode(document, "messageList", "1"+e.getMessage(), false));
		document.getDocumentElement().appendChild(makeNode(document, "statusList", Return.FAIL.toString(), false));
		document.getDocumentElement().appendChild(makeNode(document, "messageList", "2"+e.getMessage(), false));
		// status list cdata
		document.getDocumentElement().appendChild(makeNode(document, "statusListC", Return.FAIL.toString(), true));
		document.getDocumentElement().appendChild(makeNode(document, "messageListC", "3Cdata"+e.getMessage(), true));
		document.getDocumentElement().appendChild(makeNode(document, "statusListC", Return.FAIL.toString(), true));
		document.getDocumentElement().appendChild(makeNode(document, "messageListC", "4Cdata"+e.getMessage(), true));

		response.setStatus(500);
		response.getWriter().write(convertDocumentToString(document));
	}
	
	private Element makeNode(Document doc, String nodeName, String nodeValue, boolean bCdata) {
		Element elm_return = doc.createElement(nodeName);
		
		if(nodeName != null && nodeValue != null && !nodeName.isEmpty()) {
			if(bCdata) elm_return.appendChild(doc.createCDATASection(nodeValue));
			else elm_return.setTextContent(nodeValue);
		}
		
		return elm_return;
	}
	
	private static String convertDocumentToString(Document doc) {
        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer;
        try {
            transformer = tf.newTransformer();
            // below code to remove XML declaration
            // transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
    		// 들여 쓰기 있음
    		//transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            // 출력 시 문자코드: UTF-8
    		//transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String output = writer.getBuffer().toString();
            return output;
        } catch(NullPointerException e){
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (TransformerException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        }
        
        return null;
    }

    private static Document convertStringToDocument(String xmlStr) {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();  
        DocumentBuilder builder;  
        try  
        {  
            builder = factory.newDocumentBuilder();  
            Document doc = builder.parse( new InputSource( new StringReader( xmlStr ) ) ); 
            return doc;
        } catch(NullPointerException e){
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {  
        	LOGGER.error(e.getLocalizedMessage(), e);
        } 
        return null;
    }
    
}
