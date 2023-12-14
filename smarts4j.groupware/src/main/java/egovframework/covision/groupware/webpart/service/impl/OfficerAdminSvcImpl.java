package egovframework.covision.groupware.webpart.service.impl;

import javax.annotation.Resource;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.webpart.service.OfficerAdminSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("OfficerAdminService")
public class OfficerAdminSvcImpl extends EgovAbstractServiceImpl implements OfficerAdminSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getIsAdminUser(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.officer.selectAuthority", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "IsManager"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getOfficerList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();		
		CoviList list = null;
		
		list = coviMapperOne.list("webpart.officer.selectOfficerList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,Secretarys,IsUse,Sort,State,StateName,DeptName,JobLevelName,JobTitleName,JobPositionName"));
		return resultList;
	}
	
	@Override
	public CoviMap getOfficerListAdmin(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		if(params.containsKey("pageNo")) {
			cnt = (int) coviMapperOne.getNumber("webpart.officer.selectOfficerListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}
		list = coviMapperOne.list("webpart.officer.selectOfficerListAdmin", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,Secretarys,IsUse,RegistDate,Sort,State,StateName,DeptName,JobLevelName,JobTitleName,JobPositionName"));
		return resultList;
	}
	
	@Override
	public CoviMap getOfficerTargetList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.officer.selectOfficerTargetList", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "UserCode,DisplayName,Secretarys,IsUse,RegistDate,Sort,State,StateName,DeptName,JobLevelName,JobTitleName,JobPositionName"));
		
		return returnObj;
	}
	
	@Override
	public int updateOfficerState(CoviMap params) throws Exception {
		return coviMapperOne.update("webpart.officer.updateOfficerState", params);
	}
	
	@Override
	public int updateOfficerUse(CoviMap params) throws Exception {
		return coviMapperOne.update("webpart.officer.updateOfficerUse", params);
	}
	
	@Override
	public int deleteOfficer(CoviMap params) throws Exception {
		return coviMapperOne.delete("webpart.officer.deleteOfficer", params);
	}	
	
	@Override
	public CoviMap moveofficersort(CoviMap params) throws Exception {

		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		String strSortKey_A = null;
		String strSortKey_B = null;
		
		// update Sort
		params.put("TargetCode", params.get("Code_A"));
		strSortKey_A = coviMapperOne.select("webpart.officer.selectOfficerSort", params).get("Sort").toString();
		
		params.put("TargetCode", params.get("Code_B"));
		strSortKey_B = coviMapperOne.select("webpart.officer.selectOfficerSort", params).get("Sort").toString();

		
		params.put("TargetCode", params.get("Code_A"));
		params.put("TargetSortKey", strSortKey_B);
		returnCnt += coviMapperOne.update("webpart.officer.updateOfficerSort", params);
		
		params.put("TargetCode", params.get("Code_B"));
		params.put("TargetSortKey", strSortKey_A);
		returnCnt += coviMapperOne.update("webpart.officer.updateOfficerSort", params);
		
		if (returnCnt > 0)
			resultObj.put("result", "OK");
		else
			resultObj.put("result", "FAIL");

		return resultObj;
	}
	
	@Override
	public CoviMap getIsDuplicate(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		resultList = coviMapperOne.list("webpart.officer.selectDuplicate", params);
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "IsDuplicate"));
		
		return returnObj;
	}
	
	@Override
	public int addOfficer(CoviMap params) throws Exception {
		return coviMapperOne.insert("webpart.officer.addOfficer", params);
	}	
	
	@Override
	public int updateOfficerInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("webpart.officer.updateOfficerInfo", params);
	}	
	
	@Override
	public CoviMap getOfficerInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();		
		CoviList list = null;
		
		list = coviMapperOne.list("webpart.officer.selectOfficerTargetInfo", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,Secretarys,SecretarysName,IsUse,Sort"));
		return resultList;
	}
}