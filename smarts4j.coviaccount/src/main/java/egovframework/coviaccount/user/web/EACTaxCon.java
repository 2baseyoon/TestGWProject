package egovframework.coviaccount.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.EACTaxSvc;
import egovframework.coviframework.util.ComUtils;


@Controller
public class EACTaxCon {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
			
	@Autowired
	private EACTaxSvc eacTaxSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getEACTaxPopup
	 * @Description : 세금 계산서 팝업 호출
	 */
	@RequestMapping(value = "EACTax/getEACTaxPopup.do" , method = RequestMethod.GET)
	public ModelAndView getExchangeRatePopup(){
		String returnURL = "user/account/EACTaxPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : downloadTemplateFile
	 * @Description : 전표 가져오기 템플릿 다운로드
	 */
	@RequestMapping(value = "EACTax/downloadTemplateFile.do")
	public void downloadTemplateFile(HttpServletRequest request, HttpServletResponse response) throws Exception {
		InputStream in		= null;
		OutputStream os		= null;
		try {
			String fileName		= "TaxSample.csv";
			String csvPath		= request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//TaxSample.csv");
			
			File file			= new File(csvPath);
			os					= response.getOutputStream();
			in					= new FileInputStream(file);
			
			response.reset() ;
			response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+"\";");    
			response.setContentType("application/octet-stream;charset=utf-8"); 
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setHeader("Content-Length", ""+file.length() );
			response.getOutputStream().flush();
			
			byte b[]				= new byte[8192];
            int leng				= 0;
            int bytesBuffered		= 0;
            
            while ( (leng = in.read(b)) > -1){
            	os.write(b,0, leng);
            	bytesBuffered += leng;
            	if(bytesBuffered > 1024 * 1024){
            		bytesBuffered = 0;
            		os.flush();
            	}
            }
			
			os.flush();
		} catch (IOException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		} finally {
			if(in != null) { in.close(); }
			if(os != null) { os.close(); }
		}
	}
	
	/**
	 * @Method Name : getEACTaxMapList
	 * @Description : 건별 목록 리스트 조회
	 */
	@RequestMapping(value = "EACTax/getEACTaxMapList.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap getEACTaxMapListlist(
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="10")	String pageSize,
			@RequestParam(value = "sDate",			required = false)	String sDate,
			@RequestParam(value = "eDate",			required = false)	String eDate,
			@RequestParam(value = "useMapping",		required = false)	String useMapping,
			@RequestParam(value = "searchType",		required = false)	String searchType,
			@RequestParam(value = "searchWord",		required = false)	String searchWord) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params			= new CoviMap();
			String sortColumn		= "";
			String sortDirection	= "";
			sortBy	= sortBy.split(",")[0];
			
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("sDate",				sDate);
			params.put("eDate",				eDate);
			params.put("useMapping",		useMapping);
			params.put("searchType",		searchType);
			params.put("searchWord",		ComUtils.RemoveSQLInjection(searchWord, 100));
			
			returnList = eacTaxSvc.getEACTaxMapList(params);
			returnList.put("status",		Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	 * @Method Name : getEACTaxByCompanyList
	 * @Description : 건별 목록 리스트 조회
	 */
	@RequestMapping(value = "EACTax/getEACTaxByCompanyList.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap getEACTaxByCompanyList(
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="10")	String pageSize,
			@RequestParam(value = "sDate",			required = false)	String sDate,
			@RequestParam(value = "eDate",			required = false)	String eDate,
			@RequestParam(value = "searchType",		required = false)	String searchType,
			@RequestParam(value = "searchWord",		required = false)	String searchWord) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String sortColumn		= "";
			String sortDirection	= "";
			sortBy = sortBy.split(",")[0];
			
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",			companyCode);
			params.put("sDate",			sDate);
			params.put("eDate",			eDate);
			params.put("searchType",	searchType);
			params.put("searchWord",	ComUtils.RemoveSQLInjection(searchWord, 100));
			
			returnList = eacTaxSvc.getEACTaxByCompanyList(params);
			returnList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	 * @Method Name : EACTaxAutoMapping
	 * @Description : 건별 목록 자동 맵핑
	 */
	@RequestMapping(value = "EACTax/EACTaxAutoMapping.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap EACTaxAutoMapping(
			@RequestParam(value = "userCode",		required = false)	String userCode,
			@RequestParam(value = "sDate",			required = false)	String sDate,
			@RequestParam(value = "eDate",			required = false)	String eDate) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("sDate",			sDate);
			params.put("eDate",			eDate);
			params.put("userCode",		userCode);
			
			returnList = eacTaxSvc.EACTaxAutoMapping(params);
			returnList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	 * @Method Name : EACTaxInitial
	 * @Description : 건별 목록 초기화
	 */
	@RequestMapping(value = "EACTax/EACTaxInitial.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap EACTaxInitial(
			@RequestParam(value = "userCode",		required = false)	String userCode,
			@RequestParam(value = "sDate",			required = false)	String sDate,
			@RequestParam(value = "eDate",			required = false)	String eDate) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("sDate",			sDate);
			params.put("eDate",			eDate);
			params.put("userCode",		userCode);
			
			returnList = eacTaxSvc.EACTaxInitial(params);
			returnList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	 * @Method Name : registTaxMap
	 * @Description : 건별 목록 초기화
	 */
	@RequestMapping(value = "EACTax/registTaxMap.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap registTaxMap(
			@RequestParam(value = "userCode",		required = false)	String userCode,
			@RequestParam(value = "sID",			required = false)	String sID,
			@RequestParam(value = "tID",			required = false)	String tID) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("sID",			sID);
			params.put("tID",			tID);
			params.put("userCode",		userCode);
			
			returnList = eacTaxSvc.registTaxMap(params);
			returnList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	 * @Method Name : EACTaxExcelUpload
	 * @Description : 전표 가져오기 엑셀 업로드
	 */
	@RequestMapping(value = "EACTax/EACTaxExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap accountManageExcelPopup(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			returnList = eacTaxSvc.EACTaxExcelUpload(params);
			
			if(returnList.get("state").equals("DUPLICATE")){
				returnList.put("status",	"DUPLICATE");
				returnList.put("message",	"중복된 데이터가 포함되어 있습니다");
			}else{
				returnList.put("status",	Return.SUCCESS);
				returnList.put("message",	"업로드 되었습니다");
			}
		} catch (SQLException e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",		Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;		
	}
	
	/**
	* @Method Name : EACTaxMapListExcelDownload
	* @Description : 건별 목록 엑셀 다운로드 
	*/
	@RequestMapping(value = "EACTax/EACTaxMapListExcelDownload.do", method = RequestMethod.GET)
	public ModelAndView EACTaxMapListExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "companyCode",required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "headerName",	required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",	required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "useMapping",	required = false, defaultValue="")	String useMapping,
			@RequestParam(value = "searchType",	required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchWord",	required = false, defaultValue="")	String searchWord,
			@RequestParam(value = "title",		required = false, defaultValue="")	String title,
			@RequestParam(value = "sDate",		required = false, defaultValue="")	String sDate,
			@RequestParam(value = "eDate",		required = false, defaultValue="")	String eDate,
			@RequestParam(value = "headerType",	required = false, defaultValue="")	String headerType
			) {

		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("useMapping",	commonCon.convertUTF8(useMapping));
			params.put("searchType",	commonCon.convertUTF8(searchType));
			params.put("searchWord",	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchWord, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			params.put("sDate",			commonCon.convertUTF8(sDate));
			params.put("eDate",			commonCon.convertUTF8(eDate));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			resultList = eacTaxSvc.searchTaxMapListExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType", commonCon.convertUTF8(headerType));

			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
	
	/**
	 * @Method Name : EACTaxByCompanyListExcelDownload
	 * @Description : 거래처별 목록 엑셀 다운로드 
	 */
	@RequestMapping(value = "EACTax/EACTaxByCompanyListExcelDownload.do", method = RequestMethod.GET)
	public ModelAndView EACTaxByCompanyListExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "companyCode",required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "headerName",	required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",	required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "searchType",	required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchWord",	required = false, defaultValue="")	String searchWord,
			@RequestParam(value = "title",		required = false, defaultValue="")	String title,
			@RequestParam(value = "sDate",		required = false, defaultValue="")	String sDate,
			@RequestParam(value = "eDate",		required = false, defaultValue="")	String eDate,
			@RequestParam(value = "headerType",	required = false, defaultValue="")	String headerType
			) {
		
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("searchType",	commonCon.convertUTF8(searchType));
			params.put("searchWord",	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchWord, 100)));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			params.put("sDate",			commonCon.convertUTF8(sDate));
			params.put("eDate",			commonCon.convertUTF8(eDate));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			resultList = eacTaxSvc.searchTaxByCompanyListExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType", commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
}
