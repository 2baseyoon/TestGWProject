package egovframework.covision.groupware.oauth2.service.impl;


import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.oauth2.service.AdminOAuth2TestSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("adminOAuth2TestSvc")
public class AdminOAuth2TestSvcImpl extends EgovAbstractServiceImpl implements AdminOAuth2TestSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public String getValue(String code)throws Exception{
		
		String value = "";
		CoviMap params = new CoviMap();
		
		params.put("code", code);
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		value = coviMapperOne.getString("user.oAuth2.getOAuthInfo", params);
		
		return value;
	}
	public String getClient(String key, String userId)throws Exception{
		String value = "";
		CoviMap params = new CoviMap();
		
		params.put("ur_code", userId);
		
		switch(key){
			case "ci": 
				value = coviMapperOne.getString("user.oAuth2.getOAuthClient", params);
				break;
			case "ru":
				value = coviMapperOne.getString("user.oAuth2.getOAuthRedirect", params);
				break;
			case "cs":
				value = coviMapperOne.getString("user.oAuth2.getOAuthClientKey", params);
				break;	
			default :
				break;
		}
		
		return value;
	}
	
	
}
