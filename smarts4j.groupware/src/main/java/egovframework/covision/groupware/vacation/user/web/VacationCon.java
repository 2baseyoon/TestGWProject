package egovframework.covision.groupware.vacation.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

//import egovframework.baseframework.util.*;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.*;
import egovframework.baseframework.util.json.JSONArray;
import egovframework.baseframework.util.json.JSONObject;
import egovframework.baseframework.util.json.JSONParser;
import net.sf.json.JSONSerializer;
import net.sf.jxls.transformer.XLSTransformer;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;
import egovframework.covision.groupware.util.mail.MailSenderSvc;

// 휴가관리
@Controller
@RequestMapping("vacation")
public class VacationCon {
	private static Logger LOGGER = LogManager.getLogger(VacationCon.class);

	@Autowired
	private VacationSvc vacationSvc;

	@Autowired
	private MailSenderSvc mailSenderSvc;

	
	final static String firstDate = "0131"; 
	final static String secondDate = "0610"; 
	final static String thirdDate = "0930"; 
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	// 연차관리 화면 데이터 조회
	@RequestMapping(value = "/getVacationDayList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationDayList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationDayList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	// 연차관리 엑셀 다운로드
	@RequestMapping(value = "/excelDownVacationDayList.do")
	public void excelDownVacationDayList(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "99999" ) int pageSize
			) throws Exception {

		CoviMap resultList = new CoviMap();
		
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null && !sortBy.isEmpty())? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty())? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationDayList_templete.xlsx");

			resultList = vacationSvc.getVacationDayList(params);

			String currentDate =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
			params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
			params.put("title", "연차 관리");


			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationDayList_"+currentDate+".xlsx"+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
			
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
		
	}
	// 연차 생성 환경 설정 값
	@RequestMapping(value = "/getVacationConfigVal.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationConfigVal(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap req = new CoviMap();
		req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		req.put("getName", request.getParameter("getName"));
		String rtnVal = "";
		try {
			rtnVal = vacationSvc.getVacationConfigVal(req);
			returnData.put("data", rtnVal);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_createSuccess"));	//생성 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}
	
	// 연차관리 > 등록
	@RequestMapping(value = "/insertNextVacation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertNextVacation(@RequestBody VacationListVO vacationListVO) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("vacationListVo", vacationListVO);
			
			int result = vacationSvc.insertNextVacation(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_createSuccess"));	//생성 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}

	// 연차관리 > 등록 전 휴가수 체크
	@RequestMapping(value = "/checkExtraVacation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkExtraVacation(@RequestBody Map<String, Object> reqMap) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			List userCodeList = (List)reqMap.get("urCode");
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("vacDay", reqMap.get("vacDay").toString());
			params.put("year", reqMap.get("year").toString());
			params.put("sDate", reqMap.get("sDate").toString());
			params.put("eDate", reqMap.get("eDate").toString());
			params.put("vacKind", reqMap.get("vacKind").toString());
			params.put("pageNo", Integer.parseInt(reqMap.get("pageNo").toString()));
			params.put("pageSize", Integer.parseInt(reqMap.get("pageSize").toString()));

			resultList = vacationSvc.checkExtraVacation(params, userCodeList);

			returnData.put("page", resultList.get("page"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}
	// 연차관리 > 등록
	@RequestMapping(value = "/insertExtraVacation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertExtraVacation(@RequestBody Map<String, Object> reqMap) throws Exception {
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			List userCodeList = (List)reqMap.get("urCode");
			params.put("vacKind", reqMap.get("vacKind").toString());
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("comment", reqMap.get("comment").toString());
			params.put("eDate", reqMap.get("eDate").toString());
			params.put("sDate", reqMap.get("sDate").toString());
			params.put("vacDay", reqMap.get("vacDay").toString());
			params.put("year", reqMap.get("year").toString());

			int result = vacationSvc.insertExtraVacation(params, userCodeList);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_createSuccess"));	//생성 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}


		return returnData;
	}
	
	// 연차관리 > 보상휴가 등록
	@RequestMapping(value = "/insertRewardVacation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertRewardVacation(@RequestBody Map<String, Object> reqMap) throws Exception {
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			List userCodeList = (List)reqMap.get("urCode");
			params.put("vacKind", reqMap.get("vacKind").toString());
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("comment", reqMap.get("comment").toString());
			params.put("eDate", reqMap.get("eDate").toString());
			params.put("sDate", reqMap.get("sDate").toString());
			params.put("vacDay", reqMap.get("vacDay").toString());
			params.put("year", reqMap.get("year").toString());
			params.put("rewardVacDay", reqMap.get("rewardVacDay").toString());
				
			int result = vacationSvc.insertRewardVacation(params, userCodeList);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_createSuccess"));	//생성 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}


		return returnData;
	}
	
	// 연차관리 > 보상휴가 등록(부여) API
	@RequestMapping(value = "/insertRewardVacationAPI.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertRewardVacationAPI(@RequestBody CoviMap req) throws Exception {
		CoviMap returnData = new CoviMap();
		try {
			CoviList reqMapArr = req.getJSONArray("data"); 
			int result = vacationSvc.insertRewardVacationAPI(reqMapArr);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_createSuccess"));	//생성 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}


		return returnData;
	}
	
	// 연차관리 > 보상휴가 등록(부여) 취소 API
	@RequestMapping(value = "/cancelRewardVacationAPI.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap cancelRewardVacationAPI(@RequestBody CoviMap req) throws Exception {
		CoviMap returnData = new CoviMap();
		try {
			CoviList reqMapArr = req.getJSONArray("data"); 
			int result = vacationSvc.cancelRewardVacationAPI(reqMapArr);

			if(result > 0) {
				returnData.put("data", result);
				returnData.put("result", "ok");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", DicHelper.getDic("CPMail_mail_msgNormCancel")); //정상적으로 취소되었습니다.
			} else {
				returnData.put("data", result);
				returnData.put("result", "fail");
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_hrMng_selectTarget")); //처리 가능 대상이 없습니다.
			}

		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}
	
	// 휴가일수관리 팝업
	@RequestMapping(value = "/goVacationUpdatePopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationUpdatePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("urCode", request.getParameter("urCode"));
		param.put("year", request.getParameter("year"));
		
		CoviMap returnList = vacationSvc.getVacationDayList(param);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationUpdatePopup");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 휴가 수정
	@RequestMapping(value = "/updateVacDay.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateVacDay(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			float vacDay = Float.parseFloat(request.getParameter("vacDay"));
			float oriVacDay = Float.parseFloat(request.getParameter("oriVacDay"));
			params.put("vacDay", vacDay);
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			params.put("registerCode", request.getParameter("RegisterCode"));
			params.put("sDate", request.getParameter("UseStartDate"));
			params.put("eDate", request.getParameter("UseEndDate"));
			params.put("urCode", request.getParameter("urCode"));
			params.put("year", request.getParameter("year"));
			params.put("vacKind", request.getParameter("vacKind"));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			int result = vacationSvc.updateVacDay(params);
			String comment = request.getParameter("vmComment");
			if(vacDay!=oriVacDay) {
				params.put("comment",   "["+oriVacDay+"=>"+vacDay+"] " + comment);
				params.put("vmMethod", "MNL");  //AUTO(자동), EXCEL(엑셀), MNL(수기)
				int hisRst = vacationSvc.insertVmPlanHist(params);
			}
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));	//수정 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 휴가 추가 팝업
	@RequestMapping(value = "/goVacationInsertPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationInsertPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationInsertPopup");
	}


	// 기타휴가일수관리 팝업
	@RequestMapping(value = "/goExtraVacationUpdatePopup.do", method = RequestMethod.GET)
	public ModelAndView goExtraVacationUpdatePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("urCode", request.getParameter("urCode"));
		param.put("year", request.getParameter("year"));
		param.put("vacKind", request.getParameter("vacKind"));
		param.put("sDate", request.getParameter("sDate"));
		param.put("eDate", request.getParameter("eDate"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));

		CoviMap returnList = vacationSvc.getVacationExtraList(param);

		ModelAndView mav = new ModelAndView("user/vacation/ExtraVacationUpdatePopup");
		mav.addObject("result", returnList);

		return mav;
	}
	
	// 보상휴가일수관리 팝업
	@RequestMapping(value = "/goRewardVacationUpdatePopup.do", method = RequestMethod.GET)
	public ModelAndView goRewardVacationUpdatePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("urCode", request.getParameter("urCode"));
		param.put("year", request.getParameter("year"));
		param.put("vacKind", request.getParameter("vacKind"));
		param.put("sDate", request.getParameter("sDate"));
		param.put("eDate", request.getParameter("eDate"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));

		CoviMap returnList = vacationSvc.getVacationRewardList(param);

		ModelAndView mav = new ModelAndView("user/vacation/RewardVacationUpdatePopup");
		mav.addObject("result", returnList);

		return mav;
	}

	// 기타휴가 수정
	@RequestMapping(value = "/updateExtraVacDay.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateExtraVacDay(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			float vacDay = Float.parseFloat(request.getParameter("vacDay"));
			float oriExtVacDay = Float.parseFloat(request.getParameter("oriExtVacDay"));
			String comment = request.getParameter("comment");
			params.put("vacDay",  vacDay);
			params.put("oriExtVacDay",  oriExtVacDay);
			params.put("urCode",  request.getParameter("urCode"));
			params.put("year",    request.getParameter("year"));
			params.put("vacKind", request.getParameter("vacKind"));
			params.put("sDate",   request.getParameter("sDate"));
			params.put("eDate",   request.getParameter("eDate"));
			params.put("extSdate",   request.getParameter("extSdate"));
			params.put("extEdate",   request.getParameter("extEdate"));
			params.put("comment",   request.getParameter("comment"));
			params.put("registerCode",   request.getParameter("registerCode"));
			params.put("modifierCode", SessionHelper.getSession("UR_Code"));

			if(vacDay!=oriExtVacDay) {
				params.put("comment",   "["+oriExtVacDay+"=>"+vacDay+"] " + comment);
				params.put("vmMethod", "MNL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
				int hisRst = vacationSvc.insertVmPlanHist(params);
				params.replace("comment",   comment);
			}else{
				params.put("comment",   comment);
			}
			int result = vacationSvc.updateExtraVacDay(params);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));	//수정 되었습니다
		} catch (NumberFormatException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}
	
	// 보상휴가 수정
	@RequestMapping(value = "/updateRewardVacDay.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateRewardVacDay(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			float vacDay = Float.parseFloat(request.getParameter("vacDay"));
			float oriExtVacDay = Float.parseFloat(request.getParameter("oriExtVacDay"));
			String comment = request.getParameter("comment");
			params.put("vacDay",  vacDay);
			params.put("oriExtVacDay",  oriExtVacDay);
			params.put("rewardVacDay",   request.getParameter("rewardVacDay"));
			params.put("urCode",  request.getParameter("urCode"));
			params.put("year",    request.getParameter("year"));
			params.put("vacKind", request.getParameter("vacKind"));
			params.put("sDate",   request.getParameter("sDate"));
			params.put("eDate",   request.getParameter("eDate"));
			params.put("extSdate",   request.getParameter("extSdate"));
			params.put("extEdate",   request.getParameter("extEdate"));
			params.put("comment",   request.getParameter("comment"));
			params.put("registerCode",   request.getParameter("registerCode"));
			params.put("modifierCode", SessionHelper.getSession("UR_Code"));

			if(vacDay!=oriExtVacDay) {
				params.put("comment",   "["+oriExtVacDay+"=>"+vacDay+"] " + comment);
				params.put("vmMethod", "MNL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
				int hisRst = vacationSvc.insertVmPlanHist(params);
				params.replace("comment",   comment);
			}else{
				params.put("comment",   comment);
			}
			int result = vacationSvc.updateRewardVacDay(params);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));	//수정 되었습니다
		} catch (NumberFormatException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}

	//기타 휴가 추가 팝업
	@RequestMapping(value = "/goExtraVacationInsertPopup.do", method = RequestMethod.GET)
	public ModelAndView goExtraVacationInsertPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("domainId", SessionHelper.getSession("DN_ID"));
		CoviMap vacType = vacationSvc.getExtraVacKind(param);
		ModelAndView mav = new ModelAndView("user/vacation/ExtraVacationInsertPopup");
		mav.addObject("vacType", vacType);
		mav.addObject("year",request.getParameter("year"));
 		return mav;
	}
	
	//보상 휴가 추가 팝업
	@RequestMapping(value = "/goRewardVacationInsertPopup.do", method = RequestMethod.GET)
	public ModelAndView goRewardVacationInsertPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("domainId", SessionHelper.getSession("DN_ID"));
		CoviMap vacType = vacationSvc.getRewardVacKind(param);
		ModelAndView mav = new ModelAndView("user/vacation/RewardVacationInsertPopup");
		mav.addObject("vacType", vacType);
		mav.addObject("year",request.getParameter("year"));
 		return mav;
	}
	
	// 연차기간 조회 팝업
	@RequestMapping(value = "/goVacationPeriodManagePopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationPeriodManagePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView("user/vacation/VacationPeriodManagePopup");
		
		return mav;
	}
	
	// 연차기간 수정
	@RequestMapping(value = "/updateVacationPeriod.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateVacationPeriod(@RequestBody List<CoviMap> periodList) throws Exception {
		
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params =  new CoviMap();
			params.put("registerCode", SessionHelper.getSession("UR_Code"));
			params.put("modifierCode", SessionHelper.getSession("UR_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("periodList", periodList);
			
			int result = vacationSvc.updateVacationPeriod(params);
			
			returnData.put("data", result); 
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 나의휴가현황
	@RequestMapping(value = "/getMyVacationInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyVacationInfoList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
		) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("urCode",  SessionHelper.getSession("UR_Code"));
			params.put("VacKind",  request.getParameter("VacKind"));
			params.put("UseStartDate",  request.getParameter("Sdate"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			resultList = vacationSvc.getMyVacationInfoList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 나의 휴가 발생 현황
	@RequestMapping(value = "/getMyVacationCreateInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyVacationCreateInfoList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
		) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("urCode",  SessionHelper.getSession("UR_Code"));
			params.put("VacKind",  request.getParameter("VacKind"));
			params.put("UseStartDate",  request.getParameter("Sdate"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			resultList = vacationSvc.getMyVacationCreateInfoList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 휴가신청 조회(popup)
	@RequestMapping(value = "/getVacationInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationInfoList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
		) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("reqType", reqType);
			
			if (reqType.equals("vacationInfo")) {
				params.put("urCode", urCode);
			} else if (reqType.equals("manage")) {
				params.put("schTypeSel", schTypeSel);
				params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			}

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			resultList = vacationSvc.getVacationInfoList(params);
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}

	// 공통연차관리 엑셀 다운로드
	@RequestMapping(value = "/excelDownVacationInfoList.do")
	public void excelDownVacationInfoList(
				HttpServletRequest request,
				HttpServletResponse response,
				@RequestParam(value = "year", required = false) String year,
				@RequestParam(value = "reqType", required = false) String reqType,
				@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
				@RequestParam(value = "schTxt", required = false) String schTxt,
				@RequestParam(value = "urCode", required = false) String urCode,
				@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
				@RequestParam(value = "pageSize", required = false , defaultValue = "99999" ) int pageSize
				
			) throws Exception {
			CoviMap resultList = new CoviMap();
			ByteArrayOutputStream baos = null;
			InputStream is = null;
			FileInputStream fis = null;
			Workbook resultWorkbook = null;
			
			try {
				String sortBy = request.getParameter("sortBy");
				
				String sortKey =  ( sortBy != null  && !sortBy.isEmpty())? sortBy.split(" ")[0] : "";
				String sortDirec =  ( sortBy != null && !sortBy.isEmpty())? sortBy.split(" ")[1] : "";
				
				CoviMap params = new CoviMap();
				params.put("lang",SessionHelper.getSession("lang"));
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				params.put("domainCode",SessionHelper.getSession("DN_Code"));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("year", year);
				
				params.put("schTypeSel", schTypeSel);
				params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
				
				String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
				if(!orgMapOrderSet.equals("")) {
					String[] orgOrders = orgMapOrderSet.split("\\|");
					params.put("orgOrders", orgOrders);
				}
				
				String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationInfoList_templete.xlsx");

				CoviMap req = new CoviMap();
				resultList = vacationSvc.getVacationManageList(params);
				
				String currentDate =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
				params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
				params.put("title", "공통 연차 관리");

				baos = new ByteArrayOutputStream();
				XLSTransformer transformer = new XLSTransformer();
				fis = new FileInputStream(ExcelPath);
				is = new BufferedInputStream(fis);
				resultWorkbook = transformer.transformXLS(is, params);
				resultWorkbook.write(baos);

				response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationInfoListExcel_"+currentDate+".xlsx"+"\";");
				response.setHeader("Content-Description", "JSP Generated Data");
				response.setContentType("application/vnd.ms-excel;charset=utf-8");
				response.getOutputStream().write(baos.toByteArray());
				response.getOutputStream().flush();
								
			} catch (IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (ArrayIndexOutOfBoundsException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} finally { 
				if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			}
			
		}
		
		
	// 휴가신청/취소 조회, 공동연차등록, 나의휴가현황, 휴가취소처리
	@RequestMapping(value = "/getVacationCancelList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationCancelList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", schTxt);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			resultList = vacationSvc.getVacationCancelList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 연차 일괄 취소전 체크 데이터
	@RequestMapping(value = "/getVacationCancelCheck.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationCancelCheck(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String vacationInfoID = StringUtil.replaceNull(request.getParameter("vacationInfoID"), "[]");
			CoviList VacationInfoIdArray =  CoviList.fromObject(vacationInfoID.replaceAll("&quot;", "\""));

			CoviMap par = new CoviMap();
			par.put("pageNo", request.getParameter("pageNo"));
			par.put("pageSize", request.getParameter("pageSize"));
			par.put("lang", SessionHelper.getSession("lang"));
			par.put("domainID", SessionHelper.getSession("DN_ID"));
			par.put("domainCode", SessionHelper.getSession("DN_Code"));
			par.put("year", request.getParameter("year"));
			List vacIdList = new ArrayList();
			for(int i=0;i<VacationInfoIdArray.size();i++) {
				vacIdList.add(VacationInfoIdArray.getString(i));
			}
			par.put("VacationInfoId", vacIdList);
			resultList = vacationSvc.getVacationCancelCheck(par);

			returnData.put("page", resultList.get("page"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "/excelDownload.do" , method = RequestMethod.GET)
	public ModelAndView excelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		
		try {
			String reqType = StringUtil.replaceNull(request.getParameter("reqType"), "");
			CoviMap params = new CoviMap();
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			String[] headerNames = null;
			
			if (reqType.equals("manage")) {
				headerNames = new String [] {"사용자 코드","입사일자","이름","부서","연도","연차"};
				resultList = vacationSvc.getNextVacationListForExcel(params);
				
				viewParams.put("title", "VacationInsert");
			} else if (reqType.equals("commonInsert")) {
				headerNames = new String [] {"부서","이름","직위","사용자 코드"}; 
				resultList = vacationSvc.getTargetUserListForExcel(params);
				
				viewParams.put("title", "Template");
			}
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav; 
	}
	
	// 엑셀 다운로드(부서휴가유형별조회, 휴가유형별현황)
	@RequestMapping(value = "/excelDownloadForVacationListByType.do")
	public ModelAndView excelDownloadForVacationListByType(
			HttpServletRequest request, 
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "stndCur", required = false, defaultValue="N") String stndCur,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "DEPTID", required = false) String DEPTID,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "hideExtraVacation", required = false, defaultValue = "Y") String hideExtraVacation,
			@RequestParam(value = "headerName", required = false) String headerName,
			@RequestParam(value = "headerKey", required = false) String headerKey,
			@RequestParam(value = "headerType", required = false) String headerType
	) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";
			
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schTypeSel", schTypeSel);
			params.put("schEmploySel", schEmploySel);
			params.put("hideExtraVacation","Y");
			params.put("schDeptID", DEPTID);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

			if (reqType.equals("dept")) {
				params.put("deptCode", SessionHelper.getSession("DEPTID"));
			}
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("EXCEL", "true");
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			CoviMap resultList = vacationSvc.getVacationDayListByType(params);
			JSONArray colList = (JSONArray)resultList.get("colList");
			for (int i=0; i < colList.size();i++){
				JSONObject colMap =colList.getJSONObject(i);
				headerKey  += "|VAC_"+colMap.getString("Code");
				headerName += "|"+colMap.getString("CodeName");
			}

			String[] headerKeys = headerKey.split("\\|");
			String[] headerNames = headerName.split("\\|");
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerKey", headerKeys);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "VacationStatisticsExcel");
			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}

	// 연차관리 엑셀 업로드 팝업
	@RequestMapping(value = "/goVacationInsertByExcel1Popup.do", method = RequestMethod.GET)
	public ModelAndView goVacationInsertByExcel1Popup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationInsertByExcel1Popup");
	}
	
	// 공동연차등록 팝업
	@RequestMapping(value = "/goJointVacationInsertPopup.do", method = RequestMethod.GET)
	public ModelAndView goJointVacationInsertPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {		
		ModelAndView mav = new ModelAndView("user/vacation/JointVacationInsertPopup");
		mav.addObject("vacType", vacationSvc.getVacTypeDomain());
 		return mav;
	}
	
	// 공동연차등록 엑셀 업로드 팝업
	@RequestMapping(value = "/goVacationInsertByExcel2Popup.do", method = RequestMethod.GET)
	public ModelAndView goVacationInsertByExcel2Popup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView("user/vacation/VacationInsertByExcel2Popup");
		mav.addObject("vacType", vacationSvc.getVacTypeDomain());
		return mav;
	}
	
	// 공동연차등록 (Web) 
	@RequestMapping(value = "/insertJointVacation.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap insertJointVacation(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		
		try {		
			CoviMap params = new CoviMap();
			
			Enumeration<?> names = request.getParameterNames();
		    
		    while (names.hasMoreElements()) {
		    	String name = (String) names.nextElement();
		    	String nameVal = StringUtil.replaceNull(request.getParameter(name),"");
		    	params.put(name, nameVal);
		    }
			
			result = vacationSvc.insertJointVacation(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	// 공동연차등록 엑셀 업로드
	@RequestMapping(value = "/excelUploadForCommon.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile,
			@RequestParam(value="sDate", required=true) String sDate,
			@RequestParam(value="eDate", required=true) String eDate,
			@RequestParam(value="vacDay", required=true) double vacDay,
			@RequestParam(value="vacYear", required=false) int vacYear,
			@RequestParam(value="reason", required=false) String reason,
			@RequestParam(value="vacFlag", required=false) String vacFlag) {
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			params.put("sDate", sDate);
			params.put("eDate", eDate);
			params.put("vacDay", vacDay);
			params.put("vacYear", vacYear);
			params.put("reason", reason);
			params.put("vacFlag", vacFlag);
			
			result = vacationSvc.insertVacationByExcel(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	// 공동연차 취소  팝업창
	@RequestMapping(value = "/goVacationCancelByExcelpopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationCancleByExcelPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationCancelByExcelPopup");
	}
	
	// 공동연차 취소  엑셀 업로드
	@RequestMapping(value = "/excelUploadForCancel.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUploadCancle(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile,
			@RequestParam(value="sDate", required=true) String sDate,
			@RequestParam(value="eDate", required=true) String eDate,
			@RequestParam(value="vacDay", required=true) double vacDay,
			@RequestParam(value="reason", required=false) String reason) {
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			params.put("sDate", sDate);
			params.put("eDate", eDate);
			params.put("vacDay", vacDay);
			params.put("reason", reason);
			
			result = vacationSvc.insertVacationCancelByExcel(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);

		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	// 엑셀 업로드(연차관리)
	@RequestMapping(value = "/excelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			int	result = vacationSvc.insertVacationPlan(params);
			
			returnData.put("data", result);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	// 휴가취소 팝업
	@RequestMapping(value = "/goVacationCancelPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationCancelPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap params = new CoviMap();
		params.put("vacationInfoID",request.getParameter("vacationInfoId"));
		params.put("year",request.getParameter("vacYear"));
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("pageNo", 1);
		params.put("pageSize", 1);
		
		CoviMap resultList = vacationSvc.getVacationInfoList(params);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationCancelPopup");
		mav.addObject("result", resultList);
		
		return mav;
	}
	
	// 공동연차등록 > 휴가취소
	@RequestMapping(value = "/insertVacationCancel.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertVacationCancel(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String workItemId = StringUtil.replaceNull(request.getParameter("workItemId"), "");
			String processId = StringUtil.replaceNull(request.getParameter("processId"), "");
			
			params.put("vacYear", request.getParameter("vacYear"));
			params.put("urCode", request.getParameter("urCode"));
			params.put("vacFlag", request.getParameter("vacFlag"));
			params.put("sDate", request.getParameter("sDate"));
			params.put("eDate", request.getParameter("eDate"));
			params.put("vacDay", request.getParameter("vacDay"));
			params.put("vacOffFlag", request.getParameter("vacOffFlag"));
			params.put("reason", request.getParameter("reason"));
			params.put("vacationInfoID", request.getParameter("vacationInfoID"));

			// 2021.09.07, workItemId, processId 값이 빈문자열("")로 주어졌을 때 혹은 숫자아닌 다른 값이 들어왔을 때, 에러 발생 방지. Column이 Integer 이므로 0으로 대체.
			// 세팅값으로 변경되기도 하나 버전차이와 설정차이로 미적용시 에러 발생.
			if (workItemId.equals("") || !workItemId.matches("^[0-9]*$") ) {
				params.put("workItemId", 0);
			} else {
				params.put("workItemId", request.getParameter("workItemId"));
			}

			if (processId.equals("") || !processId.matches("^[0-9]*$") ) {
				params.put("processId", 0);
			} else {
				params.put("processId", request.getParameter("processId"));
			}

			params.put("gubun", request.getParameter("gubun"));
			
			int result = vacationSvc.insertVacationCancel(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	//일괄 휴가 취소 처리
	@RequestMapping(value = "/getVacationCancelDel.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationCancelDel(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		try {
			String vacationInfoID = StringUtil.replaceNull(request.getParameter("VacationInfoID"), "[]");
			CoviList VacationInfoIdArray =  CoviList.fromObject(vacationInfoID.replaceAll("&quot;", "\""));
			
			for(int i=0;i<VacationInfoIdArray.size();i++){
				CoviMap par = new CoviMap();
				par.put("lang",SessionHelper.getSession("lang"));
				par.put("domainID", SessionHelper.getSession("DN_ID"));
				par.put("domainCode",SessionHelper.getSession("DN_Code"));
				par.put("year",request.getParameter("year"));
				par.put("VacationInfoId",VacationInfoIdArray.getString(i));

				resultList = vacationSvc.getVacationCancelList(par);
				CoviMap jsonObjectresultList = CoviMap.fromObject(JSONSerializer.toJSON(resultList));

				CoviList jsonArray = CoviList.fromObject(jsonObjectresultList.get("list"));
				CoviMap jsonObject = CoviMap.fromObject(jsonArray.get(0));
				double vacDayCancel = jsonObject.getDouble("VacDayTot");
				if(vacDayCancel<0){
					continue;
				}
				CoviMap params = new CoviMap();
				params.put("vacYear", jsonObject.getString("VacYear"));
				params.put("urCode", jsonObject.getString("UR_Code"));
				params.put("vacFlag", jsonObject.getString("VacFlag"));
				params.put("sDate", jsonObject.getString("Sdate"));
				params.put("eDate", jsonObject.getString("Edate"));
				params.put("vacDay", vacDayCancel*-1);
				params.put("vacOffFlag", jsonObject.getString("VacOffFlag"));
				params.put("reason", "all cancel");
				params.put("vacationInfoID", jsonObject.getString("VacationInfoID"));
				//System.out.println("#####jsonObject:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(jsonObject));

				// 세팅값으로 변경되기도 하나 버전차이와 설정차이로 미적용시 에러 발생.
				if (!jsonObject.has("WorkItemID") ||"".equals(jsonObject.getString("WorkItemID")) || !jsonObject.getString("WorkItemID").matches("^[0-9]*$") ) {
					params.put("workItemId", 0);
				} else {
					params.put("workItemId", jsonObject.getInt("WorkItemID"));
				}

				if (!jsonObject.has("ProcessID") || "".equals(jsonObject.getString("ProcessID")) || !jsonObject.getString("ProcessID").matches("^[0-9]*$") ) {
					params.put("processId", 0);
				} else {
					params.put("processId", jsonObject.getInt("ProcessID"));
				}

				params.put("gubun", jsonObject.getString("GUBUN"));
				//System.out.println("#####params:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(params));
				cnt += vacationSvc.insertVacationCancel(params);
			}
			if(cnt == VacationInfoIdArray.size()){
				jo.put("result", cnt);
				jo.put("status", Return.SUCCESS);
				jo.put("msg", DicHelper.getDic("msg_138") );	//성공적으로 삭제되었습니다.
			}else {
				jo.put("status", Return.FAIL);
			}
		} catch(NullPointerException e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}

	// 휴가 일괄 취소 팝업
	@RequestMapping(value = "/goVacationDeletePopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationDeletePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {

		ModelAndView mav = new ModelAndView("user/vacation/VacationDeletePopup");
		mav.addObject("year", request.getParameter("year"));

		return mav;
	}

	// 나의휴가현황 > 사용휴가일수
	@RequestMapping(value = "/getUserVacationInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserVacationInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("year", request.getParameter("year"));
			params.put("urCode", Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID")));
			
			String termDate = "";
			if(request.getParameter("termDate") != null) {
				String termDateTmp = request.getParameter("termDate").replaceAll("-","");
			
				termDate = termDateTmp.substring(0,4) + "-";
				termDate += termDateTmp.substring(4,6) + "-";
				termDate += termDateTmp.substring(6,8);
			}
			params.put("termDate", termDate);
			
			if (request.getParameter("empType") != null && !request.getParameter("empType").toUpperCase().equals("NORMAL")){
				params.put("bfYear", Integer.parseInt(request.getParameter("year"))-1);
			}
			
			resultList = vacationSvc.getUserVacationInfo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}

	// 나의휴가현황 > 사용휴가일수
	@RequestMapping(value = "/getUserVacationInfoV2.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserVacationInfoV2(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();

			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("year", request.getParameter("year"));
			params.put("urCode", Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID")));

			String termDate = "";
			if(request.getParameter("termDate") != null) {
				String termDateTmp = request.getParameter("termDate").replaceAll("-","");

				termDate = termDateTmp.substring(0,4) + "-";
				termDate += termDateTmp.substring(4,6) + "-";
				termDate += termDateTmp.substring(6,8);
			}
			params.put("termDate", termDate);

			if (request.getParameter("empType") != null && !request.getParameter("empType").toUpperCase().equals("NORMAL")){
				params.put("bfYear", Integer.parseInt(request.getParameter("year"))-1);
			}

			resultList = vacationSvc.getUserVacationInfoV2(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	/**
	 * 연차촉진제 관련 서식 팝업
	 * @param year 연도 
	 * @param urCode 대상 사용자 코드
	 * @param viewType 조회 타입
	 * <ul>
	 * 	<li>user: 사용자 조회</li>
	 * 	<li>admin: 관리자 조회</li>
	 * <ul>
	 * @param formType 서식 타입
	 * <ul>
	 * 	<li>plan: 연차 사용계획서</li>
	 * 	<li>notification1: 미사용 연차 사용시기 지정통보서 (1차)</li>
	 * 	<li>request: 미사용 연차 유급휴가 일수 알림 및 사용시기 지정요청</li>
	 * 	<li>notification2: 미사용 연차 유급휴가 사용시기 지정 통보 (2차)</li>
	 * <ul>
	 * @param empType 근로자 타입
	 * <ul>
	 * 	<li>normal: 일반 직원</li>
	 * 	<li>newEmp: 1년 미만 직원 (사용계획의 경우 9/2일 구분이 필요없음)</li>
	 * 	<li>newEmpForNine: 1년 미만 직원 9일용</li>
	 * 	<li>newEmpForTwo: 1년 미만 직원 2일용</li>
	 * <ul>
	 * @return mav
	 * @throws Exception
	 */
	@RequestMapping(value = "/goVacationPromotionPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationPromotionPopup(
			@RequestParam(value = "year", required = true) String year
			, @RequestParam(value = "urCode", required = false) String urCode
			, @RequestParam(value = "viewType", required = false, defaultValue = "") String viewType
			, @RequestParam(value = "formType", required = false, defaultValue = "") String formType
			, @RequestParam(value = "empType", required = false) String empType	) throws Exception {

		int messageID = 0;
		String viewName = "";

		if(urCode == null) {
			urCode = SessionHelper.getSession("USERID");
		}
		
		CoviMap param = new CoviMap();
		param.put("year", year);
		param.put("urCode", urCode);
		param.put("lang",SessionHelper.getSession("lang"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));
		param.put("domainCode", SessionHelper.getSession("DN_Code"));
		param.put("empType", empType);
		if (!empType.toUpperCase().equals("NORMAL")){
			param.put("bfYear", Integer.parseInt(year)-1);
		}
		
		//System.out.println("##################### termDate "+param.get("termDate"));

		switch(formType.toUpperCase()) {
			case "PLAN":			// 연차 사용계획서
				messageID = 10;
				viewName = "user/vacation/VacationPromotionPlanPopup";
				break;
			case "NOTIFICATION1":	//미사용 연차 사용시기 지정통보서 (1차)
				messageID = 12;
				viewName = "user/vacation/VacationPromotionNotification1Popup";
				break;
			case "REQUEST":			//미사용 연차 유급휴가 일수 알림 및 사용시기 지정요청
				messageID = 15;
				viewName = "user/vacation/VacationPromotionRequestPopup";
				break;
			case "NOTIFICATION2":	//미사용 연차 유급휴가 사용시기 지정 통보 (2차)
				messageID = 18;
				viewName = "user/vacation/VacationPromotionNotification2Popup";
				break;
			default :
				break;
		}
		ModelAndView mav = new ModelAndView(viewName);

		CoviMap returnList = new CoviMap();
		CoviMap dateForm = new CoviMap();

		CoviMap req = new CoviMap();
		req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		req.put("getName", "CreateMethod");
		String CreateMethod = vacationSvc.getVacationConfigVal(req);
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}
		//System.out.println("####CreateMethod:"+CreateMethod);
		if(CreateMethod.equals("J")){
			returnList = vacationSvc.getUserVacationInfoV2(param);
		}else {
			returnList = vacationSvc.getUserVacationInfo(param);
		}
		//System.out.println("#####returnList:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(returnList));
		CoviList jsonArray = (CoviList) returnList.get("list");
		String targetYear = "";
		Date parsingDateFrom = null;
		Date parsingDateTo = null;
		if(jsonArray.size()>0){
			CoviMap obj = (CoviMap) jsonArray.get(0);
			targetYear = obj.get("TargetYear").toString();
			SimpleDateFormat format = new SimpleDateFormat ("yyyy-MM-dd");
			dateForm.put("VacLimitDayFrom", obj.getString("VacLimitDayFrom"));
			dateForm.put("VacLimitDayFromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitDayFrom"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimitDayTo", obj.getString("VacLimitDayTo"));
			dateForm.put("VacLimitDayToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitDayTo"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimitDayFrom"));
			parsingDateTo = format.parse(obj.getString("VacLimitDayTo"));
			dateForm.put("VacLimitDayDiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimitOneFrom", obj.getString("VacLimitOneFrom"));
			dateForm.put("VacLimitOneFromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitOneFrom"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimitOneTo", obj.getString("VacLimitOneTo"));
			dateForm.put("VacLimitOneToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitOneTo"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimitOneFrom"));
			parsingDateTo = format.parse(obj.getString("VacLimitOneTo"));
			dateForm.put("VacLimitOneDiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimitTwoFrom", obj.getString("VacLimitTwoFrom"));
			dateForm.put("VacLimitTwoFromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitTwoFrom"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimitTwoTo", obj.getString("VacLimitTwoTo"));
			dateForm.put("VacLimitTwoToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitTwoTo"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimitTwoFrom"));
			parsingDateTo = format.parse(obj.getString("VacLimitTwoTo"));
			dateForm.put("VacLimitTwoDiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimitLessFrom", obj.getString("VacLimitLessFrom"));
			dateForm.put("VacLimitLessFromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitLessFrom"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimitLessTo", obj.getString("VacLimitLessTo"));
			dateForm.put("VacLimitLessToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimitLessTo"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimitLessFrom"));
			parsingDateTo = format.parse(obj.getString("VacLimitLessTo"));
			dateForm.put("VacLimitLessDiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimit091From", obj.getString("VacLimit091From"));
			dateForm.put("VacLimit091FromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit091From"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimit091To", obj.getString("VacLimit091To"));
			dateForm.put("VacLimit091ToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit091To"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimit091From"));
			parsingDateTo = format.parse(obj.getString("VacLimit091To"));
			dateForm.put("VacLimit091DiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimit092From", obj.getString("VacLimit092From"));
			dateForm.put("VacLimit092FromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit092From"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimit092To", obj.getString("VacLimit092To"));
			dateForm.put("VacLimit092ToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit092To"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimit092From"));
			parsingDateTo = format.parse(obj.getString("VacLimit092To"));
			dateForm.put("VacLimit092DiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimit021From", obj.getString("VacLimit021From"));
			dateForm.put("VacLimit021FromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit021From"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimit021To", obj.getString("VacLimit021To"));
			dateForm.put("VacLimit021ToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit021To"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimit021From"));
			parsingDateTo = format.parse(obj.getString("VacLimit021To"));
			dateForm.put("VacLimit021DiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
			dateForm.put("VacLimit022From", obj.getString("VacLimit022From"));
			dateForm.put("VacLimit022FromForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit022From"),"YYYY년 MM월 DD일"));
			dateForm.put("VacLimit022To", obj.getString("VacLimit022To"));
			dateForm.put("VacLimit022ToForm", ComUtils.convertDateFormatV2(obj.getString("VacLimit022To"),"YYYY년 MM월 DD일"));
			parsingDateFrom = format.parse(obj.getString("VacLimit022From"));
			parsingDateTo = format.parse(obj.getString("VacLimit022To"));
			dateForm.put("VacLimit022DiffDays", TimeUnit.DAYS.convert(Math.abs(parsingDateTo.getTime() - parsingDateFrom.getTime()), TimeUnit.MILLISECONDS)+1);
		}
		//System.out.println("#####dateForm:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(dateForm));
		//사용자 조회일 경우 읽음 처리 
		if(viewType.equalsIgnoreCase("user")) {
			if(empType.equalsIgnoreCase("newEmp") || empType.equalsIgnoreCase("newEmpForNine")) {
				messageID += 1;
			}else if(empType.equalsIgnoreCase("newEmpForTwo")) {
				messageID += 2;
			}
			
			param.clear();
			param.put("year", targetYear);
			param.put("readerCode", urCode);
			param.put("messageId", messageID);
			
			vacationSvc.insertVacationMessageRead(param);
		}
		mav.addObject("result", returnList);
		mav.addObject("dateform", dateForm);
		//2021.07.26 nkpark 회사 휴무일 등록값 전달 for js
		CoviMap attendanceJobList = vacationSvc.getJobWorkOnDays(param);
		mav.addObject("offDaysList", attendanceJobList);
		//-->
		return mav;
	}

	// 연차촉진제 서식출력1,2차 팝업
	@RequestMapping(value = "/goVacationPromotion1Popup", method = RequestMethod.GET)
	public ModelAndView goVacationPromotion1Popup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		
		String year = request.getParameter("year");
		String urCode = Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID"));
		String time = Objects.toString(request.getParameter("time"), "1");
		
		param.put("year", year);
		param.put("urCode", urCode);
		param.put("termDate", year+ (time.equalsIgnoreCase("1") ? firstDate : secondDate));
		param.put("lang",SessionHelper.getSession("lang"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));
		
		CoviMap returnList = vacationSvc.getUserVacationInfoV2(param);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationPromotion1Popup");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 연차촉진제 서식출력3차  팝업
	@RequestMapping(value = "/goVacationPromotion3Popup", method = RequestMethod.GET)
	public ModelAndView goVacationPromotion3Popup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		
		String year = request.getParameter("year");
		String urCode = Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID"));
		//String time = "3";
		
		param.put("year", year);
		param.put("urCode", urCode);
		param.put("termDate", year + thirdDate);
		param.put("lang",SessionHelper.getSession("lang"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));
		
		CoviMap returnList = vacationSvc.getUserVacationInfoV2(param);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationPromotion3Popup");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 사용시기 지정통보서 팝업
	@RequestMapping(value = "/goVacationUsePlanPopup", method = RequestMethod.GET)
	public ModelAndView goVacationUsePlanPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();

		String year = request.getParameter("year");
		String urCode = Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID"));
		String time = Objects.toString(request.getParameter("time"), "1");
		
		param.put("year", year);
		param.put("urCode", urCode);
		param.put("termDate", year+ (time.equalsIgnoreCase("1") ? firstDate : (time.equalsIgnoreCase("2") ? secondDate : thirdDate)));
		param.put("lang",SessionHelper.getSession("lang"));
		param.put("domainID", SessionHelper.getSession("DN_ID"));
		
		CoviMap returnList = vacationSvc.getUserVacationInfoV2(param);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationUsePlanPopup");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 휴가현황 > 부서휴가유형별조회, 휴가관리 > 휴가유형별현황
	@RequestMapping(value = "/getVacationListByType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationListByType(
			HttpServletRequest request,
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "stndCur", required = false, defaultValue="N") String stndCur,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "DEPTID", required = false) String DEPTID,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "hideExtraVacation", required = false, defaultValue = "Y") String hideExtraVacation,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("stndCur", stndCur);
			params.put("schTypeSel", schTypeSel);
			params.put("schEmploySel", schEmploySel);
			params.put("schDeptID", DEPTID);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("hideExtraVacation", hideExtraVacation);
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if (reqType.equals("dept")) {
				params.put("deptCode", SessionHelper.getSession("DEPTID"));
			}
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationDayListByType(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	  * @Method Name : getVacTypeCol
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴가 유형별 현황 휴가 유형 컬럼 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getVacTypeCol.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacTypeCol(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try { 
			CoviMap params = new CoviMap();
			params.put("columnYn", "Y");
			String vacPageSize = request.getParameter("vacPageSize");
			int pageSize = 100;
			if(vacPageSize!=null && !vacPageSize.equals("")){
				pageSize = Integer.parseInt(vacPageSize);
			}
			params.put("pageSize", pageSize);
			params.put("hideExtraVacation",request.getParameter("hideExtraVacation"));
			params.put("pageNo", 1);
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			resultList = vacationSvc.getVacationTypeList(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}

	@RequestMapping(value = "/getUserVacTypeInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserVacTypeInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String vacPageSize = request.getParameter("vacPageSize");
			int pageSize = 100;
			if(vacPageSize!=null && !vacPageSize.equals("")){
				pageSize = Integer.parseInt(vacPageSize);
			}
			params.put("pageSize", pageSize);
			params.put("pageNo", 1);
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			resultList = vacationSvc.getVacationTypeList(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}


	// 휴가현황 팝업
	@RequestMapping(value = "/goVacationInfoPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationInfoPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationInfoPopup");
	}
	
	// 읽음 테이블에 입력
	@RequestMapping(value = "/setVacationMessageRead.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setInsertVacationMessageRead(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("readerCode", SessionHelper.getSession("USERID"));
			params.put("messageId", request.getParameter("messageId"));
			params.put("year", request.getParameter("year"));
			
			int cnt = vacationSvc.insertVacationMessageRead(params);
			
			returnList.put("cnt", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_enteredSuccess"));	//입력 되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 휴가현황 > 부서휴가월별현황, 휴가관리 > 휴가월별현황
	@RequestMapping(value = "/getVacationListByMonth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationListByMonth(
			HttpServletRequest request,
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "stndCur", required = false, defaultValue="N") String stndCur,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "DEPTID", required = false) String DEPTID,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "displayName", required = false) String displayName,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schDeptID", DEPTID);
			params.put("displayName", displayName);
			params.put("stndCur", stndCur);
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if (reqType.equals("dept")) {
				params.put("deptCode", SessionHelper.getSession("DEPTID"));
			}
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationListByMonth(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드(부서휴가월별현황, 휴가월별현황)
	@RequestMapping(value = "/excelDownloadForVacationListByMonth.do")
	public void excelDownloadForVacationListByMonth(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "reqType", required = true) String reqType,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "DEPTID", required = false) String DEPTID,
			@RequestParam(value = "hideExtraVacation", required = false, defaultValue = "Y") String hideExtraVacation,
			@RequestParam(value = "hideEarlyVacation", required = false, defaultValue = "Y") String hideEarlyVacation,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "deptName", required = false) String deptName,
			@RequestParam(value = "displayName", required = false) String displayName,
			@RequestParam(value = "schVacType", required = false) String schVacType
			) throws Exception {
		XSSFWorkbook workbook = null;
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";
			
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schDeptID", DEPTID);
			params.put("displayName", displayName);
			params.put("schVacType", schVacType);
			params.put("EXCEL", "true");
			params.put("hideExtraVacation", hideExtraVacation);
			params.put("hideEarlyVacation", hideEarlyVacation);
			params.put("deptName", deptName);
			
			// 부서휴가월별현황/휴가월별현황 엑셀 다운로드 시 대상
			if (schEmploySel.equals("INOFFICE")) {
				params.put("schEmployTypeTxt", "재직자");
			} else if(schEmploySel.equals("RETIRE")) {
				params.put("schEmployTypeTxt", "퇴직자");
			} else {
				params.put("schEmployTypeTxt", "전체");
			}
			
			if (reqType.equals("dept")) {
				params.put("deptName", SessionHelper.getSession("DEPTNAME"));
				params.put("deptCode", SessionHelper.getSession("DEPTID"));
			}
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			workbook = new XSSFWorkbook();
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationListByMonth_templete.xlsx");
			
			CoviMap resultList = vacationSvc.getVacationListByMonth(params);
			CoviList coviList = (CoviList) resultList.get("list");
			params.put("list",new Gson().fromJson(coviList.toString(), Object.class));
			params.put("title", "휴가월별 사용현황");
			params.put("printdate", StringUtil.getNowDate("yyyy-MM-dd"));
			params.put("target", request.getParameter("deptName"));
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationMonthExcel.xlsx"+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (workbook != null) { try { workbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 연차촉진제 조회내역
	@RequestMapping(value = "/getVacationMessageReadList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationMessageReadList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "messageId", required = false) String strMessageId,
			@RequestParam(value = "empType", required = false) String empType,
			@RequestParam(value = "formType", required = false) String formType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schReadTypeSel", required = false) String schReadTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			int messageId = Integer.parseInt(StringUtil.nullToZero(strMessageId));

			// 0일 경우 2020년 연차촉진 서식
			if(messageId == 0){
				switch(formType.toUpperCase()) {
				case "PLAN":			// 연차 사용계획서
					messageId = 10;
					break;
				case "NOTIFICATION1":	//미사용 연차 사용시기 지정통보서 (1차)
					messageId = 12;
					break;
				case "REQUEST":			//미사용 연차 유급휴가 일수 알림 및 사용시기 지정요청
					messageId = 15;
					break;
				case "NOTIFICATION2":	//미사용 연차 유급휴가 사용시기 지정 통보 (2차)
					messageId = 18;
					break;
				default :
					break;
				}
				
				//사용자 조회일 경우 읽음 처리 
				if(empType.equalsIgnoreCase("newEmp") || empType.equalsIgnoreCase("newEmpForNine")) {
					messageId += 1;
				}else if(empType.equalsIgnoreCase("newEmpForTwo")) {
					messageId += 2;
				}
			}
			
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("formType", formType);
			params.put("empType", empType);
			params.put("year", year);
			params.put("schReadTypeSel", schReadTypeSel);
			params.put("schTypeSel", schTypeSel);
			params.put("schEmploySel", schEmploySel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("messageId", messageId);
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationMessageReadList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 휴가정보-결재용
	@RequestMapping(value = "/getVacationData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("mySummary", "Y");
			params.put("schTxt", request.getParameter("UR_CODE"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));

			returnList.put("Table", vacationSvc.getVacationData(params));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}	
	
	/**
	 * 휴가신청 시 해당 날짜에 이미 휴가가 신청된 경우
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getVacationInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVacationInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultArray = null;
		
		try
		{
			CoviList vacationInfo = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("vacationInfo")));
			
			CoviMap params = new CoviMap();
			params.put("vacationInfo", vacationInfo);
			params.put("chkType", paramMap.get("chkType"));
			params.put("userCode", paramMap.get("userCode"));
			
			resultArray = vacationSvc.getVacationInfo(params);
			
			returnList.put("dupVac", resultArray);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("error", Return.FAIL);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
		
	// 휴가관리 홈
	@RequestMapping(value = "/getVacationInfoForHome.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationInfoForHome(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		String vacationPolicy = null;
		try {
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("year", request.getParameter("year"));
			params.put("urCode", SessionHelper.getSession("USERID"));
			params.put("deptCode", SessionHelper.getSession("DEPTID"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat)); //timezone 적용 현재시간
			
			resultList = vacationSvc.getVacationInfoForHome(params);
			vacationPolicy = vacationSvc.getVacationPolicy();
			
			returnList.put("list", resultList.get("list"));
			returnList.put("todayList", resultList.get("todayList"));
			returnList.put("vacationPolicy",vacationPolicy);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 연차 사용시기 입력 팝업
	@RequestMapping(value = "/goVacationUsePlanDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationUsePlanDetailPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("year", request.getParameter("year"));
		param.put("type", request.getParameter("empType"));
		param.put("urCode", Objects.toString(request.getParameter("urCode"), SessionHelper.getSession("USERID")));
		param.put("domainID", SessionHelper.getSession("DN_ID"));
		param.put("domainCode", SessionHelper.getSession("DN_Code"));
		
		CoviMap returnList = vacationSvc.getVacationUsePlan(param);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationUsePlanDetailPopup");
		mav.addObject("result", returnList);
		mav.addObject("rangeDateFrom", request.getParameter("rangeDateFrom"));
		mav.addObject("rangeDateTo", request.getParameter("rangeDateTo"));
		mav.addObject("CreateMethod", request.getParameter("CreateMethod"));
		
		return mav;
	}
	
	// 연차 사용시기 입력
	@RequestMapping(value = "/insertVacationUsePlan.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertVacationUsePlan(/* @RequestBody UsePlanVO usePlanVO */
			@RequestBody CoviMap planObj
	) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("usePlan", planObj.toString()); 
			params.put("year",	planObj.get("year")); 
			params.put("urCode", planObj.get("urCode"));
			
			int result = vacationSvc.insertVacationUsePlan(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Common_10"));	//저장 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	// 휴가취소처리 > 문서연결 팝업
	@RequestMapping(value = "/goVacationCancelDocPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationCancelDocPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationCancelDocPopup");
	}
	
	// 휴가취소처리 > 문서연결
	@RequestMapping(value = "/getVacationCancelDocList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationCancelDocList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("urCode", request.getParameter("urCode"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			resultList = vacationSvc.getVacationCancelDocList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	// 연차촉진제관리 > 미사용연차계획 저장내역 조회
	@RequestMapping(value = "/getVacationUsePlanList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationUsePlanList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "empType", required = false) String empType,
			@RequestParam(value = "formType", required = false) String formType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("term", request.getParameter("term"));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("year", year);
			params.put("empType", empType);
			params.put("formType", formType);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			if(empType != null && empType.equalsIgnoreCase("normal")) {
				params.put("baseDate", year + RedisDataUtil.getBaseConfig(formType + "NormalDate"));
			}
			
			resultList = vacationSvc.getVacationUsePlanList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	 
	// 엑셀 다운로드(연차촉진제 1차 조회내역, 연차촉진제 2차 조회내역, 사용시기 지정통보 조회내역)
	@RequestMapping(value = "/excelDownloadForVacationMessageReadList.do")
	public void excelDownloadForVacationMessageReadList(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "messageId", required = false) String strMessageId,
			@RequestParam(value = "empType", required = false) String empType,
			@RequestParam(value = "formType", required = false) String formType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schReadTypeSel", required = false) String schReadTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt
			) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String title = "연차촉진제 조회내역";
			String FileName = "연차촉진제_조회내역.xlsx"; 
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";
			
			int messageId = Integer.parseInt(StringUtil.nullToZero(strMessageId));
			
			// 0일 경우 2020년 연차촉진 서식
			if(messageId == 0){
				
				switch(formType.toUpperCase()) {
				case "PLAN":			// 연차 사용계획서
					title = "연차사용계획서 조회내역";
					FileName = "연차사용계획서_조회내역.xlsx"; 
					messageId = 10;
					break;
				case "NOTIFICATION1":	//미사용 연차 사용시기 지정통보서 (1차)
					title = "연차촉진제 1차 조회내역";
					FileName = "연차촉진제_1차_조회내역.xlsx"; 
					messageId = 12;
					break;
				case "REQUEST":			//미사용 연차 유급휴가 일수 알림 및 사용시기 지정요청
					title = "사용시기 지정요청 1차 조회내역";
					FileName = "사용시기_지정요청_1차조회내역.xlsx"; 
					messageId = 15;
					break;
				case "NOTIFICATION2":	//미사용 연차 유급휴가 사용시기 지정 통보 (2차)
					title = "연차촉진제 2차 조회내역";
					FileName = "연차촉진제_2차_조회내역.xlsx"; 
					messageId = 18;
					break;
				default : 
					break;
				}
				
				//사용자 조회일 경우 읽음 처리 
				if(empType.equalsIgnoreCase("newEmp") || empType.equalsIgnoreCase("newEmpForNine")) {
					messageId += 1;
				}else if(empType.equalsIgnoreCase("newEmpForTwo")) {
					messageId += 2;
				}
			}
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("formType", formType);
			params.put("empType", empType);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schReadTypeSel", schReadTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("messageId", messageId);
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationMessageReadList_templete.xlsx");
			
			CoviMap resultList = vacationSvc.getVacationMessageReadList(params);
			CoviList jArray = (CoviList) resultList.get("list");
			
			if( RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
				String urTimeZone = SessionHelper.getSession("UR_TimeZone");		//사용자 타임존 
				
				for(Object obj : jArray){
					CoviMap jObj = (CoviMap) obj;
					String readDate = jObj.getString("ReadDate");
					
					if(readDate.isEmpty()) {
						continue;
					}
					
					jObj.put("ReadDate", ComUtils.TransLocalTime(readDate, ComUtils.UR_DateFullFormat, urTimeZone));
				}
			}
			
			
			params.put("list",new Gson().fromJson(jArray.toString(), Object.class));
			params.put("cnt",resultList.getInt("cnt"));
			params.put("title", title);
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+URLEncoder.encode(FileName,"UTF-8")+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 엑셀 다운로드(미사용연차계획 저장내역 조회)
	@RequestMapping(value = "/excelDownloadForVacationUsePlanList.do")
	public void excelDownloadForVacationUsePlanList(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "empType", required = false) String empType,
			@RequestParam(value = "formType", required = false) String formType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt
			) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("empType", empType);
			params.put("formType", formType);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("term", request.getParameter("term"));
			params.put("lang",SessionHelper.getSession("lang"));
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			if(empType != null && empType.equalsIgnoreCase("normal")) {
				params.put("baseDate", year + RedisDataUtil.getBaseConfig(formType + "NormalDate"));
			}
			
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationUsePlanList_templete.xlsx");
			
			String FileName = "미사용연차계획_저장내역";
			switch(formType.toUpperCase()) {
			case "PLAN": 
				FileName = "미사용연차계획_저장내역_사용계획서"; 
				break;
			case "NOTIFICATION1": 
				FileName = "미사용연차계획_저장내역_1차"; 
				break;
			case "NOTIFICATION2": 
				FileName = "미사용연차계획_저장내역_2차"; 
				break;
			default :
				break;
			}
			
			CoviMap resultList = vacationSvc.getVacationUsePlanList(params);
			params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
			params.put("cnt",resultList.getJSONArray("list").size());
			params.put("title", FileName);
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+URLEncoder.encode(FileName + ".xlsx","UTF-8")+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 나의휴가현황 > 버튼 visible
	@RequestMapping(value = "/getPromotionBtnVisible.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPromotionBtnVisible(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("domainID", SessionHelper.getSession("DN_ID"));
			
			returnList.put("data", vacationSvc.getPromotionBtnVisible(param).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	// 스케줄러 (일주기 호출)- 신규입사자 월차 자동증가 + 연차 촉진 대상자 메일 발송
	@RequestMapping(value = "/autoIncreaseMonthlyVacation.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap autoCreateMonthlyVacation(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		int rst = 0;
		try {
			String domainCode = request.getParameter("DN_Code");
			//System.out.println("####domainCode:"+domainCode);
			if(domainCode != null && !domainCode.isEmpty()) {

				CoviMap param = new CoviMap();
				param.put("domainCode", domainCode);

				CoviMap reqMap = new CoviMap();
				reqMap.put("CompanyCode", domainCode);

				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				CoviMap vacConfigMap = (CoviMap) returnJsonArray.get(0);
				String CreateMethod = vacConfigMap.getString("CreateMethod");//F:회계년도 기준, J:입사일 기준
				String IsAuto = vacConfigMap.getString("IsAuto");
				int InitCnt = vacConfigMap.getInt("InitCnt");
				int IncCnt = vacConfigMap.getInt("IncCnt");
				int MaxCnt = vacConfigMap.getInt("MaxCnt");
				int IncTerm = vacConfigMap.getInt("IncTerm");
				String RemMethod = vacConfigMap.getString("RemMethod");
				String ReqInfoMethod = vacConfigMap.getString("ReqInfoMethod");
				String IsRemRenewal = vacConfigMap.getString("IsRemRenewal"); // 이월연차갱신 
				String YearCreateAnnualVacation = vacConfigMap.getString("YearCreateAnnualVacation"); // 만 1년까지만 월차 자동 생성
				param.put("InitCnt", InitCnt);
				param.put("IncCnt", IncCnt);
				param.put("MaxCnt", MaxCnt);
				param.put("CreateMethod", CreateMethod);
				param.put("IncTerm", IncTerm);
				param.put("RemMethod", RemMethod);
				param.put("domainCode", domainCode);
				param.put("IsRemRenewal", IsRemRenewal);
				param.put("YearCreateAnnualVacation", YearCreateAnnualVacation);
				if (IsAuto.equals("Y")) {
					if (CreateMethod.equals("F")) {//회계연도 기준(기존)
						// 연차 생성안된 사용자 0으로 먼저 생성하기.
						vacationSvc.insertNewAnnualVacation(param);
						vacationSvc.autoIncreaseMonthlyVacation(param);
					} else {//입사일 기준
						// 연차 생성안된 사용자 0으로 먼저 생성하기.
						vacationSvc.insertNewAnnualVacationV2(param);
						//매일 오늘기준 최근 1년 내 입사자 의 입사일이 1달 만근인 경우 휴가+1 처리
						vacationSvc.autoIncreaseMonthlyVacationV2(param);
						//입사 만 1년 이상 직원의 년차 지급 처리 3년차 부터 15+1(2년단위 +1개)가산
						rst = vacationSvc.insertCreateAnnualVacationV2(param);
					}
				}

				ExecutorService executorServiceSendMail = Executors.newCachedThreadPool();
				executorServiceSendMail.submit(() -> {

					// 연차 촉진 대상자 메일 발송
					if(ReqInfoMethod!=null && ReqInfoMethod.equals("Y")) {
						CoviMap params = new CoviMap();
						params.put("domainCode",domainCode);
						params.put("lang",SessionHelper.getSession("lang"));
						CoviList targetList = null;
						try {
							targetList = vacationSvc.getVacationPromotionTargetList(params);
						} catch (NullPointerException e) {
							throw new NullPointerException();
						} catch (Exception e) {
							throw new RuntimeException(e);
						}
						//UserCode,DisplayName,EnterDate,ReqType,RetireDate,CreateMethod,
						//IsOneYear,OneDate,TwoDate,LessOneDate9,LessTwoDate9,LessOneDate2,LessTwoDate2
						for(Object targetInfo : targetList) {
							CoviMap obj = (CoviMap) targetInfo;
							CoviMap mailForm = new CoviMap();
							String receiverCode = "[{\"Type\":\"UR\",\"Code\":\""+obj.getString("UserCode")+"\"}]";
							mailForm.put("ReceiverInfo", receiverCode);
							mailForm.put("ReceiverMailAddress", obj.getString("MailAddress"));
							mailForm.put("ReqType", obj.getString("ReqType"));
							mailForm.put("domainCode",domainCode);

							try {
								CoviMap rstJsonObj = mailSenderSvc.SendMailVacationPromotionInfoNotice(mailForm, vacConfigMap);
							} catch (NullPointerException e) {
								throw new NullPointerException();
							} catch (Exception e) {
								throw new RuntimeException(e);
							}


						}

					}// end 연차 촉진 대상자 메일 발송

				});

			}//end if DN_Code

			returnList.put("status", Return.SUCCESS);
			returnList.put("rst", rst);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	// 이월연차 데이터 패치용
	@RequestMapping(value = "/updateLastVacDay.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap updateLastVacDay(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String domainCode = request.getParameter("DN_Code");
			String domainId = request.getParameter("DN_ID");
			if(domainCode != null && !domainCode.isEmpty() && domainId != null && !domainId.isEmpty()) {

				CoviMap param = new CoviMap();
				param.put("domainCode", domainCode);

				CoviMap reqMap = new CoviMap();
				reqMap.put("CompanyCode", domainCode);

				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				CoviMap vacConfigMap = (CoviMap) returnJsonArray.get(0);
				String CreateMethod = vacConfigMap.getString("CreateMethod");//F:회계년도 기준, J:입사일 기준
				String IsAuto = vacConfigMap.getString("IsAuto");
				int InitCnt = vacConfigMap.getInt("InitCnt");
				int IncCnt = vacConfigMap.getInt("IncCnt");
				int MaxCnt = vacConfigMap.getInt("MaxCnt");
				int IncTerm = vacConfigMap.getInt("IncTerm");
				String RemMethod = vacConfigMap.getString("RemMethod");
				String ReqInfoMethod = vacConfigMap.getString("ReqInfoMethod");
				param.put("InitCnt", InitCnt);
				param.put("IncCnt", IncCnt);
				param.put("MaxCnt", MaxCnt);
				param.put("CreateMethod", CreateMethod);
				param.put("IncTerm", IncTerm);
				param.put("RemMethod", RemMethod);
				param.put("domainCode", domainCode);
				param.put("lastVacDayReCalcDate", RedisDataUtil.getBaseConfig("LastVacDayReCalcDate",domainId));
				if (IsAuto.equals("Y")) {
					if (CreateMethod.equals("F")) {//회계연도 기준(기존)
						// 데이터 재계산
						vacationSvc.updateLastLongVacDay(param);
					} else {//입사일 기준
						// 데이터 재계산
						vacationSvc.updateLastLongVacDayV2(param);
					}
				}

			}//end if DN_Code

			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 스케줄러 - 신규입사자 06/30 연차 정산
	@RequestMapping(value = "/autoUpdateAnnualVacation.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap autoUpdateAnnualVacation(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String domainCode = request.getParameter("DN_Code");

			if(domainCode != null && !domainCode.isEmpty()) {

				CoviMap param = new CoviMap();
				param.put("domainCode", domainCode);


				CoviMap reqMap = new CoviMap();
				reqMap.put("CompanyCode", domainCode);
				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				CoviMap returnMap = (CoviMap) returnJsonArray.get(0);
				String CreateMethod = returnMap.getString("CreateMethod");//F:회계년도 기준, J:입사일 기준
				String IsAuto = returnMap.getString("IsAuto");
				String YearCreateAnnualVacation = returnMap.getString("YearCreateAnnualVacation"); // 만 1년까지만 월차 자동 생성

				if(IsAuto.equals("Y") && CreateMethod.equals("F") && YearCreateAnnualVacation.equals("N")) {// 회계연도 기준(기존) 일때만 동작

					int InitCnt = returnMap.getInt("InitCnt");
					int IncCnt = returnMap.getInt("IncCnt");
					int MaxCnt = returnMap.getInt("MaxCnt");
					int IncTerm = returnMap.getInt("IncTerm");
					String RemMethod = returnMap.getString("RemMethod");
					param.put("InitCnt", InitCnt);
					param.put("IncCnt", IncCnt);
					param.put("MaxCnt", MaxCnt);
					param.put("CreateMethod", CreateMethod);
					param.put("IncTerm", IncTerm);
					param.put("RemMethod", RemMethod);
					param.put("domainCode", domainCode);
					vacationSvc.autoUpdateAnnualVacation(param);
					//입사일 기준 휴가 생성은 매년 6월 30일 정산 처리 필요 없음.
				}

			}
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 스케줄러 - 1/1 연차 자동 생성
	@RequestMapping(value = "/autoCreateAnnualVacation.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap autoCreateAnnualVacation(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String domainCode = request.getParameter("DN_Code");

			if(domainCode != null && !domainCode.isEmpty()) {

				CoviMap param = new CoviMap();
				param.put("domainCode", domainCode);

				CoviMap reqMap = new CoviMap();
				reqMap.put("CompanyCode", domainCode);
				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				Object obj = returnJsonArray.get(0);
				CoviMap returnMap = (CoviMap) obj;
				String CreateMethod = returnMap.getString("CreateMethod");//F:회계년도 기준, J:입사일 기준
				String IsAuto = returnMap.getString("IsAuto");
				int InitCnt = returnMap.getInt("InitCnt");
				int IncCnt = returnMap.getInt("IncCnt");
				int MaxCnt = returnMap.getInt("MaxCnt");
				int IncTerm = returnMap.getInt("IncTerm");
				String RemMethod = returnMap.getString("RemMethod");
				param.put("InitCnt", InitCnt);
				param.put("IncCnt", IncCnt);
				param.put("MaxCnt", MaxCnt);
				param.put("CreateMethod", CreateMethod);
				param.put("IncTerm", IncTerm);
				param.put("RemMethod", RemMethod);

				if(IsAuto.equals("Y") && CreateMethod.equals("F")) {// 회계연도 기준(기존) 일때만 동작
					vacationSvc.autoCreateAnnualVacation(param);
				}//입사일 기준은 매일 동작 스케쥴러 쪽에서 일단위 1년 만근 자 체크 하여 할당

			}
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	@RequestMapping(value = "/updateDeptInfo.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap updateDeptInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("domainCode", SessionHelper.getSession("DN_Code"));
			
			vacationSvc.updateDeptInfo(param);
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	  * @Method Name : getVacationTypeList
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴가 유형 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getVacationTypeList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationTypeList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
		String sortColumn = "";
		String sortDirection = "";
		
		if(sortBy.length > 1) {
			sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
			sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
		}
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("showAll", request.getParameter("showAll"));
		params.put("sortColumn", sortColumn);
		params.put("sortDirection", sortDirection);
		
		try{
			resultList = vacationSvc.getVacationTypeList(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("cnt", resultList.get("cnt"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch(NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		
		return returnList;
		
	}
	
	/**
	  * @Method Name : updVacationType
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :휴가 유형 수정
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/updVacationType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updVacationType(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try{
//			String IsUse = request.getParameter("IsUse");
//			String Reserved1 = request.getParameter("Reserved1");
//			String ReservedInt = request.getParameter("ReservedInt");
			String CodeID = request.getParameter("CodeID");
			//resultList = attendVacationSvc.getVacationTypeList(params);
			
			CoviMap params = new CoviMap();
			params.put("CodeName", request.getParameter("CodeName"));
			params.put("MultiCodeName", request.getParameter("MultiCodeName"));
			params.put("IsUse", request.getParameter("IsUse"));
			params.put("Reserved1", request.getParameter("Reserved1"));
			params.put("Reserved2", request.getParameter("Reserved2"));
			params.put("Reserved3", request.getParameter("Reserved3"));
			params.put("ReservedInt", request.getParameter("ReservedInt"));
			params.put("SortKey", request.getParameter("SortKey"));

			params.put("CodeID",CodeID);
			 
			vacationSvc.updVacationType(params);
			 
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch(NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	

	/**
	  * @Method Name : goVacationTypeAddPopup
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴가유형등록 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goVacationTypeAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationTypeAddPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav =  new ModelAndView("user/vacation/VacationTypeAddPopup");
		if (!"".equals(request.getParameter("Code"))){
			CoviMap params = new CoviMap();
			params.put("Code", request.getParameter("Code"));
			params.put("pageNo", 1); 
			params.put("pageSize", 10);
			CoviMap resultList = vacationSvc.getVacationTypeList(params);
			CoviList list = (CoviList)resultList.get("list");
			CoviMap detailMap = (CoviMap)list.get(0);

			mav.addObject("CodeID",detailMap.get("CodeID"));
			mav.addObject("Code",detailMap.get("Code"));
			mav.addObject("IsUse",detailMap.get("IsUse"));
			
			mav.addObject("SortKey",detailMap.get("SortKey"));
			mav.addObject("CodeName",detailMap.get("CodeName"));
			mav.addObject("MultiCodeName",detailMap.get("MultiCodeName"));
			
			mav.addObject("Reserved1",detailMap.get("Reserved1"));
			mav.addObject("Reserved2",detailMap.get("Reserved2"));
			mav.addObject("Reserved3",detailMap.get("Reserved3"));
			mav.addObject("ReservedInt",detailMap.get("ReservedInt"));

			mav.addObject("mode", "U");
		}
		else {
			mav.addObject("IsUse","Y");
			mav.addObject("Reserved1","Y");
			mav.addObject("Reserved2","Y");
			mav.addObject("Reserved3","1");
			mav.addObject("mode", "A");
		}	
		return mav;
	}
	

	/**
	  * @Method Name : setVacationType
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴가유형 등록
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/setVacationType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setVacationType(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			params.put("Code", request.getParameter("Code"));
			params.put("CodeName", request.getParameter("CodeName"));
			params.put("MultiCodeName", request.getParameter("MultiCodeName"));
			params.put("IsUse", request.getParameter("IsUse"));
			params.put("Reserved1", request.getParameter("Reserved1"));
			params.put("Reserved2", request.getParameter("Reserved2"));
			params.put("Reserved3", request.getParameter("Reserved3"));
			params.put("ReservedInt", request.getParameter("ReservedInt"));
			params.put("SortKey", request.getParameter("SortKey"));
			 
			vacationSvc.setVacationType(params);
			 
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	/**
	  * @Method Name : deleteVacationType
	  * @작성일 : 2020. 4. 28.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 휴가유형 삭제
	  * @param request
	  * @param response
	  * @param CodeID
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/deleteVacationType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteVacationType(HttpServletRequest request, HttpServletResponse response
			,@RequestParam(required=false) String[] CodeID) throws Exception {
		CoviMap returnList = new CoviMap();
		try{
				
			for(int i=0;i<CodeID.length;i++){
				CoviMap params = new CoviMap();
				params.put("CodeID", CodeID[i]);
				vacationSvc.delVacationType(params);
			}

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * @Method Name : getDeptList
	 * @Method 설명 : 권한있는 부서 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params= new CoviMap();
			params.put("DeptCode", SessionHelper.getSession("DEPTID"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("isAdmin", "Y");
			
			/*
			params.put("isAdmin", "N");
			if(SessionHelper.getSession("isAdmin").equalsIgnoreCase("Y")) {
				CoviList assignedDomain = ComUtils.getAssignedDomainCode();
				
				if( assignedDomain.isEmpty() || assignedDomain.contains(params.getString("CompanyCode")) ) {
					params.put("isAdmin", "Y");
				}
			}
			*/
			
			returnList.put("deptList",vacationSvc.getDeptList(params).get("deptList"));
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
	
		return returnList;
	}
	
	
	@RequestMapping(value = "/selectVacationListByAll.do")
	public  @ResponseBody CoviMap selectVacationListByAll(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap authParam = new CoviMap();
		
		authParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		authParam.put("DN_ID", SessionHelper.getSession("DN_ID"));
		authParam.put("lang",SessionHelper.getSession("lang"));
		authParam.put("isAdmin","Y");
		authParam.put("sDate", request.getParameter("sDate"));
		CoviMap resultList = vacationSvc.selectVacationListByAll(authParam);
		returnList.put("deptList", resultList.get("deptList"));
		returnList.put("vacList", resultList.get("vacList"));
		returnList.put("result", "ok");
		returnList.put("status", Return.SUCCESS);
		return returnList;
	}
	
	// 휴가사용목록
	@RequestMapping(value = "/getVacationListByUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationListByUse(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
		) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
			
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			String VacTypeArr = StringUtil.replaceNull(request.getParameter("VacTypeArr"));
			String VacTypeArrs[] = VacTypeArr.split(",");
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			if (mode.equals("DEPT")){
				params.put("DEPTID",  request.getParameter("DEPTID"));
			}
			else{
				params.put("DEPTID",  SessionHelper.getSession("DEPTID"));
			}	
			params.put("schUrName",  request.getParameter("schUrName"));
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			
			params.put("month", ComUtils.removeMaskAll(request.getParameter("month")));
			params.put("vacFlag",  request.getParameter("vacFlag"));
				
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("VacTypeArrs",  VacTypeArrs);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationListByUse(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	 //@Override
	 @RequestMapping(value = "/excelDownloadForVacationListByUse.do")
	 public void excelDownloadForVacationListByUse(HttpServletRequest request,			HttpServletResponse response,
				@RequestParam(value = "year", required = false) String year,
				@RequestParam(value = "reqType", required = false) String reqType,
				@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
				@RequestParam(value = "schTxt", required = false) String schTxt,
				@RequestParam(value = "urCode", required = false) String urCode) {
		 SXSSFWorkbook resultWorkbook = null;
	    try {
	    	String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";
			
	    	String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
	    	Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "VacaltionList"+dateFormat.format(today)+".xlsx";
	
	        
	        CoviMap params = new CoviMap();
			String lang = SessionHelper.getSession("lang");
			
			String VacTypeArr = StringUtil.replaceNull(request.getParameter("VacTypeArr"));
			String VacTypeArrs[] = VacTypeArr.split(",");
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang",lang);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("year", year);
			params.put("reqType", reqType);
			
			if (mode.equals("DEPT")){
				params.put("DEPTID",  request.getParameter("DEPTID"));
			}
			else{
				params.put("DEPTID",  SessionHelper.getSession("DEPTID"));
			}	
			params.put("schUrName",  request.getParameter("schUrName"));
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			
			params.put("month", ComUtils.removeMaskAll(request.getParameter("month")));
			params.put("vacFlag",  request.getParameter("vacFlag"));
			params.put("VacTypeArrs",  VacTypeArrs);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			CoviMap resultList  = vacationSvc.getVacationListByUse(params);
			CoviList excelList = (CoviList)resultList.get("list");
	
			List<HashMap> colInfo = new java.util.ArrayList<HashMap>();
			
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lblNyunDo",lang)); put("colWith","50"); put("colKey","VacYear");  put("colAlign","CENTER");  }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_DraftDate",lang)); put("colWith","80"); put("colKey","AppDate"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_apv_accepted",lang)); put("colWith","80"); put("colKey","EndDate"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_ParentDeptName",lang)); put("colWith","100"); put("colKey","UpDeptName"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_dept",lang)); put("colWith","100"); put("colKey","DeptName"); }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_name",lang)); put("colWith","50"); put("colKey","DisplayName"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, Object>() {{put("colName",DicHelper.getDic("lbl_UserCode",lang)); put("colWith","50"); put("colKey","UR_Code"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_apv_jobposition",lang)); put("colWith","50"); put("colKey","JobPositionName"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Gubun",lang)); put("colWith","70"); put("colKey","VacText"); put("colAlign","CENTER"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_startdate",lang)); put("colWith","80"); put("colKey","Sdate"); put("colAlign","CENTER");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_EndDate",lang)); put("colWith","80"); put("colKey","Edate"); put("colAlign","CENTER");}});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_used_days",lang)); put("colWith","50"); put("colKey","VacDay"); put("colAlign","CENTER");put("colType","F"); }});
			colInfo.add(new HashMap<String, String>() {{put("colName",DicHelper.getDic("lbl_Reason",lang)); put("colWith","200"); put("colKey","Reason"); put("colAlign","LEFT");  }});

			String excelTitle= year +" "+ DicHelper.getDic("lbl_vacationMsg47",lang);
	        		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, excelList);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
			try { resultWorkbook.close(); } catch(IOException ignore) { LOGGER.error(ignore.getLocalizedMessage(), ignore);}
		
	    } catch (IOException e) {
	        LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	        LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	        LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	        LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	        if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
	    }
	}

	// 기타휴가목록 조회
	@RequestMapping(value = "/getVacationExtraList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationExtraList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("reqType", reqType);

			params.put("urCode", urCode);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}

			resultList = vacationSvc.getVacationExtraList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 기타연차관리 엑셀 다운로드
	@RequestMapping(value = "/excelDownVacationExtraList.do")
	public void excelDownVacationExtraList(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "99999" ) int pageSize

		) throws Exception {
			CoviMap resultList = new CoviMap();

			ByteArrayOutputStream baos = null;
			InputStream is = null;
			FileInputStream fis = null;
			Workbook resultWorkbook = null;
			
			try {
				String sortBy = request.getParameter("sortBy");

				String sortKey =  ( sortBy != null  && !sortBy.isEmpty())? sortBy.split(" ")[0] : "";
				String sortDirec =  ( sortBy != null && !sortBy.isEmpty())? sortBy.split(" ")[1] : "";

				CoviMap params = new CoviMap();
				params.put("lang",SessionHelper.getSession("lang"));
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				params.put("domainCode",SessionHelper.getSession("DN_Code"));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("year", year);
				params.put("reqType", reqType);

				params.put("urCode", urCode);
				params.put("schTypeSel", schTypeSel);
				params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
				
				String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
				if(!orgMapOrderSet.equals("")) {
					String[] orgOrders = orgMapOrderSet.split("\\|");
					params.put("orgOrders", orgOrders);
				}
				
				String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationExtraList_templete.xlsx");

				resultList = vacationSvc.getVacationExtraList(params);

				String currentDate =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
				params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
				params.put("title", "기타 연차 관리");

				baos = new ByteArrayOutputStream();
				XLSTransformer transformer = new XLSTransformer();
				fis = new FileInputStream(ExcelPath);
				is = new BufferedInputStream(fis);
				resultWorkbook = transformer.transformXLS(is, params);
				resultWorkbook.write(baos);
				
				response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationExtraListExcel_"+currentDate+".xlsx"+"\";");
				response.setHeader("Content-Description", "JSP Generated Data");
				response.setContentType("application/vnd.ms-excel;charset=utf-8");
				response.getOutputStream().write(baos.toByteArray());
				response.getOutputStream().flush();
				
			} catch (IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (ArrayIndexOutOfBoundsException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} finally {
				if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			}

	}
	
	// 기타연차관리 엑셀 다운로드
	@RequestMapping(value = "/excelDownVacationRewardList.do")
	public void excelDownVacationRewardList(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "99999" ) int pageSize

		) throws Exception {
			CoviMap resultList = new CoviMap();

			ByteArrayOutputStream baos = null;
			InputStream is = null;
			FileInputStream fis = null;
			Workbook resultWorkbook = null;
			
			try {
				String sortBy = request.getParameter("sortBy");

				String sortKey =  ( sortBy != null  && !sortBy.isEmpty())? sortBy.split(" ")[0] : "";
				String sortDirec =  ( sortBy != null && !sortBy.isEmpty())? sortBy.split(" ")[1] : "";

				CoviMap params = new CoviMap();
				params.put("lang",SessionHelper.getSession("lang"));
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				params.put("domainCode",SessionHelper.getSession("DN_Code"));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("year", year);
				params.put("reqType", reqType);

				params.put("urCode", urCode);
				params.put("schTypeSel", schTypeSel);
				params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
				
				String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationExtraList_templete.xlsx");

				resultList = vacationSvc.getVacationRewardList(params);

				String currentDate =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
				params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
				params.put("title", "보상 휴가 관리");

				baos = new ByteArrayOutputStream();
				XLSTransformer transformer = new XLSTransformer();
				fis = new FileInputStream(ExcelPath);
				is = new BufferedInputStream(fis);
				resultWorkbook = transformer.transformXLS(is, params);
				resultWorkbook.write(baos);
				
				response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationExtraListExcel_"+currentDate+".xlsx"+"\";");
				response.setHeader("Content-Description", "JSP Generated Data");
				response.setContentType("application/vnd.ms-excel;charset=utf-8");
				response.getOutputStream().write(baos.toByteArray());
				response.getOutputStream().flush();
				
			} catch (IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (ArrayIndexOutOfBoundsException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} finally {
				if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
				if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			}

	}
	
	// 보상휴가목록 조회
	@RequestMapping(value = "/getVacationRewardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationRewardList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("reqType", reqType);

			params.put("urCode", urCode);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                params.put("orgOrders", orgOrders);
			}

			resultList = vacationSvc.getVacationRewardList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	// 공통휴가목록 조회
	@RequestMapping(value = "/getVacationManageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationManageList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);

			params.put("urCode", urCode);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}

			resultList = vacationSvc.getVacationManageList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
		
	// 년도별 휴가사용 현황
	@RequestMapping(value = "/getVacationListByKind.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationListByKind(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "urCode", required = false) String urCode
	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("year", year);
			params.put("reqType", reqType);

			params.put("urCode", urCode==null?SessionHelper.getSession("USERID"):urCode);
			params.put("schTypeSel", schTypeSel);
			if (reqType != null && reqType.equals("myVacation")){
				params.put("schTxt", SessionHelper.getSession("USERID"));
			}else{
				if (schTxt == null) schTxt		=SessionHelper.getSession("USERID");			
				params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			}	
			
			resultList = vacationSvc.getVacationListByKind(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	@RequestMapping(value = "/getVacationByCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationByCode(@RequestBody Map<String, Object> reqMap ) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			List urCodeList = (List)reqMap.get("urCodeList");

			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("year", reqMap.get("year").toString());
			String urCode = "";
			if(reqMap.get("urCode")!=null && !reqMap.get("urCode").toString().equals("")){
				urCode = reqMap.get("urCode").toString();
			}
			params.put("urCode", urCode);
			params.put("codeID", reqMap.get("codeID").toString());
			params.put("calMonth", reqMap.get("calMonth").toString());

			resultList = vacationSvc.getVacationByCode(params, urCodeList);

			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	// 발생이력 목록 조회
	@RequestMapping(value = "/getVacationPlanHistList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationPlanHistList(
			HttpServletRequest request,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			String VacTypeArr = StringUtil.replaceNull(request.getParameter("VacTypeArr"));
			String VacTypeArrs[] = VacTypeArr.split(",");
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("vacFlag",  request.getParameter("vacFlag"));
			params.put("VacTypeArrs",  VacTypeArrs);
			params.put("urCode", SessionHelper.getSession("USERID"));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}

			resultList = vacationSvc.getVacationPlanHistList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 발생이력 목록 조회
	@RequestMapping(value = "/excelDownVacationOccurrenceHist.do", method = {RequestMethod.GET, RequestMethod.POST})
	public /*@ResponseBody JSONObject*/ void excelDownVacationOccurrenceHist(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schEmploySel", required = false) String schEmploySel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "vacFlag", required = false) String vacFlag,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "99999") int pageSize

	) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		XSSFWorkbook workbook = null;
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;

		try {

			String sortBy = request.getParameter("sortBy");

			String sortKey =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.isEmpty() )? sortBy.split(" ")[1] : "";

			String VacTypeArr = StringUtil.replaceNull(request.getParameter("VacTypeArr"));
			String VacTypeArrs[] = VacTypeArr.split(",");
			
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("domainCode",SessionHelper.getSession("DN_Code"));
			params.put("year", year);
			params.put("schEmploySel", schEmploySel);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", ComUtils.RemoveSQLInjection(schTxt, 100));
			params.put("urCode", SessionHelper.getSession("USERID"));
			params.put("vacFlag",  vacFlag);
			params.put("VacTypeArrs",  VacTypeArrs);

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}

			workbook = new XSSFWorkbook();
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//VacationOccrrenceHist_templete.xlsx");

			resultList = vacationSvc.getVacationPlanHistList(params);
			//System.out.println("#####resultList:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(resultList));

			String currentDate =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");
			params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
			params.put("title", "휴가 발생이력");
			params.put("printdate", StringUtil.getNowDate("yyyy-MM-dd"));

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+"VacationOccrrenceHistExcel_"+currentDate+".xlsx"+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (workbook != null) { try { workbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	// 발생이력 목록 조회
		@RequestMapping(value = "/selectVacationFlagSelList.do", method = RequestMethod.POST)
		public @ResponseBody CoviMap selectVacationFlagSelList(HttpServletRequest request, HttpServletResponse response) throws Exception {
			CoviMap returnList = new CoviMap();
			CoviMap resultList = new CoviMap();

			try {
				CoviMap params = new CoviMap();
				
				params.put("lang",SessionHelper.getSession("lang"));
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				
				resultList = vacationSvc.selectVacationFlagSelList(params);

				returnList.put("list", resultList.get("list"));
				returnList.put("status", Return.SUCCESS);
			} catch (ArrayIndexOutOfBoundsException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			}

			return returnList;
		}
		
	// 연차촉진 기간설정 목록 조회
	@RequestMapping(value = "/getVacationPromotionDateList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationPromotionList(
			HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));

			resultList = vacationSvc.getVacationPromotionDateList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 연차촉진 기간설정 목록 조회
	@RequestMapping(value = "/initVacationPromotionDate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap initVacationPromotionDate(
			HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("companyCode",SessionHelper.getSession("DN_Code"));
			int rst = vacationSvc.initVacationPromotionDate(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	//연차촉진 기간설정 팝업
	@RequestMapping(value = "/goVacationPromotionDatePopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationPromotionDatePopup(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "reqType", required = false) String reqType) throws Exception {
		
		CoviMap params =  new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("reqType", reqType);
		
		CoviMap returnData = vacationSvc.getVacationPromotionDate(params);
		
		ModelAndView mav = new ModelAndView("user/vacation/VacationPromotionDatePopup");
		mav.addObject("result", returnData.get("data"));
		
 		return mav;
	}
	
	//연차촉진 기간설정 수정
	@RequestMapping(value = "/updateVacationPromotionDate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateVacationPromotionDate(HttpServletRequest request,
			@RequestParam(value = "reqType", required = false) String reqType,
			@RequestParam(value = "reqOrd", required = false) String reqOrd,
			@RequestParam(value = "reqMonth", required = false) String reqMonth,
			@RequestParam(value = "reqTermDay", required = false) String reqTermDay,
			@RequestParam(value = "reqOrder", required = false) String reqOrder) throws Exception {
		
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params =  new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("reqType", reqType);
			params.put("reqOrd", reqOrd);
			params.put("reqMonth", reqMonth);
			params.put("reqTermDay", reqTermDay);
			params.put("reqOrder", reqOrder);
			
			int result = vacationSvc.updateVacationPromotionDate(params);
			
			returnData.put("data", result); 
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}

	// 휴가생성 자동 규칙설정 데이터 초기 구성
	@RequestMapping(value = "/initVacationConfig.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap initVacationConfig(
			HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("companyCode",SessionHelper.getSession("DN_Code"));
			int rst = vacationSvc.initVacationConfig(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}
	
	//휴가생성 자동 규칙설정 조회
	@RequestMapping(value = "getVacationConfig.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getVacationConfig(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
			if(returnJsonArray.size()>0) {
				CoviMap returnMap = (CoviMap) returnJsonArray.get(0);
				returnObj.put("data", returnMap);
			}
			
			String userCode = StringUtil.replaceNull(request.getParameter("BeforeAnnualMember"), "");    //폴더 타입
			String[] userCodes = userCode.split(";");
			
			if(userCodes.length > 0) {
				reqMap.put("BeforeAnnualMember", userCodes);
				CoviList returnUserDisplayName = vacationSvc.getUserDisplayName(reqMap);
				returnObj.put("userList", returnUserDisplayName);
			}

			returnObj.put("status", Return.SUCCESS);
			returnObj.put("count", returnJsonArray.size());
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	//휴가생성 자동 규칙설정 수정
	@RequestMapping(value = "/updateVacationConfig.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateVacationConfig(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			String changeMethod = StringUtil.replaceNull(request.getParameter("changeMethod"), "");
			param.put("urCode", SessionHelper.getSession("USERID"));
			param.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			param.put("createMethod", request.getParameter("createMethod"));
			param.put("initCnt", request.getParameter("initCnt"));
			param.put("incTerm", request.getParameter("incTerm"));

			param.put("incCnt", request.getParameter("incCnt"));
			param.put("maxCnt", request.getParameter("maxCnt"));
			param.put("remMethod", request.getParameter("remMethod"));
			param.put("yearRemMethod", request.getParameter("yearRemMethod"));
			param.put("isRemRenewal", request.getParameter("isRemRenewal"));
			param.put("yearCreateAnnualVacation", StringUtil.replaceNull(request.getParameter("yearCreateAnnualVacation"), "N"));
			param.put("reqInfoMethod", request.getParameter("reqInfoMethod"));
			param.put("isAuto", request.getParameter("isAuto"));

			param.put("formTitle090", request.getParameter("formTitle090"));
			param.put("formTitle091", request.getParameter("formTitle091"));
			param.put("formTitle092", request.getParameter("formTitle092"));
			param.put("formTitle021", request.getParameter("formTitle021"));
			param.put("formTitle022", request.getParameter("formTitle022"));
			param.put("formTitle100", request.getParameter("formTitle100"));
			param.put("formTitle101", request.getParameter("formTitle101"));
			param.put("formTitle102", request.getParameter("formTitle102"));
			param.put("formBody090", request.getParameter("formBody090"));
			param.put("formBody091", request.getParameter("formBody091"));
			param.put("formBody092", request.getParameter("formBody092"));
			param.put("formBody021", request.getParameter("formBody021"));
			param.put("formBody022", request.getParameter("formBody022"));
			param.put("formBody100", request.getParameter("formBody100"));
			param.put("formBody101", request.getParameter("formBody101"));
			param.put("formBody102", request.getParameter("formBody102"));

			param.put("mailSenderName", request.getParameter("mailSenderName"));
			param.put("mailSenderAddr", request.getParameter("mailSenderAddr"));

			param.put("useYn100", request.getParameter("useYn100"));
			param.put("useYn101", request.getParameter("useYn101"));
			param.put("useYn102", request.getParameter("useYn102"));
			param.put("useYn090", request.getParameter("useYn090"));
			param.put("useYn091", request.getParameter("useYn091"));
			param.put("useYn092", request.getParameter("useYn092"));
			param.put("useYn021", request.getParameter("useYn021"));
			param.put("useYn022", request.getParameter("useYn022"));
			
			int result = vacationSvc.updateVacationConfig(param);
			if(changeMethod.equals("true")){//연차생성 기준이 변경되면 연차 유효 범위 변경 업데이트
				vacationSvc.deleteVacationPlanHist(param);
				vacationSvc.updateVacationExpireDateRange(param);
				vacationSvc.updateResetVacationDays(param);
				//System.out.println("######rst:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(param));
			}

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;
	}
	
	//선연차 설정 수정
	@RequestMapping(value = "updateBeforeAnnual.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateBeforeAnnual(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap param = new CoviMap();
			param.put("isBeforeAnnual", request.getParameter("isBeforeAnnual"));
			param.put("beforeAnnualMember", request.getParameter("beforeAnnualMember"));
			
			int result = vacationSvc.updateBeforeAnnual(param);

			returnObj.put("data", result);
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "수정 되었습니다");
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	//사용자별 연차촉진일 목록 조회
	@RequestMapping(value = "/getVacationFacilitatingDateList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationFacilitatingDateList(
			HttpServletRequest request,
			@RequestParam(value = "tabType", required = false ) String tabType,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "schDateType", required = false , defaultValue = "1") String schDateType,
			@RequestParam(value = "urCode", required = false, defaultValue = "") String urCode,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "notiTarget", required = false  , defaultValue = "") String notiTarget,
			@RequestParam(value = "endDate", required = false) String endDate,
			@RequestParam(value = "emailReSend", required = false, defaultValue = "") String emailReSend,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String sortBy = request.getParameter("sortBy");
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
					
			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));

			if(!notiTarget.equals("")){
				String dayType = notiTarget.substring(0,1);
				int daysValue = Integer.parseInt(notiTarget.substring(1));
				if(dayType.equals("W")){
					daysValue = daysValue*7;
					dayType = "D";
				}
				params.put("dayType", dayType);
				params.put("daysValue", daysValue);
			}else{
				params.put("dayType", "");
				params.put("daysValue", "");
			}

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("tabType", tabType);
			params.put("year", year);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", schTxt);
			params.put("schDateType", schDateType);
			params.put("urCode", urCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("emailReSend", emailReSend);

			CoviList sendMailUsersList = new CoviList();
			if(emailReSend.equals("Y")) {
				String sendMailUsers = StringUtil.replaceNull(request.getParameter("sendMailUsers"), "[]");
				sendMailUsersList = CoviList.fromObject(sendMailUsers.replaceAll("&quot;", "\""));
				params.put("sendMailUsersList",sendMailUsersList.toArray());
			}
			
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			resultList = vacationSvc.getVacationFacilitatingDateList(params);
			returnList.put("cnt", resultList.get("cnt"));
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);

			//email 재전송 모드 동작 데이터 미입력자 대상
			if(emailReSend.equals("Y")){
				Gson gson = new Gson();
				JSONObject jsonObjectresultList = JSONObject.fromObject(JSONSerializer.toJSON(resultList));
				CoviMap reqMap = new CoviMap();
				String domainCode = SessionHelper.getSession("DN_Code");
				reqMap.put("CompanyCode", domainCode);

				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				CoviMap vacConfigMap = (CoviMap) returnJsonArray.get(0);
				JSONArray jsonArray = JSONArray.fromObject(jsonObjectresultList.get("list"));
				for(int i=0;i<jsonArray.size();i++) {
					JSONObject jsonObject = JSONObject.fromObject(jsonArray.get(i));
					String vacplan = jsonObject.getString("VACPLAN");
					String mailAddress = jsonObject.getString("MailAddress");
					String userCode = jsonObject.getString("UserCode");

					//System.out.println("#####vacplan:"+vacplan);
					if(tabType!=null){
						String reqType = "";
						boolean existData = false;
						switch (tabType) {
							case "1": //1년 이상 1차 촉진 미입력자
								reqType = "101";
								if(vacplan!=null && !vacplan.equals("")){
									CoviMap coviMapVacPlan = gson.fromJson(vacplan, CoviMap.class);
									if(coviMapVacPlan.containsKey("notification1") && coviMapVacPlan.containsKey("notification2") ){
										CoviMap coviMapNoti1 = gson.fromJson(coviMapVacPlan.get("notification1").toString(), CoviMap.class);
										CoviMap coviMapNoti2 = gson.fromJson(coviMapVacPlan.get("notification2").toString(), CoviMap.class);
										if(coviMapNoti1.containsKey("normal") && coviMapNoti2.containsKey("normal")){
											CoviMap coviMapType1 = gson.fromJson(coviMapNoti1.get("normal").toString(), CoviMap.class);
											CoviMap coviMapType2 = gson.fromJson(coviMapNoti2.get("normal").toString(), CoviMap.class);
											if(coviMapType1.containsKey("months")  && coviMapType2.containsKey("months")){
												CoviList coviMapMonth1 = gson.fromJson(coviMapType1.get("months").toString(), CoviList.class);
												CoviList coviMapMonth2 = gson.fromJson(coviMapType2.get("months").toString(), CoviList.class);
												if(coviMapMonth1.size()>0 && coviMapMonth2.size()>0){
													existData = true;
												}
											}
										}
									}
								}
								break;
							case "2": //1년 미만 9일 미만 1차
								reqType = "091";
								if(vacplan!=null && !vacplan.equals("")){
									CoviMap coviMapVacPlan = gson.fromJson(vacplan, CoviMap.class);
									if(coviMapVacPlan.containsKey("notification1")){
										CoviMap coviMapNoti = gson.fromJson(coviMapVacPlan.get("notification1").toString(), CoviMap.class);
										if(coviMapNoti.containsKey("newEmpForNine")){
											CoviMap coviMapType = gson.fromJson(coviMapNoti.get("newEmpForNine").toString(), CoviMap.class);
											if(coviMapType.containsKey("months")){
												CoviList coviMapMonth = gson.fromJson(coviMapType.get("months").toString(), CoviList.class);
												if(coviMapMonth.size()>0){
													existData = true;
												}
											}
										}
									}
								}
								break;
							case "3": //1년 이상 1차 촉진 미입력자
								reqType = "021";
								if(vacplan!=null && !vacplan.equals("")){
									CoviMap coviMapVacPlan = gson.fromJson(vacplan, CoviMap.class);
									//System.out.println("#####coviMapVacPlan:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(coviMapVacPlan));
									if(coviMapVacPlan.containsKey("notification1")){
										CoviMap coviMapNoti = gson.fromJson(coviMapVacPlan.get("notification1").toString(), CoviMap.class);
										if(coviMapNoti.containsKey("newEmpForTwo")){
											CoviMap coviMapType = gson.fromJson(coviMapNoti.get("newEmpForTwo").toString(), CoviMap.class);
											if(coviMapType.containsKey("months")){
												CoviList coviMapMonth = gson.fromJson(coviMapType.get("months").toString(), CoviList.class);
												if(coviMapMonth.size()>0){
													existData = true;
												}
											}
										}
									}
								}
								break;
							case "4": //1년 이상 1차 촉진 미입력자
								reqType = "100";
								if(vacplan!=null && !vacplan.equals("")){
									CoviMap coviMapVacPlan = gson.fromJson(vacplan, CoviMap.class);
									if(coviMapVacPlan.containsKey("plan")){
										CoviMap coviMapNoti = gson.fromJson(coviMapVacPlan.get("plan").toString(), CoviMap.class);
										if(coviMapNoti.containsKey("normal")){
											CoviMap coviMapType = gson.fromJson(coviMapNoti.get("normal").toString(), CoviMap.class);
											if(coviMapType.containsKey("months")){
												CoviList coviMapMonth = gson.fromJson(coviMapType.get("months").toString(), CoviList.class);
												if(coviMapMonth.size()>0){
													existData = true;
												}
											}
										}
									}
								}
								break;
							case "5": //1년 이상 1차 촉진 미입력자
								reqType = "090";
								if(vacplan!=null && !vacplan.equals("")){
									CoviMap coviMapVacPlan = gson.fromJson(vacplan, CoviMap.class);
									if(coviMapVacPlan.containsKey("plan")){
										CoviMap coviMapNoti = gson.fromJson(coviMapVacPlan.get("plan").toString(), CoviMap.class);
										if(coviMapNoti.containsKey("newEmp")){
											CoviMap coviMapType = gson.fromJson(coviMapNoti.get("newEmp").toString(), CoviMap.class);
											if(coviMapType.containsKey("months")){
												CoviList coviMapMonth = gson.fromJson(coviMapType.get("months").toString(), CoviList.class);
												if(coviMapMonth.size()>0){
													existData = true;
												}
											}
										}
									}
								}
								break;
							default : break;
						}
						//System.out.println("#####existData:"+existData);
						if(!existData) {
							// 이메일 발송 조건
							if (tabType.equals("1")) {
								if (schDateType.equals("1")) {
									reqType = "101"; 	// 일반직원, 1차 촉진.
								} else if (schDateType.equals("2")) {
									reqType = "102"; 	// 일반직원, 2차 촉진.
								}
							} else if (tabType.equals("2")) {
								if (schDateType.equals("1")) {
									reqType = "091";	// 1년 미만(9일), 1차 촉진.
								} else if (schDateType.equals("2")) { 	
									reqType = "092"; 	// 1년 미만(9일), 2차 촉진.
								}
							} else if (tabType.equals("3")) {
								if (schDateType.equals("1")) {
									reqType = "021";	// 1년 미만(2일), 1차 촉진
								} else if (schDateType.equals("2")) { 
									reqType = "022";	// 1년 미만(2일), 2차 촉진
								}
							}
							
							CoviMap mailForm = new CoviMap();
							String receiverCode = "[{\"Type\":\"UR\",\"Code\":\"" + userCode + "\"}]";
							mailForm.put("ReceiverInfo", receiverCode);
							mailForm.put("ReceiverMailAddress", mailAddress);
							mailForm.put("ReqType", reqType);
							mailForm.put("domainCode", domainCode);

							try {
								JSONObject rstJsonObj = mailSenderSvc.SendMailVacationPromotionInfoNotice(mailForm, vacConfigMap);
								Thread.sleep(100);
							} catch (NullPointerException e) {
								throw new NullPointerException();
							} catch (Exception e) {
								throw new RuntimeException(e);
							}
						}//end if
					}

				}

			}
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}

	// 엑셀 다운로드(미사용연차계획 저장내역 조회)
	@RequestMapping(value = "/getVacationFacilitatingExcelDateList.do")
	public void getVacationFacilitatingExcelDateList(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "tabType", required = false ) String tabType,
			@RequestParam(value = "year", required = false) String year,
			@RequestParam(value = "schTypeSel", required = false) String schTypeSel,
			@RequestParam(value = "schTxt", required = false) String schTxt,
			@RequestParam(value = "schDateType", required = false , defaultValue = "1") String schDateType,
			@RequestParam(value = "urCode", required = false, defaultValue = "") String urCode,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "endDate", required = false) String endDate,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10000" ) int pageSize
	) {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			String sortBy = request.getParameter("sortBy");
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("tabType", tabType);
			params.put("year", year);
			params.put("schTypeSel", schTypeSel);
			params.put("schTxt", schTxt);
			params.put("schDateType", schDateType);
			params.put("urCode", urCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", SessionHelper.getSession("DN_ID"));
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}

			String excelTempleteFile = "";
			String formType1 = "";
			String formType2 = "";
			String readType1 = "";
			String readType2 = "";
			String rangeFrom1 = "";
			String rangeTo1 = "";
			String rangeFrom2 = "";
			String rangeTo2 = "";
			String empType = "";
			String FileName = "연차촉진_현황조회_";
			switch(tabType) {
				case "1":
					FileName += "1년이상(일반직원)";
					formType1 = "notification1";
					formType2 = "notification2";
					empType = "normal";
					readType1 = "Read12";
					readType2 = "Read18";
					rangeFrom1 = "OneDate";
					rangeTo1 = "OneDateUntil";
					rangeFrom2 = "TwoDate";
					rangeTo2 = "TwoDateUntil";
					excelTempleteFile = "VacationFacilitating_templete1";
					break;
				case "2":
					FileName += "1년미만(9일)";
					formType1 = "notification1";
					formType2 = "notification2";
					empType = "newEmpForNine";
					readType1 = "Read13";
					readType2 = "Read19";
					rangeFrom1 = "LessOneDate9";
					rangeTo1 = "LessOneDate9Until";
					rangeFrom2 = "LessTwoDate9";
					rangeTo2 = "LessTwoDate9Until";
					excelTempleteFile = "VacationFacilitating_templete1";
					break;
				case "3":
					FileName += "1년미만(2일)";
					formType1 = "notification1";
					formType2 = "notification2";
					empType = "newEmpForTwo";
					readType1 = "Read14";
					readType2 = "Read20";
					rangeFrom1 = "LessOneDate2";
					rangeTo1 = "LessOneDate2Until";
					rangeFrom2 = "LessTwoDate2";
					rangeTo2 = "LessTwoDate2Until";
					excelTempleteFile = "VacationFacilitating_templete1";
					break;
				case "4":
					FileName += "연차계획서(일반직원)";
					formType1 = "plan";
					empType = "normal";
					readType1 = "Read10";
					readType2 = "";
					rangeFrom1 = "VacDate";
					rangeTo1 = "VacDateUntil";
					rangeFrom2 = "";
					rangeTo2 = "";
					excelTempleteFile = "VacationFacilitating_templete2";
					break;
				case "5":
					FileName += "연차계획서(1년미만)";
					formType1 = "plan";
					empType = "newEmp";
					readType1 = "Read11";
					readType2 = "";
					rangeFrom1 = "LessVacDate";
					rangeTo1 = "LessVacDateUntil";
					rangeFrom2 = "";
					rangeTo2 = "";
					excelTempleteFile = "VacationFacilitating_templete2";
					break;
				default :
					break;
			}
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+excelTempleteFile+".xlsx");


			CoviMap resultList = vacationSvc.getVacationFacilitatingDateList(params);
			CoviList jsonArray = (CoviList) resultList.get("list");
			CoviList njsonArray = new CoviList();
			Gson gson = new Gson();
			for (int i=0;i<jsonArray.size();i++){
				CoviMap rowObj = jsonArray.getMap(i);
				String strVanPlan = rowObj.getString("VACPLAN");
				//read check & checked date
				if(!rangeFrom1.equals("") && !rangeTo1.equals("")){
					rowObj.put("rangeFromTo1", rowObj.getString(rangeFrom1)+" ~ "+rowObj.getString(rangeTo1));
				}
				if(!rangeFrom2.equals("") && !rangeTo2.equals("")){
					rowObj.put("rangeFromTo2", rowObj.getString(rangeFrom2)+" ~ "+rowObj.getString(rangeTo2));
				}

				if(!readType1.equals("")){
					rowObj.put("readDate1", rowObj.getString(readType1));
				}
				if(!readType2.equals("")){
					rowObj.put("readDate2", rowObj.getString(readType2));
				}
				if(strVanPlan!=null && !strVanPlan.equals("")) {
					CoviMap dataObj = gson.fromJson(strVanPlan, CoviMap.class);
					//System.out.println("#####strVanPlan>" + strVanPlan);
					if (!formType1.equals("")) {
						if(dataObj.containsKey(formType1)) {
							CoviMap tempObj = gson.fromJson(dataObj.get(formType1).toString(), CoviMap.class);
							if(tempObj.containsKey(empType)) {
								CoviMap tempObj2 = gson.fromJson(tempObj.get(empType).toString(), CoviMap.class);
								if(tempObj2.containsKey("months")) {
									CoviList monthArray = gson.fromJson(tempObj2.get("months").toString(), CoviList.class);
									if (monthArray.size() > 0) {
										rowObj.put(formType1 + "_check", "Y");
									}
								}
							}
						}
					}
					if(!rowObj.containsKey(formType1 + "_check")){
						rowObj.put(formType1 + "_check", "");
					}
					if (!formType2.equals("")) {
						if(dataObj.containsKey(formType2)) {
							CoviMap tempObj = gson.fromJson(dataObj.get(formType2).toString(), CoviMap.class);
							if(tempObj.containsKey(empType)) {
								CoviMap tempObj2 = gson.fromJson(tempObj.get(empType).toString(), CoviMap.class);
								if(tempObj2.containsKey("months")) {
									CoviList monthArray = gson.fromJson(tempObj2.get("months").toString(), CoviList.class);
									if (monthArray.size() > 0) {
										rowObj.put(formType2 + "_check", "Y");
									}
								}
							}
						}
					}
					if(!rowObj.containsKey(formType2 + "_check")){
						rowObj.put(formType2 + "_check", "");
					}
				}else{
					rowObj.put(formType1 + "_check", "");
					rowObj.put(formType2 + "_check", "");
				}

				njsonArray.add(rowObj);
			}

			//System.out.println("#####njsonArray:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(njsonArray));

			Object listObj = gson.fromJson(njsonArray.toString(), Object.class);
			params.put("list",listObj);
			params.put("cnt",jsonArray.size());
			params.put("title", FileName);

			//System.out.println("#####params:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(params));

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+URLEncoder.encode(FileName + ".xlsx","UTF-8")+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (baos != null) { try { baos.flush(); baos.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}

	@RequestMapping(value = "/testMailSend.do", method = {RequestMethod.POST, RequestMethod.GET})
	public @ResponseBody CoviMap testMailSend(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String domainCode = SessionHelper.getSession("DN_Code");
			if(domainCode != null && !domainCode.isEmpty()) {
				CoviMap reqMap = new CoviMap();
				reqMap.put("CompanyCode", domainCode);
				CoviList returnJsonArray = vacationSvc.getVacationConfig(reqMap);
				CoviMap vacConfigMap = (CoviMap) returnJsonArray.get(0);
				CoviMap mailForm = new CoviMap();
				mailForm.put("ReceiverMailAddress", SessionHelper.getSession("UR_Mail"));
				mailForm.put("ReqType", request.getParameter("reqType"));
				String receiverCode = "[{\"Type\":\"UR\",\"Code\":\""+request.getParameter("rcvUserCode")+"\"}]";
				mailForm.put("ReceiverInfo", receiverCode);
				returnList = mailSenderSvc.SendMailVacationPromotionInfoNotice(mailForm, vacConfigMap);
			}//end if DN_Code
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	//마이그레션 휴가 고도화 후 1년 미만 직원들의 연차계획서 기록 데이터가 입력 당시 해당년도 기준으로 입력됨.
	//따라서 1년 미만자는 입사년 기준년으로 데이터를 땡겨와 기록 처리
	@RequestMapping(value = "/migrationVacationPlan.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap migrationVacationPlan(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();

		try {
			CoviMap param = new CoviMap();
			param.put("year", request.getParameter("year"));
			param.put("domainCode", SessionHelper.getSession("DN_Code"));
			int result = vacationSvc.updateVacPlanMigration(param);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));	//수정 되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}

	// 휴가부여이력 팝업
	@RequestMapping(value = "/goVacationPlanHistPopup.do", method = RequestMethod.GET)
	public ModelAndView goVacationPlanHistPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/vacation/VacationPlanHistPopup");
	}
	// 휴가부여이력팝업 조회
	@RequestMapping(value = "/getVacationPlanHist.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getVacationPlanHist(
			HttpServletRequest request,
			@RequestParam(value = "urCode", required = false) String urCode,
			@RequestParam(value = "startDate", required = false) String startDate,
			@RequestParam(value = "endDate", required = false) String endDate,
			@RequestParam(value = "vacType", required = false) String vacType,
			@RequestParam(value = "vacKind", required = false  , defaultValue = "Public") String vacKind,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
		) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null  && !sortBy.equals(""))? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null && !sortBy.equals(""))? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("urCode", urCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("vacType", vacType);
			params.put("vacKind", vacKind);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			resultList = vacationSvc.getVacationPlanHist(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
}
