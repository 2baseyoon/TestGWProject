package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.TwoFactorManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("twoFactorManageService")
public class TwoFactorManageSvcImpl extends EgovAbstractServiceImpl implements TwoFactorManageSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("twofactor.selectgrid", params);
		int cnt = (int) coviMapperOne.getNumber("twofactor.selectgridcnt", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SEQ,DESCRIPTION,REGISTDATE,REGISTERCODE,MODIFYDATE,MODIFIERCODE,STARTIP,ENDIP,ISLOGIN,ISADMIN,TWOFACTOR,COMPANYNAME"));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	@Override
	public boolean twoFactorUserIsCheck(CoviMap params)throws Exception{
		boolean flag = false;
		int cnt = coviMapperOne.update("twofactor.twoFactorUserIsCheck", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
		
	}
	
	@Override
	public boolean twoFactorAdminIsCheck(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("twofactor.twoFactorAdminIsCheck", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	@Override
	public boolean deleteTwoFactorList(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("twofactor.deleteTwoFactorList", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	@Override
	public CoviMap selectTwoFactorInfo(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("twofactor.selectTwoFactorInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SEQ,DESCRIPTION,STARTIP,ENDIP,ISLOGIN,ISADMIN,TWOFACTOR,COMPANYCODE"));
		return resultList;
	}

	@Override
	public boolean twoFactorEdit(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("twofactor.twoFactorEdit", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	@Override
	public boolean twoFactorAdd(CoviMap params)throws Exception{
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("twofactor.TwoFactorAdd", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	
}
