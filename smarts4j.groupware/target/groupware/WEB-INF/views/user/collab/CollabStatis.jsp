<%@page import="egovframework.coviframework.util.StringUtil"%>
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
	
	String projectState = StringUtil.replaceNull(request.getParameter("projectState"),"");
%>
<div id="divCollabStatis">
<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_project_dashboard'/></h2>
	<div class="searchBox02">
		<span><input type="text" id="searchText"  />
		<button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContCollabo mScrollVH'>
	<div class="selectBox" id="selectBoxDiv">
		<div class="chkStyle10">
			<input type="checkbox" class="check_class" id="chk_prj_comp" value="Y" >
			<label for="chk_prj_comp"><span class="s_check"></span><spring:message code='Cache.lbl_TaskClose' /></label>
		</div>	
		<div class="chkStyle10" style="margin-right:10px;"><span class="s_check">|</span></div>
		<span id="prjStatus" style="margin-right:50px;">
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_w" value="W" >
				<label for="chk_w"><span class="s_check"></span><spring:message code='Cache.lbl_Ready' /></label> <!-- 대기 -->
			</div>	
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_p" value="P" checked>
				<label for="chk_p"><span class="s_check"></span><spring:message code='Cache.lbl_Progress' /></label> <!-- 진행 -->
			</div>	
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_h" value="H" >
				<label for="chk_h"><span class="s_check"></span><spring:message code='Cache.lbl_Hold' /></label> <!-- 보류 -->
			</div>	
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_f" value="F" >
				<label for="chk_f"><span class="s_check"></span><spring:message code='Cache.lbl_Cancel' /></label> <!-- 취소 -->
			</div>	
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="chk_c" value="C" >
				<label for="chk_c"><span class="s_check"></span><spring:message code='Cache.lbl_Completed' /></label> <!-- 완료 -->
			</div>
		</span>	
		<select class="selectType01" id="selectSize">
			<option>10</option>
			<option>20</option>
			<option>30</option>
		</select>
		<button href="#" class="btnRefresh" type="button"></button>							
		<button href="#" class="btnMoreStyle01 btnExcel" id="btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></button> 
	</div>
	<div style="width:100%; min-height: 200px">
		<div id="collabStatisGridDiv"></div>
	</div>	
</div>
</div>
<script type="text/javascript">
var collabStatis = {
		gridStatis : new coviGrid(),
		headerData:	[{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'30', align:'center', display:true, formatter:function(){ return this.index+1}, sort:false},
					{key:'PrjName',  label:"<spring:message code='Cache.lbl_project_name'/>",width:'130',align:'left',display:true, formatter:function(){
   		        		return String.format("<a href='#' id='btnMove'>{0}</a>", this.item.PrjName);
						//return (this.item.IsClose == 'Y'?"[<spring:message code='Cache.lbl_TaskClose'/>]":"")+this.item.PrjName;
   		        	}}, 
   		        	{key:'Remark',  label:"<spring:message code='Cache.lbl_Memo'/>",width:'120',align:'left',display:true, sort:false, formatter:function(){
   		        		return unescape(coviCmn.isNull(this.item.Remark,''));
   		        	}},  
   		        	{key:'MmUser',  label:"<spring:message code='Cache.lbl_apv_Admin'/>",width:'100',align:'center',display:true, formatter:function(){
   		        		return collabUtil.formatManager(this.item.MmUser);
   		        	}},  
					{key:'TF_Period',  label:"<spring:message code='Cache.lbl_scope'/>",width:'120',align:'center',display:true, formatter:function(){
						return coviCmn.getDateFormat(this.item.StartDate) + '~' + coviCmn.getDateFormat(this.item.EndDate);
					}},
					{key:'TmUserCnt',  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'50',align:'center',display:true},
					{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_Status'/>",width:'80',align:'center',display:true, formatter:function(){
						switch (this.item.PrjStatus)
						{
							case "W":
								return "<spring:message code='Cache.lbl_Ready' />"; //대기
								break;
							case "H":
								return "<spring:message code='Cache.lbl_Hold' />"; //보류
								break;
							case "C":
								return "<spring:message code='Cache.lbl_Completed' />"; //완료
								break;
							case "F":
								return "<spring:message code='Cache.lbl_Cancel' />"; //취소
								break;
							default:
								return "<spring:message code='Cache.lbl_Progress' />"; //진행
								break;
						}
					}},
					{key:'ProgRate',  label:"<spring:message code='Cache.lbl_ProgressRate'/>",width:'70',align:'center',display:true, formatter:function(){
						return Math.round(this.item.ProgRate*10)/10+"%";
					}},
					{key:'',  label:"<spring:message code='Cache.lbl_StatisticsView'/>",width:'90',align:'center', display:true, sort:false, formatter:function () {
	 		  			return String.format("<a href='#' title='{0}' class='btnTypeDefault btnSearchBlue01' id='btnStatic'>{1}</a>", this.item.PrjName, "<spring:message code='Cache.lbl_StatisticsView'/>");
   		        	}},
					{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_RegDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'100',align:'center',display:true, formatter:function(){
						return (this.item.RegisteDate != null && this.item.RegisteDate != ""? CFN_TransLocalTime(this.item.RegisteDate):"");
					}},
					{key:'CloseDate',  label:"<spring:message code='Cache.lbl_TaskClose'/>",width:'100',align:'center', formatter:function(){
						return (this.item.CloseDate != null && this.item.CloseDate != ""? (this.item.CloseDate):"");
					}},
     		],
		objectInit : function(){	
			this.addEvent();
			this.searchData(1);
		}	,
		addEvent : function(){
			$("#divCollabStatis .check_class").click(function() {
				//마감이 체크 되면 다른건 체크 못함
				if ($(this).prop("checked")){
					if ($(this).attr("id") == "chk_prj_comp" ){
						$("#divCollabStatis #prjStatus .check_class").prop("checked", false);
					}
					else{
						$("#divCollabStatis #chk_prj_comp").prop("checked", false);
					}
				}	
				collabStatis.searchData(1);
			});

			$('#divCollabStatis #searchText' ).on( 'keypress', function(e){
				if(event.keyCode==13) {collabStatis.searchData(1); return false;}
			});
			$('#divCollabStatis #selectSize' ).on( 'change', function(e){
				collabStatis.searchData(1);
			});
			
			$('#divCollabStatis #btnSearch, #divCollabStatis .btnRefresh' ).on( 'click', function(e){
				collabStatis.searchData(1);
			});
			$('#divCollabStatis #btnExcel').on( 'click', function(e){
				collabStatis.exportExcel();
			});
			
			var configObj = {targetID : "collabStatisGridDiv",
					height : "auto",
					emptyListMSG:"<spring:message code='Cache.msg_NoDataList'/>",  //조회할 목록이 없습니다.
					paging:true,
					fitToWidth:true,
					viewMode :"grid",
					page : {pageNo: 1,pageSize: 10},
					colGroup : collabStatis.headerData,
					colHead : collabStatis.headerData};
			
			collabStatis.gridStatis.setConfig(configObj);
			collabStatis.gridStatis._targetID = "collabStatisGridDiv";

			//통계보기
			$(document).off("click","#collabStatisGridDiv #btnStatic").on("click","#collabStatisGridDiv #btnStatic",function(){
				var obj = collabStatis;
				var gridData = obj.gridStatis.getSelectedItem();
				var item = gridData["item"];
				var popupID	= "CollabProjectAllocPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabStatis/CollabStatisDetailPopup.do?"
						 		+ "&prjType="+"P"
		 						+ "&prjSeq="+item.PrjSeq
		 						+ "&prjName="+encodeURI(item.PrjName)
		 						+ "&popupID="	 + popupID;
				Common.open("", popupID, "<spring:message code='Cache.lbl_StatisticsView'/>", popupUrl, "1000", "800", "iframe", true, null, null, true);
			});	

			//페이지 이동
			$(document).off("click","#collabStatisGridDiv #btnMove").on("click","#collabStatisGridDiv #btnMove",function(){
				var obj = collabStatis;
				var gridData = obj.gridStatis.getSelectedItem();
				var item = gridData["item"];
				if ((item.IsManager == "Y" || 		item.IsMember == "Y" 	|| item.IsRegister == "Y") && $('.collaboMenu #list_P_'+item.PrjSeq).length>0){//프로젝트 멤버인 경우 탭으로 이동
					$('.collaboMenu #list_P_'+item.PrjSeq).trigger("click");
				}
				else{
					//				collabMenu.goTab(this, objId, prjName, "MAIN", "/groupware/collab/CollabMain.do?param="+encodeURI($(this).text()),dataMap);
					var popupID	= "CollabProjectAllocPopup";
			 		var openerID	= "";
			 		var popupYN		= "N";
			 		var popupUrl	= "/groupware/collab/CollabMainView.do?"
			 						+ "&prjSeq="+item.PrjSeq
			 						+ "&prjName="+encodeURI(item.PrjName)
			 						+ "&popupID="	 + popupID;
					Common.open("", popupID, item.PrjName, popupUrl, "1600", "800", "iframe", true, null, null, true);
				}
			});	
		},
		searchData:function(pageNo){
			var trgArr = new Array();
			$('#divCollabStatis #prjStatus .check_class:checked').each( function (i, v) {
				trgArr.push($(v).val())
			})

			var params = {"mode" : "L","isClose": $('#divCollabStatis #chk_prj_comp').prop("checked")?"Y":"N"
					, "searchText":$('#divCollabStatis #searchText' ).val()
					, "prjStatus"	:$('#divCollabStatis #chk_prj_comp').prop("checked")?"":trgArr.toString()};
			
			if (pageNo !="-1"){
				collabStatis.gridStatis.page.pageNo =pageNo;
				collabStatis.gridStatis.page.pageSize = $('#divCollabStatis #selectSize').val();
			}
			collabStatis.gridStatis.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabStatis/getStatisList.do"
			});
			
		},//엑셀
        exportExcel: function(e){
			var trgArr = new Array();
			$('#divCollabStatis #prjStatus .check_class:checked').each( function (i, v) {
				trgArr.push($(v).val())
			})
        	var params = "isClose="+($('#divCollabStatis #chk_prj_comp').prop("checked")?"Y":"N")+
					 "&searchText="+$('#divCollabStatis #searchText' ).val()+
					 "&prjStatus="+($('#divCollabStatis #chk_prj_comp').prop("checked")?"":trgArr.toString());

	        if (confirm(Common.getDic("msg_WantToDownload"))) { //다운로드 하시겠습니까?
	            location.href= '/groupware/collabStatis/exportStatisList.do?'+params;
	        }
        }
}

$(document).ready(function(){
	collabStatis.objectInit();
});
</script>
