<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit" style="margin-bottom: 0px; border-bottom: none;">활동 현황/집계</span>	
</h3>

<form id="frm">
	<input type="hidden" id="communityId" value=""/>
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
	<input type="hidden" id ="_hiddenMemberOf" value = ""/>	
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/>
			<select id="communityApSelBox" class="AXSelect W100" style="vertical-align: middle; height: 24px;">
				<option value="S">현황</option>
			</select>
			<select id="communityCSelBox" class="AXSelect W100" style="vertical-align: middle; height: 24px;">
				<option value="S">단일</option>
				<option value="M">전체</option>
			</select>
			<input id="excel" type="button" class="AXButton BtnExcel" value="엑셀저장" onclick="goExcel();"/>
			<div class="w_top" id="divNoticeMedia" style="float: right; padding-right: 10px; width: 300px;">
                <dl style="float: right;">
                    <dd class="w_top_line" style="display: inline; vertical-align: middle;">
                    	<input id="chkNoticeMail" type="checkbox" value="Mail" checked="" class="input_check2">
                    	Mail
                    </dd>
                    <dd class="w_top_line" style="display: inline; vertical-align: middle;">
                    	<input id="chkNoticeTODOLIST" type="checkbox" value="TODOLIST" checked="" class="input_check2">
                    	Todo
                    </dd>
              		<input type="button" class="AXButton"  value="<spring:message code="Cache.msg_contactOperator"/>" onclick="javascript:sendMessage();"/>	
                </dl>
       		 </div>
		</div>
		<div id="topitembar02" class="topbar_grid ">
			
			<%-- 21.12.29, 도메인 관리자는 도메인 선택 화면을 안보여줍니다(CoreInclude.jsp를 통한 class domain 처리). --%>
			<span class="domain">
				<spring:message code='Cache.lbl_OwnedCompany'/>
				<select id="communityDoSelBox" class="AXSelect W100"></select>
			</span>
			
			포탈유형
			<select id="communityPuSelBox" class="AXSelect W100">
			</select>
			상태
			<select id="communityStSelBox" class="AXSelect W100">
			</select>
			<select id="communitySeSelBox" class="AXSelect W100">
				<option value="A">전체</option>
				<option value="C">커뮤니티 명</option>
				<option value="O">운영자</option>
			</select>
			<input name="search" type="text" id="searchValue" class="AXInput" />
			<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchBtn" class="AXButton" />
		</div>
		<div id="gridDiv"></div>
		<div class="w_top" class="topbar_grid" style="width: 100%; margin-top: 30px; margin-bottom: 10px;">
            <div class="dateSel type02">
		            <h1 style="float: left;"><span id="txtSeMCName" style="margin-right: 10px;"></span></h1>
					<input class="AXInput" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate"> - 
					<input class="AXInput" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate">
					<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchSubBtn" class="AXButton" />
			</div>	    
        </div>
		<div id="subGridDiv"></div>		
	</div>
</form>
<script type="text/javascript">
var communityGrid = new coviGrid();
var communitySubGrid = new coviGrid();

var msgHeaderData = "";
var msgSubHeaderData = "";

communityGrid.config.fitToWidthRightMargin=0;
communitySubGrid.config.fitToWidthRightMargin=0;

window.onload = initLoad();

function initLoad(){
	event();
	setCommunityGrid();
	setCommunitySubGrid();
}

//폴더 그리드 세팅
function setCommunityGrid(){
	communityGrid.setGridHeader(GridHeader());
	selectCommunityList();				
}

function setCommunitySubGrid(){
	communitySubGrid.setGridHeader(SubGridHeader());
	selectSubCommunityList();		
}

function GridHeader(){
	var communityGridHeader = [
		      		         	{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
		      		  			{key:'number', label:"No",width:'1', align:'center', display:true},
			      		  		{key:'CommunityName', label:"커뮤니티 명",width:'2', align:'center', display:true,formatter:function () {
				      		  		var html = "";
			      		        	html = String.format("<a href='#' onclick='javascript:subCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
		      		        		return html;
		      		        	}},
			      		  		{key:'Grade', label:"순위",width:'1', align:'center', display:true},
			      			 	{key:'Point', label:"포인트",width:'1', align:'center', display:true},
					      		{key:'MemberCount', label:"회원수",width:'1', align:'center', display:true},
					      		{key:'VisitCount', label:"방문수",width:'1', align:'center', display:true},
					      		{key:'MsgCount', label:"게시글수",width:'2', align:'center', display:true},
					      		{key:'ViewCount', label:"조회수",width:'2', align:'center', display:true},
					      		{key:'ReplyCount', label:"답글",width:'1', align:'center', display:true},
					      		{key:'FileSize', label:"사용량(MB)",width:'2', align:'center', display:true},
					      		{key:'RegStatus', label:"상태",width:'1', align:'center', display:true},
					      		{key:'DisplayName', label:"운영자",width:'1', align:'center', display:true},
					      		{key:'RegProcessDate', label:"개설일" +Common.getSession("UR_TimeZoneDisplay"),width:'2', align:'center', display:true,  sort:'desc',
					      			formatter:function(){
					      				return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
					      			}
					      		},
		      		        ]; 
	
	msgHeaderData = communityGridHeader;
	return communityGridHeader;
}

function SubGridHeader(){
	var communitySubGridHeader = [
									{key:'YYYYMMDD', label:"년월",width:'2', align:'center', display:true,  sort:'desc'},  
									{key:'Grade', label:"순위",width:'2', align:'center', display:true},
									{key:'Point', label:"포인트",width:'2', align:'center', display:true},
									{key:'MemberCount', label:"회원수",width:'2', align:'center', display:true},
									{key:'VisitCount', label:"방문수",width:'2', align:'center', display:true},
									{key:'MsgCount', label:"게시글수",width:'2', align:'center', display:true},
									{key:'ViewCount', label:"조회수",width:'2', align:'center', display:true},
									{key:'ReplyCount', label:"답글",width:'2', align:'center', display:true}
		      		        ]; 
	
	msgSubHeaderData = communitySubGridHeader;
	return communitySubGridHeader;
}

function selectCommunityList(){
	//폴더 변경시 검색항목 초기화
	setCommunityGridConfig();
	communityGrid.bindGrid({
		ajaxUrl:"/groupware/layout/community/selectCommunityStaticGridList.do",
		ajaxPars: {
			DN_ID : $("#communityDoSelBox").val(),
			CommunityType : $("#communityPuSelBox").val(),
			RegStatus : $("#communityStSelBox").val(),
			SearchOption : $("#communitySeSelBox").val(),
			searchValue : $("#searchValue").val()
		},onLoad:function(){
			communityGrid.click(0);
        }
	}); 
	
}

function selectSubCommunityList(){
	//폴더 변경시 검색항목 초기화
	setCommunitySubGridConfig();
	communitySubGrid.bindGrid({
		ajaxUrl:"/groupware/layout/community/selectCommunityStaticSubGridList.do",
		ajaxPars: {
			CU_ID : $("#communityId").val(),
			startDate : $("#startdate").val(),
			endDate : $("#enddate").val()
		},
	}); 
}

function setCommunityGridConfig(){
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:5
		},
		paging : true,
		colHead:{},
		body:{
			onclick: function () {
				  $("#communityId").val(this.item.CU_ID);
				  $("#txtSeMCName").text(this.item.CommunityName);
				  selectSubCommunityList();
	        }
		}
	};
	
	communityGrid.setGridConfig(configObj);
}

function setCommunitySubGridConfig(){
	var configSubObj = {
		targetID : "subGridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:5
		},
		paging : true,
		colHead:{},
		body:{
			
		}
	};
	
	communitySubGrid.setGridConfig(configSubObj);
}

function event(){
	$.ajax({
		type:"POST",
		data:{
			
		},
		async : false,
		url:"/groupware/layout/community/selectCommunityD.do",
		success:function (data) {
			var recResourceHTML = "";
			$("#communityDoSelBox").html("");
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					recResourceHTML += '<option value="'+v.DomainID+'"  >'+v.DisplayName+'</option>';
    			});
			}
			
			$("#communityDoSelBox").append(recResourceHTML);
			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/selectCommunityD.do", response, status, error);
		}
	});
	
	selBoxBind();
	
	$("#searchBtn").on("click",function(){
		gridRefresh();
	});
	
	$("#communityDoSelBox").change(function(){
		gridRefresh();
	});		
	
	$("#searchSubBtn").on("click",function(){
		selectSubCommunityList();
	});
	
	$("#communityDoSelBox").on("change", selBoxBind);
}

function selBoxBind(){
	$("#communityPuSelBox").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityType", "DomainID": $("#communityDoSelBox").val()},
			"<spring:message code='Cache.lbl_selection'/>",
			""
	);
	
	$("#communityStSelBox").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CuStatus", "DomainID": $("#communityDoSelBox").val()},
			"<spring:message code='Cache.lbl_selection'/>",
			""
	);
}

function sendMessage(){
	var notiMail = "";
	var todoList = "";
	
	if($('input:checkbox[id="chkNoticeMail"]').is(":checked") == true){
		notiMail = 'Y';
	}else{
		notiMail = 'N';
	}
	
	if($('input:checkbox[id="chkNoticeTODOLIST"]').is(":checked") == true){
		todoList = 'Y';
	}else{
		todoList = 'N';
	}
	
	var checkCommunityList = communityGrid.getCheckedList(0);
	if (checkCommunityList.length == 0) {
		Common.Warning("<spring:message code='Cache.lbl_apv_alert_selectRow'/>"); // 선택한 행이 없습니다.
		return false;
	} else if (checkCommunityList.length > 0) {
		var paramArr = new Array();
		paramArr = returnArr(checkCommunityList);
		 
		Common.open("","todoOperator","<spring:message code='Cache.lbl_MessageInputDialog'/>","/groupware/community/todoOperator.do?DN_ID="+$("#communityDoSelBox").val()+"&notiMail="+notiMail+"&todoList="+todoList+"&paramArr="+paramArr,"260px","150px","iframe","false",null,null,true);
	}
}

function returnArr(checkCommunityList){
	var paramArr = new Array();
	$(checkCommunityList).each(function(i, v) {
			var str = v.CU_ID;
			paramArr.push(str);
	});
	
	return paramArr;
}

function gridRefresh(){
	selectCommunityList();	
}

function subCommunity(id){
	Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/community/modifyCommunity.do?DN_ID="+$("#communityDoSelBox").val()+"&mode=E"+"&CU_ID="+id,"670px","620px","iframe","false",null,null,true);
}

function goExcel(){
	Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
   		if(result){
   			var	sortKey = communityGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
   			var	sortWay = communityGrid.getSortParam("one").split("=")[1].split(" ")[1];
   			var action = "";
   			if($("#communityId").val() != "" && $("#communityCSelBox").val() == "S"){
   				action = String.format("community/CommunityStaticCompileExcelFormatDownload.do?communityId={0}&sortKey={1}&sortWay={2}", $("#communityId").val(), sortKey, sortWay);
   							
   			}else{
   				var headerName = getHeaderNameForExcel();
   				action = String.format("community/CommunityStaticStatusExcelFormatDownload.do?DN_ID={0}&CommunityType={1}&sortKey={2}&sortWay={3}&headerName={4}&RegStatus={5}&SearchOption={6}&searchValue={7}", $("#communityDoSelBox").val(), $("#communityPuSelBox").val(), sortKey, sortWay, encodeURI(headerName), $("#communityStSelBox").val(),$("#communitySeSelBox").val(),$("#searchValue").val());
   			}
   			location.href = action;
   		}
	});
}

function getHeaderNameForExcel(){
	var returnStr = "";
   	for(var i=0;i<msgHeaderData.length; i++){
   		if( msgHeaderData[i].hideFilter != 'Y' ){
			returnStr += msgHeaderData[i].label + "|";
   	   	}
	}
	return returnStr;
}

</script>