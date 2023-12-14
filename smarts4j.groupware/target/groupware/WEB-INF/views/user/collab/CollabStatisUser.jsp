<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.DicHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%		String modeList[][] = {{"TotCnt",DicHelper.getDic("lbl_TotalNumber")},{"CompCnt",DicHelper.getDic("lbl_Completed")},{"WaitCnt",DicHelper.getDic("lbl_Ready")},{"ProcCnt",DicHelper.getDic("lbl_Progress")},{"HoldCnt",DicHelper.getDic("lbl_Hold")}
,{"ImpCnt",DicHelper.getDic("lbl_Important")},{"EmgCnt",DicHelper.getDic("lbl_Urgency")},{"DelayCnt",DicHelper.getDic("lbl_Delay")}
,{"NowCompCnt",DicHelper.getDic("lbl_Completed_To")}	,{"NowNoCnt",DicHelper.getDic("lbl_UnList_To")}	,{"NowTotCnt",DicHelper.getDic("lbl_Whole_To")}};
 %>
<style>
.AXGrid input:disabled{background-color:#Eaeaea}
.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
#inputBasic_AX_EndDate_AX_dateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
.adLine { display:inline-block; vertical-align:middle; width:15px; font-size:24px; font-weight:600; }
#divDate { margin-top:-3px; }
.pagingType02 { margin-left:2px; }

</style>
<div id="divCollabStatisUser">
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_User_Statistics'/></h2>	
	<div id="divDate" >
		<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span> 
		<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly>
	</div>											
	<div class="searchBox02">
		<span><input type="text" id="searchText"  />
		<button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContCollabo mScrollVH'>
	<div class="selectBox" id="selectBoxDiv" style="padding-top:5px;overflow:hidden">
		<span style="float:left;">
			<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
			<select class="size112" id="groupPath"></select>
		</span>	
		<select class="selectType01" id="selectSize" style="display:none">
			<option>10</option>
			<option>20</option>
			<option>30</option>
		</select>
		<span id="statusCheckSpan" style="margin-right:50px;">
		<%for (int i=0; i<modeList.length; i++){ %>
			<div class="chkStyle10">
				<input type="checkbox" class="check_class chk_mode" id="chk_mode_<%=i%>" <%=(modeList[i][0].equals("ProcCnt")?"checked":"")%> value="<%=modeList[i][0]%>" >
				<label for="chk_mode_<%=i%>"><span class="s_check"></span><%=modeList[i][1]%></label>
			</div>	
		<%} %>
		</span>
			<div class="chkStyle10">
				<a href="#" class="btnListView listViewType01" data-tab="atab-1" data-view="LIST"></a> 
			</div>	
			<div class="chkStyle10 ml0">
				<a href="#" class="btnListView listViewType02 active" data-tab="atab-2" data-view="KANB"></a>
			</div>	
		<button href="#" class="btnRefresh" type="button"></button>							
		<button href="#" class="btnMoreStyle01 btnExcel" id="btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></button> 
	</div>
	<div class="Project_tabCont"  style="width:100%; min-height: 200px; display:none;top: 110px;" id="atab-1">
		<div id="collabStatisUserGridDiv"></div>
	</div>	
  	<div class="Project_tabCont" id="atab-2" style="top: 110px;">
		<div class="tstab_cont active">
			<div class="container-fluid active" id="collabStatisUserItem">
				<div class="row">
				</div>
			</div>
		</div>				
	</div>	
	<!-- 컨텐츠 끝 -->
</div>

</div>
<script type="text/javascript">
var collabStatisUser = {
		grdUser : new coviGrid(),
		g_curDate : CFN_GetLocalCurrentDate("yyyy.MM.dd"),
		dataMode:'KANB',
		headerData : [
						{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'55', align:'center', display:true, formatter:function(){ return this.index+1}, sort:false},
						{key:'DisplayName',  label:"<spring:message code='Cache.lbl_name'/>",width:'109',align:'left'},
						{key:'PrjCnt',  label:"<spring:message code='Cache.lbl_Project'/>",width:'109',align:'center',formatter:function(){
	      		  			return this.item.PrjCnt=="0"?"":"<a href='#' id='btnPrjInfo'>"+this.item.PrjCnt+"</a>";      		  			
						}},
						<c:forEach var="item" items="${modeList}"  varStatus="status">
						{key:'${item[0]}',  label:"<spring:message code='Cache.${item[1]}'/>",width:'109',align:'center',formatter:function(){
	      		  			return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";      		  			
						}},
						</c:forEach>
						{key:'ProgRate',  label:"<spring:message code='Cache.lbl_TheProgression'/>",width:'87',align:'center',display:true, formatter:function(){ //진행율
							return this.item.NowTotCnt>0?this.item.ProgRate+"%":"";
						}},
	     		],
		objectInit : function(){		
			collabUtil.getDeptList($("#divCollabStatisUser #groupPath"),'<%=SessionHelper.getSession("GR_GroupPath")%>', false, false, true);
			$("#divCollabStatisUser #EndDate").bindTwinDate({
				startTargetID : "StartDate",
				separator : ".",
				onChange:function(){
					collabStatisUser.searchData(1);
				},
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
			$("#divCollabStatisUser #StartDate").val(schedule_SetDateFormat(new Date(this.g_curDate.substring(0,4), (this.g_curDate.substring(5,7) - 1), 1), '.'));
			$("#divCollabStatisUser #EndDate").val(this.g_curDate);
			
			this.addEvent();
			this.searchData(1);
		}	,
		addEvent : function(){
			$('#divCollabStatisUser #searchText' ).on( 'keypress', function(e){
				if(event.keyCode==13) {collabStatisUser.searchData(1); return false;}
			});
			$('#divCollabStatisUser #groupPath, #divCollabStatisUser #selectSize' ).on( 'change', function(e){
				collabStatisUser.searchData(1);
			});

			$('#divCollabStatisUser #btnSearch, #divCollabStatisUser .btnRefresh' ).on( 'click', function(e){
				
				collabStatisUser.searchData(1);
			});
			
			$("#divCollabStatisUser .chk_mode").click(function() {
				 $('#divCollabStatisUser .chk_mode').not(this).prop("checked", false);
				 collabStatisUser.searchData(1);
			});

			$('#divCollabStatisUser #btnExcel').on( 'click', function(e){
				collabStatisUser.exportExcel();
			});
			
			$('#divCollabStatisUser .btnListView').on('click',  function (e) {
				$("#divCollabStatisUser .btnListView").removeClass('active');
				$(this).addClass('active');
				var tab_id = $(this).attr('data-tab');
				
				$('#divCollabStatisUser .Project_tabCont').hide();
				$('#divCollabStatisUser #'+tab_id ).show();
				
				if(tab_id == "atab-1") {
					$("#statusCheckSpan").hide();
				}
				else {
					$("#statusCheckSpan").show();
				}
				
				collabStatisUser.dataMode= $(this).attr('data-view');
				collabStatisUser.searchData(1);
			});
			//타스트 상세
			$(document).off('click', '#divCollabStatisUser #cardTitle').on('click', '#divCollabStatisUser #cardTitle', function () {
				collabUtil.openObjectPopup("CollabTaskPopup", "", $(this).data());
				
			});

			//프로젝트보기
			$(document).on("click","#collabStatisUserGridDiv #btnPrjInfo",function(){
				var obj = collabStatisUser.grdUser;
				var gridData =obj.getSelectedItem()["item"];
				var popupID	= "CollabProjectAllocPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabStatis/CollabStatisProjectPopup.do?"
		 						+ "&userCode="+gridData.UserCode
		 						+ "&userName="+encodeURIComponent(gridData.DisplayName)
		 						+ "&popupID="	 + popupID;

				Common.open("", popupID, "<spring:message code='Cache.lbl_Project'/>", popupUrl, "800", "400", "iframe", true, null, null, true);
			});		
			//통계보기
			$(document).on("click","#collabStatisUserGridDiv #btnStatic",function(){
				var obj = collabStatisUser.grdUser;
				var gridData =obj.getSelectedItem()["item"];
				var gridCol = obj._colGroup;
				var colKey = $(this).attr("mode");
				var colLabel 
				$.each(gridCol, function( idx, item ){
					if (item.key == colKey){
						colLabel= item.label;
						return;
					}	
				});
				var popupID	= "CollabStatisPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabStatis/CollabStatisPopup.do?"
		 						+ "groupKey=Member"
		 						+ "&groupCode="+gridData.UserCode
		 						+ "&groupName="+encodeURIComponent(gridData.DisplayName)
		 						+ "&mode="+colKey
		 						+ "&modeName="+encodeURIComponent(colLabel)
		 						+ "&startDate="+$("#divCollabStatisUser #StartDate").val()
								+ "&endDate="+$("#divCollabStatisUser #EndDate").val()
		 						+ "&popupID="	 + popupID;

				Common.open("", popupID, "<spring:message code='Cache.lbl_apv_processState'/>", popupUrl, "1200", "650", "iframe", true, null, null, true);
			});		
		},
		searchData:function(pageNo){
			var objId = "collabStatisUserItem"
			var trgArr = new Array();
			var params = {"groupPath":$("#divCollabStatisUser #groupPath").val()
						,"searchText":$("#divCollabStatisUser #searchText").val().trim()
						,"startDate":$("#divCollabStatisUser #StartDate").val()
						,"endDate":$("#divCollabStatisUser #EndDate").val()};
			if (collabStatisUser.dataMode == "KANB"){
				params["mode"]=$('#divCollabStatisUser .chk_mode:checked').val();
				$.ajax({
		    		type:"POST",
		    		data:params,
		    		url:"/groupware/collabStatis/getStatisUserData.do",
		    		success:function (data) {
		    			if (data.taskFilter.length >0){
		    				$('#'+objId+' .row').empty().append(
		    					data.taskFilter.map( function( item,idx ){
		    						var prjData = {"myTodo":"N", "prjAdmin":"N","prjMember":"N"}
		    						return collabMain.drawSection(item, prjData, "MEM", "");
		    					})
		    				);
		    			}
		    			else{
		    				$('#'+objId+' .row').empty();
		    			}
	
		    			$('#'+objId+' .row .card').remove();
		    			$('#'+objId+' .nodata_type03').remove();
		    			
		    			$('#'+objId+' .row').show();
		    			//타스크 콕록
		    			$('#'+objId+' .row .column_num').text(0);
		    			if (data.taskFilter.length >0){
		    	        	data.taskData.map( function( taskList,idx ){
		    	        		var page = taskList["page"];
		    	        		var key = "";
		    	        		if (taskList["list"].length>0){
	   					    		key = 'section_'+taskList["key"]["UserCode"];
		    			    		$('#'+objId+' .row #'+key+' .column_num').text(page["listCount"]);
		    		        		
		    		        		taskList["list"].map( function( item,idx ){
	    		        				var objAddId=item.UserCode;
	    			        			var objAddId= '#'+objId+' .row #'+key;
	    			        			item.authSave=="N";
	   			        				$(objAddId + " .cardBox_area").append(collabUtil.drawTask(item,"TODO","KANB", "MEM", "N"));
		    						});
		    	        		}	
		    				});
		    			}
		    		},
		    		error:function (request,status,error){
		    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		    		}
		    	});
			}else{
				var configObj = {	targetID : "collabStatisUserGridDiv",height : "auto",
						page : {pageNo: 1,pageSize: 10,},
						paging:true,
						emptyListMSG:Common.getDic("msg_NoDataList"),
						colHead:{rows: [ [
						                  {colSeq:0, rowspan:2},
						                  {colSeq:1, rowspan:2},
						                  {colSeq:2, rowspan:2},
						                  {colSeq:3, rowspan:2},
						                  {colSeq:4, rowspan:2},
						                  {colSeq:5, rowspan:2},
						                  {colSeq:6, rowspan:2},
						                  {colSeq:7, rowspan:2},
						                  {colSeq:null, colspan:2, label:"<spring:message code='Cache.lbl_Progress' />", align:"center"}, //진행
						                  {colSeq:10, rowspan:2},
						                  {colSeq:null, colspan:3, label:"Today", align:"center"},
						                  {colSeq:14, rowspan:2}
						              ],
						              [{colSeq:8},{colSeq:9},{colSeq:11},{colSeq:12},{colSeq:13}]
						          ]},
					colGroup : collabStatisUser.headerData};
				
				collabStatisUser.grdUser.setConfig(configObj);
				collabStatisUser.grdUser._targetID= "collabStatisUserGridDiv";
	
				if (pageNo !="-1"){
					collabStatisUser.grdUser.page.pageNo =pageNo;
					collabStatisUser.grdUser.page.pageSize = $('#divCollabStatisUser #selectSize').val();
				}

				collabStatisUser.grdUser.bindGrid({
					ajaxPars : params,
					ajaxUrl:"/groupware/collabStatis/getStatisUserCurst.do"
				});
				

			}
		},//엑셀
        exportExcel: function(e){
			var params ="groupPath="+$("#divCollabStatisUser #groupPath").val()+
						"&searchText="+$("#divCollabStatisUser #searchText").val().trim()+
						"&startDate="+$("#divCollabStatisUser #StartDate").val()+
						"&endDate="+$("#divCollabStatisUser #EndDate").val();
	        if (confirm(Common.getDic("msg_WantToDownload"))) { //다운로드 하시겠습니까?
	            location.href= '/groupware/collabStatis/exportStatisUserCurst.do?'+params;
	        }
        }
}

$(document).ready(function(){
	collabStatisUser.objectInit();
});

</script>