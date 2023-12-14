package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.TempSaveDocSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("tempSaveDocService")
public class TempSaveDocSvcImpl extends EgovAbstractServiceImpl implements TempSaveDocSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectGrid(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int cnt = (int) coviMapperOne.getNumber("admin.tempSaveDoc.selectgridcnt", params);
		
		pagingData = ComUtils.setPagingData(params, cnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.tempSaveDoc.selectgrid", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormTempInstBoxID,FormInstID,FormID,SchemaID,FormPrefix,FormName,Revision,FileName,FormInstTableName,UserCode,CREATED,Subject,WORKDT,Kind,UR_Name,DEPT_Name"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
}
