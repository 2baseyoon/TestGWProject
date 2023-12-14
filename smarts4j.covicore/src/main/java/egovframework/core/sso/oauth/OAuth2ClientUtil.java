package egovframework.core.sso.oauth;

import java.io.IOException;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.map.annotate.JsonSerialize.Inclusion;

import com.google.api.client.repackaged.org.apache.commons.codec.binary.Base64;

public class OAuth2ClientUtil {
	private static final Logger LOGGER = LogManager.getLogger(OAuth2ClientUtil.class);
	
	private static ObjectMapper mapper;

	static {
		mapper = new ObjectMapper();
		mapper.setSerializationInclusion(Inclusion.NON_NULL);
		mapper.setSerializationInclusion(Inclusion.NON_EMPTY);
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

	// hex to byte[]
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

	// byte[] to hex
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

	// URL Encoding Utility
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
		// This exception should never occur.
		catch (UnsupportedEncodingException e) {
			result = s;
		}
		return result;
	}

	
	public static String generateBasicAuthHeaderString(String client_id, String client_secret) {
		try {
			String base = "";
			if (client_secret == null
					|| client_secret.equals("")) {
				base = encodeURIComponent(client_id);
			} else {
				base = encodeURIComponent(client_id) + ":"
						+ encodeURIComponent(client_secret);
			}

			return "Basic " + Base64.encodeBase64String(base.getBytes("UTF-8"));
			
		} catch (UnsupportedEncodingException e) {
			return null;
		}
	}
	
	public static String generateBearerTokenHeaderString(String access_token) {
			return "Bearer " + access_token;
	}
}
