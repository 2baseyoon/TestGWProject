package egovframework.coviaccount.form.service;

import egovframework.coviaccount.form.dto.FormRequest;
import egovframework.coviaccount.form.dto.UserInfo;

public interface FormAuthSvc {
	public boolean hasReadAuth(FormRequest formRequest, UserInfo userInfo);
	public boolean hasReadAuthDefault(FormRequest formRequest, UserInfo userInfo);
	public boolean hasWriteAuth(FormRequest formRequest, UserInfo userInfo);
}
