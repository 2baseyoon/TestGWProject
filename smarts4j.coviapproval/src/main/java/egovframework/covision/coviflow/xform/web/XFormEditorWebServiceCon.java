package egovframework.covision.coviflow.xform.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.coviflow.xform.service.XFormEditorWebServiceSvc;

/**
 * @Class Name : XFormEditorWebServiceCon.java
 * @Description : XForm 웹서비스 연동 관련 요청 처리
 * @2016.11.18 최초생성
 * 
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class XFormEditorWebServiceCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(XFormEditorWebServiceCon.class);

	@Autowired
	private XFormEditorWebServiceSvc xformEditorWebServiceSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getMethodList - WebService 함수 목록 죄
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getMethodList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMethodList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try	{
			String connectStr = request.getParameter("strConnectString");
			
			resultList = xformEditorWebServiceSvc.selectMethodList(connectStr);
			
			returnList.put("Table", resultList.get("Method"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * getParamList - WebService 파라미터 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getParamList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getParamList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try	{
			String connectStr = request.getParameter("strConnectString");
			String tableName = request.getParameter("strTableName");
			
			resultList = xformEditorWebServiceSvc.selectParamList(connectStr,tableName);
			
			
			returnList.put("Table", resultList.getJSONArray("Param"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getJSONList - xform webservice 예제를 위한 json 결과값 제공
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getJSONList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getJSONList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String jsonStr = "{\"Method\":[{\"NAME\":\"XFormViewLinkExam\"},{\"NAME\":\"XFormWriteLinkExam\"},{\"NAME\":\"BusinessJobInsert\"}],\"Param\":[{\"TABLE\":\"XFormViewLinkExam\",\"NAME\":\"Param\"},{\"TABLE\":\"XFormWriteLinkExam\",\"NAME\":\"XmlParam\"},{\"TABLE\":\"BusinessJobInsert\",\"NAME\":\"XmlParam\"}]}";
		CoviMap returnList = CoviMap.fromObject(jsonStr);
		
		return returnList;
	}
}
