package egovframework.core.manage.web;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.xml.sax.SAXException;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.core.manage.service.ComTableManageSvc;



@Controller
public class ComTableManageCon {
	
	private Logger LOGGER = LogManager.getLogger(ComTableManageCon.class);
	
	@Autowired
	private ComTableManageSvc comTableManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String dbVendor = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
	
	
	// 공통테이블관리 리스트조회
	@RequestMapping(value = "manage/getComTableManageList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComTableManageList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			String isUse = request.getParameter("IsUse");
			String searchType = request.getParameter("SearchType");
			String searchText = request.getParameter("SearchText");
			String companyCode = request.getParameter("CompanyCode");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			//params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("IsUse",ComUtils.RemoveSQLInjection(isUse, 100));
			params.put("CompanyCode",ComUtils.RemoveSQLInjection(companyCode, 100));
			//params.put("assignedDomain", ComUtils.getAssignedDomainID());
			params.put("SearchType",ComUtils.RemoveSQLInjection(searchType, 100));
			params.put("SearchText",ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = comTableManageSvc.selectComTableManageList(params);
			
			returnList.put("page",resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 공통테이블관리 상세 데이터 조회
	@RequestMapping(value = "manage/getComTableManageData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComTableManageData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String comTableID = request.getParameter("ComTableID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("ComTableID", comTableID);
			
			resultList = comTableManageSvc.selectComTableManageData(params);
			
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 공통테이블관리 추가/수정
	@RequestMapping(value = "manage/setComTableManageData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap setComTableManageData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String queryType = request.getParameter("QueryType");
			String companyCode = request.getParameter("CompanyCode");
			String comTableID = request.getParameter("ComTableID");
			String comTableName = request.getParameter("ComTableName");
			String sortKey = request.getParameter("SortKey");
			String isUse = request.getParameter("IsUse");
			String description = request.getParameter("Description");
			
			CoviMap params = new CoviMap();			
			params.put("CompanyCode", companyCode);
			params.put("ComTableID", comTableID);
			params.put("ComTableName", ComUtils.RemoveScriptAndStyle(comTableName));
			params.put("SortKey", sortKey);
			params.put("IsUse", isUse);
			params.put("Description", ComUtils.RemoveScriptAndStyle(description));
			params.put("UserCode",SessionHelper.getSession("USERID"));
			
			int cnt = 0;
			if("Edit".equalsIgnoreCase(queryType)) {
				cnt = comTableManageSvc.updateComTableManageData(params);
			}else if("Add".equalsIgnoreCase(queryType)) {
				cnt = comTableManageSvc.insertComTableManageData(params);
			}
			returnList.put("object", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 공통테이블관리 삭제
	@RequestMapping(value = "manage/deleteComTableManageData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteComTableManageData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String comTableID   = request.getParameter("ComTableID");
			
			CoviMap params = new CoviMap();			
			params.put("ComTableID",comTableID);
			
			returnList.put("object", comTableManageSvc.deleteComTableManageData(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 쿼리 샘플 불러오기
	@RequestMapping(value = "manage/getComTableQuerySample.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap getComTableQuerySample(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String sampleQuery = comTableManageSvc.getComTableQuerySample(dbVendor);
			
			returnList.putOrigin("query", sampleQuery); // 쿼리문 특수문자 유지
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 작성된 쿼리 테스트
	@RequestMapping(value = "manage/execComTableQueryCheck.do", method = { RequestMethod.POST })
	public @ResponseBody CoviMap execComTableQueryCheck(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception, IOException, ParserConfigurationException, SAXException, IllegalArgumentException {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultList = null;
			CoviMap paramsMap = new CoviMap(paramMap); // xmldata,pageNo,pageSize
			CoviMap params_config = new CoviMap();
			CoviMap params_query = new CoviMap();
			String xmldata = StringEscapeUtils.unescapeXml(request.getParameter("xmldata")); //params_config.optString("xmldata"); // 쿼리문 (특수문자 유지)
			String pageNo = Objects.toString(paramsMap.get("pageNo"), "1");
			String pageSize = Objects.toString(paramsMap.get("pageSize"), "10");
			String companyCode = paramsMap.optString("CompanyCode");
			
			// TEST용 namespace 명
			String namespace = java.util.UUID.randomUUID().toString();
			
			// query 변환 및 validation
			CoviMap queryInfo = comTableManageSvc.convertQueryAndValidation(xmldata, namespace, dbVendor);
			String validationMsg = queryInfo.optString("validationMsg");
			if(!validationMsg.equals("")) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", validationMsg);
				return returnList;
			}
			String queryId = queryInfo.optString("QueryId");
			String queryIdCnt = queryInfo.optString("QueryIdCnt");
			String convertXml = (queryInfo.get("convertXml") != null) ? queryInfo.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
			
			// 쿼리실행용 파라미터
			params_query.put("pageNo", pageNo);
			params_query.put("pageSize", pageSize);
			params_query.put("lang", SessionHelper.getSession("lang"));
			params_query.put("CompanyCode",ComUtils.RemoveSQLInjection(companyCode, 100));
			params_query.put("UserCode",SessionHelper.getSession("USERID"));
			
			// 쿼리설정용 파라미터
			params_config.put("QueryNamespace", namespace);
			params_config.put("QueryId", queryId);
			params_config.put("QueryIdCnt", queryIdCnt);
			params_config.putOrigin("convertXml", convertXml); // 쿼리문 특수문자 유지
			params_config.put("IsFieldInfo","N"); // 필드정보 조회 유무
			
			// mybatis coviMapperOne cache 등록
			comTableManageSvc.putComTableQueryCache(params_config);
			// 쿼리실행(데이터조회)
			resultList = comTableManageSvc.execComTableQuery(params_config, params_query);
			// mybatis coviMapperOne cache 제거
			comTableManageSvc.removeComTableQueryCache(params_config);
			
			returnList.put("page",resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 공통테이블 쿼리 수정
	@RequestMapping(value = "manage/setComTableQuery.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap setComTableQuery(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap paramsMap = new CoviMap(paramMap); // ComTableID,xmldata,OldNamespace,OldQueryId,OldQueryIdCnt
			CoviMap params_config = new CoviMap();
			String xmldata = StringEscapeUtils.unescapeXml(request.getParameter("xmldata")); //params_config.optString("xmldata"); // 쿼리문 (특수문자 유지)
			String comTableID = paramsMap.optString("ComTableID");
			String oldNamespace = paramsMap.optString("OldNamespace");
			String oldQueryId = paramsMap.optString("OldQueryId");
			String oldQueryIdCnt = paramsMap.optString("OldQueryIdCnt");
			boolean isNotBlank = StringUtils.isNotBlank(xmldata);
			
			// namespace 명(고정규칙)
			String namespace = "covi-runtimesql-" + comTableID;
						
			// query 변환 및 validation
			CoviMap queryInfo = new CoviMap();
			if(isNotBlank) { // 빈값인 경우 그대로 저장
				queryInfo = comTableManageSvc.convertQueryAndValidation(xmldata, namespace, dbVendor);
				String validationMsg = queryInfo.optString("validationMsg");
				if(!validationMsg.equals("")) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", validationMsg);
					return returnList;
				}
			}
			String queryId = queryInfo.optString("QueryId");
			String queryIdCnt = queryInfo.optString("QueryIdCnt");
			String convertXml = (queryInfo.get("convertXml") != null) ? queryInfo.get("convertXml").toString() : ""; // 쿼리문 특수문자 유지
			
			// 파라미터 셋팅
			params_config.put("QueryNamespace", ComUtils.RemoveScriptAndStyle(namespace));
			params_config.put("QueryId", ComUtils.RemoveScriptAndStyle(queryId));
			params_config.put("QueryIdCnt", ComUtils.RemoveScriptAndStyle(queryIdCnt));
			params_config.putOrigin("convertXml", ComUtils.RemoveScriptAndStyle(convertXml)); // 쿼리문 특수문자 유지
			params_config.put("originXml", comTableManageSvc.utf8ToBase64(ComUtils.RemoveScriptAndStyle(xmldata)));
			params_config.put("ComTableID", comTableID);
			params_config.put("UserCode",SessionHelper.getSession("USERID"));
			
			// 저장
			int cnt = comTableManageSvc.updateComTableQuery(params_config);
					
			// 이전 내용이 있는경우 mybatis coviMapperOne cache 제거
			if(!oldNamespace.isEmpty() && !oldQueryId.isEmpty() && !oldQueryIdCnt.isEmpty()){
				CoviMap paramsOld = new CoviMap();
				paramsOld.put("QueryNamespace", ComUtils.RemoveScriptAndStyle(namespace));
				paramsOld.put("QueryId", ComUtils.RemoveScriptAndStyle(queryId));
				paramsOld.put("QueryIdCnt", ComUtils.RemoveScriptAndStyle(queryIdCnt));
				paramsOld.putOrigin("convertXml", "");
				comTableManageSvc.removeComTableQueryCache(paramsOld);
			}
			
			//  mybatis coviMapperOne cache 제거
			comTableManageSvc.removeComTableQueryCache(params_config);
			// mybatis coviMapperOne cache 등록 (쿼리가 빈값이 아닌경우에만)
			if(isNotBlank) comTableManageSvc.putComTableQueryCache(params_config);
			
			returnList.put("object", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 공통테이블 필드 상세 데이터 조회
	@RequestMapping(value = "manage/getComTableFieldData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComTableFieldData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String comTableID = request.getParameter("ComTableID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("ComTableID", comTableID);
			
			resultList = comTableManageSvc.selectComTableFieldData(params);
			
			returnList.put("list", resultList.get("list"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 작성된 쿼리를 기준으로 공통테이블 필드 정보 조회
	@RequestMapping(value = "manage/getComTableFieldReset.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComTableFieldReset(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			CoviMap params_config = new CoviMap();
			CoviMap params_query = new CoviMap();
			
			String comTableID = request.getParameter("ComTableID");
			String pageNo = "1";
			String pageSize = "10";
			
			CoviMap resultList = null;
			params_config.put("ComTableID", comTableID);
			
			// 쿼리 호출 정보 조회
			CoviList manageReturn = comTableManageSvc.selectComTableManageData(params_config).optJSONArray("map");
			CoviMap manageData = manageReturn.getMap(0);
			
			params_config.put("QueryNamespace",manageData.optString("QueryNamespace"));
			params_config.put("QueryId",manageData.optString("QueryId"));
			params_config.put("QueryIdCnt",manageData.optString("QueryIdCnt"));
			params_config.put("IsFieldInfo","Y"); // 필드정보 조회 유무
			
			// 쿼리 파라미터
			params_query.put("pageNo", pageNo);
			params_query.put("pageSize", pageSize);
			params_query.put("lang", SessionHelper.getSession("lang"));
			params_query.put("CompanyCode",manageData.optString("CompanyCode"));
			params_query.put("UserCode",SessionHelper.getSession("USERID"));
			
			resultList = comTableManageSvc.execComTableQuery(params_config, params_query);
			
			returnList.put("list", resultList.get("fieldList"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 공통테이블 필드 수정(추가/삭제)
	@RequestMapping(value = "manage/setComTableField.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap setComTableField(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String comTableID = request.getParameter("ComTableID");
			String strFieldList = StringUtil.replaceNull(request.getParameter("FieldList"), "[]"); 
			String strOldFieldKey = StringUtil.replaceNull(request.getParameter("OldFieldKey"), "[]");
			
			CoviList fieldList = CoviList.fromObject(StringEscapeUtils.unescapeHtml(strFieldList)); // 입력받은 필드정보
			CoviList oldFieldKey = CoviList.fromObject(StringEscapeUtils.unescapeHtml(strOldFieldKey)); // 기존 필드정보
			
			int cnt = 0;
			CoviMap params = new CoviMap();
			params.put("ComTableID",comTableID);
			params.put("UserCode",SessionHelper.getSession("USERID"));
			
			cnt += comTableManageSvc.setComTableField(params, fieldList, oldFieldKey);
			
			returnList.put("object", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 공통 테이블 목록 조회 (콤보박스)
	@RequestMapping(value = "manage/getComTableList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getComTableList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap paramsMap = new CoviMap(paramMap); // CompanyCode,ComTableID
			String companyCode = paramsMap.optString("CompanyCode");
			String comTableID = paramsMap.optString("ComTableID");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			//params.put("lang", SessionHelper.getSession("lang"));
			params.put("CompanyCode",ComUtils.RemoveSQLInjection(companyCode, 100));
			//params.put("assignedDomain", ComUtils.getAssignedDomainID());
			params.put("ComTableID",ComUtils.RemoveSQLInjection(comTableID, 100));
			
			resultList = comTableManageSvc.selectComTableList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 공통 테이블 쿼리 실행(실제 데이터 조회)
	@RequestMapping(value = "manage/execComTableQuery.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap execComTableQuery(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			CoviMap params_config = new CoviMap();
			CoviMap params_query = new CoviMap();
			
			String comTableID = request.getParameter("ComTableID");
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			String searchType = request.getParameter("SearchType");
			String searchText = StringEscapeUtils.unescapeXml(Objects.toString(request.getParameter("SearchText"), "")); // unescapeHtml은 &apos; 변환이 안됨
			String companyCode = request.getParameter("CompanyCode");
			String icoSearch = StringEscapeUtils.unescapeXml(Objects.toString(request.getParameter("icoSearch"), ""));
			String headerkey = StringEscapeUtils.unescapeXml(Objects.toString(request.getParameter("headerkey"), "")); // 헤더키(엑셀저장시 사용)
			String comTableName = ""; // 엑셀저장시 상단 타이틀로 사용
						
			if(sortColumn != null && !sortColumn.isEmpty()) sortColumn = "sort_" +  sortColumn;
			if(searchType != null && !searchType.isEmpty()) searchType = "srch_" +  searchType;
			
			CoviMap resultList = null;
			params_config.put("ComTableID", comTableID);
			
			// 쿼리 호출 정보 조회
			CoviList manageReturn = comTableManageSvc.selectComTableManageData(params_config).optJSONArray("map");
			CoviMap manageData = manageReturn.getMap(0);
			
			params_config.put("QueryNamespace",manageData.optString("QueryNamespace"));
			params_config.put("QueryId",manageData.optString("QueryId"));
			params_config.put("QueryIdCnt",manageData.optString("QueryIdCnt"));
			params_config.put("IsFieldInfo","N"); // 필드정보 조회 유무
			params_config.put("headerkey",headerkey); // 헤더키(엑셀저장시 사용)
			comTableName = manageData.optString("ComTableName"); // 엑셀저장시 상단 타이틀로 사용
			
			// 쿼리 파라미터
			params_query.put("lang", SessionHelper.getSession("lang"));
			params_query.put("UserCode",SessionHelper.getSession("USERID"));
			params_query.put("CompanyCode",companyCode);
			params_query.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params_query.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params_query.put("SearchType",ComUtils.RemoveSQLInjection(searchType, 100));
			params_query.put("SearchText",ComUtils.RemoveSQLInjection(searchText, 100));
			params_query.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			if(headerkey.isEmpty()) { // 엑셀저장이 아닐때만 카운트쿼리
				params_query.put("pageNo", pageNo);
				params_query.put("pageSize", pageSize);
			}
			
			
			resultList = comTableManageSvc.execComTableQuery(params_config, params_query);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			if(headerkey.isEmpty()) { // 엑셀저장이 아닐때만 페이지 리턴
				returnList.put("page",resultList.get("page"));
			}else {
				returnList.put("ComTableName", comTableName);
			}
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 공통 테이블 쿼리 실행(실제 데이터 엑셀저장)
	@RequestMapping(value = "manage/execComTableQueryExcel.do", method=RequestMethod.GET)
	public void execComTableQueryExcel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		SXSSFWorkbook resultWorkbook = null;
		try {
			Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
			String FileName = "ComTableList"+dateFormat.format(today);
			String lang = SessionHelper.getSession("lang");
			
			CoviMap rtnMap = execComTableQuery(request, response, paramMap);
			String excelTitle = rtnMap.optString("ComTableName");
			CoviMap execMap = rtnMap.optJSONObject("list");
			
			CoviList excelList = execMap.optJSONArray("execList");
			CoviList headerList = execMap.optJSONArray("headerList");
			
			excelTitle = (excelTitle.isEmpty()) ? "ComTableList" : DicHelper.getDicInfo(excelTitle, lang);
					
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, headerList, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
			try {
				resultWorkbook.close();
			} catch (NullPointerException ex) {
				LOGGER.error(ex.getLocalizedMessage(), ex);
			} catch (Exception ignore) {
				LOGGER.error(ignore.getLocalizedMessage(), ignore);
			}

		}
		catch(IOException ioe) {
			LOGGER.error(ioe.getLocalizedMessage(), ioe);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) {LOGGER.error(ioe.getLocalizedMessage(), ioe);} catch (Exception e) { LOGGER.error(e.getLocalizedMessage(), e); } }
		}
	}
	
	
	
	
	
	// 공통 테이블 추가/수정 팝업
	@RequestMapping(value = "/manage/goComTableManagePop.do", method = RequestMethod.GET)
	public ModelAndView goComTableManage() {
		String rtnUrl = "manage/comtable/ComTableManagePop";
		return new ModelAndView(rtnUrl);
	}
	
	// 쿼리설정 팝업
	@RequestMapping(value = "/manage/goComTableQueryPop.do", method = RequestMethod.GET)
	public ModelAndView goComExecQuery() {
		String rtnUrl = "manage/comtable/ComTableQueryPop";
		ModelAndView mav = new ModelAndView(rtnUrl);
		mav.addObject("dbVendor", dbVendor);
		return mav;
	}
		
	// 필드매핑 팝업
	@RequestMapping(value = "/manage/goComTableFieldPop.do", method = RequestMethod.GET)
	public ModelAndView goComField() {
		String rtnUrl = "manage/comtable/ComTableFieldPop";
		return new ModelAndView(rtnUrl);
	}

}
