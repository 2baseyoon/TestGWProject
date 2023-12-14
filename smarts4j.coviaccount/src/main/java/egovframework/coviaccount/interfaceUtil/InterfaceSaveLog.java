package egovframework.coviaccount.interfaceUtil;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;

@Service
@Transactional
public class InterfaceSaveLog  {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Transactional(isolation=Isolation.DEFAULT, propagation=Propagation.REQUIRES_NEW)
	public void saveAccountInterFaceLog(CoviMap logInfo) {
		try {
			coviMapperOne.insert("accountInterFace.util.saveAccountInterFaceLog",logInfo);			
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	}
}
