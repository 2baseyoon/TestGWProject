package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.collab.user.service.CollabCommonSvc;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import egovframework.coviframework.util.ACLHelper;

@Service("CollabCommonSvc")
public class CollabCommonSvcImpl extends EgovAbstractServiceImpl implements CollabCommonSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 리스트
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserProject(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		coviMapperOne.insert("collab.common.setUserTeamExec", params);

		cmap.put("prjList",coviMapperOne.list("collab.common.getUserProject", params));
		cmap.put("deptList",coviMapperOne.list("collab.common.getUserTeam", params));
		return cmap;
		
	}
	
	@Override
	public String getUserAuthType() throws Exception {
		String attendAuth = "";
		
		CoviMap params = new CoviMap();
//		params = paramSet(params);
		String domainID =  SessionHelper.getSession("DN_ID");
		
		//협업 관리자 권한조회
		String AuthType = domainID+"_Collab_Admin";
	/*	params.put("AuthType", AuthType);
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("DeptCode",SessionHelper.getSession("GR_Code"));
		params.put("DeptPath",SessionHelper.getSession("GR_GroupPath"));
		int adminCnt = coviMapperOne.selectOne("attend.common.getUserAuthType", params);

		
		String[] subjectInArr =  authorityService.getAssignedSubject(SessionHelper.getSession());
		*/
		
		if(ACLHelper.getExitsUserGroup(SessionHelper.getSession(), AuthType)) {
			attendAuth = "ADMIN";
		}else{
/*			//관리자 권한 없을 시 Manager 권한확인
			AuthType = domainID+"_Collab_Manager";
			params.put("AuthType", AuthType);
			int managerCnt = 0;//coviMapperOne.selectOne("attend.common.getUserAuthType", params);
			
			if(managerCnt>0){
				attendAuth = "MANAGER";
			}else{*/
				//Manager 권한 없을 시 일반 사용자
				attendAuth = "USER";
//			}
		}

		return attendAuth;
	}
	
	@Override
	public CoviList getDeptListByAuth() throws Exception {
		
		CoviMap params = new CoviMap();
		if (SessionHelper.getSession("isCollabAdmin").equals("ADMIN")){
			params.put("isAdmin", "Y");
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
		}
		params.put("GR_GroupPath", SessionHelper.getSession("GR_GroupPath"));
		return coviMapperOne.list("collab.common.getSubDeptList", params);
	}
}
