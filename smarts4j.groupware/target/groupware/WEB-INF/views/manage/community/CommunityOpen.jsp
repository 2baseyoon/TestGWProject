<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_communityOpManage'/></h2>	
</div>
<div class="cRContBottom mScrollVH">

<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView"> 
				<spring:message code='Cache.lbl_apv_searchcomment'/>
				<select id="communitySeSelBox" class="selectType02">
					<option value="0"><spring:message code='Cache.lbl_Choice'/></option>
					<option value="1"><spring:message code='Cache.lbl_Requester'/></option>
					<option value="2"><spring:message code='Cache.lbl_RequestDept'/></option>
				</select>
				<input name="search" type="text" id="searchValue"/>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"  id="searchBtn" ><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
	</div>
    <div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault" id="btnApproval"><spring:message code='Cache.lbl_Approved'/></a>
				<a class="btnTypeDefault" id="btnReject"><spring:message code='Cache.lbl_Rejection'/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" id="btnRefresh"></button>
			</div>
		</div>	
		<div id="gridDiv" class="tblList"></div>
	</div>
</div>
<script type="text/javascript">
var confCommuOpen = {
	commuOpenGrid : new coviGrid(),
	msgOrgRootHeaderData : [		 				
		{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
      	{key:'DN_NM', label:"<spring:message code='Cache.ObjectType_DN'/>",width:'2', align:'center', display:true},
        {key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
		{key:'CU_Code', label:"<spring:message code='Cache.lbl_Alias'/>",width:'2', align:'center', display:true},
		{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>",width:'2',display:true,formatter:function () {
	  			var html = "";
	        	html = String.format("<a href='#' onclick='javascript:confCommuOpen.openCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
       		return html;
       	}},
		{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_SingleLineIntroduction'/>",width:'4',display:true},  
		{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Requester'/>",width:'2',align:'center',display:true},  
		/* {key:'CreatorDept',  label:"<spring:message code='Cache.lbl_apv_department'/>",width:'2',display:true}, */
		{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.RegProcessDate,_StandardServerDateFormat);
			}
		} 
	],
	msgHeaderData : [		 				
		{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
		{key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
		{key:'CU_Code', label:"<spring:message code='Cache.lbl_Alias'/>",width:'2', align:'center', display:true},
		{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>",width:'2',display:true,formatter:function () {
			var html = "";
     		html = String.format("<a href='#' onclick='javascript:confCommuOpen.openCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
    		return html;
    	}},
		{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_SingleLineIntroduction'/>",width:'4',display:true},  
		{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Requester'/>",width:'2',align:'center',display:true},
		{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.RegProcessDate,_StandardServerDateFormat);
			}
		} 
	],
	initLoad: function (){
			this.event();
			this.setCommunityGrid();
	},
	event:function (){
		$("#searchValue").on( 'keydown',function(){
			if(event.keyCode=="13"){
				confCommuOpen.selectCommunityList();

			}
		});	
		
		$("#searchBtn").on("click",function(){
			confCommuOpen.selectCommunityList();
		});
		$("#btnRefresh").on("click",function(){
			confCommuOpen.selectCommunityList();
		});
		$('#selectPageSize').on('change', function(e) {
			confCommuOpen.commuOpenGrid.page.pageSize = $(this).val();
			confCommuOpen.selectCommunityList();
		});
		$("#btnApproval").on("click",function(){
			confCommuOpen.approvalCommunityOpen();
		});
		$("#btnReject").on("click",function(){
			confCommuOpen.rejectCommunityOpen();
		});
	},
	setCommunityGrid:function(){
		if(confMenu.domainId == "0") {
			this.commuOpenGrid.setGridHeader(this.msgOrgRootHeaderData);
		} else {
			this.commuOpenGrid.setGridHeader(this.msgHeaderData);	
		}
		
		this.commuOpenGrid.setGridConfig( {
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
			});
		this.selectCommunityList();				
	},
	selectCommunityList:function(){
		this.commuOpenGrid.bindGrid({
			ajaxUrl:"/groupware/manage/community/selectCommunityOpenGridList.do",
			ajaxPars: {
				"DN_ID" : confMenu.domainId,
				"Option" : $("#communitySeSelBox").val(),
				"searchValue" : $("#searchValue").val()
			},
		}); 
	},
	approvalCommunityOpen:function(){
		var paramArr = coviCmn.getGridCheckListToArray(this.commuOpenGrid,"CU_ID");
		if (paramArr.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (paramArr.length > 0) {
			Common.Confirm("<spring:message code='Cache.msg_OpenApprovalCommunity' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						url:"/groupware/manage/community/openCommunity.do",
						type:"post",
						data:{
							"paramArr" : paramArr.toString()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_OpenApprovalNotice'/>");
								confCommuOpen.selectCommunityList();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/openCommunity.do", response, status, error); 
						}
					}); 		
				}
			});
			
		}
	},
	rejectCommunityOpen:function(){
		var paramArr = coviCmn.getGridCheckListToArray(this.commuOpenGrid,"CU_ID");
		if (paramArr.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (paramArr.length > 0) {
			Common.Confirm("<spring:message code='Cache.msg_OpenApprovalCommunityR' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						url:"/groupware/manage/community/rejectOpenCommunity.do",
						type:"post",
						data:{
							"paramArr" : paramArr.toString()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_OpenDenialNotice'/>");
								confCommuOpen.selectCommunityList();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/rejectOpenCommunity.do", response, status, error); 
						}
					}); 		
				}
			});
		}
	},
	openCommunity:function(id){
		Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/manage/community/modifyCommunity.do?mode=E"+"&CU_ID="+id,"620px","550px","iframe","false",null,null,true);
	}



}

this.gridRefresh = function() {
	confCommuOpen.selectCommunityList();
}

window.onload = confCommuOpen.initLoad();





</script>