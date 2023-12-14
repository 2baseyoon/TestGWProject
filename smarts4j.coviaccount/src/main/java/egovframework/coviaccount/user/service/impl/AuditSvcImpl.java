package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.AuditSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AuditSvc")
public class AuditSvcImpl extends EgovAbstractServiceImpl implements AuditSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountUtil accountUtil;
	
	/**
	 * @Method Name : getAuditList
	 * @Description : Audit 목록 조회
	 */
	@Override
	public CoviMap getAuditList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list	= coviMapperOne.list("account.audit.getAuditList", params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAuditDetail
	 * @Description : Audit 상세 조회
	 */
	@Override
	public CoviMap getAuditDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list = coviMapperOne.list("account.audit.getAuditDetail",	params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
	
	/**
	 * @Method Name : saveAuditInfo
	 * @Description : Audit 저장
	 */
	@Override
	public CoviMap saveAuditInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		if(!params.get("auditID").equals("")){
			resultList = updateAuditInfo(params);	
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : updateAuditInfo
	 * @Description : Audit Update
	 */
	public CoviMap updateAuditInfo(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		coviMapperOne.update("account.audit.updateAuditInfo", params);
		return resultList;
	}

	@Override
	public CoviMap getAuditRuleInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list = coviMapperOne.list("account.audit.getAuditRuleInfo",	params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList; 
	}	
}
