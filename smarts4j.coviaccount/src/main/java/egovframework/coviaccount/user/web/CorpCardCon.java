package egovframework.coviaccount.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
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
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.CorpCardSvc;
import egovframework.coviframework.util.ComUtils;
import net.sf.jxls.transformer.XLSTransformer;

/**
 * @Class Name : corpCardCon.java
 * @Description : 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CorpCardCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CorpCardSvc corpCardSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getCorpCardList
	 * @Description : 카드 등록 관리 목록 조회
	 */
	@RequestMapping(value = "corpCard/getCorpCardList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCorpCardList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "ownerUserCode",	required = false, defaultValue="")	String ownerUserCode,
			@RequestParam(value = "cardStatus",		required = false, defaultValue="")	String cardStatus,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass) throws Exception{
			
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("ownerUserCode",	ownerUserCode);
			params.put("cardStatus",	cardStatus);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("cardClass",		cardClass);
			
			resultList = corpCardSvc.getCorpCardList(params);
			resultList.put("status",	Return.SUCCESS);
			
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : getCorpCardPopup
	 * @Description : 카드 등록 관리 팝업 호출
	 */
	@RequestMapping(value = "corpCard/getCorpCardPopup.do", method = RequestMethod.GET)
	public ModelAndView getCorpCardPopup(Locale locale, Model model) {
		String returnURL = "user/account/CorpCardPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getCorpCardChgPopup
	 * @Description : 카드 등록 관리 카드번호 변경 팝업 호출
	 */
	@RequestMapping(value = "corpCard/getCorpCardChgPopup.do", method = RequestMethod.GET)
	public ModelAndView getCorpCardChgPopup(Locale locale, Model model) {
		String returnURL = "user/account/CorpCardChgPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getCardNoChk
	 * @Description : 카드 등록 관리 카드번호 중복체크
	 */
	@RequestMapping(value = "corpCard/getCardNoChk.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardNoChk(
			@RequestParam(value = "cardNo",	required = false, defaultValue="") String cardNo) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("cardNo",	ComUtils.RemoveSQLInjection(cardNo, 100));
			resultList = corpCardSvc.getCardNoChk(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : getCorpCardDetail
	 * @Description : 카드 등록 관리 상세 정보 조회
	 */
	@RequestMapping(value = "corpCard/getCorpCardDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCorpCardDetail(
			@RequestParam(value = "corpCardID",	required = false, defaultValue="") String corpCardID) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("corpCardID",	corpCardID);
			resultList = corpCardSvc.getCorpCardDetail(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : saveCorpCardInfo
	 * @Description : 카드 등록 관리 저장
	 */
	@RequestMapping(value = "corpCard/saveCorpCardInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCorpCardInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
		try {
			corpCardSvc.saveCorpCardInfo(params);
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : updateCorpCardNo
	 * @Description : 카드 등록 관리 카드번호 변경
	 */
	@RequestMapping(value = "corpCard/updateCorpCardNo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateCorpCardNo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
		try {
			corpCardSvc.updateCorpCardNo(params);
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : deleteCorpCard
	 * @Description : 카드 등록 관리 삭제
	 */
	@RequestMapping(value = "corpCard/deleteCorpCard.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteCorpCard(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",		required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			
			params.put("deleteSeq",	deleteSeq);	
			corpCardSvc.deleteCorpCard(params);
			
			rtValue.put("result", "ok");
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : corpCardExcelDownload
	 * @Description : 카드 등록 관리 엑셀 다운로드
	 */
	@RequestMapping(value = "corpCard/corpCardExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView corpCardExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "ownerUserCode",	required = false, defaultValue="")	String ownerUserCode,
			@RequestParam(value = "cardStatus",		required = false, defaultValue="")	String cardStatus,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "cardClass",		required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames		= commonCon.convertUTF8(headerName).split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("ownerUserCode",	commonCon.convertUTF8(ownerUserCode));
			params.put("cardStatus",	commonCon.convertUTF8(cardStatus));
			params.put("cardNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("cardClass",		commonCon.convertUTF8(cardClass));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = corpCardSvc.corpCardExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : CorpCardExcelPopup
	 * @Description : 카드 등록 관리 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "corpCard/CorpCardExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView corpCardExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/CorpCardExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : corpCardExcelUpload
	 * @Description : 카드 등록 관리 엑셀 업로드
	 */
	@RequestMapping(value = "corpCard/corpCardExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap corpCardExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			CoviMap	result = corpCardSvc.corpCardExcelUpload(params);
			
			if(!result.has("err")) {
				returnData.put("status",	Return.SUCCESS);
				returnData.put("message",	DicHelper.getDic("msg_UploadOk"));
			} else {
				returnData.put("status",	Return.FAIL);
				returnData.put("message", result.get("message"));
			}
			
			returnData.put("data",		result);
			returnData.put("result",	"ok");
		} catch (SQLException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	/**
	 * @Method Name : corpCardSync
	 * @Description : 카드 등록 관리 동기화
	 */
	@RequestMapping(value = "corpCard/corpCardSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap corpCardSync(){
		CoviMap	resultList	= new CoviMap();
		resultList = corpCardSvc.corpCardSync();
		return resultList;
	}
	
	/**
	 * @Method Name : downloadTemplateFile
	 * @Description : 카드등록엑셀 템플릿 다운로드
	 */
	@RequestMapping(value = "corpCard/downloadTemplateFile.do")
	public void downloadTemplateFile(HttpServletRequest request, HttpServletResponse response) throws Exception {
		XSSFWorkbook workbook = null;
		Workbook resultWorkbook = null;
		InputStream is = null;
		ByteArrayOutputStream baos = null;
		try {
			CoviMap params = new CoviMap();
			
			workbook = new XSSFWorkbook();
			String FileName = "CorpCardUploadTemplate.xls";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//CorpCardUploadTemplate.xls");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			is = new BufferedInputStream(new FileInputStream(ExcelPath));
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			baos.flush();
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		} finally {
			if(is != null) { is.close(); }
			if(baos != null) { baos.close(); }
			if(workbook != null) { workbook.close(); }
			if(resultWorkbook != null) { resultWorkbook.close(); }
		}
	}
	
	/**
	 * @Method Name : getCorpCardReturnYNPopup
	 * @Description : 카드 불출 팝업 호출
	 */
	@RequestMapping(value = "corpCard/getCorpCardReturnYNPopup.do", method = RequestMethod.GET)
	public ModelAndView getCorpCardReturnYNPopup(Locale locale, Model model) {
		String returnURL = "user/account/CorpCardReturnYNPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getCorpCardReleaseListPopup
	 * @Description : 카드 불출 팝업 호출
	 */
	@RequestMapping(value = "corpCard/getCorpCardReleaseListPopup.do", method = RequestMethod.GET)
	public ModelAndView getCorpCardListPopup(Locale locale, Model model) {
		String returnURL = "user/account/CorpCardReleaseListPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getCorpCardHistoryList
	 * @Description : 카드 불출 대장 화면 조회
	 */
	@RequestMapping(value = "corpCard/getCorpCardHistoryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCorpCardHistoryList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "CorporGubun",		required = false, defaultValue="1")	String CorporGubun,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "releaseUserCode",	required = false, defaultValue="")	String releaseUserCode,
			@RequestParam(value = "cardStatus",			required = false, defaultValue="")	String cardStatus,
			@RequestParam(value = "cardNo",				required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "cardClass",			required = false, defaultValue="")	String cardClass,
			@RequestParam(value = "releaseSt",			required = false, defaultValue="")	String releaseSt,
			@RequestParam(value = "releaseEd",			required = false, defaultValue="")	String releaseEd) {
		CoviMap resultList	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		String sortColumn		= "";
		String sortDirection	= "";	
		if(sortBy.length() > 0){
			sortColumn		= sortBy.split(" ")[0];
			sortDirection	= sortBy.split(" ")[1];
		}
		params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
		params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
		params.put("sortBy",			sortBy);
		params.put("pageNo",			pageNo);
		params.put("pageSize",			pageSize);
		params.put("CorporGubun",		CorporGubun);
		params.put("companyCode",		companyCode);
		params.put("releaseUserCode",	releaseUserCode);
		params.put("cardStatus",		cardStatus);
		params.put("cardNo",			ComUtils.RemoveSQLInjection(cardNo, 100));
		params.put("cardClass",			cardClass);
		params.put("releaseSt",			releaseSt);
		params.put("releaseEd",			releaseEd);
		
		try {
			resultList = corpCardSvc.getCorpCardHistoryList(params);
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateCorpReturnCardInfo
	 * @Description : 카드 불출 및 반납
	 */
	@RequestMapping(value = "corpCard/updateCorpReturnCardInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCorpReturnCardInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		params.put("UR_Code", SessionHelper.getSession("USERID"));
		
		if(params.getString("ReleaseYN").equals("Y")){
			try {
				corpCardSvc.updateCorpCardReturnStatus(params);
				corpCardSvc.saveCorpCardReturnInfo(params);
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}
		}else{
			try {
				corpCardSvc.updateCorpCardReturnStatus(params);
				corpCardSvc.updateCorpCardReturnInfo(params);
				rtValue.put("status", Return.SUCCESS);
			} catch (SQLException e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				rtValue.put("status", Return.FAIL);
				rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				logger.error(e.getLocalizedMessage(), e);
			}
		}
		
		return rtValue;
	}
	
	/**
	 * @Method Name : getReleaseUserInfo
	 * @Description : 카드 불출자 정보 조회
	 */
	@RequestMapping(value = "corpCard/getReleaseUserInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getReleaseUserInfo(
			@RequestParam(value = "ReleaseUserCode",	required = false, defaultValue="") String ReleaseUserCode) throws Exception{
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("ReleaseUserCode",	ReleaseUserCode);
			resultList = corpCardSvc.getReleaseUserInfo(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	/**
	 * @Method Name : deleteCorpCardReturnYN
	 * @Description : 카드 불출 대장 삭제
	 */
	@RequestMapping(value = "corpCard/deleteCorpCardReturnYN.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteCorpCardReturnYN(
			@RequestParam(value = "deleteSeq",	required = false, defaultValue="") String deleteSeq) throws Exception{
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("deleteSeq",	deleteSeq);
			resultList = corpCardSvc.deleteCorpCardReturnYN(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
