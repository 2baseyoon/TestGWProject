<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
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

#selSearchTarget, #selObjectType{
	border-radius: 0px;
	height: 22px;
	color: #717b85;
}
</style>
<h3 class="con_tit_box">
	<span class="con_tit">권한 변경 이력</span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh" />
			
			<input type="button" value="<spring:message code="Cache.btn_SaveToExcel"/>" onclick="ExcelSave();" class="AXButton BtnExcel" />
		</div>
		<div id="topitembar02" class="topbar_grid">
			<label><spring:message code="Cache.lbl_Domain"/></label>&nbsp;
			<select class="AXSelect" id="selectDomain"></select>
			<label style="margin-left: 10px;"><spring:message code="Cache.lblSearchScope"/></label>&nbsp; 
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
			
			<label style="margin-left: 10px;"><spring:message code="Cache.lbl_Gubun"/></label>&nbsp;
			<select id="selObjectType" class="AXSelect" onchange="setDate();"> <!-- 구분 타입 -->
				<option value="" selected=""><spring:message code="Cache.lbl_all"/></option> 구분 타입
				<option value="MN"><spring:message code="Cache.lbl_Menu"/></option>
				<option value="FD"><spring:message code="Cache.lbl_Folder"/></option>
			</select>
			
			<label style="margin-left: 10px;"><spring:message code="Cache.lbl_SearchTarget"/></label>&nbsp;
			<select id="selSearchTarget" class="AXSelect"> <!-- 검색 대상  -->
				<option value="" selected=""><spring:message code="Cache.lbl_all"/></option>
				<option value="target"><spring:message code="Cache.lbl_target"/></option>
				<option value="changer"><spring:message code="Cache.lbl_ChangerName"/></option>
			</select>
			<input type="text" id="deptusername" style="width:120px" class="AXInput"  onkeypress="if (event.keyCode==13){ searchLog(); return false;}" />
			<input type="button" value="<spring:message code="Cache.btn_OrgManage"/>" onclick="OrgMapLayerPopup();" class="AXButton"/>		
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchLog();" class="AXButton" class="AXInput" />
		</div>
		<div id="authChangeHistoryGrid"></div>
	</div>
</form>
<script type="text/javascript">
	
	var myGrid;
	var headerData;
	window.onload = initContent();
	
	function initContent(){
		headerData = [
			{key:'RegistDateDate',  	label:"<spring:message code='Cache.lbl_apv_chgdate' />" + Common.getSession("UR_TimeZoneDisplay"), 	width:'2.3', align:'center', sort:'desc', 
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
			{key:'ObjectType',  		label:"<spring:message code='Cache.lbl_Gubun' />", 		width:'1', 		align:'center',
				formatter:function(){
					switch (this.item.ObjectType.toUpperCase()) {		
					case "MENU":
						return Common.getDic("lbl_Menu");
					default:
						return Common.getDic("lbl_Folder");
					}
	     		}
			},
			{key:'ObjectName',  		label:"객체명", 		width:'3', 		align:'center'},
			{key:'SubjectName',  		label:"<spring:message code='Cache.lbl_target' />", 		width:'2', 		align:'center'},
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
			{key:'Security', 			label:"<spring:message code='Cache.lbl_ACL_Security' />", 	width:'1',	align:'center',		
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Security.replace("_", "<span class='auth_deny'></span>").replace("S", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'Create', 				label:"<spring:message code='Cache.lbl_ACL_Generation' />", width:'1', align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Create.replace("_", "<span class='auth_deny'></span>").replace("C", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'Delete', 				label:"<spring:message code='Cache.lbl_ACL_Delete' />", 	width:'1', align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Delete.replace("_", "<span class='auth_deny'></span>").replace("D", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'Modify', 				label:"<spring:message code='Cache.lbl_ACL_Edit' />", 		width:'1', align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Modify.replace("_", "<span class='auth_deny'></span>").replace("M", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'Execute', 			label:"<spring:message code='Cache.lbl_ACL_Execute' />", 	width:'1', 	align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Execute.replace("_", "<span class='auth_deny'></span>").replace("E", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'View', 				label:"<spring:message code='Cache.lbl_ACL_Views' />", 		width:'1', align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.View.replace("_", "<span class='auth_deny'></span>").replace("V", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'Read', 				label:"<spring:message code='Cache.lbl_ACL_Read' />", 		width:'1', align:'center',
				formatter:function(){
					var returnIcon = "<div class='auth_change'>" + this.item.Read.replace("_", "<span class='auth_deny'></span>").replace("R", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
	     			return returnIcon;
	     		}
			},
			{key:'IsSubInclude',  		label:"<spring:message code='Cache.lbl_SubInclude' />", 	width:'1.5', 		align:'center',
				formatter:function(){
					var returnIcon = "";
					if(this.item.SubjectType.toUpperCase() != "UR") {
						returnIcon = "<div class='auth_change'>" + this.item.IsSubInclude.replace("N", "<span class='auth_deny'></span>").replace("Y", "<span class='auth_allow'></span>").replace("|", "<span class='indenter'></span>") + "</div>";
					}
	     			return returnIcon;
	     		}
			},
			{key:'RegisterName',  		label:"<spring:message code='Cache.lbl_apv_chgname' />", 	width:'2.3', 		align:'center'}
		];
		
		myGrid = new coviGrid();
		
		setGrid();
		setDateTypeSelect();
		setTimeout(function(){setDate();}, 10);
	};
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "authChangeHistoryGrid",
			height: "auto",
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function setDate(){
		var date_str = $("#searchDateType option:selected").val();
		
		var thisyear = new Date();
		var startdate = "";
		var enddate = "";
		
		if(date_str == "Today"){
			startdate = XFN_getCurrDate("-", "dash");
		} else if(date_str == "Yesterday"){
			startdate = XFN_addMinusDateByCurrDate(-1, "-", "dash");
		} else if(date_str == "BeforeYesterday"){
			startdate = XFN_addMinusDateByCurrDate(-2, "-", "dash");
		} else if(date_str == "AWeek"){
			startdate = XFN_addMinusDateByCurrDate(-6, "-", "dash");
		} else if(date_str == "AMonth"){
			startdate = XFN_addMinusDateByCurrDate(-30, "-", "dash");
		} else if(date_str == "TwoMonth") {
			startdate = XFN_addMinusDateByCurrDate(-61, "-", "dash");
		} else if(date_str == "ThisYear"){
			thisyear.setMonth(0);	
			thisyear.setDate(1);
			startdate = thisyear.getFullYear() + "-" + (thisyear.getMonth()+1 < 10 ? "0"+(thisyear.getMonth()+1) : thisyear.getMonth()+1) + "-" +(thisyear.getDate() < 10 ? "0"+thisyear.getDate() : thisyear.getDate());					// XFN_TransDateLocalFormat(< % = _strThisYear % > + ".01.01");
			enddate = thisyear.getFullYear() + "-12-31"; 
		}
		
		if(enddate == ""){
			enddate = XFN_getCurrDate("-", "dash");
		}
		
		document.getElementById("startdate").value = startdate;
		document.getElementById("enddate").value = enddate;
		
		searchLog();
	}
	
	function searchLog(){
		
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var text = $("#deptusername").val();

		if((enddate.split("-")[0] - strdate.split("-")[0]) > 2){
			dateVali = false;
		}else if((enddate.split("-")[0] - strdate.split("-")[0]) == 2){
			if(enddate.split("-")[1] > strdate.split("-")[1]){
				dateVali = false;
			}else if(enddate.split("-")[1] == strdate.split("-")[1] && enddate.split("-")[2] > strdate.split("-")[2]){
				dateVali = false;
			}
		}
		
		if(!dateVali){
			Common.Inform("<spring:message code='Cache.msg_CanSelectTwoYearAgo'/>", "Information Dialog", function(result) {
				$("#startdate").val(XFN_getCurrDate("-", "dash"));
				$("#enddate").val(XFN_getCurrDate("-", "dash"));
				
				strdate = $("#startdate").val();
				enddate = $("#enddate").val();
			});			
			
			return false;
		}
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/log/getauthchangehistorylist.do",
 			ajaxPars: {
 				"startdate":strdate,
 				"enddate":enddate,
 				"searchtext":text,
 				"companyCode":$("#selectDomain").val(),
 				"objectType":$("#selObjectType").val(),
 				"searchTarget":$("#selSearchTarget").val()
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
			,objectName: 'myGrid'
			,callbackName: 'searchLog'
		});
	}
	
	function ExcelSave(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var strdate = $("#startdate").val();
    			var enddate = $("#enddate").val();
    			var text = $("#deptusername").val();
    			var domain = $("#selectDomain").val();
    			var objectType = $("#selObjectType").val();
    			var searchTarget = $("#selSearchTarget").val();
    			
    			var headername = getHeaderNameForExcel();
    			var headerType = getHeaderTypeForExcel();
    			var sortKey = myGrid.getSortParam("one").split("=")[1].split(" ")[0];
    			var sortWay = myGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			
    			if(strdate == ""){
    				strdate = $("#enddate").attr("minDate");
    			}
    			if(enddate == ""){
    				enddate = $("#enddate").attr("maxDate");
    			}
    			
    			location.href = "/covicore/authchangehistoryexceldownload.do?startdate=" + strdate + "&enddate="+ enddate + "&searchtext="+ text +"&companyCode="+domain+"&objectType="+objectType+"&searchTarget="+searchTarget+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType);
       		}
		});
	}
	
	function Refresh(){
		location.reload();
	}
	
	function OrgMapLayerPopup(){
		Common.open("","orgchart_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=D1","1040px", "580px", "iframe", true, null, null,true);
	}
	
	// 조직도 데이터	
	
	function _CallBackMethod2(data){
		var dataObj = $.parseJSON(data);
		if(dataObj.item.length > 0){
			var searchData = CFN_GetDicInfo(dataObj.item[0].DN);
			$("#deptusername").val(searchData);
		}
		
		searchLog();
	}
	
	function setDateTypeSelect(){
		$("#searchDateType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"<spring:message code='Cache.btn_Today'/>", "value":"Today"},
                       {"name":"<spring:message code='Cache.btn_Yesterday'/>", "value":"Yesterday"},
                       {"name":"<spring:message code='Cache.btn_BeforeYesterday'/>", "value":"BeforeYesterday"},
                       {"name":"<spring:message code='Cache.btn_AWeek'/>", "value":"AWeek"},
                       {"name":"<spring:message code='Cache.btn_AMonth'/>", "value":"AMonth"},
                       {"name":"<spring:message code='Cache.btn_TwoMonth'/>", "value":"TwoMonth"},
                       {"name":"<spring:message code='Cache.btn_AYear'/>", "value":"ThisYear"}]
        });
		coviCtrl.renderCompanyAXSelect('selectDomain', 'ko', true, 'searchLog', '', '');

	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		for(var i=0;i<headerData.length; i++){
			returnStr += headerData[i].label + ";";
		}
		
		return returnStr;
	}
	function getHeaderTypeForExcel(){
		var returnStr = "";

	   	for(var i=0;i<headerData.length; i++){
			returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
		}
		return returnStr;
	}
	
</script>

