<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.biztaskImg{
	width: 318px;
	height: 380px;
	padding: 15px;
	float : left;
}

.tList {
	width: calc(100% - 338px);
	height: 380px;
}

.OWListBox {
	margin : 5px; 
}
.gridDiv{
	margin : 10px;
}
.selectDiv {
	margin : 10px;
}
.selectDiv select{
	width : 80px;
}
.selectYear{
	float: right;
	width: 60px;
}

/*
	pie chart
*/
.cycleCont > .bizTask_cycleSlice > .pie {
	position:absolute;
	width:100%;
	height:100%;
	clip:rect(0em,101px,201px,0em);
	-moz-border-radius:101px;
	-webkit-border-radius:101px;
	border-radius:101px;
}
.cycleCont > .bizTask_cycleSlice > .pie.fill {display:none;-moz-transform:rotate(180deg) !important;-webkit-transform:rotate(180deg) !important;-o-transform:rotate(180deg) !important;transform:rotate(180deg) !important;}
.cycleCont > .bizTask_cycleSlice.gt50 > .pie.fill {display:block;}
.cycleCont > .bizTask_cycleSlice {position:absolute;width:202px;height:201px;clip:rect(0px,202px,201px,101px);}
.cycleCont > .bizTask_cycleSlice.gt50 {clip:rect(auto, auto, auto, auto);} 

.cyclePrograssBarper {margin-top:10px; border:none;}
.cyclePrograssBarper > div {font-size:15px; border:none; text-align:center;}
.cyclePrograssBarper > div > .num {float:none; margin:0 0 0 5px; padding:0 5px; width:auto; min-width:26px; height:26px; line-height:24px;}


.cyclePrograssBarper .b_progress_num > .num{background-color: #6892F2;}
.cyclePrograssBarper .b_delay_num > .num{background-color: #3170d4;}
.cyclePrograssBarper .b_complete_num > .num{background-color: #26acf4;}
.cyclePrograssBarper .b_waiting_num > .num{background-color: #5FCAFA;}

.cyclePrograssBarper div { cursor: pointer; } 
.cycleTxt { cursor: pointer; } 
</style>

<!-- 통합업무관리 포탈 시작-->
<!-- 리스트 시작 -->
<div class="cRContBottom mScrollVH ITMPortalCont">
	<div class="ITMPortalWrap">
		<p class="ITMTopTitle"><spring:message code='Cache.lbl_myworkreport' /></p><!-- 나의업무현황 -->
		<div class="workboard">
			<div class="prograssArea prograss_Project">	<!-- 업무그래프 -->
				<div class="PrograssImg OWListBox biztaskImg">
					<h3 style="display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 60%;" title="<spring:message code='Cache.lbl_tf_collaboration_status' />"><spring:message code='Cache.lbl_tf_collaboration_status' /></h3> <!-- 협업 업무 현황 -->
					<select class="selectYear" id="" data-targettype="Project"><!-- 연도설정 -->
					</select>	
					<div class="cyclePrograssBarimg">
						<div class="cyclePrograssBar" style=" margin-left: 40px;">
						<div class="cycleCont circle_Project">
							<div class="cycleBg bizTask_cycleTotal">
								<div class="pie" style="border: 40px solid rgb(38, 172, 244);"></div>
							</div>
							<div class="bizTask_cycleSlice">
								<div class="pie bizTask_pieDiv"></div>
								<div class="pie fill"></div>
							</div>
							<div class="bizTask_cycleSlice">
								<div class="pie bizTask_pieDiv"></div>
								<div class="pie fill"></div>
							</div>
							<div class="bizTask_cycleSlice">
								<div class="pie bizTask_pieDiv"></div>
								<div class="pie fill"></div>
							</div>
						</div>
						<div class="cycleTxt" onclick="setGridSearchEvent(this);" data-type-status="Project_" style="background: none; top: -35px;">
							<p><spring:message code='Cache.lbl_MyWork' /></p> <!-- 내업무 -->
							<p>
								<span id="myTaskTxt_Project">0</span> <spring:message code='Cache.lbl_apv_item' /> <!-- 건 -->
							</p>
						</div>
					</div>
					</div>
					<div class="cyclePrograssBarper">
						<div class="b_progress_num" data-type-status="Project_Process">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_goProcess' />"><spring:message code='Cache.lbl_goProcess' /></span> <!-- 진행 -->
							<span class="num">0</span>
						</div>
						<div class="b_complete_num" data-type-status="Project_Complete">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_apv_completed' />"><spring:message code='Cache.lbl_apv_completed' /></span> <!-- 완료 -->
							<span class="num">0</span>
						</div>
						<div class="b_waiting_num" data-type-status="Project_Waiting">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_apv_inactive' />"><spring:message code='Cache.lbl_apv_inactive' /></span> <!-- 대기 -->
							<span class="num">0</span>
						</div>
						<div class="b_delay_num" data-type-status="Project_Delay">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_Delay' />"><spring:message code='Cache.lbl_Delay' /></span> <!-- 지연 -->
							<span class="num">0</span>
						</div>
					</div>
				</div>
				<div class="fLeft tList OWListBox"> <!-- 업무 리스트 grid -->
					<div class="selectDiv">
						<select class="selectState" id="Project_state" data-targettype="Project"></select>
					</div>
					<div class="gridDiv" id="portal_projectGrid"></div> 
				</div>
			</div>
			
			<div class="prograssArea prograss_Work"> <!-- 내 업무그래프 -->
				<div class="PrograssImg OWListBox biztaskImg">
					<h3 style="display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 60%;" title="<spring:message code='Cache.lbl_tf_general_business_mng' />"><spring:message code='Cache.lbl_tf_general_business_mng' /></h3> <!-- 일반업무 관리 현황 -->
					<select class="selectYear" id="" data-targettype="Work"><!-- 연도설정 -->
					</select>
					<div class="cyclePrograssBarimg">
						<div class="cyclePrograssBar" style=" margin-left: 40px;">
							<div class="cycleCont circle_Work">
								<div class="cycleBg bizTask_cycleTotal">
									<div class="pie" style="border: 40px solid rgb(38, 172, 244);"></div>
								</div>
								<div class="bizTask_cycleSlice">
									<div class="pie bizTask_pieDiv"></div>
									<div class="pie fill"></div>
								</div>
								<div class="bizTask_cycleSlice">
									<div class="pie bizTask_pieDiv"></div>
									<div class="pie fill"></div>
								</div>
								<div class="bizTask_cycleSlice">
									<div class="pie bizTask_pieDiv"></div>
									<div class="pie fill"></div>
								</div>
							</div>
							<div class="cycleTxt" onclick="setGridSearchEvent(this);" data-type-status="Work_" style="background: none; top: -35px;">
								<p><spring:message code='Cache.lbl_MyWork' /></p> <!-- 내업무 -->
								<p>
									<span id="myTaskTxt_Work">0</span> <spring:message code='Cache.lbl_apv_item' /> <!-- 건 -->
								</p>
							</div>
						</div>
					</div>
					<div class="cyclePrograssBarper">
						<div class="b_progress_num" data-type-status="Work_Process">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_goProcess' />" ><spring:message code='Cache.lbl_goProcess' /></span> <!-- 진행 -->
							<span class="num">0</span>
						</div>
						<div class="b_complete_num" data-type-status="Work_Complete">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_apv_completed' />"><spring:message code='Cache.lbl_apv_completed' /></span> <!-- 완료 -->
							<span class="num">0</span>
						</div>
						<div class="b_waiting_num" data-type-status="Work_Waiting">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_apv_inactive' />"><spring:message code='Cache.lbl_apv_inactive' /></span> <!-- 대기 -->
							<span class="num">0</span>
						</div>
						<div class="b_delay_num" data-type-status="Work_Delay">
							<span class="txt" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 50px;" title="<spring:message code='Cache.lbl_Delay' />"><spring:message code='Cache.lbl_Delay' /></span> <!-- 지연 -->
							<span class="num">0</span>
						</div>
					</div>
				</div>
				<div class="fLeft tList OWListBox" >	<!-- 업무 리스트 grid -->
					<div class="selectDiv">
						<select class="selectState" id="Work_state" data-targettype="Work"></select>
					</div>
					<div class="gridDiv" id="workGrid"></div>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	var _prjStatus = Common.getBaseCode('TFProjectState').CacheData;
	
	var pjGrid = new coviGrid();
	var wGrid = new coviGrid();
	
	$(document).ready(function(){
		init();
	});
	
	function init(){
		//year option
		var tFSearchYear =  Common.getBaseConfig('TFSearchYear').split(";");
		var option = new Array();
		tFSearchYear.forEach(function(items){
			option.push({
				"name" : items
				,"value" :  items
			});
		});
		
		$(".selectYear").bindSelect({
			reserveKeys : {
				optionText : "name"
				,optionValue : "value"
			},
			options : option
		});
		
		$(".selectYear").on('change',function(){
			var type = $(this).data("targettype");
			getPortalGraphData(type);
			setGrid(type);
		});
		
		//selectbox option
		setStateOptions();
		
		$(".selectState").on('change',function(){
			var type = $(this).data("targettype");
			setGrid(type);
		});
		
		//circle chart event
		$(".cyclePrograssBarper div").on("click",function(){
			setGridSearchEvent(this);
		}); 
		
		//협업업무현황 그래프
		getPortalGraphData("Project");
		//일반업무관리 현황 그래프
		getPortalGraphData("Work");
		
		//gridList
		setGrid("Project");
		setGrid("Work");
	}
	
	function setGridSearchEvent(o){
		var st = $(o).data("type-status").split("_");
		var type = st[0];
		var state = st[1];
		$("#"+type+"_state").val(state);
		//검색 옵션 초기화
		setStateOptions();
		setGrid(type);
	}
	
	function setStateOptions(){
		var option = new Array();
		option.push({
			"name" : Common.getDic("lbl_all") // 전체
			,"value" : ""
		});
		_prjStatus.forEach(function(item){
			option.push({
				"name" : CFN_GetDicInfo(item.MultiCodeName)
				,"value" : item.Code
			});
		});
		$(".selectState").bindSelect({
			reserveKeys : {
				optionText : "name"
				,optionValue : "value"
			},
			options : option
		});
	}
	
	function getPortalGraphData(type){
		var sYear = "";
		for(var i=0;i<$(".selectYear").length;i++){
			if( $(".selectYear").eq(i).data("targettype") == type) {
				sYear = $(".selectYear").eq(i).val();
			}
		}
		var params = {
			"userCode"	: userCode 
			,"type"		: type
			,"sYear"	: sYear
		}
		
		$.ajax({
			url: "/groupware/biztask/getBizTaskPortalGraphData.do",
			type: "POST",
			data: params,
			success: function(res){
				if(res.status === "SUCCESS"){
					var list = res.list;
					
					if(list.length > 0){
						var pData = {};
						list.forEach(function(item){
							var code = item.Code;
							pData[code] = item.Cnt;
						});
						setCircleGraphLegend(type,pData);
						setCircleGraph(type,pData);
					}
				}else{
					Common.Warning(res.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/getBizTaskPortalGraphData.do", response, status, error);
			}
		});
	}
	
	// 그래프 범례 표기
	function setCircleGraphLegend(type,data){
		var waiting_num		= Number(data.Waiting);
		var progress_num	= Number(data.Process);
		var delay_num		= Number(data.Delay);
		var complete_num	= Number(data.Complete);
		
		// 지연 업무 개수가 99보다 클 때
		if(delay_num > 99){
			$(".prograss_"+type+" .cyclePrograssBarper .b_delay_num .num").text("99+");
		}else{
			$(".prograss_"+type+" .cyclePrograssBarper .b_delay_num .num").text(delay_num);
		}
		
		// 진행 업무 개수가 99보다 클 때
		if(progress_num > 99){
			$(".prograss_"+type+" .cyclePrograssBarper .b_progress_num .num").text("99+");
		}else{
			$(".prograss_"+type+" .cyclePrograssBarper .b_progress_num .num").text(progress_num);
		}
		
		// 대기 업무 개수가 99보다 클 때
		if(waiting_num > 99){
			$(".prograss_"+type+" .cyclePrograssBarper .b_waiting_num .num").text("99+");
		}else{
			$(".prograss_"+type+" .cyclePrograssBarper .b_waiting_num .num").text(waiting_num);
		}
		
		// 완료 업무 개수가 99보다 클 때
		if(complete_num > 99){
			$(".prograss_"+type+" .cyclePrograssBarper .b_complete_num .num").text("99+");
		}else{
			$(".prograss_"+type+" .cyclePrograssBarper .b_complete_num .num").text(complete_num);
		}
	}
	
	// 원형 그래프 처리
	function setCircleGraph(type,data){
		var waiting_num		= Number(data.Waiting);
		var progress_num	= Number(data.Process);
		var delay_num		= Number(data.Delay);
		var complete_num	= Number(data.Complete);
		
		var totalNum = waiting_num+progress_num+delay_num+complete_num;
		
		if(totalNum != 0){
			var perArr = [
							{
								percent: waiting_num/totalNum*100,
								style: "40px solid #5FCAFA"
							}, 
							{
								percent: progress_num/totalNum*100,
								style: "40px solid #6892F2"
							}, 
							{
								percent: delay_num/totalNum*100,
								style: "40px solid rgb(49, 112, 212)"
							}, 
							{
								percent: complete_num/totalNum*100,
								style: "40px solid rgb(38, 172, 244)"
							}
						];
			
			perArr.sort(function(a, b) {
				return a.percent > b.percent ? -1 : a.percent < b.percent ? 1 : 0;
			});
			
			$(".circle_"+type+" .bizTask_cycleSlice").removeClass("gt50");
			
			$.each(perArr, function(idx, item){
				if(idx == 0){
					$(".circle_"+type+" .bizTask_cycleTotal .pie").css("border", item.style);
				}else{
					var percent = 0;
					
					for(var i = idx; i < perArr.length; i++){
						percent += perArr[i].percent;
					}
					
					$(".circle_"+type+" .bizTask_cycleSlice").eq(idx-1).find(".pie").css("border", item.style);
					$(".circle_"+type+" .bizTask_cycleSlice").eq(idx-1).find(".bizTask_pieDiv").css("transform", "rotate(" + (3.6*percent) + "deg)");
					
					if(percent > 49) {
						$(".circle_"+type+" .bizTask_cycleSlice").eq(idx-1).addClass("gt50");
					}
				}
			});
			
			$("#myTaskTxt_"+type).text(totalNum);
		}else{
			$(".circle_"+type+" .bizTask_cycleTotal .pie").css("border", "40px solid rgb(221, 221, 221)");
			$(".circle_"+type+" .bizTask_cycleSlice .pie").css("border", "40px solid rgb(221, 221, 221)");
			$(".circle_"+type+" .bizTask_pieDiv").css("transform", "rotate(0deg)");
			$("#myTaskTxt_"+type).text("0");
		}
	}
	
	function setGrid(type){
		/*
			각 조회 리스트 대상이 달라질 수 있어 분리 처리
		*/
		if(type=="Project"){
			setPjGrid();
		}else if(type=="Work"){
			setWGrid();
		}
	}
	
	function setPjGrid(){
		var type = "Project";
		pjGrid = new coviGrid();
		pjGrid.page.pageNo = 1;
		pjGrid.setGridHeader(setGridHeader(type));
		
		pjGrid.setGridConfig(gridConfig("portal_projectGrid"));
		
		var sYear = "";
		for(var i=0;i<$(".selectYear").length;i++){
			if($(".selectYear").eq(i).data("targettype") == type) {
				sYear = $(".selectYear").eq(i).val();
			}
		}
		
		pjGrid.bindGrid({
			ajaxUrl:"/groupware/biztask/getBizTaskPortalData.do",
			ajaxPars: {
				 "userCode" : userCode 
				,"type"	: type
				,"stateCode": $(".selectState").eq(0).val() 
				,"sYear" : sYear
			}
		});
	}
	
	function setWGrid(){
		var type = "Work";
		wGrid = new coviGrid();
		wGrid.page.pageNo = 1;
		wGrid.setGridHeader(setGridHeader(type));
		wGrid.setGridConfig(gridConfig("workGrid"));
		
		var sYear = "";
		for(var i=0;i<$(".selectYear").length;i++){
			if( $(".selectYear").eq(i).data("targettype") == type ) {
				sYear = $(".selectYear").eq(i).val();
			}
		}
		
		wGrid.bindGrid({
			ajaxUrl:"/groupware/biztask/getBizTaskPortalData.do",
			ajaxPars: {
				 "userCode" : userCode 
				,"type"	: type
				,"stateCode": $(".selectState").eq(1).val() 
				,"sYear" : sYear
			}
		});
	}
	
	function gridConfig(targetGrid){
		var configObj = {
			targetID : targetGrid,
			height:"330px",
			page : {
				pageNo:1,
				pageSize:99999
			},
			paging : false,
			colHead:{},
			body:{},
			fitToWidthRightMargin : 1
		};
		
		return configObj;
	}
	
	function setGridHeader (type) {
		var headerData = null;
		switch( type ){
		case "Project":
			headerData = [ 
				{key:'CommunityName', label:'<spring:message code="Cache.lbl_tf_collaboration_name" />', width:150 , align:'center',
					formatter : function (){
						var html = "<a href='#' onclick='goCommunitySite("+this.item.CU_ID+")' >"+this.item.CommunityName+"</a>";
						return html;
					}
				}
				,{key:'ATName', label:'<spring:message code="Cache.lbl_tf_activity_name" />', width:150 , align:'center',
					formatter : function (){
						var html = "<a href='#' onclick='openPop("+this.item.CU_ID+","+this.item.AT_ID+")' >"+this.item.ATName+"</a>";
						return html;
					}
				}
				,{key:'', label:'<spring:message code="Cache.lbl_scope" />', width:150 , align:'center', sort:false,
					formatter : function () {
						 return this.item.StartDate+"~"+this.item.EndDate;
					}
				}
				,{key:'', label:'<spring:message code="Cache.lbl_apv_state" />', width:50 , align:'center', sort:false,
					formatter : function(){
						var state = this.item.PjState;
						
						var stateHtml = "";
						_prjStatus.forEach(function(baseCode){
							if(state == baseCode.Code){
								stateHtml = CFN_GetDicInfo(baseCode.MultiCodeName);
							}
						});
						return stateHtml;
					}
				}
				,{key:'Progress', label:'<spring:message code="Cache.lbl_ProgressRate" />', width:100 , align:'center',
					formatter : function(){
						var progressHtml = '<span class="OWList_participation"><div class="participationRateBar color01"><div style="width:'+this.item.Progress+'%;"></div></div><span>'+this.item.Progress+'%</span></span>';
						
						return progressHtml;
					}
				}
			];
			break;
		case "Work" : 
			headerData = [
				{key:'Subject', label:'<spring:message code="Cache.lbl_Business_details" />', width:200 , align:'center',
					formatter : function (){
						var isOwner = (this.item.RegisterCode==userCode || this.item.OwnerCode == userCode)? "Y":"N";
						var html = "<a onclick='goTaskSetPopup(\""+this.item.TaskID +"\",\""+this.item.FolderID +"\",\""+ isOwner +"\")'>"+this.item.Subject+"</a>";
						
						return html;
					}
				}
				,{key:'', label:'<spring:message code="Cache.lbl_scope" />', width:100 , align:'center', sort:false ,
					formatter : function () {
						return this.item.StartDate+"~"+this.item.EndDate;
					}
				}
				,{key:'', label:'<spring:message code="Cache.lbl_apv_state" />', width:50 , align:'center', sort:false ,
					formatter : function (){	
						var state = this.item.PjState;
						
						var stateHtml = "";
						_prjStatus.forEach(function(baseCode){ 
							if(state == baseCode.Code){
								stateHtml = CFN_GetDicInfo(baseCode.MultiCodeName);
							}
						});
						return stateHtml;
					}
				}
				,{key:'', label:'<spring:message code="Cache.lbl_ProgressRate" />', width:100 , align:'center',
					formatter : function(){
						var progressHtml = '<span class="OWList_participation"><div class="participationRateBar color01"><div style="width:'+this.item.Progress+'%;"></div></div><span>'+this.item.Progress+'%</span></span>';
						
						return progressHtml;
					}
				}
			];
			
			break;
		}
		return headerData;
	}
	
	// 제목 클릭 
	function openPop(pcommunityId, ActivityId) {
		Common.open("","ActivitySet","<spring:message code='Cache.lbl_activitymng' />","/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+pcommunityId+"&ActivityId="+ActivityId ,"950px", "650px","iframe", true,null,null,true);
	}
	
	function goTaskSetPopup(taskID,folderID,isOwner,isSearch){
		var height = isOwner=="Y"? "650px": "570px";
		//업무관리
		Common.open("","taskSet","<spring:message code='Cache.lbl_task_taskManage' />","/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+taskID+"&folderID="+folderID+"&isSearch="+isSearch,"950px", height ,"iframe", true,null,null,true);
	}
</script>