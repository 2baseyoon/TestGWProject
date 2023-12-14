<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<style>
/*
.table1_12 table {
	margin:15px 0
}
.table1_12 th {
	background-color:#F8F8FF;
	color:black;
}
.table1_12,.table1_12 th,.table1_12 td
{
	font-size:0.95em;
	text-align:left;
	padding:2px;
	border:1px solid #dddddd;
	border-collapse:collapse;
}
*/
a { cursor : pointer; }
.layer_divpop .divpop_body {
	padding:0px;
}
#ErrorStackTrace_container .divpop_body textarea {
	margin:0;
	outline:none;
	border:none;
	font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left
}
* {
	box-sizing : border-box;
}
</style>
<h3 class="con_tit_box">
	<span class="con_tit">연동시스템 로그</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>												
			<select class="AXInput selectType02 w120p" name="searchMode" id="searchMode" onchange="searchConfig()">
					<option value="LEGACY" ><spring:message code="Cache.lbl_apv_legacyIf"/></option>
					<option value="DISTRIBUTION" ><spring:message code="Cache.lbl_apv_distribution"/></option>
					<option value="MESSAGE" ><spring:message code="Cache.lbl_apv_setMessaging"/></option>	
			</select>
			<select class="AXInput selectType02 w120p" name="searchState" id="searchState" onchange="searchConfig()">
					<option value=""><spring:message code="Cache.lbl_Whole"/></option><!-- 전체  -->
					<option value="error" selected><spring:message code="Cache.lbl_apv_legacyError"/></option>
					<option value="start"><spring:message code="Cache.lbl_apv_legacyStart"/></option>
					<option value="complete"><spring:message code="Cache.lbl_apv_legacyComplete"/></option>
			</select>
			<select class="AXInput selectType02" id="selectSearchType" onChange="fn_searchType();">
					<option value="" selected><spring:message code="Cache.lbl_apv_searchcomment"/></option>
					<option value="FormName"><spring:message code="Cache.lbl_FormNm"/></option>
					<option value="Subject"><spring:message code="Cache.lbl_subject"/></option>
					<option value="InitiatorName"><spring:message code="Cache.lbl_apv_writer"/></option>
					<option value="DocNumber"><spring:message code="Cache.lbl_DocNo"/></option>
					<option value="FormInstID">FORM_INST_ID</option>
			</select>
			<input type="text" class="AXInput" id="searchInput" onKeyPress="if (event.keyCode == 13) {searchConfig(1);}" disabled="disabled">
			&nbsp;&nbsp;&nbsp;&nbsp;			
			발생시간			
			<input class="AXInput" id="startdate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate">
		   	    ~ 				   	   
			<input class="AXInput" id="enddate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
		</div>
		<div id="divGrid"></div>
	</div>
</form>
<script type="text/javascript">

	var myGrid = new coviGrid();
	setGrid();			// 그리드 세팅
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
						  {key:'LegacyID', label:'<spring:message code="Cache.lbl_apv_no"/>', width:'90', align:'center', sort:"desc"},
						  {key:'Process', label:'<spring:message code="Cache.lbl_process"/>', width:'60', align:'center',  sort: false, 
						   	  formatter:function () {
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessID+"\", "+( (this.item.ProcessState == "528") ? "true" : "false")+", \"" + this.item.DocNumber + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
							   }
			              },
		                  {key:'ApvMode',  label:'<spring:message code="Cache.lbl_apv_legacyType"/>', width:'100', align:'center', 
							  formatter : function() {
								  switch(this.item.ApvMode) {
									  case "DRAFT" : return '<spring:message code="Cache.lbl_apv_setschema_94"/>';
									  case "COMPLETE" : return'<spring:message code="Cache.lbl_apv_setschema_95"/>';
									  case "OTHERSYSTEM" : return '<spring:message code="Cache.lbl_apv_setschema_121"/>'; // 진행중 연동
									  case "DISTCOMPLETE" : return '<spring:message code="Cache.lbl_apv_setschema_141"/>';
									  case "CHARGEDEPT" : return '<spring:message code="Cache.lbl_apv_setschema_97"/>';
									  //case "SUBREJECT" : return "부서협조반려";
									  //case "SUBCOMPLETE" : return "부서협조완료";
									  case "WITHDRAW" : return '<spring:message code="Cache.bl_apv_setschema_121"/>';
									  case "REJECT" : return '<spring:message code="Cache.lbl_apv_setschema_96"/>';
									  default : return this.itemApvMode;
								  }
						  }},
		                  {key:'State',  label:'<spring:message code="Cache.lbl_apv_legacyEventType"/>', width:'100', align:'center', 
							  formatter : function() {
								  switch(this.item.State) {
									  case "error" : return '<a style="color:red;font-weight:bold;" class="txt_underline" title="<spring:message code="Cache.lbl_DetailView"/>" onclick="showErrorDetail(\'' + this.index + '\')"><spring:message code="Cache.lbl_apv_legacyError"/></a>';
									  case "start" : return '<spring:message code="Cache.lbl_apv_legacyStart"/>';
									  case "complete" : return '<spring:message code="Cache.lbl_apv_legacyComplete"/>';
									  default : return this.itemApvMode;
								  }
						  }},
						  {key:'FormInstID', label:'FormInstID', width:'90', align:'center'},
						  {key:'ProcessID', label:'ProcessID', width:'90', align:'center'},
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center',
							  formatter: function () { return CFN_GetDicInfo(this.item.FormName); }
						  },
						  {key:'Subject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'200', align:'left',
							  formatter:function () {
								if (this.item.ProcessID != "" && this.item.ProcessID != undefined){
						   			return "<a class='txt_underline' onclick='onClickPopButton(\""+this.item.ProcessID+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); '>"+this.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}else{
									return this.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
								}
							  }
						  },
						  {key:'InitiatorName', label:'<spring:message code="Cache.ApvType_initiator"/>', width:'90', align:'center',
							  formatter: function () { return CFN_GetDicInfo(this.item.InitiatorName); }
						  },
		                  {key:'DocNumber', label:'<spring:message code="Cache.lbl_apv_DocNo"/>', width:'100', align:'center'},
		                  {key:'EventTime',  label:'<spring:message code="Cache.lbl_EventDate"/>', width:'150', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.EventTime, "yyyy-MM-dd HH:mm:ss")}
		                  },
		                  // 재처리요청완료(시간)
						  {key:'LastRetryTime',  label:'<spring:message code="Cache.lbl_apv_retryTime"/>', width:'110', align:'center', sort:false,
		                	  	formatter:function(){return CFN_TransLocalTime(this.item.LastRetryTime, "yyyy-MM-dd HH:mm:ss")}
						  },
		                  // 재처리요청
						  {key:'Detail',  label:'<spring:message code="Cache.btn_apv_process"/>', width:'90', align:'center', sort:false,
                        	  formatter:function () {
                        		  if(this.item.State != "start"){
							   		  return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_DetailView'/>\" onclick=\"showDetail(" + this.index + "); return false;\">"; // 상세보기
                        		  }
						  }},
		                  {key:'Delete',  label:'<spring:message code="Cache.lbl_apv_delete"/>', width:'75', align:'center', sort:false,
                        	  formatter:function () {
							   		return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_apv_delete'/>\" onclick=\"deleteErrorLog(" + this.item.LegacyID + "); return false;\">";
						  }}
			      		];
		
		myGrid.setGridHeader(headerData);
		setSelect();
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "divGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// Select box 바인드 (회사)
	function setSelect(){
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",			
			ajaxAsync:false,
			onchange: function(){
				searchConfig();
			}
		});
		$("#search").bindSelect();
	}
	
	function showErrorDetail(index) {
   		var ErrorMessage = myGrid.list[index].ErrorStackTrace;
   		Common.open("","ErrorStackTrace", "ErrorStackTrace", "<textarea style='' readonly>"+ErrorMessage+"</textarea>", "900px","530px","html",true,null,null,true);
	}
	
	function showDetail(index) {
		var searchMode = myGrid.list[index].Mode;
		var LegacyID = myGrid.list[index].LegacyID;
		var searchState = myGrid.list[index].State;
		var LayerTitle = $("#searchMode option:checked").text() + ' <spring:message code="Cache.btn_apv_process"/> / [' + myGrid.list[index].Subject+']';
		Common.open("","OpenJsonEditPopup",LayerTitle,"/approval/admin/OpenJsonEditPopup.do?index="+index+"&searchMode="+searchMode+"&searchState="+searchState+"&pLegacyID="+LegacyID, "1024px", "800px", "iframe",true,null,null,true);
	}
	
	
	// 검색
	function searchConfig(flag){
		var searchMode = $("#searchMode").val();
		var searchState = $("#searchState").val();
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getLegacy.do",
				ajaxPars: {					
					"searchMode":searchMode,
					"searchState":searchState,
					"startDate":startdate,
					"endDate":enddate,
					"EntCode":$("#hidden_domain_val").val(),
					"icoSearch":$("#searchInputSimple").val(),
					"searchType":$("#selectSearchType").val(),
					"searchWord":$("#searchInput").val()
				},
				onLoad:function(){
				}
		});
	}	

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	function deleteErrorLog(legacyID) {
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (!result) return; // 삭제하시겠습니까??
		
			$.ajax({
				url:"/approval/admin/deleteLegacyErrorLog.do",
				type:"post",
				data: {
					"legacyID": legacyID
				},
				async:false,
				success:function (data) {
					if(data.status == 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							//myGrid.reloadList();
							searchConfig();
						});
	    			} else {
	    				Common.Error(data.message);
	    			}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteErrorLog.do", response, status, error);
				}
			});
		});
	}
	
	function onClickPopButton(ProcessID, forminstanceID, BusinessData1, BusinessData2){
		if(BusinessData1 == "ACCOUNT") {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&forminstanceID="+forminstanceID+"&ExpAppID="+BusinessData2, "", 790, (window.screen.height - 100), "resize");
		} else {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
		}
	}
	
	function ViewProcessListPop(fiid, piid, archived, DocNO){
		CFN_OpenWindow("/approval/admin/monitoring.do?FormInstID=" + fiid+"&ProcessID="+piid+"&archived="+archived+"&DocNO="+encodeURI(DocNO), "", 1360, (window.screen.height - 100), "both");
	}
	
	function fn_searchType(){
		if($("#selectSearchType").val() != ''){
			$("#searchInput").attr("disabled",false);
		}else{
			$("#searchInput").attr("disabled",true);
		}
	}
</script>
