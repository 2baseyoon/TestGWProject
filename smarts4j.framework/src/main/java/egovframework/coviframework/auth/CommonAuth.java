package egovframework.coviframework.auth;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;

/**
 * 공통 인증 함수 모음
 *
 * @author 코비젼 연구소
 */

public class CommonAuth {
	/**
	 * SaaS여부
	 * */
	private static final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
	/**
	 * 도메인 권한 관련 인증
	 * @param  요청데이타
	 * @return 인증성공여부
	 * @see #getAssignedDomainID(CoviMap)
	 */
	
	public static boolean getAssignedDomainID(CoviMap params) {
		boolean bAuth = false;
		
		try {
			//saas이면서 그룹사 공용 관리자는 모든 도메인 설정 가능
			if(isSaaS.equalsIgnoreCase("Y") && SessionHelper.getSession("DN_ID").equalsIgnoreCase("0") && "Y".equals(SessionHelper.getSession("isAdmin"))) return true;		

			
			String domain = params.getString("domain");
			CoviList domainList = ComUtils.getAssignedDomainID();
			for (int i =0; i < domainList.size(); i++){
				if (domain.equals(domainList.get(i))) return true;
			}
		} catch(NullPointerException e){	
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return bAuth;
	}
	
}
