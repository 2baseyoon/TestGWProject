package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.DeadlineSvc;


/**
 * @Class Name : DeadlineCon.java
 * @Description : 마감일자 컨트롤러
 * @Modification Information 
 * @ 2018.03.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018. 03.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class DeadlineCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private DeadlineSvc deadlineSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getDeadlineInfo
	 * @Description : 마감일자 정보 조회
	 */
	@RequestMapping(value = "deadline/getDeadlineInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getDeadlineInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "companyCode" , required = false , defaultValue="") String companyCode
			) throws Exception{

		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("companyCode", companyCode);
			
			resultList = deadlineSvc.getDeadlineInfo(params);
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
	 * @Method Name : saveDeadlineInfo
	 * @Description : 마감일자 정보 저장
	 */
	@RequestMapping(value = "deadline/saveDeadlineInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveDeadlineInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "companyCode" , required = false , defaultValue="") String companyCode,
			@RequestParam(value = "noticeText" , required = false , defaultValue="") String noticeText,
			@RequestParam(value = "deadlineStartDate" , required = false , defaultValue="") String deadlineStartDate,
			@RequestParam(value = "deadlineFinishDate" , required = false , defaultValue="") String deadlineFinishDate,
			@RequestParam(value = "standardMonth" , required = false , defaultValue="") String standardMonth,
			@RequestParam(value = "isUse" , required = false , defaultValue="") String isUse,
			@RequestParam(value = "control" , required = false , defaultValue="") String control
			) throws Exception{
		
		CoviMap resultList = new CoviMap();
		CoviMap params 		= new CoviMap();
		
		try {
			params.put("companyCode", companyCode);
			params.put("noticeText", noticeText);
			params.put("deadlineStartDate", deadlineStartDate);
			params.put("deadlineFinishDate", deadlineFinishDate);
			params.put("standardMonth", standardMonth);
			params.put("isUse", isUse);
			params.put("control", control);
			
			resultList = deadlineSvc.saveDeadlineInfo(params);
			resultList.put("status" , Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			resultList.put("status" , Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
}
