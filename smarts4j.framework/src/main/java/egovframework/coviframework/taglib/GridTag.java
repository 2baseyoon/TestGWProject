package egovframework.coviframework.taglib;

import java.util.Iterator;
import java.util.List;
import java.io.ByteArrayInputStream;
import java.io.IOException;

import javax.servlet.http.Cookie;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletRequest;

import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.StringUtil;

import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.ServletException;


/**
 */
public class GridTag extends BodyTagSupport{
	private String id = "";
	private String pageCookie		    = "";
	private int pageSize		        = 0;
	private String gridVar = "";
	private String initFn = "";
	private boolean gridEvent = false;
	/**테이블id 반환*/
	public String getId() { return id; }
	/**테이블id 설정*/
	public void setId(String id) { this.id = id; }

	
	/**테이블 size page반환*/
	public String getPageCookie() { return pageCookie; }
	public void setPageCookie(String pageCookie) { this.pageCookie = pageCookie; }
	
	public int getPageSize() { return pageSize; }
	public void setPageSize(int pageSize) { this.pageSize = pageSize; }

	
	public String getGridVar() {return gridVar;	}
	public void setGridVar(String gridVar) {this.gridVar = gridVar;}
	
	public String getInitFn() {return initFn;}
	public void setInitFn(String initFn) {this.initFn = initFn;}


	private static final String INC_END_JSP = "/WEB-INF/views/tags/gridEnd.jsp";
	
	/**
	 * 태그 실행시 호출되는 함수
	 * @return 결과
	 */	
	@Override
	public int doAfterBody() throws  JspException{
		BodyContent body = getBodyContent();
		StringBuffer sbColTag = new StringBuffer();
		StringBuffer sbEventTag = new StringBuffer();
		gridEvent = false;

		try{
			ByteArrayInputStream bais = null;
			SAXBuilder builder 	= new SAXBuilder(false);
			bais = new ByteArrayInputStream(("<html>"+body.getString()+"</html>").getBytes( "UTF-8" ) ); 
			Document doc	= builder.build(bais);
			Element  root 	= doc.getRootElement();													//Get the root element
			
			bais.close();

			List trList 	= root.getChildren("tr");
			Iterator j		= trList.iterator();
			
			if(j.hasNext())	//tr
			{	
				Element	  tr	= (Element)j.next();

				//td 속성 처리
				List tdList 	= tr.getChildren("td");
				Iterator i		= tdList.iterator();
				int iColIndex   = -1;

				while(i.hasNext()) //td
				{
					iColIndex++;
					Element	  td			= (Element)i.next();
					String 	  key		= StringUtil.replaceNull(td.getAttributeValue("key"),"");
					String 	  label		= StringUtil.replaceNull(td.getAttributeValue("label")," ");
					String 	  width		= StringUtil.replaceNull(td.getAttributeValue("width"),"0");
					String 	  sort		= StringUtil.replaceNull(td.getAttributeValue("sort"),"");
					String    align     = StringUtil.replaceNull(td.getAttributeValue("align"),"center");
					String    disabled  = StringUtil.replaceNull(td.getAttributeValue("disabled"),"");
					
					
					String 	  addClass		= StringUtil.replaceNull(td.getAttributeValue("addClass"),"");
					String 	  display		= StringUtil.replaceNull(td.getAttributeValue("display"),"");
					String 	  hideFilter		= StringUtil.replaceNull(td.getAttributeValue("hideFilter"),"");
					String    formatter      	= StringUtil.replaceNull(td.getAttributeValue("formatter"),"");
					String    linkEvent      	= StringUtil.replaceNull(td.getAttributeValue("linkEvent"),"");

					sbColTag.append(getGridVar() + "_header.push({");
					sbColTag.append("key : \"" + key + "\"");
					sbColTag.append(",label : \"" + (label.equals("")?"":DicHelper.getDic(label)) + "\"");
					sbColTag.append(",align : \"" + align + "\"");
					sbColTag.append(",width : \"" + width + "\"");
					
					if ("FLOWER".equals(formatter)) {
						sbColTag.append(",addClass :  \"bodyTdFile\"");
					}
					else {
						if (!addClass.equals("")) {
							sbColTag.append(",addClass :  \"" + addClass + "\"");
						}
					}
					if (!sort.equals(""))  		sbColTag.append(",sort :  " + sort + "");
					if (!display.equals(""))  	sbColTag.append(",display : "+display);
//					: function(formatter, item){ return  "+formatAddtion+"(item);}");
					if (!disabled.equals(""))  	sbColTag.append(",disabled :function(){ return "+disabled+"(this.item);}");
					if (!hideFilter.equals("")) sbColTag.append(",hideFilter : \"" + hideFilter + "\"");
//					
					String    formatAddtion = StringUtil.replaceNull(td.getAttributeValue("formatAddtion"),"");
					String    callback =  StringUtil.replaceNull(td.getAttributeValue("callback"),"");
					if(formatter != null && !"".equals(formatter)) {
						switch (formatter){//
							case "money":
							case "dec":
							case "html":
							case "checkbox":
							case "radio":
								sbColTag.append(",formatter :\""+formatter+"\"");
								break;
							case "SWITCH":
								sbColTag.append(",formatter : function(formatter, item){ ");
								sbColTag.append(" return coviCmn.getCoviSwitch('"+key+iColIndex+"',{'on':'Y','off':'N', 'defVal':this.item."+key+", 'retVal':this.item."+formatAddtion+"}, function (retVal, thisVal) { "+callback+"(retVal, thisVal);})");
								sbColTag.append("}");		
								break;
							case "CUSTOM":	
								sbColTag.append(",formatter : function(formatter, item){ return  "+formatAddtion+"(item);}");
								break;	
							default://LINK, DIC, FLOWER, TERM
								sbColTag.append(",formatter : function(formatter, item){ return  coviCmn.getCoviGridFormat('"+formatter+"', item, '"+key+"', '"+formatAddtion+"');}");
								break;
						}	
					}	
					sbColTag.append("});\r\n");

					if(linkEvent != null && !"".equals(linkEvent)) {
						sbEventTag.append("case \""+iColIndex+"\": "+linkEvent+"(item);break;\r\n");
					}
				}
			}	
			JspWriter out = body.getEnclosingWriter(); 
			out.println("<script type='text/javascript'> ");
			out.println("var "+getGridVar() + "_header=[];");
			out.println(sbColTag.toString());
			
			if (!sbEventTag.toString().equals("")){
				out.println("function grid"+getGridVar()+"_Click(){\r\n"+
					"let col = this.c;\r\n"+
					"let item= this.item;\r\n"+
					"switch(col){\r\n"+
						sbEventTag.toString()+"\r\n"+
					"	}}\r\n");
				gridEvent = true;
			}
			out.println("</script>\r\n");
		} catch(NullPointerException e) {
			throw new JspException(e);
		} catch(Exception e) {
			throw new JspException(e);
		}
		
		return SKIP_BODY;
	}
	
	@Override
	public int doEndTag() throws JspException {
		try {
			ServletRequest req = pageContext.getRequest();
			if (!getPageCookie().equals("")){
				Cookie[] cookies =    ((HttpServletRequest) req).getCookies();   
				for (int i = 0 ; i < cookies.length ; i++) {
					if(getPageCookie().equals(cookies[i].getName())){
						pageSize = Integer.parseInt(cookies[i].getValue());
						break;
					}
				}
			}
			
			if (pageSize == 0) pageSize =10;
			
			String incUrl = INC_END_JSP + "?id="+getId() + "&gridVar=" + getGridVar() + "&initFn=" + getInitFn()+"&gridEvent="+gridEvent+"&pageSize="+pageSize;
			pageContext.include(incUrl);
			return EVAL_PAGE;
		}catch(IOException ioe) {
			return EVAL_PAGE;
		} catch (ServletException e) {
			return EVAL_PAGE;
		}
	}


}	