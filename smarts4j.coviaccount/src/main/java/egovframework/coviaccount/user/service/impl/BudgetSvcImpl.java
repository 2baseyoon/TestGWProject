package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.BudgetSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BudgetSvc")
public class BudgetSvcImpl extends EgovAbstractServiceImpl implements BudgetSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
		
	/**
	 * @Method Name : getBudgetInfo
	 * @Description : 예산 상세 조회
	 */
	@Override
	public CoviMap getBudgetInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list = coviMapperOne.list("budget.getBudgetInfo", params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
}
