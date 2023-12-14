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
import egovframework.coviaccount.user.service.CardApplicationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("CardApplicationSvc")
public class CardApplicationSvcImpl extends EgovAbstractServiceImpl implements CardApplicationSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	/**
	 * @Method getCardApplicationList List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 21.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap getCardApplicationList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.cardApplication.getCardApplicationListCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardApplication.getCardApplicationList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method cardApplicationExcelDownload
	 * @작성자 Covision
	 * @작성일 2018. 5. 21.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap cardApplicationExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.cardApplication.getCardApplicationExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.cardApplication.getCardApplicationListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method getCardApplicationDetail Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 21.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap getCardApplicationDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= coviMapperOne.list("account.cardApplication.getCardApplicationDetail", params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
	
	/**
	 * @Method saveCardApplicationInfo
	 * @작성자 Covision
	 * @작성일 2018. 5. 21.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap saveCardApplicationInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		updateCardApplicationUseYN(params);
		return resultList; 
	}
	
	public void updateCardApplicationUseYN(CoviMap params) throws Exception {
		coviMapperOne.update("account.cardApplication.updateCardApplicationUseYN", params);
	}
}
