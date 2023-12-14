package egovframework.covision.coviflow.legacy.service.impl;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.legacy.service.DistributionSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.idgnr.impl.Base64;

import net.sf.json.JSONException;


@Service("distributionService")
public class DistributionSvcImpl extends EgovAbstractServiceImpl implements DistributionSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public String startDistribution(String parameters) throws Exception{
		
		CoviMap distributionInfo = new CoviMap();
		CoviList receipts = new CoviList();
		CoviMap context = new CoviMap();
		String piid = "";
		String type = "";
		String docNumber = "";
		String fiid = "";
		String subject = "";
		String rowSeq = "";
		String returnval = "FAIL";		
		
		try {
			distributionInfo = CoviMap.fromObject(parameters);
	    } catch (JSONException ex) {
	        try {
	        	distributionInfo = CoviList.fromObject(parameters).getJSONObject(0);
	        } catch (JSONException ex2) {
	            throw ex2;
	        }
	    }
		
		receipts = (CoviList)distributionInfo.get("receiptList");
		context = CoviMap.fromObject(distributionInfo.get("context"));
		piid = (String)distributionInfo.get("piid");
		type = (String)distributionInfo.get("type");
		docNumber = (String)distributionInfo.get("docNumber");
		
		if(distributionInfo.containsKey("fiid")) {
			fiid = (String)distributionInfo.get("fiid");
			if(!fiid.equals("")) {
				context.put("FormInstID", fiid);
			}
		}
		if(distributionInfo.containsKey("subject")) {
			subject = (String)distributionInfo.get("subject");
		}
		if(distributionInfo.containsKey("rowSeq")) {
			rowSeq = (String)distributionInfo.get("rowSeq");
		}
		
		//receiptList로 부터 결재선을 조작하는 코드를 추가 할 것
		for(int j = 0; j < receipts.size(); j++)
		{
			CoviMap receipt = (CoviMap)receipts.get(j);
			CoviMap modifiedApvLineObj = new CoviMap();
			modifiedApvLineObj = CoviMap.fromObject(distributionInfo.optString("approvalLine"));		//(CoviMap)parser.parse(distributionInfo.optString("approvalLine"));
			modifiedApvLineObj = addReceiptDivision(modifiedApvLineObj, receipt, type);
			
			CoviList params = new CoviList();
			
			CoviMap contextParam = new CoviMap();
			contextParam.put("name", "g_context");
			contextParam.put("value", context.toString());
			params.add(contextParam);
			
			CoviMap appvLineParam = new CoviMap();
			appvLineParam.put("name", "g_appvLine");
			appvLineParam.put("value", modifiedApvLineObj.toString());
			params.add(appvLineParam);
			
			CoviMap piidParam = new CoviMap();
			piidParam.put("name", "g_piid");
			piidParam.put("value", piid);
			params.add(piidParam);
			
			CoviMap isDistributionParam = new CoviMap();
			isDistributionParam.put("name", "g_isDistribution");
			isDistributionParam.put("value", "true");
			params.add(isDistributionParam);
			
			CoviMap docNumberParam = new CoviMap();
			docNumberParam.put("name", "g_docNumber");
			docNumberParam.put("value", docNumber);
			params.add(docNumberParam);
			
			if(!fiid.equals("")) {
				CoviMap fiidParam = new CoviMap();
				fiidParam.put("name", "g_subFiid");
				fiidParam.put("value", fiid);
				params.add(fiidParam);
			}

			if(!subject.equals("")) {
				CoviMap subjectParam = new CoviMap();
				subjectParam.put("name", "g_subSubject");
				subjectParam.put("value", subject);
				params.add(subjectParam);
			}
			
			if(!rowSeq.equals("")) {
				CoviMap rowSeqParam = new CoviMap();
				rowSeqParam.put("name", "g_subRowSeq");
				rowSeqParam.put("value", rowSeq);
				params.add(rowSeqParam);
			}
			
			CoviMap postObj = new CoviMap();
			
			postObj.put("processDefinitionKey", "basic1");
			postObj.put("variables", params);
			
			//프로세스 시작 호출
			String url = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
			url += "/service/runtime/process-instances";
			
			//RequestHelper.sendPOST(url, postObj);
			HttpsUtil httpsUtil = new HttpsUtil();
			String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
	        String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");
	        
			String strResult = httpsUtil.httpsClientWithRequest(url, "POST", postObj, "UTF-8", "Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8)));
			 
	        CoviMap returnList = new CoviMap();
	        returnList = CoviMap.fromObject(strResult);
	               
	        if(returnList.containsKey("id")){
				CoviMap paramsObj = new CoviMap();
				paramsObj.put("ProcessID", returnList.get("id"));
				paramsObj.put("FormInstID", context.get("FormInstID"));

				//문서유통 접수문서중 ProcessID가 null인경우 update
				if (context.get("mode").equals("GOVACCEPT")) {
					int cnt = (int) coviMapperOne.selectOne("form.forminstance.selectProcessIdNullChkCnt", paramsObj);
					if (cnt > 0) { 
						coviMapperOne.update("form.forminstance.updateProcessID", paramsObj); 
					}
				}
				returnval = "SUCCESS";
	        }
			
			//지연시간
			Thread.sleep(1000);
		}
		return returnval;
	}
	
	@Override
	public void deleteDistribution(String parameters) throws Exception{
		CoviMap distributionInfo = new CoviMap();
		CoviList items = new CoviList();
		String piid;
		String wiid;
		
		try {
			distributionInfo = CoviMap.fromObject(parameters);
	    } catch (JSONException ex) {
	        try {
	        	distributionInfo = CoviList.fromObject(parameters).getJSONObject(0);
	        } catch (JSONException ex2) {
	            throw ex2;
	        }
	    }
		
		items = (CoviList)distributionInfo.get("item");
		for(int j = 0; j < items.size(); j++)
		{
			CoviMap item = (CoviMap)items.get(j);
			piid = item.optString("piid");
			wiid = item.optString("wiid");

			CoviMap paramsMapForProcess = new CoviMap();
			paramsMapForProcess.put("ProcessID", piid);
			paramsMapForProcess.put("State", "546");
			coviMapperOne.update("form.process.updateState", paramsMapForProcess);			
			
			CoviMap paramsMapforWorkitem = new CoviMap();
			paramsMapforWorkitem.put("WorkitemID", wiid);
			paramsMapforWorkitem.put("State", "546");
			coviMapperOne.update("form.workitem.updateState", paramsMapforWorkitem);
		}
	}
	
	@Override
	public CoviList selectReceiptPersonInfo(CoviMap params) throws Exception{
		CoviList resultList = new CoviList();
		
		CoviList list = coviMapperOne.list("legacy.common.selectReceiptPersonInfo", params);
		if(list.isEmpty() && params.containsKey("oucode")) {
			params.remove("oucode");
			list = coviMapperOne.list("legacy.common.selectReceiptPersonInfo", params);
		}
		resultList = convertToJSON(list);
		
		return resultList;
	}
	
	private CoviMap addReceiptDivision(CoviMap apvLineObj, CoviMap receipt, String type) throws Exception {
		
		CoviMap ret = new CoviMap();
		
		try{
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			
			String code = receipt.optString("code");
			String name = receipt.optString("name");

			CoviMap root = (CoviMap)apvLineObj.get("steps");
			Object divisionObj = root.get("division");
			CoviList divisions = new CoviList();
			
			if(divisionObj instanceof CoviMap){
				divisions.add(divisionObj);
			} else {
				divisions = (CoviList)divisionObj;
				
				for(int i = 0; i < divisions.size(); i++)
				{
					CoviMap d = (CoviMap)divisions.get(i);
					String divisionType = (String)d.get("divisiontype");
				    
					if(divisionType.equalsIgnoreCase("receive")){
						divisions.remove(i);
					}			      
				}
			}
			
			CoviMap taskinfo = new CoviMap();
			taskinfo.put("status", "pending");
			taskinfo.put("result", "pending");
			taskinfo.put("kind", "normal");
			taskinfo.put("datereceived", sdf.format(new Date()));
			
			CoviMap ou = new CoviMap();
			
			CoviMap step = new CoviMap();
			
			CoviMap addingDivision = new CoviMap();
			addingDivision.put("divisiontype", "receive");

			if(type.equalsIgnoreCase("0")){
				//부서
				ou.put("code", code);
				ou.put("name", name);
				ou.put("taskinfo", taskinfo);
				
				step.put("unittype", "ou");
				step.put("routetype", "receive");
				step.put("ou", ou);
				step.put("name", "수신");
				
				addingDivision.put("name", "수신");
				addingDivision.put("oucode", code);
				addingDivision.put("ouname", name);
				addingDivision.put("step", step);
				
			} else{ 
				//사람
				//get user 정보
				CoviMap params = new CoviMap();
				params.put("urCode", code);
				CoviList personInfos = new CoviList();
				CoviMap personInfo = new CoviMap();
				
				if(receipt.has("oucode")) {
					params.put("oucode", receipt.optString("oucode"));
				}
				
				personInfos = selectReceiptPersonInfo(params);
				personInfo = (CoviMap)personInfos.get(0);
				
				String oucode = personInfo.optString("DeptID");
				String ouname = personInfo.optString("DeptName");
				String level = (personInfo.has("JobLevel") && personInfo.get("JobLevel") != null) ? personInfo.optString("JobLevel") : "";
				String position = (personInfo.has("JobTitle") && personInfo.get("JobTitle") != null) ? personInfo.optString("JobTitle") : "";
				String title = (personInfo.has("JobPosition") && personInfo.get("JobPosition") != null) ? personInfo.optString("JobPosition") : "";
				
				taskinfo.put("kind", "charge");
				
				CoviMap person = new CoviMap();
				person.put("code", code);
				person.put("name", name);
				person.put("oucode", oucode);
				person.put("ouname", ouname);
				person.put("taskinfo", taskinfo);
				
				person.put("level", level);
				person.put("position", position);
				person.put("title", title);
				
				ou.put("code", oucode);
				ou.put("name", ouname);
				ou.put("taskinfo", taskinfo);
				ou.put("person", person);
				
				step.put("unittype", "person");
				step.put("routetype", "approve");
				step.put("ou", ou);
				step.put("name", "담당결재");
				
				addingDivision.put("name", "담당결재");
				addingDivision.put("oucode", oucode);
				addingDivision.put("ouname", ouname);
				addingDivision.put("step", step);
			}
			
			CoviMap divisionTaskinfo = new CoviMap();
			divisionTaskinfo.put("status", "pending");
			divisionTaskinfo.put("result", "pending");
			divisionTaskinfo.put("kind", "receive");
			divisionTaskinfo.put("datereceived", sdf.format(new Date()));
			
			addingDivision.put("taskinfo", divisionTaskinfo);
			
			divisions.add(addingDivision);
			
			root.put("division", divisions);
			apvLineObj.put("steps", root);
			
			ret = apvLineObj;
			
		} catch(NullPointerException npE){
			throw npE;
		} catch(Exception e){
			throw e;
		}
		
		return ret;
	}
	
	private CoviList convertToJSON(CoviList clist) {
		CoviList returnArray = new CoviList();
		
		if(null != clist && !clist.isEmpty()){
				for(int i=0; i<clist.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while(iter.hasNext()){   
						String ar = iter.next();
						newObject.put(ar, clist.getMap(i).getString(ar));
					}
					
					returnArray.add(newObject);
				}
			}
		
		return returnArray;
	}
	
}
