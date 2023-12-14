package egovframework.coviaccount.api.jwt;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel("로그인 요청")
public class LoginMemberRequest {
	
	@ApiModelProperty(value = "아이디", required = true)
	private String id;
	
	@ApiModelProperty(value = "비밀번호", required = true)
	private String password;

	public String getId() {
		return id;
	}

	public String getPassword() {
		return password;
	}
}
