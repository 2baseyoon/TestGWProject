package egovframework.covision.groupware.auth;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;

public class PrivacyAuth {
	
	/**
	 * 사용자 권한
	 * @param CoviMap params
	 * @return boolean
	 */
	public static boolean getUserAuth(CoviMap params){
		boolean bUserAuth = false;
		
		try {
			String userCode = params.getString("userCode");
			
			if (userCode.equals(SessionHelper.getSession("USERID"))) {
				bUserAuth = true;
			}
			
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}

		return bUserAuth;
	}
}
