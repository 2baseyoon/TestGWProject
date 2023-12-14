package egovframework.core.sso.oauth;

import java.nio.charset.StandardCharsets;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.SsoOauthSvc;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sso.saml.SamlException;

@Service("TokenService")
public class OAuth2AccessTokenService {
	private Logger LOGGER = LogManager.getLogger(OAuth2AccessTokenService.class);
	
	@Autowired
	private SsoOauthSvc ssoOAuthsvc;
	
    public String encrypt(String message) throws Exception {

        SecretKeySpec skeySpec = new SecretKeySpec(OAuth2Constant.AES_ENCRYPTION_KEY.getBytes("UTF-8"), "AES");

        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, skeySpec);

        byte[] encrypted = cipher.doFinal(message.getBytes(StandardCharsets.UTF_8));
        return OAuth2Util.binaryToHex(encrypted);
    }
    
    //복호화
    public String decrypt(String encrypted) throws Exception {

        SecretKeySpec skeySpec = new SecretKeySpec(OAuth2Constant.AES_ENCRYPTION_KEY.getBytes("UTF-8"), "AES");

        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, skeySpec);
        byte[] original = cipher.doFinal(OAuth2Util.hexToBinary(encrypted));
        String originalString = new String(original, StandardCharsets.UTF_8);
        return originalString;
    }
    
	/**
	 * <pre>
	 * 1. 개요 : Create Access Token
	 * 2. 처리내용 :
	 * </pre>
	 * @Method Name : generateAccessToken
	 * @date : 2017. 8. 24.
	 * @param client_id
	 * @param client_secret
	 * @param password
	 * @return prev_next
	 * @throws SamlException
	 */ 	
    public String generateAccessToken(String client_id, String client_secret, String userid, String password) {
    	try {
    		String prev = encrypt(userid+"&"+client_id);
    		String next = OAuth2Util.getHmacSha256(password+"&"+client_secret);
    		next = next.substring(0, 16);
    		return prev+"_"+next;
    	} catch (NullPointerException e) {
    		LOGGER.error(e.getLocalizedMessage(), e);
    		return null;
    	} catch (Exception e) {
    		LOGGER.error(e.getLocalizedMessage(), e);
    		return null;
    	}
    }
	
    public TokenVO validateAccessToken(String access_token) {    
    	try {
    		String[] temp = access_token.split("_");

    		String clientHash = temp[1];
    		
    		String base = decrypt(temp[0]);
    		temp = base.split("&");
    		String userid = temp[0];
    		String client_id = temp[1];
    		
    		CoviMap clientResultList = new CoviMap();
    		CoviMap userResultList = new CoviMap();
    		
    		clientResultList = ssoOAuthsvc.getClientOne(client_id);
    		
    		userResultList = ssoOAuthsvc.getUserInfo(userid);
    		CoviMap clientAccount = (CoviMap) clientResultList.get("account");
    		CoviMap userAccount = (CoviMap) userResultList.get("account");

    		base = userAccount.get("LogonPW")+ "&" +clientAccount.get("client_secret");
    		String hash = OAuth2Util.getHmacSha256(base).substring(0, 16);
    		
    		if (!clientHash.equals(hash)) {
    			return null;
    		}
    		
    		TokenVO tVO = null;
    		if (userAccount.size() > 0 && clientAccount.size() > 0) {
    			tVO = new TokenVO();
    			tVO.setClient_id(client_id);
    			tVO.setScope(clientAccount.get("scope").toString());
    			tVO.setAccess_token(access_token);
    			tVO.setClient_type(clientAccount.get("client_type").toString());
    			tVO.setUserid(userid);
    		}
    		
    		return tVO;
    		
    	} catch (NullPointerException e) {
    		return null;
    	} catch (Exception e) {
    		return null;
    	}
    }

}
