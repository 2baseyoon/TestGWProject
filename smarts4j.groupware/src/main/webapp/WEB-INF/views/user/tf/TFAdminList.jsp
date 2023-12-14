<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String kind = request.getParameter("kind");
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String searchWordStatus = request.getParameter("searchWordStatus");
	String searchTypeStatus = request.getParameter("searchTypeStatus");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
%>

<div class='cRConTop titType'>
	<h2 class="title"></h2>
	<div class="searchBox02">
		<span><input type="text" id="seValue"  onkeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}" /><button type="button" class="btnSearchType01" onclick="onClickSearchButton()"><spring:message code='Cache.lbl_search'/></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>
	</div>
</div>
<div class='cRContBottom mScrollVH surveyProgress'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>
				<select id="searchType" class="selectType02">
					<option value="A"><spring:message code='Cache.lbl_all'/></option>
					<option value="C"><spring:message code='Cache.lbl_TFName'/></option> <!-- T/F 팀룸 명 -->
					<option value="O"><spring:message code='Cache.lbl_TFContent'/></option> <!-- 추진내용 -->
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text" onkeypress="if(event.keyCode==13) {goSearchDetail(); return false;}">
				</div>
			</div>
			<div>
				<a href="#" id="btnSearch" onclick="goSearchDetail()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a>
			</div>
		</div>
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a href="#" id="btnApprove" class="btnTypeDefault btnThemeBg" onclick="javascript:updateTFTeamRoomStatus('RV');" style="display: none;"><spring:message code='Cache.btn_Approval2'/></a>
			<a href="#" id="btnReject" class="btnTypeDefault" onclick="javascript:updateTFTeamRoomStatus('RD');" style="display: none; left: 90px;"><spring:message code='Cache.btn_Reject'/></a>
			<a href="#" id="btnDelete" class="btnTypeDefault left" onclick="javascript:deleteTFTeamRoom();" style="display: none;"><spring:message code='Cache.lbl_delete'/></a>
		</div>
		<select class="selectType02" id="selectState" style="width: 160px;">
		</select>
		<select class="selectType01" id="selectSize">
			<option>10</option>
			<option>15</option>
			<option>20</option>
			<option>30</option>
			<option>50</option>
		</select>
		<button href="#" class="btnRefresh" type="button" onclick="onClickSearchButton()"></button>
	</div>
	<div class="tblList tblCont">
		<form id="form1">
			<div id="gridDiv">
			</div>
		</form>
	</div>
</div>
<script type="text/javascript">
var kind = '<%=kind%>';

var searchWord = '<%=searchWord%>';
var searchType = '<%=searchType%>';

var g_sortColumn = '<%=sortColumn%>';
var g_sortDirectoin =  '<%=sortDirection%>';

var AdminTFGrid = new coviGrid();
var msgHeaderData = "";
AdminTFGrid.config.fitToWidthRightMargin=0;

$(function(){
	$("#searchType").val(searchType == "null" ? "A" : searchType);
	searchWord = urlDecodeValue(searchWord);
	
	if(searchWord != "null" && searchWord != "" && searchWord != null){
		$("#seValue").val(searchWord);
	}else{
		$("#seValue").val("");
		searchWord = "";
	}
	
	switch(kind) {
	case "1" : //등록대기
		$("h2.title").html("<spring:message code='Cache.MN_980'/>");
		$("#btnApprove").show();
		$("#btnReject").show();
		$("#btnDelete").hide();
		break;
	case "2" : //등록된
		$("h2.title").html("<spring:message code='Cache.MN_981'/>");
		$("#btnApprove").hide();
		$("#btnReject").hide();
		$("#btnDelete").show();
		break;
	case "3" : //지연된
		$("h2.title").html("<spring:message code='Cache.MN_982'/>");
		$("#btnApprove").hide();
		$("#btnReject").hide();
		$("#btnDelete").show();
		break;
	}
	
	setAdminTFGrid();
	setSelectState();
	setEvent();
});

function setSelectState() {
	$(Common.getBaseCode("TFDetailState").CacheData).each(function(){
		if(this.Code != ""){
			$("#selectState").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
		}
	});
}

//폴더 그리드 세팅
function setAdminTFGrid(){
	AdminTFGrid.setGridHeader(GridHeader());
	selectAdminTFList();
}

function selectAdminTFList(){
	var sortColumn = "";
	var sortDicrection  = "";
	
	if(g_sortColumn != "null" && g_sortColumn != "" && g_sortColumn != null){
		sortColumn = g_sortColumn;
	}
	if(g_sortDirectoin != "null" && g_sortDirectoin != "" && g_sortDirectoin != null){
		sortDicrection = g_sortDirectoin;
	}
	
	//폴더 변경시 검색항목 초기화
	setAdminTFGridConfig();
	
	AdminTFGrid.bindGrid({
		ajaxUrl:"/groupware/layout/selectUserAdminTFGridList.do",
		ajaxPars: {
			"kind" : kind,
			"searchWord" : searchWord,
			"searchType" : $("#searchType").val(),
			"AppStatus" : $("#selectState").val(),
			"sortColumn" : sortColumn,
			"sortDirection" : sortDicrection
		},
	});
}
function setAdminTFGridConfig(){
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:$("#selectSize").val()
		},
		paging : true,
		colHead:{},
		body:{
		}
	};
	
	AdminTFGrid.setGridConfig(configObj);
}

function GridHeader(){
	var AdminGridHeader;
	
	switch(kind) {
	//등록대기
	case "1":
		AdminGridHeader = [
			{key:'chk', label:'chk', width:'1', align:'center', display:true, formatter:'checkbox'},
			//{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true},
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_TFName'/>",width:'2',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
	  			var html = String.format("<div title='{0}'><a href='#' onclick='javascript:OpenTFInfo({1});' style='text-decoration:none'>{0}</a></div>", (this.item.CommunityName=="" ? "-" : this.item.CommunityName), this.item.CU_ID);
        		return html;
	        }},
        	{key:'Description',  label:"<spring:message code='Cache.lbl_TFContent'/>",width:'3',align:'center',display:true, sort:false, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", unescape(this.item.Description));
        	}},
        	{key:'TF_PM',  label:"PM",width:'2',align:'center',display:true, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
        	}},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_TFPeriod'/>",width:'2',align:'center',display:true},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'1',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_Status'/>",width:'1',align:'center',display:true},
			{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RegDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegRequestDate,_StandardServerDateFormat);
				}
			},
			{key:'UserCode', label:'UserCode', align:'center', display:false, hideFilter : 'Y'},
			{key:'CU_ID', label:'<spring:message code='Cache.lbl_Move'/>', align:'center', display:false, hideFilter : 'Y', sort:false}
      	];
	//등록된
	case "2":
		AdminGridHeader = [
			{key:'chk', label:'chk', width:'1', align:'center', display:true, formatter:'checkbox'},
			//{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true},
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_TFName'/>",width:'2',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
	  			var html = String.format("<div title='{0}'><a href='#' onclick='javascript:OpenTFInfo({1});' style='text-decoration:none'>{0}</a></div>", (this.item.CommunityName=="" ? "-" : this.item.CommunityName), this.item.CU_ID);
        		return html;
	        }},
        	{key:'Description',  label:"<spring:message code='Cache.lbl_TFContent'/>",width:'3',align:'center',display:true, sort:false, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", unescape(this.item.Description));
        	}},
        	{key:'TF_PM',  label:"PM",width:'2',align:'center',display:true, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
        	}},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_TFPeriod'/>",width:'2',align:'center',display:true},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'1',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_Status'/>",width:'1',align:'center',display:true},
			{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RegDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegRequestDate,_StandardServerDateFormat);
				}
			},
	        {key:'UserCode',  label:'UserCode', align:'center' , display:false, hideFilter : 'Y'},
	        {key:'CU_ID',  label:"<spring:message code='Cache.lbl_Move'/>",width:'1',display:true, sort:false, formatter:function () {
				// T/F 팀룸으로 이동
	  			var html = "";
	  			
	  			if(this.item.AppStatus == "RA" || this.item.AppStatus == "RD" || this.item.AppStatus == "UV"){ //개설신청:RA,개설거부:RD,개설승인:RV,폐쇄신청UA,폐쇄거부:UD,폐쇄승인:UV,복원RS
	  				html = String.format("<div></div>");
	  			}else{
 		        	html = String.format("<div title='{0}'><a href='#' onclick='javascript:goCommunitySite({1});' class='btnTypeDefault btnSearchBlue01'>{2}</a></div>", this.item.CommunityName, this.item.CU_ID, "<spring:message code='Cache.lbl_Move'/>");
	  			}
	  			
        		return html;
        	}}
      	];
	//지연된
	case "3":
		AdminGridHeader = [
			{key:'chk', label:'chk', width:'1', align:'center', display:true, formatter:'checkbox'},
			//{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true},
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_TFName'/>",width:'2',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
	  			var html = String.format("<div title='{0}'><a href='#' onclick='javascript:OpenTFInfo({1});' style='text-decoration:none'>{0}</a></div>", (this.item.CommunityName=="" ? "-" : this.item.CommunityName), this.item.CU_ID);
        		return html;
        	}},
        	{key:'Description',  label:"<spring:message code='Cache.lbl_TFContent'/>",width:'3',align:'center', display:true, sort:false, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", unescape(this.item.Description));
        	}},
        	{key:'TF_PM',  label:"PM",width:'2',align:'center',display:true, formatter:function(){
        		return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
        	}},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_TFPeriod'/>",width:'2',align:'center',display:true},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'1',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_Status'/>",width:'1',align:'center',display:true},
			{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RegDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegRequestDate,_StandardServerDateFormat);
				}
			},
	        {key:'UserCode',  label:'UserCode', align:'center' , display:false, hideFilter : 'Y'},
	        {key:'CU_ID',  label:"<spring:message code='Cache.lbl_Move'/>",width:'1', display:true, sort:false, formatter:function () {
				// T/F 팀룸으로 이동
	  			var html = "";
	  			
	  			if(this.item.AppStatus == "RA" || this.item.AppStatus == "RD" || this.item.AppStatus == "UV"){ //개설신청:RA,개설거부:RD,개설승인:RV,폐쇄신청UA,폐쇄거부:UD,폐쇄승인:UV,복원RS
	  				html = String.format("<div></div>");
	  			}else{
 		        	html = String.format("<div title='{0}'><a href='#' onclick='javascript:goCommunitySite({1});' class='btnTypeDefault btnSearchBlue01'>{2}</a></div>", this.item.CommunityName, this.item.CU_ID, "<spring:message code='Cache.lbl_Move'/>");
	  			}
	  			
        		return html;
        	}}
      	];
	}
	
	msgHeaderData = AdminGridHeader;
	return AdminGridHeader;
}

function onClickSearchButton(){
	searchWord = $("#seValue").val();
	searchType =   $("#searchType").val();
	
	selectAdminTFList();
}

function goSearchDetail(){
	searchWord = $("#searchText").val();
	searchType = $("#searchType").val();
	
	selectAdminTFList();
}

function goCommunitySite(community){
	 var specs = "left=10,top=10,width=1050,height=900";
	 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
	 //window.open("/groupware/layout/userTF/TFMain.do?C="+community, "TF"+community, specs);
	 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);
}

function OpenTFInfo(CU_ID) {
	Common.open("", "TFInfo"+CU_ID, "<spring:message code='Cache.lbl_TFView'/>", "/groupware/layout/goTFInfoViewPopup.do?CU_ID=" + CU_ID, "700px", "670px", "iframe");
}

function setEvent(){
	$("#selectSize").change(function(){
		selectAdminTFList();
	});
	$("#selectState").change(function(){
		selectAdminTFList();
	});
	
	$('.btnDetails').unbind("click");
	$('.btnDetails').bind("click",function(){
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	
}

function updateTFTeamRoomStatus(mode) {
	var chkObj = AdminTFGrid.getCheckedList(0);
	var CU_IDs = '';
	
	if(chkObj.length ==0){
		Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />"); //선택된 항목이 없습니다.
		return false;
	}
	
	var msg = "<spring:message code='Cache.msg_RUApprove' />"; //승인하시겠습니까?
	if(mode == "RD") {
		msg = "<spring:message code='Cache.msg_RUReject' />"; //거부하시겠습니까?
	}
	
	
	Common.Confirm(msg, "Confirmation Dialog", function(result){
		if(result){
			for(var i = 0; i < chkObj.length; i++) {
				if(chkObj[i].AppStatus != "RA") {
					Common.Warning(chkObj[i].CommunityName + "의 상태가 "+chkObj[i].AppStatusName+"이므로 승인/거부 처리가 불가능합니다.");
					CU_IDs = "";
					break;
				}
				CU_IDs += chkObj[i].CU_ID + ",";
			}
			
			if(CU_IDs.length > 0) {
				CU_IDs = CU_IDs.substring(0, CU_IDs.length - 1);
				
				$.ajax({
					type:"POST",
					data:{
						"CU_IDs" : CU_IDs,
						"AppStatus" : mode
					},
					url:"/groupware/layout/updateTFTeamRoomStatus.do",
					success:function (data) {
						if(data.status == "SUCCESS") {
							selectAdminTFList();
						} else if(data.status == "FAIL" && data.message == "ERROR") {
							Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>", '', function (result) { selectAdminTFList(); });
						}
						
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/groupware/layout/updateTFTeamRoomStatus.do", response, status, error);
					}
				});
			}
		}
	});
}

function deleteTFTeamRoom() {
	var chkObj = AdminTFGrid.getCheckedList(0);
	var CU_IDs = '';
	
	if(chkObj.length ==0){
		Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />"); //선택된 항목이 없습니다.
		return false;
	}
	
	Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){//삭제하시겠습니까?
		if(result){
			for(var i = 0; i < chkObj.length; i++) {
				CU_IDs += chkObj[i].CU_ID + ",";
			}
			if(CU_IDs.length > 0) {
				CU_IDs = CU_IDs.substring(0, CU_IDs.length - 1);
				
				$.ajax({
					type:"POST",
					data:{
						"CU_IDs" : CU_IDs
					},
					url:"/groupware/layout/deleteTFTeamRoom.do",
					success:function (data) {
						if(data.status == "SUCCESS") {
							selectAdminTFList();
						} else if(data.status == "FAIL" && data.message == "ERROR") {
							Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>", '', function (result) { selectAdminTFList(); });
						} else {
							Common.Warning("<spring:message code='Cache.msg_MyListAuth'/>" + "\n" + data.message, '', function (result) { selectAdminTFList(); });
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/groupware/layout/deleteTFTeamRoom.do", response, status, error);
					}
				});
			}
		}
	});
}
</script>