package egovframework.covision.coviflow.form.service;

import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;

public interface FormAuthSvc {
	public boolean hasReadAuth(FormRequest formRequest, UserInfo userInfo);
	public boolean hasReadAuthDefault(FormRequest formRequest, UserInfo userInfo);
	public boolean hasDocReadAuthGov(FormRequest formRequest, UserInfo userInfo);
	public boolean hasWriteAuth(FormRequest formRequest, UserInfo userInfo);
}
