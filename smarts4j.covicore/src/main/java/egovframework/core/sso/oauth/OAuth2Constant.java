package egovframework.core.sso.oauth;

import egovframework.baseframework.util.PropertiesUtil;

public class OAuth2Constant {

	public static final String CLIENT_ID = "client_id";
	public static final String CLIENT_SECRET = "client_secret";
	public static final String REDIRECT_URI = "redirect_uri";
	public static final String RESPONSE_TYPE = "response_type";
	public static final String STATE = "state";
	public static final String SCOPE = "scope";
	public static final String CODE = "code";
	public static final String AUTHORIZATION_CODE = "authorization_code";
	public static final String GRANT_TYPE = "grant_type";
	public static final String ACCESS_TOKEN = "access_token";
	public static final String REFRESH_TOKEN = "refresh_token";	
	public static final String TOKEN_TYPE = "token_type";
	public static final String EXPIRES_IN = "expires_in";
	public static final String ISSUED_AT = "issued_at";
	
	//Expires_in : 한시간.
	public static final long EXPIRES_IN_VALUE = 60*60;		
	
	//Response Type
	public static final String RESPONSE_TYPE_CODE = "code";
	public static final String RESPONSE_TYPE_TOKEN = "token";
	
	
	//Token Type
	public static final String TOKEN_TYPE_BEARER = "bearer";
	public static final String TOKEN_TYPE_MAC = "mac";
	public static final String TOKEN_TYPE_JWT = "jwt";
		
	//Grant type
	public static final String GRANT_TYPE_AUTHORIZATION_CODE = "authorization_code";
	public static final String GRANT_TYPE_PASSWORD = "password";
	public static final String GRANT_TYPE_CLIENT_CREDENTIALS = "client_credentials";
	public static final String GRANT_TYPE_REFRESH_TOKEN = "refresh_token";
	
	//에러 발생시 사용할 상수
	public static final String ERROR = "error";
	public static final String ERROR_DESCRIPTION = "error_description";
	
	//Request Header
	public static final String HEADER_AUTHORIZATION = "Authorization";

	//인터셉터에서 유효한 경우 controller로 forward시킬 때 request객체에 추가할 때 사용하는 키값
	public static final String RESOURCE_TOKEN_NAME = "resource_token";
	
	//refresh token의 사용 여부
	public static final boolean USE_REFRESH_TOKEN = false;
	
	//access token을 데이터베이스에 저장하지 않고 정해진 규칙에 따라 생성하고자 할 때 사용할 암호화키
	public static final String AES_ENCRYPTION_KEY = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.token.key"));
}
