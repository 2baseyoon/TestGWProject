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
import egovframework.coviaccount.user.service.BudgetUsePerformSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BudgetUsePerformSvc")
public class BudgetUsePerformSvcImpl extends EgovAbstractServiceImpl implements BudgetUsePerformSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	 * @Method Name : getBudgetUsePerformList 
	 * @Description : 예산사용 목록 조회
	 */
	@Override
	public CoviMap getBudgetUsePerformList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page = new CoviMap();
		
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);
			
			
			cnt		= (int) coviMapperOne.getNumber("budget.perform.getBudgetUsePerformListCnt" , params);
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}	
		CoviList list	= coviMapperOne.list("budget.perform.getBudgetUsePerformList", params);				
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetUsePerformDetailList 
	 * @Description : 예산사용  상세 목록 조회
	 */
	@Override
	public CoviMap getBudgetUsePerformDetailList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		
		cnt		= (int) coviMapperOne.getNumber("budget.perform.getBudgetUsePerformDetailCnt" , params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		CoviList list	= coviMapperOne.list("budget.perform.getBudgetUsePerformDetail", params);				
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetUsePerformChart 
	 * @Description : 예산사용 차트
	 */
	@Override
	public CoviList getBudgetUsePerformChart(CoviMap params) throws Exception {
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		CoviList list	= coviMapperOne.list("budget.perform.getBudgetUsePerformChart", params);				
		//resultList.put("list",	list);
		
		return list; 
	}
	
}
