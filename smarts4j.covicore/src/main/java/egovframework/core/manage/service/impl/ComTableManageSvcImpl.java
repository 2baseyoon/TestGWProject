package egovframework.core.manage.service.impl;

import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.CoviThreadContextHolder;
import egovframework.core.manage.service.ComTableManageSvc;

import org.apache.commons.codec.binary.Base64;
import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.session.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ComTableManageSvcImpl")
public class ComTableManageSvcImpl extends EgovAbstractServiceImpl implements ComTableManageSvc{

	private static final Logger LOGGER = LogManager.getLogger(ComTableManageSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	// 로드시 저장된 공통테이블 쿼리 mybatis coviMapperOne cache 등록
	@PostConstruct
	@Override
	public void init() throws Exception {
		
		CoviList list = coviMapperOne.list("comtable.admin.selectComTableManageList", new CoviMap());
		String dbVendor = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		
		try {
			for (int i = 0; i < list.size(); i++) {
				CoviMap comTable = list.getMap(i);
				
				//comTable = base64ToUtf8(comTable, "QueryText");
				String xmldata = base64ToUtf8(comTable.optString("QueryText"));
				comTable.putOrigin("QueryText",xmldata); // 쿼리문 특수문자 유지
				if(!xmldata.isEmpty()) { // 빈값인 경우 로드하지 않음
					CoviMap queryInfo = convertQueryAndValidation(xmldata, comTable.optString("QueryNamespace"), dbVendor);
					if(queryInfo.optString("validationMsg").equals("")) {
						String convertXml = (queryInfo.get("convertXml") != null) ? queryInfo.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
						if(!convertXml.equals("")) {
							comTable.putOrigin("convertXml",convertXml); // 쿼리문 특수문자 유지
							putComTableQueryCache(comTable); // mybatis coviMapperOne cache 등록
							LOGGER.info("Success put comtable query to mybatis cache.");
						}
					}
				}
			}
		}catch(NullPointerException e) {
			LOGGER.info("Fail put comtable query to mybatis cache.");
			LOGGER.error(e.getLocalizedMessage(), e);
		}catch(Exception e) {
			LOGGER.info("Fail put comtable query to mybatis cache.");
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	@Override
	public CoviMap selectComTableManageList(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("comtable.admin.selectComTableManageListCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		
		list = coviMapperOne.list("comtable.admin.selectComTableManageList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectComTableManageData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("comtable.admin.selectComTableManageData", params);		
		CoviMap resultList = new CoviMap();		
		CoviList list = (CoviList)CoviSelectSet.coviSelectJSON(map);
		list = base64ToUtf8(list, "QueryText");
		resultList.put("map", list);	
		
		return resultList;
	}
	
	@Override
	public int insertComTableManageData(CoviMap params) throws Exception {
		return coviMapperOne.insert("comtable.admin.insertComTableManageData", params);
	}
	
	@Override
	public int updateComTableManageData(CoviMap params) throws Exception {
		return coviMapperOne.update("comtable.admin.updateComTableManageData", params);
	}
	
	@Override
	public int deleteComTableManageData(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("comtable.admin.deleteComTableManageData", params);
		cnt += coviMapperOne.delete("comtable.admin.deleteComTableField", params);
		
		return cnt;
	}
	
	@Override
	public String getComTableQuerySample(String dbVendor) throws Exception{
		InputStream is = null;
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();  
		DocumentBuilder builder;  
		String strSampleQuery = "";
		try  
		{  
			// 쿼리문 xml파일을 document로 로드
			Document doc = null;
			is = this.getClass().getClassLoader().getResourceAsStream("/sqlmap/sql/" + dbVendor + "/comtable_admin.xml");
			
			// dtd 사용불가(있으면 오류발생) - XML DOCTYPE 선언 비활성화
			/*
			factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
			*/
			
			// dtd 있어도 적용하지 않고 파싱
			/*
			factory.setValidating(false);
			factory.setNamespaceAware(true);
			factory.setFeature("http://xml.org/sax/features/namespaces", false);
			factory.setFeature("http://xml.org/sax/features/validation", false);
			factory.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar", false);
			factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
			factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
			factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
			*/
			
			builder = factory.newDocumentBuilder();
			
			// 특정 dtd만 허용
			builder.setEntityResolver(new EntityResolver() {
	            @Override
	            public InputSource resolveEntity(String publicId, String systemId)
	                    throws SAXException, IOException {
	            	if (publicId.equals("-//mybatis.org//DTD Mapper 3.0//EN") && systemId.contains("mybatis.org/dtd/mybatis-3-mapper.dtd")) { // <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://www.mybatis.org/dtd/mybatis-3-mapper.dtd">
	            		return null; // dtd적용
	                } else {
	                	return new InputSource(new ByteArrayInputStream("<?xml version='1.0' encoding='UTF-8'?>".getBytes(StandardCharsets.UTF_8))); // dtd무시
	                }
	            }
	        });
			
			doc = builder.parse(is); 
			
			XPath xpath = XPathFactory.newInstance().newXPath();
			Node nSampleQuery = (Node)xpath.compile("/mapper/select[@id='selectExampleList']").evaluate(doc, XPathConstants.NODE);
			//Node nSampleQuery = (Node) xpath.evaluate("/mapper/select[@id='selectExampleMysql']", doc, XPathConstants.NODE);
			//NodeList nSampleQuery = (NodeList)xpath.compile("/mapper/select[@id='selectExampleMysql']").evaluate(doc, XPathConstants.NODESET);
			strSampleQuery = convertDocumentToString(nSampleQuery);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} finally {
			if(is != null) is.close();
		}
		
		return strSampleQuery;
	}
	
	/**
	 * mybatis coviMapperOne cache에 등록된 쿼리를 실행하며, 아래 3가지 모두에서 사용됨
	 * [작성한 쿼리 테스트] , [쿼리기준 컬럼 불러오기] , [실제 리스트 쿼리]
	 * params_config : 쿼리 호출을 위한 정보(필드정보 불러오기 여부도 있음 isFieldInfo)
	 * params_query : 쿼리호출시 보내는 파라미터
	 */
	@Override
	public CoviMap execComTableQuery(CoviMap params_config, CoviMap params_query) throws Exception {				
		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		
		String namespace = params_config.optString("QueryNamespace");
		String queryId = params_config.optString("QueryId");
		String queryIdCnt = params_config.optString("QueryIdCnt");
		String isFieldInfo = params_config.optString("IsFieldInfo"); // 필드정보 조회 유무
		//String convertXml = (params_config.get("convertXml") != null) ? params_config.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
		String statementId = namespace + "." + queryId;
		String statementIdCnt = namespace + "." + queryIdCnt;
		
		String headerkey = params_config.optString("headerkey"); // 헤더키(엑셀저장시 사용)
		String comTableID = params_config.optString("ComTableID");
		
		try {
			if(headerkey.isEmpty()) { // 엑셀저장이 아닐때만 카운트쿼리
				// mssql은 페이징처리가 포함되있으므로, 카운트쿼리시 사이즈 무제한
				CoviMap params_cnt = new CoviMap(params_query);
				params_cnt.remove("pageNo");
				params_cnt.remove("pageSize");
				int listCnt = (int) coviMapperOne.getNumber(statementIdCnt, params_cnt);
				
				pagingData = ComUtils.setPagingData(params_query, listCnt);
				params_query.addAll(pagingData);
			}
			
			// 조회된 row가 없을때 필드정보 조회 위해
			// ibatis 환경에서 metadata 를 접근하려면 Intercepts 밖에 없음. 필요한 데이터를 꺼내기 위해 ThreadLocal 사용.
			// 1) mapper.select, mapper.list 호출전에 column 정보를 가져오기위해
			if(isFieldInfo.equalsIgnoreCase("Y")) CoviThreadContextHolder.setIsSaveColumnInfo(true);
			
			if(headerkey.isEmpty()) { // 엑셀저장이면 별도 데이터처리
				list = coviMapperOne.list(statementId, params_query);
				resultList.put("list", CoviSelectSet.coviSelectJSON(list));
				resultList.put("page", pagingData);
			}else {
				list = coviMapperOne.list(statementId, params_query);
				resultList.put("list", coviSelectJSON(list,headerkey,comTableID));
			}
			
			// 2) 호출후 조회한 쿼리기준으로 Column Info 를 조회한다 (ResultSet.getMetadata)
			if(isFieldInfo.equalsIgnoreCase("Y") && CoviThreadContextHolder.getCurrentColumnInfo() != null) {
            	// read metadata
            	List<Map<String, String>> metaData = CoviThreadContextHolder.getCurrentColumnInfo();
        		if(metaData != null) {
        			CoviList fieldInfoList = new CoviList();
        			int idx = 1;
        			for(Map<String, String> colInfo : metaData) {
        				// colInfo.get("columnName") , colInfo.get("columnLabel") , colInfo.get("columnType")
        				CoviMap fieldInfo = new CoviMap();
        				fieldInfo.put("SortKey",String.valueOf(idx));
        				fieldInfo.put("FieldID",colInfo.get("columnName"));
        				fieldInfo.put("FieldName",colInfo.get("columnName"));
        				fieldInfoList.add(fieldInfo);
        				idx++;
        			}
        			resultList.put("fieldList",fieldInfoList);
            	}
            }
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} finally {
			// ThreadLocal 사용후 반드시 Remove 처리한다!! (Thread Pool 환경에서 재활용이 가능하므로)
			CoviThreadContextHolder.remove();
		}

		return resultList;
	}
	
	@Override
	public int updateComTableQuery(CoviMap params) throws Exception {
		return coviMapperOne.update("comtable.admin.updateComTableQuery", params);
	}
	
	@Override
	public CoviMap selectComTableFieldData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("comtable.admin.selectComTableFieldData", params);		
			
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));	
		
		return resultList;
	}
	
	@Override
	public int insertComTableField(CoviMap params) throws Exception {
		return coviMapperOne.insert("comtable.admin.insertComTableField", params);
	}
	
	@Override
	public int updateComTableField(CoviMap params) throws Exception {
		return coviMapperOne.update("comtable.admin.updateComTableField", params);
	}
	
	@Override
	public int deleteComTableField(CoviMap params) throws Exception {
		return coviMapperOne.delete("comtable.admin.deleteComTableField", params);
	}
	
	@Override
	public int setComTableField(CoviMap params, CoviList fieldList, CoviList oldFieldKey) throws Exception {
		int cnt = 0;
		
		/*
		 * 1. 입력한 필드(fieldList)가 없으면 모두 delete
		 * 2. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 있는값이면 update
		 * 3. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 없는값이면 insert
		 * 4. 삭제된필드 모두 delete - 2번에서 업데이트된 기존필드정보는 삭제하므로, 기존 필드(oldFieldKey) 중 남아있는값 
		 */
		if(fieldList.size() == 0) { // 1. 입력한 필드(fieldList)가 없으면 모두 delete
			cnt += deleteComTableField(params); // by ComTableID
		}else {
			for (int i = 0; i < fieldList.size(); i++) {
				CoviMap field = fieldList.getMap(i);
				//field.put("ComTableID",comTableID);
				field.putAll(params);
				
				boolean existOldField = false;
				for (int j = 0; j < oldFieldKey.size(); j++) {
					String oldFieldId = (String)oldFieldKey.get(j);
					String newFieldId = field.optString("ComTableFieldID");
					if(newFieldId.equals(oldFieldId)) { // 2. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 있는값이면 update
						cnt += updateComTableField(field);
						existOldField = true;
						oldFieldKey.remove(j);
						break;
					}
				}
				// 3. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 없는값이면 insert
				if(!existOldField) cnt += insertComTableField(field);
			}
			// 4. 삭제된필드 모두 delete - 2번에서 업데이트된 기존필드정보는 삭제하므로, 기존 필드(oldFieldKey) 중 남아있는값 
			for (int j = 0; j < oldFieldKey.size(); j++) {
				String oldFieldId = (String)oldFieldKey.get(j);
				params.put("ComTableFieldID",oldFieldId);
				cnt += deleteComTableField(params); // by ComTableFieldID
			}
		}
		
		return cnt;
	}
	
	@Override
	public CoviMap selectComTableList(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("comtable.admin.selectComTableList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
	}
	
	
	
	
	// 엑셀저장인 경우 필드 설정에 따라 데이터 변경 및 헤더 설정
	// 기존 CoviSelectSet.coviSelectJSON 내용에서 데이터변경 추가
	public CoviMap coviSelectJSON(CoviList cList, String colName, String comTableID) throws Exception {
		
		String [] cols = StringUtil.replaceNull(colName).split(",");
		String lang = SessionHelper.getSession("lang");
		
		// 필드 설정정보 조회 후 key로 매핑 , 엑셀 헤더정보 셋팅
		CoviMap fieldConfig = new CoviMap(); // 필드 설정정보
		CoviList headerList = new CoviList(); // 엑셀 헤더정보
		CoviMap params = new CoviMap();		
		params.put("ComTableID", comTableID);
		CoviList fieldReturn = selectComTableFieldData(params).optJSONArray("list");
		for (int i = 0; i < fieldReturn.size(); i++) {
			CoviMap field = fieldReturn.getMap(i);
			String fieldID = field.optString("FieldID");
			if(Arrays.asList(cols).contains(fieldID)) {
				fieldConfig.put(fieldID, field);
				
				CoviMap header = new CoviMap();
				header.put("colName", DicHelper.getDicInfo(field.optString("FieldName"), lang));
				header.put("colWith", convertExcelWidth(field.optString("FieldWidth")));
				header.put("colKey", fieldID);
				header.put("colAlign", field.optString("FieldAlign").toUpperCase());
				if(field.optString("FieldDisplayType").equalsIgnoreCase("dateFormat")) header.put("colFormat", "DATETIME");
				headerList.add(header);
			}
		}
		
		CoviMap returnMap = new CoviMap();
		CoviList returnArray = new CoviList();
		
		if(null != cList && cList.size() > 0){
				for(int i=0; i<cList.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					for(int j=0; j<cols.length; j++){
						Iterator<String> iter = cList.getMap(i).keySet().iterator();
						
						while(iter.hasNext()){   
							Object key = iter.next();
							
							if(key.equals(cols[j].trim())){
								Object value = cList.getMap(i).getString(cols[j]);
								if(value == null){
									newObject.put(cols[j], "");
								} else{
									// 데이터변경 추가 부분
									//newObject.putJSONObject(cols[j], value);
									
									CoviMap field = fieldConfig.optJSONObject(cols[j]);
									
									// base64 decode여부
									if(field.optString("DecodeB64").equalsIgnoreCase("Y")) {
										value = base64ToUtf8(value.toString());
									}
									
									switch(field.optString("FieldDisplayType")) {
										case "dictionary": // 다국어 처리
											value = DicHelper.getDicInfo(value.toString(), lang);
											break;
										case "dateFormat": // 다국어 처리
											String strValue = value.toString();
											if(strValue.length() > 19) value = strValue.substring(0, 19);
											break;
										//case "json":
										//	break;
										default : 
											break;
									}
									
									newObject.putJSONObject(cols[j], value);
								}
							}
						}
					}
					
					returnArray.add(newObject);
				}
		}
		
		returnMap.put("execList",returnArray);
		returnMap.put("headerList",headerList);
		return returnMap;
	}
	
	// excel 넓이에 맞게 계산
	public String convertExcelWidth(String sWidth) {
		String rtn = sWidth;
		if(rtn != null && !rtn.isEmpty()) {
			Double dWidth = Double.parseDouble(rtn);
			int iWidth = (int)Math.ceil(dWidth*0.64); // 브라우저에서의 넓이보다 커지므로, 비율에 맞게 축소
			if(iWidth > 650) iWidth = 650; // 650이 넘으면 255(엑셀 최대넒이)로 고정됨 (1016px 이상이면)
			rtn = Integer.toString(iWidth);
		}
		return rtn;
	}
	
	// query 변환 및 validation
	@Override
	public CoviMap convertQueryAndValidation(String xmldata, String namespace, String dbVendor) throws Exception{
		CoviMap returnList = new CoviMap();		
		String validationMsg = "";
		String queryId = "";
		String queryIdCnt = "";
		String convertXml = "";
		
		
		// xml에 mapper namespace 추가
		StringBuilder buf = new StringBuilder();
		buf.append("<mapper namespace=\""+ namespace +"\">");
		buf.append(xmldata);
		buf.append("</mapper>");
		String fullXml = buf.toString();
				
		
		// String to xml(document) , xml Syntax 확인
		Document doc = null;
		try {
			doc = convertStringToDocument(fullXml); // string to xml
		} catch (NullPointerException e) {
			validationMsg = DicHelper.getDic("msg_xmlParsingError"); // 작성한 xml Syntax를 확인해 주세요.
			returnList.put("validationMsg", validationMsg);
			returnList.put("QueryId", queryId);
			returnList.put("QueryIdCnt", queryIdCnt);
			returnList.put("convertXml", convertXml);
			return returnList;
		} catch (IOException e) {
			validationMsg = DicHelper.getDic("msg_xmlParsingError"); // 작성한 xml Syntax를 확인해 주세요.
			returnList.put("validationMsg", validationMsg);
			returnList.put("QueryId", queryId);
			returnList.put("QueryIdCnt", queryIdCnt);
			returnList.put("convertXml", convertXml);
			return returnList;
		} catch (Exception e) {
			validationMsg = DicHelper.getDic("msg_xmlParsingError"); // 작성한 xml Syntax를 확인해 주세요.
			returnList.put("validationMsg", validationMsg);
			returnList.put("QueryId", queryId);
			returnList.put("QueryIdCnt", queryIdCnt);
			returnList.put("convertXml", convertXml);
			return returnList;
		}

		
		// select노드체크 , id/parameterType/resultType 속성체크 , query id 추출
		Element eRoot = doc.getDocumentElement();
		Node eSelect = (Node)eRoot.getFirstChild();
		NodeList nList = eRoot.getChildNodes();
		
		if(nList.getLength() == 1 && eSelect.getNodeName().equalsIgnoreCase("select")) {
			if(eSelect.getAttributes().getNamedItem("id") != null) {
				if(eSelect.getAttributes().getNamedItem("parameterType") != null && eSelect.getAttributes().getNamedItem("resultType") != null 
						&& eSelect.getAttributes().getNamedItem("parameterType").getNodeValue().equalsIgnoreCase("cmap")
						&& eSelect.getAttributes().getNamedItem("resultType").getNodeValue().equalsIgnoreCase("cmap")) {
					queryId = eSelect.getAttributes().getNamedItem("id").getNodeValue(); // getTextContent()
					queryIdCnt = queryId + "Cnt";
				}else {
					validationMsg = DicHelper.getDic("msg_inputParamResultType"); // parameterType, resultType 을 cmap으로 지정해주세요.
				}
			} else {
				validationMsg = DicHelper.getDic("msg_inputSelectNodeId"); // select 노드 id를 추가해 주세요.
			}
		} else {
			validationMsg = DicHelper.getDic("msg_inputOneSelectNode"); // 쿼리는 select 노드 1개만 등록 가능합니다.
		}
		
		if(!validationMsg.equals("")) {
			returnList.put("validationMsg", validationMsg);
			returnList.put("QueryId", queryId);
			returnList.put("QueryIdCnt", queryIdCnt);
			returnList.put("convertXml", convertXml);
			return returnList;
		}
		
		
		// 카운트 쿼리 노드 추가
		Node eCnt = (Node)eSelect.cloneNode(true);
		Text preCnt = doc.createTextNode(" SELECT count(1) FROM ( ");
		Text postCnt = doc.createTextNode(" ) TBL_CNT ");
		eCnt.insertBefore(preCnt, eCnt.getFirstChild());
		eCnt.appendChild(postCnt);
		eCnt.getAttributes().getNamedItem("id").setNodeValue(queryIdCnt);
		eCnt.getAttributes().getNamedItem("resultType").setNodeValue("java.lang.Long");
		eRoot.appendChild(eCnt);
		
		
		// 페이징 쿼리 노드 추가(리스트 쿼리 안에 추가)
		switch(dbVendor.toLowerCase()){
			case "mysql":
				Element ePaging = doc.createElement("if");
				ePaging.setTextContent(" LIMIT #{pageSize} OFFSET #{pageOffset} ");
				ePaging.setAttribute("test","pageSize != null and pageOffset != null");
				eSelect.appendChild(ePaging);
				break;
			case "oracle":
			case "tibero":
				Element ePagingPre = doc.createElement("include");
				ePagingPre.setAttribute("refid","oracle.include.pagingHeader");
				eSelect.insertBefore(ePagingPre,eSelect.getFirstChild());
				Element ePagingPost = doc.createElement("include");
				ePagingPost.setAttribute("refid","oracle.include.pagingFooter");
				eSelect.appendChild(ePagingPost);
				break;
			case "mssql":
				break;
		}
		
		
		// xml 상단 declaration 추가
		buf.setLength(0);
		buf.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		buf.append("<!DOCTYPE mapper PUBLIC \"-//mybatis.org//DTD Mapper 3.0//EN\" \"http://www.mybatis.org/dtd/mybatis-3-mapper.dtd\">");
		buf.append(convertDocumentToString(doc)); // xml to string
		convertXml = buf.toString();
		
		
		returnList.put("validationMsg", validationMsg);
		returnList.put("QueryId", queryId);
		returnList.put("QueryIdCnt", queryIdCnt);
		returnList.putOrigin("convertXml", convertXml); // 쿼리문 특수문자 유지
		return returnList;
	}
	
	// xml(Document) to string
	@Override
	public String convertDocumentToString(Object doc) throws TransformerException {
		TransformerFactory tf = TransformerFactory.newInstance();
		Transformer transformer;
		try {
			transformer = tf.newTransformer();
			// below code to remove XML declaration
			transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
			// 들여 쓰기 있음
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			// 출력 시 문자코드: UTF-8
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			StringWriter writer = new StringWriter();
			if(doc instanceof Element) transformer.transform(new DOMSource((Element)doc), new StreamResult(writer));
			else if(doc instanceof Node) transformer.transform(new DOMSource((Node)doc), new StreamResult(writer));
			else transformer.transform(new DOMSource((Document)doc), new StreamResult(writer));
			String output = writer.getBuffer().toString();
			return output;
		} catch (TransformerException e) {
			//e.printStackTrace();
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		}  catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} 
	}

	// string to xml(Document)
	@Override
	public Document convertStringToDocument(String xmlStr) throws Exception {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();  
		DocumentBuilder builder;  
		try  
		{  
			builder = factory.newDocumentBuilder();  
			
			// 특정 dtd만 허용
			builder.setEntityResolver(new EntityResolver() {
	            @Override
	            public InputSource resolveEntity(String publicId, String systemId)
	                    throws SAXException, IOException {
	            	if (publicId.equals("-//mybatis.org//DTD Mapper 3.0//EN") && systemId.contains("mybatis.org/dtd/mybatis-3-mapper.dtd")) { // <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://www.mybatis.org/dtd/mybatis-3-mapper.dtd">
	            		return null; // dtd적용
	                } else {
	                	return new InputSource(new ByteArrayInputStream("<?xml version='1.0' encoding='UTF-8'?>".getBytes(StandardCharsets.UTF_8))); // dtd무시
	                }
	            }
	        });
						
			Document doc = builder.parse( new InputSource(new StringReader(xmlStr)) ); 
			return doc;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			//e.printStackTrace();
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} 
	}
	
	// mybatis coviMapperOne cache 등록
	@Override
	public void putComTableQueryCache(CoviMap params_config) throws Exception {
		String namespace = params_config.optString("QueryNamespace");
		//String queryId = params_config.optString("QueryId");
		//String queryIdCnt = params_config.optString("QueryIdCnt");
		String convertXml = (params_config.get("convertXml") != null) ? params_config.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
		//String statementId = namespace + "." + queryId;
		//String statementIdCnt = namespace + "." + queryIdCnt;
		String mapperLocation = "covi-runtime-sql/" + namespace + ".xml";
		
		InputStream is = null;
		Configuration configuration = coviMapperOne.getSqlSessionFactory().getConfiguration();
		CoviMap returnData = new CoviMap();
		try {
			// 새로 등록
			is = new ByteArrayInputStream(convertXml.getBytes("UTF-8"));
			XMLMapperBuilder xmlMapperBuilder = new XMLMapperBuilder(is, configuration, mapperLocation, configuration.getSqlFragments());
			xmlMapperBuilder.parse();
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		}finally {
			if(is != null) is.close();
		}
	}
	
	// mybatis coviMapperOne cache 제거
	@Override
	public void removeComTableQueryCache(CoviMap params_config) throws Exception {
		String namespace = params_config.optString("QueryNamespace");
		String queryId = params_config.optString("QueryId");
		String queryIdCnt = params_config.optString("QueryIdCnt");
		//String convertXml = (params_config.get("convertXml") != null) ? params_config.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
		String statementId = namespace + "." + queryId;
		String statementIdCnt = namespace + "." + queryIdCnt;
		String mapperLocation = "covi-runtime-sql/" + namespace + ".xml";
		
		InputStream is = null;
		Configuration configuration = coviMapperOne.getSqlSessionFactory().getConfiguration();
		try {
			
			// 수정일경우 기존 쿼리등 mybatis cache 제거
			String[] mapFieldNames = new String[]{
				"mappedStatements", "caches",
				"resultMaps", "parameterMaps",
				"keyGenerators", "sqlFragments"
			};
			for (String fieldName: mapFieldNames){
				Field field = configuration.getClass().getDeclaredField(fieldName);
				field.setAccessible(true);
				Map<String, Object> map;
				try {
					map = ((Map<String, Object>)field.get(configuration));
					// Configuration$StrictMap 은 update 를 막아놨으므로 HashMap 으로 바꿔치기 해놓음.
					Map<String, Object> newMap = new HashMap<String, Object>();
					for(Map.Entry<String, Object> entry : map.entrySet()) {
						newMap.put(entry.getKey(), entry.getValue());
					}
					newMap.remove(statementId);
					newMap.remove(statementIdCnt);
					field.set(configuration, newMap);
				} catch (NullPointerException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
					throw e;
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
					throw e;
				}
			}
			
			//Clean up the loaded resource identifier so that it can be reloaded.
			Field loadedResourcesField = configuration.getClass().getDeclaredField("loadedResources");
			loadedResourcesField.setAccessible(true);
			Set loadedResourcesSet = ((Set)loadedResourcesField.get(configuration));
			loadedResourcesSet.remove(mapperLocation);
			// 캐시 제거 끝.
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		}finally {
			if(is != null) is.close();
		}
		
	}

	// base64 encode
	@Override
	public String utf8ToBase64(String strUtf8) throws Exception {
		strUtf8 = StringUtil.replaceNull(strUtf8, "");
		return new String(Base64.encodeBase64(strUtf8.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
	}
	
	// base64 decode
	@Override
	public CoviList base64ToUtf8(CoviList list, String target) throws Exception { // QueryText
		if(list != null ) {
			for (int i = 0; i < list.size(); i++) {
				CoviMap map = list.getMap(i);
				map = base64ToUtf8(map, target);
			}
		}
		return list;
	}
	@Override
	public CoviMap base64ToUtf8(CoviMap map, String target) throws Exception { // QueryText
		if(map != null ) {
			if(map.get(target) != null) {
				map.putOrigin(target,base64ToUtf8(map.optString(target))); // 쿼리문 특수문자 유지
			}
		}
		return map;
	}
	@Override
	public String base64ToUtf8(String strBase64) throws Exception {
		strBase64 = StringUtil.replaceNull(strBase64, "");
		return new String(Base64.decodeBase64(strBase64),StandardCharsets.UTF_8);
	}
	
}
