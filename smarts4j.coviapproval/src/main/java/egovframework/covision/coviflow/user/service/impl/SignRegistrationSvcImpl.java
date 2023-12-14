package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;
import javax.jdo.annotations.Transactional;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.user.service.SignRegistrationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("signRegistrationService")
public class SignRegistrationSvcImpl extends EgovAbstractServiceImpl implements SignRegistrationSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectUserSignList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.signRegistration.selectUserSignList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(list));

		return resultList;
	}

	@Override
	public CoviMap selectUserSignImage(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.signRegistration.selectUserSignImage", params);
		return CoviSelectSet.coviSelectMapJSON(map);
	}

	@Transactional
	@Override
	public int deleteUserSign(CoviMap params) throws Exception {
		if(params.get("IsUse").equals("Y")){
			coviMapperOne.update("user.signRegistration.insertUserSignUseYTop",params);
		}
		return coviMapperOne.delete("user.signRegistration.deleteUserSign", params);
	}

	@Transactional
	@Override
	public int updateUserSignUse(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("user.signRegistration.updateUserSignUseY",params);
		cnt += coviMapperOne.update("user.signRegistration.updateUserSignUseN",params);
		return cnt;
	}

	@Transactional
	@Override
	public int insertUserSign(CoviMap params) {
		int cnt = 0;
		if(params.get("IsUse").equals("Y")){
			cnt += coviMapperOne.update("user.signRegistration.insertUserSignUseN",params);
		}
		cnt += coviMapperOne.insert("user.signRegistration.insertUserSign",params);
		return cnt;
	}

	@Transactional
	@Override
	public int updateUserSign(CoviMap params) {
		int cnt = 0;
		if(params.get("IsUse").equals("Y")){
			cnt += coviMapperOne.update("user.signRegistration.insertUserSignUseN",params);
		}
		cnt += coviMapperOne.update("user.signRegistration.updateUserSign",params);
		return cnt;
	}
	
	@Override
	public int selectUserSignAuth(CoviMap params) {
		return (int) coviMapperOne.getNumber("user.signRegistration.selectUserSignAuth", params);
	}
}
