package egovframework.covision.coviflow.legacy.service.impl;

import java.io.FileNotFoundException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import org.apache.commons.codec.binary.Base64;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.legacy.service.FormLegacySvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

@Service("formLegacyService")
public class FormLegacySvcImpl extends EgovAbstractServiceImpl implements FormLegacySvc{
	
	private final CoviMapperOne coviMapperOne;
	private final FileUtilService fileUtilSvc;
	@Autowired
	public FormLegacySvcImpl(CoviMapperOne coviMapperOne, FileUtilService fileUtilSvc) {
		this.coviMapperOne = coviMapperOne;
		this.fileUtilSvc = fileUtilSvc;
	}
	
	@Override //승인,반려처리
	public CoviMap doAction(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String piid =  params.get("piid").toString();
		String apvMode =  params.get("apvMode").toString();
		String empno = params.get("empno").toString();
		String deptcode = params.get("deptcode").toString();
		String comment = params.get("comment").toString();
		String mode = "";
		
		if(piid != null && !piid.equals("")) {
			
			params.put("piid", piid);
			CoviMap resultMap = coviMapperOne.select("form.forLegacy.getDomain", params);
			String taskId = "";
			ArrayList<String> routetypeArr = new ArrayList<String>();
			
			if(resultMap.get("DomainContext") != null && !resultMap.get("DomainContext").equals("")){
				CoviMap domainContext = CoviMap.fromObject(resultMap.get("DomainContext"));
				
				Object divisionObj = domainContext.getJSONObject("steps").get("division");
				CoviList divisonArr = new CoviList();
				if(divisionObj instanceof CoviMap){
					divisonArr.add(divisionObj);
				}else{
					divisonArr = (CoviList) divisionObj;
				}
				
				CoviList stepArr = new CoviList();
				for(Object obj : divisonArr){
					CoviMap division = CoviMap.fromObject(obj);
					
					if (division.get("step") instanceof CoviMap){
						stepArr.add(division.get("step"));
					}else{
						stepArr = division.getJSONArray("step");
					}
				}
				
				CoviList ouArr = new CoviList();
				for(Object stepObj : stepArr){
					CoviMap step = CoviMap.fromObject(stepObj);
					if (step.get("ou") instanceof CoviMap){
						ouArr.add(step.get("ou"));
						routetypeArr.add((String) step.get("routetype"));
					}else if(step.get("allottype").equals("parallel") && !(step.get("ou") instanceof CoviMap)) {
						CoviList parallelArr = (CoviList) step.get("ou");
						for(Object obj : parallelArr) {
							ouArr.add(obj);
							routetypeArr.add((String) step.get("routetype"));
						}
					}else{
						ouArr = step.getJSONArray("ou");
					}
				}
				int ouObjIdx = -1;
				boolean personChk = true;
				for(Object ouObj : ouArr){
					ouObjIdx++;
					CoviMap ou = CoviMap.fromObject(ouObj);
					CoviMap taskInfo;
					
					if(ou.containsKey("person")){
						CoviMap person = ou.getJSONObject("person");
						taskInfo = person.getJSONObject("taskinfo");
					}else{
						taskInfo = ou.getJSONObject("taskinfo");
					}
					
					if(taskInfo.getString("result").equals("pending") && taskInfo.getString("status").equals("pending")){
						if(ou.getJSONObject("person").getString("code").equals(empno) && ou.getJSONObject("person").getString("oucode").equals(deptcode)) {
							taskId = StringUtil.replaceNull(ou.get("taskid"),"");
							if(routetypeArr.get(ouObjIdx).equals("consult") || routetypeArr.get(ouObjIdx).equals("assist")) {
								if(apvMode.equals("APPROVAL")) {
									apvMode = "AGREE";	
								}else {
									apvMode = "DISAGREE";
								}
							}
							personChk = true;
							break;
						}else {
							personChk = false;
						}
					}
				}
				if(!personChk) throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."

				CoviList variables = new CoviList();
				if(!taskId.equals("")){
					CoviMap jsonParams = new CoviMap(); 
					jsonParams.put("g_actioncomment_" + taskId , new String(Base64.encodeBase64(comment.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
					jsonParams.put("g_actioncomment_attach_" + taskId , new CoviList());
					jsonParams.put("g_signimage_" + taskId , "");
					jsonParams.put("g_isMobile_" + taskId , "N");
					jsonParams.put("g_isBatch_" + taskId , "N");
					jsonParams.put("g_appvLine" , resultMap.get("DomainContext"));
					jsonParams.put("g_action_" + taskId, apvMode);
					
					for (Object key : jsonParams.keySet()) {
						String keyStr = (String) key;
						
						CoviMap variable = new CoviMap();
						variable.put("name", keyStr);
						variable.put("value", jsonParams.get(keyStr));
						variable.put("scope", "global");
						
						variables.add(variable);
					}
					
					try {
						CoviList taskValues = getActivitiVariables(taskId);
						if(taskValues.size() == 0) {
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", DicHelper.getDic("msg_apv_084"));
							throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
						}	
					} catch (FileNotFoundException e) { // 활성화 된 task가 없는 경우
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", DicHelper.getDic("msg_apv_084"));
						throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
					}
					
					String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.path");
					url += "/activiti-rest/service/runtime/tasks/" + taskId;
					
					CoviMap param = new CoviMap();
					param.put("action", "complete");
					param.put("variables", variables);
					
					RequestHelper.sendPOST(url, param);
					returnObj.put("status", "SUCCESS");
					returnObj.put("DomainContext", domainContext);
				}else{
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_apv_084"));
					throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
				}
			}else{
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_apv_084"));
				throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
			}
		} else {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", DicHelper.getDic("msg_apv_084"));
			throw new Exception(DicHelper.getDic("msg_apv_084"));//"결재문서가 이미 처리되었습니다."
		}
		return returnObj;
	}
	
	@Override
	public CoviList getActivitiVariables(String taskId) throws Exception {
		String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.path");
		url += "/activiti-rest/service/runtime/tasks/" + taskId + "/variables";
		
		CoviList returnObj =  (CoviList)RequestHelper.sendGET(url).get("result");
		returnObj = convertNullJSON(returnObj);
		
		return returnObj;
	}
	
	// 모니터링에서 activiti를 호출했을 경우, 반환값에서 NULL 값을 문자열 "NULL"값으로 변경
	@Override
	public CoviMap convertNullJSON(CoviMap paramObj) throws Exception{
		Iterator<?> keys = paramObj.keys();

		while (keys.hasNext()) {
			String key = (String) keys.next();
			if(paramObj.getString(key).equalsIgnoreCase("NULL")){
				paramObj.put(key, "NULL");
			}
		}
		
		return paramObj;
	}
	
	@Override
	public CoviList convertNullJSON(CoviList paramArr) throws Exception{
		for(Object obj :  paramArr){
			CoviMap paramObj = (CoviMap)obj;
			Iterator<?> keys = paramObj.keys();
	
			while (keys.hasNext()) {
				String key = (String) keys.next();
				if(paramObj.getString(key).equalsIgnoreCase("NULL")){
					paramObj.put(key, "NULL");
				}
			}
		}
		return paramArr;
	}


	@Override
	public void writeLog(CoviMap logMap) throws Exception {
		// TODO Auto-generated method stub
		
	}
	
		
}
