package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.SystemSsoBaseConfigSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("systemSsoBaseConfigService")
public class SystemSsoBaseConfigSvcImpl extends EgovAbstractServiceImpl implements SystemSsoBaseConfigSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.ssobaseconfig.selectgridcnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.ssobaseconfig.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Code,SsoType,SortKey,Lable,SettingValue,IsUse,Description,RegisterCode,RegisterDate,ModifierCode,ModifierDate"));
		return resultList;
	}
	
	/**
	 * 사용유무 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUse(CoviMap params)throws Exception{
		return coviMapperOne.update("sys.ssobaseconfig.updateIsUse", params);
	};
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.ssobaseconfig.selectList", params);
	
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,  "Code,SsoType,SortKey,Lable,SettingValue,IsUse,Description,RegisterCode,RegisterDate,ModifierCode,ModifierDate"));
		return resultList;
	}
	
	/**
	 * 데이터 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	public boolean update(CoviMap params)throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("sys.ssobaseconfig.updategrid", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	@Override
	public CoviMap selectClientList(String urCode) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
	
		params.put("ur_code", urCode);
	
		resultList.put("list", CoviSelectSet.coviSelectMapJSON(coviMapperOne.select("sys.ssobaseconfig.selectClientList", params)));
		
		return resultList;
	}
	
	public boolean updateClient(CoviMap params)throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("sys.ssobaseconfig.updateClient", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean createClient(CoviMap params)throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("sys.ssobaseconfig.createClient", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean deleteClient(CoviMap params)throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("sys.ssobaseconfig.deleteClient", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean deleteToken(CoviMap params)throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("sys.ssobaseconfig.deleteToken", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public int selectClient(CoviMap params)throws Exception{
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("sys.ssobaseconfig.selectClient", params);
		return cnt;
		
	}
	
	public int selectToken(CoviMap params)throws Exception{
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("sys.ssobaseconfig.selectToken", params);
		return cnt;
		
	}
	
	public String getDomainURL(CoviMap params)throws Exception{
		String value = "";
		
		value = coviMapperOne.getString("sys.ssobaseconfig.selectDomainUrl", params);
		
		return value;
	}
}
