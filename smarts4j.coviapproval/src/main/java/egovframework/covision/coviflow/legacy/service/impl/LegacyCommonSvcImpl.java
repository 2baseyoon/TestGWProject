package egovframework.covision.coviflow.legacy.service.impl;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;


import net.sf.json.JSONException;


import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("legacyCommonService")
public class LegacyCommonSvcImpl extends EgovAbstractServiceImpl implements LegacyCommonSvc {
	private static final Logger LOGGER = LogManager.getLogger(LegacyCommonSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	public FormSvc formSvc;
	
	@Override
	public void insertLegacy(String mode, String state, String parameters, Exception ex) throws Exception{
		//SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		//String eventTime = null;
		
		parameters = parameters.replace("&quot;", "\"");
		
		Map<String, Object> params = new HashMap<>();
		params.put("parameters", parameters);
		params.put("mode", mode);
		params.put("state", state);
		
		//eventTime = sdf.format(new Date());
		
		//params.put("eventTime", eventTime);
		
		CoviMap legacyInfo = new CoviMap();
		try {
			legacyInfo = CoviMap.fromObject(parameters);
		} catch (JSONException e) {
			legacyInfo = (CoviMap)CoviList.fromObject(parameters).get(0);
		}
		
		String formInstID = null; 
		if(legacyInfo.containsKey("formInstID")) {
			formInstID = new String(Base64.decodeBase64(legacyInfo.getString("formInstID")), StandardCharsets.UTF_8);
		} else if (legacyInfo.containsKey("FormInstId")) { // MESSAGE
			formInstID = legacyInfo.getString("FormInstId");
		} else if (legacyInfo.containsKey("context")) { // DISTRIBUTION
			Object contextObj = legacyInfo.get("context");
			if(contextObj instanceof String) {
				formInstID = (String) CoviMap.fromObject(legacyInfo.get("context")).get("FormInstID");
			}else {
				formInstID = legacyInfo.getJSONObject("context").getString("FormInstID");
			}
		}
		params.put("FormInstID", formInstID);
		
		if(legacyInfo.containsKey("processID")) {
			String processID = new String(Base64.decodeBase64(legacyInfo.getString("processID")), StandardCharsets.UTF_8);
			params.put("ProcessID", processID);
		}
		if(legacyInfo.containsKey("formPrefix")) {
			String formPrefix = new String(Base64.decodeBase64(legacyInfo.getString("formPrefix")), StandardCharsets.UTF_8);
			params.put("FormPrefix", formPrefix);
		}
		if(legacyInfo.containsKey("docNumber")) {
			String docNumber = mode.equalsIgnoreCase("DISTRIBUTION") ? legacyInfo.getString("docNumber") : new String(Base64.decodeBase64(legacyInfo.getString("docNumber")), StandardCharsets.UTF_8);
			params.put("DocNumber", docNumber);
		}
		if(legacyInfo.containsKey("approverId")) {
			String approverId = new String(Base64.decodeBase64(legacyInfo.getString("approverId")), StandardCharsets.UTF_8);
			params.put("ApproverId", approverId);
		}
		if(legacyInfo.containsKey("apvMode")) {
			String apvMode = new String(Base64.decodeBase64(legacyInfo.getString("apvMode")), StandardCharsets.UTF_8);
			params.put("ApvMode", apvMode);
		}
		if(legacyInfo.containsKey("formInfoExt")) {
			String formInfoExt = new String(Base64.decodeBase64(legacyInfo.getString("formInfoExt")), StandardCharsets.UTF_8);
			params.put("FormInfoExt", formInfoExt);
		}
		if(legacyInfo.containsKey("approvalContext")) {
			String approvalContext = new String(Base64.decodeBase64(legacyInfo.getString("approvalContext")), StandardCharsets.UTF_8);
			params.put("ApprovalContext", approvalContext);
		}
		
		//error message
		if(ex != null){
			params.put("errorMessage", ex.getMessage());
			//stacktrace
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			ex.printStackTrace(pw);
			
			params.put("errorStackTrace", sw.toString());
			//class name
			params.put("errorClass", ex.getClass().toString());
			
			
			// [20-05-07] 오류발생 시, 관리자에게 알림메일 발송 추가
			if(mode.equalsIgnoreCase("LEGACY")) {
				String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path");
				String httpCommURL = approvalURL + "/legacy/setmessage.do";
				String errorReceivers = RedisDataUtil.getBaseConfig("ErrorReceiverCode");
				String errorSender = RedisDataUtil.getBaseConfig("ErrorSenderCode");
				
				CoviList messageInfos = new CoviList();
				for(String recevierCode : errorReceivers.split(";")) {
					CoviMap messageInfo = new CoviMap();
					
					messageInfo.put("UserId", recevierCode);
					messageInfo.put("Subject", "");
					messageInfo.put("Initiator", errorSender);
					messageInfo.put("Status", "LEGACYERROR"); 
					messageInfo.put("ProcessId", params.get("ProcessID").toString()); 
					messageInfo.put("WorkitemId", "");
					messageInfo.put("FormInstId", params.get("FormInstID").toString());
					messageInfo.put("FormName", "");
					messageInfo.put("ApproveCode", "");
					messageInfo.put("Type", "UR");
					
					messageInfo.put("Comment", ex.getMessage());
					
					messageInfos.add(messageInfo);	
				}
				
				if(!messageInfos.isEmpty()) {
					CoviMap params2 = new CoviMap();
					params2.put("MessageInfo", messageInfos);
					
					HttpsUtil httpsUtil = new HttpsUtil();
					httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8", null);	
				}
			}
		}
		else {
			params.put("errorMessage", "");
			params.put("errorStackTrace", "");
		}
		
		//Legacy만 저장
		//message도 저장해야 할 경우 ||mode.equalsIgnoreCase("MESSAGE") 추가
		if(mode.equalsIgnoreCase("LEGACY")||
				mode.equalsIgnoreCase("DISTRIBUTION") || 
				(mode.equalsIgnoreCase("MESSAGE") && ex != null)){
			coviMapperOne.insert("legacy.common.insertLegacy_param", params);
		}
	}
	
	@Override
	public CoviMap selectGrid(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("legacy.common.selectGridCount", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);		
		
		CoviList list = coviMapperOne.list("legacy.common.selectGrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap getVacInfoForUser(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacInfoForUser", params);
		
		CoviMap resultList = new CoviMap();

		resultList.put("list",CoviSelectSet.coviSelectJSON(list,"VACDAY,DAYSREQ,DAYSCAN,USEDAYS,ATot"));
		
		return resultList;
	}	
	
	@Override
	public void deleteLegacyErrorLog(CoviMap params) throws Exception {		
		coviMapperOne.update("legacy.common.deleteLegacyErrorLog", params);
	}
	
	@Override
	public void updateLegacyRetryFlag(String legacyID) throws Exception {
		CoviMap params = new CoviMap();
		params.put("LegacyID", legacyID);
		coviMapperOne.update("legacy.common.updateLegacyRetryFlag", params);
	}
	
	@Override
	public void docInfoselectInsert(CoviMap params) throws Exception {		
		coviMapperOne.insert("legacy.common.docInfoselectInsert", params);
	}

	@Override
	public CoviMap getBodyData(CoviMap params) throws Exception {
		CoviMap bodyData = new CoviMap();
		String formID = params.optString("FormID");
		String formInstID = params.optString("FormInstID");
		
		if(StringUtils.isNotBlank(formID)) { 
			CoviMap formParams = new CoviMap();
			formParams.put("formID", formID);
			formParams.put("isSaaS", PropertiesUtil.getGlobalProperties().getProperty("isSaaS"));
			
			CoviMap extInfo = null;
			CoviMap subtableInfo = null;
			//CoviMap form = coviMapperOne.select("form.formLoad.selectForm", formParams);
			CoviMap form = formSvc.selectForm(formParams).optJSONArray("list").getMap(0);
			
			if(!form.optString("ExtInfo").equals("")){
				extInfo = form.getJSONObject("ExtInfo");
			}
			if(!form.optString("SubTableInfo").equals("")) {
				subtableInfo = form.getJSONObject("SubTableInfo");
			}
			
			bodyData = formSvc.getBodyData(subtableInfo, extInfo, formInstID);
		}
		
		return bodyData;
	}
	
	@Override
	public CoviList getLegacyInterfaceInfo(CoviMap params) throws Exception {
		// ApvMode 당 n 개일수 있음.
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("legacy.interface.config.selectConfig", params));
	}
	
	// 연동 로그 기록(자동화)
	@Override
	public CoviMap insertInterfaceHistory(CoviMap logParam, Exception ex, String callType) throws Exception {
		if(ex != null){
			LOGGER.error(ex.getLocalizedMessage(), ex);
			
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			ex.printStackTrace(pw);
			logParam.put("State", Return.FAIL);
			logParam.put("ErrorStackTrace", sw.toString());
		}
		if(callType != null && !callType.equals("CHECK")) coviMapperOne.insert("legacy.common.insertLegacyIfHistory", logParam); // 테스트일땐 로그기록하지않음
		return logParam;
	}
	
	// 연동 로그 기록(자동화) - logParam정보 만들기 전에 오류난경우 가지고있는 파라미터로 로그기록
	@Override
	public CoviMap insertInterfaceHistory(CoviMap legacyInfo, CoviMap spParams, Exception ex, String callType) throws Exception {
		CoviMap logParam = makeLogParamDefault(legacyInfo, spParams); // 기본 로그셋팅(EventStartTime,LegacyConfigID,FormPrefix,FormInstID,ProcessID,Subject,UserCode,ApvMode,IfType,LegacyInfo,Parameters)
		logParam.remove("EventStartTime");
		if(ex != null){
			LOGGER.error(ex.getLocalizedMessage(), ex);
			
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			ex.printStackTrace(pw);
			logParam.put("State", Return.FAIL);
			logParam.put("ErrorStackTrace", sw.toString());
		}
		if(callType != null && !callType.equals("CHECK")) coviMapperOne.insert("legacy.common.insertLegacyIfHistory", logParam); // 테스트일땐 로그기록하지않음
		return logParam;
	}
	
	@Override
	public CoviMap getInterfaceHistory(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectMapJSON(coviMapperOne.selectOne("legacy.common.selectLegacyIfHistory", params));
	}
	
	// 결재연동(자동화) logParam 기본정보 셋팅
	@Override
	public CoviMap makeLogParamDefault(CoviMap legacyInfo, CoviMap spParams) throws Exception {
		CoviMap defaultLogParam = new CoviMap();
		
		defaultLogParam.put("LegacyConfigID", legacyInfo.optString("LegacyConfigID"));
		defaultLogParam.put("EventStartTime", new Date());
		defaultLogParam.put("FormPrefix", spParams.optString("formPrefix"));
		defaultLogParam.put("FormInstID", spParams.optString("formInstID"));
		defaultLogParam.put("ProcessID", spParams.optString("processID"));
		defaultLogParam.put("Subject", spParams.optString("subject"));
		defaultLogParam.put("UserCode", spParams.optString("approverId"));
		defaultLogParam.put("ApvMode", spParams.optString("apvMode"));
		defaultLogParam.put("IfType", legacyInfo.optString("IfType"));
		defaultLogParam.put("LegacyInfo", new CoviMap(legacyInfo));
		defaultLogParam.put("Parameters", new CoviMap(spParams));
		
		return defaultLogParam;
	}
	
	// 연동 Event별 설정에 따른 Param setting
	@Override
	public CoviMap makeLegacyParams(CoviMap legacyInfo, CoviMap spParams) throws Exception {
		CoviMap legacyParams = new CoviMap();
		String ifType = legacyInfo.optString("IfType");
		
		if(ifType.equals("JAVA")) { // JAVA 타입만 legacyParams 대신 spParams(전체데이터) 사용
			legacyParams = spParams;
		} else {
			legacyParams.put("paramDataType","L"); // 데이터타입 - A(전체데이터 spParams) , L(일부 추출된데이터 legacyParams)
			spParams.put("paramDataType","L");
			
			String bodyContext = StringUtil.replaceNull(spParams.optString("bodyContext"),"{}");
			CoviMap bodyContextObj = new CoviMap(bodyContext);
			bodyContextObj.remove("tbContentElement");
			
			CoviMap formInstance = spParams.optJSONObject("formInstance");
			
			for(Object entrySet : spParams.entrySet()) {
				Map.Entry<String, Object> entry = (Map.Entry<String, Object>)entrySet;
				if(entry.getValue() instanceof String || entry.getValue() instanceof Integer || entry.getValue() instanceof Boolean 
						|| entry.getValue().getClass() == int.class 
						|| entry.getValue().getClass() == boolean.class) {
					legacyParams.put(entry.getKey(), entry.getValue());
				}
			}
			legacyParams.putAll(formInstance);
			legacyParams.putAll(bodyContextObj);
			
			// BodyData
			try {
				CoviMap bodyData = spParams.optJSONObject("bodyData");
				legacyParams.putAll(bodyData.getJSONObject("MainTable"));
			}catch(NullPointerException e) {
				LOGGER.warn(e.getLocalizedMessage(), e);
			}catch(Exception e) {
				LOGGER.warn(e.getLocalizedMessage(), e);
			}
		}
		
		return legacyParams;
	}
	
	@Override
	public CoviMap selectEachGrid(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("legacy.common.selectEachGridCount", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);		
		
		CoviList list = coviMapperOne.list("legacy.common.selectEachGrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public void deleteEachLegacyErrorLog(CoviMap params) throws Exception {		
		coviMapperOne.update("legacy.common.deleteEachLegacyErrorLog", params); 
	}
	
}
