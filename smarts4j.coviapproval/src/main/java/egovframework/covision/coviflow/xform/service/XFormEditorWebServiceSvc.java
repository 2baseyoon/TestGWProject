package egovframework.covision.coviflow.xform.service;

import egovframework.baseframework.data.CoviMap;

public interface XFormEditorWebServiceSvc {

	CoviMap selectParamList(String connectStr, String tableName) throws Exception;

	CoviMap selectMethodList(String connectStr) throws Exception;
}
