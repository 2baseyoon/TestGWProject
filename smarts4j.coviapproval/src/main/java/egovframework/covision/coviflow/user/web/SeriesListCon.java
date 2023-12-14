package egovframework.covision.coviflow.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.util.Locale;
import java.util.Map;

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
import egovframework.covision.coviflow.user.service.SeriesListSvc;

@Controller
public class SeriesListCon {
	private static Logger LOGGER = LogManager.getLogger(SeriesListCon.class);
	
	@Autowired
	private SeriesListSvc seriesListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getSeriesAddPopup - 단위업무 상세 정보 조회 및 수정 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/SeriesAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSeriesAddPopup(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/approval/SeriesAddPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getSeriesModifyPopup - 단위업무 수정 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/SeriesModifyPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSeriesModifyPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/SeriesModifyPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getSeriesSearchPopup - 단위업무 검색 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesSearchPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSeriesSearchPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/SeriesSearchPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getSeriesFunctionPopup - 단위업무 기능 팝업
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesFunctionPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSeriesFunctionPopup(Locale locale, Model model)
	{
		String returnURL = "user/approval/SeriesFunctionPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * downloadSeriesTemplateFile - 단위업무 엑셀 업로드용 템플릿 파일 다운로드
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/downloadSeriesTemplateFile.do", method = RequestMethod.GET)
	public void downloadSeriesTemplateFile(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String fileName = "Series_template.xlsx";
		String csvPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Series_template.xlsx");
		File file = new File(FileUtil.checkTraversalCharacter(csvPath));
		try ( OutputStream os = response.getOutputStream();
				InputStream in = new FileInputStream(file);
				) {
			
			response.reset() ;
			response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+"\";");
			response.setContentType("application/octet-stream;charset=utf-8"); 
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setHeader("Content-Length", ""+file.length() );
			response.getOutputStream().flush();
			
			byte[] b = new byte[8192];
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
		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	/**
	 * getBaseYearList - 기준 년도 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesBaseYearList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesBaseYearList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			
			CoviMap resultList = seriesListSvc.selectBaseYearList(params);
			
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
	 * getDeptSchList - 부서 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptSchList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptSchList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("DEPTIDORI", SessionHelper.getSession("DEPTID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap resultList = seriesListSvc.getSubDeptList(params);
			
			returnList.put("list", resultList.get("subDeptList"));
			returnList.put("isAdmin", resultList.get("isAdmin"));
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
	 * getDeptSchList - 단위업무> 업무구분 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getFunctionLevel.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFunctionLevel(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			String level = request.getParameter("level");
			String deptid = request.getParameter("deptid");
			String functioncode = request.getParameter("functioncode");
			String year = request.getParameter("baseyear");
					
			CoviMap params = new CoviMap();
			params.put("deptCode", deptid);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("level",level);
			params.put("baseYear",year);
			params.put("functioncode",functioncode);
				
			CoviMap resultList = seriesListSvc.getFunctionLevel(params);
			
			returnList.put("list", resultList.get("levelList"));
			returnList.put("isAdmin", resultList.get("isAdmin"));
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
	 * getSeriesListData - 단위업무 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesListData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			CoviMap params = new CoviMap();
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("deptCode", request.getParameter("deptCode") == null ? "" : request.getParameter("deptCode"));
			params.put("keepPeriod", request.getParameter("keepPeriod") == null ? "" : request.getParameter("keepPeriod"));
			params.put("seriesCode", request.getParameter("seriesCode") == null ? "" : request.getParameter("seriesCode"));
			params.put("sfCode", request.getParameter("sfCode") == null ? "" : request.getParameter("sfCode"));
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("searchWord", request.getParameter("searchWord") == null ? "" : request.getParameter("searchWord"));
			params.put("revokeStatus", request.getParameter("revokeStatus") == null ? "" : request.getParameter("revokeStatus"));
			params.put("baseYear", request.getParameter("baseYear") == null ? "" : request.getParameter("baseYear"));
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("searchWord", request.getParameter("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(request.getParameter("searchWord"),100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			CoviMap resultList = seriesListSvc.selectSeriesListData(params, "");
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	 * SeriesExcelUpload - 단위업무 엑셀 업로드
	 * @param uploadfile
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/seriesExcelUpload.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap seriesExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			
			params.put("userCode", userCode);
			params.put("uploadfile", uploadfile);
			
			returnList = seriesListSvc.seriesExcelUpload(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "업로드 되었습니다.");
		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?ioE.getMessage():DicHelper.getDic("msg_apv_030"));
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
	 * insertSeriesData - 단위업무 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertSeriesData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertSeriesData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			String[] deptName = StringUtil.replaceNull(request.getParameter("DeptName")).split(", ");
			String[] deptCode = StringUtil.replaceNull(request.getParameter("DeptCode")).split(";");
			
			params.put("userCode", userCode);
			params.put("UnitTaskType", request.getParameter("UnitTaskType"));
			params.put("ArrDeptName", deptName);
			params.put("ArrDeptCode", deptCode);
			params.put("SFCode", request.getParameter("SFCode"));
			params.put("SeriesName", request.getParameter("SeriesName"));
			params.put("SeriesDescription", request.getParameter("SeriesDescription"));
			params.put("KeepPeriod", request.getParameter("KeepPeriod"));
			params.put("KeepPeriodReason", request.getParameter("KeepPeriodReason"));
			params.put("KeepMethod", request.getParameter("KeepMethod"));
			params.put("KeepPlace", request.getParameter("KeepPlace"));
			params.put("BaseYear", request.getParameter("BaseYear"));
			params.put("BaseGroupCode", deptCode[0]);
			
			int result = seriesListSvc.insertSeriesData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "추가되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
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
	 * modifySeriesData - 단위업무 수정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/modifySeriesData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap modifySeriesData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String userCode = SessionHelper.getSession("USERID");
			
			params.put("userCode", userCode);
			params.put("DeptName", request.getParameter("DeptName"));
			params.put("DeptCode", request.getParameter("DeptCode"));
			params.put("SFCode", request.getParameter("SFCode"));
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("SeriesName", request.getParameter("SeriesName"));
			params.put("SeriesDescription", request.getParameter("SeriesDescription"));
			params.put("KeepPeriod", request.getParameter("KeepPeriod"));
			params.put("KeepPeriodReason", request.getParameter("KeepPeriodReason"));
			params.put("KeepMethod", request.getParameter("KeepMethod"));
			params.put("KeepPlace", request.getParameter("KeepPlace"));
			params.put("MappingID", request.getParameter("MappingID"));
			params.put("BaseYear", request.getParameter("BaseYear"));
			
			int result = seriesListSvc.updateSeriesData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "수정되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
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
	 * setRevokeSeries - 단위업무 폐지
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setRevokeSeries.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setRevokeSeries(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("DeptCode", request.getParameter("DeptCode"));
			params.put("AbolitionReason", request.getParameter("AbolitionReason"));
			params.put("BaseYear", request.getParameter("BaseYear"));
			
			int result = seriesListSvc.updateRevokeSeries(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "폐지되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
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
	 * setRestoreSeries - 단위업무 폐지복원
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/setRestoreSeries.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setRestoreSeries(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			
			params.put("SeriesCode", request.getParameter("SeriesCode"));
			params.put("DeptCode", request.getParameter("DeptCode"));
			params.put("BaseYear", request.getParameter("BaseYear"));
			
			int result = seriesListSvc.updateRestoreSeries(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_AbolitionRestored")); // 폐지복원되었습니다.
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
			
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
	 * seriesExcelDownload - 단위업무 목록 엑셀 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/seriesExcelDownload.do")
	public ModelAndView seriesExcelDownload(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
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
			
			params.put("deptCode", selParams.get("deptCode") == null ? "" : selParams.get("deptCode"));
			params.put("keepPeriod", selParams.get("keepPeriod") == null ? "" : selParams.get("keepPeriod"));
			params.put("seriesCode", selParams.get("seriesCode") == null ? "" : selParams.get("seriesCode"));
			params.put("sfCode", selParams.get("sfCode") == null ? "" : selParams.get("sfCode"));
			params.put("searchType", selParams.get("searchType") == null ? "" : selParams.get("searchType"));
			params.put("searchWord", selParams.get("searchWord") == null ? "" : selParams.get("searchWord"));
			params.put("revokeStatus", selParams.get("revokeStatus") == null ? "" : selParams.get("revokeStatus"));
			params.put("baseYear", selParams.get("baseYear") == null ? "" : selParams.get("baseYear"));
			params.put("searchType", selParams.get("searchType") == null ? "" : selParams.get("searchType"));
			params.put("searchWord", selParams.get("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(selParams.optString("searchWord"),100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			
			CoviMap resultList = seriesListSvc.selectSeriesListData(params, headerCode);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Series_List");

			mav = new ModelAndView(returnURL, viewParams);

		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
	
	/**
	 * getSeriesSearchList - 단위업무 검색 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesSearchList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesSearchList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("deptCode", request.getParameter("deptCode") == null ? "" : request.getParameter("deptCode"));
			params.put("baseYear", request.getParameter("baseYear") == null ? "" : request.getParameter("baseYear"));
			params.put("searchWord", request.getParameter("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(request.getParameter("searchWord"),100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			
			CoviMap resultList = seriesListSvc.selectSeriesSearchList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	 * getSeriesSearchTreeData - 단위업무 트리 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesSearchTreeData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesSearchTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("baseYear", request.getParameter("baseYear") == null ? "" : request.getParameter("baseYear"));
			
			CoviMap resultList = seriesListSvc.selectSeriesSearchTreeData(params);
			
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
	 * getSeriesFunctionListData - 기능 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesFunctionListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesFunctionListData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			CoviMap params = new CoviMap();
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("searchWord", request.getParameter("searchWord") == null ? "" : ComUtils.RemoveSQLInjection(request.getParameter("searchWord"),100));
			params.put("FunctionLevel", request.getParameter("functionLevel") == null ? "" : request.getParameter("functionLevel"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			
			CoviMap resultList = seriesListSvc.selectSeriesFunctionListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	 * getSeriesFunctionTreeData - 기능 트리 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesFunctionTreeData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesFunctionTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();
			
			CoviMap resultList = seriesListSvc.selectSeriesFunctionListData(params);
			page = resultList.getJSONObject("page");
			
			returnList.put("page", page);
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
	 * getSeriesPath - 단위업무 경로 가져오기
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSeriesPath.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSeriesPath(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String returnStr = "";
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("SeriesCode", request.getParameter("SeriesCode") == null ? "" : request.getParameter("SeriesCode"));
			params.put("BaseYear", request.getParameter("BaseYear") == null ? "" : request.getParameter("BaseYear"));
			
			returnStr = seriesListSvc.getSeriesPath(params);
			
			returnList.put("SeriesPath", returnStr);
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
	 * syncSeries - 단위업무 동기화
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/syncSeries.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap syncSeries(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("BaseYear", request.getParameter("BaseYear") == null ? "" : request.getParameter("BaseYear"));
			
			int result = seriesListSvc.updateSyncSeries(params);
			
			if(result == 0){
				returnList.put("message", "동기화 될 단위업무가 없습니다");
			}else{
				returnList.put("message", "동기화 되었습니다");
			}
			
			returnList.put("result", result);
			returnList.put("status", Return.SUCCESS);
			
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
	 * insertSeriesByYear - 단위업무 연도별 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertSeriesByYear.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertSeriesByYear(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			String baseYear =request.getParameter("BaseYear");
			if (baseYear == null ||baseYear.equals("")) {
				baseYear = StringUtil.getNowDate("yyyy");
			}
			
			CoviMap params = new CoviMap();
			params.put("BaseYear", baseYear);			
			seriesListSvc.insertSeriesByYear(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "성공적으로 생성되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * CreateNextYearSeriesDataPopup - 단위업무 차년도 데이터 복사(생성)
	 * @param Locale
	 * @param Model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/CreateNextYearSeriesDataPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView createNextYearSeriesDataPopup(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/approval/CreateNextYearSeriesDataPopup";
		return new ModelAndView(returnURL);
	}
}
