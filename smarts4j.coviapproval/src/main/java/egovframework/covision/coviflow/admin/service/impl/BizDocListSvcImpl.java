package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.BizDocListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("bizDocListService")
public class BizDocListSvcImpl extends EgovAbstractServiceImpl implements BizDocListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectBizDocList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.bizDocMember.selectBizDocgridcnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);		
		list = coviMapperOne.list("admin.bizDocMember.selectBizDocgrid", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "EntCode,EntName,BizDocCode,BizDocID,BizDocName,BizDocTypeName,Description,SortKey,InsertDate,IsUse,UR_Name,FormName"));
		resultList.put("page",pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectBizDocData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.bizDocMember.selectBizDocData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "EntCode,BizDocCode,BizDocID,BizDocName,BizDocType,Description,SortKey,InsertDate,IsUse,UR_Name,FormName"));	
		
		return resultList;
	}

	@Override
	public int insertBizDoc(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("admin.bizDocMember.duplicateBizdocCode", params);
		if (cnt == 0)
			cnt = coviMapperOne.insert("admin.bizDocMember.insertBizDoc", params);		
		else
			cnt = 0;
		return cnt;
	}
	
	@Override
	public int updateBizDoc(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.bizDocMember.updateBizDoc", params);
	}
	@Override
	public int deleteBizDoc(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("admin.bizDocMember.deleteBizDoc", params);
		cnt += coviMapperOne.delete("admin.bizDocMember.deleteBizDocAfterForm", params);
		cnt += coviMapperOne.delete("admin.bizDocMember.deleteBizDocAfterMember", params);
				
		return cnt;
	}
	
	@Override
	public CoviMap selectBizDocFormList(CoviMap params) throws Exception {			
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = new CoviMap();

		if(params.containsKey("pageNo")) {
			int listCnt = (int) coviMapperOne.getNumber("admin.bizDocMember.selectBizDocFormListCnt", params);
			pagingData = ComUtils.setPagingData(params, listCnt);
			params.addAll(pagingData);
			
			resultList.put("page", pagingData);
		}
		
		CoviList list = coviMapperOne.list("admin.bizDocMember.selectBizDocFormList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BizDocFormID,BizDocID,SortKey,FormPrefix,FormName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectBizDocSelOrginFormList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		
		if (params.get("pageNo")!= null || params.get("pageSize") != null){
			int listCnt = (int) coviMapperOne.getNumber("admin.bizDocMember.selectBizDocSelOrginFormgridCnt", params);
			pagingData = ComUtils.setPagingData(params, listCnt);
			params.addAll(pagingData);	
		}
		CoviList list = coviMapperOne.list("admin.bizDocMember.selectBizDocSelOrginFormgrid", params);
		
		resultList.put("list", list);
		resultList.put("page", pagingData);
		return resultList;
	}
	
	@Override
	public int insertBizDocForm(CoviMap params) throws Exception {
		// #1. 기존 양식 항목 삭제. 
		// coviMapperOne.delete("admin.bizDocMember.deleteBizDocAfterForm", params); 
		
		// #2. 선택된 항목 추가.
		int cnt = 0;
		
		CoviList bizDocFormList = (CoviList) params.get("BizDocFormList");
		if(bizDocFormList != null) {
			for(int i = 0; i < bizDocFormList.size(); i++) {
				CoviMap param = new CoviMap();
				CoviMap bizDocForm = bizDocFormList.getJSONObject(i);
				param.put("BizDocID", params.getString("BizDocID"));
				param.put("SortKey", "0");
				param.put("FormPrefix", bizDocForm.getString("FormPrefix"));
				param.put("FormName", bizDocForm.getString("FormName"));
				param.put("FormID", bizDocForm.getString("FormID"));
			
				cnt += coviMapperOne.insert("admin.bizDocMember.insertBizDocForm", param);
			}
		}
		
		return cnt;	
	}
	
	@Override
	public CoviMap selectBizDocFormData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.bizDocMember.selectBizDocFormData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "BizDocFormID,BizDocID,SortKey,FormPrefix,FormName"));	
		
		return resultList;
	}
	
	@Override
	public CoviList selectBizDocFormAllList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.bizDocMember.selectBizDocFormAllList", params);		
		return CoviSelectSet.coviSelectJSON(list, "bizDocFormID,bizDocID,sotrKey,formPrefix,formName,formID");
	}
	
	
	@Override
	public int updateBizDocForm(CoviMap params) throws Exception {
		return  coviMapperOne.update("admin.bizDocMember.updateBizDocForm", params);
	}
	@Override
	public int deleteBizDocForm(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.bizDocMember.deleteBizDocForm", params);
	}
	
	@Override
	public CoviMap selectBizDocMemberList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;		
		int listCnt = (int) coviMapperOne.getNumber("admin.bizDocMember.selectBizDocMembergridcnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);		
		list = coviMapperOne.list("admin.bizDocMember.selectBizDocMembergrid", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BizDocID,BizDocMemberID,UR_Name,UR_Code,DEPT_ID,DEPT_NAME,SortKey"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public int insertBizDocMember(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.bizDocMember.insertBizDocMember", params);
	}
	
	@Override
	public int updateBizDocMember(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.bizDocMember.updateBizDocMember", params);
	}
	
	@Override
	public int deleteBizDocMember(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.bizDocMember.deleteBizDocMember", params);
	}	
	
	@Override
	public CoviMap selectBizDocMemberData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.bizDocMember.selectBizDocMemberData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "BizDocID,BizDocMemberID,UR_Name,UR_Code,DEPT_ID,DEPT_NAME,SortKey"));	
		
		return resultList;
	}	
}
