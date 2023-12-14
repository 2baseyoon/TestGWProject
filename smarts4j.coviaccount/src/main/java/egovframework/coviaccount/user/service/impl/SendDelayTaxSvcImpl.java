package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.SendDelayTaxSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("SendDelayTaxSvc")
public class SendDelayTaxSvcImpl extends EgovAbstractServiceImpl implements SendDelayTaxSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : getSendDelayTaxList
	 * @Description : 미상신내역 메일발송대상 조회
	 */
	@Override
	public CoviMap getSendDelayTaxList(CoviMap params) throws Exception {
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
		
		cnt = (int) coviMapperOne.getNumber("account.senddelaytax.getSendDelayTaxListCnt" , params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.senddelaytax.getSendDelayTaxList", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
}
