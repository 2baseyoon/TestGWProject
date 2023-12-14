<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.CN_264'/></h2>	
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
				<spring:message code='Cache.lbl_CommunityRegStatus'/>
				<select id="communityApSelBox" class="selectType02">
					<option value="UA"><spring:message code="Cache.CuAppDetail_UA"/></option>
					<option value="UV"><spring:message code="Cache.CuAppDetail_UV"/></option>
					<option value="UD"><spring:message code="Cache.CuAppDetail_UD"/></option>
				</select>
			</div>
		</div>
	</div>	
    <div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<%-- <a id="btnStop" class="btnTypeDefault"><spring:message code="Cache.btn_Inactivity"/></a> 커뮤니티 "활동 중지"에 대한 정의가 불명확하여 해당 버튼 제거  --%>
				<a id="btnApproval"class="btnTypeDefault" ><spring:message code="Cache.btn_closureApproval"/></a>
				<a id="btnReject" class="btnTypeDefault"><spring:message code="Cache.btn_denialClosure"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#"  id="btnRefresh"></button>
			</div>
		</div>	
			
		<div id="gridDiv" class="tblList"></div>
	</div>	
</div>
<script type="text/javascript">
var confCommuClose = {
	commuCloseGrid : new coviGrid(),	
	msgOrgRootHeaderData : [
		{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
		{key:'DN_NM', label:"<spring:message code='Cache.ObjectType_DN'/>",width:'2', align:'center', display:true},
      	{key:'UnRegRequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'2', align:'center', display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.UnRegRequestDate,_ServerDateSimpleFormat);
			}
		},
		{key:'RegStatus',  label:"<spring:message code='Cache.lbl_CommunityRegStatus'/>",width:'2', align:'center', display:true},
		{key:'CuAppDetail',  label:"<spring:message code='Cache.lbl_CommunityAppStatus'/>",width:'2', align:'center', display:true},
		{key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
		{key:'CU_Code', label:"<spring:message code='Cache.lbl_Alias'/>",width:'2', align:'center', display:true},
		{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>",width:'2',display:true,formatter:function () {
			var html = "";
			html = String.format("<a href='#' onclick='javascript:closeCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
			return html;
		}},
		{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_SingleLineIntroduction'/>",width:'4',display:true},  
		{key:'UnRegProcessDate',  label:"<spring:message code='Cache.lbl_ProcessingDays'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.UnRegProcessDate,_ServerDateSimpleFormat);
			}
		} 
	],
	msgHeaderData : [
		{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
      	{key:'UnRegRequestDate',  label:"<spring:message code='Cache.lbl_RequestDay'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'2', align:'center', display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.UnRegRequestDate,_ServerDateSimpleFormat);
			}
		},
		{key:'RegStatus',  label:"<spring:message code='Cache.lbl_CommunityRegStatus'/>",width:'2', align:'center', display:true},
		{key:'CuAppDetail',  label:"<spring:message code='Cache.lbl_CommunityAppStatus'/>",width:'2', align:'center', display:true},
		{key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
		{key:'CU_Code', label:"<spring:message code='Cache.lbl_Alias'/>",width:'2', align:'center', display:true},
		{key:'CommunityName',  label:"<spring:message code='Cache.lbl_communityName'/>",width:'2',display:true,formatter:function () {
			var html = "";
			html = String.format("<a href='#' onclick='javascript:closeCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
			return html;
		}},
		{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_SingleLineIntroduction'/>",width:'4',display:true},  
		{key:'UnRegProcessDate',  label:"<spring:message code='Cache.lbl_ProcessingDays'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',display:true,
			formatter:function(){
				return CFN_TransLocalTime(this.item.UnRegProcessDate,_ServerDateSimpleFormat);
			}
		} 
	],
	initLoad:function(){
		this.event();
		this.setCommunityGrid();
	},
	event:function(){
		$("#communityApSelBox").change(function(){
			if(this.value == "UA"){		//폐쇄요청
				$("#btnStop").show();
				$("#btnApproval").show();
				$("#btnReject").show();
			}else if(this.value == "UV"){	//폐쇄승인->활동중지만 가능
				$("#btnStop").show();
				$("#btnApproval").hide();
				$("#btnReject").hide();
			}else{							//폐쇄거부->활동중지,폐쇄승인
				$("#btnStop").show();
				$("#btnApproval").show();
				$("#btnReject").hide();
			}
			confCommuClose.selectCommunityList();
		});
		
		$("#searchBtn").on("click",function(){
			confCommuClose.selectCommunityList();
		});
		$("#btnRefresh").on("click",function(){
			confCommuClose.selectCommunityList();
		});
		$('#selectPageSize').on('change', function(e) {
			confCommuClose.commuCloseGrid.page.pageSize = $(this).val();
			confCommuClose.selectCommunityList();
		});
		$("#btnStop").on("click",function(){
			confCommuClose.btnActivityOnClick('RF');
		});
		$("#btnApproval").on("click",function(){
			confCommuClose.btnActivityOnClick('UV');
		});
		$("#btnReject").on("click",function(){
			confCommuClose.btnActivityOnClick('UD');
		});
		
	},
	btnActivityOnClick:function(state){
		var paramArr = coviCmn.getGridCheckListToArray(this.commuCloseGrid,"CU_ID");
		if (paramArr.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (paramArr.length > 0) {
			var confirm = "";
			if(state == "RF"){
				confirm = "<spring:message code='Cache.msg_ActivityStop' />";
			}else if(state == "UV"){
				confirm = "<spring:message code='Cache.msg_ActivityStart' />";
			}else{
				confirm = "<spring:message code='Cache.msg_ActivityReject' />";
			}
			
			Common.Confirm(confirm, "Confirmation Dialog", function (confirmResult) {
				 if (confirmResult) {
					 $.ajax({
						url:"/groupware/manage/community/StaticCommunityUpdate.do",
						type:"post",
						data:{
							"paramArr" : paramArr.toString(),
							"AppStatus" : state
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform(Common.getDic('msg_Changed'),"Information",function(){ //변경되었습니다.
									confCommuClose.selectCommunityList();
					        	});
							}else{ 
								Common.Inform(Common.getDic('msg_changeFail'));
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/manage/community/StaticCommunityUpdate.do", response, status, error); 
						}
					});
				}
			});
			
		}
	},
	setCommunityGrid:function(){
		if(confMenu.domainId == "0") {
			this.commuCloseGrid.setGridHeader(this.msgOrgRootHeaderData);
		} else {
			this.commuCloseGrid.setGridHeader(this.msgHeaderData);	
		}
		
		this.commuCloseGrid.setGridConfig({
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
		this.commuCloseGrid.bindGrid({
			ajaxUrl:"/groupware/manage/community/selectCommunityCloseGridList.do",
			ajaxPars: {
				"DN_ID" : confMenu.domainId,
				"AppStatus" : $("#communityApSelBox").val()
			},
		}); 
	},
	openCommunity:function(id){
		Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/manage/community/modifyCommunity.do?mode=E"+"&CU_ID="+id,"620px","550px","iframe","false",null,null,true);
	}
}

window.onload = confCommuClose.initLoad();


</script>