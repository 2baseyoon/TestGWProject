package egovframework.coviaccount.api.jwt;

import java.time.Duration;
import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Component
public class JwtProvider {
	
	private static final String secret = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIiLCJuYW1lIjoiSm9obiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.ih1aovtQShabQ7l0cINw4k1fagApg3qLWiB8Kt59Lno";
	
	public String createToken(LoginMemberRequest loginMemberRequest) {
		CoviMap loginMemberCoviMap = new ObjectMapper().convertValue(loginMemberRequest, CoviMap.class);
		
		if (ApiUser.check(loginMemberRequest)) {
			throw new AuthorizationException("아이디 또는 패스워가 일치하지 않습니다.");
		}
		
		Date now = new Date();
        Date validity = new Date(now.getTime() + Duration.ofDays(30).toMillis());
        
		return Jwts.builder()
				.setClaims(loginMemberCoviMap)
				.setExpiration(validity)
				.signWith(SignatureAlgorithm.HS256, secret)
				.compact();
	}
	
	public boolean validateToken(String token) {
		try {
			Jws<Claims> claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(BearerRemove(token));
			return !claims.getBody().getExpiration().before(new Date());
		} catch (JwtException | IllegalArgumentException e) {
			throw new AuthorizationException("유효하지 않는 토큰입니다.");
		}
	}
	
	private String BearerRemove(String token) {
		if(token.startsWith("Bearer ")) {
			return token.substring("Bearer ".length());
		}
		return token;
    }
}
