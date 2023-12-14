package egovframework.covision.groupware.attend.user.util;

import java.util.StringTokenizer;
import java.util.regex.Pattern;


















import com.nhncorp.lucy.security.xss.markup.Description;

import egovframework.baseframework.base.Enums.Return;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;

/**
 * @author sjhan0418
 * {@link Description}
 */
public class AuthCheckUtils {

	
	public static String getAttendanceAuthCheck(String jobTitle){
		return setAuthType(jobTitle);
	}
	
	public static String getAttendanceAuthCheck(){
		String jobTitle =  SessionHelper.getSession("UR_JobTitleCode");
		return setAuthType(jobTitle);
	}
	
	public static String setAuthType(String jobTitle){
		 
		String tmJobArray = RedisDataUtil.getBaseConfig("AttendanceTMJobTiltle");
		String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");
		String authType = jobTitle;
		StringTokenizer tmJob = new StringTokenizer(tmJobArray, "|");
		StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
		
		// 팀장 권한 확인
		while(tmJob.hasMoreTokens()) {
			String strJobTitle = tmJob.nextToken();
			if(jobTitle.equalsIgnoreCase(strJobTitle)) {
				authType = "Team";
				break;
			}
		}
		
		// 본부장 권한 확인 
		while(gmJob.hasMoreTokens()) {
			String strJobTitle = gmJob.nextToken();
			if(jobTitle.equalsIgnoreCase(strJobTitle)) {
				authType = "General";
				break;
			}
		}
		
		//관리자
		/*if("Y".equals(SessionHelper.getSession("isAdmin"))){
			authType = "Admin";
		} 관리자는 따로체크
	 	*/		
		if("".equals(authType)||authType == null){
			authType = "Normal";
		}
		
		return authType;
		
	}
	
}
