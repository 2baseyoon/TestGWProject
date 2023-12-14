package egovframework.api.admin.util;

import java.time.Duration;
import java.util.Date;
import java.util.Hashtable;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

public class TokenUtil {

	private static final String secret = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIiLCJuYW1lIjoiSm9obiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.ih1aovtQShabQ7l0cINw4k1fagApg3qLWiB8Kt59Lno";
	
	public static String generateToken(String domainID) {
		
		Date now = new Date();
        Date validity = new Date(now.getTime() + Duration.ofDays(50000).toMillis());
        
        Map<String, Object> info = new Hashtable<String, Object>();
        info.put("domain", domainID); // 회사별 토큰.
		return Jwts.builder()
				.addClaims(info)
				.setExpiration(validity)
				.signWith(SignatureAlgorithm.HS256, secret)
				.compact();
	}
}
