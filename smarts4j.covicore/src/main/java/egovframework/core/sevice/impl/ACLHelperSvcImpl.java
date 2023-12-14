package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.ACLHelperSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("aclHelperService")
public class ACLHelperSvcImpl extends EgovAbstractServiceImpl implements ACLHelperSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviList selectDomain(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviList list = coviMapperOne.list("devhelper.acl.selectdomain", params);
		return CoviSelectSet.coviSelectJSON(list, "DomainID,DisplayName");
	}
	
	@Override
	public CoviList selectServiceType(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return coviMapperOne.list("framework.cache.selectObjectType", null);
	}
	
	@Override
	public String getDomainID(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return coviMapperOne.getString("devhelper.acl.selectdomainbycode", params);
	}
}
