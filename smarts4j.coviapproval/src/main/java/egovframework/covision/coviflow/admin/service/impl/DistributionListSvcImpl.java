package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.DistributionListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("distributionManagerService")
public class DistributionListSvcImpl extends EgovAbstractServiceImpl implements DistributionListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectDistributionList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		int listCnt = (int) coviMapperOne.getNumber("admin.distributionManager.selectDistributionListCnt", params);
		
		CoviMap pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		CoviList list = coviMapperOne.list("admin.distributionManager.selectDistributionList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,GroupID,GroupName,Description,SortKey,IsUse,InsertDate,EntCode"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public int insertDistributionList(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.distributionManager.insertDistributionList", params);
	}
	
	@Override
	public int updateDistribution(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.distributionManager.updateDistribution", params);
	}
	
	@Override
	public int deleteDistribution(CoviMap params) throws Exception {
		int cnt =coviMapperOne.delete("admin.distributionManager.deleteDistribution", params);
		cnt += coviMapperOne.delete("admin.distributionManager.deleteDistributionAfter", params);
		
		return cnt;
	}

	@Override
	public CoviMap selectDistirbutionData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.distributionManager.selectDistirbutionData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "GroupCode,GroupID,GroupName,Description,SortKey,IsUse,InsertDate,EntCode"));	
		
		return resultList;
	}
	@Override
	public CoviMap selectDistributionMemberList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		int listCnt = (int) coviMapperOne.getNumber("admin.distributionManager.selectDistributionMemberListCnt", params);
		
		CoviMap pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		CoviList list = coviMapperOne.list("admin.distributionManager.selectDistributionMemberList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupMemberID,GroupID,UserCode,SortKey,Weight,UR_Name,DEPT_Name"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public int insertDistributionMember(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.distributionManager.insertDistributionMember", params);
	}
	
	@Override
	public int updateDistributionMember(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.distributionManager.updateDistributionMember", params);
	}
	
	@Override
	public int deleteDistributionMember(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.distributionManager.deleteDistributionMember", params);
	}
	
	@Override
	public CoviMap selectDistributionMemberData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.distributionManager.selectDistributionMemberData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "GroupMemberID,GroupID,UserCode,SortKey,Weight,UR_Name,DEPT_Name"));	
		
		return resultList;
	}
	
}
