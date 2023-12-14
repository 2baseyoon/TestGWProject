package egovframework.covision.groupware.bizcard.user.service;

import egovframework.baseframework.data.CoviMap;


public interface BizCardUtilService {
	CoviMap selectBizCardExcelList(CoviMap params) throws Exception;
	CoviMap selectBizCardCSVList(CoviMap params) throws Exception;
	CoviMap selectBizCardVCFList(CoviMap params) throws Exception;
}
