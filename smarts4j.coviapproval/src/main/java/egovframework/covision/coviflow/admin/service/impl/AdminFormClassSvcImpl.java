package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AdminFormClassSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("adminFormClassService")
public class AdminFormClassSvcImpl extends EgovAbstractServiceImpl implements AdminFormClassSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getFormClassList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.adminFormClass.selectFormClassListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.adminFormClass.selectFormClassList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormClassID,FormClassName,SortKey,EntCode,DisplayName,EntName"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap getFormClassData(CoviMap params) throws Exception {		
		CoviMap map = coviMapperOne.select("admin.adminFormClass.selectFormClassData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "FormClassID,FormClassName,SortKey,EntCode,DisplayName"));
		
		CoviList aclList = coviMapperOne.list("admin.adminFormClass.getFormClassAclSelect", params);		
		resultList.put("item", CoviSelectSet.coviSelectJSON(aclList));
		
		return resultList;
	}

	@Override
	public int insertFormClassData(CoviMap params) throws Exception {
		int cnt = coviMapperOne.insert("admin.adminFormClass.insertFormClassData", params);		
		if(params.optString("AclAllYN").equals("N")) {
			CoviMap map = new CoviMap();
			
			CoviMap obj = CoviMap.fromObject(params.getString("AuthDept"));
			CoviList result = (CoviList) obj.get("item");
			
			CoviList resultList = new CoviList();
			for(int i=0; i<result.size(); i++){
				CoviMap tmp = new CoviMap();
				CoviMap aclObj = CoviMap.fromObject(result.getJSONObject(i));
				
				tmp.put("ObjectType", "CLASS");
				tmp.put("TargetID", params.getString("FormClassID"));
				tmp.put("CompanyCode", aclObj.getString("CompanyCode"));
				tmp.put("GroupCode", aclObj.getString("GroupCode"));
				tmp.put("GroupType", aclObj.getString("GroupType"));
				tmp.put("RegisterCode", SessionHelper.getSession("USERID"));
				
				resultList.add(tmp);
			}
			
			map.put("FormClassID", params.getString("FormClassID"));
			map.put("list", resultList);
			map.put("size", result.size()-1);
			updateAclListClassData(map);
		}
		return cnt;
	}
	
	@Override
	public int updateFormClassData(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.adminFormClass.updateFormClassData", params);
	}
	@Override
	public int selectEachFormClassData(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.adminFormClass.selectEachFormClassData", params);
	}
	@Override
	public int deleteFormClassData(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("admin.adminFormClass.deleteFormClassData", params);
		cnt += coviMapperOne.delete("admin.adminFormClass.deleteAllClassAcl", params);
		return cnt;
	}
	
	@Override
	public void updateAclListClassData(CoviMap params) throws Exception{
		coviMapperOne.delete("admin.adminFormClass.deleteClassAcl", params);
		coviMapperOne.insert("admin.adminFormClass.insertClassAcl", params);
	}
	
	@Override
	public void deleteAclListClassData(CoviMap params) throws Exception{
		coviMapperOne.delete("admin.adminFormClass.deleteAllClassAcl", params);
	}
}
