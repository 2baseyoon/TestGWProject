package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.TaxInvoiceTaxTotalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("TaxInvoiceTaxTotalSvc")
public class TaxInvoiceTaxTotalSvcImpl extends EgovAbstractServiceImpl implements TaxInvoiceTaxTotalSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	/**
	 * @Method Name : getTaxInvoiceTaxTotalList
	 * @Description : 부가세조회 목록 조회
	 */
	@Override
	public CoviMap getTaxInvoiceTaxTotalList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.taxInvoiceTaxTotal.getTaxInvoiceTaxTotalListCnt" , params);
		
		page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.taxInvoiceTaxTotal.getTaxInvoiceTaxTotalList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : taxInvoiceTaxTotalExcelDownload
	 * @Description : 부가세 엑셀 다운로드
	 */
	@Override
	public CoviMap taxInvoiceTaxTotalExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		list	= coviMapperOne.list("account.taxInvoiceTaxTotal.getTaxInvoiceTaxTotalExcelList", params);
		cnt		= (int) coviMapperOne.getNumber("account.taxInvoiceTaxTotal.getTaxInvoiceTaxTotalListCnt" , params);
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
}
