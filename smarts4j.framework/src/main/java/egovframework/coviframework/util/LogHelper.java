package egovframework.coviframework.util;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * @Class Name : LogUtil.java
 * @Description : logging 처리
 * @Modification Information 
 * @ 2016.06.30 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 06.30 
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
public class LogHelper {
	
	public void getCurrentClassErrorLog(Exception e) {
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		org.apache.logging.log4j.Logger LOGGER = LogManager.getLogger(LogHelper.class);
		
		String t = request.getContextPath().replaceAll("/", "");
		String s = e.getStackTrace()[0]+"";
		
		LOGGER.error("###### [EXCEPTION "+t.toUpperCase()+" LOG START] ######");
		LOGGER.error("- " + e.toString());
		LOGGER.error("  > "+s);
		LOGGER.error("###### [EXCEPTION "+t.toUpperCase()+" LOG END] ######");
	}
	
}
