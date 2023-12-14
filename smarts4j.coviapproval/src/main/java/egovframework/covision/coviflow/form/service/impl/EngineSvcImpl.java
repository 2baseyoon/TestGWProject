package egovframework.covision.coviflow.form.service.impl;

import java.io.FileNotFoundException;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;

import javax.annotation.Resource;




import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.context.annotation.Scope;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.form.service.EngineSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.idgnr.impl.Base64;

@Scope("prototype")
@Service("EngineSvc")
public class EngineSvcImpl extends EgovAbstractServiceImpl implements EngineSvc {
	Logger LOGGER = LogManager.getLogger(EngineSvcImpl.class);
	
	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public void requestComplete(String taskId, CoviList params) throws Exception {
		CoviMap requestObj = new CoviMap();
		
		requestObj.put("taskId", taskId);
		requestObj.put("action", "complete");
		
		complete(requestObj, params);
	}

	@Override
	public int requestStart(String pdef, CoviList params) throws Exception {
		CoviMap requestObj = new CoviMap();
		int returnId = 0;
		
		requestObj.put("processDefinitionId", pdef);
		requestObj.put("variables", params);
		
		returnId = start(requestObj);
		
		return returnId;
	}
	
	@Override
	public void requestAbort(CoviMap formObj) throws Exception {
		if(formObj.optString("mode").equalsIgnoreCase("ABORT")){
			deleteProcess(formObj.getString("piid"));
		}
	}

	@Override
	public void requestUpdate() throws Exception {
		updateProcess();
	}
	
	@Override
	public void requestUpdateValue(String taskID, String variableName, CoviMap params) throws Exception {
		updateVariable(taskID, variableName, params);
	}
	
	@Override
	public CoviList requestGetActivitiVariables(String taskID) throws Exception {
		return getActivitiVariables(taskID);
	}
	
	@Override
	public String requestGetActivitiVariables(String taskID, String variableName) throws Exception {
		return getActivitiVariables(taskID, variableName);
	}
	
	//Activiti////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//Activiti Process Start 
	private int start(CoviMap obj) throws Exception{
		String activitiURL = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");//http://192.168.11.126:8081
		String httpCommURL = activitiURL+"/service/runtime/process-instances";
		HttpsUtil httpsUtil = new HttpsUtil();
        
        //make connection
        
        String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
        String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");
		java.util.Map<String, Object> result = httpsUtil.httpsClientConnectResponse(httpCommURL, "POST", obj, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
		
		CoviMap returnList = null;
		String jsonResponseStr = "";
		if(result != null) {
			jsonResponseStr = (String)result.get("MESSAGE");
			returnList = CoviMap.fromObject(jsonResponseStr);
			
			if(result.get("STATUSCODE") != null && (Integer)result.get("STATUSCODE") >= 500) {
				try {
					jsonResponseStr = returnList.optString("exception");
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				throw new Exception(jsonResponseStr);
			}
		}
        
        int returnId = 0;
        /*
         * 기안후 Process ID를 정상적으로 받아올 경우 체크
         * 0일때는 ApvProcessSvcImpl.java에서 Exception 처리
         * 
         */
        if(returnList != null && returnList.containsKey("id")){
        	returnId = returnList.getInt("id");
        }
        
		return returnId;
	}
	
	//Activiti Process Update
	private int updateProcess(){
		
		return 0;
	}
	
	//Activiti Task complete
	private int complete(CoviMap request, CoviList params) throws Exception{
		String taskId = request.getString("taskId");
		HttpsUtil httpsUtil = new HttpsUtil();
		CoviMap obj = new CoviMap();
		
		obj.put("action", request.get("action"));
		obj.put("variables", params);
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String taskDupKey = "[APV_TASK]"+taskId;
		try {
			try{
				String taskIdInRedis = instance.get(taskDupKey); 
				
				if(StringUtils.isNoneBlank(taskIdInRedis)){
					throw new DuplicateKeyException("NOTASK");
				}else{
					instance.setex(taskDupKey, 60, request.optString("action"));
				}
			}catch(DuplicateKeyException e){
			    throw new DuplicateKeyException("NOTASK");
			}catch(Exception ex){
				throw ex;
			}
			
			// [20-03-30] Process & Workitem 상태 체크 start ---------------------------------------------------------
			CoviMap paramsObj = new CoviMap();
			paramsObj.put("TaskID", taskId);
			
			String sPIState = coviMapperOne.selectOne("form.process.selectProcessState", paramsObj);
			if (sPIState == null || !sPIState.equals("288"))
			{
				throw new Exception(DicHelper.getDic("msg_apv_084"));
			}
			String sWIState = coviMapperOne.selectOne("form.process.selectWorkitemState", paramsObj);
			if (sWIState == null || !sWIState.equals("288"))
			{
				throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
			}
			
			try {
				CoviList taskValues = getActivitiVariables(taskId);
				if(taskValues.isEmpty()) {
					throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
				}	
			} catch (FileNotFoundException e) { // 활성화 된 task가 없는 경우
				throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
			}
			// Process & Workitem 상태 체크 end ----------------------------------------------------------------------
			
			
			String activitiURL = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");//http://192.168.11.126:8081
			String httpCommURL = activitiURL+"/service/runtime/tasks/" + taskId;
			
			String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
			String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");
			
			try{
				java.util.Map<String, Object> result = httpsUtil.httpsClientConnectResponse(httpCommURL, "POST", obj, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
				if(result != null && result.get("STATUSCODE") != null && (Integer)result.get("STATUSCODE") >= 500) {
					String jsonResponseStr = (String)result.get("MESSAGE");
					try {
						CoviMap jo = CoviMap.fromObject(jsonResponseStr);
						jsonResponseStr = jo.optString("exception");
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
					throw new Exception(jsonResponseStr);
				}
			} catch(FileNotFoundException e) {
				throw new FileNotFoundException("NOTASK");
			} catch(Exception ex){
				throw ex;
			}
		} finally {
			try {
				instance.remove(taskDupKey);
			}catch(NullPointerException npE) {  LOGGER.debug(npE); 
			}catch(Exception e) {  LOGGER.debug(e); }
		}
        
		return 0;
	}

	private int deleteProcess(String processID) throws Exception{
		String activitiURL = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");//http://192.168.11.126:8081
		String httpCommURL = activitiURL+"/service/runtime/process-instances/" + processID;
		HttpsUtil httpsUtil = new HttpsUtil();
		
		CoviMap obj = new CoviMap();
		obj.put("processID", processID);
		
        String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
        String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");
        
        String strResult = httpsUtil.httpsClientWithRequest(httpCommURL, "DELETE", obj, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
        
		return 0;
	}
	
	@SuppressWarnings("unused")
	private void updateVariable(String taskID, String variableName, CoviMap params) throws Exception{
		String activitiURL = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");//http://192.168.11.126:8081
		String httpCommURL = activitiURL+"/service/runtime/tasks/"+taskID+"/variables/"+variableName;
		HttpsUtil httpsUtil = new HttpsUtil();
        
        //make connection
        
        String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
        String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");
        
        httpsUtil.httpsClientWithRequest(httpCommURL, "PUT", params, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
        
	}
	
	//Activiti Variables
	public CoviList getActivitiVariables(String taskId) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
		url += "/service/runtime/tasks/" + taskId + "/variables";
		
		CoviList returnObj =  (CoviList)RequestHelper.sendGET(url).get("result");
		returnObj = convertNullJSON(returnObj);
		
		return returnObj;
	}
	public String getActivitiVariables(String taskId, String variableName) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		String returnValue = "";
		
		try{
			if(variableName != null && !variableName.isEmpty()) {
				String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
				url += "/service/runtime/tasks/" + taskId + "/variables/" + variableName;
				returnObj = (CoviMap)RequestHelper.sendGET(url).get("result");
				returnValue = returnObj.optString("value");
			}
		}catch(NullPointerException npE){
			returnValue = "";
		}catch(Exception ex){
			returnValue = "";
		}
		
		return returnValue;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// 모니터링에서 activiti를 호출했을 경우, 반환값에서 NULL 값을 문자열 "NULL"값으로 변경
	public CoviList convertNullJSON(CoviList paramArr){
		for(Object obj :  paramArr){
			CoviMap paramObj = (CoviMap)obj;
			Iterator<?> keys = paramObj.keys();
	
			while (keys.hasNext()) {
				String key = (String) keys.next();
				if(paramObj.get(key) == null){
					paramObj.put(key, "NULL");
				}
			}
		}
		return paramArr;
	}
	
}
