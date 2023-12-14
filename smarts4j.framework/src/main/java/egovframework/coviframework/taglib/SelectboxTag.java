package egovframework.coviframework.taglib;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;

import java.io.ByteArrayInputStream;
import java.util.Iterator;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

import egovframework.coviframework.util.StringUtil;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.coviframework.service.CoviService;
import egovframework.coviframework.util.SessionCommonHelper;
/**
 */
public class SelectboxTag extends BodyTagSupport{
	private static final Logger LOGGER = LogManager.getLogger(SelectboxTag.class);
			
	private String id = "";
	private String name = "";
	private String disabled = "";
	private String onclick = "";
	private String onchange = "";
	private String className = "";
	private String selected = "";
	private String boxType = "";
	private int startYear = Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4;
	private int yearSize = 6;
	private String mode ="select";
	private String style="";
	private String codeGroups = "";
	private String queryId = "";
	/**
	 * 태그 실행시 호출되는 함수
	 * @return 결과
	 */	
	@Override
	public int doEndTag() throws  JspException{
		BodyContent body = getBodyContent();
		StringBuilder buf = new StringBuilder();

		String selValue= "";
		CoviList dataList=  new CoviList();
		String lang = SessionHelper.getSession("lang");
		String dnId = SessionHelper.getSession("DN_ID");
		try {
			ByteArrayInputStream bais = null;
			SAXBuilder builder 	= new SAXBuilder(false);
			if (body != null && !body.getString().equals("")){
				bais = new ByteArrayInputStream(("<html>"+body.getString()+"</html>").getBytes( "UTF-8" ) ); 
				Document doc	= builder.build(bais);
				Element  root 	= doc.getRootElement();													//Get the root element
				bais.close();
				List optionList 	= root.getChildren("option");
				Iterator i		= optionList.iterator();
				while(i.hasNext()) //optionList
				{
					Element	  optTag			= (Element)i.next();
					String 	  value		= StringUtil.replaceNull(optTag.getAttributeValue("value"),"");
					CoviMap map = new CoviMap();
					map.put("value", value);
					map.put("text", optTag.getText());
					dataList.add(map);
				}	
			}		

			switch (boxType){
				case "PAGE":
					for (int pageInx = 10; pageInx < 50; pageInx = pageInx+5){
						CoviMap map = new CoviMap();
						map.put("value", String.valueOf(pageInx));
						map.put("text", String.valueOf(pageInx));
						dataList.add(map);
					}
					break;
				case "YEAR":
					int year =startYear-1;
					for (int j = 0; j < yearSize; j++){
						year++;
						CoviMap map = new CoviMap();
						map.put("value", String.valueOf(year));
						map.put("text", String.valueOf(year));
						dataList.add(map);
					}
					break;
				case "CODE":
					if(StringUtils.isNoneBlank(codeGroups)){
						String codeGroupArray[] = codeGroups.split(",");
						for (String codeGroup: codeGroupArray) {
							CoviList resultCode= RedisDataUtil.getBaseCode(codeGroup, dnId);
							for(int j=0;j<resultCode.size();j++){
								CoviMap code = (CoviMap)resultCode.getMap(j);
								CoviMap map = new CoviMap();
								map.put("value", code.getString("Code"));
								map.put("text",  DicHelper.getDicInfo(code.getString("MultiCodeName"), lang));
								dataList.add(map);
							} 
					    }
					}
					break;
				case "DB":
					try{
						CoviService coviSvc= StaticContextAccessor.getBean(CoviService.class);
						CoviMap params =  SessionCommonHelper.getSession();
						
						if (!queryId.equals("")){
							CoviList resultList = coviSvc.list(queryId, params);
							for(int j=0;j<resultList.size();j++){
								CoviMap code = (CoviMap)resultList.getMap(j);
								CoviMap map = new CoviMap();
								String stepPath = "";
								if (!code.getString("Step").equals("")){
									for(int k=1;k<code.getInt("Step");k++) {
										stepPath += "&nbsp;";
									}
								}
								map.put("value", code.getString("Value"));
								map.put("text",  stepPath+code.getString("Text"));
								dataList.add(map);
							} 
						}	
					}catch(NullPointerException e){
						LOGGER.error(e.getLocalizedMessage(), e);
					}catch(Exception e){
						LOGGER.error(e.getLocalizedMessage(), e);
					}
					break;
				default:
					break;	
			}

			if (mode.equals("select")){
				buf.append("<select class='" + getClassName() + "' id=\"" + getId() + "\" style=\""+style+"\" ");
				buf.append(""+ (getDisabled() != null && !"".equals(getDisabled()) ? " disabled=\"disabled\"" : "") + "");
				buf.append(""+ (getOnclick() != null && !"".equals(getOnclick()) ? " onclick=\""+ getOnclick() +"\"" : "") + "");
				buf.append(""+ (getOnchange() != null && !"".equals(getOnchange()) ? " onchange=\""+ getOnchange() +"\"" : "") + "");
				buf.append( ">");
				for (int j=0; j < dataList.size(); j++){
					CoviMap map = (CoviMap)dataList.get(j);
					buf.append("<option value='"+map.getString("value")+"' "+(map.getString("value").equals(selected)?" selected ":"")+">"+ map.getString("text")+"</option>");
				}
				buf.append("</select>");
			}else{
				buf.append("<div class='cusSelect " + getClassName() + "'>");
				buf.append("<input id=\"" + getId() + "\" type='txt' readonly='' class='selectValue' value='"+selected+"'>");
				buf.append("<span class='sleOpTitle' onclick='sleOpTitleOnClick(this);'>"+selValue+"</span>");
				buf.append("	<ul id='ulFolderTypes' class='selectOpList'>");
				
				for (int j=0; j < dataList.size(); j++){
					CoviMap map = (CoviMap)dataList.get(j);
					buf.append("<li onclick='selectOpListLiOnclick(this);' data-selvalue='"+map.getString("value")+"'>");
					if (map.getString("value").equals(selected)){	//select된 값 표현
						selValue = map.getString("text");
					}
					buf.append(map.getString("text"));
					buf.append("</li>");
				}
				buf.append("	</ul>");
				buf.append("</div>");
			}	

//			JspWriter out = body.getEnclosingWriter(); 
			JspWriter out = pageContext.getOut();
			out.println(buf.toString());
			boxType = "";
		}catch(NullPointerException e){
			throw new JspException(e);
		}catch(Exception e){
			throw new JspException(e);
		}
		
		return SKIP_BODY;
	}

	/*태그가 닫힐때 발생하는 이벤트
	 * 
	 * 
	public int doEndTag() throws  JspException
	{
		boxType = "";
		return SKIP_BODY;
		
	}
*/

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
	public void setSelected(String selected) {
		this.selected = selected;
	}
	public void setBoxType(String boxType) {
		this.boxType = boxType;
	}

	public void setDisabled(String disabled) {
		this.disabled = disabled;
	}
	public void setOnclick(String onclick) {
		this.onclick = onclick;
	}
	public void setOnchange(String onchange) {
		this.onchange = onchange;
	}
	public void setStartYear(int startYear) {
		this.startYear = startYear;
	}
	public void setYearSize(int yearSize) {
		this.yearSize = yearSize;
	}
	public void setStyle(String style) {
		this.style = style;
	}
	public void setCodeGroups(String codeGroups) {
		this.codeGroups = codeGroups;
	}
	public void setQueryId(String queryId) {
		this.queryId = queryId;
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
	public String getSelected() {
		return selected;
	}
	public String getBoxType() {
		return boxType;
	}
	public String getDisabled() {
		return disabled;
	}
	public String getOnclick() {
		return onclick;
	}
	public String getOnchange() {
		return onchange;
	}
	
}
