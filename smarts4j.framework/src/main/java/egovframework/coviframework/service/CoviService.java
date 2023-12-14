package egovframework.coviframework.service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;


public interface CoviService {

	int insert(String svcId, CoviMap params) throws Exception;
	CoviList list(String svcId, CoviMap params) throws Exception;
	CoviMap select(String svcId, CoviMap params) throws Exception;
}
