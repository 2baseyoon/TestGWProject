package egovframework.core.manage.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.core.common.enums.SyncObjectType;
import egovframework.core.sevice.LocalBaseSyncSvc;


import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.SysBaseConfigSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : SysBaseConfigCon.java
 * @Description : 시스템 - 기초설정관리
 * @Modification Information 
 * @ 2016.04.07 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("manage")
public class BaseConfigManageCon {

	private Logger LOGGER = LogManager.getLogger(BaseConfigManageCon.class);
	
	@Autowired
	private SysBaseConfigSvc sysBaseConfigSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getDataBaseConfig : 시스템 관리 - 기초설정 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseConfig/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String domain = request.getParameter("domain");
			String configtype = request.getParameter("configtype");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("configtype", configtype);
			params.put("isuse", "Y");
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			
			if (request.getParameter("configTypeArray") != null) {
				params.put("configTypeArray", request.getParameter("configTypeArray").split(","));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if(StringUtil.replaceNull(domain).isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			resultList = sysBaseConfigSvc.select(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	 //@Override
	 @RequestMapping(value = "baseConfig/excelDown.do")
	 public void excelDown(HttpServletResponse response, HttpServletRequest request) {
		 SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "BaseConfig"+dateFormat.format(today);
	
			CoviMap params = new CoviMap();
			String domain = request.getParameter("domain");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			String configtype = request.getParameter("configtype");
			String sortColumn = request.getParameter("sortKey");
			String sortDirection = request.getParameter("sortWay");
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("configtype", configtype);
			params.put("isuse", "Y");
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			if (request.getParameter("configTypeArray") != null) {
				params.put("configTypeArray", request.getParameter("configTypeArray").split(","));
			}
			
			CoviMap list = (CoviMap)sysBaseConfigSvc.select(params);
			CoviList excelList = (CoviList)list.get("list");
	
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_BizSection")); put("colWith","100"); put("colKey","BizSectionName");  put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_SettingKey")); put("colWith","150"); put("colKey","SettingKey"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_SettingValue")); put("colWith","200"); put("colKey","SettingValue");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ConfigName")); put("colWith","200"); put("colKey","ConfigName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Description")); put("colWith","300"); put("colKey","Description");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Register")); put("colWith","80"); put("colKey","RegisterName"); put("colAlign","CENTER");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ModifyDate")); put("colWith","100"); put("colKey","ModifyDate"); put("colAlign","CENTER"); }});
			String excelTitle= DicHelper.getDic("lbl_task_setting");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
			try {
				resultWorkbook.close();
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception ignore) {
				LOGGER.error(ignore.getLocalizedMessage(), ignore);
			}
	    } 
	    catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	    catch(IOException ioe) {
	    	LOGGER.error(ioe.getLocalizedMessage(), ioe);
	    }
	    catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	        if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) {LOGGER.error(ioe.getLocalizedMessage(), ioe);} catch (Exception e) { LOGGER.error(e.getLocalizedMessage(), e); } }
	    }
	}
}
