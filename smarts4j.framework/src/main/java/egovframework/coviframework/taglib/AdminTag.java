package egovframework.coviframework.taglib;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * 타이틀 태그 생성 클래스
 * @version 1.0
 * @author 	ucare
 * @since 	2004.06.01
 */
public class AdminTag extends TagSupport {
	private static final Logger LOGGER = LogManager.getLogger(AdminTag.class);
	private String hiddenWhenEasyAdmin = "";
	public void setHiddenWhenEasyAdmin(String value) {
		hiddenWhenEasyAdmin = value;
	}
	
	/**
	 * 태그 실행시 호출되는 함수
	 * @return 결과
	 */	
	@Override
	public int doStartTag() throws JspException {
		String isEasyAdmin = SessionHelper.getSession("isEasyAdmin");
		
		if(StringUtil.replaceNull(isEasyAdmin,"N").equals("Y")) {
			
			if(hiddenWhenEasyAdmin != null && "true".equals(hiddenWhenEasyAdmin)) {
				try {
					this.pageContext.getOut().write("style='display:none' visibleFixed");
				} catch (IOException e) {
					LOGGER.error(e);
				}
				return (SKIP_BODY);
			}else {
				return (SKIP_BODY);
			}
		}
		else {
			return (EVAL_BODY_INCLUDE);
		}
	}
}
