package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;

import javax.annotation.Resource;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.BudgetRegistSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BudgetRegistSvc")
public class BudgetRegistSvcImpl extends EgovAbstractServiceImpl implements BudgetRegistSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	 * @Method Name : getBuggetRegistList
	 * @Description : 예산편성 목록 조회
	 */
	@Override 
	public CoviMap getBudgetRegistList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);

			cnt		= (int) coviMapperOne.getNumber("budget.regist.getBudgetRegistListCnt" , params);
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}	
		CoviList list	= coviMapperOne.list("budget.regist.getBudgetRegistList", params);	
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetRegistItem
	 * @Description : 사용유무저장
	 */
	@Override
	public CoviMap getBudgetRegistItem(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list	= coviMapperOne.list("budget.regist.getBudgetRegistItem" , params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getBudgetRegistInfo
	 * @Description : 예산편성 정보 조회
	 */
	@Override
	public CoviMap getBudgetRegistInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap list = coviMapperOne.selectOne("budget.regist.getBudgetRegistInfo" , params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}
	
	
	/**
	 * @Method Name : changeControl
	 * @Description : 통제유무 저장
	 */
	public int changeControl(CoviMap params)throws Exception {
		return coviMapperOne.insert("budget.regist.changeControl", params);
	}
	/**
	 * @Method Name : changeUse
	 * @Description : 사용유무저장
	 */
	public int changeUse(CoviMap params)throws Exception {
		return coviMapperOne.insert("budget.regist.changeUse", params);
	}
	
	
	public CoviMap addBudgetRegist (CoviMap params, CoviList saveList) throws Exception {
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		int dupCnt 	=  (int) coviMapperOne.getNumber("budget.regist.getBudgetRegistExists" , params);
		int typeCnt =  (int) coviMapperOne.getNumber("budget.regist.getBudgetRegistTypeExists" , params);
		int ccCnt 	=  (int) coviMapperOne.getNumber("budget.regist.getCostCenterExists" , params);
		
		if(dupCnt > 0 || typeCnt > 0 || ccCnt == 0) {
			resultList.put("dupFlag", 	dupCnt > 0 ? true : false);
			resultList.put("typeFlag", 	typeCnt > 0 ? true : false);
			resultList.put("ccFlag", 	ccCnt == 0 ? true : false);
			return resultList;
		}
		
		for(int i=0; i<saveList.size(); i++){
			CoviMap item = saveList.getJSONObject(i);
			params.put("version",		1);
			params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
			params.put("periodLabel", item.get("periodLabel"));
			params.put("budgetAmount", item.get("budgetAmount"));

			cnt += coviMapperOne.insert("budget.regist.insertBudgetRegist", params);
		}
		resultList.put("dupFlag", false);
		resultList.put("typeFlag", false);
		resultList.put("ccFlag", false);
		resultList.put("tot", saveList.size());
		resultList.put("cnt", cnt);
		
		return resultList;
	}
	public int saveBudgetRegist (CoviMap params, CoviList periodInfo) throws Exception {
		int cnt = 0;
		for(int i = 0; i < periodInfo.size(); i++){
			CoviMap item = periodInfo.getJSONObject(i);
			int result = 0;
			
			params.put("periodLabel",	item.get("periodLabel"));
			params.put("diffAmount",	item.get("diffAmount"));
			params.put("totalAmount",	item.get("totalAmount"));
			
			//예산편성 업데이트
			result += coviMapperOne.update("budget.regist.updateBudgetRegist", params);
			//예산편성 히스토리 추가 
			result += coviMapperOne.insert("budget.regist.insertBudgetRegistHist", params);
			//업데이트 값이 없으면 기존 값이 없으므로 새로 insert
			if (result == 0) {
				params.put("version", 1);
				params.put("budgetAmount", item.get("diffAmount"));
				coviMapperOne.update("budget.regist.insertBudgetRegist", params);
			}
			
			cnt += result;
		}

		return cnt;
	}
	public int deleteBudgetRegist (CoviList saveList) throws Exception {
		int cnt = 0;
		for(int i=0; i<saveList.size(); i++){
			CoviMap params = new  CoviMap();
			CoviMap item = saveList.getJSONObject(i);
			
			params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
			
			params.put("companyCode",		item.get("companyCode"));
			params.put("fiscalYear",		item.get("fiscalYear"));
			params.put("costCenter",		item.get("costCenter"));
			params.put("accountCode",		item.get("accountCode"));
			params.put("standardBriefID",	item.get("standardBriefID"));
			params.put("baseTerm",		    item.get("baseTerm"));
			
			params.put("periodLabel",	item.get("periodLabel"));
			params.put("version", item.get("version"));
			cnt += coviMapperOne.delete("budget.regist.deleteBudgetRegist", params);
		}
		return cnt;
	}
	
	/**
	 * @Method Name : uploadExcel
	 * @Description : 예산편성 엑셀 업로드
	 */
	@Override
	public CoviMap uploadExcel(CoviMap params) throws Exception{
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));

		int totalCnt   =0 ;
		int successCnt =0;
		int failBriefCnt = 0;
		int failCostCenterCnt = 0;
		int failDupCnt = 0;
		int failTypeCnt = 0;

		for (ArrayList list : dataList) { // 추가
			CoviMap paramsSave = new  CoviMap();
			paramsSave.put("UR_Code", SessionHelper.getSession("UR_Code"));
			
			paramsSave.put("companyCode", params.get("companyCode"));
			paramsSave.put("fiscalYear", list.get(0));
			paramsSave.put("costCenter", StringUtil.replaceNull(list.get(1).toString(),""));
			paramsSave.put("accountCode", StringUtil.replaceNull(list.get(2).toString(),""));
			paramsSave.put("accountName", StringUtil.replaceNull(list.get(3).toString(),""));
			paramsSave.put("standardBriefName", StringUtil.replaceNull(list.get(4).toString(),""));
			paramsSave.put("baseTerm", StringUtil.replaceNull(list.get(5).toString(),""));
			
			paramsSave.put("validFrom", StringUtil.replaceNull(list.get(6).toString()).replaceAll("[^0-9]",""));
			paramsSave.put("validTo", StringUtil.replaceNull(list.get(7).toString()).replaceAll("[^0-9]",""));
			paramsSave.put("periodLabel", StringUtil.replaceNull(list.get(8).toString(),""));
			paramsSave.put("budgetAmount", list.get(9));
			paramsSave.put("isUse", StringUtil.replaceNull(list.get(10).toString(),""));
			paramsSave.put("isControl", StringUtil.replaceNull(list.get(11).toString(),""));
			paramsSave.put("empNo", StringUtil.replaceNull(list.get(13).toString(),""));
			
			paramsSave.put("standardBriefID", coviMapperOne.selectOne("budget.regist.getStandardBriefID" , paramsSave));
			paramsSave.put("costCenterType", coviMapperOne.selectOne("budget.regist.getCostCenterType" , paramsSave));
			
			CoviMap dataMap	= coviMapperOne.select("budget.regist.getBudgetRegistCodeExists" , paramsSave);
			if (dataMap.getInt("CostCnt") > 0 && dataMap.getInt("SBCnt") > 0) {
				int dupCnt 	=  (int) coviMapperOne.getNumber("budget.regist.getBudgetRegistExists" , paramsSave);
				int typeCnt =  (int) coviMapperOne.getNumber("budget.regist.getBudgetRegistTypeExists" , paramsSave);
				
				//데이터 중복이거나 다른 예산타입 존재하면 등록하지 않기
				if (dupCnt > 0 || typeCnt > 0)	{
					if (dupCnt  > 0) failDupCnt++;
					if (typeCnt > 0) failTypeCnt++;
					totalCnt++;
					continue;
				}
				
				cnt = coviMapperOne.insert("budget.regist.insertBudgetRegist", paramsSave);
				if (cnt > 0) successCnt++;
			} else {
				if (dataMap.getInt("CostCnt") == 0) failCostCenterCnt++;
				if (dataMap.getInt("SBCnt") == 0)  	failBriefCnt++;
			}
			
			totalCnt++;
		}
		
		resultList.put("totalCnt", totalCnt);
		resultList.put("successCnt", successCnt);
		resultList.put("failBriefCnt", failBriefCnt);
		resultList.put("failCostCenterCnt", failCostCenterCnt);
		resultList.put("failDupCnt", failDupCnt);
		resultList.put("failTypeCnt", failTypeCnt);

		return resultList;
	}
	
}
