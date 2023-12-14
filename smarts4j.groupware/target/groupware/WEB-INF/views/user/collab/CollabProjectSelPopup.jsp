<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="collabo_popup_wrap" id="divCollabStatis">
	<div class="searchBox02">
		<span><input type="text" id="searchText"  />
		<button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<div class="chkStyle10">
			<input type="checkbox" class="check_class" id="chk_prj_comp" value="Y" >
			<label for="chk_prj_comp"><span class="s_check"></span><spring:message code='Cache.lbl_TaskClose' /></label>
		</div>	
		<span id="prjStatus">
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
	</div>
	<div id="collabStatisGridDiv"></div>
	<div class="bottom">
		<a id="btnConfirm" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_Confirm'/></a> <!-- 확인 -->
		<a id="btnCancel" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
	</div>
</div>
<script type="text/javascript">
var collabStatis = {
		gridPrj : new coviGrid(),
		headerData:	[{key:'chk', label:'chk', width:'10', align:'center', formatter: 'checkbox', formatter:'checkbox'}, 
					{key:'PrjName',  label:"<spring:message code='Cache.lbl_project_name'/>",width:'100',align:'left',display:true, formatter:function(){
   		        		return (this.item.IsClose == 'Y'?"[<spring:message code='Cache.lbl_TaskClose'/>]":"")+this.item.PrjName;
   		        	}}, 
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
					{key:'ProgRate',  label:"<spring:message code='Cache.lbl_ProgressRate'/>",width:'80',align:'center',display:true, formatter:function(){
						return Math.round(this.item.ProgRate*10)/10+"%";
					}}
     		],
		objectInit : function(){	
			this.addEvent();
			this.searchData(1);
		}	,
		addEvent : function(){
			$('#divCollabStatis .check_class' ).on( 'click', function(e){
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
			
			$("#btnConfirm").on("click", function(){
				collabStatis.setProjectSel();
			});
			
			$("#btnCancel").on("click", function(){
				Common.Close();
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
			
			collabStatis.gridPrj.setConfig(configObj);
			collabStatis.gridPrj._targetID = "collabStatisGridDiv";

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
				collabStatis.gridPrj.page.pageNo =pageNo;
				collabStatis.gridPrj.page.pageSize = $('#divCollabStatis #selectSize').val();
			}
			collabStatis.gridPrj.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabStatis/getStatisList.do"
			});
			
		},
		setProjectSel : function(){
			var result = { "list":		collabStatis.gridPrj.getCheckedList(0)			};

			window.parent.postMessage({
				  "functionName": "setProjectSel"
				, "params": result
			}, '*');
			Common.Close();
		}
}

$(document).ready(function(){
	collabStatis.objectInit();
});
</script>