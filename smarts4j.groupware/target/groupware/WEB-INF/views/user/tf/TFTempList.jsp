<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String searchWordStatus = request.getParameter("searchWordStatus");
	String searchTypeStatus = request.getParameter("searchTypeStatus");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
%>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_TempSaveList'/></h2><!-- T/F팀룸 임시저장 리스트 -->
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
			<a href="#" id="btnDelete" class="btnTypeDefault left" onclick="javascript:deleteTempTFTeamRoom();"><spring:message code='Cache.lbl_delete'/></a>
		</div>
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
var searchWord = '<%=searchWord%>';
var searchType = '<%=searchType%>';

var g_sortColumn = '<%=sortColumn%>';
var g_sortDirectoin =  '<%=sortDirection%>';

var TempTFGrid = new coviGrid();
var msgHeaderData = "";
TempTFGrid.config.fitToWidthRightMargin=0;

$(function(){
	$("#searchType").val(searchType == "null" ? "A" : searchType);
	searchWord = urlDecodeValue(searchWord);
	
	if(searchWord != "null" && searchWord != "" && searchWord != null){
		$("#seValue").val(searchWord);
	}else{
		$("#seValue").val("");
		searchWord = "";
	}
	
	setTempTFGrid();
	setEvent();
});

//폴더 그리드 세팅
function setTempTFGrid(){
	TempTFGrid.setGridHeader(GridHeader());
	selectTempTFList();
}

function selectTempTFList(){
	var sortColumn = "";
	var sortDicrection  = "";
	
	if(g_sortColumn != "null" && g_sortColumn != "" && g_sortColumn != null){
		sortColumn = g_sortColumn;
	}
	if(g_sortDirectoin != "null" && g_sortDirectoin != "" && g_sortDirectoin != null){
		sortDicrection = g_sortDirectoin;
	}

	//폴더 변경시 검색항목 초기화
	setTempTFGridConfig();
	
	TempTFGrid.bindGrid({
		ajaxUrl:"/groupware/layout/selectUserTempTFGridList.do",
		ajaxPars: {
			"searchWord" : searchWord,
			"searchType" : $("#searchType").val(),
			"AppStatus" : $("#selectState").val(),
			"sortColumn" : sortColumn,
			"sortDirection" : sortDicrection
		},
	});
}

function setTempTFGridConfig(){
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
	
	TempTFGrid.setGridConfig(configObj);
}

function GridHeader(){
	var TempTFGridHeader = [
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
							{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_TFContent'/>",width:'3',align:'center',display:true, formatter:function(){
								return String.format("<div title='{0}'>{0}</div>", unescape(this.item.SearchTitle));
							}},
							{key:'TF_MajorDept',  label:"<spring:message code='Cache.lbl_HeadDept'/>",width:'2',align:'center',display:true},
							{key:'TF_Period',  label:"<spring:message code='Cache.lbl_TFPeriod'/>",width:'2',align:'center',display:true},
							{key:'TF_PM',  label:"PM",width:'2',align:'center',display:true, formatter:function(){
								return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
							}},
							{key:'TF_MemberCount',  label:"<spring:message code='Cache.lbl_MemberCount'/>",width:'1',align:'center',display:true},
							{key:'RegistDate',  label:"<spring:message code='Cache.lbl_RegDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
								formatter:function(){
									return CFN_TransLocalTime(this.item.RegistDate,_StandardServerDateFormat);
								}
							},
							{key:'UserCode',  label:'UserCode', align:'center' , display:false, hideFilter : 'Y'},
							{key:'CU_ID', label:'', align:'center', display:false, hideFilter : 'Y'}
						];
	msgHeaderData = TempTFGridHeader;
	return TempTFGridHeader;
}

function onClickSearchButton(){
	searchWord = $("#seValue").val();
	searchType = $("#searchType").val();
	
	selectTempTFList();
}

function goSearchDetail(){
	searchWord = $("#searchText").val();
	searchType = $("#searchType").val();
	
	selectTempTFList();
}

function OpenTFInfo(CU_ID) {
	CoviMenu_GetContent("/groupware/layout/TF_TFCreate.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask"+ "&CU_ID=" + CU_ID);
}

function setEvent(){
	$("#selectSize").change(function(){
		selectTempTFList();
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

function deleteTempTFTeamRoom() {
	var chkObj = TempTFGrid.getCheckedList(0);
	var CU_IDs = '';
	
	if(chkObj.length ==0){
		Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />"); //선택된 항목이 없습니다.
		return false;
	}
	
	Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){//삭제하시겠습니까?
		if(result){
			for(var i = 0; i < chkObj.length; i++) {
				CU_IDs += (CU_IDs==""?"":",") + String(chkObj[i].CU_ID);
			}
			$.ajax({
				type:"POST",
				data:{
					"CU_IDs" : CU_IDs
				},
				url:"/groupware/layout/deleteTempTFTeamRoom.do",
				success:function (data) {
					if(data.status == "SUCCESS") {
						selectTempTFList();
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>", '', function (result) { selectTempTFList(); }); //오류가 발생하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/deleteTempTFTeamRoom.do", response, status, error);
				}
			});
		}
	});
}
</script>