package egovframework.covision.groupware.collab.user.service.impl;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.util.SessionHelper;

import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;


import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabTmplSvc;

@Service("CollabTmplSvc")
public class CollabTmplSvcImpl extends EgovAbstractServiceImpl implements CollabTmplSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	/**
	 * @Method Name : getTmplRequestList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getTmplRequestList(CoviMap params) {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= (int) coviMapperOne.getNumber("collab.tmpl.getTmplRequestListCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		list = coviMapperOne.list("collab.tmpl.getTmplRequestList", params);
		
		resultList.put("page", page);
		resultList.put("list", list);
		
		return resultList; 
	}
	
	//승인관련
	public CoviMap approvalTmplRequest (CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap	= new CoviMap();
		int resultCnt = 0;
		for(int j=0; j<objList.size(); j++){
			Map params = (Map)objList.get(j);
			
			//params.put("orgPrjSeq", arg1)
			reqMap.put("requestSeq", params.get("requestSeq"));
			reqMap.put("prjSeq", params.get("prjSeq"));
			reqMap.put("tmplName", params.get("tmplName"));
			int cnt = 0;
			cnt = coviMapperOne.insert("collab.tmpl.addTmplProject", reqMap);
			reqMap.put("tmplSeq", reqMap.get("TmplSeq"));
			cnt = coviMapperOne.insert("collab.tmpl.addTmplProjectUserform", reqMap);
			cnt = coviMapperOne.insert("collab.tmpl.addTmplProjectSection", reqMap);
			cnt = coviMapperOne.insert("collab.tmpl.addTmplProjectTask", reqMap);

			reqMap.put("reqStatus", "Approval");
			resultCnt += coviMapperOne.update("collab.tmpl.saveTmplRequest", reqMap);
		}
		//resultMap
		resultMap.put("resultCnt", resultCnt);
		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
//		resultMap.put("cnt", value)
		return resultMap;
	}
	
	//거절관련
	public CoviMap rejectTmplRequest (CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap	= new CoviMap();
		int resultCnt = 0;
		for(int j=0; j<objList.size(); j++){
			Map params = (Map)objList.get(j);
			reqMap.put("requestSeq", params.get("requestSeq"));
			reqMap.put("reqStatus", "Reject");
			resultCnt += coviMapperOne.update("collab.tmpl.saveTmplRequest", reqMap);
		}
		//resultMap
		resultMap.put("resultCnt", resultCnt);
		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
//			resultMap.put("cnt", value)
		return resultMap;
	}
	
	//삭제관련
	public CoviMap deleteTmplRequest (CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap	= new CoviMap();
		int resultCnt = 0;
		for(int j=0; j<objList.size(); j++){
			Map params = (Map)objList.get(j);
			reqMap.put("tmplSeq", params.get("tmplSeq"));
			resultCnt += coviMapperOne.update("collab.tmpl.deleteTmplProject", reqMap);
//			coviMapperOne.update("collab.tmpl.deleteTmplProjectUserForm", reqMap);
			coviMapperOne.update("collab.tmpl.deleteTmplSection", reqMap);
			coviMapperOne.update("collab.tmpl.deleteTmplTask", reqMap);
		}
		//resultMap
		resultMap.put("resultCnt", resultCnt);
		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
//				resultMap.put("cnt", value)
		return resultMap;
	}
		
	/**
	 * @Method Name : getTmplList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getTmplList(CoviMap params) {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		list = coviMapperOne.list("collab.tmpl.getTmplList", params);
		resultList.put("list", list);
//		resultList.put("page", page);
		
		return resultList; 
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보
	 * @throws Exception
	 */
	@Override
	public CoviMap getTmplMain(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList returnMap = new CoviList();
		resultList.put("sectionList", coviMapperOne.selectList("collab.tmpl.getTmplSection", params));
		List sectionList = (List)resultList.get("sectionList");
		for (int i = 0; i < sectionList.size(); ++i) {
			params.put("sectionSeq", ((CoviMap)sectionList.get(i)).get("SectionSeq"));
	        int cnt = (int) coviMapperOne.getNumber("collab.tmpl.getTmplTaskListCnt", params);
	        
	        CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			CoviMap dataMap = new CoviMap();
			dataMap.put("key", sectionList.get(i));
			dataMap.put("list", coviMapperOne.list("collab.tmpl.getTmplTaskList", params));
			dataMap.put("page", page);
			returnMap.add(dataMap);
        }
		resultList.put("taskData", returnMap);
		return resultList;
	}
	
	//순서변경
	public int changeTmplTaskOrder  (CoviMap params, List ordTask) throws Exception {
		params.put("taskList", ordTask);
		coviMapperOne.insert("collab.tmpl.changeTmplTaskSection", params);
		return  coviMapperOne.insert("collab.tmpl.changeTmplTaskOrder", params);
	}	

	//삭제
	public int deleteTmpl  (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.delete("collab.tmpl.deleteTmplTask", params);
		cnt = coviMapperOne.delete("collab.tmpl.deleteTmpl", params);
		return cnt;
	}
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 섹션추가
	 * @throws Exception
	 */
	@Override
	public CoviMap addTmplSection(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		long iCnt = coviMapperOne.getNumber("collab.tmpl.getExistsTmplSection", params);
		
		if (iCnt >0){
			resultList.put("status", Return.FAIL);
			resultList.put("code", "DUP");
			resultList.put("message", "DUP");
		}	
		else{
			iCnt = coviMapperOne.insert("collab.tmpl.addTmplSection", params);
			resultList.put("SectionSeq", params.get("SectionSeq"));
			resultList.put("SectionName", params.get("sectionName"));
			resultList.put("status", Return.SUCCESS);
		}	
		return resultList;
	}
	
	@Override
	public CoviMap saveTmplSection(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int iCnt = coviMapperOne.insert("collab.tmpl.saveTmplSection", params);
		resultList.put("SectionSeq", params.get("sectionSeq"));
		resultList.put("SectionName", params.get("sectionName"));
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 섹션삭제
	 * @throws Exception
	 */
	@Override
	public int deleteTmplSection(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("collab.tmpl.deleteTmplSection", params);
		return cnt;
	}
		
	
	//타스트 추가
	@Override
	public int addTmplTask(CoviMap params) throws Exception {
		return  coviMapperOne.insert("collab.tmpl.addTmplTask", params);
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 수정
	 * @throws Exception
	 */
	@Override
	public int saveTmplTask(CoviMap params) throws Exception {
		int cnt = coviMapperOne.insert("collab.tmpl.saveTmplTask", params);
		return cnt;
	}
	//삭제

	public  int deleteTmplTask(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.delete("collab.tmpl.deleteTmplTask", params);
		return cnt;
	}
	
	//복사
	public int copyTmplTask  (CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.insert("collab.tmpl.copyTmplTask", params);
		params.put("taskSeq", params.getInt("TaskSeq"));
		
		return cnt;
	}
	
	@Override
	public CoviMap getTmplTask(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap taskData = coviMapperOne.selectOne("collab.tmpl.getTmplTask", params);
		int taskSeq = params.getInt("taskSeq");
		CoviMap param = new CoviMap();
		param.put("ObjectID", taskSeq);
		//param.put("ObjectType", "None");
		param.put("MessageID", 0);

		resultList.put("taskData", taskData);
		return resultList;
	}
	
		
	
}
