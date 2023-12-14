package egovframework.covision.groupware.oauth2.service.impl;


import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.oauth2.service.AdminOAuth2Svc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("adminOAuth2Svc")
public class AdminOAuth2SvcImpl extends EgovAbstractServiceImpl implements AdminOAuth2Svc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public String getEmail(String userId)throws Exception{
		
		String value = "";
		CoviMap params = new CoviMap();
		
		params.put("UserCode", userId);
		
		value = coviMapperOne.getString("user.oAuth2.getEmail", params);
		
		return value;
	}
	
}
