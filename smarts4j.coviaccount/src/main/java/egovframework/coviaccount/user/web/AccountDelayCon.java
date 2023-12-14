package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.user.service.AccountDelaySvc;

@Scope("request")
@Controller
public class AccountDelayCon {

	@Autowired
	private AccountDelaySvc accountDelaySvc;
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
//	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 지연 미상신 내역 통합알림서비스
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doAutoDelayAlam.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAutoDelayAlam(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();

		CoviMap cmap = new CoviMap();
		cmap.put("companyCode",request.getParameter("companyCode"));
		cmap.put("accountDelayTerm", RedisDataUtil.getBaseConfig("AccountDelayTerm"));
		CoviMap dataMap = accountDelaySvc.getSendFlag(cmap);
		try{
			if ("Y".equals(dataMap.getString("SendFlag")) || "Y".equals(request.getParameter("DirectSend"))){
				// 대상 가져오기(TaskID)
				String targetStartDate = RedisDataUtil.getBaseConfig("AccountDelayStartDay");
				String targetEndDate = dataMap.getString("StartDate").substring(0,8);
				String SendAlamList = request.getParameter("SendAlamList");
				String DelayManagerList = request.getParameter("DelayManagerList");
				
				String accountDelayStartDay = (targetStartDate != null && !targetStartDate.equals("")) ? targetStartDate : "2018-01-01"; //기초설정 AccountDelayStartDay
				String accountDelayEndDay = targetEndDate + RedisDataUtil.getBaseConfig("AccountDelayEndDay"); //마감일자관리 종료일
				
				cmap.put("SendType", request.getParameter("SendType"));
				cmap.put("senderCode", SessionHelper.getSession("UR_Code") ); 
				//cmap.put("accountDelayStartDay", "2018-01-" + RedisDataUtil.getBaseConfig("AccountDelayStartDay")); //01
				cmap.put("accountDelayStartDay", accountDelayStartDay);
				cmap.put("accountDelayEndDay", accountDelayEndDay);
				cmap.put("accountDelayMessage", RedisDataUtil.getBaseConfig("AccountDelayMessage"));
				if (RedisDataUtil.getBaseConfig("AccountDelayEndDay").equals("31")) cmap.put("accountDelayEndLast","Y");
				if (SendAlamList != null && !SendAlamList.equals("")) cmap.put("SendAlamList", SendAlamList.split(","));
				if (DelayManagerList != null && !DelayManagerList.equals("")) cmap.put("DelayManagerList", DelayManagerList.split(","));
				
				CoviMap data = accountDelaySvc.doDelayAlam(cmap);
				
				result.put("data", data);
				result.put("status", Return.SUCCESS);
				result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			}
			else {
				result.put("status", Return.FAIL);
				result.put("message", "Not Send Term["+dataMap.getString("DeadlineFinishDate")+","+RedisDataUtil.getBaseConfig("AccountDelayTerm") +"]");
			}
			
		} catch(SQLException e){
			result.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			result.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 지연 미상신 내역 통합알림서비스(미상신내역관리 메뉴에서 수동처리)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doManualDelayAlamCorpCard.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doManualDelayAlamCorpCard(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();

		try{
			
			String dataListStr =  StringEscapeUtils.unescapeHtml(request.getParameter("dataList"));
			CoviMap dataList = CoviMap.fromObject(dataListStr);
			String sendMailType = request.getParameter("sendMailType");

			CoviMap data = accountDelaySvc.doManualDelayAlamCorpCard(dataList, sendMailType);
			
			result.put("data", data);
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
		
		} catch(SQLException e){
			result.put("status", Return.FAIL);			
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			result.put("status", Return.FAIL);			
			logger.error(e.getLocalizedMessage(), e);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 지연 미상신 내역 통합알림서비스(미상신내역관리 메뉴에서 수동처리)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doManualDelayAlam.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doManualDelayAlam(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();

		try{
			
			String dataListStr =  StringEscapeUtils.unescapeHtml(request.getParameter("dataList"));
			CoviMap dataList = CoviMap.fromObject(dataListStr);
			String sendMailType = request.getParameter("sendMailType");

			CoviMap data = accountDelaySvc.doManualDelayAlam(dataList, sendMailType);
			
			result.put("data", data);
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
		
		} catch(SQLException e){
			result.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			result.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
}
