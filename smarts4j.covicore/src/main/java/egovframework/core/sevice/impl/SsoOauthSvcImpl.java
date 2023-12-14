package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.SsoOauthSvc;
import egovframework.core.sso.oauth.AccessTokenVO;
import egovframework.core.sso.oauth.TokenVO;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ssoOauth")
public class SsoOauthSvcImpl extends EgovAbstractServiceImpl implements SsoOauthSvc{

	private Logger LOGGER = LogManager.getLogger(SsoOauthSvcImpl.class);
	
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public int loginCheck(String userId, String password)throws Exception{
		CoviMap params = new CoviMap();
		params.put("UR_Code", userId);
		params.put("LogonPW", password);
		
		int cnt = 0 ;
		cnt  = (int) coviMapperOne.getNumber("sys.SsoOauth.checkUserCnt" , params);
		
		return cnt;
	}
	
	
	public CoviMap getClientOne(String clientId) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("client_id", clientId);
			
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.getClientOne", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public CoviMap getUserInfo(String userId) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("id", userId);
			
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.getUserInfo", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public CoviMap getUserInfoLogin(String userId, String password) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("id", userId);
		params.put("password", password);
		params.put("aeskey", aeskey);
		
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.getUserInfoLogin", params);
			
		resultList.put("account", account);
		resultList.put("LogonPW", password);
		
		return resultList;
	}
	
	public boolean createToken(TokenVO tVO) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("client_id", tVO.getClient_id());
		params.put("userid", tVO.getUserid());
		params.put("access_token", tVO.getAccess_token());
		params.put("refresh_token", tVO.getRefresh_token());
		params.put("token_type", tVO.getToken_type());
		params.put("scope", tVO.getScope());
		params.put("code", tVO.getCode());
		params.put("client_type", tVO.getClient_type());
		params.put("created_at", tVO.getCreated_at());
		params.put("created_rt", tVO.getCreated_rt());
		params.put("expires_in", tVO.getExpires_in());
		
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("sys.SsoOauth.createToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public CoviMap selectTokenByCode(String code) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("code", code);
		
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.selectTokenByCode", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public boolean deleteToken(String accessToken) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("access_token", accessToken);
	
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("sys.SsoOauth.deleteToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public CoviMap selectRefreshToken(String refreshToken) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("refresh_token", refreshToken);
		
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.selectRefreshToken", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public boolean updateAccessToken(String accessToken, String refreshToken, long createdAt) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("access_token", accessToken);
		params.put("refresh_token", refreshToken);
		params.put("created_at", createdAt);
	
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("sys.SsoOauth.updateAccessToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public CoviMap selectToken(String accessToken) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("access_token", accessToken);
		
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.selectToken", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public boolean deleteExpiredToken(long longTime) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("long_time", longTime);
	
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("sys.SsoOauth.deleteExpiredToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public CoviMap getMyInfo(String userId) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("id", userId);
			
		CoviMap account;
			
		account = coviMapperOne.select("sys.SsoOauth.getMyInfo", params);
			
		resultList.put("account", account);
		
		return resultList;
	}
	
	public String getValue(String code)throws Exception
	{
		String value = "";
		CoviMap params = new CoviMap();
		
		params.put("code", code);
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		value = coviMapperOne.getString("sys.SsoOauth.getValue", params);
		
		return value;
		
	}
	
	public int selectTokenCnt(String userId)throws Exception
	{
		CoviMap params = new CoviMap();
		
		params.put("UserCode", userId);
		
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("sys.SsoOauth.selectTokenCnt", params);
		
		return cnt;	
	}
	
	public int selectGoogleTokenByExpires(String userId)throws Exception{
		
		CoviMap params = new CoviMap();
		
		params.put("userCode", userId);
		
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("sys.SsoOauth.selectGoogleTokenByExpires", params);
		
		return cnt;
	}
	
	
	public boolean updateRefreshToken(AccessTokenVO tVO, String userId) throws Exception
	{
		CoviMap params = new CoviMap();
		
		int cnt = 0;
		boolean flag = false;
		
		
		params.put("UserCode", userId);
		params.put("RefreshToken", tVO.getRefresh_token());
		params.put("AccessToken", tVO.getAccess_token());
		params.put("Expiresin", tVO.getExpires_in());
		
		cnt = coviMapperOne.update("sys.SsoOauth.updateRefreshToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public boolean updateUserTokenInfo(String userId, String mail) throws Exception
	{
		CoviMap params = new CoviMap();
		
		int cnt = 0;
		boolean flag = false;
		
		params.put("UserCode", userId);
		params.put("Mail", mail);
		
		cnt = coviMapperOne.update("sys.SsoOauth.updateUserTokenInfo", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public boolean insertUserTokenInfo(String userId, String mail) throws Exception
	{
		CoviMap params = new CoviMap();
		
		int cnt = 0;
		boolean flag = false;
		
		params.put("UserCode", userId);
		params.put("Mail", mail);
		
		cnt = coviMapperOne.update("sys.SsoOauth.insertUserTokenInfo", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	public String selectGoogleTokenByUserCode(String userCode) throws Exception
	{
		String token = "";
		
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		
		token = coviMapperOne.selectOne("sys.SsoOauth.selectGoogleTokenByUserCode", params);
		
		return token;
	}
	
	public String selectGoogleRefreshTokenByUserCode(String userCode) throws Exception
	{
		String token = "";
		
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		
		token = coviMapperOne.selectOne("sys.SsoOauth.selectGoogleRefreshTokenByUserCode", params);
		
		return token;
	}
	
	public int selectGoogleTokenNotToUseCount(String userId)throws Exception{
		
		CoviMap params = new CoviMap();
		
		params.put("userCode", userId);
		
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("sys.SsoOauth.selectGoogleTokenNotToUseCount", params);
		
		return cnt;
	}
	
}
