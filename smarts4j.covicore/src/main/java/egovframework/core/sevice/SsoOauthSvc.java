package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;
import egovframework.core.sso.oauth.AccessTokenVO;
import egovframework.core.sso.oauth.TokenVO;

public interface SsoOauthSvc {
	
	public CoviMap getClientOne(String clientId) throws Exception;
	public CoviMap getUserInfo(String userId) throws Exception;
	public CoviMap getMyInfo(String userId) throws Exception;
	public CoviMap getUserInfoLogin(String userId, String password) throws Exception;
	public CoviMap selectTokenByCode(String code) throws Exception;
	public CoviMap selectRefreshToken(String refreshToken) throws Exception;
	public CoviMap selectToken(String accessToken) throws Exception;
	
	public int loginCheck(String userId, String password) throws Exception;
	public int selectTokenCnt(String userId) throws Exception;
	public int selectGoogleTokenByExpires(String userId) throws Exception;
	public int selectGoogleTokenNotToUseCount(String userId) throws Exception;
	
	public boolean createToken(TokenVO tVO) throws Exception;
	public boolean deleteToken(String accessToken) throws Exception;
	public boolean updateAccessToken(String accessToken, String refreshToken, long createdAt) throws Exception;
	public boolean deleteExpiredToken(long longTime) throws Exception;
	public boolean updateRefreshToken(AccessTokenVO tVO, String userId) throws Exception;
	public boolean updateUserTokenInfo(String userId, String mail) throws Exception;
	public boolean insertUserTokenInfo(String userId, String mail) throws Exception;
	
	public String getValue(String code) throws Exception;

	public String selectGoogleTokenByUserCode(String userCode) throws Exception;
	public String selectGoogleRefreshTokenByUserCode(String userCode) throws Exception;
}
