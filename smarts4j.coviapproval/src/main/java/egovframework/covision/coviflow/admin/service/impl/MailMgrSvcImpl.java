package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MailMgrSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("mailMgrService")
public class MailMgrSvcImpl extends EgovAbstractServiceImpl implements MailMgrSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getMailMgrList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.mailMgr.selectMailMgrListCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.mailMgr.selectMailMgrList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MailID,Sender,Subject,Recipients,CopyRecipients,BlindCopyRecients,Body,BodyFormat,SendYN,InsertDate,ProcessID,ErrorCount,ErrorMessage"));
		resultList.put("page", pagingData);

		return resultList;
	}
	
	@Override
	public CoviMap getMailDetail(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.mailMgr.selectMailDetail", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "MailID,Sender,Subject,Recipients,CopyRecipients,BlindCopyRecients,Body,BodyFormat,SendYN,InsertDate,ProcessID,ErrorCount,ErrorMessage"));	
		
		return resultList;
	}
	
	@Override
	public int resendMail(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.mailMgr.resendMail", params);
	}
}
