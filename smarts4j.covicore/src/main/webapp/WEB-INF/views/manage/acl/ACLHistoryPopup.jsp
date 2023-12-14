<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil, egovframework.baseframework.util.SessionHelper, egovframework.coviframework.util.StringUtil"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	String allowedACL = StringUtil.replaceNull(request.getParameter("allowedACL"), "SCDMEVR");
	String[] aclShard = allowedACL.split("(?!^)");
	
	String securityDisplay = "display:true";
	String createDisplay = "display:true";
	String deleteDisplay = "display:true";
	String modifyDisplay = "display:true";
	String executeDisplay = "display:true";
	String viewDisplay = "display:true";
	String readDisplay = "display:true";
	
	if(aclShard[0].equals("_")) {
		securityDisplay = "display:false";
	}
	
	if(aclShard[1].equals("_")) {
		createDisplay = "display:false";
	}
	
	if(aclShard[2].equals("_")) {
		deleteDisplay = "display:false";
	}
	
	if(aclShard[3].equals("_")) {
		modifyDisplay = "display:false";
	}
	
	if(aclShard[4].equals("_")) {
		executeDisplay = "display:false";
	}
	
	if(aclShard[5].equals("_")) {
		viewDisplay = "display:false";
	}
	
	if(aclShard[6].equals("_")) {
		readDisplay = "display:false";
	}	
%>
<style type="text/css">
div.auth_change {
	margin-top: 3px;
}

span.auth_allow {
	display: inline-block;
	width: 20px;
	height: 16px;
	background: url("<%=cssPath%>/contentsApp/resources/images/ic_auth_yes.png") no-repeat center;
}

span.auth_deny {
	display: inline-block;
	width: 20px;
	height: 16px;
	background: url("<%=cssPath%>/contentsApp/resources/images/ic_auth_no.png") no-repeat center;
}

span.inherited_label {
	display: inline-block; 
	background: #fff; 
	border: 1px solid #f56868; 
	border-radius: 3px; 
	color: #f56868;
	height: 19px; 
	line-height: 17px; 
	font-size: 12px; 
	width: auto; 
	text-indent: 0;
}

span.indenter {
	display: inline-block;
	width: 5px;
	height: 9px;
	margin: 3px 2px 3px 2px;
	background: url("<%=cssPath%>/covicore/resources/images/common/bul_arrow_13.png") no-repeat center;
}
</style>
<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" property="">
	<div class="divpop_contents">
		<div class="popContent layerType02 boardReadingList">
			<div>
				<div class="middle" style="margin-top:11px;">
					<div class="tblList tblCont">					
						<div id="messageGrid"></div>			
					</div>
				</div>
				<div class="bottom">
					<div class="popBottom">
						<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code='Cache.btn_Close'/></a>	<!-- 닫기 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var objectID = (CFN_GetQueryString("objectID") == 'undefined' ? "" : CFN_GetQueryString("objectID"));
var objectType = (CFN_GetQueryString("objectType") == 'undefined' ? "" : CFN_GetQueryString("objectType"));

$(document).ready(function (){
	var messageGrid = new coviGrid();
	messageGrid.config.fitToWidthRightMargin=0;
	
	var headerData = [
		{key:'LogChangeID',			label:'LogChangeID', 	align:'center', display:false, hideFilter : 'Y'},
		{key:'RegistDateDate',  	label:"<spring:message code='Cache.lbl_apv_chgdate' />" + Common.getSession("UR_TimeZoneDisplay"), 	width:'3', 		align:'center',
			formatter:function(){
				return CFN_TransLocalTime(this.item.RegistDateDate);
			}
		},
		{key:'ChangeType',			label:"<spring:message code='Cache.lbl_type' />", 			width:'1', 		align:'center',
			formatter:function(){
				var str = "";
     			if(this.item.ChangeType == "Insert") {
     				str = Common.getDic("lbl_Add");
     			} else if(this.item.ChangeType == "Update") {
     				str = Common.getDic("lbl_change");
     			} else if(this.item.ChangeType == "Delete") {
     				str = Common.getDic("lbl_delete");
     			}
     			return str;
     		}
		},		
		{key:'SubjectName',  		label:"<spring:message code='Cache.lbl_name' />", 		width:'2', 		align:'center'},
		{key:'SubjectType',  		label:"<spring:message code='Cache.lbl_Gubun' />", 		width:'1', 		align:'center',
			formatter:function(){
				switch (this.item.SubjectType.toUpperCase()) {		
				case "UR":
					return Common.getDic("lbl_User");
				default:
					return Common.getDic("lbl_group");
				}
     		}
		},
		{key:'InheritedObjectID',  	label:"<spring:message code='Cache.lbl_Inherited' />", 		width:'2', 		align:'center',
			formatter:function(){
				var returnIcon = "<div>" + this.item.InheritedObjectID.replace("N", "<span class='inherited_label'>"+Common.getDic("lbl_NoInherited")+"</span>").replace("Y", "<span class='inherited_label'>"+Common.getDic("lbl_Inherited")+"</span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Security', 			label:"<spring:message code='Cache.lbl_ACL_Security' />", 	width:'1', 		<%=securityDisplay%>,	align:'center',		
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Security.replace("_", "<span class='auth_deny'></span>").replace("S", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Create', 				label:"<spring:message code='Cache.lbl_ACL_Generation' />", width:'1', 		<%=createDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Create.replace("_", "<span class='auth_deny'></span>").replace("C", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Delete', 				label:"<spring:message code='Cache.lbl_ACL_Delete' />", 	width:'1', 		<%=deleteDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Delete.replace("_", "<span class='auth_deny'></span>").replace("D", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Modify', 				label:"<spring:message code='Cache.lbl_ACL_Edit' />", 		width:'1', 		<%=modifyDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Modify.replace("_", "<span class='auth_deny'></span>").replace("M", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Execute', 			label:"<spring:message code='Cache.lbl_ACL_Execute' />", 	width:'1', 		<%=executeDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Execute.replace("_", "<span class='auth_deny'></span>").replace("E", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'View', 				label:"<spring:message code='Cache.lbl_ACL_Views' />", 		width:'1', 		<%=viewDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.View.replace("_", "<span class='auth_deny'></span>").replace("V", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'Read', 				label:"<spring:message code='Cache.lbl_ACL_Read' />", 		width:'1', 		<%=readDisplay%>,	align:'center',
			formatter:function(){
				var returnIcon = "<div class='auth_change'>" + this.item.Read.replace("_", "<span class='auth_deny'></span>").replace("R", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
     			return returnIcon;
     		}
		},
		{key:'IsSubInclude',  		label:"<spring:message code='Cache.lbl_SubInclude' />", 	width:'1', 		align:'center',
			formatter:function(){
				var returnIcon = "";
				if(this.item.SubjectType.toUpperCase() != "UR") {
					returnIcon = "<div class='auth_change'>" + this.item.IsSubInclude.replace("N", "<span class='auth_deny'></span>").replace("Y", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
				}
     			return returnIcon;
     		}
		},
		{key:'RegisterName',  		label:"<spring:message code='Cache.lbl_apv_chgname' />", 	width:'2', 		align:'center'},
		{key:'RegisterDeptName',	label:"<spring:message code='Cache.lbl_dept' />", 			width:'1', 		align:'center',		display:false, 		hideFilter : 'Y'},
	];
	
	messageGrid.setGridHeader(headerData);
	
	var configObj = {
		targetID : "messageGrid",
		listCountMSG:"<b>{listCount}</b> " + Common.getDic("lbl_Count"), 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize: 10
		},
		paging : true,
		colHead:{},
		body:{}
	};
		
	messageGrid.setGridConfig(configObj);
		
	var searchParam = {
		"ObjectID": objectID,
		"ObjectType": objectType
	}
	
	messageGrid.bindGrid({
		ajaxUrl:"/covicore/log/getACLChangeLogList.do",
		ajaxPars: searchParam,
	});	
});

//하단의 닫기 버튼 함수
function closeLayer(){
	Common.Close();
}
</script>