package egovframework.coviaccount.api.jwt;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.commons.codec.binary.Base64;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;

public enum ApiUser {
	
	ADMIN(
		PropertiesUtil.getExtensionProperties().getProperty("account.jwt.token.admin.id"), 
		PropertiesUtil.getExtensionProperties().getProperty("account.jwt.token.admin.password")
	);
	
	private String id;

    private String password;
    
    private static final Map<String, String> members = Collections.unmodifiableMap(
            Stream.of(values())
                .collect(Collectors.toMap(ApiUser::getId, ApiUser::getPassword))
        );

    ApiUser(String id, String password) {
        this.id = id;
        this.password = password;
    }
    
    public static boolean check(LoginMemberRequest loginMemberRequest) {
    	String decodeId = new String(Base64.decodeBase64(((String) loginMemberRequest.getId()).getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
    	String decodePw = new String(Base64.decodeBase64(((String)  loginMemberRequest.getPassword()).getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
        if (members.containsKey(decodeId) && Objects.equals(members.get(decodeId), decodePw)) {
            return false;
        }
        return true;
    }

	public String getId() {
		return id;
	}

	public String getPassword() {
		return password;
	}
}
