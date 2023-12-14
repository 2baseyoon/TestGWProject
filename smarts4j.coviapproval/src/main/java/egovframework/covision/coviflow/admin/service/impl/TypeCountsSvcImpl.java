package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.TypeCountsSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("typeCountsService")
public class TypeCountsSvcImpl extends EgovAbstractServiceImpl implements TypeCountsSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getStatDeptList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.typeCounts.selectStatDeptListcnt", params);
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.typeCounts.selectStatDeptList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UNIT_NAME,A_Count,REQCMP_count,document_leadtime"));
		resultList.put("cnt", listCnt);
		resultList.put("page", pagingData);
		return resultList;
	}

	@Override
	public CoviMap getStatFormList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = null;
		int cnt = (int) coviMapperOne.getNumber("admin.typeCounts.selectStatFormListcnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		list = coviMapperOne.list("admin.typeCounts.selectStatFormList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormName,document_Count,document_leadtime"));
		resultList.put("cnt", cnt);
		resultList.put("page", page);
		return resultList;
	}
	
	@Override
	public CoviMap getStatPersonList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.typeCounts.selectStatPersonListcnt", params);
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.typeCounts.selectStatPersonList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DISPLAY_NAME,UNIT_NAME,Draft_Count,Approval_Count,Approval_leadtime"));
		resultList.put("cnt", listCnt);
		resultList.put("page", pagingData);

		return resultList;
	}
}
