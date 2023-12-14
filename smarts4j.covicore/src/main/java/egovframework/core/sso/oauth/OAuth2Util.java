package egovframework.core.sso.oauth;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.UUID;
import java.util.Map.Entry;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.DeserializationConfig;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.map.SerializationConfig;
import org.codehaus.jackson.map.annotate.JsonSerialize.Inclusion;

import com.google.api.client.repackaged.org.apache.commons.codec.binary.Base64;

@SuppressWarnings("deprecation")
public class OAuth2Util {
	private static final Logger LOGGER = LogManager.getLogger(OAuth2Util.class);
	
	private static ObjectMapper mapper;

	static {
		mapper = new ObjectMapper();
		// 1.9.x 버전 이상
		mapper.setSerializationInclusion(Inclusion.NON_NULL);
		mapper.setSerializationInclusion(Inclusion.NON_EMPTY);
		// 1.8.x 버전 이하.
		mapper.configure(SerializationConfig.Feature.WRITE_NULL_PROPERTIES,
				false);
		mapper.configure(SerializationConfig.Feature.WRITE_EMPTY_JSON_ARRAYS,
				false);
		mapper.configure(
				DeserializationConfig.Feature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT,
				true);
	}

	public static String encodeURIComponent(String s) {
		String result;

		try {
			result = URLEncoder.encode(s, "UTF-8").replaceAll("\\+", "%20")
					.replaceAll("\\%21", "!").replaceAll("\\%27", "'")
					.replaceAll("\\%28", "(").replaceAll("\\%29", ")")
					.replaceAll("\\%7E", "~");
		} catch (UnsupportedEncodingException e) {
			result = s;
		}

		return result;
	}

	public static String decodeURIComponent(String s) {
		if (s == null) {
			return null;
		}
		String result = null;
		try {
			result = URLDecoder.decode(s, "UTF-8");
		}
		catch (UnsupportedEncodingException e) {
			result = s;
		}
		return result;
	}

	public static byte[] hexToBinary(String hex) {
		if (hex == null || hex.length() == 0) {
			return null;
		}

		byte[] ba = new byte[hex.length() / 2];
		for (int i = 0; i < ba.length; i++) {
			//ba[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);
			ba[i] = Integer.valueOf(hex.substring(2 * i, 2 * i + 2), 16).byteValue();
		}
		return ba;
	}

	public static String binaryToHex(byte[] ba) {
		if (ba == null || ba.length == 0) {
			return null;
		}

		StringBuffer sb = new StringBuffer(ba.length * 2);
		String hexNumber;
		for (int x = 0; x < ba.length; x++) {
			hexNumber = "0" + Integer.toHexString(0xff & ba[x]);

			sb.append(hexNumber.substring(hexNumber.length() - 2));
		}
		return sb.toString();
	}

	public static String getHmacSha256(String str) {
		byte[] binary = null;
		try{
			MessageDigest sh = MessageDigest.getInstance("SHA-256"); 
			sh.update(str.getBytes("UTF-8")); 
			binary = sh.digest();
		} catch (NoSuchAlgorithmException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (UnsupportedEncodingException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return binaryToHex(binary);
	}

	public static String encodeBase64String(String data) {
		byte[] binary;
		try {
			binary = data.getBytes("UTF-8");
			return Base64.encodeBase64String(binary);

		} catch (UnsupportedEncodingException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		}
	}

	public static String decodeBase64String(String base64String) {
		try {
			byte[] binary = Base64.decodeBase64(base64String);
			return new String(binary, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		}
	}

	// 용도 : GET 방식으로 access token을 요청할 때 사용
	// grant_type이 password인 경우(Password Credential 방식인 경우 Access Token 요청할 때)
	public static String generateBasicAuthHeaderString(RequestBaseVO token) {
		try {
			String base = "";
			if (token.getClient_secret() == null
					|| token.getClient_secret().equals("")) {
				base = encodeURIComponent(token.getClient_id());
			} else {
				base = encodeURIComponent(token.getClient_id()) + ":"
						+ encodeURIComponent(token.getClient_secret());
			}

			return "Basic " + Base64.encodeBase64String(base.getBytes("UTF-8"));

		} catch (UnsupportedEncodingException e) {
			return null;
		}
	}

	public static void parseBasicAuthHeader(String authHeader,
			RequestBaseVO token){
		try {
			String basicToken = authHeader.split(" ")[1];
			String decoded = new String(Base64.decodeBase64(basicToken), "utf-8");
			String[] temp = decoded.split(":");
			if (temp.length == 2) {
				token.setClient_id(temp[0]);
				token.setClient_secret(temp[1]);
			} else {
				token.setClient_id(temp[0]);
			}
		} catch (UnsupportedEncodingException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
	}

	public static String generateBearerToken(String access_token) {
		return "Bearer " + access_token;
	}

	public static String parseBearerToken(String authHeader) {
		return authHeader.split(" ")[1];
	}

	public static String getJSONFromObject(Object obj) {
		try {
			StringWriter sw = new StringWriter(); // serialize
			mapper.writeValue(sw, obj);
			sw.close();

			return sw.getBuffer().toString();
		} catch (JsonGenerationException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (JsonMappingException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return null;
	}

	public static <T> T getObjectFromJSON(String json, Class<T> classOfT) {
		try {
			return mapper.readValue(json.getBytes("UTF-8"), classOfT);
		} catch (JsonGenerationException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (JsonMappingException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return null;
	}

	
	//Client ID 생성
	public static String generateClientID() {
		String clientId = "";
		try {
			UUID uuid = UUID.randomUUID();
			clientId = uuid.toString();
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return clientId;
	}
	//Client Secret Key 생성
	public static String generateClientSecret() {
		String clientSecret = "";
		try {
			clientSecret = OAuth2Util.generateRandomState();
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return clientSecret; 
	}
	
	public static long getCurrentTimeStamp() {
		return System.currentTimeMillis();
	}
	
	public static String getAccessTokenToFormUrlEncoded(ResponseAccessTokenVO vo) {
		String s = OAuth2Constant.ACCESS_TOKEN + "=" + encodeURIComponent(vo.getAccess_token());
		s+= "&" + OAuth2Constant.TOKEN_TYPE + "=" + OAuth2Constant.TOKEN_TYPE_BEARER;

		if (vo.getRefresh_token() != null)
			s+= "&" + OAuth2Constant.REFRESH_TOKEN + "=" + encodeURIComponent(vo.getRefresh_token());
		if (vo.getExpires_in() != 0)
			s+= "&" + OAuth2Constant.EXPIRES_IN + "=" + +vo.getExpires_in();
		if (vo.getIssued_at() != 0)
			s+= "&" + OAuth2Constant.ISSUED_AT + "=" + vo.getIssued_at();
		if (vo.getState() != null) {
			s+= "&" + OAuth2Constant.STATE + "=" + vo.getState();
		}
		
		return s;
	}
	
	public static String getAccessTokenToJson(ResponseAccessTokenVO vo) {
		return getJSONFromObject(vo);
	}
	
	public static String getParamString(HashMap<String,String> map, boolean useAuthHeader) throws Exception {
		int i=0;
		String strout = "";
		StringBuffer buf = new StringBuffer();
		for(Entry<String, String> entry : map.entrySet()) {
			if (useAuthHeader == true && 
					(entry.getKey().equals("client_id") || entry.getKey().equals("client_secret") )) {
				continue;
			}
			if (i !=0 )	buf.append("&");
			buf.append(entry.getKey()).append("=").append(URLEncoder.encode(entry.getValue(), "utf-8"));
			i++;			
		}		
		strout = buf.toString();		
		return strout;
	}
	
	public static byte[] getSalt() {
		SecureRandom rand = new SecureRandom ();
	    byte[] salt = new byte[12];
	    rand.nextBytes(salt);
	    return salt;
	}
	
	public static String generateRandomState() {
		SecureRandom secureRandom;
		try {
			secureRandom = SecureRandom.getInstance("SHA1PRNG");
			secureRandom.setSeed(secureRandom.generateSeed(256));
			MessageDigest digest = MessageDigest.getInstance("SHA-1");
			digest.reset();  
			digest.update(getSalt());  
			byte[] dig = digest.digest((secureRandom.nextLong() + "").getBytes(StandardCharsets.UTF_8));
			return binaryToHex(dig).substring(0, 5);
		} catch (NoSuchAlgorithmException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		}

	}
}
