package egovframework.core.properties.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.properties.service.PropertiesMailManageSvc;
import egovframework.coviframework.util.ExcelUtil;


@Controller
public class PropertiesMailManageCon {
	
	private Logger LOGGER = LogManager.getLogger(PropertiesMailManageCon.class);
	
	@Autowired
	private PropertiesMailManageSvc propertiesMailManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@PostMapping("/propertiesMailManage/list.do")
	public @ResponseBody CoviMap list(
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "context", required = false, defaultValue="")	String context,
			@RequestParam(value = "input", required = false, defaultValue="")	String input) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			returnData = propertiesMailManageSvc.selectMailList(new CoviMap() {{
				this.put("dbType", dbType);
				this.put("wasType", wasType);
				this.put("context", context);
				this.put("input", input);
			}});
			
		} catch(NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "/propertiesMailManage/excelDown.do", method = RequestMethod.POST)
	public void excelDown(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "dbType",	required = false, defaultValue="")	String dbType,
			@RequestParam(value = "wasType", required = false, defaultValue="")	String wasType,
			@RequestParam(value = "context", required = false, defaultValue="")	String context,
			@RequestParam(value = "input", required = false, defaultValue="")	String input) throws Exception {
		
		SXSSFWorkbook resultWorkbook = null;
		
		try { 
			CoviMap params = new CoviMap();
			params.put("dbType", dbType);
			params.put("wasType", wasType);
			params.put("context", context);
			params.put("input", URLDecoder.decode(input, "UTF-8").replaceAll("&", "&amp;"));
			
			CoviList excelList = (CoviList) propertiesMailManageSvc.selectMailList(params).get("list");
			
			List<HashMap> colInfo = new ArrayList<HashMap>();	
			colInfo.add(new HashMap<String, String>() {{ put("colName", "location"); put("colWith", "150"); put("colKey", "location"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "key name"); put("colWith", "150"); put("colKey", "setkey"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "설정타입(가변/불변)"); put("colWith", "150"); put("colKey", "referenceValueType"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Reference Value"); put("colWith", "150"); put("colKey", "referencevalue"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Input Value"); put("colWith", "150"); put("colKey", "inputvalue"); }});
			colInfo.add(new HashMap<String, String>() {{ put("colName", "Description"); put("colWith", "250"); put("colKey", "description"); }});
			
			resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅_dbType:"+ dbType + ", wasType:"+wasType, colInfo, excelList);
			resultWorkbook = ExcelUtil.makeExcelFile("서버 설정 리포팅", colInfo, excelList);
			
			Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
			String FileName = "MailProperties_" + dateFormat.format(today);
			
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

}
