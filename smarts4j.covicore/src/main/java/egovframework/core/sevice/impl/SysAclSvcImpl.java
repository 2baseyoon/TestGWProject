package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.core.sevice.SysAclSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysSclSvc")
public class SysAclSvcImpl extends EgovAbstractServiceImpl implements SysAclSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * getAclList: 권한 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAclList(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		String queryId = "acl.selectAcl";
		switch (params.getString("aclType")){
			case "User":
				queryId += "User";
				break;
			case "Cm":
				queryId += "Cm";
				break;
			default:	
				queryId += "Group";
				break;
		}
		
		int cnt = (int) coviMapperOne.getNumber(queryId+"Cnt", params);
		page = ComUtils.setPagingCoviData(params,cnt);
		params.addAll(page);
		CoviList list = coviMapperOne.list(queryId, params);
		resultList.put("list",list);
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * getAclTarget: 사용자 상세 권한 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAclTarget(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("acl.selectAclTargetCnt", params);
		page = ComUtils.setPagingCoviData(params,cnt);
		params.addAll(page);
		
		String queryId = "acl.selectAclTarget";
		CoviList list = coviMapperOne.list(queryId, params);
		resultList.put("list",list);
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * getAclDetail: 상세 권한 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAclDetail(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		String queryId = "acl.selectAclDetail";
		switch (params.getString("objectType")){
			case "MN":
				queryId += "MN";
				break;
			case "FD":
				queryId += "FD";
				break;
			case "PT":
				queryId += "PT";
				break;
			case "CU":
				queryId += "CU";
				break;
			default:	
				queryId += "Group";
				break;
		}
		
		int cnt = (int) coviMapperOne.getNumber(queryId+"Cnt", params);
		page = ComUtils.setPagingCoviData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list(queryId, params);
		resultList.put("list",list);
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * deleteAcl: 권한 삭제
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap deleteAcl(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int deleteCnt = coviMapperOne.delete("acl.deleteAcl", params);
		resultList.put("resultCnt",deleteCnt);
		
		return resultList;
	}
	
	/**
	 * getFolderType: 폴더 타입 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getFolderType(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("acl.selectFolderType", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	/**
	 * getACLInfo: 권한 정보 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getACLInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("acl.selectACLInfo", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	/**
	 * addAclInfo: 권한 데이터 추가
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap addAclInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		String[] objectIDList = params.getString("objectIDList").split(";");
		int insertCnt = 0, aclCnt = 0;
		
		for (String objectID : objectIDList) {
			params.put("objectID", objectID);
			
			aclCnt = (int) coviMapperOne.getNumber("acl.selectACLInfoCnt", params);
			
			if (aclCnt == 0) {
				insertCnt += coviMapperOne.insert("acl.addAclInfo", params);
			}
		}
		
		resultList.put("insertCnt", insertCnt);
		
		return resultList;
	}
	
	/**
	 * setACLInfo: 권한 데이터 수정
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap setACLInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int updateCnt = coviMapperOne.update("acl.setACLInfo", params);
		resultList.put("updateCnt", updateCnt);
		
		return resultList;
	}
	
	/**
	 * getAddList: 권한 추가 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAddList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		boolean isTree = false;
		
		String queryId = "acl.selectAddList";
		switch(params.getString("objectType")){
			case "MN":
				queryId += "MN";
				isTree = true;
				break;
			case "FD":
				queryId += "FD";
				isTree = true;
				break;
			case "PT":
				queryId += "PT";
				break;
			case "CU":
				queryId += "CU";
				break;
			default :
				break;
		}
		
		if (!isTree) {
			int cnt = (int) coviMapperOne.getNumber(queryId+"Cnt", params);
			CoviMap page = ComUtils.setPagingCoviData(params,cnt);
			
			params.addAll(page);
			resultList.put("page", page);
		}
		
		CoviList list = coviMapperOne.list(queryId, params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	/**
	 * getAddTargetList: 권한 추가 대상 목록 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAddTargetList(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		String queryId = "acl.selectAddTargetList";
		switch (params.getString("aclType")) {
			case "User":
				queryId += "User";
				break;
			case "Cm":
				queryId += "Cm";
				break;
			default:	
				queryId += "Group";
				break;
		}
		
		int cnt = (int) coviMapperOne.getNumber(queryId+"Cnt", params);
		page = ComUtils.setPagingCoviData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list(queryId, params);
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * syncAclData: 도메인 별 권한 데이터 동기화
	 * @param objectType - String
	 * @param domainID - String
	 * @return void
	 * @throws Exception
	 */
	@Override
	public void syncAclData(String objectType, String domainID) throws Exception {
		RedisDataUtil.refreshACLSyncKey(domainID, objectType);
		
		if (objectType.equals("MN")) {
			// Menu Cache Reload
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			instance.removeAll(domainID, RedisDataUtil.PRE_MENU + domainID + "_*");
		}
	}
	
	/**
	 * getDomainID: 도메인 아이디 조회
	 * @param domainCode - String
	 * @return String
	 * @throws Exception
	 */
	@Override
	public String getDomainID(String domainCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("domainCode", domainCode);
		
		return coviMapperOne.getString("acl.selectDomainID", params);
	}
}