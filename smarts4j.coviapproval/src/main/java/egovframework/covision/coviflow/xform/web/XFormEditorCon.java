package egovframework.covision.coviflow.xform.web;

import java.util.Map;
import java.net.URLDecoder;
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
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.xform.service.XFormEditorSvc;

/**
 * @Class Name : XFormEditorCon.java
 * @Description : XForm 기본 기능 요청 처리 (양식, 템플릿 저장, 삭제, 조회 등)
 * @2016.11.14 최초생성
 * 
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class XFormEditorCon {

	private static final Logger LOGGER = LogManager.getLogger(XFormEditorCon.class);

	@Autowired
	private XFormEditorSvc xformEditorSvc;

	@Autowired
	public FormSvc formSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getFormList - 양식 리스트를 가져온다.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getFormList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try	{
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
			if("Y".equals(isSaaS)) {
				paramMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			}
			resultList = xformEditorSvc.selectFormList(paramMap);
			
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
	
	/**
	 * getFormFile - 특정 양식의 html과 javascript 내용을 가져온다. 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getFormFile.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFormFile(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			String htmlFileName = request.getParameter("htmlFileName");
			String jsFileName = request.getParameter("jsFileName");
			
			CoviMap paramsForms = new CoviMap();
			paramsForms.put("userID", SessionHelper.getSession("UR_Code"));
			paramsForms.put("formID", request.getParameter("formID"));
			
			String formCompanyCode = "";
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
			if("Y".equals(isSaaS)) {
				CoviMap forms = (((CoviList)(formSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
				formCompanyCode = forms.optString("CompanyCode");
			}
			
			String htmlStr = xformEditorSvc.getHTMLFormFile(FileUtil.checkTraversalCharacter(htmlFileName), formCompanyCode);
			String jsStr = xformEditorSvc.getJSFormFile(FileUtil.checkTraversalCharacter(jsFileName), formCompanyCode);
			
			returnList.put("htmlStr", htmlStr);
			returnList.put("jsStr", jsStr);
			
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
	 * createFormFile - [저장 버튼 클릭] 특정 양식의 html과 javascript 정보를 저장한다. 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/createFormFile.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createFormFile(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			String htmlFileName = request.getParameter("htmlFileName");
			String htmlFileContent = request.getParameter("htmlFileContent");
			String jsFileName = request.getParameter("jsFileName");
			String jsFileContent = request.getParameter("jsFileContent");
			htmlFileContent = URLDecoder.decode(htmlFileContent, "utf-8"); // 인코딩된 html 디코딩
			
			CoviMap paramsForms = new CoviMap();
			paramsForms.put("userID", SessionHelper.getSession("UR_Code"));
			paramsForms.put("formID", request.getParameter("formID"));
			
			String formCompanyCode = "";
			String formDomainID = "";
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
			if("Y".equals(isSaaS)) {
				CoviMap forms = (((CoviList)(formSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
				formCompanyCode = forms.optString("CompanyCode");
				formDomainID = forms.optString("DomainID");
			}
			
			String createHtmlResult = xformEditorSvc.createHTMLFormFile(FileUtil.checkTraversalCharacter(htmlFileName),htmlFileContent, formCompanyCode, formDomainID);
			String createJSResult = xformEditorSvc.createJSFormFile(FileUtil.checkTraversalCharacter(jsFileName), jsFileContent, formCompanyCode, formDomainID);
			
			returnList.put("htmlResult", createHtmlResult);
			returnList.put("jsResult", createJSResult);
			
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
	 * templateHtmlFn - XForm 에서 자주 사용되는 템플릿 저장/삭제/조회/목록 조회 작업 (작업 구분값: mode)
	 * mode : LIST(목록조회), SELECT(특정 템플릿 HTML 데이터 조회), INSERT(템플릿 저장), DELETE(템플릿 삭제)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/templateHtmlFn.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap templateHtmlFn(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			String mode = request.getParameter("mode");
			String templateID = request.getParameter("templateID");
			String templateName = request.getParameter("templateName");
			String templateHTML = request.getParameter("templateHTML");
			
			CoviMap params = new CoviMap();
			params.put("templateID", templateID);
			params.put("templateName", templateName);
			params.put("templateHTML", templateHTML);
			
			String templateResult = xformEditorSvc.setTemplate(mode, params);
			
			returnList.put("templateResult", templateResult);
			
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
	 * getEncrypt - DB 연결 정보 암호화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "xform/getEncrypt.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getEncrypt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			String encryptStr = request.getParameter("pSettingValue");
			
			String encrypt = xformEditorSvc.getEncrypt(encryptStr);
					
			returnList.put("encryptStr",encrypt);
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
	
	/*
	public static void main(String ... args ) throws Exception  {
		System.out.println("2023.05.19_10.00".compareTo("2023.05.22_09.30"));
		System.out.println("2023.05.19_10.00".compareTo("2023.05.19_10.30"));
		System.out.println("2023.05.19_10.00".compareTo("2023.05.19_09.30"));
		System.out.println("2023.05.19_10.00".compareTo("2023.05.19_10.00"));
	}
	*/
}
