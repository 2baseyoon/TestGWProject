package egovframework.coviframework.taglib;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import egovframework.coviframework.util.DicHelper;

/**
 */
public class CheckboxTag extends TagSupport {
	private String id = "";
	private String name = "";
	private String value = "";
	private String checked = "";
	private String disabled = "";
	private String onclick = "";
	private String className = "";
	private String msgCode = "";
	
	/**
	 * 태그 실행시 호출되는 함수
	 * @return 결과
	 */	
	@Override
	public int doStartTag() throws JspException {
		StringBuilder buf = new StringBuilder();
		
		try {
			buf.append("<span class=\"" + getClassName() + "\">");
			buf.append("	<input type=\"checkbox\" name=\"" + getName() + "\"");
			
			buf.append(" id=\"" + getId() + "\"");
			buf.append(" id=\"" + getId() + "\"");
			buf.append(" value=\"" + getValue() + "\"");
			buf.append(""+ (getChecked() != null && !"".equals(getChecked()) ? " checked=\"checked\"" : "") + "");
			buf.append(""+ (getDisabled() != null && !"".equals(getDisabled()) ? " disabled=\"disabled\"" : "") + "");
			buf.append(""+ (getOnclick() != null && !"".equals(getOnclick()) ? " onclick=\""+ getOnclick() +"\"" : "") + "");
			buf.append("	/>");
			
			buf.append("	<label for=\""+ getId() +"\">");
			buf.append("		<span></span>" + DicHelper.getDic(msgCode) + "");
			buf.append("	</label>");
			buf.append("</span>");
		
			this.pageContext.getOut().write(buf.toString());
			return (SKIP_BODY);
		} catch (IOException e) {
			return (SKIP_BODY);
		}
	}

	/* Setters */
	public void setId(String id) {
		this.id = id;
	}
	public void setName(String name) {
		this.name = name;
	}
	public void setClassName(String className) {
		this.className = className;
	}
	public void setMsgCode(String msgCode) {
		this.msgCode = msgCode;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public void setChecked(String checked) {
		this.checked = checked;
	}
	public void setDisabled(String disabled) {
		this.disabled = disabled;
	}
	public void setOnclick(String onclick) {
		this.onclick = onclick;
	}
	
	
	/* Getters */
	public String getId() {
		if(id == null || "".equals(id)) {
			return "chk_" + name;
		}
		return id;
	}
	public String getName() {
		return name;
	}
	public String getClassName() {
		if(className == null || "".equals(className)) {
			return "chkStyle01";
		}
		return className;
	}
	public String getMsgCode() {
		return msgCode;
	}
	public String getValue() {
		return value;
	}
	public String getChecked() {
		return checked;
	}
	public String getDisabled() {
		return disabled;
	}
	public String getOnclick() {
		return onclick;
	}
	
}
