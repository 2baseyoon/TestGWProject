package egovframework.covision.groupware.bizcard.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizCardGroupManageService")
public class BizCardGroupManageServiceImpl extends EgovAbstractServiceImpl implements BizCardGroupManageService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectBizcardGroup(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		CoviMap returnObj = new CoviMap();
		selList = coviMapperOne.list("groupware.bizcard.selectBizCardGroup", params);		
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "GroupID,GroupName,OrderNO,ShareType,RegisterID"));		
		selList = coviMapperOne.list("groupware.bizcard.selectBizCardGroupPerson", params);
		returnObj.put("bizcardlist",CoviSelectSet.coviSelectJSON(selList, "Name,BizCardID,Email,Code,ItemType"));
		return returnObj;
	}	
	@Override
	public CoviMap selectGroup(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		CoviMap returnObj = new CoviMap();
		selList = coviMapperOne.list("groupware.bizcard.selectBizCardGroup", params);		
		returnObj.put("list",selList);		
		return returnObj;
	}
	@Override
	public CoviMap insertGroup(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		CoviMap duplicate = coviMapperOne.select("groupware.bizcard.cntBizCardGroup", params);
		int duplicateCnt = duplicate.getInt("Count");
		
		if(duplicateCnt == 0) {
			// 중복이 아니라면
			returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardGroup", params);
			
			if(returnCnt == 1) resultObj.put("result", "OK");
			else resultObj.put("result", "FAIL");
		} else {
			// 중복
			resultObj.put("result", "EXIST");
		}
		return resultObj;
	}	
	@Override
	public CoviMap updateGroup(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardGroup", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}	
	@Override
	public CoviMap selectGroupList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("groupware.bizcard.selectGroupList", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "GroupID,GroupName"));
		
		return returnObj;
	}
	@Override
	public CoviMap selectGroupPersonList(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("groupware.bizcard.selectBizCardGroupPersonListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		selList = coviMapperOne.list("groupware.bizcard.selectBizCardGroupPersonList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "Name,BizCardID,Email,Code,ItemType"));
		returnObj.put("page", page);
		
		return returnObj;
	}
	@Override
	public int insertGroupId(CoviMap params) throws Exception {
		int returnGroupId = 0;
		
		CoviMap duplicate = coviMapperOne.select("groupware.bizcard.cntBizCardGroup", params);
		int duplicateCnt = duplicate.getInt("Count");
		
		if(duplicateCnt == 0) {
			// 중복이 아니라면
			coviMapperOne.insert("groupware.bizcard.insertBizCardGroupId", params);
			returnGroupId = params.getInt("GroupID");
		}
		
		return returnGroupId;
	}
	
	@Override
	public int updateGroupId(CoviMap params) throws Exception {
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardGroupId", params);
		
		return returnCnt;
	}	
	@Override
	public int deleteGroupId(CoviMap params) throws Exception {
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardGroupId", params);
		
		return returnCnt;
	}
	@Override
	public int deleteBizCard_GroupPerson(CoviMap params) throws Exception {
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCard_GroupPerson", params);
		
		return returnCnt;
	}	

	
	@Override
	public int insertBizcard_GroupPerson(CoviMap params) throws Exception {
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCard_GroupPerson", params);

		return returnCnt;
	}	
	
	@Override
	public int insertBizcard_Person(CoviMap params) throws Exception {
		int returnBizcardId = 0;
		
		coviMapperOne.insert("groupware.bizcard.insertBizCard_Person", params);
		returnBizcardId = params.getInt("BizCardID");
		return returnBizcardId;
	}		
	@Override
	public int updateBizCard_Person(CoviMap params) throws Exception {
		int returnBizcardId = 0;
		
		coviMapperOne.insert("groupware.bizcard.updateBizCard_Person", params);
		returnBizcardId = params.getInt("BizCardID");
		return returnBizcardId;
	}
	
	@Override
	public int deleteBizCard_Person(CoviMap params) throws Exception {
		int returnBizcardId = 0;
		
		coviMapperOne.insert("groupware.bizcard.deleteBizCard_Person", params);
		returnBizcardId = params.getInt("BizCardID");
		return returnBizcardId;
	}
	
	public int insertGroupMail(CoviMap params) throws Exception {
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardGroupMail", params);

		return returnCnt;
	}
	
	public int deleteGroupMail(CoviMap params) throws Exception {
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.deleteBizCardGroupMail", params);

		return returnCnt;
	}
}
