package egovframework.core.sevice.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.core.sevice.SysPasswordPolicySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysPasswordPolicyService")
public class SysPasswordPolicySvcImpl extends EgovAbstractServiceImpl implements SysPasswordPolicySvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getSelectPolicyComplexity(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.policy.getSelectPolicyComplexity", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "CodeName,Code"));
		 
		return returnObj;
	}
	
	@Override
	public CoviMap getPolicy(CoviMap params) throws Exception {
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.policy.getPolicy", params);
		
		if(selList.isEmpty()) {
			params.put("domainID", "0");
			selList = coviMapperOne.list("admin.policy.getPolicy", params);
		}
		CoviMap returnObj = new CoviMap();
		returnObj.put("list",CoviSelectSet.coviSelectJSON(selList, "DomainID,MaxChangeDate,IsUseComplexity,MinimumLength,ChangeNoticeDate,MaxUnAccessLogin,SpecialCharacterPolicy"));
		 
		// 초기 비밀번호 ,비밀번호 오류 횟수 조회
		CoviList valList = new CoviList();
		valList = coviMapperOne.list("admin.policy.getSettingValue", params);
		returnObj.put("valList",CoviSelectSet.coviSelectJSON(valList, "InitPassword,DefaultInitPassword,LoginFailCount,DefaultFailCount"));
		
		return returnObj;
	}
	
	@Override
	public boolean updatePasswordPolicy(CoviMap params, CoviMap parInitPass, CoviMap parFailCount) throws Exception{
		int cnt = 0;
		int cntInitPass = 0;
		int cntFailCount = 0;
		boolean flag = false;
		//간편관리자는 초기 비밀번호만
		if ("Y".equals(SessionHelper.getSession("isEasyAdmin")) ){
			cntInitPass = coviMapperOne.update("admin.policy.insertMergeBase", parInitPass);
			if (cntInitPass > 0) return true;
			else return false;
		}
			
		cnt = (int) coviMapperOne.getNumber("admin.policy.updatePasswordPolicyCount", params);
		
		if(cnt > 0 ){
			cnt = coviMapperOne.update("admin.policy.updatePasswordPolicy", params);
		}else{
			cnt = coviMapperOne.insert("admin.policy.insertPasswordPolicy", params);
		}
		
		// 초기 비밀번호
		if("".equals(parInitPass.getString("SettingValue"))) {
			coviMapperOne.delete("admin.policy.deleteMergeBase", parInitPass);
		}else {
			coviMapperOne.update("admin.policy.insertMergeBase", parInitPass);
		}

		// 비밀번호 오류 횟수
		if("".equals(parFailCount.getString("SettingValue"))) {
			coviMapperOne.delete("admin.policy.deleteMergeBase", parFailCount);
		}else {
			coviMapperOne.update("admin.policy.insertMergeBase", parFailCount);
		}
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;	
		
	}
	
	
}
