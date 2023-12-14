package egovframework.covision.groupware.collab.user.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.covision.groupware.collab.user.service.CollabCommonSvc;
import egovframework.covision.groupware.collab.user.service.CollabStatisSvc;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;

import org.apache.poi.xssf.streaming.SXSSFWorkbook;

import java.util.Date;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.HashMap;

// 협업 스페이스 
@Controller
@RequestMapping("collabStatis")
public class CollabStatisCon {
	@Autowired
	private CollabStatisSvc collabStatisSvc;
	
	@Autowired
	private CollabProjectSvc collabProjectSvc;
	
	@Autowired
	private CollabCommonSvc collabCommonSvc;

	private Logger LOGGER = LogManager.getLogger(CollabCommonCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		

	//프로젝트 조회
	@RequestMapping(value = "getStatisList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getStatisList(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("inClose", request.getParameter("isClose"));
			
			reqMap.put("seValue", request.getParameter("searchText"));
			if (request.getParameter("prjStatus") != null && !request.getParameter("prjStatus").equals("")){
				
				reqMap.put("prjStatus", request.getParameter("prjStatus").split(","));
			}

			CoviMap returnMap = collabStatisSvc.getStatisList(reqMap);
					
			returnObj.put("page",  returnMap.get("page"));
			returnObj.put("list",  returnMap.get("prjList"));
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}
	//프로젝트 excel
	@RequestMapping(value = "exportStatisList.do")
	public  void exportStatisList(HttpServletRequest request, HttpServletResponse response) throws Exception {
	    SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
			
	        String FileName = "CollabProjectList"+dateFormat.format(today);
	        
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("inClose", request.getParameter("isClose"));
			
			reqMap.put("seValue", request.getParameter("searchText"));
			if (request.getParameter("prjStatus") != null && !request.getParameter("prjStatus").equals("")){
				
				reqMap.put("prjStatus", request.getParameter("prjStatus").split(","));
			}

			CoviMap returnMap = collabStatisSvc.getStatisList(reqMap);
			List<HashMap> excelList = (List<HashMap>)returnMap.get("prjList");
			HashMap statusCode = new HashMap<String, String>() {{put("W",DicHelper.getDic("lbl_Ready")); put("P",DicHelper.getDic("lbl_Progress")); put("H",DicHelper.getDic("lbl_Hold")); put("C",DicHelper.getDic("lbl_Completed"));}};
					
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_project_name")); put("colWith","150"); put("colKey","PrjName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Memo")); put("colWith","200"); put("colKey","Remark"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_apv_Admin")); put("colWith","70"); put("colKey","MmUser"); put("colAlign","CENTER"); put("colFormat","USERCOUNT");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_startdate")); put("colWith","70"); put("colKey","StartDate"); put("colAlign","CENTER"); put("colFormat","DATE"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_EndDate")); put("colWith","70"); put("colKey","EndDate"); put("colAlign","CENTER"); put("colFormat","DATE"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TFTotalCount")); put("colWith","50"); put("colKey","TmUserCnt"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_Status")); put("colWith","50"); put("colKey","PrjStatus"); put("colAlign","CENTER");put("colFormat","CODE");put("colCode",statusCode); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ProgressRate")); put("colWith","50"); put("colKey","ProgRate"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_RegDate")); put("colWith","100"); put("colKey","RegisteDate"); put("colAlign","CENTER");put("colFormat","DATETIME");  }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TaskClose")); put("colWith","100"); put("colKey","CloseDate");put("colAlign","CENTER");put("colFormat","DATETIME");   }});
			String excelTitle = DicHelper.getDic("lbl_project_dashboard");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose();
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	    	if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}
	
	//타스트 상세 화면
	@RequestMapping(value = "/CollabStatisDetailPopup.do")
	public ModelAndView collabStatisDetailPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabStatisDetailPopup";
		CoviMap reqMap = new CoviMap();
		reqMap.put("prjType", request.getParameter("prjType"));
		reqMap.put("prjSeq", Integer.parseInt(request.getParameter("prjSeq")));
		CoviMap data = collabProjectSvc.getProjectStat(reqMap);

		ModelAndView mav		= new ModelAndView(returnURL);
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjData",data.get("prjData"));
		mav.addObject("prjStat",data.get("prjStat"));


		return mav;
	}
	
	//프로젝트 상세 조회
	@RequestMapping(value = "getCurstList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getCurstList(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("groupBy", request.getParameter("groupBy"));
			reqMap.put("searchKeyword", request.getParameter("searchKeyword"));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			reqMap.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			reqMap.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			CoviMap returnMap = collabStatisSvc.getStatisCurst(reqMap);
					
			returnObj.put("page",  returnMap.get("page"));
			returnObj.put("list",  returnMap.get("prjList"));
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}
	
	//프로젝트 상태상세 엑셀
	@RequestMapping(value = "exportCurstList.do")
	public  void exportCurstList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
			
	        String FileName = "CollabProjectList"+dateFormat.format(today);
	        
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("groupBy", request.getParameter("groupBy"));
			reqMap.put("searchKeyword", request.getParameter("searchKeyword"));

			CoviMap returnMap = collabStatisSvc.getStatisCurst(reqMap);
			List<HashMap> excelList = (List<HashMap>)returnMap.get("prjList");
			HashMap statusCode = new HashMap<String, String>() {{put("W",DicHelper.getDic("lbl_Ready")); put("P",DicHelper.getDic("lbl_Progress")); put("H",DicHelper.getDic("lbl_Hold")); put("C",DicHelper.getDic("lbl_Completed"));}};
					
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_name")); put("colWith","150"); put("colKey","GroupName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TotalNumber")); put("colWith","80"); put("colKey","TotCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Ready")); put("colWith","80"); put("colKey","WaitCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Progress")); put("colWith","80"); put("colKey","ProcCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Hold")); put("colWith","80"); put("colKey","HoldCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Completed")); put("colWith","80"); put("colKey","CompCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Delay")); put("colWith","80"); put("colKey","DelayCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Urgency")); put("colWith","80"); put("colKey","EmgCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Important")); put("colWith","80"); put("colKey","ImpCnt"); put("colAlign", "CENTER");put("colType", "I");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TFProgressing")); put("colWith","80"); put("colKey","ProcRate"); put("colAlign", "CENTER");put("colType", "F");}});
			
			String excelTitle = "["+request.getParameter("prjName")+"] "+DicHelper.getDic("lbl_TFProgressing");
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose();
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	    	if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}
	
	//사용자별 현황--칸반형태로 
	@RequestMapping(value = "getStatisUserData.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getStatisUserData(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("groupPath", request.getParameter("groupPath"));
			reqMap.put("mode", request.getParameter("mode"));
			reqMap.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			reqMap.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			reqMap.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			CoviMap returnMap = collabStatisSvc.getStatisUserData(reqMap);
					
			returnObj.put("taskData",    returnMap.get("taskData"));
			returnObj.put("taskFilter",  returnMap.get("taskFilter"));
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}
	//사용자별 현황
	@RequestMapping(value = "getStatisUserCurst.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getStatisUserCurst(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("groupPath", request.getParameter("groupPath"));
			reqMap.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			reqMap.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			reqMap.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			CoviMap returnMap = collabStatisSvc.getStatisUserCurst(reqMap);
					
			returnObj.put("page",  returnMap.get("page"));
			returnObj.put("list",  returnMap.get("dataList"));
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}

	//사용자별 현황 엑셀
	@RequestMapping(value = "exportStatisUserCurst.do")
	public void exportStatisUserCurst(HttpServletRequest request, HttpServletResponse response) throws Exception {
		SXSSFWorkbook resultWorkbook = null;
	    try {
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
			
	        String FileName = "CollabUserList"+dateFormat.format(today);
	        
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("groupPath", request.getParameter("groupPath"));
			reqMap.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			
			CoviMap returnMap = collabStatisSvc.getStatisUserCurst(reqMap);
			List<HashMap> excelList = (List<HashMap>)returnMap.get("dataList");
			HashMap statusCode = new HashMap<String, String>() {{put("W",DicHelper.getDic("lbl_Ready")); put("P",DicHelper.getDic("lbl_Progress")); put("H",DicHelper.getDic("lbl_Hold")); put("C",DicHelper.getDic("lbl_Completed"));}};
					
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_name")); put("colWith","150"); put("colKey","DisplayName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Project")); put("colWith","50"); put("colKey","PrjCnt"); put("colAlign", "CENTER");}});
			for (int i=0; i< modeList.length; i++){
				String colName = DicHelper.getDic(modeList[i][1]);
				String colKey  = modeList[i][0];
				colInfo.add(new HashMap<String, String>() {{put("colName",colName); put("colWith","80"); put("colKey",colKey); put("colAlign", "CENTER");put("colType", "I");}});
			}
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_TheProgression")); put("colWith","80"); put("colKey","ProgRate"); put("colAlign", "CENTER");put("colType", "F");}});
			
			String excelTitle = DicHelper.getDic("lbl_User_Statistics")+" ["+request.getParameter("startDate")+"~"+request.getParameter("endDate")+"]";
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	    	if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}
			
	String modeList[][] = {{"TotCnt","lbl_TotalNumber"},{"CompCnt","lbl_Completed"},{"WaitCnt","lbl_Ready"},{"ProcCnt","lbl_Progress"},{"HoldCnt","lbl_Hold"}
	,{"ImpCnt","lbl_Important"},{"EmgCnt","lbl_Urgency"},{"DelayCnt","lbl_Delay"}
	,{"NowCompCnt","lbl_Completed_To"}	,{"NowNoCnt","lbl_UnList_To"}	,{"NowTotCnt","lbl_Whole_To"}}; 
	//사용자별 현황
	@RequestMapping(value = "/CollabStatisUser.do")
	public ModelAndView collabStatisUser(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabStatisUser";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("modeList", modeList);
		return mav;
	}

	//상태별 상세 화면
	@RequestMapping(value = "/CollabStatisPopup.do")
	public ModelAndView collabStatisPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabStatisPopup";
		ModelAndView mav		= new ModelAndView(returnURL);
		mav.addObject("groupKey", request.getParameter("groupKey"));
		mav.addObject("groupName", request.getParameter("groupName"));
		mav.addObject("groupCode", request.getParameter("groupCode"));
		mav.addObject("prjType", request.getParameter("prjType"));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjName", request.getParameter("prjName"));
		mav.addObject("mode", request.getParameter("mode"));
		mav.addObject("modeName", request.getParameter("modeName"));
		mav.addObject("modeList", modeList);
		mav.addObject("startDate", request.getParameter("startDate"));
		mav.addObject("endDate", request.getParameter("endDate"));
		mav.addObject("searchKeyword", request.getParameter("searchKeyword"));
		mav.addObject("searchOption", request.getParameter("searchOption"));
		return mav;
	}
	
	//사용자 상태 리스트
	@RequestMapping(value = "getStatisStatusCurst.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getStatisStatusCurst(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("groupKey", request.getParameter("groupKey"));
			reqMap.put("groupCode", request.getParameter("groupCode"));
			reqMap.put("prjType", request.getParameter("prjType"));
			reqMap.put("prjSeq", request.getParameter("prjSeq"));
			reqMap.put("mode", request.getParameter("mode"));
			reqMap.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			reqMap.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			reqMap.put("searchKeyword", request.getParameter("searchKeyword"));
			reqMap.put("searchOption", request.getParameter("searchOption"));
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			reqMap.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			reqMap.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			CoviMap returnMap = collabStatisSvc.getStatisStatusCurst(reqMap);
					
			returnObj.put("page",  returnMap.get("page"));
			returnObj.put("list",  returnMap.get("dataList"));
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}
  	
	//사용자별 프로젝트
	@RequestMapping(value = "/CollabStatisProjectPopup.do")
	public ModelAndView collabStatisProjectPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabStatisProjectPopup";
		ModelAndView mav		= new ModelAndView(returnURL);
        if (!ComUtils.nullToString(request.getParameter("userCode"),"").equals("")){
            CoviMap reqMap = new CoviMap();

			CoviMap params = new CoviMap();
			params.put("USERID",request.getParameter("userCode"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("onlyMember", "Y");
			params.put("prjStatus","P".split(","));
			params.put("isSaas", isSaaS);
			CoviMap returnData= collabCommonSvc.getUserProject(params);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			//returnData.put("message", DicHelper.getDic("msg_Edited"));	//수정되었습니다

			mav.addObject("prjList", returnData.get("prjList"));
			mav.addObject("detpList", returnData.get("deptList"));
//			mav.addObject("prjList", returnData.get("prjList"));
        }
		mav.addObject("userCode", request.getParameter("userCode"));
		mav.addObject("userName", request.getParameter("userName"));
		return mav;
	}
	
	//팀별 현황
	@RequestMapping(value = "/CollabStatisTeam.do")
	public ModelAndView collabStatisTeam(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabStatisTeam";
		ModelAndView mav	= new ModelAndView(returnURL);
//		mav.addObject("modeList", modeList);
		return mav;
	}
	
	//팀별 현황
	@RequestMapping(value = "getStatisTeamCurst.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getStatisTeamCurst(HttpServletRequest request) throws Exception {
		//getProjectStatusList
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("pageNo", request.getParameter("pageNo"));
			reqMap.put("pageSize", request.getParameter("pageSize"));
			reqMap.put("searchText", request.getParameter("searchText"));
			reqMap.put("groupPath", request.getParameter("groupPath"));
			reqMap.put("isClose", request.getParameter("isClose"));
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			reqMap.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			reqMap.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			CoviMap returnMap = collabStatisSvc.getStatisTeamCurst(reqMap);
					
			returnObj.put("page",  returnMap.get("page"));
			returnObj.put("list",  returnMap.get("dataList"));
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}
}
