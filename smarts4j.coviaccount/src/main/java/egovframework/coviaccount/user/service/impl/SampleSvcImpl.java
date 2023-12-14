package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.user.service.SampleSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sampleService")
public class SampleSvcImpl extends EgovAbstractServiceImpl implements SampleSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	

}
