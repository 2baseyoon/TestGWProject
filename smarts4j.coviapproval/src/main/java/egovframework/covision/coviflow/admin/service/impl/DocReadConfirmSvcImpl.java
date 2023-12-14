package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.DocReadConfirmSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("docReadConfirmService")
public class DocReadConfirmSvcImpl extends EgovAbstractServiceImpl implements DocReadConfirmSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getDocReadConfirmList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.docReadConfirm.selectDocReadConfirmListCnt", params);

		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);		
		list = coviMapperOne.list("admin.docReadConfirm.selectDocReadConfirmList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DocReadID,UserID,UserName,ReadDate,AdminYN,ProcessID,FormInstID,FormID,FormName,FormPrefix,Subject,Revision,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
}
