<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ACLHelper,egovframework.baseframework.util.json.JSONSerializer,org.apache.commons.lang3.StringUtils,egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<body>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.FolderType_ScheduleShare'/></h2> <!-- 공유일정 -->
</div>
<div class="cRContBottom mScrollVH" id=confSchedule>
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView" id="divShare"> 
				<select name="" id="selectSearchShareType">
					<option value="SpecifierCode" selected="selected"><spring:message code='Cache.lbl_ShareSpecifier' /></option> <!-- 공유 등록자 -->
					<option value="TargetCode"><spring:message code='Cache.lbl_ShareTarget' /></option> <!-- 공유 대상자 -->
				</select>
				<input type="text" id="shareUserName" onKeyDown="onKeyDown();">&nbsp;&nbsp;&nbsp;
				
				<spring:message code="Cache.lbl_SharingPeriod"/> &nbsp;<!-- 공유 기간 -->
				<input id="startDate" style="width: 100px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate" date_separator=".">
			   	    ~ 				   	   
				<input id="endDate" style="width: 100px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate" date_separator=".">
			</div>	
			
			<div class="dateSel type02">
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch" ><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>	
	</div>
    <div class="sadminContent">
    	<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div  id="divBtnSchedule">
					<a class="btnTypeDefault" id="btnAddShare"><spring:message code='Cache.btn_AddShare' /></a><!-- 공유 추가 -->
					<a class="btnTypeDefault" id="btnDelShare"><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
				</div>
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
		<!-- 폴더 Grid 리스트 -->
		<div id="folderGrid" class="tblList tblCont"></div>
	</div>
</div>	
</body>

<script type="text/javascript">
var confSchedule = {
		folderGrid :new coviGrid(),		//폴더 Grid
		domainID :confMenu.domainId,
		folderID : '',
		shareHeader :[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	                 {key:'SpecifierName', label:'<spring:message code="Cache.lbl_ShareSpecifier"/>', width:'100', align:'left', sort:"asc", formatter:function(){
								  return '<a href="#" onclick="confSchedule.editSharePopup(\'' + this.item.SpecifierCode + '\')">' + CFN_GetDicInfo(this.item.SpecifierName)+ '</a>';
							  }},// 공유 등록자
                  {key:'SpecifierCode', label:'<spring:message code="Cache.lbl_ShareSpecifier"/>ID', width:'100', align:'left'},
                  {key:'TargetData', label:'<spring:message code="Cache.lbl_ShareTarget"/>', width:'400', align:'left',sort:false}],
		initContent:function (){
			confSchedule.folderGrid = new coviGrid();
			confSchedule.folderGrid.setGridHeader(confSchedule.shareHeader);
			confSchedule.folderGrid.setGridConfig( {
				targetID : "folderGrid",
				height:"auto",
				page : {
					pageNo:1,
					pageSize:$('#selectPageSize').val()
				},
				paging : true});

			this.setFolderData();
			
			$("#scheduleFolder").click(function () {//폴더 새로고침
				confSchedule.setFolderData();
			});

			//검색
			$("#shareUserName").on( 'keydown',function(){
				if(event.keyCode=="13"){
					confSchedule.setFolderData();
	
				}
			});	

			
			$("#btnSearch").on( 'click',function(){
				confSchedule.setFolderData();
			});	
			
			//공유일정 추기
			$("#btnAddShare").on( 'click',function(){
				confSchedule.editSharePopup('');
			});
			//공유 삭제
			$("#btnDelShare").on( 'click',function(){
				confSchedule.deleteShareScheduleData();
			});			
			$("#btnRefresh").on("click",function(){
				confSchedule.setFolderData();
			});
			$('#selectPageSize').on('change', function(e) {
				confSchedule.folderGrid.page.pageSize = $(this).val();
				confSchedule.setFolderData();
			});


		},
		setFolderData:function(){
			var selectSearchType = $("#selectSearchType").val();	
			var searchValue = $("#searchValue").val();
			var url = "/groupware/manage/schedule/getAdminShareList.do";
			var params = {
					"domainID": confMenu.domainId,
					"selectSearchType":$("#selectSearchShareType").val(),
					"shareUserName":$("#shareUserName").val(),
					"startDate": ($("#startDate").val() != '') ? CFN_TransServerTime($("#startDate").val().replaceAll('.', "-")) : '',
					"endDate": ($("#endDate").val() != '') ? CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays($("#endDate").val().replaceAll('.', "-"), 1),'-')) : ''
				}
			confSchedule.folderGrid.bindGrid({
				ajaxUrl:url,
				ajaxPars:params
			});
		
			// Tree 세팅
		},
		editSharePopup:function(shareID){
			Common.open("","updateConfig","<spring:message code='Cache.lbl_AddEditShare' />","/groupware/manage/schedule/adminSharePopup.do?ShareID="+shareID,"600px","400px","iframe",true,null,null,true);
		},
		deleteShareScheduleData:function(){
			var paramArr = coviCmn.getGridCheckListToArray(this.folderGrid,"SpecifierCode");

			if(paramArr.length > 0){
				Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirm", function(result){
					if(result){
						$.ajax({
						    url: "/groupware/manage/schedule/deleteAdminShareData.do",
						    type: "POST",
						    data: {
						    	"SpecifierCodeArr":paramArr.toString()
							},
						    success: function (res) {
					            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
					            	confSchedule.setFolderData();
					            });
					        },
					        error:function(response, status, error){
								CFN_ErrorAjax("/groupware/schedule/deleteAdminShareData.do", response, status, error);
							}
						});
					}
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
			}
		}
}

$(document).ready(function(){
	confSchedule.initContent();
	
	
});
	

</script>