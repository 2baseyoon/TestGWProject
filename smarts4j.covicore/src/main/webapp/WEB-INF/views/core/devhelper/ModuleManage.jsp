<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">모듈권한관리</span>
</h3>
<form id="form1">

	<%-- Tab page 구성 --%>
	<div class="AXTabs">
		<div id="divTabTray" class="AXTabsTray" style="height:30px">
			<a id="tabMenu02" href="#" onclick="clickTab(this);" class="AXTab on" value="tabMenu02">module</a>
			<a id="tabMenu03" href="#" onclick="clickTab(this);" class="AXTab" value="tabMenu03">program</a>
			<a id="tabMenu04" href="#" onclick="clickTab(this);" class="AXTab" value="tabMenu04">program_map</a>
			<a id="tabMenu05" href="#" onclick="clickTab(this);" class="AXTab" value="tabMenu05">program_menu</a>
			<input type="button" class="AXButton" onclick="reloadCache(); return false;" value="URL 감시 초기화" style="float: right;"/>
		</div>
	</div>
	<br/>

	<div id="divCnts">
		<table class="AXFormTable">
			<colgroup>
				<col width="16%"/>
				<col width="16%"/>
				<col width="16%"/>
				<col width="16%"/>
				<col width="16%"/>
				<col width="16%"/>
			</colgroup>
			<tr id="sttstc01">
				<th>URL</th><td id="sttstcUrl"></td>
				<th>AuditClass</th><td id="sttstcAuditClass"></td>
				<th>AuditMethod</th><td id="sttstcAuditMethod"></td>
			</tr>
		</table>
	</div>

	<%-- search & buttons --%>
	<div id="divTabContent00">
		<input type="button" id="btnAdd" value="<spring:message code='Cache.btn_Add'/>" onclick="fnBtnAdd();" class="AXButton BtnAdd" />	<!-- 추가 -->
		<input type="button" id="btnDelete" value="<spring:message code="Cache.btn_delete"/>" onclick="fnBtnDel();"class="AXButton BtnDelete"/> <!-- 삭제 -->
		<select id="searchType" class="AXSelect W100">
			<option value="URL">URL</option>
			<option value="ModuleName">ModuleName</option>
			<option value="AuditMethod">AuditMethod</option>
			<option value="AuditClass">AuditClass</option>
			<option value="BizSection">BizSection</option>
			<option value="MenuName">MenuName</option>
		</select>
		<input type="text" id="searchText" class="AXInput" onkeypress="if (event.keyCode==13){ getGridData(); return false;}" />&nbsp;
		<input type="button" value="<spring:message code='Cache.btn_search'/>" onclick="javascript:getGridData();" class="AXButton" />
	</div>

	<%-- div for Tab Contents. --%>
	<div id="tabContent02" class="topbar_grid"></div>

	<div id="tabContent03" class="topbar_grid"></div>
	
	<div id="tabContent04" class="topbar_grid"></div>

	<div id="tabContent05" class="topbar_grid"></div>
	
</form>

<script type="text/javascript">
//# sourceURL=ModuleManage.jsp


var myGrid;

var paramTabType;

initContent();
	
function initContent(){
	
	$(".topbar_grid").hide();

	$("#divTabContent00").show(); // 공통 버튼들 보여주기.
	
	// active된 탭의 value값을 가지고 온다.
	paramTabType = $(".AXTab.on")[0];
	paramTabType = paramTabType.getAttribute("value")
	
	setDisplayTab(paramTabType);	// 탭별 화면 세팅.
}

// Tab별 Grid 데이터 표시.
function getGridData() {
	myGrid = new coviGrid();
	var pType = $(".AXTab.on")[0].getAttribute("value");
	setGrid(pType);  		// 테이블 데이터 config 세팅.
	bindGrid(pType); 		// 테이블 데이터 loading & bind.
}

function setDisplayTab(pTabType) { 	// 탭설정에 따른 show/hide.
	
	var tmpStr = pTabType.substr("tabMenu".length, 2);
	var option = "";
	
	if (pTabType === "tabMenu02") { 	// module 탭
		// selectBox 값 세팅.
		$("#searchType option").remove();
		option = $('<option value="ModuleID">ModuleID</option><option value="ModuleName">ModuleName</option>'
				+ '<option value="AuditMethod">AuditMethod</option><option value="AuditClass">AuditClass</option>'
				+ '<option value="URL">URL</option><option value="BizSection">BizSection</option>');
		$("#searchType").append(option);
	
		$('#sttstc01').hide();
		$('#btnAdd').show();
		$("#btnDelete").show();
	} else if (pTabType === "tabMenu03") { 	// program 탭
		// selectBox 값 세팅.
		$("#searchType option").remove();
		option = $('<option value="PrgmID">PrmgID</option><option value="PrgmName">PrgmName</option>');
		$("#searchType").append(option);
	
		$('#sttstc01').hide();
		$('#btnAdd').show();
		$("#btnDelete").show();
	} else if (pTabType === "tabMenu04") { 	// program_map 탭
		// selectBox 값 세팅.
		$("#searchType option").remove();
		option = $('<option value="PrgmID">PrmgID</option><option value="ModuleID">ModuleID</option>');
		$("#searchType").append(option);
	
		$('#sttstc01').hide();
		$('#btnAdd').show();
		$("#btnDelete").show();
	} else if (pTabType === "tabMenu05") { 	// program_menu 탭
		// selectBox 값 세팅.
		$("#searchType option").remove();
		option = $('<option value="MenuName">MenuName</option><option value="MenuID">MenuID</option><option value="PrgmID">PrgmID</option>');
		$("#searchType").append(option);
		
		$('#sttstc01').hide();
		$('#btnAdd').show();
		$("#btnDelete").show();
	}
	
	$("#tabContent" + tmpStr).show(); 	// contents.
	
	getGridData();		// grid 데이터 조회.
	
}

// Grid Setting. types : moduelMenu, module, prgm, prgmMap, prgmMenu
function setGrid(type){
	if(type == undefined || type == null) { 	// type 값이 없을 땐 첫번째 탭의 내용을 보여줍니다.
		type = "tabMenu02";
	}
	
	if (type === "tabMenu02") { 		// 2nd tab (가칭:module)
		myGrid.setGridHeader([
			{key:'chk', label:'chk', width:'6', align:'center', formatter:'checkbox'}
			, {key:'ModuleID', label:'ModuleID (ModuleName)', width:'70', align:'center'
				, formatter:function() {
				var strModuleID = this.item.ModuleID;
				var strModuleName = this.item.ModuleName;
				if (strModuleID === "") { strModuleID = "-"; }
				if (strModuleName === "") { strModuleName = "-"; }
				return "<a href='#' onclick='fnViewDetail(\""+this.item.ModuleID+"\")'>"+strModuleID+"<br/>("+strModuleName+")</a>";
			}}
			, {key:'AuditMethod', label:'AuditMethod (AuditClass)', width:'70', align:'center', formatter:function() {
				var strAuditMethod = this.item.AuditMethod;
				var strAuditClass = this.item.AuditClass;
				if (strAuditMethod === "") { strAuditMethod = "-"; }
				if (strAuditClass === "") { strAuditClass = "-"; }
				return strAuditMethod+"<br/>("+strAuditClass+")";
			}}
			, {key:'URL', label:'URL (BizSection)', width:'70', align:'center', formatter:function() {
				return this.item.URL+"<br/>("+this.item.BizSection+")";
				}
			}
			, {key:'IsUse'
				, label: "<input type='button' value='IsUse' onclick='updateAllStatus(\"" + "IsUse" + "\");' class='AXButton BtnRefresh' />"
				, width:'20', align:'center'
				, formatter:function() {
				return "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+ this.item.ModuleID +"\", \""+this.item.IsUse+"\")' />";
			}}
			, {key:'IsAdmin'
				, label: "<input type='button' value='IsAdmin' onclick='updateAllStatus(\"" + "IsAdmin" + "\");' class='AXButton BtnRefresh' />"
				, width:'23', align:'center'
				, formatter:function() {
				return "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsAdmin+"' onchange='updateIsAdmin(\""+this.item.ModuleID+"\", \""+this.item.IsAdmin+"\")' />";
			}}
			, {key:'IsAudit'
				, label: "<input type='button' value='IsAudit' onclick='updateAllStatus(\"" + "IsAudit" + "\");' class='AXButton BtnRefresh' />"
				, width:'26', align:'center', formatter:function() {
				return "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsAudit+"' onchange='updateIsAudit(\""+this.item.ModuleID+"\", \""+this.item.IsAudit+"\")' />";
			}}
		]);
	} else if (type === "tabMenu03") { 		// 3rd tab (가칭:program)
		myGrid.setGridHeader([
			{key:'chk', label:'chk', width:'6', align:'center', formatter:'checkbox'}
			, {key:'PrgmID', label:'PrgmID', width:'70', align:'center', formatter:function() {
				return "<a href='#' onclick='fnViewDetail(\""+this.item.PrgmID+"\")'>"+this.item.PrgmID+"</a>";
			}}
			, {key:'PrgmName', label:'PrgmName', width:'70', align:'center'}
			, {key:'ModifierCode', label:'<spring:message code="Cache.lbl_Modifier"/>', width:'30', align:'center'}
			, {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.ModifyDate);
				}
			}
			, {key:'RegisterCode', label:'<spring:message code="Cache.lbl_Register"/>', width:'30', align:'center'}
			, {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}	
			}
		]);
	} else if (type === "tabMenu04") { 		// 4th tab (가칭:program_map)
		myGrid.setGridHeader([
			{key:'chk', label:'chk', width:'6', align:'center', formatter:'checkbox'}
			, {key:'PrgmID', label:'PrgmID', width:'70', align:'center'}
			, {key:'ModuleID', label:'ModuleID', width:'70', align:'center'}
			, {key:'ModifierCode', label:'<spring:message code="Cache.lbl_Modifier"/>', width:'30', align:'center'}
			, {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.ModifyDate);
				}	
			}
			, {key:'RegisterCode', label:'<spring:message code="Cache.lbl_Register"/>', width:'30', align:'center'}
			, {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}	
			}
		]);
	} else if (type === "tabMenu05") { 		// 5th tab (가칭:program_menu)
		myGrid.setGridHeader([
			{key:'chk', label:'chk', width:'6', align:'center', formatter:'checkbox'}
			, {key:'MenuName', label:'MenuName', width:'50', align:'center', formatter:function() {
				return "<a href='#' onclick='fnViewDetail(\""+this.item.MenuID+"\")'>"+this.item.MenuName+"</a>";
			}}
			, {key:'MenuID', label:'MenuID', width:'20', align:'center', formatter:function() {
				return "<a href='#' onclick='fnViewDetail(\""+this.item.MenuID+"\")'>"+this.item.MenuID+"</a>";
			}}
			, {key:'PrgmID', label:'PrgmID', width:'50', align:'center'}
			, {key:'ModifierCode', label:'<spring:message code="Cache.lbl_Modifier"/>', width:'30', align:'center'}
			, {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.ModifyDate);
				}	
			}
			, {key:'RegisterCode', label:'<spring:message code="Cache.lbl_Register"/>', width:'30', align:'center'}
			, {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center',
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}	
			}
		]);
	}
	
	fnSetGridConfig(type);
}

function fnSetGridConfig(type){
	
	var targetTabID = "";
	
	if (type === "tabMenu02") {
		targetTabID = "tabContent02";
	} else if (type === "tabMenu03" ) {
		targetTabID = "tabContent03";
	} else if (type === "tabMenu04" ) {
		targetTabID = "tabContent04";
	} else if (type === "tabMenu05" ) {
		targetTabID = "tabContent05";
	} else {
		return;
	}
	
	var configObj = {
			targetID : targetTabID,
			height:"auto",
			xscroll:true,
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort: false
		};
	
	myGrid.setGridConfig(configObj);
}

function bindGrid(type) {
	
	if(type === undefined || type === null) { 	// 지정된 값이 없다면, 활성화된 탭의 값을 가져오고, 첫번째 메뉴를 보여주기.
		type = ($(".AXTab.on").attr("value") != '') ? $(".AXTab.on").attr("value") : "tabMenu02";
	}
	
	var url = "";
	
	if (type === "tabMenu02") {
		url = "/covicore/devhelper/getModuleDataList.do";
	} else if (type === "tabMenu03") {
		url = "/covicore/devhelper/getPrgmDataList.do";
	} else if (type === "tabMenu04") {
		url = "/covicore/devhelper/getPrgmMapDataList.do";
	} else if (type === "tabMenu05") {
		url = "/covicore/devhelper/getPrgmMenuDataList.do";
	} else {
		return;
	}
	
	var params = {
		"searchType" : $('#searchType').val()
		, "searchText" : $('#searchText').val()
	}
	
	myGrid.bindGrid({
		ajaxUrl:url
		, ajaxPars:params
		, objectName: 'myGrid'
		, callbackName: 'bindGrid'
	});
	
}

// 탭 클릭 이벤트.
function clickTab(pObj){
	
	$("#divTabTray .AXTab").attr("class","AXTab");
	$(pObj).addClass("AXTab on");

	var str = $(pObj).attr("value");
	str = str.substr("tabMenu".length, 2);
	
	$(".topbar_grid").hide();
	$("#tabContent" + str).show();
	
	$("#searchText").val("");	// 검색 키워드 초기화.
	
	// 탭별 화면 세팅.
	setDisplayTab($(pObj).attr("value"));
}

// IsUse, on/off 클릭 이벤트.
function updateIsUse(pModuleID, pIsUse) {
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/updateModuleIsUse.do"
		, data : { "ModuleID":pModuleID , "IsUse": pIsUse}
		, success : function(data){
			if(data.status == "SUCCESS"){
				parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
				getGridData();
			} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

function updateIsAdmin(pModuleID, pIsAdmin) {
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/updateModuleIsAdmin.do"
		, data : { "ModuleID":pModuleID , "IsAdmin": pIsAdmin}
		, success : function(data){
			if(data.status == "SUCCESS"){
				parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
				getGridData();
			} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

// IsAudit, on/off 클릭 이벤트.
function updateIsAudit(pModuleID, pIsAudit) {
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/updateModuleIsAudit.do"
		, data : { "ModuleID":pModuleID , "IsAudit": pIsAudit}
		, success : function(data){
			if(data.status == "SUCCESS"){
				parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
				getGridData();
			} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

function updateAllStatus(pUrlType) {
	// 체크 데이터 여부 확인.
	if (myGrid.getCheckedList(0).length == 0) {
		Common.Inform("<spring:message code='Cache.lbl_Mail_NoSelectItem'/>"); 	// 선택된 항목이 없습니다.
		return;
	}
	
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/updateAllStatus.do"
		, contentType : "application/json"
		, data : JSON.stringify({"dataList" : myGrid.getCheckedList(0), "pType": pUrlType })// myGrid.getCheckedList(0) : 체크된 myGrid 데이터.
		, success : function(data){
			if(data.status == "SUCCESS"){
				parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
				getGridData();
			} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

// 추가 버튼 클릭 이벤트.
function fnBtnAdd() {
	var pType = $(".AXTab.on")[0].getAttribute("value");	// 어느 탭에서 추가버튼을 눌렀는지 확인.
	var sOpenName = "";
	var sTitle = "";
	var sURL = "";
	var sWidth = "870px"; 	// 기본값.
	var sHeight = "560px"; 	// 기본값.
	
	sOpenName = "divModuleAttr";
	sTitle = "추가";
	sURL = "/covicore/devhelper/modulemanagepop.do?popuptype=add";
	sWidth = "870px";
	sHeight = "560px";
		
	Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
}

// 삭제 버튼 클릭 이벤트.
function fnBtnDel() {
	
	var pType = $(".AXTab.on")[0].getAttribute("value");	// 어느 탭에서 버튼을 눌렀는지 확인.
	
	if (myGrid.getCheckedList(0).length == 0) {
		Common.Inform("<spring:message code='Cache.lbl_Mail_NoSelectItem'/>"); 	// 선택된 항목이 없습니다.
		return;
	}
	
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/delModuleData.do"
		, contentType : "application/json"
		, data : JSON.stringify({"dataList" : myGrid.getCheckedList(0), "pType": pType })// myGrid.getCheckedList(0) : 체크된 myGrid 데이터.
		, success : function(data){
			if(data.status == "SUCCESS"){
				parent.Common.Inform("<spring:message code='Cache.lbl_delete'/>")	// 삭제
				getGridData();
			} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
	
}

// 상세보기 클릭 이벤트.
function fnViewDetail(pId) { 		// program_map 은 제외. 컬럼 모두 Unique.
	
	var pType = $(".AXTab.on")[0].getAttribute("value");	// 어느 탭에서 추가버튼을 눌렀는지 확인.
	var sOpenName = "";
	var sTitle = "";
	var sURL = "";
	var sWidth = "870px"; 	// 기본값.
	var sHeight = "600px";
	
	sOpenName = "divViewDetail";
	
	if (pType === "tabMenu02") { 	// module tab
		sTitle = "Module View";
		sURL = "/covicore/devhelper/modulemanagepop.do?popuptype=dtlmodule&pid="+pId;
	} else if (pType === "tabMenu03") { 	// 활성화 탭 : program
		sTitle = "Program View";
		sURL = "/covicore/devhelper/modulemanagepop.do?popuptype=dtlprgm&pid="+pId;
	} else if ( pType === "tabMenu05") { 	// 활성화 탭 : program_menu
		sTitle = "Program_Menu View";
		sURL = "/covicore/devhelper/modulemanagepop.do?popuptype=dtlprgmmenu&pid="+pId;
	}

	Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
}

// URL 감시 초기화.
function reloadCache(pCacheType) {
    var replication_mode = "";
	$.ajax({
        url:"/covicore/cache/reloadCache.do",
        type:"post",
        data:{
              "replicationFlag": replication_mode,         	// 빈값.
              "cacheType" : "AUDIT"
        },
        success: function (res) {
        	Common.Error(res.status);
        },
        error : function (error){
        	Common.Error(error);  
        }
  });
}
</script>