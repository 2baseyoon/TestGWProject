package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.AccountPortalHomeSvc;
import egovframework.coviframework.util.ComUtils;

import org.apache.commons.lang3.StringUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("AccountPortalHomeSvc")
public class AccountPortalHomeSvcImpl extends EgovAbstractServiceImpl implements AccountPortalHomeSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Override
	public int getExecutiveCheck(CoviMap params) throws Exception {
		int cnt		= (int) coviMapperOne.getNumber("account.portalHome.getExecutiveCheck" , params);
		return cnt;
	}
	
	@Override
	public CoviMap getDeadline(CoviMap params) throws Exception {
		//마감일 
		return coviMapperOne.selectOne("accountPortal.selectDeadlineInfo", params);
	}

	/**
	 * @Method Name : getAccountPortalUser 
	 * @Description : 감사레포트 목록 조회
	 */
	@Override
	public CoviMap getAccountPortalUser(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		//증빙별 갯수
		resultList.put("proofCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getProofCodeCount", params)));				
		//계정별 갯수
		resultList.put("accountCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getAccountCodeCount", params)));		
		
		/*
		//승인건
		params.put("state","288");
		resultList.put("readyListCnt",	coviMapperOne.getNumber("account.portalHome.getApprovalListCnt", params));				
		resultList.put("readyList",	coviMapperOne.list("account.portalHome.getApprovalList", params));				

		//진행건
		params.put("state","528");
		resultList.put("ingListCnt",	coviMapperOne.getNumber("account.portalHome.getApprovalListCnt", params));				
		resultList.put("ingList",	coviMapperOne.list("account.portalHome.getApprovalList", params));				
		*/
		
		//법인카드 리스트
		//params.put("proofCode","CorpCard");
		resultList.put("corpCardListCnt",	coviMapperOne.getNumber("account.portalHome.getCorpCardListCnt", params));				
		resultList.put("corpCardList",	 	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getCorpCardList", params)));				

		//세금계산서 리스트
		//params.put("proofCode","TaxBill");
		resultList.put("taxBillListCnt",	coviMapperOne.getNumber("account.portalHome.getTaxBillListCnt", params));				
		resultList.put("taxBillList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getTaxBillList", params)));				
		
		//영수증
		resultList.put("billListCnt",	coviMapperOne.getNumber("account.portalHome.getMobileReceiptListCnt", params));				
		resultList.put("billList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getMobileReceiptList", params)));		
		
		params.put("searchType", "user");
		
		CoviList accountList = (CoviList) AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountSum", params));

		ArrayList<String> colList = new ArrayList<String>();
		for (int i = 0; i < accountList.size(); i++) {
			colList.add(accountList.getJSONObject(i).getString("Code"));
 		}
		
		params.put("Codes", colList);
		//월별 현황조회
		resultList.put("monthHeader",	accountList);		
		resultList.put("monthList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountMonthSum", params)));		

		//마감일 
		resultList.put("deadline",		coviMapperOne.selectOne("account.portalHome.getDeadlineInfo", params));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAccountPortalManager 
	 * @Description : 감사레포트 목록 조회
	 */
	@Override
	public CoviMap getAccountPortalManager(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		//마감 기한
		resultList.put("deadline",		coviMapperOne.selectOne("account.portalHome.getDeadlineInfo", params));		
		//부서코드 리스트
		resultList.put("deptList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getDeptList", params)));
		
		resultList.put("accountList",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountList", params)));
		
		//증빙별 갯수
		resultList.put("proofCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getProofCodeCount", params)));				
		//계정별 갯수
		resultList.put("accountCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountCodeCount", params)));			
		//승인건
		params.put("state","288");
		resultList.put("readyListCnt",	coviMapperOne.getNumber("account.portalManager.getApprovalListCnt", params));				
		resultList.put("readyList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getApprovalList", params)));				

		//진행건
		params.put("state","528");
		resultList.put("ingListCnt",	coviMapperOne.getNumber("account.portalManager.getApprovalListCnt", params));				
		resultList.put("ingList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getApprovalList", params)));				

		//법인카드 리스트
		params.put("proofCode","CorpCard");
		resultList.put("corpCardListCnt",coviMapperOne.getNumber("account.portalHome.getCorpCardListCnt", params));			
		resultList.put("corpCardList",	 AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getCorpCardList", params)));						

		//세금계산서 리스트
		params.put("proofCode","TaxBill");
		resultList.put("taxBillListCnt",coviMapperOne.getNumber("account.portalHome.getTaxBillListCnt", params));				
		resultList.put("taxBillList",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getTaxBillList", params)));				
		
		//영수증
		resultList.put("billListCnt",	coviMapperOne.getNumber("account.portalHome.getMobileReceiptListCnt", params));				
		resultList.put("billList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getMobileReceiptList", params)));
		
		CoviList accountList = (CoviList) AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountSum", params));
		
		ArrayList<String> colList = new ArrayList<String>();
		for (int i = 0; i < accountList.size(); i++) {
			colList.add(accountList.getJSONObject(i).getString("Code"));
 		}

		params.put("Codes", colList);
		//월별 현황조회
		resultList.put("monthHeader",	accountList);		
		resultList.put("monthList",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountMonthSum", params)));		
		
		resultList.put("budgetStd",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getBudgetStdCode", params)));
		return resultList; 
	}
	@Override
	public CoviMap getTotalSummery(CoviMap map) throws Exception {		
		return coviMapperOne.selectOne("account.portalManager.getTotalSummery", map);
	}		
	@Override
	public CoviMap getPortalProof(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getProofCodeCount", map)));
		
		return resultList;
	}	
	@Override
	public CoviMap getPortalAccount(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountCodeCount", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getAccountCode(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountList", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getProofDeptCode(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getDeptList", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getTopCategory(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getTopCategory", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getAccountMonth(CoviMap map) throws Exception {
		
		CoviMap resultList	= new CoviMap();
		
		CoviList accountList = (CoviList) AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountSum", map));

		ArrayList<String> colList = new ArrayList<String>();
		for (int i = 0; i < accountList.size(); i++) {
			colList.add(accountList.getJSONObject(i).getString("Code"));
 		}
		
		map.put("Codes", colList);
		
		//월별 현황조회
		resultList.put("monthHeader",	accountList);		
		resultList.put("monthList",		AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getAccountMonthSum", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getBudgetMonthSum(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getBudgetMonthSum", map)));
		
		return resultList;
	}
	
	@Override
	public CoviMap getBudgetTotal(CoviMap map) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalManager.getBudgetTotal", map)));
		
		return resultList;
	}
	
	@Override
	public int getAuditList(String reportType,CoviMap params) throws Exception {
		 return (int) coviMapperOne.getNumber("account.audit_report.get"+reportType+"ListCnt", params);
	}
	
	/**
	 * @Method Name : getAccountUserMonth 
	 * @Description : 증빙별
	 */
	@Override
	public CoviMap getAccountUserMonth(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		//증빙별 갯수
		resultList.put("proofCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getProofCodeCount", params)));				
		//계정별 갯수
		resultList.put("accountCount",	AccountUtil.convertNullToSpace(coviMapperOne.list("account.portalHome.getAccountCodeCount", params)));		
		return resultList; 
	}
	
	@Override
	public CoviMap getReportDetailList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		int cnt	= (int) coviMapperOne.getNumber("account.portalManager.getReportDetailListCnt", params);
		
		if(params.containsKey("isExcel") && params.getString("isExcel").equals("Y")) {
			CoviList list = coviMapperOne.list("account.portalManager.getReportDetailList",params);

			String headerKey = params.get("headerKey").toString();
			
			returnList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
			returnList.put("cnt", cnt);
		} else {
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);
			
			CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
						
			CoviList list = coviMapperOne.list("account.portalManager.getReportDetailList",params);
			
			returnList.put("list", AccountUtil.convertNullToSpace(list));
			returnList.put("page", page);
		}
		
		return returnList; 
	}
	
	/**
	 * @Method Name : reportTransferExcelDownload
	 * @Description : 자금지출보고서 관련 이체자료 다운로드
	 */
	@Override
	public CoviMap reportTransferExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		CoviList list	= coviMapperOne.list("account.portalManager.reportTransferExcelDownload", params);
		
		// mapping.
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : employeeExpenceExcelDownload
	 * @Description : 자금지출결의서 중 직원경비내역 이체자료 다운로드
	 */
	@Override
	public CoviMap employeeExpenceExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		CoviList list	= coviMapperOne.list("account.portalManager.employeeExpenceExcelDownload", params);
		
		// mapping.
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : vendorExpenceExcelDownload
	 * @Description : 자금지출결의서 중 거래처지급내역 이체자료 다운로드
	 */
	@Override
	public CoviMap vendorExpenceExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		CoviList list	= coviMapperOne.list("account.portalManager.vendorExpenceExcelDownload", params);
		
		// mapping.
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : updatePortalListTabSort
	 * @Description : 포탈 항목 정렬순서
	 */
	@Override
	public int updatePortalListTabSort(CoviMap params) throws Exception{
		int result = 0;
		String [] sortList = StringUtils.split(params.optString("sortList"), ";");
		CoviList updateList = new CoviList();
		for(int i = 0; sortList != null && i < sortList.length; i++) {
			CoviMap map = new CoviMap();
			map.put("SectionKey", sortList[i]);
			map.put("SortKey", (i + 1));
			updateList.add(map);
		}
		if(updateList.size() > 0) {
			params.put("Type", params.getString("Type"));
			params.put("SortList", updateList);
			result = coviMapperOne.update("account.portalHome.updateHomeSectionSort", params);
		}
		return result;
	}
	
	@Override
	public CoviList selectPortalSectionSort(CoviMap params) throws Exception {
		params.put("UserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.list("account.portalHome.selectHomeSectionSort", params);
	}
}
