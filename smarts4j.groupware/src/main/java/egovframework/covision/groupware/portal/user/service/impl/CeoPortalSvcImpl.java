package egovframework.covision.groupware.portal.user.service.impl;

import javax.annotation.Resource;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.portal.user.service.CeoPortalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ceoPortalService")
public class CeoPortalSvcImpl extends EgovAbstractServiceImpl implements CeoPortalSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	private Logger LOGGER = LogManager.getLogger(CeoPortalSvcImpl.class);
	

	@Override
	public CoviMap getDeptVacationList(CoviMap params) throws Exception {
		CoviMap jsonObject = new CoviMap();
		
			
		CoviMap mapCnt = coviMapperOne.selectOne ("ceo.portal.selectUserCount" , params);
		Object cnt = mapCnt.get("Cnt");
		CoviList list = coviMapperOne.list("ceo.portal.selectDeptVacationList", params);

		jsonObject.put("Cnt", cnt);
		jsonObject.put("list", list);
		return jsonObject;
	}

}
