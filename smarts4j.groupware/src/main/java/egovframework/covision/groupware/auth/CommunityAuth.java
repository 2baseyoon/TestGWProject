package egovframework.covision.groupware.auth;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;

public class CommunityAuth {
	/**
	 * 커뮤니티 관리자 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getAdminAuth(CoviMap params) {
		boolean bAdminAuth = false;
		
		try {
			CommunityUserSvc communityUserSvc = StaticContextAccessor.getBean(CommunityUserSvc.class);
			
			setParameter(params);
			
			String memberLevel = communityUserSvc.selectCommunityUserLevelCheck(params);
			
			if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { //관리자
				bAdminAuth = true;
			} else if(StringUtil.isNotNull(memberLevel) && memberLevel.equals("9")) {
				bAdminAuth = true;
			}
			
			return bAdminAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 커뮤니티 회원 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getMemberAuth(CoviMap params) {
		boolean bMemberAuth = false;
		
		try {
			CommunityUserSvc communityUserSvc = StaticContextAccessor.getBean(CommunityUserSvc.class);
			
			setParameter(params);
			
			if (getAdminAuth(params)) {
				bMemberAuth = true;
			} else {
				int communityMemberCnt = communityUserSvc.selectCommunityMemberCount(params);
				
				if (communityMemberCnt > 0) {
					bMemberAuth = true;
				}
			}
			
			return bMemberAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 커뮤니티 도메인 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getDomainAuth(CoviMap params) {
		boolean bDomainAuth = false;
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
		
		try {
			if ("Y".equals(SessionHelper.getSession("isAdmin"))){		// Admin인 경우, 도메인 확인하지 않음. 
				return true;
			}
			
			if ("N".equals(isSaaS)) {									// isSaaS = N인 경우, 도메인 확인하지 않음.
				return true;
			}
			
			CommunityUserSvc communityUserSvc = StaticContextAccessor.getBean(CommunityUserSvc.class);
			
			setParameter(params);
			
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			if (communityUserSvc.selectCommunityDomainCheck(params) != 0) {
				bDomainAuth = true;
			}
			
			return bDomainAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	private static void setParameter(CoviMap params) {
		String communityID = params.getString("communityID");
		
		if(StringUtil.isNull(communityID)) {
			if (StringUtil.isNotNull(params.getString("CU_ID"))) {
				communityID = params.getString("CU_ID");
			} else if(StringUtil.isNotNull(params.getString("C"))) {
				communityID = params.getString("C");
			} else if(StringUtil.isNotNull(params.getString("CommunityID"))) {
				communityID = params.getString("CommunityID");
			} else if(StringUtil.isNotNull(params.getString("communityId"))) {
				communityID = params.getString("communityId");
			} else if(StringUtil.isNotNull(params.getString("cid"))) {
				communityID = params.getString("cid");
			} else if(StringUtil.isNotNull(params.getString("cId"))) {
				communityID = params.getString("cId");
			}
		}
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userID", SessionHelper.getSession("USERID"));
		params.put("UR_Code", SessionHelper.getSession("USERID"));
		params.put("CU_ID", communityID);
	}
}