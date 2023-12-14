package egovframework.covision.groupware.approval.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface ApprovalSvc {
	public CoviList selectLastestUsedFormListData(CoviMap params) throws Exception;
	public CoviList selectFavoriteUsedFormListData(CoviMap params) throws Exception;
	public CoviList selectMyInfoProfileApprovalData(CoviMap params) throws Exception;
}
