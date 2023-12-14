package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.user.service.RecordInOutSvc;

@Service("RecordInOutSvc")
public class RecordInOutSvcImpl extends EgovAbstractServiceImpl implements RecordInOutSvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private RecordInOutSvc recordInOutSvc;
	
	@Override
	public CoviMap selectGovRecordDocInOutManager(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.govDoc.selectGovRecordDocManageList", params);
		int cnt = (int) coviMapperOne.getNumber("user.govDoc.selectGovRecordDocManageCnt", params);
		page = egovframework.coviframework.util.ComUtils.setPagingData(params, cnt);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptCode,DeptName,ListAuthorityName,ListAuthorityID"));		
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public void insertGovRecordDocInOutUser(CoviMap params) throws Exception {
		coviMapperOne.insert("user.govDoc.insertGovRecordDocInOutUser", params);
	}
	
	@Override
	public void deleteGovRecordDocInOutUser(CoviMap params) throws Exception {		
		coviMapperOne.delete("user.govDoc.deleteGovRecordDocInOutUser", params);
	}
	
	@Override
	public void selectRecordDeptAdminCnt(CoviMap params) throws Exception {
		coviMapperOne.insert("user.govDoc.selectRecordDeptAdminCnt", params);
	}
}
