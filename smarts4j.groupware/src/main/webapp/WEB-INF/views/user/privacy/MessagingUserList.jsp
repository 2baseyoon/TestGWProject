<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>

.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic'; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
.AXanchorDateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
</style>

<div class='cRConTop titType'>
		<h2 class="title"><spring:message code='Cache.CN_362'/></h2>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="myInfoContainer myInfoMsgCont">
		<div class="boradTopCont anniversaryTop">			
			<div id="divDate" >
				<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span>  
				<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly>
			</div>		
				<a onclick="msgListObj.grid.searchData();" class="btnTypeDefault" ><spring:message code="Cache.btn_search"/></a>
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCntSel" >
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
			</div>
		</div>	
		<div class="anniversaryBtm">
			<div class="tblList tblCont">
				<div id="gridDiv">
				</div>
			</div>
		</div>
	</div>
</div>	

<script>
	var msgListObj = {
		pageStart: function () {
			var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");

			$("#EndDate").bindTwinDate({
				startTargetID : "StartDate",
				separator : ".",
				onChange:function(){
					msgListObj.grid.searchData(1);
				},
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
		
					//오늘 클릭시
			$(".calendartoday").click(function(){
				$("#StartDate").val(g_curDate);
				$("#EndDate").val(g_curDate);
				msgListObj.grid.searchData(1);		
				
			});

			if ($("#StartDate").val()==""){
				var gDate =  $("#StartDate").val();
				$("#StartDate").val(g_curDate);
				$("#EndDate").val(g_curDate);
				$("#dateTitle").text($("#StartDate").val() + "~" + $("#EndDate").val());
			}

			$(".cal").bind("click", function(){
				$(".AXanchorDateHandle").trigger("click");
			});
			
			msgListObj.util.searchType();
		},	
		util:{
			mediaType : '',
			searchType:function(){
				$.ajax({
					type:"POST",
					data:{"codeGroups" : "NotificationMedia"},
					url:"/covicore/basecode/get.do",
					success:function (data) {
						if(data.result == "ok"){
							msgListObj.util.mediaType=data.list[0]["NotificationMedia"];
							msgListObj.grid.bind();
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
			},
			inArray:function(findStr, arrayList, col){
				for (var i=0; i < arrayList.length; i++){
					if (col != "")
						if (arrayList[i][col] == findStr)	return true;
					else
						if (arrayList[i] == findStr)	return true;
				}
				return false;
			},
			getMedia:function(data, filterType){
				var mediaList = data.MediaType.split(";");//사용가능한 매체
				return msgListObj.util.inArray(filterType, mediaList)?"√":"";
			},
			findMedia:function(filterType){
				return msgListObj.util.inArray(filterType, msgListObj.util.mediaType, "Code");
			}			
		},
		grid:{
			myGrid:new coviGrid(),
			bind: function () {
				msgListObj.grid.myGrid.setGridConfig({
						targetID: "gridDiv",
						height:"auto",			
						page : {pageNo: 1,pageSize: 10},
						colGroup: [
				             {key:'MsgType',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'100', align:'left'},
				             {key:'MessagingSubject',  label:'<spring:message code="Cache.lbl_Subject"/>', width:'150', align:'left'},
		            		 {key:'MessagingState',  label:'<spring:message code="Cache.lbl_ProcessStatus"/>', width:'100', align:'center',formatter:function(){
		            			 	switch(this.item.MessagingState){
			            			 	case "1":return "전송대기";break;
			            			 	case "2":return "결과대기";break;
			            			 	case "3":return "완료";break;
			            			 	case "4":return "취소";break;
			            			 	case "5":return "오류";break;
		            			 	}
		            		 	}
				             },
		            		 {key:'SenderCode',  label:'<spring:message code="Cache.lbl_apv_history_mail_sender"/>', width:'100', align:'left'},
		            		 {key:'ReservedDate',  label:'<spring:message code="Cache.lbl_SendDateTime"/>', width:'100', align:'left'},
		            		 {key:'',  label:'MAIL ', width:'50', align:'center',  display:msgListObj.util.findMedia('MAIL'), formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MAIL")}
		            		 },	
		            		 {key:'',  label:'TODO ', width:'50', align:'center',  display:msgListObj.util.findMedia('TODOLIST'), formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "TODOLIST")}
		            		 },	
		            		 {key:'',  label:'PUSH ', width:'50', align:'center',  display:msgListObj.util.findMedia('MDM'), formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MDM")}
		            		 },	
		            		 {key:'',  label:'EUM', width:'50', align:'center',  display:msgListObj.util.findMedia('MESSENGER'), formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MESSENGER")}
		            		 },	
						]
					}
				);
				msgListObj.grid.searchData();
			},
			searchData: function () {
				msgListObj.grid.myGrid.page.pageNo = 1;
				msgListObj.grid.myGrid.page.pageSize= 10;
				
				msgListObj.grid.myGrid.bindGrid({
					ajaxUrl:"/covicore/user/messaging/selectMessagingList.do",
		 			ajaxPars: {"domain": 0,"startDate":$("#StartDate").val(),"endDate":$("#EndDate").val()}
				});
			},
		}
	};
	
jQuery(document.body).ready(function () {
	msgListObj.pageStart();
});
</script>
