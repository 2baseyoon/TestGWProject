<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
<%
String onlyMyDept = "N";
if (request.getParameter("authType") == null ||  "USER".equals(request.getParameter("authType"))){
out.println(".appTree{display:none}.arrowBtn{left: 277px;}");
}
if ("DEVISION".equals(request.getParameter("authType"))){
	onlyMyDept = "Y";
}
%>
</style>
<script>

	
	var openerID = CFN_GetQueryString("openerID");
	var callBackFunc = CFN_GetQueryString("callBackFunc");
	var type = CFN_GetQueryString("type") ;
	var treeKind = CFN_GetQueryString("treeKind") ;
	var allCompany = CFN_GetQueryString("allCompany");
	var setParamData = CFN_GetQueryString("setParamData") ;
	var bizcardKind = CFN_GetQueryString("bizcardKind");
	
	$(document).ready(function(){
		init();
		//$(".groupTreeDiv").hide();
	});

	function init(){
		var config ={
				targetID: 'orgChart',
				drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
				type: type,
				treeKind: treeKind,
				allCompany: allCompany,
				callbackFunc: callBackFunc,
				openerID: openerID,
				bizcardKind: bizcardKind,
				onlyMyDept:"<%=onlyMyDept%>"
		};
		coviOrg.render(config);
		
		if(setParamData != 'undefined' ){
	    	if(openerID != 'undefined' && openerID != ''){
	    		coviDic.setParamData(new Function ("return "+ coviCmn.getParentFrame( openerID )+setParamData +"()").apply());
	    	}else if(parent[setParamData] != undefined){
				coviOrg.setParamData(parent[setParamData]);
			}else if(opener[setParamData] != undefined){
				coviOrg.setParamData(opener[setParamData]);
			}
		}
	}	
	
</script>

<div id="orgChart" >
</div>