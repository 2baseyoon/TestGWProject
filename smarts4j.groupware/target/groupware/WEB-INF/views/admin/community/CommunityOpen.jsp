<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.lbl_communityOpManage'/></span>	
</h3>

<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
   <div style="width:100%;min-height: 500px">
   	<div id="topitembar01" class="topbar_grid">
		<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridSubRefresh();"/>
		<input id="aoc" type="button" class="AXButton"  value="<spring:message code='Cache.lbl_Approved'/>" onclick="btnApprovalOnClick();"/>
		<input id="roc" type="button" class="AXButton"  value="<spring:message code='Cache.lbl_Rejection'/>" onclick="btnRejectOnClick();"/>
	</div>
	<div id="topitembar02" class="topbar_grid">
		
		<%-- 21.12.29, 도메인 관리자는 도메인 선택 화면을 안보여줍니다(CoreInclude.jsp를 통한 class domain 처리). --%>
		<span class="domain">
			<spring:message code='Cache.lbl_OwnedCompany'/>
			<select id="communityDoSelBox" class="AXSelect W100"></select>
		</span>
		
		<spring:message code='Cache.lbl_apv_searchcomment'/>
		<select id="communitySeSelBox" class="AXSelect W100">
			<option value="0"><spring:message code='Cache.lbl_Choice'/></option>
			<option value="1"><spring:message code='Cache.lbl_Requester'/></option>
			<option value="2"><spring:message code='Cache.lbl_RequestDept'/></option>
		</select>
		<input name="search" type="text" id="searchValue" class="AXInput" />
		<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchBtn" class="AXButton" />
	</div>	
	<div id="gridDiv"></div>
</div>

<script type="text/javascript">
var communityGrid = new coviGrid();

var msgHeaderData = "";

communityGrid.config.fitToWidthRightMargin=0;

window.onload = initLoad();

function initLoad(){
	event();
	setCommunityGrid();
}

function GridHeader(){
	var communityGridHeader = [
		                       	{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
		                       	{key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
								{key:'CU_Code', label:"<spring:message code='Cache.lbl_Alias'/>",width:'2', align:'center', display:true},
								{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>",width:'2',display:true,formatter:function () {
			      		  			var html = "";
			      		        	html = String.format("<a href='#' onclick='javascript:openCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
		      		        		return html;
		      		        	}},
								{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_SingleLineIntroduction'/>",width:'4',display:true},  
								{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Requester'/>",width:'2',display:true},  
								/* {key:'CreatorDept',  label:"<spring:message code='Cache.lbl_apv_department'/>",width:'2',display:true}, */
								{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2',display:true,
									formatter:function(){
										return CFN_TransLocalTime(this.item.RegProcessDate,_StandardServerDateFormat);
									}
								} 
		      		        ]; 
	
	msgHeaderData = communityGridHeader;
	return communityGridHeader;
}

//폴더 그리드 세팅
function setCommunityGrid(){
	communityGrid.setGridHeader(GridHeader());
	selectCommunityList();				
}


function setCommunityGridConfig(){
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:10
		},
		paging : true,
		colHead:{},
		body:{}
	};
	
	communityGrid.setGridConfig(configObj);
}

function gridSubRefresh(){
	selectCommunityList();
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
	
	$("#searchBtn").on("click",function(){
		selectCommunityList();
	});
	
}

function selectCommunityList(){
	//폴더 변경시 검색항목 초기화
	setCommunityGridConfig();
	communityGrid.bindGrid({
		ajaxUrl:"/groupware/layout/community/selectCommunityOpenGridList.do",
		ajaxPars: {
			"DN_ID" : $("#communityDoSelBox").val(),
			"Option" : $("#communitySeSelBox").val(),
			"searchValue" : $("#searchValue").val()
		},
	}); 
}

$("#communityDoSelBox").change(function(){
	selectCommunityList();
})

function openCommunity(id){
	Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/community/modifyCommunity.do?DN_ID="+$("#communityDoSelBox").val()+"&mode=E"+"&CU_ID="+id,"620px","550px","iframe","false",null,null,true);
}

function btnApprovalOnClick(){
	var checkCommunityList = communityGrid.getCheckedList(0);
	if (checkCommunityList.length == 0) {
		Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
	} else if (checkCommunityList.length > 0) {
		Common.Confirm("<spring:message code='Cache.msg_OpenApprovalCommunity' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var paramArr = new Array();
				
				paramArr = returnSubArr(checkCommunityList);
				
				if (paramArr.length > 0) {
					$.ajax({
						url:"/groupware/layout/community/openCommunity.do",
						type:"post",
						data:{
							"paramArr" : paramArr.toString()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_OpenApprovalNotice'/>");
								gridSubRefresh();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
								gridSubRefresh();
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/openCommunity.do", response, status, error); 
						}
					}); 		
					
				}
			}
		});
		
	}
}

function btnRejectOnClick(){
	var checkCommunityList = communityGrid.getCheckedList(0);
	if (checkCommunityList.length == 0) {
		Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
	} else if (checkCommunityList.length > 0) {
		Common.Confirm("<spring:message code='Cache.msg_OpenApprovalCommunityR' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var paramArr = new Array();
				
				paramArr = returnSubArr(checkCommunityList);
				
				if (paramArr.length > 0) {
					$.ajax({
						url:"/groupware/layout/community/rejectOpenCommunity.do",
						type:"post",
						data:{
							"paramArr" : paramArr.toString()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_OpenDenialNotice'/>");
								gridSubRefresh();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
								gridSubRefresh();
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/rejectOpenCommunity.do", response, status, error); 
						}
					}); 		
					
				}
			}
		});
		
	}
}

function returnSubArr(checkCommunityList){
	var paramArr = new Array();
	$(checkCommunityList).each(function(i, v) {
			var str = v.CU_ID;
			paramArr.push(str);
	});
	
	return paramArr;
} 

</script>