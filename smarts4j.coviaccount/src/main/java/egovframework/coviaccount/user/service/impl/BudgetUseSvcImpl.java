package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;

import javax.annotation.Resource;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.BudgetUseSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BudgetUseSvc")
public class BudgetUseSvcImpl extends EgovAbstractServiceImpl implements BudgetUseSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	 * @Method Name : getBudgetExecuteList
	 * @Description : 예산사용 목록 조회
	 */
	@Override
	public CoviMap getBudgetExecuteList(CoviMap params) throws Exception {
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
			
			
			cnt		= (int) coviMapperOne.getNumber("budget.use.getBudgetExecuteListCnt" , params);
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}	
		CoviList list	= coviMapperOne.list("budget.use.getBudgetExecuteList", params);				
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetCtrlInfo
	 * @Description : 예산구분조회
	 */
	@Override
	public CoviMap getBudgetCtrlInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList budgetTypeList = coviMapperOne.list("budget.use.getBudgetCtrlInfo", params);
		
		if (budgetTypeList.isEmpty()) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "empty");
		} else if (budgetTypeList.size() > 1) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "multi");
		} else {
			resultList.put("status", Return.SUCCESS);
			resultList.put("data",	budgetTypeList.get(0));
		}
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetAmount
	 * @Description : 예산금액
	 */
	@Override
	public CoviList getBudgetAmount(CoviMap params) throws Exception {
		CoviList resultList	= new CoviList();
		CoviList chkList = CoviList.fromObject(params.getString("chkList"));
		String companyCode = params.getString("companyCode");
		
		for(int i = 0; i < chkList.size(); i++) {
			CoviMap item = chkList.getMap(i);
			CoviMap itemParams = new CoviMap();

			itemParams.put("companyCode", 		companyCode);
			itemParams.put("fiscalYear", 		item.getString("fiscalYear"));
			itemParams.put("executeDate",		item.getString("executeDate"));
			itemParams.put("budgetCode",		item.getString("budgetCode"));
			itemParams.put("costCenterCode",	item.getString("costCenterCode"));
			itemParams.put("accountCode", 		item.getString("accountCode"));
			itemParams.put("standardBriefID", 	item.getString("standardBriefID"));
			
			CoviMap itemResult = coviMapperOne.select("budget.use.getBudgetAmount", itemParams);
			
			resultList.add(itemResult);
		}
		
		return resultList; 
	}

	/**
	 * @Method Name : addExecuteRegist
	 * @Description : 예산실행금액등록
	 */
	public CoviMap addExecuteRegist (CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
	
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		
		int cnt = coviMapperOne.insert("budget.use.addExecuteRegist", params);
		
		resultList.put("status", Return.SUCCESS);
		resultList.put("cnt", cnt);
		
		return resultList;
	}
	
	/**
	 * @Method Name : changeStatus
	 * @Description : 상태변경
	 */
	public int changeStatus(CoviMap params)throws Exception {
		return coviMapperOne.insert("budget.use.changeStatus", params);
	}
}	
