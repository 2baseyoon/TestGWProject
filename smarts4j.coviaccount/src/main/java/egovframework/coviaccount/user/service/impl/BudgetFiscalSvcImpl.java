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
import egovframework.coviaccount.user.service.BudgetFiscalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BudgetFiscalSvc")
public class BudgetFiscalSvcImpl extends EgovAbstractServiceImpl implements BudgetFiscalSvc {

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
	public CoviMap getBudgetFiscalList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		
		cnt		= (int) coviMapperOne.getNumber("budget.fiscal.getBudgetFiscalListCnt" , params);
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		CoviList list	= coviMapperOne.list("budget.fiscal.getBudgetFiscalList", params);				
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	public CoviList getBudgetFiscalCode()throws Exception {
		return coviMapperOne.list("budget.fiscal.getBudgetFiscalCode", null);	
	}
	/**
	 * @Method Name : getBudgetUsePerformDetailList 
	 * @Description : 예산사용  상세 목록 조회
	 */
	@Override
	public CoviMap addBudgetFiscal(CoviMap params) throws Exception {
		
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;

		long orgFiscalYear = ((Long)coviMapperOne.selectOne("budget.fiscal.getBudgetFiscalMaxYear")).longValue();

		String fiscalYear  = params.getString("fiscalYear");
		String yearStart  = params.getString("yearStart");
		String yearEnd  = params.getString("yearEnd");
		//((Long)getSqlSession().selectOne(id, params)).longValue();
		//회계년도 저장
		params.put("orgFiscalYear", orgFiscalYear);
		params.put("fiscalYear", fiscalYear);
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));

		String aYearData[][] = {{  "Year", yearStart, "12"}
						 ,{  "Half", yearStart, "6"}
						 ,{  "Quarter", yearStart, "3"}
						 ,{  "Month", yearStart, "1"}};
		for (int i=0; i < aYearData.length; i++)
		{
			params.put("baseTerm", aYearData[i][0]);
			params.put("yearStart", aYearData[i][1]);
			params.put("addTerm", aYearData[i][2]);
			cnt	+= coviMapperOne.update("budget.fiscal.addBudgetFiscal", params);
			
		}
		
		//시작월/종료월 세팅
		String aCodeData[][] = {{  "FirstMonthOfFiscalYear",yearStart}
							,{  "LastMonthOfFiscalYear",  yearEnd}};
		for (int i=0; i < aCodeData.length; i++)
		{
			CoviMap paramsCode = new CoviMap();
			paramsCode.put("code", aCodeData[i][0]);
			paramsCode.put("date", aCodeData[i][1]);
		}
		
		resultList.put("cnt", cnt);
		return resultList; 
	}
	
	public CoviMap getFiscalYearByDate(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("FiscalYear", coviMapperOne.getNumber("budget.fiscal.getFiscalYearByDate", params));
		
		return resultList;	
	}
	
}
