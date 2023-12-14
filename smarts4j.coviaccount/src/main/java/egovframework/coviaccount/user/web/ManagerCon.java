package egovframework.coviaccount.user.web;

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
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.ManagerSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : SampleCon.java
 * @Description : 샘플컨트롤러
 * @Modification Information 
 * @ 2018.03.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018. 03.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ManagerCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private ManagerSvc managerSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getManagerlist
	 * @Description : 담당자관리 목록 조회
	 */
	@RequestMapping(value = "manager/getManagerlist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getManagerlist(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "startDD",			required = false, defaultValue="")	String startDD,
			@RequestParam(value = "endDD",				required = false, defaultValue="")	String endDD,
			@RequestParam(value = "managerSearchType",	required = false, defaultValue="") String managerSearchType ,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr) throws Exception{
			
		CoviMap resultList = new CoviMap();
		try {
			int pageSize = 10;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length()> 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}
			
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
			params.put("startDD",		startDD);
			params.put("endDD",			endDD);
			params.put("managerSearchType", managerSearchType);
			params.put("searchStr", 	ComUtils.RemoveSQLInjection(searchStr, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDD") != null && !params.get("startDD").equals("")){
				params.put("startDD",ComUtils.TransServerTime(params.get("startDD").toString() + " 00:00:00"));
			}
			if(params.get("endDD") != null && !params.get("endDD").equals("")){
				params.put("endDD",ComUtils.TransServerTime(params.get("endDD").toString() + " 23:59:59"));
			}
			
			resultList = managerSvc.getManagerList(params);
			
			resultList.put("result" , "ok");
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
	 * @Method Name : getManagerPopup
	 * @Description : 담당자 관리 팝업 호출
	 */
	@RequestMapping(value = "manager/getManagerPopup.do" , method = RequestMethod.GET)
	public ModelAndView getManagerPopup(HttpServletRequest request){
		String returnURL = "user/account/ManagerPopup";
		ModelAndView mav = new ModelAndView(returnURL);

		String managerID = request.getParameter("ManagerID");
		
		mav.addObject("ManagerID", managerID);
		
		return mav;
	}
	
	/**
	 * @Method Name : saveManagerInfo
	 * @Description : 담당자 관리 저장
	 */
	@RequestMapping(value = "manager/saveManagerInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveManagerInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "CompanyCode",		required = false , defaultValue="") String companyCode,
			@RequestParam(value = "ManagerUserCode",	required = false , defaultValue="") String managerUserCode,
			@RequestParam(value = "TaxMailAddress",		required = false , defaultValue="") String taxMailAddress,
			@RequestParam(value = "ManagerID",			required = false , defaultValue="") String managerID) throws Exception{
		
		CoviMap resultList = new CoviMap();
		CoviMap params 		= new CoviMap();
		
		try {
			params.put("CompanyCode",			companyCode);
			params.put("ManagerUserCode",	managerUserCode);
			params.put("TaxMailAddress",	ComUtils.RemoveScriptAndStyle(taxMailAddress));
			params.put("ManagerID",			managerID);
			
			resultList = managerSvc.saveManagerInfo(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteManagerInfo
	 * @Description : 담당자관리 삭제
	 */
	@RequestMapping(value = "manager/deleteManagerInfo.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteManagerInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq", required = false , defaultValue ="") String deleteSeq
			) throws Exception {
		CoviMap resultList  = new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			params.put("deleteSeq" , deleteSeq);
			managerSvc.deleteManagerInfo(params);
			
			resultList.put("result" , "ok");
			resultList.put("status" , Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message" , "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : managerExcelDownload
	 * @Description : 담당자 관리 엑셀 다운로드
	 */
	@RequestMapping(value ="manager/managerExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView managerExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",			required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "startDD",			required = false, defaultValue="")	String startDD,
			@RequestParam(value = "endDD",				required = false, defaultValue="")	String endDD,
			@RequestParam(value = "userCode",			required = false, defaultValue="") String userCode,
			@RequestParam(value = "managerSearchType",	required = false, defaultValue="") String managerSearchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="") String searchStr,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("userCode",			commonCon.convertUTF8(userCode));
			params.put("managerSearchType",	commonCon.convertUTF8(managerSearchType));
			params.put("searchStr",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("companyCode",		commonCon.convertUTF8(companyCode));
			params.put("startDD",			commonCon.convertUTF8(startDD));
			params.put("endDD",				commonCon.convertUTF8(endDD));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			
			//timezone 적용 날짜변환
			if(params.get("startDD") != null && !params.get("startDD").equals("")){
				params.put("startDD",ComUtils.TransServerTime(params.get("startDD").toString() + " 00:00:00"));
			}
			if(params.get("endDD") != null && !params.get("endDD").equals("")){
				params.put("endDD",ComUtils.TransServerTime(params.get("endDD").toString() + " 23:59:59"));
			}
						
			resultList = managerSvc.managerExcelDownload(params);
			
			viewParams.put("list" ,		resultList.get("list"));
			viewParams.put("cnt"  , 	resultList.get("cnt"));
			viewParams.put("headerName",headerNames);
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL , viewParams);
		
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}	

	/**
	 * @Method Name : searchManagerInfo
	 * @Description : 관리자 관리 상세 정보 조회
	 */
	@RequestMapping(value="manager/searchManagerInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchManagerInfo(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String ManagerID =  request.getParameter("ManagerID");
			
			CoviMap params = new CoviMap();
			params.put("ManagerID", ManagerID);
			resultMap = managerSvc.searchManagerInfo(params);
			returnObj.put("data", resultMap.get("result"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (SQLException e) {
			returnObj.put("status",	Return.FAIL);
			returnObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
}
