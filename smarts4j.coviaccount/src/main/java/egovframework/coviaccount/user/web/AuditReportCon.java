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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
//import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.AuditReportSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : AuditReportCon.java
 * @Description : 감사 레포트
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class AuditReportCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AuditReportSvc auditReportSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	
	/**
	 * @Method Name : getAuditReportList
	 * @Description : 감사 레포팅 조회
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "auditReport/getAuditReportList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAuditReportList(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= request.getParameter("sortColumn");
			String sortDirection	= request.getParameter("sortDirection");
			String sortBy			= StringUtil.replaceNull(request.getParameter("sortBy"),"");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			StringUtil.replaceNull(request.getParameter("pageNo"),"1"));
			params.put("pageSize",			StringUtil.replaceNull(request.getParameter("pageSize"),"1"));
			
			params.put("proofDate",			StringUtil.replace(request.getParameter("proofDate"),"-",""));
			params.put("reportType",		request.getParameter("reportType"));
			params.put("companyCode",		request.getParameter("companyCode"));
			
			resultList = auditReportSvc.getAuditReportList(params);
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
	 * @Method Name : downloadExcel
	 * @Description : 다운로드
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "auditReport/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest	request,			HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(request.getParameter("headerName"),"utf-8").split("†");
			String[] headerKeys  = StringUtil.replaceNull(commonCon.convertUTF8(headerKey)).split(",");
			
			CoviMap params = new CoviMap();
			
			params.put("proofDate",			StringUtil.replace(request.getParameter("proofDate"),"-",""));
			params.put("reportType",		request.getParameter("reportType"));
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("headerName",		headerName);
			params.put("headerKey",			headerKey);
			params.put("isExcel",			"Y");
			
			CoviMap resultList = auditReportSvc.getAuditReportList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",			accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}		
}
