package egovframework.covision.coviflow.admin.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.JobFunctionSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("jobFunctionService")
public class JobFunctionSvcImpl extends EgovAbstractServiceImpl implements JobFunctionSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectJobFunctionGrid(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.jobFunction.selectJobFunctionGridCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		
		list = coviMapperOne.list("admin.jobFunction.selectJobFunctionGrid", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "EntCode,EntName,JobFunctionCode,JobFunctionID,JobFunctionName,JobFunctionType,JobFunctionTypeName,DeptName,DeptID,Description,DeptCode,SortKey,InsertDate,IsUse"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectJobFunctionMemberGrid(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("admin.jobFunction.selectJobFunctionMemberGridCnt", params);		
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.jobFunction.selectJobFunctionMemberGrid", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_ID,JobFunctionMemberID,JobFunctionID,UserCode,SortKey,Weight,UR_Name,DEPT_NAME,DEPT_CODE,DN_Name"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectJobFunctionAllMember(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.jobFunction.selectJobFunctionMemberGrid", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_ID,JobFunctionMemberID,JobFunctionID,UserCode,SortKey,Weight,UR_Name,DEPT_NAME,DEPT_CODE,DN_Name"));
		return resultList;
	}
	
	@Override
	public CoviMap selectJobFunctionData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.jobFunction.selectJobFunctionData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "EntCode,JobFunctionCode,JobFunctionID,JobFunctionName,JobFunctionType,DeptName,DeptID,Description,DeptCode,SortKey,InsertDate,IsUse"));	
		
		return resultList;
	}
	@Override
	public CoviMap selectJobFunctionMemberData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.jobFunction.selectJobFunctionMemberData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "JobFunctionMemberID,JobFunctionID,UserCode,SortKey,Weight,UR_Name,DEPT_NAME,DEPT_CODE"));	
		
		return resultList;
	}
	
	@Override
	public int deleteJobFunction(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("admin.jobFunction.deleteJobFunction", params);
		cnt += coviMapperOne.delete("admin.jobFunction.deleteJobFunctionAfter", params);
		
		return cnt;
	}
	
	@Override
	public int insertJobFunction(CoviMap params) throws Exception {
		int cnt = coviMapperOne.insert("admin.jobFunction.insertJobFunction", params);		
		return cnt;
	}
	
	@Override
	public List selectJobFunctionCode(String entCode) throws Exception {
		List list = coviMapperOne.selectList("admin.jobFunction.selectJobFunctionCode", entCode);		
		return list;
	}
	
	@Override
	public int updateJobFunction(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.jobFunction.updateJobFunction", params);
	}

	@Override
	public int insertJobFunctionMember(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.jobFunction.insertJobFunctionMember", params);
	}
	
	@Override
	public int updateJobFunctionMember(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.jobFunction.updateJobFunctionMember", params);
	}
	@Override
	public int deleteJobFunctionMember(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.jobFunction.deleteJobFunctionMember", params);
	}
	
	
}
