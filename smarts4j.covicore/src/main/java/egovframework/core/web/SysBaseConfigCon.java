package egovframework.core.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
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
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LocalBaseSyncSvc;
import egovframework.core.sevice.SysBaseConfigSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import net.sf.jxls.transformer.XLSTransformer;

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
public class SysBaseConfigCon {

	private Logger LOGGER = LogManager.getLogger(SysBaseConfigCon.class);
	
	@Autowired
	//private SystemBaseConfigSvc sysBaseConfigSvc;
	private SysBaseConfigSvc sysBaseConfigSvc;

	@Autowired
	private LocalBaseSyncSvc localBaseSyncSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getDataBaseConfig : 시스템 관리 - 기초설정 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String domain = request.getParameter("domain");
			String bizsection = request.getParameter("bizsection");
			String configtype = request.getParameter("configtype");
			String isuse = request.getParameter("isuse");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("bizsection", bizsection);
			params.put("configtype", configtype);
			params.put("isuse", isuse);
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			
			if (request.getParameter("configArray") != null) {
				params.put("configArray", request.getParameter("configArray").split(","));
				//String[] aList = request.getParameter("configArray").split(",");
			}
			
			if (request.getParameter("configTypeArray") != null) {
				params.put("configTypeArray", request.getParameter("configTypeArray").split(","));
				//String[] aList = request.getParameter("configTypeArray").split(",");
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}
			
			if(StringUtil.replaceNull(domain).isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			resultList = sysBaseConfigSvc.select(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
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
	
	/**
	 * addbaseconfiglayerpopup : 시스템 관리 - 기초설정 관리 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "baseconfig/goBaseConfigPopup.do", method = RequestMethod.GET)
	public ModelAndView goBaseConfigPopup(Locale locale, Model model) {
		String returnURL = "core/system/addbaseconfiglayerpopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * baseconfigexcelupload : 시스템 관리 - 기초설정 관리 엑셀 업로드 팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "baseconfig/uploadExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView uploadExcelPopup(Locale locale, Model model) {
		String returnURL = "core/system/baseconfigexcelupload";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * baseconfigexcelupload : 시스템 관리 - 기초설정 관리 엑셀 업로드 파일 다운로드
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "baseconfig/uploadSampleDownload.do")
	public void uploadSampleDownload(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {

			CoviMap params = new CoviMap();
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//BaseConfig_template.xls");

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(FileUtil.checkTraversalCharacter(ExcelPath));
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			baos.flush();

			response.setHeader("Content-Disposition", "attachment;fileName=\""+"BaseConfigUploadSample.xls"+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (resultWorkbook != null) {
				try {
					resultWorkbook.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
			if (is != null) {
				try {
					is.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
			if (baos != null) {
				try {
					baos.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
			if (fis != null) {
				try {
					fis.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
		}
	}
	
	/**
	 * baseconfigexcelupload : 시스템 관리 - 기초설정 관리 엑셀 업로드
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "baseconfig/uploadExcel.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap workInfoExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile, 
			@RequestParam(value = "add_domain", required = false, defaultValue="0" ) String add_domain) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			//엑셀파일 데이터 추출
			ArrayList<ArrayList<Object>> dataList = sysBaseConfigSvc.extractionExcelData(params, 1);	// 엑셀 데이터 추출

			//검증데이터 파싱
			CoviList exArry = new CoviList();
			int totalCnt = 0;
			int insertCnt = 0;
			int updateCnt = 0;
			for (int i=0;i< dataList.size();i++) {
				totalCnt++;
				
				CoviMap exObj = new CoviMap();
				ArrayList<Object> tempList = dataList.get(i);
				
				// 업로드 엑셀 약식 널 체크 공백 로우 체크
				if(tempList.size() < 6) continue;
				
				String BizSection = String.valueOf(tempList.get(0));
				String SettingKey = String.valueOf(tempList.get(1));
				String SettingValue = String.valueOf(tempList.get(2));
				String ConfigType = String.valueOf(tempList.get(3));
				String ConfigName = String.valueOf(tempList.get(4));
				String Description = String.valueOf(tempList.get(5));
				String IsCheck = String.valueOf(tempList.get(6));
				String IsUse = String.valueOf(tempList.get(7));
				
				exObj.put("BizSection", BizSection);
				exObj.put("SettingKey", SettingKey);
				exObj.put("SettingValue", SettingValue);
				exObj.put("ConfigType", ConfigType);
				exObj.put("ConfigName", ConfigName);
				exObj.put("Description", Description);
				exObj.put("IsCheck", IsCheck);
				exObj.put("IsUse", IsUse);
				
				exObj.put("DN_ID", add_domain);
				exObj.put("RegID", SessionHelper.getSession("USERID"));
				exObj.put("ModID", SessionHelper.getSession("USERID"));
				
				
			    CoviMap checkParam = new CoviMap();
			    checkParam.put("DN_ID", add_domain);
			    checkParam.put("settingKey", SettingKey);
				int resultCnt = sysBaseConfigSvc.selectForCheckingDouble(checkParam);
				
				if(resultCnt == 0) {
					if(sysBaseConfigSvc.insertMerge(exObj) == 1) insertCnt++;
				}else {
					exObj.put("Seq", sysBaseConfigSvc.selectForCheckingKey(checkParam));
					
					if(sysBaseConfigSvc.update(exObj) == 1) updateCnt++;
				}
			}

			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "총:"+totalCnt+", 등록:"+insertCnt+", 수정 "+updateCnt+" 업로드 되었습니다");
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
	
	@RequestMapping(value = "/goWorkInfoByExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView goWorkInfoByExcelPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/attend/AttendWorkInfoByExcelPopup");
	}
	
	
	/**
	 * addBaseConfig : 기초설정 관리 데이터 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//단일 insert일 경우
			//prameter validation 처리 할 것
			String bizSect = request.getParameter("BizSection");
			int dnId = Integer.parseInt(request.getParameter("DN_ID"));
			String setKey = request.getParameter("SettingKey");
			String setVal = request.getParameter("SettingValue");
			String isChk = request.getParameter("IsCheck");
			String isUse = request.getParameter("IsUse");
			String configType = request.getParameter("ConfigType");
			String configName = request.getParameter("ConfigName");
			String desc = request.getParameter("Description");
			String regId = SessionHelper.getSession("USERID");
			CoviMap params = new CoviMap();
			
			params.put("BizSection", bizSect);
			params.put("DN_ID", dnId);
			params.put("SettingKey", setKey);
			params.put("SettingValue", setVal);
			params.put("IsCheck", isChk);
			params.put("IsUse", isUse);
			params.put("ConfigType", configType);
			params.put("ConfigName", configName);
			params.put("Description", desc);
			params.put("RegID", regId);
			params.put("ModID", regId);
			
			returnList.put("object", sysBaseConfigSvc.insert(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");

		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateBaseConfig : 기초설정 관리 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//단일 insert일 경우
			//prameter validation 처리 할 것
			int seq = Integer.parseInt(request.getParameter("Seq"));
			String bizSect = request.getParameter("BizSection");
			int dnId = Integer.parseInt(request.getParameter("DN_ID"));
			String setKey = request.getParameter("SettingKey");
			String setVal = request.getParameter("SettingValue");
			String isChk = request.getParameter("IsCheck");
			String isUse = request.getParameter("IsUse");
			String configType = request.getParameter("ConfigType");
			String configName = request.getParameter("ConfigName");
			String desc = request.getParameter("Description");
			String modId = SessionHelper.getSession("USERID");
			
			CoviMap params = new CoviMap();
			
			params.put("Seq", seq);
			params.put("BizSection", bizSect);
			params.put("DN_ID", dnId);
			params.put("SettingKey", setKey);
			params.put("SettingValue", setVal);
			params.put("IsCheck", isChk);
			params.put("IsUse", isUse);
			params.put("ConfigType", configType);
			params.put("ConfigName", configName);
			params.put("Description", desc);
			params.put("ModID", modId);
			
			returnList.put("object", sysBaseConfigSvc.update(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");

		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsUseBaseConfig : 기초설정 관리에서 사용여부 값 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyUse(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int seq = Integer.parseInt(request.getParameter("Seq"));
			String isUse = request.getParameter("IsUse");
			String modId = request.getParameter("ModID");
			
			CoviMap params = new CoviMap();
			
			params.put("Seq", seq);
			params.put("IsUse", isUse);
			params.put("ModID", modId);
			
			returnList.put("object", sysBaseConfigSvc.updateIsUse(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");

		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * selectOneBaseConfig : 기초설정 관리에서 하나의 데이터 셀렉트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/getOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOneBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		int seq = Integer.parseInt(request.getParameter("Seq"));

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("configID", seq);
			resultList = sysBaseConfigSvc.selectOne(params);
			
			returnList.put("list", resultList.get("map"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteBaseConfig : 기초설정관리 데이터 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "baseconfig/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap removeBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String DeleteData = request.getParameter("DeleteData");
		String[] saData = StringUtil.replaceNull(DeleteData).split(",");
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("seq", saData);
			sysBaseConfigSvc.delete(params);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다");

		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "baseconfig/checkDouble.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDoubleBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String settKey = request.getParameter("SettingKey");
		String dnID = request.getParameter("DN_ID");
	
		int resultCnt = 0;
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("settingKey", settKey);
			params.put("DN_ID", dnID);
			resultCnt = sysBaseConfigSvc.selectForCheckingDouble(params);
			
			if(resultCnt == 0)
				returnList.put("result", "ok");
			else
				returnList.put("result", "not ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "baseconfig/encrypt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap encryptBaseConfigValue(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String settValue = request.getParameter("SettingValue");
		String resultValue = "";
		CoviMap returnList = new CoviMap();
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")); 

		try {
			AES aes = new AES(key, "N");
			resultValue = aes.encrypt(settValue);		// 키, 설정값으로 교체
			
			returnList.put("result", "ok");
			returnList.put("encryptText", resultValue);

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "baseconfig/downloadExcel.do" )
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String domain = request.getParameter("domain");
			String bizsection = request.getParameter("bizsection");
			String configtype = request.getParameter("configtype");
			String isuse = request.getParameter("isuse");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			String sortKey = request.getParameter("sortKey");
			sortKey = StringUtil.replaceNull(sortKey).equalsIgnoreCase("DisplayName") ? "B.DisplayName" : "A."+sortKey; //sortKey 테이블 alias 추가
			String sortWay = request.getParameter("sortWay");

			String headerName = request.getParameter("headername");
			String headerType = request.getParameter("headerType");
			
			String[] headerNames = StringUtil.replaceNull(headerName).split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("bizsection", bizsection);
			params.put("configtype", configtype);
			params.put("isuse", isuse);
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}
			
			if(StringUtil.replaceNull(domain).isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			viewParams = sysBaseConfigSvc.selectExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "BaseConfigView");
			viewParams.put("headerType", headerType);
			
			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (NullPointerException e) {
			LOGGER.error("SystemBaseConfigCon", e);
		} catch (Exception e) {
			LOGGER.error("SystemBaseConfigCon", e);
		}

		return mav;
	}
}
