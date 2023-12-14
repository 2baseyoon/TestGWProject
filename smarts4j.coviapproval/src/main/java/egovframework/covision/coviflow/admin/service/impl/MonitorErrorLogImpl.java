package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MonitorErrorLogSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("monitorErrorLogService")
public class MonitorErrorLogImpl extends EgovAbstractServiceImpl implements MonitorErrorLogSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getMonitorErrorLog(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.monitorErrorLog.selectMonitorErrorLogLisCnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		
		CoviList list = coviMapperOne.list("admin.monitorErrorLog.selectMonitorErrorLogList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ServerIP,ErrorTime,ErrorKind,ErrorMessage,ErrorStackTrace,ProcessInsID,FormInstID,ErrorID"));
		resultList.put("page", page);

		return resultList;
	}
	
	@Override
	public void deleteErrorLog(CoviMap params) throws Exception {		
		coviMapperOne.update("admin.monitorErrorLog.deleteErrorLog", params);
	}
}
