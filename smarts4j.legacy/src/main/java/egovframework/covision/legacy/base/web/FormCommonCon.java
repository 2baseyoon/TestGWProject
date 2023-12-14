package egovframework.covision.legacy.base.web;

import java.nio.charset.StandardCharsets;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import net.sf.json.JSONException;


import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.covision.legacy.base.service.FormCommonSvc;

/**
 * @Class Name : CommonCon.java
 * @Description : 공통컨트롤러
 * @Modification Information 
 * @ 2016.05.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 05.20
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class FormCommonCon {
	private static final Logger LOGGER = LogManager.getLogger(FormCommonCon.class);
	
	@Autowired
	private FormCommonSvc formCommonSvc;
		
	@RequestMapping(value = "form/executeLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDataList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String dataInfo = null;
		String formInstID = "";

		CoviMap returnList = new CoviMap();
		
		try{
			String formPrefix;
			String bodyContext;
			String formInfoExt;
			String approvalContext;
			String preApproveprocsss;
			String apvResult;
			String docNumber;
			String approverId;
			String apvMode;
			String processID;
			String formHelperContext;
			String formNoticeContext;
			CoviMap legacyInfo = new CoviMap();
			
			if(request.getParameter("LegacyInfo") != null){
				dataInfo = new String(Base64.decodeBase64(request.getParameter("LegacyInfo")), StandardCharsets.UTF_8);
				try {
					legacyInfo = CoviMap.fromObject(dataInfo);
				} catch (JSONException e) {
					legacyInfo = (CoviMap)CoviList.fromObject(dataInfo).get(0);
				}
				
				formPrefix = new String(Base64.decodeBase64(legacyInfo.getString("formPrefix")), StandardCharsets.UTF_8);
				formInfoExt = new String(Base64.decodeBase64(legacyInfo.getString("formInfoExt")), StandardCharsets.UTF_8);
				approvalContext = new String(Base64.decodeBase64(legacyInfo.getString("approvalContext")), StandardCharsets.UTF_8);
				preApproveprocsss = new String(Base64.decodeBase64(legacyInfo.getString("preApproveprocsss")), StandardCharsets.UTF_8);
				apvResult = new String(Base64.decodeBase64(legacyInfo.getString("apvResult")), StandardCharsets.UTF_8);
				docNumber = new String(Base64.decodeBase64(legacyInfo.getString("docNumber")), StandardCharsets.UTF_8);
				approverId = new String(Base64.decodeBase64(legacyInfo.getString("approverId")), StandardCharsets.UTF_8);
				formInstID = new String(Base64.decodeBase64(legacyInfo.getString("formInstID")), StandardCharsets.UTF_8);
				apvMode = new String(Base64.decodeBase64(legacyInfo.getString("apvMode")), StandardCharsets.UTF_8);
				processID = legacyInfo.has("processID")?new String(Base64.decodeBase64(legacyInfo.getString("processID")), StandardCharsets.UTF_8):"";
				formHelperContext = legacyInfo.has("formHelperContext")?new String(Base64.decodeBase64(legacyInfo.getString("formHelperContext")), StandardCharsets.UTF_8):"";
				formNoticeContext = legacyInfo.has("formNoticeContext")?new String(Base64.decodeBase64(legacyInfo.getString("formNoticeContext")), StandardCharsets.UTF_8):"";
				
				bodyContext = StringUtils.defaultIfEmpty(request.getParameter("BodyContext"),"");
			} else {
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("LegacyInfo"); 
				legacyInfo = CoviMap.fromObject(dataInfo);
				
				formPrefix = new String(Base64.decodeBase64(legacyInfo.getString("formPrefix")), StandardCharsets.UTF_8);
				formInfoExt = new String(Base64.decodeBase64(legacyInfo.getString("formInfoExt")), StandardCharsets.UTF_8);
				approvalContext = new String(Base64.decodeBase64(legacyInfo.getString("approvalContext")), StandardCharsets.UTF_8);
				preApproveprocsss = new String(Base64.decodeBase64(legacyInfo.getString("preApproveprocsss")), StandardCharsets.UTF_8);
				apvResult = new String(Base64.decodeBase64(legacyInfo.getString("apvResult")), StandardCharsets.UTF_8);
				docNumber = new String(Base64.decodeBase64(legacyInfo.getString("docNumber")), StandardCharsets.UTF_8);
				approverId = new String(Base64.decodeBase64(legacyInfo.getString("approverId")), StandardCharsets.UTF_8);
				formInstID = new String(Base64.decodeBase64(legacyInfo.getString("formInstID")), StandardCharsets.UTF_8);
				apvMode = new String(Base64.decodeBase64(legacyInfo.getString("apvMode")), StandardCharsets.UTF_8);
				processID = legacyInfo.has("processID")?new String(Base64.decodeBase64(legacyInfo.getString("processID")), StandardCharsets.UTF_8):"";
				formHelperContext = legacyInfo.has("formHelperContext")?new String(Base64.decodeBase64(legacyInfo.getString("formHelperContext")), StandardCharsets.UTF_8):"";
				formNoticeContext = legacyInfo.has("formNoticeContext")?new String(Base64.decodeBase64(legacyInfo.getString("formNoticeContext")), StandardCharsets.UTF_8):"";
				
				bodyContext = jsonObj.optString("BodyContext");
			}
			
			CoviMap spParams = new CoviMap(); //각 프로시저 매개변수
			
			spParams.put("formPrefix",formPrefix);
			spParams.put("bodyContext",bodyContext);
			spParams.put("formInfoExt",formInfoExt);
			spParams.put("approvalContext",approvalContext);
			spParams.put("preApproveprocsss",preApproveprocsss);
			spParams.put("apvResult",apvResult);
			spParams.put("docNumber",docNumber);
			spParams.put("approverId",approverId);
			spParams.put("formInstID",formInstID);
			spParams.put("apvMode",apvMode);
			spParams.put("processID",processID);
			spParams.put("formHelperContext",formHelperContext);
			spParams.put("formNoticeContext",formNoticeContext);
			
			switch(spParams.getString("formPrefix")){
				case "WF_FORM_LEGACY_SAMPLE": // 연동 샘플 양식
					formCommonSvc.execWF_FORM_LEGACY_SAMPLE(spParams);
				break;
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
			LOGGER.error("formInstID: " + formInstID + "\n" + e.getMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
			LOGGER.error("formInstID: " + formInstID + "\n" + e.getMessage(), e);
		}
		return returnList;
	}
}
