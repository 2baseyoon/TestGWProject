package egovframework.covision.groupware.collab.user.web;


import java.io.IOException;
import java.text.SimpleDateFormat;
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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.covision.groupware.collab.user.service.CollabHistSvc;

@Controller
@RequestMapping("collabHist")
public class CollabHistCon {
	
	private Logger LOGGER = LogManager.getLogger(CollabHistCon.class);
	LogHelper logHelper = new LogHelper();
	
	@Autowired
	CollabHistSvc collabHistSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
		* @Method Name : getTaskHistList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 오청목록조회
		* @param request 
		* @param response
		* @return
		* @throws Exception
	@RequestMapping(value = "/addTaskSimple.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTaskSimple(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		*/
	@RequestMapping(value = "getTaskHistList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTaskHistList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			String sortBy = request.getParameter("sortBy");
			String sortColumn = StringUtil.isNotNull(sortBy) ? sortBy.split(" ")[0] : "";
			String sortDirection = StringUtil.isNotNull(sortBy) ? sortBy.split(" ")[1] : "";
			
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("modItem", request.getParameter("modItem"));
			params.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			params.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			
			if (request.getParameter("trgUser") != null && !request.getParameter("trgUser").equals("")){
				params.put("trgUser", request.getParameter("trgUser").split(","));
			}	
			if (request.getParameter("trgProject") != null && !request.getParameter("trgProject").equals("")){
				params.put("trgProject", request.getParameter("trgProject").split(","));
			}
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = collabHistSvc.getTaskHistList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	 //@Override
	 @RequestMapping(value = "/excelTaskHistLis.do")
	 public void excelTaskHistLis(HttpServletRequest request, HttpServletResponse response) {
		 SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "CollabHist"+dateFormat.format(today);
	
	        HashMap<String,Object> pars = new HashMap<>();
	        CoviMap params = new CoviMap();
			

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("modItem", request.getParameter("modItem"));
			params.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			params.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			
			if (request.getParameter("trgUser") != null && !request.getParameter("trgUser").equals("")){
				params.put("trgUser", request.getParameter("trgUser").split(","));
			}	
			if (request.getParameter("trgProject") != null && !request.getParameter("trgProject").equals("")){
				params.put("trgProject", request.getParameter("trgProject").split(","));
			}
			
			CoviMap resultList = new CoviMap();
			resultList = collabHistSvc.getTaskHistList(params);
			
			CoviList excelList = (CoviList)resultList.get("list");
	
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_EventDate")); put("colWith","150"); put("colKey","RegisteDate"); put("colAlign","CENTER"); put("colFormat","DATETIME");  }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_apv_modiuser")); put("colWith","80"); put("colKey","RegisterName"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TaskName")); put("colWith","200"); put("colKey","TaskName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ItemName")); put("colWith","70"); put("colKey","ModItemName"); put("colAlign","CENTER");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_eventtype")); put("colWith","70"); put("colKey","ModTypeName"); put("colAlign","CENTER");  }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_BeforeChange")); put("colWith","250"); put("colKey","BfValName");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_change")); put("colWith","250"); put("colKey","AfValName");  }});
			String excelTitle = DicHelper.getDic("lbl_apv_chglog");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	        if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}


}
