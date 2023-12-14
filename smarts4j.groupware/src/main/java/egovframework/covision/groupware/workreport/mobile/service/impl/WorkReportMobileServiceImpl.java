package egovframework.covision.groupware.workreport.mobile.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.workreport.mobile.service.WorkReportMobileService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WorkReportMobileService")
public class WorkReportMobileServiceImpl extends EgovAbstractServiceImpl implements WorkReportMobileService {
	
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
}
