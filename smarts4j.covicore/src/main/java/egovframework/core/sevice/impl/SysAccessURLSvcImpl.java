package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.SysAccessURLSvc;
import egovframework.coviframework.util.AccessURLUtil;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("sysAccessURLService")
public class SysAccessURLSvcImpl extends EgovAbstractServiceImpl implements SysAccessURLSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.accessurl.selectListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.accessurl.selectList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap getInfo(CoviMap params) throws Exception {
		CoviMap info = new CoviMap();
		info.addAll(coviMapperOne.select("sys.accessurl.selectInfo", params));
		
		return info;
	}

	@Override
	public boolean add(CoviMap params) throws Exception {
		boolean flag = false;
		
		int cnt = coviMapperOne.insert("sys.accessurl.insert", params);
		String accessURLID = params.getString("AccessUrlID");
		
		if(cnt > 0 || !accessURLID.isEmpty()){
			flag = true;	
			
			if(params.getString("isUse").equalsIgnoreCase("Y")) {
				AccessURLUtil.addAccessURL(accessURLID, params.getString("url"));
			}
		}
		
		return flag;
	}

	@Override
	public boolean modify(CoviMap params) throws Exception {
		boolean flag = false;
		
		int cnt = coviMapperOne.insert("sys.accessurl.update", params);
		if(cnt > 0){
			flag = true;	
			
			//URL이 변경되었을 경우를 위해 삭제 후 추가
			AccessURLUtil.deleteAccessURL(params.getString("accessURLID"));
			
			if(params.getString("isUse").equalsIgnoreCase("Y")) {
				AccessURLUtil.addAccessURL(params.getString("accessURLID"), params.getString("url"));
			}
		}
		
		return flag;
	}

	@Override
	public boolean modifyIsUse(CoviMap params) throws Exception {
		boolean flag = false;
		
		int cnt = coviMapperOne.insert("sys.accessurl.updateIsUse", params);
		if(cnt > 0){
			flag = true;			
			
			CoviMap accessURLInfo = getInfo(params);
			
			if(params.getString("isUse").equalsIgnoreCase("Y")) {
				AccessURLUtil.addAccessURL(accessURLInfo.getString("AccessUrlID"), accessURLInfo.getString("URL"));
			}else if(params.getString("isUse").equalsIgnoreCase("N")) {
				AccessURLUtil.deleteAccessURL(accessURLInfo.getString("AccessUrlID"));
			}
		}
		
		return flag;
	}
	
	@Override
	public boolean modifyIsAdmin(CoviMap params) throws Exception {
		boolean flag = false;
		
		int cnt = coviMapperOne.insert("sys.accessurl.updateIsAdmin", params);
		if(cnt > 0){
			flag = true;			
			
			CoviMap accessURLInfo = getInfo(params);
			
			if(params.getString("isAdmin").equalsIgnoreCase("Y")) {
				AccessURLUtil.addAccessURL(accessURLInfo.getString("AccessUrlID"), accessURLInfo.getString("URL"));
				AccessURLUtil.deleteAccessURLWithNoExtendExpireTime(accessURLInfo.getString("AccessUrlID"));
				
			}else if(params.getString("isAdmin").equalsIgnoreCase("N")) {
				AccessURLUtil.addAccessURLWithNoExtendExpireTime(accessURLInfo.getString("AccessUrlID"), accessURLInfo.getString("URL"));
				AccessURLUtil.deleteAccessURL(accessURLInfo.getString("AccessUrlID"));
			}
		}
		
		return flag;
	}

	@Override
	public boolean delete(CoviMap params) throws Exception {
		boolean flag = false;
		
		int cnt = coviMapperOne.insert("sys.accessurl.delete", params);
		if(cnt > 0){
			flag = true;	
			
			String[] arrAccessURLID = (String[]) params.get("arrAccessURLID");
			
			for(String accessURLID : arrAccessURLID) {
				AccessURLUtil.deleteAccessURL(accessURLID);
			}
		}
		
		return flag;
	}
	
	
}
