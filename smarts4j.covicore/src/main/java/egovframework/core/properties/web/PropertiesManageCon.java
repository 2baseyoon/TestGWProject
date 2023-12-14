package egovframework.core.properties.web;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesInfraSvc;
import egovframework.core.properties.service.PropertiesManageSvc;
import egovframework.core.properties.service.PropertiesEumtalkSvc;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.coviframework.util.FileUtil;


@Controller
@RequestMapping("/propertiesManage")
public class PropertiesManageCon {
	
	private static final Logger LOGGER = LogManager.getLogger(PropertiesManageCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	private PropertiesManageSvc propertiesManageSvc;
	
	@Autowired
	private PropertiesInfraSvc propertiesInfraSvc;
	
	@Autowired
	private PropertiesEumtalkSvc propertiesEumTalkSvc;
	
	/**
	 * 서버 설정 리포팅
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/propertiesManage.do") 
	public ModelAndView propertiesManage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		ModelAndView mav = new ModelAndView("core/propertiesManage/propertiesManage");
		
		try {
			// properties
			String propertiesJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesManage.js"));
			mav.addObject("propertiesJS", propertiesJS);
			String propertiesHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesManage.html"));
			mav.addObject("propertiesHTML", propertiesHTML);
			
			// context
			String contextJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesContextManage.js"));
			mav.addObject("contextJS", contextJS);
			String contextHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesContextManage.html"));
			mav.addObject("contextHTML", contextHTML);
			
			// mail
			String mailJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesMailManage.js"));
			mav.addObject("mailJS", mailJS);
			String mailHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesMailManage.html"));
			mav.addObject("mailHTML", mailHTML);
			
			// infra
			String infraJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesInfra.js"));
			mav.addObject("infraJS", infraJS);
			String infraHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesInfra.html"));
			mav.addObject("infraHTML", infraHTML);
			
			// eumtalk
			String eumtalkJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesEumtalk.js"));
			mav.addObject("eumtalkJS", eumtalkJS);
			String eumtalkHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesEumtalk.html"));
			mav.addObject("eumtalkHTML", eumtalkHTML);
						
			CoviMap params = new CoviMap();
			
			// DB Type 
			params.put("codeGroup", "property_dbtype");
			mav.addObject("dbList", propertiesManageSvc.selectCodeList(params));
			
			// Was Type
			params.put("codeGroup", "property_wasType");
			mav.addObject("wasList", propertiesManageSvc.selectCodeList(params));		
			
			// Properties Type
			params.put("codeGroup", "property_standardtype");
			params.put("reserved1", "Y");
			mav.addObject("propertiesList", propertiesManageSvc.selectCodeList(params));
			
			// Infra Properties Type
			params.put("codeGroup", "property_standardtype");
			params.put("reserved2", "Y");
			mav.addObject("propertiesInfraList", propertiesInfraSvc.selectCodeList(params));
			
			// Mail Properties Type
			params.put("codeGroup", "property_standardtype");
			params.put("reserved1", "M");
			mav.addObject("propertiesListMail", propertiesManageSvc.selectCodeList(params));
			
			// EumTalk Properties Type
			params.put("codeGroup", "property_standardtype");
			params.put("reserved1", "E");
			mav.addObject("propertiesEumTalkList", propertiesEumTalkSvc.selectCodeList(params));
			
			// Server List
			mav.addObject("serverList", propertiesManageSvc.selectServerList());
		} catch (NullPointerException e) {
			LOGGER.error("PropertiesManage error = {}"+ e.getMessage(), e);
		} catch (Exception e) {
			LOGGER.error("PropertiesManage error = {}"+ e.getMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * 목록 조회
	 * 
	 * @param request
	 * @param response
	 * @param isSaaS
	 * @param dbType
	 * @param wasType
	 * @param propertiesArray
	 * @param serverArray
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getProperties.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getProperties(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value="isSaaS", required=true) String isSaaS,
			@RequestParam(value="dbType", required=true) String dbType,
			@RequestParam(value="wasType", required=true) String wasType,
			@RequestParam(value="propertiesArray[]", required=false) String[] propertiesArray,
			@RequestParam(value="serverArray[]", required=false) String[] serverArray) throws Exception {

		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();

		try{			
			CoviMap params = new CoviMap();
			params.put("isSaaS", isSaaS);
			params.put("dbType", dbType);
			params.put("wasType", wasType);
			params.put("propertiesArray", propertiesArray);
			params.put("serverArray", serverArray);
			
			returnList = propertiesManageSvc.selectPropertiesList(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * 엑셀 다운로드
	 * 
	 * @param request
	 * @param response
	 * @param isSaaS
	 * @param dbType
	 * @param wasType
	 * @param propertiesArray
	 * @param serverArray
	 * @throws Exception
	 */
	@SuppressWarnings({ "serial", "rawtypes" })
	@RequestMapping(value = "/propertiesExcelDown.do", method = RequestMethod.POST)
	public void excelDown(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value="isSaaS", required=true) String isSaaS,
			@RequestParam(value="dbType", required=true) String dbType,
			@RequestParam(value="wasType", required=true) String wasType,
			@RequestParam(value="propertiesArray[]", required=false) String[] propertiesArray,
			@RequestParam(value="serverArray[]", required=false) String[] serverArray) throws Exception {
		
		SXSSFWorkbook resultWorkbook = null;
		 
		try { 
			CoviMap params = new CoviMap();
			params.put("isSaaS", isSaaS);
			params.put("dbType", dbType);
			params.put("wasType", wasType);
			params.put("propertiesArray", propertiesArray);
			params.put("serverArray", serverArray);
			 
			CoviList excelList = propertiesManageSvc.selectPropertiesList(params);
	
			List<HashMap> colInfo = new ArrayList<HashMap>();
			
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Properties Type"); put("colWith", "100"); put("colKey", "standardtype"); }});			 
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Key Name"); put("colWith", "150"); put("colKey", "setkey"); }});			 
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Reference Value"); put("colWith", "150"); put("colKey", "referenceValue"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "설정타입(가변/불변)"); put("colWith", "150"); put("colKey", "referenceValueType"); }});
			 
			for(int i = 0; i < serverArray.length; i++) {
				String colName = serverArray[i];
				String colKey = "serverIndex_"+i;
				 
				colInfo.add(new HashMap<String, String>() {{ put("colName", colName); put("colWith", "150"); put("colKey", colKey); }});
			}
			 
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Description"); put("colWith", "250"); put("colKey", "description"); }});
	        		
			resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅 (Properties)_isSaaS:"+ isSaaS + ", dbType:"+ dbType + ", wasType:"+wasType, colInfo, excelList);
			//resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅 (Properties)", colInfo, excelList);
			
			Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
			String FileName = "Properties_" + dateFormat.format(today);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\"" + FileName + ".xlsx\";");
			
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose();
			resultWorkbook.close();
		} catch(IOException ioe) {
	    	LOGGER.error(ioe.getLocalizedMessage(), ioe);
	    	
	    	response.reset();
			response.setContentType("text/html;charset=UTF-8");
			
	    	try (PrintWriter out = response.getWriter();){
        		out.println("out.println(\"<script language='javascript'>alert('오류가 발생하였습니다.'); history.back();</script>\");");
        	}
		} catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	
	    	response.reset();
			response.setContentType("text/html;charset=UTF-8");
			
	    	try (PrintWriter out = response.getWriter();){
        		out.println("out.println(\"<script language='javascript'>alert('오류가 발생하였습니다.'); history.back();</script>\");");
        	}
		} finally {
			if (resultWorkbook != null) {
				try {
					resultWorkbook.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
	}
	
	private String readJsFile(String filePath) throws IOException {
		return FileUtils.readFileToString(new java.io.File(FileUtil.checkTraversalCharacter(filePath)), StandardCharsets.UTF_8);
    }
}
