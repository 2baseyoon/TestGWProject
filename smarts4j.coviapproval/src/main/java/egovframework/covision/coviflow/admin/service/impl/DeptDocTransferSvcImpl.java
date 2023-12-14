package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.admin.service.DeptDocTransferSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("deptDocTransferService")
public class DeptDocTransferSvcImpl extends EgovAbstractServiceImpl implements DeptDocTransferSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public void transferDeptDoc(CoviMap params) throws Exception {		
		//#WF_WORKITEM 기존값 저장
		coviMapperOne.insert("admin.deptDocTransfer.insert", params);	
		
		//#WF_ENDWORKITEM 테이블의 PERFORMER_ID 업데이트 
		coviMapperOne.update("admin.deptDocTransfer.update", params);
		coviMapperOne.update("admin.deptDocTransfer.updateCirculation", params);
		
	}

	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
			
		int cnt = (int) coviMapperOne.getNumber("admin.deptDocTransfer.selectcount", params);	
		
		resultList.put("cnt",cnt);
		return resultList;
	}

	
}
