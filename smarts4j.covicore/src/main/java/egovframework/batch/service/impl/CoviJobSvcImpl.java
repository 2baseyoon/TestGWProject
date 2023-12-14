package egovframework.batch.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.batch.service.CoviJobSvc;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("jobService")
public class CoviJobSvcImpl extends EgovAbstractServiceImpl implements CoviJobSvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int callProc(String procName, CoviMap params) throws Exception{
		return coviMapperOne.update(procName, params);
	} 
	
	@Override
	public int createJobHistory(CoviMap params) throws Exception{
		return coviMapperOne.insert("jobscheduler.admin.insertJobHistory", params);
	}

}
