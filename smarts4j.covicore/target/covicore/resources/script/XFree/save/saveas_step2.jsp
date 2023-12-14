
<%@ page pageEncoding = "UTF-8" contentType = "text/html; charset=UTF-8" %>
<%@ page import = "java.io.*,
                   java.util.*"
%>
<%!

	 private String cleanXSS(String val) {
		
		//val = val.replaceAll("<", "&lt;").replaceAll(">", "&gt;");		  
		val = val.replaceAll("\\(", "&#40;").replaceAll("\\)", "&#41;");		  
		val = val.replaceAll("'", "&#39;");        		  
		val = val.replaceAll("eval\\((.*)\\)", ""); 		  
		val = val.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");		  
		val = val.replaceAll("script", "");         
		  
		return val;
	}
	
	 
	public static String concatenate2(String arg1, String arg2) {
		
		String res = "";
			
		res = res.concat(arg1);
		res = res.concat(arg2);		
		
		return res;
	} 
	
	public static String concatenate3(String arg1, String arg2, String arg3) {
		
		String res = "";
			
		res = res.concat(arg1);
		res = res.concat(arg2);
		res = res.concat(arg3);
		
		return res;
	}
	
	
	public static String concatenate5(String arg1, String arg2, String arg3, String arg4, String arg5) {
		
		String res = "";
			
		res = res.concat(arg1);
		res = res.concat(arg2);
		res = res.concat(arg3);
		res = res.concat(arg4);
		res = res.concat(arg5);
		
		return res;
	}	 
	
%>
<%
	request.setCharacterEncoding("UTF-8");
	response.setContentType("text/html; charset=UTF-8");
	response.setHeader("Content-Disposition", "attachment; filename=Untitled.htm");

	out.clear();
	out = pageContext.pushBody();

	BufferedOutputStream outs = new BufferedOutputStream(response.getOutputStream());
	outs.write(0xEF);
	outs.write(0xBB);
	outs.write(0xBF);
	String sContent = request.getParameter("mime_contents");
	
	if(sContent != null && !sContent.equals("")) {
	
		sContent = cleanXSS(sContent);
	}
	
	
	outs.write(sContent.getBytes("UTF-8"), 0, sContent.getBytes("UTF-8").length);
	outs.flush(); 
	outs.close();
%>
