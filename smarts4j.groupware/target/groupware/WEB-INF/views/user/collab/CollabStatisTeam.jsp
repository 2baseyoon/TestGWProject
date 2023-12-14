<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<div id="divCollabStatisTeam">
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_TeamWorkBox'/></h2>	
	<div class="searchBox02">
		<span><input type="text" id="searchText"  />
		<button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContCollabo mScrollVH'>
	<div class="selectBox" id="selectBoxDiv">
		<span style="float:left;">
			<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
			<select class="size112" id="groupPath"></select>
		</span>	
		<span style="margin-right:50px;">
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_comp" value="Y" >
				<label for="chk_comp"><span class="s_check"></span><spring:message code='Cache.lbl_TaskClose'/></label>
			</div>	
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_prc" value="N" checked>
				<label for="chk_prc"><span class="s_check"></span><spring:message code='Cache.lbl_goProcess'/></label>
			</div>	
		</span>	
		<select class="selectType01" id="selectSize">
			<option>10</option>
			<option>20</option>
			<option>30</option>
		</select>
		<button href="#" class="btnRefresh" type="button"></button>							
	</div>
	<div style="width:100%; min-height: 200px">
		<div id="collabStatisTeamGridDiv"></div>
	</div>	
	<!-- 컨텐츠 끝 -->
</div>

</div>
<script type="text/javascript">
var collabStatisTeam = {
		grdTeam : new coviGrid(),
		headerData : [
						{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true, formatter:function(){ return this.index+1}, sort:false},
						{key:'DeptName',  label:"<spring:message code='Cache.lbl_name'/>",width:'2',align:'left', formatter:function () {
		 		  			return (this.item.IsClose == "Y"?"["+this.item.ExecYear+"]":"")+this.item.DeptName;}
						},
						{key:'ManagerName',  label:"<spring:message code='Cache.lbl_apv_Admin'/>",width:'1',align:'center'},
						{key:'tmUser',  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'1',align:'center',display:true},
						{key:'',  label:"<spring:message code='Cache.lbl_StatisticsView'/>",width:'1',align:'center', display:true, sort:false, formatter:function () {
							return "<a href='#' class='btnTypeDefault btnSearchBlue01' id='btnStatic'><spring:message code='Cache.lbl_StatisticsView'/></a>";
	   		        	}},
						{key:'',  label:"<spring:message code='Cache.lbl_Move'/>",width:'1',align:'center', display:true, sort:false, formatter:function () {
		 		  			return "<a href='#' class='btnTypeDefault btnSearchBlue01' id='btnMove'><spring:message code='Cache.lbl_Move'/></a>";
	   		        	}},
						{key:'CloseDate',  label:"<spring:message code='Cache.lbl_TaskClose'/>",width:'1',align:'center', formatter:function(){
							return (this.item.CloseDate != null && this.item.CloseDate != ""? (this.item.CloseDate):"");
						}},
	     		],
		objectInit : function(){		
			collabUtil.getDeptList($("#divCollabStatisTeam #groupPath"),'', false, false, true);
			this.addEvent();
			this.searchData(1);
		}	,
		addEvent : function(){
			$('#divCollabStatisTeam #searchText' ).on( 'keypress', function(e){
				if(event.keyCode==13) {collabStatisTeam.searchData(1); return false;}
			});
			$('#divCollabStatisTeam #groupPath, #divCollabStatisTeam #selectSize' ).on( 'change', function(e){
				collabStatisTeam.searchData(1);
			});
			
			$('#divCollabStatisTeam #btnSearch, #divCollabStatisTeam .btnRefresh' ).on( 'click', function(e){
				collabStatisTeam.searchData(1);
			});
			
			$("#divCollabStatisTeam .check_class").click(function() {
				 $('#divCollabStatisTeam .check_class').not(this).prop("checked", false);
				 collabStatisTeam.searchData(1);
			});
			
			
			var configObj = {	
					targetID : "collabStatisTeamGridDiv",
					height : "auto",
					emptyListMSG:"<spring:message code='Cache.msg_NoDataList'/>",  //조회할 목록이 없습니다.
					paging:true,
					fitToWidth:true,
					viewMode :"grid",
					page : {pageNo: 1,pageSize: 10},
					colHead : collabStatisTeam.headerData,
					colGroup : collabStatisTeam.headerData};
			
//			collabStatisTeam.grdTeam = new coviGrid();
			collabStatisTeam.grdTeam.setConfig(configObj);
			collabStatisTeam.grdTeam._targetID = "collabStatisTeamGridDiv";


			
			//통계보기
			$(document).off("click","#divCollabStatisTeam #btnStatic").on("click","#divCollabStatisTeam #btnStatic",function(){
				var obj = collabStatisTeam;
				var gridData = obj.grdTeam.getSelectedItem();
				var item = gridData["item"];
				var popupID	= "CollabStatisDetailPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabStatis/CollabStatisDetailPopup.do?"
						 		+ "&prjType=T"+item.ExecYear
		 						+ "&prjSeq="+item.GroupID
		 						+ "&prjName="+encodeURI(item.DeptName)
		 						+ "&popupID="	 + popupID;
				Common.open("", popupID, "<spring:message code='Cache.lbl_StatisticsView'/>", popupUrl, "1000", "800", "iframe", true, null, null, true);
			});	

			//페이지 이동
			$(document).off("click","#divCollabStatisTeam #btnMove").on("click","#divCollabStatisTeam #btnMove",function(){
				var obj = collabStatisTeam;
				var gridData = obj.grdTeam.getSelectedItem();
				var item = gridData["item"];
				var popupID	= "CollabMainView";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collab/CollabMainView.do?"
						 		+ "&prjType=T"+item.ExecYear
								+ "&prjSeq="+item.GroupID
		 						+ "&prjName="+encodeURI(item.DeptName)
		 						+ "&popupID="	 + popupID;
				Common.open("", popupID, item.DeptName, popupUrl, "1200", "800", "iframe", true, null, null, true);
			});	
			
		},
		searchData:function(pageNo){

			var params = {"isClose" : $('#divCollabStatisTeam .check_class:checked').val(), "groupPath":$("#divCollabStatisTeam #groupPath").val(),"searchText":$("#divCollabStatisTeam #searchText").val().trim()};

			if (pageNo !="-1"){
				collabStatisTeam.grdTeam.page.pageNo =pageNo;
				collabStatisTeam.grdTeam.page.pageSize = $('#divCollabStatisTeam #selectSize').val();
			}
			// bind
			collabStatisTeam.grdTeam.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabStatis/getStatisTeamCurst.do"
			});
		},
		formatManager:function (mmUser){
			if (mmUser== null || mmUser == "") return "";
			var str=mmUser.split("|");
			var ret = mmUser;
			if (str.length>0) {
				var usrs = str[0].split("^");
				if (usrs.length>0) ret = usrs[1]+ ' <spring:message code="Cache.lbl_att_and" />'+(usrs.length-1); //외
			}
			return ret;
		}
}

$(document).ready(function(){
	collabStatisTeam.objectInit();
});

</script>