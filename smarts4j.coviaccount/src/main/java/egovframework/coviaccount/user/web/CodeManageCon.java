package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.CodeManageSvc;


/**
 * @Class Name : CodeManageCon.java
 * @Description : CodeManage 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CodeManageCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CodeManageSvc codeManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getCodeSearchGroupList
	 * @Description : 증빙별코드매핑 코드 그룹 조회
	 */
	@RequestMapping(value = "codemanage/getCodeSearchGroupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCodeSearchGroupList(
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{

		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			resultList = codeManageSvc.getCodeSearchGroupList(params);
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
	 * @Method Name : getCodeSearchList
	 * @Description : 증빙별코드매핑 목록 조회
	 */
	@RequestMapping(value = "codemanage/getCodeSearchList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCodeSearchList(
			@RequestParam(value = "proofCode",	required = false, defaultValue="")	String proofCode,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{

		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("proofCode", proofCode);
			params.put("companyCode", companyCode);
			resultList = codeManageSvc.getCodeSearchList(params);
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
	 * @Method Name : saveCodeManageInfo
	 * @Description : 증빙별코드매핑 저장
	 */
	@RequestMapping(value = "codemanage/saveCodeManageInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCodeManageInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
		try {
			codeManageSvc.saveCodeManageInfo(params);
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
}
