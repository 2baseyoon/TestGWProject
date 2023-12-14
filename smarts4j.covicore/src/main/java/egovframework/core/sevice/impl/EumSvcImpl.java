package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.sevice.EumSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("eumService")
public class EumSvcImpl extends EgovAbstractServiceImpl implements EumSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public boolean messengerAuthHis(CoviMap params) throws Exception {
		boolean flag = false;
		
		if(coviMapperOne.getNumber("eum.selectAuthCount", params) > 0){
			if(coviMapperOne.update("eum.updateAuth", params) > 0)
				flag = true;
				
		}else{
			if(coviMapperOne.insert("eum.createAuth", params) > 0)
				flag = true;
			
		}
		
		return flag;
	}
	
	public CoviMap selectTokenInfo(CoviMap params)throws Exception{
		
		return coviMapperOne.selectOne("eum.selectTokenInfo", params);
	}
	
	public CoviMap selectUserInfo(CoviMap params)throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviMap account  = new CoviMap();
		
		account = coviMapperOne.select("common.login.selectSSO", params);
		
		resultList.put("account", account);
		
		return resultList;
	}

	public boolean updateAccessToken(CoviMap params)throws Exception{
		boolean flag = false;
		
		if(coviMapperOne.update("eum.updateAccessToken", params) > 0)
			flag = true;
		
		return flag;
	}
	
}
