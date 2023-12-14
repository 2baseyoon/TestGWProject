package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MonitorErrorListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("monitorErrorListService")
public class MonitorErrorListImpl extends EgovAbstractServiceImpl implements MonitorErrorListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getMonitorErrorList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap page = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.monitorErrorList.selectMonitorErrorListCnt", params);
		page = ComUtils.setPagingData(params, listCnt);
		params.addAll(page);
		
		list = coviMapperOne.list("admin.monitorErrorList.selectMonitorErrorList", params);
		if("Workitem".equals(params.optString("TYPE"))){
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "WorkItemID,ProcessID,Name,DSCR,UserName,PerformerID,Created,FinishRequested,ProcessState"));
		}else{
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,ProcessName,StartDate,ProcessState,DocSubject,InitiatorID,InitiatorName"));
		}
		resultList.put("page", page);
		return resultList;
	}
	
	@Override
	public int setMonitorChangeState(CoviMap params) throws Exception{
		return  coviMapperOne.update("admin.monitorErrorList.updateMonitorChangeState", params);			
	}	
}
