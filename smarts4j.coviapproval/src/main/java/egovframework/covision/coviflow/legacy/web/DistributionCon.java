package egovframework.covision.coviflow.legacy.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.coviflow.legacy.service.DistributionSvc;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;


/**
 * @Class Name : DistributionCon.java
 * @Description : 배포 서비스 요청
 * @Modification Information 
 * @ 2017.05.18 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 05.18
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class DistributionCon {

	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	
	@Autowired
	private DistributionSvc distributionSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "legacy/startDistribution.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDataFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String dataInfo = null;
		
		try
		{
			/*
			 * {
			 * 		"DistributionInfo" : {
			 * 			"type" : "",
			 * 			"context" : "",
			 * 			"approvalLine" : "",
			 * 			"piid" : "",
			 * 			"receiptList" : ""
			 * 		}
			 * }
			 */
			
			if(request.getParameter("DistributionInfo") != null){
				dataInfo = request.getParameter("DistributionInfo");
			} else {
				//String bodyInfo = messageSvc.getBody(request);
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("DistributionInfo"); 
			}
			
			if(dataInfo != null){
				String escapedJson = StringEscapeUtils.unescapeHtml(dataInfo);		
				//CoviMap tempObj = CoviMap.fromObject(escapedJson);
				// insert dataInfo. 다안조건에 따라 처리
				
				String returnval = distributionSvc.startDistribution(escapedJson);
				if(returnval.equals("SUCCESS")){
					CoviMap getInfojsonObj = CoviMap.fromObject(escapedJson);
					Object contextObj = getInfojsonObj.get("context");
					CoviMap getContextObj = null; 
					if(contextObj instanceof CoviMap) {
						getContextObj = (CoviMap) getInfojsonObj.get("context");
					}else if(contextObj instanceof String) {
						String context =  (String) getInfojsonObj.get("context");
						getContextObj = CoviMap.fromObject(context);
					}

					String fiid = getInfojsonObj.optString("fiid");
					String multiEditReceiptGubun = (getContextObj != null) ? getContextObj.optString("MultiEditReceiptGubun") : "";					
				
					if(!fiid.equals("") && multiEditReceiptGubun.equals("Y")) {
						CoviMap params = new CoviMap();
						params.put("FormInstID", fiid);
						legacyCmmnSvc.docInfoselectInsert(params);
					}
		        }
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", dataInfo);
			
			legacyCmmnSvc.insertLegacy("DISTRIBUTION", "complete", dataInfo, null);
			
			// 오류목록에서 재처리한 경우 재처리대상(원본) 레코드에 Flag 처리한다.
			if(!StringUtils.isEmpty(request.getParameter("LegacyID"))) {
				String legacyID = request.getParameter("LegacyID");
				legacyCmmnSvc.updateLegacyRetryFlag(legacyID);
			}
		}catch(NullPointerException npE){
			legacyCmmnSvc.insertLegacy("DISTRIBUTION", "error", dataInfo, npE);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			legacyCmmnSvc.insertLegacy("DISTRIBUTION", "error", dataInfo, e);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "legacy/deleteDistribution.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteDistribution(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String dataInfo = null;
		
		try
		{
			if(request.getParameter("Items") != null){
				dataInfo = request.getParameter("Items");
			} else {
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("Items"); 
			}
			
			if(dataInfo != null){
				String escapedJson = StringEscapeUtils.unescapeHtml(dataInfo);
				distributionSvc.deleteDistribution(escapedJson);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", dataInfo);
			
			legacyCmmnSvc.insertLegacy("DISTRIBUTION_DEL", "complete", dataInfo, null);
		}catch(NullPointerException npE){
			legacyCmmnSvc.insertLegacy("DISTRIBUTION_DEL", "error", dataInfo, npE);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			legacyCmmnSvc.insertLegacy("DISTRIBUTION_DEL", "error", dataInfo, e);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
}
