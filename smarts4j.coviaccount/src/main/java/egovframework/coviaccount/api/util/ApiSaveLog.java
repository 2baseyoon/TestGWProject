package egovframework.coviaccount.api.util;

import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;

@Service
@Transactional
public class ApiSaveLog {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public void saveAccountInterFaceLog(ApiLog apiLog) {
		coviMapperOne.insert("accountApi.util.saveAccountApiLog",apiLog);
	}
}
