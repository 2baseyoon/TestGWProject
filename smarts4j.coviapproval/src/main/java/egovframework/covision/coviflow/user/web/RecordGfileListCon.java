package egovframework.covision.coviflow.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.user.service.RecordGfileListSvc;
import egovframework.covision.coviflow.user.service.SeriesListSvc;

@Controller
public class RecordGfileListCon {
	@Autowired
	private RecordGfileListSvc recordGfileListSvc;
	
	@Autowired
	private SeriesListSvc seriesListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	static final Logger LOGGER = LogManager.getLogger(RecordGfileListCon.class);
	/**
	 * getRecordGFileAddPopup - 기록물철 상세 정보 조회 및 수정 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getRecordGFileAddPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/RecordGFileAddPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getRecordGFileInfoPopup - 기록물철 상세 정보 조회 및 수정 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileInfoPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getRecordGFileInfoPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/RecordGFileInfoPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getRecordGFileListData - 기록물철 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getRecordGFileListData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap resultList = new CoviMap();
			CoviMap params = new CoviMap();
			
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("searchMode", request.getParameter("searchMode") == null ? "" : request.getParameter("searchMode"));
			params.put("recordClassNum", request.getParameter("recordClassNum") == null ? "" : request.getParameter("recordClassNum"));
			params.put("deptCode", request.getParameter("deptCode") == null ? "" : request.getParameter("deptCode"));
			params.put("seriesCode", request.getParameter("seriesCode") == null ? "" : request.getParameter("seriesCode"));
			params.put("takeOverCheck", request.getParameter("takeOverCheck") == null ? "" : request.getParameter("takeOverCheck"));
			params.put("recordStatus", request.getParameter("recordStatus") == null ? "" : request.getParameter("recordStatus"));
			params.put("baseYear", request.getParameter("baseYear") == null ? "" : request.getParameter("baseYear"));
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("searchWord", request.getParameter("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(request.getParameter("searchWord"),100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = recordGfileListSvc.selectRecordGFileListData(params, "");
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * getRecordBaseYearList - 기준 년도 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordBaseYearList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getRecordBaseYearList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("selBaseYear", request.getParameter("selBaseYear") == null ? "" : request.getParameter("selBaseYear"));
			
			resultList = recordGfileListSvc.selectBaseYearList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * insertRecordGFileData - 기록물철 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertRecordGFileData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertRecordGFileData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap subParams = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			subParams.put("SeriesCode", request.getParameter("SeriesCode"));
			subParams.put("BaseYear", StringUtil.getNowDate("yyyy"));
			String seriesPath = seriesListSvc.getSeriesPath(subParams);
			
			params.put("userCode", userCode);
			params.put("RecordSubject", request.getParameter("RecordSubject"));
			params.put("RecordDeptCode", request.getParameter("RecordDeptCode"));
			params.put("RecordDeptName", request.getParameter("RecordDeptName"));
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("SeriesName", request.getParameter("SeriesName"));
			params.put("ProductYear", StringUtil.getNowDate("yyyy"));
			
			String recordSeq = recordGfileListSvc.selectRecordSeq(params);
			String recordClassNum =   params.getString("RecordDeptCode")
									+ params.getString("SeriesCode")
									+ params.getString("ProductYear")
									+ recordSeq
									+ "001";
			
			params.put("RecordSeq", recordSeq);
			params.put("RecordType", request.getParameter("RecordType"));
			params.put("EndYear", request.getParameter("EndYear"));
			params.put("KeepPeriod", request.getParameter("KeepPeriod"));
			params.put("KeepMethod", request.getParameter("KeepMethod"));
			params.put("KeepPlace", request.getParameter("KeepPlace"));
			params.put("WorkCharger", request.getParameter("WorkCharger"));
			params.put("RecordFileCount", request.getParameter("RecordFileCount"));
			params.put("ProvideEndDate", request.getParameter("ProvideEndDate"));
			params.put("AutoYearYN", request.getParameter("AutoYearYN"));
			params.put("RecordClassNum", recordClassNum);
			params.put("SeriesPath", seriesPath);
			
			int result = recordGfileListSvc.insertRecordGFileData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "추가되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * modifyRecordGFileData - 기록물철 수정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/modifyRecordGFileData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap modifyRecordGFileData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap subParams = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			subParams.put("SeriesCode", request.getParameter("SeriesCode"));
			subParams.put("BaseYear", request.getParameter("BaseYear"));
			String seriesPath = seriesListSvc.getSeriesPath(subParams);
			
			params.put("userCode", userCode);
			params.put("RecordSubject", request.getParameter("RecordSubject"));
			params.put("RecordDeptCode", request.getParameter("RecordDeptCode"));
			params.put("RecordDeptName", request.getParameter("RecordDeptName"));
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("SeriesName", request.getParameter("SeriesName"));
			params.put("RecordType", request.getParameter("RecordType"));
			params.put("EndYear", request.getParameter("EndYear"));
			params.put("KeepPeriod", request.getParameter("KeepPeriod"));
			params.put("KeepMethod", request.getParameter("KeepMethod"));
			params.put("KeepPlace", request.getParameter("KeepPlace"));
			params.put("WorkCharger", request.getParameter("WorkCharger"));
			params.put("RecordClassNum", request.getParameter("RecordClassNum"));
			params.put("ModifyReason", request.getParameter("ModifyReason"));
			params.put("BaseYear",  request.getParameter("BaseYear"));
			params.put("RecordFileCount", request.getParameter("RecordFileCount"));
			params.put("ProvideEndDate", request.getParameter("ProvideEndDate"));
			params.put("AutoYearYN", request.getParameter("AutoYearYN"));
			params.put("SeriesPath", seriesPath);
			
			int result = recordGfileListSvc.updateRecordGFileData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "수정되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * setRecordStatus - 기록물철 상태 변경
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setRecordStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setRecordStatus(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String[] recordClassNumArr = StringUtil.replaceNull(request.getParameter("RecordClassNum")).split(";");
			
			params.put("RecordStatus", request.getParameter("RecordStatus"));
			params.put("RecordClassNumArr", recordClassNumArr);
			
			int result = recordGfileListSvc.updateRecordStatus(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "변경되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * setExtendWork - 업무 연장
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setExtendWork.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setExtendWork(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String[] recordClassNumArr = StringUtil.replaceNull(request.getParameter("RecordClassNum")).split(";");
			
			params.put("RecordClassNumArr", recordClassNumArr);
			
			int result = recordGfileListSvc.updateExtendWork(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "변경되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * setRecordTakeover - 기록물철 인계
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setRecordTakeover.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setRecordTakeover(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap subParams = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			subParams.put("SeriesCode", request.getParameter("SeriesCode"));
			subParams.put("BaseYear", request.getParameter("BaseYear"));
			String seriesPath = seriesListSvc.getSeriesPath(subParams);
			
			params.put("userCode", userCode);
			params.put("BaseYear", request.getParameter("BaseYear"));
			params.put("RecordClassNum", request.getParameter("RecordClassNum"));
			params.put("BeforeDeptCode", request.getParameter("BeforeDeptCode"));
			params.put("AfterDeptCode", request.getParameter("AfterDeptCode"));
			params.put("AfterDeptName", request.getParameter("AfterDeptName"));
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("SeriesName", request.getParameter("SeriesName"));
			params.put("WorkCharger", request.getParameter("WorkCharger"));
			params.put("SeriesPath", seriesPath);
			
			int result = recordGfileListSvc.updateRecordTakeover(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "변경되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getRecordHistoryList - 기록물철 변경 이력
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordHistoryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getRecordHistoryList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try	{
			CoviMap params = new CoviMap();
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("RecordClassNum", request.getParameter("RecordClassNum"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = recordGfileListSvc.selectRecordHistoryList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getRecordGFileInfoPopup - 기록물철 통합 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileIntegrationPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getRecordGFileIntegrationPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/RecordGFileIntegrationPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getRecordGFileListSearchPopup - 기록물철 검색 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileListSearchPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getRecordGFileListSearchPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/RecordGFileListSearchPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * downloadRecordFileTemplateFile - 단위업무 엑셀 업로드용 템플릿 파일 다운로드
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/downloadRecordFileTemplateFile.do", method = RequestMethod.GET)
	public void downloadRecordFileTemplateFile(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		OutputStream os = null;
		InputStream in = null;
		try {
			String fileName = "RecordGFile_template.xlsx";
			String csvPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//RecordGFile_template.xlsx");
			
			File file = new File(FileUtil.checkTraversalCharacter(csvPath));
			os = response.getOutputStream();
			in = new FileInputStream(file);
			
			response.reset() ;
			response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+"\";");
			response.setContentType("application/octet-stream;charset=utf-8"); 
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setHeader("Content-Length", ""+file.length() );
			response.getOutputStream().flush();
			
			byte b[] = new byte[8192];
			int leng = 0;
			int bytesBuffered = 0;
			
			while ( (leng = in.read(b)) > -1){
				os.write(b,0, leng);
				bytesBuffered += leng;
				if(bytesBuffered > 1024 * 1024){
					bytesBuffered = 0;
					os.flush();
				}
			}
			
			os.flush();
			os.close();
		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if(os != null) {
				try {
					os.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if(in != null) {
				try {
					in.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
	}
	
	/**
	 * RecordGFileExcelUpload - 기록물철 엑셀 업로드
	 * @param uploadfile
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/recordGFileExcelUpload.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap seriesExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			
			params.put("userCode", userCode);
			params.put("uploadfile", uploadfile);
			
			recordGfileListSvc.recordGFileExcelUpload(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "업로드 되었습니다.");
		} catch (IOException ioE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ioE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * seriesExcelDownload - 기록물철 엑셀 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/recordExcelDownload.do")
	public ModelAndView seriesExcelDownload(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String selectParams = URLDecoder.decode(request.getParameter("selectParams"), "utf-8").replace("&quot;", "\"");
			JSONParser parser = new JSONParser();
			CoviMap selParams = (CoviMap) parser.parse(selectParams);
			String headerCode = request.getParameter("headercode");
			String headerName = request.getParameter("headername");
			headerCode = URLDecoder.decode(headerCode, "utf-8");
			headerName = URLDecoder.decode(headerName, "utf-8");
			String[] headerNames = headerName.split(";");
			String sortKey = selParams.get("sortBy") == null || selParams.get("sortBy").equals("") ? "" : selParams.optString("sortBy").split(" ")[0];
			String sortDirec = selParams.get("sortBy") == null || selParams.get("sortBy").equals("") ? "" : selParams.optString("sortBy").split(" ")[1];
			
			params.put("searchMode", selParams.get("searchMode") == null ? "" : selParams.get("searchMode"));
			params.put("recordClassNum", selParams.get("recordClassNum") == null ? "" : selParams.get("recordClassNum"));
			params.put("deptCode", selParams.get("deptCode") == null ? "" : selParams.get("deptCode"));
			params.put("seriesCode", selParams.get("seriesCode") == null ? "" : selParams.get("seriesCode"));
			params.put("takeOverCheck", selParams.get("takeOverCheck") == null ? "" : selParams.get("takeOverCheck"));
			params.put("recordStatus", selParams.get("recordStatus") == null ? "" : selParams.get("recordStatus"));
			params.put("baseYear", selParams.get("baseYear") == null ? "" : selParams.get("baseYear"));
			params.put("searchType", selParams.get("searchType") == null ? "" : selParams.get("searchType"));
			params.put("searchWord", selParams.get("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(selParams.optString("searchWord"),100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			
			resultList = recordGfileListSvc.selectRecordGFileListData(params, headerCode);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Series_List");

			mav = new ModelAndView(returnURL, viewParams);

		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}

	/**
	 * insertRecordGFileByYear - 기록물철 년도별 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertRecordGFileByYear.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertRecordGFileByYear(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			String baseYear =request.getParameter("BaseYear");
			if (baseYear == null || baseYear.equals("")) {
				baseYear = StringUtil.getNowDate("yyyy");
			}
			
			CoviMap params = new CoviMap();
			params.put("BaseYear", baseYear);
			
			recordGfileListSvc.insertRecordGFileByYear(params);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "성공적으로 생성되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * CreateNextYearRecordDataPopup - 기록물철 차년도 데이터 복사(생성)
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/CreateNextYearRecordDataPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView createNextYearRecordDataPopup(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/approval/CreateNextYearRecordDataPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * insertinsertRecordGFileByYearSchedule - 기록물철 년단위 자동생성 스케줄러
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/RecordGFileByYearSchedule.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertinsertRecordGFileByYearSchedule(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{			
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy");
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			
			String baseYear = sdf.format(new Date());
			
			CoviMap params = new CoviMap();
			params.put("BaseYear", baseYear);
			
			recordGfileListSvc.insertRecordGFileByYearSchedule(params);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "성공적으로 생성되었습니다");
		}catch(IOException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	

	/**
	 * getRecordGFileTreeData - 기록물철 트리 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordGFileTreeData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getRecordGFileTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("BaseYear", request.getParameter("BaseYear"));
			params.put("RecordAdmin", request.getParameter("RecordAdmin"));
			params.put("DeptId", request.getParameter("DeptId"));
			
			CoviMap resultList = recordGfileListSvc.selectRecordGFileTreeData(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * setRecordGFileIntergration - 기록물철 통합
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setRecordGFileIntergration.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setRecordGFileIntergration(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try{
			String targetRecordClassNum = StringUtil.replaceNull(request.getParameter("targetRecordClassNum"));
			String intergrationRecordClassNum = request.getParameter("intergrationRecordClassNum");
			String[] targetRecordClassNumArr = targetRecordClassNum.split(",");
			String userCode = SessionHelper.getSession("USERID");
			
			CoviMap params = new CoviMap();
			params.put("RecordStatus", "6");
			params.put("UserCode", userCode);
			params.put("RecordClassNumArr", targetRecordClassNumArr);
			params.put("IntergrationRecordClassNum", intergrationRecordClassNum);
			
			// 1. 대상기록물철 History 저장
			int result = recordGfileListSvc.insertRecordGFileIntergrationHistory(params);
			
			// 2. 대상기록물철 기록물들 통합기록물철 기록물로 변경
			result = recordGfileListSvc.updateDocIntergration(params);
			
			// 3. 대상기록물철 상태값 변경 (RecordStatus = 6 통합)
			result = recordGfileListSvc.updateRecordStatus(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_Been_saved"));
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
			}
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
