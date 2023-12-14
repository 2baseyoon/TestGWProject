package egovframework.covision.coviflow.form.service.impl;

import java.util.Objects;

import javax.annotation.Resource;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.form.service.EngineSvc;
import egovframework.covision.coviflow.form.service.InstMgrSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("InstMgrSvc")
public class InstMgrSvcImpl extends EgovAbstractServiceImpl implements InstMgrSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private EngineSvc engineSvc;
	
	@Override
	public void doAbort(CoviMap formObj) throws Exception {
		//데이터 초기화
		CoviMap apvLine = CoviMap.fromObject(formObj.get("apvLine"));
		CoviMap formData = CoviMap.fromObject(formObj.optString("formData"));

		CoviMap params = new CoviMap();
		
		//forminstanceid 생성
		int newFormInstID = (int) coviMapperOne.getNumber("form.forminstance.getIdentity", params); 
		
		//결재선 초기화
		//Covi_flow_form_def.[dbo].[usp_wf_abort_tempsave] 참조해서
		//새로운 form instance 생성(processid null) 및 임시저장함 데이터 추가
		//결재선 privatedomaindata에 추가
		//workitem, performer, process 관련 데이터 삭제
		//Process 삭제 api 호출
		
		//forminstance에 데이터 추가
		params.clear();
		params.put("FormInstID",Objects.toString(formObj.get("fiid"),""));
		params.put("newFormInstID",newFormInstID);
		
		coviMapperOne.insert("form.forminstance.insertForTempSave", params);
		
		//tempsave에 데이터 추가
		params.clear();
		params.put("FormInstID",Objects.toString(formObj.get("fiid"),""));
		params.put("newFormInstID",newFormInstID);
		
		coviMapperOne.insert("form.formstempinstbox.insertFromForminstanceW", params);
		
		
		//결재선 private domaindata에 추가
		params.clear();
		params.put("CustomCategory", "APPROVALCONTEXT");
		params.put("DefaultYN", null);
		params.put("DisplayName", SessionHelper.getSession("USERID") + "-" + formData.getString("SUBJECT"));
		params.put("OwnerID", newFormInstID);
		params.put("Abstract", "");
		params.put("Description", SessionHelper.getSession("USERID") + "-" + formData.getString("SUBJECT"));
		params.put("PrivateContext", apvLine.toString());
		
		coviMapperOne.insert("form.privatedomaindata.insert", params);
		
		//workitem, performer, process 관련 데이터 삭제
		params.clear();
		params.put("ProcessID", formObj.get("piid"));
		coviMapperOne.delete("form.workitem.delete",params);
		coviMapperOne.delete("form.performer.delete",params);
		coviMapperOne.delete("form.process.delete",params);
		
		engineSvc.requestAbort(formObj);
	}

	@Override
	public void doCancel(CoviMap formObj) throws Exception {
		String taskId = formObj.getString("taskId");
		
		CoviList params = new CoviList();
		
		CoviMap obj1 = new CoviMap();
		obj1.put("name", "g_action");
		obj1.put("value", formObj.get("actindx"));
		obj1.put("scope", "global");
		obj1.put("type", "string");
		params.add(obj1);
		
		obj1.put("name", "g_actionCmt");
		obj1.put("value", formObj.get("actcmt"));
		obj1.put("scope", "global");
		obj1.put("type", "string");
		params.add(obj1);
		
		engineSvc.requestComplete(taskId, params);
	}

	@Override
	public void doFoward(CoviMap formObj) throws Exception {
		engineSvc.requestUpdate();
	}

	@Override
	public void doDelConsent(CoviMap formObj) throws Exception {
		engineSvc.requestUpdate();
	}

	@Override
	public void doForcedConsent(CoviMap formObj) throws Exception {
		engineSvc.requestUpdate();
	}
}
