package egovframework.coviframework.util;

import javax.servlet.http.HttpServletRequest;

import egovframework.baseframework.util.PropertiesUtil;

public class ClientInfoHelper {
	
	/**
	 * String getClntIP(HttpServletRequest request) : 클라이언트(Client)의 IP주소를 조회하는 기능
	 * @param     : HttpServletRequest request Request객체
	 * @return    : String ipAddr IP주소
	 * @exception : Exception
	
	public static String getClntIP(HttpServletRequest request) throws Exception {
		
		// IP주소
		String ipAddr = request.getRemoteAddr();
		return ipAddr;
	}
	*/
	/**
	 * getClientOsInfo(HttpServletRequest request) : 클라이언트(Client)의 OS 정보를 조회하는 기능
	 * @param     : HttpServletRequest request Request객체
	 * @return    : String osInfo OS 정보
	 * @exception : Exception
	*/
	public static String getClientOsInfo(HttpServletRequest request) throws Exception {
	
		String user_agent = request.getHeader("user-agent");
		
		if(user_agent.indexOf("NT 6.0") != -1) return "Windows Vista/Server 2008";
		else if(user_agent.indexOf("Windows") != -1) return "Windows";
		else if(user_agent.indexOf("NT 10.0") != -1) return "Windows 10";
		else if(user_agent.indexOf("NT 6.1") != -1) return "Windows 7";
		else if(user_agent.indexOf("NT 6.2") != -1) return "Windows 8";
		else if(user_agent.indexOf("iPhone") != -1) return "iPhone";
		else if(user_agent.indexOf("Android") != -1) return "Android";
		else if(user_agent.indexOf("Mac_PowerPC") != -1) return "Mac OS";
		else if(user_agent.indexOf("iPad") != -1) return "iPad";
		else if(user_agent.indexOf("NT 5.2") != -1) return "Windows Server 2003";
		else if(user_agent.indexOf("NT 5.1") != -1) return "Windows XP";
		else if(user_agent.indexOf("NT 5.0") != -1) return "Windows 2000";
		else if(user_agent.indexOf("NT 6.3") != -1) return "Windows 8.1​";
		else if(user_agent.indexOf("NT 4.0") != -1) return "Windows NT 4.0";
		else if(user_agent.indexOf("Windows ME") != -1) return "Windows ME";
		else if(user_agent.indexOf("Windows CE") != -1) return "Windows CE";
		else if(user_agent.indexOf("OpenBSD") != -1) return "OpenBSD";
		else if(user_agent.indexOf("SunOS") != -1) return "SunOS";
		else if(user_agent.indexOf("9x 4.90") != -1) return "Windows Me";
		else if(user_agent.indexOf("98") != -1) return "Windows 98";
		else if(user_agent.indexOf("95") != -1) return "Windows 95";
		else if(user_agent.indexOf("Win16") != -1) return "Windows 3.x";
		else if(user_agent.indexOf("Linux") != -1) return "Linux";
		else if(user_agent.indexOf("Macintosh") != -1) return "Macintosh";
		else if(user_agent.indexOf("QNX") != -1) return "QNX";
		else if(user_agent.indexOf("BeOS") != -1) return "BeOS";
		else if(user_agent.indexOf("OS/2") != -1) return "OS/2";
		else if(user_agent.indexOf("NT") != -1) return "Windows NT";
		else return "";
		// OS 종류 조회
		/*String os_info = user_agent.substring(user_agent.indexOf("(")+1, user_agent.indexOf(";"));
		return os_info;*/
	}
	
	/**
	 * getClientAgentInfo(HttpServletRequest request) : 클라이언트(Client)의 Agent 정보를 조회하는 기능
	 * @param     : HttpServletRequest request Request객체
	 * @return    : String osInfo Agent 정보
	 * @exception : Exception
	*/
	public static String getClientAgentInfo(HttpServletRequest request) throws Exception {
	
		String user_agent = request.getHeader("user-agent");
		return user_agent;
	}
	
	/**
	 * getClientWebKind(HttpServletRequest request) : 클라이언트(Client)의 웹브라우저 종류를 조회하는 기능
	 * @param     : HttpServletRequest request Request객체
	 * @return    : String webKind 웹브라우저 종류
	 * @exception : Exception
	*/
	public static String getClientWebKind(HttpServletRequest request) throws Exception {
		
		String user_agent = request.getHeader("user-agent");
		
		// 웹브라우저 종류 조회
		String webKind = "";
		if(user_agent.indexOf("Edge") != -1){
			webKind = "Microsoft Edge" + user_agent.substring(user_agent.indexOf("Edge") + 4, user_agent.length());
		}else if(user_agent.indexOf("Edg/") != -1){
			webKind = "Microsoft Edge" + user_agent.substring(user_agent.indexOf("Edg/") + 5, user_agent.length());
		} else if (user_agent.indexOf("rv") != -1 && user_agent.indexOf("Trident") != -1){
			webKind = "Internet Explorer " + user_agent.substring(user_agent.indexOf("rv") + 3, user_agent.indexOf(")"));
		} else if (user_agent.toUpperCase().indexOf("SAFARI") != -1) {
			if (user_agent.toUpperCase().indexOf("CHROME") != -1) {
				webKind = "Google Chrome";
			} else {
				webKind = "Safari";
			}
		} else if (user_agent.toUpperCase().indexOf("GECKO") != -1) {
			if (user_agent.toUpperCase().indexOf("NESCAPE") != -1) {
				webKind = "Netscape (Gecko/Netscape)";
			} else if (user_agent.toUpperCase().indexOf("FIREFOX") != -1) {
				webKind = "Mozilla Firefox (Gecko/Firefox)";
			} else {
				webKind = "Mozilla (Gecko/Mozilla)";
			}
		} else if (user_agent.toUpperCase().indexOf("MSIE") != -1) {
			if (user_agent.toUpperCase().indexOf("OPERA") != -1) {
				webKind = "Opera (MSIE/Opera/Compatible)";
			} else {
				webKind = "Internet Explorer (MSIE/Compatible)";
			}
		} else if (user_agent.toUpperCase().indexOf("THUNDERBIRD") != -1) {
			webKind = "Thunderbird";
		} else {
			webKind = "Other Web Browsers";
		}
		return webKind;
	}
	
	/**
	 * getClientWebVer(HttpServletRequest request) : 클라이언트(Client)의 웹브라우저 버전을 조회하는 기능
	 * @param     : HttpServletRequest request Request객체
	 * @return    : String webVer 웹브라우저 버전
	 * @exception : Exception
	*/
	public static String getClientWebVer(HttpServletRequest request) throws Exception {
		
		String user_agent = request.getHeader("user-agent");
		
		// 웹브라우저 버전 조회
		String webVer = "";
		String [] arr = {"MSIE", "OPERA", "NETSCAPE", "FIREFOX", "SAFARI", "CHROME" };
		for (int i = 0; i < arr.length; i++) {
			int s_loc = user_agent.toUpperCase().indexOf(arr[i]);
			if (s_loc != -1) {
				int f_loc = s_loc + arr[i].length();
				webVer = user_agent.toUpperCase().substring(f_loc, f_loc+5);
				webVer = webVer.replaceAll("/", "").replaceAll(";", "").replaceAll("^", "").replaceAll(",", "").replaceAll("//.", "");
			}
		}
		return webVer;
	}
	
	/**
	 * 모바일 브라우져 접속 여부
	 * @param HttpServletRequest request
	 * @return
	 * @description 
	 */
	public static boolean isMobile(HttpServletRequest request) {
        boolean isMobile = false;
		
		String userAgent = request.getHeader("user-agent");
		
		// Mobile user-agent regex
		String mobileUserAgentRegex = PropertiesUtil.getGlobalProperties().getProperty("mobile.userAgent.regex", 
				".*(LG|SAMSUNG|Samsung|iPhone|iPad|iPod|Android|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson).*");
		// Mobile user-agent exclusion regex
		String mobileUserAgentExcluRegex = PropertiesUtil.getGlobalProperties().getProperty("mobile.userAgent.exclusionRegex",""); 
		// Mobile APP package name
		String mobileAppPackageName = PropertiesUtil.getGlobalProperties().getProperty("mobile.appPackageName", "com.covision.moapp");
				
        isMobile = userAgent.matches(mobileUserAgentRegex);
        
        if(userAgent.indexOf(mobileAppPackageName) > -1){
        	isMobile = true;
        }else if(!mobileUserAgentExcluRegex.isEmpty() && userAgent.matches(mobileUserAgentExcluRegex)) {
        	isMobile = false;
        }
        
        return isMobile;
    }
	
	/**
	 * 모바일 앱 접속 여부
	 * @param HttpServletRequest request
	 * @return
	 * @description 
	 */
	public static boolean isMobileApp(HttpServletRequest request) {
	    String userAgent = request.getHeader("user-agent");
        String mobileAppPackageName = PropertiesUtil.getGlobalProperties().getProperty("mobile.appPackageName", "com.covision.moapp");
        
        if(isMobile(request) && userAgent.contains(mobileAppPackageName)){
        	return true;
        }
        	
        return false;
    }
	
}
