package egovframework.coviaccount.common.web;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

import egovframework.coviframework.util.RedisDataUtil;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

public class HmacEncoder {
    private static final String SECRET = RedisDataUtil.getBaseConfig("KakaoToken");	//토큰발급
    private static final String HASH_ALGORITHM = "HmacSHA1";

    public static String encode(Integer nonce, String url, String httpMethod, String corpId, long timestamp) throws NoSuchAlgorithmException, InvalidKeyException {
        String message = String.format("%s%n%s%n%s%n%s%n%s%n%s", nonce, url, httpMethod, corpId, timestamp, nonce);
        Mac sha256_HMAC = Mac.getInstance(HASH_ALGORITHM);
        SecretKeySpec secret_key = new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), HASH_ALGORITHM);
        sha256_HMAC.init(secret_key);
        byte[] hash = sha256_HMAC.doFinal(message.getBytes(StandardCharsets.UTF_8));
        return DatatypeConverter.printBase64Binary(hash);
    }
}

