package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.AuditReportSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AuditReportSvc")
public class AuditReportSvcImpl extends EgovAbstractServiceImpl implements AuditReportSvc {

	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	 * @Method Name : getAuditReportList 
	 * @Description : 감사레포트 목록 조회
	 */
	@SuppressWarnings("unchecked")
	@Override
	public CoviMap getAuditReportList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		params.put("lang", SessionHelper.getSession("lang"));
		
		String reportType = params.getString("reportType");;
		String queryId = "account.audit_report.get"+reportType+"List";

		int cnt	= 0;
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);
			
			
			cnt		= (int) coviMapperOne.getNumber(queryId+"Cnt", params);
			CoviMap page 	= ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			
			resultList.put("page",	page);
		}
		
		CoviList list = coviMapperOne.list(queryId, params);		
		
		if(params.containsKey("isExcel") && params.getString("isExcel").equals("Y")) {
			String headerKey = params.get("headerKey").toString();
			resultList.put("list", accountExcelUtil.selectJSONForExcel(list,headerKey));
			resultList.put("cnt", cnt);
		} else {
			resultList.put("list",	AccountUtil.convertNullToSpace(list));
		}
		
		return resultList; 
	}
	

	
}
