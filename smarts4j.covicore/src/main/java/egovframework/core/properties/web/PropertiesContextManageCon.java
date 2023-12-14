package egovframework.core.properties.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
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
import org.springframework.web.bind.annotation.PostMapping;
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
import egovframework.core.properties.service.PropertiesContextManageSvc;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.coviframework.util.FileUtil;


@Controller
public class PropertiesContextManageCon {
	
	private static final Logger LOGGER = LogManager.getLogger(PropertiesContextManageCon.class);
	
	@Autowired
	private PropertiesContextManageSvc propertiesContextManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "/propertiesContextManage.do") 
	public ModelAndView propertiesContextManage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		ModelAndView mav = new ModelAndView("core/propertiesManage/propertiesContextManage");
		
		try {
			CoviMap params = new CoviMap();
			
			// DB Type 
			params.put("codeGroup", "property_dbtype");
			mav.addObject("dbList", propertiesContextManageSvc.selectCodeList(params));
			
			// Was Type
			params.put("codeGroup", "property_wasType");
			mav.addObject("wasList", propertiesContextManageSvc.selectCodeList(params));		
			
			// Properties Type
			params.put("codeGroup", "property_standardtype");
			params.put("reserved1", "Y");
			mav.addObject("propertiesList", propertiesContextManageSvc.selectCodeList(params));
			
			// Server List
			mav.addObject("serverList", propertiesContextManageSvc.selectServerList());
			
			String contextJS = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesContextManage.js"));
			mav.addObject("contextJS", contextJS);
			String contextHTML = readJsFile(request.getSession().getServletContext().getRealPath("/WEB-INF/views/core/propertiesManage/propertiesContextManage.html"));
			mav.addObject("contextHTML", contextHTML);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	@PostMapping("/propertiesContextManage/list.do")
	public @ResponseBody CoviMap list(
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "context", required = false, defaultValue="")	String context) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			returnData = propertiesContextManageSvc.selectContextList(new CoviMap() {{
				this.put("dbType", dbType);
				this.put("wasType", wasType);
				this.put("context", context);
			}});
		} catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "/propertiesContextManage/excelDown.do", method = RequestMethod.POST)
	public void excelDown(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "context", required = false, defaultValue="")	String context) throws Exception {
		
		SXSSFWorkbook resultWorkbook = null;
		
		try { 
			CoviMap params = new CoviMap();
			params.put("dbType", dbType);
			params.put("wasType", wasType);
			params.put("context", URLDecoder.decode(context, "UTF-8").replaceAll("&", "&amp;"));
			
			CoviList excelList = (CoviList) propertiesContextManageSvc.selectContextList(params).get("list");
			
			List<HashMap> colInfo = new ArrayList<HashMap>();
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Properties Type"); put("colWith", "150"); put("colKey", "standardtype"); }});			 
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Name"); put("colWith", "150"); put("colKey", "name"); }});			 
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Node Name"); put("colWith", "150"); put("colKey", "setkey"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "설정타입(가변/불변)"); put("colWith", "150"); put("colKey", "referenceValueType"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Reference Value"); put("colWith", "150"); put("colKey", "referencevalue"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Input Value"); put("colWith", "150"); put("colKey", "inputvalue"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Description"); put("colWith", "250"); put("colKey", "description"); }});
			
			
			resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅 (context.xml)_dbType:"+ dbType + ", wasType:"+wasType, colInfo, excelList);
			resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅 (context.xml)", colInfo, excelList);
			
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
		} 
	}
	
	private String readJsFile(String filePath) throws IOException {
		return FileUtils.readFileToString(new java.io.File(FileUtil.checkTraversalCharacter(filePath)), StandardCharsets.UTF_8);
    }
}
