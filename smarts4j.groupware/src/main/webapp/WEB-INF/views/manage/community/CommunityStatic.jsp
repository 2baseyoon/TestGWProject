<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_AggreagtionCommunity'/></h2>	<!-- 활동 현황 집계 -->
</div>

<div class="cRContBottom mScrollVH">
<form id="frm">
	<input type="hidden" id="communityId" value=""/>
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
	<input type="hidden" id ="_hiddenMemberOf" value = ""/>	
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<spring:message code='Cache.lbl_type'/> 		<!-- 유형 -->
			<select id="communityPuSelBox" class="selectType02"></select>
			<spring:message code='Cache.lbl_State'/>		<!-- 상태 -->
			<select id="communityStSelBox" class="selectType02"></select>
			<select id="communitySeSelBox" class="selectType02">
				<option value="A"><spring:message code='Cache.lbl_all'/></option> 			<!-- 전체 -->
				<option value="C"><spring:message code='Cache.lbl_communityName'/></option> <!-- 커뮤니티 명 -->
				<option value="O"><spring:message code='Cache.lbl_Operator'/></option> 		<!-- 운영자 -->
			</select>
			<input name="search" type="text" id="searchValue" />
			<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchBtn" class="AXButton" />
		</div>	
	</div>
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<select id="communityApSelBox" class="selectType02">
					<option value="S"><spring:message code='Cache.lbl_CurrentSituation'/></option> 	<!-- 현황 -->
				</select>
				<select id="communityCSelBox" class="selectType02">
					<option value="S"><spring:message code='Cache.lbl_single'/></option> 		<!-- 단일 -->
					<option value="M"><spring:message code='Cache.lbl_all'/></option> 		<!-- 전체 -->
				</select>
				<a class="btnTypeDefault" id="btnExcel" onclick="goExcel()"><spring:message code="Cache.btn_ExcelDownload"/></a>
				<div class="w_top" id="divNoticeMedia" style="float: right; padding-right: 10px; width: 300px;">
					<div class="selectCalView" > 
						<div class="chkStyle10"><input type="checkbox" class="check_class" id="chkNoticeMail" value="Mail" checked="">
							<label for="chkNoticeMail"><span class="s_check"></span>Mail</label> 
						</div>	
						<div class="chkStyle10"><input type="checkbox" class="check_class" id="chkNoticeTODOLIST" value="TODOLIST" checked="">
							<label for="chkNoticeTODOLIST"><span class="s_check"></span>Todo</label> 
						</div>	
		           		<input type="button" class="AXButton"  value="<spring:message code="Cache.msg_contactOperator"/>" onclick="javascript:sendMessage();"/>	
		       		 </div>
	       		 </div>
	       </div>	
	       	<div class="buttonStyleBoxRight">
				<button class="btnRefresh" id="btnRefresh" type="button" href="#"  onclick="gridRefresh();"></button>
			</div>
		</div>
		<div id="gridDiv"  class="tblList tblCont"></div>
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft cRConTop ">
	            <span id="txtSeMCName" class="title"></span>
				<input id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate"> - 
				<input id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate">
				<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchSubBtn" class="AXButton" />
			</div>	    
        </div>
		<div id="subGridDiv"  class="tblList tblCont"></div>		
	</div>
</form>
</div>
<script type="text/javascript">

(function() {
	var communityGrid = new coviGrid();
	var communitySubGrid = new coviGrid();
	
	var msgHeaderData = "";
	var msgSubHeaderData = "";
	
	var selBoxBind = function() {
		coviCtrl.renderAXSelect('CuStatus', 'communityStSelBox', lang, '', '','',true,true);
		coviCtrl.renderAXSelect('CommunityType', 'communityPuSelBox', lang, '', '','',true,true);
	}
	
	communityGrid.config.fitToWidthRightMargin=0;
	communitySubGrid.config.fitToWidthRightMargin=0;
	
	var initLoad = function() {
		// 첫번째 타이틀 값은 선택한 메뉴에서 가져온다.
		if ($(".sub.selected").size() === 1) {
      		$("h2.title").text($(".sub.selected").text());
		}
		
		event();
		setCommunityGrid();
		setCommunitySubGrid();
	}
	
	var event = function() {
		selBoxBind();
		
		$("#searchBtn").on("click",function(){
			gridRefresh();
		});
		
		$("#searchSubBtn").on("click",function(){
			selectSubCommunityList();
		});
	}
	
	var selectCommunityList = function() {
		//폴더 변경시 검색항목 초기화
		setCommunityGridConfig();
		communityGrid.bindGrid({
			ajaxUrl : "/groupware/manage/community/selectCommunityStaticGridList.do",
			ajaxPars: {
				DN_ID : confMenu.domainId,
				CommunityType : $("#communityPuSelBox").val(),
				RegStatus : $("#communityStSelBox").val(),
				SearchOption : $("#communitySeSelBox").val(),
				searchValue : $("#searchValue").val()
			}, onLoad : function() {
				communityGrid.click(0);
	        }
		}); 
	}

	var setCommunityGridConfig = function() {
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo: 1,
				pageSize:5
			},
			paging : true,
			colHead:{},
			body:{
				onclick: function () {
					  $("#communityId").val(this.item.CU_ID);
					  $("#txtSeMCName").text(this.item.CommunityName);
					  selectSubCommunityList();
		        }
			}
		};
		communityGrid.setGridConfig(configObj);
	}
	
	var selectSubCommunityList = function() {
		//폴더 변경시 검색항목 초기화
		setCommunitySubGridConfig();
		communitySubGrid.bindGrid({
			ajaxUrl:"/groupware/manage/community/selectCommunityStaticSubGridList.do",
			ajaxPars: {
				CU_ID : $("#communityId").val(),
				startDate : $("#startdate").val(),
				endDate : $("#enddate").val()
			},
		}); 
	}
	
	var setCommunitySubGridConfig = function() {
		var configSubObj = {
			targetID : "subGridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo: 1,
				pageSize:5
			},
			paging : true,
			colHead:{},
			body:{}
		};
		communitySubGrid.setGridConfig(configSubObj);
	}
	
	//폴더 그리드 세팅
	var setCommunityGrid = function() {
		communityGrid.setGridHeader(GridHeader());
		selectCommunityList();				
	}
	
	var GridHeader = function() {
		var communityGridHeader = [
        	{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
 			{key:'number', label:"No",width:'1', align:'center', display:true},
  			{key:'CommunityName', label:"<spring:message code='Cache.lbl_communityName'/>",width:'2', align:'center', display:true 		// 커뮤니티 명
 				,formatter:function() {
	  				var html = "";
        			html = String.format("<a href='#' onclick='javascript:subCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
       				return html;
       		}},
  			{key:'Grade', label:"<spring:message code='Cache.lbl_RankTitle'/>",width:'1', align:'center', display:true},	// 순위
	 		{key:'Point', label:"<spring:message code='Cache.lbl_PointTitle'/>",width:'1', align:'center', display:true}, 	// 포인트
			{key:'MemberCount', label:"<spring:message code='Cache.lbl_User_Count'/>",width:'1', align:'center', display:true}, 	// 회원수
			{key:'VisitCount', label:"<spring:message code='Cache.lbl_Counter'/>",width:'1', align:'center', display:true}, 	// 방문수
			{key:'MsgCount', label:"<spring:message code='Cache.lbl_noticeCount'/>",width:'2', align:'center', display:true}, 	// 게시글수
			{key:'ViewCount', label:"<spring:message code='Cache.lbl_ReadCount'/>",width:'2', align:'center', display:true}, 	// 조회수
			{key:'ReplyCount', label:"<spring:message code='Cache.lbl_Reply'/>",width:'1', align:'center', display:true}, 	// 답글
			{key:'FileSize', label:"<spring:message code='Cache.lbl_Mail_UsageCapacity'/>(MB)",width:'2', align:'center', display:true}, 	// 사용량
			{key:'RegStatus', label:"<spring:message code='Cache.lbl_State'/>",width:'1', align:'center', display:true}, 	// 상태
			{key:'DisplayName', label:"<spring:message code='Cache.lbl_Operator'/>",width:'1', align:'center', display:true}, 	// 운영자
			{key:'RegProcessDate', label:"<spring:message code='Cache.lbl_Establishment_Day'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2', align:'center', display:true,  sort:'desc' 	// 개설일
				, formatter:function() {
					return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
				}
			}
		]; 
		
		msgHeaderData = communityGridHeader;
		return communityGridHeader;
	}
	
	var SubGridHeader = function() {
		var communitySubGridHeader = [
			{key:'YYYYMMDD', label:"<spring:message code='Cache.lbl_year_month'/>",width:'2', align:'center', display:true,  sort:'desc'},   // 년월
			{key:'Grade', label:"<spring:message code='Cache.lbl_RankTitle'/>",width:'2', align:'center', display:true}, 	// 순위
			{key:'Point', label:"<spring:message code='Cache.lbl_PointTitle'/>",width:'2', align:'center', display:true}, 	// 포인트
			{key:'MemberCount', label:"<spring:message code='Cache.lbl_User_Count'/>",width:'2', align:'center', display:true}, 		// 회원수
			{key:'VisitCount', label:"<spring:message code='Cache.lbl_Counter'/>",width:'2', align:'center', display:true}, 	// 방문수
			{key:'MsgCount', label:"<spring:message code='Cache.lbl_noticeCount'/>",width:'2', align:'center', display:true}, 	// 게시글수
			{key:'ViewCount', label:"<spring:message code='Cache.lbl_ReadCount'/>",width:'2', align:'center', display:true}, 	// 조회수
			{key:'ReplyCount', label:"<spring:message code='Cache.lbl_Reply'/>",width:'2', align:'center', display:true} 		// 답글
		]; 
		
		msgSubHeaderData = communitySubGridHeader;
		return communitySubGridHeader;
	}
	
	var setCommunitySubGrid = function() {
		communitySubGrid.setGridHeader(SubGridHeader());
		selectSubCommunityList();		
	}
	
	var getHeaderNameForExcel = function() {
		var returnStr = "";
	   	for(var i=0;i<msgHeaderData.length; i++){
	   		if( msgHeaderData[i].hideFilter != 'Y' ){
				returnStr += msgHeaderData[i].label + "|";
	   	   	}
		}
		return returnStr;
	}
	
	var returnArr = function(checkCommunityList) {
		var paramArr = new Array();
		$(checkCommunityList).each(function(i, v) {
				var str = v.CU_ID;
				paramArr.push(str);
		});
		
		return paramArr;
	}
	
	this.gridRefresh = function() {
		selectCommunityList();	
	}
	
	this.goExcel = function() {
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var	sortKey = communityGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
    			var	sortWay = communityGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			var action = "";
    			if($("#communityId").val() != "" && $("#communityCSelBox").val() == "S"){
    				action = String.format("/groupware/manage/community/CommunityStaticCompileExcelFormatDownload.do?communityId={0}&sortKey={1}&sortWay={2}", $("#communityId").val(), sortKey, sortWay);
    							
    			}else{
    				var headerName = getHeaderNameForExcel();
    				action = String.format("/groupware/manage/community/CommunityStaticStatusExcelFormatDownload.do?DN_ID={0}&CommunityType={1}&sortKey={2}&sortWay={3}&headerName={4}&RegStatus={5}&SearchOption={6}&searchValue={7}", confMenu.domainId, $("#communityPuSelBox").val(), sortKey, sortWay, encodeURI(headerName), $("#communityStSelBox").val(),$("#communitySeSelBox").val(),$("#searchValue").val());
    			}
    			
    			location.href = action;
       		}
		});
	}
	
	this.sendMessage = function() {
		var notiMail = "";
		var todoList = "";
		
		if($('input:checkbox[id="chkNoticeMail"]').is(":checked") == true){
			notiMail = 'Y';
		}else{
			notiMail = 'N';
		}
		
		if($('input:checkbox[id="chkNoticeTODOLIST"]').is(":checked") == true){
			todoList = 'Y';
		}else{
			todoList = 'N';
		}
		
		var checkCommunityList = communityGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_selectRow'/>"); // 선택한 행이 없습니다.
			return false;
		} else if (checkCommunityList.length > 0) {
			var paramArr = new Array();
			paramArr = returnArr(checkCommunityList);
			
			Common.open("","todoOperator","<spring:message code='Cache.lbl_MessageInputDialog'/>","/groupware/manage/community/todoOperator.do?DN_ID="+confMenu.domainId+"&notiMail="+notiMail+"&todoList="+todoList+"&paramArr="+paramArr,"400px","300px","iframe","false",null,null,true);
		}
	}

	this.subCommunity = function(id) {
		// 커뮤니티 정보 관리
		Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/manage/community/modifyCommunity.do?DN_ID="+confMenu.domainId+"&mode=E"+"&CU_ID="+id,"670px","620px","iframe","false",null,null,true);
	}

	initLoad();
	
})();

</script>