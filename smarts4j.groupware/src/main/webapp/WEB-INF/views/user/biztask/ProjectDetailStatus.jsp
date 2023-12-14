<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 통합업무관리 팀룸 진행상황 시작-->
<div class="cRConTop titType">
	<h2 class="title" id="projectTxt"></h2>
	<div class="fRight"><a href="#" onclick="javascript:goCommunitySiteDetail();" class="btnSurPartiPortTbl btnTypeDefault "><spring:message code='Cache.lbl_shortcut'/></a></div>
	<div class="searchBox02"  style="display:none;">
		<span><input type="text"><button type="button" class="btnSearchType01">검색</button></span><a href="#" class="btnDetails">상세</a>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="ITMSubCont">
		<!-- 컨텐츠 시작 -->
		<div class="ITMtabwrap">
			<ul class="tabMenu clearFloat">
				<li class="active" id="liGantt"><a href="#" onclick="onBizTaskloadTab('W');"><spring:message code='Cache.lbl_ProgressReport'/></a></li>
				<li class="" id="liActivity" style="display:none;"><a href="#" onclick="onBizTaskloadTab('A');"><spring:message code='Cache.lbl_Activity'/></a></li>
				<li class="" id="liApprovalDocs"><a href="#" onclick="onBizTaskloadTab('D');"><spring:message code='Cache.lbl_att_approvalForm'/></a></li>
				<li class="" id="liProjectInfo"><a href="#" onclick="onBizTaskloadTab('P');"><spring:message code='Cache.lbl_TFInfo'/></a></li>
			</ul>
			<!-- 진행상황 -->
			<div class="ITMtrpInfotxt"><span class="ITMtrpInfotxt_tit"><spring:message code='Cache.lbl_ProgressRate'/> : <span class="ITMtrpInfotxt_info delay" id="spanProjectProgress"><!-- 지연 : delay class추가--></span></span><span class="ITMtrpInfotxt_tit"><spring:message code='Cache.lbl_prj_contract'/> : <span class="ITMtrpInfotxt_info" id="spanProjectTerm">19.08.08~19.10.30</span></span></div>
		</div>
		<!-- 세부컨텐츠 시작 -->
		<div id="divGantt" style="display:none;height:auto;min-height: 680px;">
			<iframe id="WbsIframe" style="width:100%;border:none;height:auto;min-height: 680px;" src="">
			</iframe>
		</div>
		<div class="ITMtrpfield_table_wrap" id="divApprovalDocs" style="display:none;height:auto;min-height: 500px;">
			<div class="pjtroom_title_wrap">
				<p class="pjtroom_title"><spring:message code='Cache.lbl_att_approvalForm'/></p>
			</div>
			<div id="docLinksList" ></div>
			<div class="pjtroom_title_wrap">
				<p class="pjtroom_title"><spring:message code='Cache.lbl_apv_filelist' /></p><a id="aBtnAllDown" href='#' class="btnAllDown" onclick='javascript:downloadAll(l_fileList)' style='display:none;'><span><spring:message code='Cache.lbl_download_all'/></span></a>
			</div>
			<div id="divFileList"></div>
		</div>
		<div class="ITMtrpfield_table_wrap" id="divProjectInfo" style="display:none;height:auto;min-height: 500px;">
			<p class="pjtroom_title"><spring:message code='Cache.lbl_baseInfo'/></p>
			<div class="rowTypeWrap contDetail">
				<table class="pjtroom_info" cellpadding="0" cellspacing="0">
					<tbody>
					<tr>
						<th><spring:message code='Cache.lbl_HeadDept' /></th> <!-- 주관부서 -->
						<td><span id="spnMajorDept" ></span></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_TFPeriod' /></th> <!-- 수행기간 -->
						<td><span id="spnStartDate" ></span> ~ <span id="spnEndDate" ></span></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_TFPM' /></th> <!-- PM -->
						<td><span id="spnPM"></span></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_TFAdmin' /></th>
						<td><span id="spnAdmin"></span></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_TFContent' /></th> <!-- 추진내용 -->
						<td><span id="spnSearchTitle"></span></td>
					</tr>
					</tbody>
				</table>
			</div>
			<p class="pjtroom_title"><spring:message code='Cache.lbl_memberdetail' /></p>	
			<div class="rowTypeWrap contDetail">
				<table class="pjtroom_info" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_TFMember' /></th> <!-- 팀원 -->
							<td><span id="spnMember"></span></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<!-- 세부 컨텐츠 끝 -->
		<div id="divActivity" style="display:none;">
			<!-- #tabList -->
			<ul id="tabList" class="tabType2 clearFloat" style="display:none;">
			</ul>
			<div id="switchTopCnt" class="boradTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a href="#" id="btnWrite" class="btnTypeDefault btnTypeChk" onclick="javascript:addActivity();"><spring:message code='Cache.lbl_Write'/></a>	<!-- 작성 -->
					<a href="#" id="btnDelete" class="btnTypeDefault left" onclick="javascript:deleteActivity();"><spring:message code='Cache.lbl_delete'/></a>	<!-- 삭제 -->
					<a href="#" id="btnExcel" class="btnTypeDefault btnExcel" onclick="javascript:ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel'/></a>	<!-- 엑셀저장 -->
					<a href="#" id="btnExcelSave" class="btnTypeDefault btnExcel" onclick="javascript:ExcelUpload();"><spring:message code='Cache.btn_ExcelUpload'/></a>	<!-- 엑셀저장 -->
				</div>
				<div class="buttonStyleBoxRight" style="display:none;">
					<select id="selectPageSize" class="selectType02 listCount">
						<option value="10">10</option>
						<option value="20">20</option>
						<option value="30">30</option>
					</select>
					<button id="btnRefresh" class="btnRefresh" type="button"></button>
				</div>
				<div class="pagingType02" style="float:right;">
					<div class="searchBox02 ">
						<span><input id="simpleSchTxt" type="text" onkeypress="if (event.keyCode==13){ search(); return false;}" placeholder="Activity <spring:message code='Cache.lbl_search'/>"><!--검색--><button type="button" class="btnSearchType01" onclick="search();"><spring:message code='Cache.lbl_search'/><!-- 검색 --></button></span> ./=
					</div>
				</div>
			</div>
			<!-- 목록보기-->
			<div id="divListView" class="tblList tblCont">
				<div id="gridDiv"></div>
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
</div>
<input type="hidden" id="txtProjectCode" />
<input type="hidden" id="hidDocLinks" />
<!-- 통합업무관리 팀룸 진행상황 끝-->

<script>
	var param = location.search.substring(1).split('&');
	var key = param[3].split('=')[1];					//프로젝트코드
	var mode = CFN_GetQueryString("mode");				//진행함인지 전체진행함인지
	var bizSection = CFN_GetQueryString("CLBIZ"); 		//Project
	var g_viewType = CFN_GetQueryString("viewType");	//탭타입
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	var lang = sessionObj["lang"];
	
	var g_lastURL = "";
	var ProjectName = "";
	
	if(g_viewType=="" ||g_viewType == "undefined"){
		g_viewType='W';
	}
	//project code setting
	$("#txtProjectCode").val(key);
	
	var chartgrid = new coviGrid();
	var communityId = key;	// 커뮤니티ID	
	var g_hasAuthActivity = false;
	//목록이동
	if(mode == 'A'){
		g_lastURL = '/groupware/layout/biztask_ProjectStatusList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&mode=A';
	}else{
		g_lastURL = '/groupware/layout/biztask_ProjectStatusList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&mode=S';
	}
	
	ProjectName = decodeURIComponent(CFN_GetQueryString("prjName"));
	if($('#projectTxt').val()!=ProjectName){
		//var html = String.format("{0}&nbsp;<a href='#' onclick='javascript:goCommunitySite({1});' class='btnTypeDefault btnSearchBlue01'>{2}</a>", ProjectName, communityId, "<spring:message code='Cache.lbl_Move'/>");
		html = ProjectName;
		
		$('#projectTxt').html(html);
	}
	
	setProjectBasicInfo();	//프로젝트정보set
	onBizTaskloadTab(g_viewType);	//탭메뉴set
	
	function onBizTaskloadTab(p_viewType){
		var liID = "";
		
		$(".tabMenu li").each(function(index, item){
			$(item).removeClass("active");
		});
		
		if(p_viewType == "W"){
			$("#divApprovalDocs, #divProjectInfo, #divActivity").hide();
			$("#divGantt").show();
			liID = "liGantt";
			var iURL = "/groupware/biztask/goProjectGanttView.do";
			$("#WbsIframe").attr("src", iURL);
		}else if(p_viewType == "D"){
			$("#divProjectInfo, #divGantt,#divActivity").hide();
			$("#divApprovalDocs").show();
			//initContent_Doc();
			liID = "liApprovalDocs";
		}else if(p_viewType == "P"){
			$("#divApprovalDocs, #divGantt,#divActivity").hide();
			$("#divProjectInfo").show();
			//initContent();
			liID = "liProjectInfo";
		}else if(p_viewType == "A"){
			$("#divApprovalDocs, #divGantt,#divProjectInfo").hide();
			$("#divActivity").show();
			//initContent();
			liID = "liActivity";
			setGrid();	// 그리드 세팅
			search();	// 검색
		}
		$("#"+liID).addClass("active");
	}
	
	//프로젝트 기본정보 셋팅
	var l_fileList;//MultiFileDownlod용
	function setProjectBasicInfo() {
		$.ajax({
			type:"POST",
			data:{
				"CU_ID" : $("#txtProjectCode").val()
			},
			async : false,
			url:"/groupware/layout/selectTFDetailInfo.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					var infoHTML = "";
					// 기본정보 셋팅
					if(data.TFInfo != undefined && data.TFInfo.length > 0) {
						var info = data.TFInfo[0];
						
						//아래 2개 항목의 경우 지연일 경우 delay class추가
						$("#spanProjectTerm").html(info.TF_StartDate + "~" + info.TF_EndDate);
						
						if(data.TFProgressInfo != undefined && data.TFProgressInfo.length > 0) {
							var progressinfo = data.TFProgressInfo[0];
							$("#spanProjectProgress").html((Common.getBaseConfig('IsUseWeight') == 'Y' ? progressinfo.TF_WProgress : progressinfo.TF_AVGProgress)+'%');
						}
						
						//결재문서 쪽...
						$("#hidDocLinks").val(info.TF_DocLinks);
						G_displaySpnDocLinkInfo4Detail();
						
						if(data.fileList != undefined && data.fileList.length > 0) {
							var fileList = data.fileList;
							
							$("#divFileList").html("");
							
							var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + fileList.length + ')');
							var attFileListCont = $('<ul>').addClass('file_list');
							var attFileDownAll = $('<li style="width:100%;">').append("<a href='#' onclick='javascript:downloadAll(fileList)'><spring:message code='Cache.lbl_download_all'/></a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >'));//.addClass("btnXClose btnAttFileListBoxClose")
							var videoHtml = '';
							
							$.each(fileList, function(i, item){
								var iconClass = "";
								if(item.Extention == "ppt" || item.Extention == "pptx"){
									iconClass = "ppt";
								} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
									iconClass = "fNameexcel";
								} else if (item.Extention == "pdf"){
									iconClass = "pdf";
								} else if (item.Extention == "doc" || item.Extention == "docx"){
									iconClass = "word";
								} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
									iconClass = "zip";
								} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
									iconClass = "attImg";
								} else {
									iconClass = "default";
								}
								var attFileList = $('<li style="line-height: 20px;"></li>');
								$(attFileList).append($($('<a href="#" onclick="javascript:Common.fileDownLoad(\'' + item.FileID+  '\',\'' + item.FileName + '\',\''  + item.FileToken + '\');"/>').addClass('btn_File '+iconClass).text(item.FileName)).append($('<span title="'+item.FileName+'">').addClass('tx_size').text('(' + coviFile.convertFileSize(item.Size) + ')')));
								$(attFileListCont).append(attFileList);
							});
							
							$("#divFileList").append(attFileListCont);//attFileAnchor ,
							$("#divFileList").show();
							$(".attFileListCont").toggleClass("active");
							l_fileList = data.fileList;
							if(l_fileList.length > 1) $("#aBtnAllDown").show();
						} else {
							$("#divFileList").html("<ul class=\"appdoc_list\"><li style='text-align: center; line-height: 70px;'>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>");
						}
						
						$("#spnMajorDept").html(info.TF_MajorDept);
						
						$("#spnStartDate").html(info.TF_StartDate);
						$("#spnEndDate").html(info.TF_EndDate);
						
						$("#spnPM").html(getTFUserName(info.TF_PM));
						$("#spnAdmin").html(getTFUserName(info.TF_Admin));
						$("#spnMember").html(getTFUserName(info.TF_Member));
						$("#spnViewer").html(getTFUserName(info.TF_Viewer));
						
						$("#spnSearchTitle").html(unescape(info.Description).replace(/(\r\n|\n|\r)/g,"<br />"));
						
						//Activity 변경 권한체크
						if(('@'+info.TF_PM).indexOf(sessionObj["UR_Code"]+"|") > -1) g_hasAuthActivity = true; //PM
						if(('@'+info.TF_Admin).indexOf(sessionObj["UR_Code"]+"|") > -1) g_hasAuthActivity = true;
						if(('@'+info.TF_Member).indexOf(sessionObj["UR_Code"]+"|") > -1) g_hasAuthActivity = true; //팀원
						
						if(g_hasAuthActivity) $("#liActivity").show();
					}
				}
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/project/getProjectInfoOne.do", response, status, error);
			}
		});
	}
	
	function G_displaySpnDocLinkInfo4Detail() {//수정본
		var szdoclinksinfo = "";
		var szdoclinks =  $("#hidDocLinks").val();
		szdoclinks = szdoclinks.replace("undefined^", "");
		szdoclinks = szdoclinks.replace("undefined", "");
		var bEdit = false; 
		var bDisplayOnly = false;
		if (szdoclinks != "") {
			var adoclinks = szdoclinks.split("^^^");
			if(adoclinks.length > 0){
				szdoclinksinfo ="<ul class=\"appdoc_list\">";
				for (var i = 0; i < adoclinks.length; i++) {
					var adoc = adoclinks[i].split("@@@");
					var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
					var iWidth = 790;
					var iHeight = window.screen.height - 82;
					szdoclinksinfo += "<li style='line-height:20px;'><a href='#' class='btn_File ico_doc' onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \"><span>" + adoc[2] + "</a></li>";
				}
				szdoclinksinfo +="</ul>";
			}else{
				szdoclinksinfo ="<ul class=\"appdoc_list\"><li>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>";
			}
		}else{
			szdoclinksinfo ="<ul class=\"appdoc_list\"><li style='text-align: center; line-height: 70px;'>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>";
		}
		
		$("#docLinksList").html(szdoclinksinfo);
	}
	
	function getTFUserName(data) {
		var result = "";
		var data = data.split("@");
		
		for(var i = 0; i < data.length; i++) {
			if(data[i] != "") {
				var temp = data[i];
				result += temp.split("|")[1] + ",";
			}
		}
		
		if(result.length > 0) {
			result = result.substring(0, result.length-1);
		}
		
		return result;
	}
	
	//object내부 데이터를 하나씩 재귀호출로 삭제하면서 시도
	function downloadAll( pFileList ){
		var fileList = pFileList.slice(0);	//array 객체 복사용
		Common.downloadAll(fileList);
	}
	
	function goCommunitySiteDetail(){
		goCommunitySite(communityId);
	}
	
	function goCommunitySite(community){
		 var specs = "left=10,top=10,width=1050,height=900";
		 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		 //window.open("/groupware/layout/userTF/TFMain.do?C="+community, "TF"+community, specs);
		 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);
	}
	
	//Activity 추가 시작
	var msgHeaderData;
	// 그리드 세팅
	function setGrid() {
		// header
		var headerData;
		var overflowCell =[];
		
		headerData = [
			{key:'AT_ID',		label:'chk', width:'20', align:'center', formatter: 'checkbox'},
			{key:'',	label:'<spring:message code="Cache.lbl_Number"/>', width:'30', align:'center', sort:false,
		 		formatter:function(){
		 			return formatRowNum(this);
		 		}
			},		//번호
			{key:'ATName', label:'Activity', width:'100', align:'left',
				formatter:function () {
					var html = "<div class='tblLink'>";
					html += "<a onclick='openPop(\"" + communityId + "\", \"" + this.item.AT_ID + "\", \"" + this.item.isOwner + "\"); return false;'>";
					html += getSubFormat(this.item.ATPath)+ this.item.ATName;
					html += "</a>";
					html += "</div>";
					return html;
				}
			},
			// 상태
			{key:'TaskState', label:'<spring:message code="Cache.lbl_State" />', width:'40', align:'center', 
				formatter: function(){
					var TaskState = this.item.TaskState;
					var taskStateDic = Common.getBaseCode("FolderState").CacheData.filter(function (n) { return n.Code == TaskState; });
					return CFN_GetDicInfo(taskStateDic[0].MultiCodeName);
				}
			},
			{key:'Progress', label:'<spring:message code="Cache.lbl_ProgressRate" />', width:'40', align:'center', 
				formatter: function(){	return (this.item.Progress + '%');}
			},
			{key:'StartDate', label:'<spring:message code="Cache.lbl_startdate" />', width:'60', align:'center', 
				formatter: function(){	return this.item.StartDate;}
			},
			{key:'EndDate', label:'<spring:message code="Cache.lbl_EndDate" />', width:'60', align:'center', 
				formatter: function(){ return this.item.EndDate;}
			},
			{key:'RegistDate',	label:'<spring:message code="Cache.lbl_RegistDate" />' + Common.getSession("UR_TimeZoneDisplay") , width:'60', align:'center', 
				formatter: function(){ return CFN_TransLocalTime(this.item.RegistDate, "yyyy-MM-dd"); }
			}
		];
		overflowCell = [2];
		
		chartgrid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
			paging : false,
			colHeadTool: false,
			overflowCell: overflowCell
		};
		chartgrid.setGridConfig(configObj);
		
		msgHeaderData = headerData;
	}
	
	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	// 검색
	function search() {
		chartgrid.page.pageSize =500;
		
		var searchDate = coviCtrl.getDataByParentId('searchDate');
		var params = {reqType : "A",
					  schContentType : $('#schContentType').val(),
					  schTxt : $('#schTxt').val(),
					  simpleSchTxt : $('#simpleSchTxt').val(), /* 상단 간편검색 제목 기준 */
					  CU_ID : communityId,
					  startDate : searchDate.startDate,
					  endDate : searchDate.endDate,
					  sortBy : "ATPATH ASC"
					  };
		
		// bind
		chartgrid.bindGrid({
			ajaxUrl : "/groupware/tf/getActivityList.do",
			ajaxPars : params
		});
	}
	
	// 제목 클릭 
	function openPop(pcommunityId, ActivityId, pIsOwner) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_Modify' />","/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+pcommunityId+"&ActivityId="+ActivityId+"&isOwner="+pIsOwner ,"950px", "650px","iframe", true,null,null,true);
	}
	
	//추가
	function addActivity(){
		if(!g_hasAuthActivity){
			Common.Warning("<spring:message code='Cache.msg_WriteAuth' />"); // 작성 권한이 없습니다.
			return false;
		}
		
		Common.open("","ActivitySet","<spring:message code='Cache.btn_Add' />","/groupware/tf/goActivitySetPopup.do?mode=ADD&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+communityId ,"950px", "650px","iframe", true,null,null,true);
	}
	
	// 삭제
	function deleteActivity() {
		var params = new Object();
		var checkedObj = grid.getCheckedList(0);
		var chkLen = checkedObj.filter(function(obj){
			return obj.RegisterCode == sessionObj["USERID"];
		}).length;
		
		if(checkedObj.length > 0){
			if(chkLen != checkedObj.length){
				Common.Warning("<spring:message code='Cache.msg_noDeleteACL' />"); // 삭제 권한이 없습니다.
				return false;
			}
		}else{
			Common.Warning("<spring:message code='Cache.msg_apv_003' />"); // 선택된 항목이 없습니다.
			return false;
		}
		
		var AT_IDs = "";
		$('#gridDiv_AX_gridBodyTable tr').find('input[type="checkbox"]:checked').each(function () {
			AT_IDs += this.value+";";
		});
		params.AT_ID = AT_IDs;
		params.communityId = communityId;
		
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/tf/deleteTask.do",
					success:function (data) {
						if(data.status == 'SUCCESS') {
							Common.Inform("<spring:message code='Cache.msg_50' />", "Inform", function() {
								search();	// 검색
							});
						} else {
							Common.Warning("<spring:message code='Cache.msg_apv_030' />");
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	//TaskExcelUpload
	function ExcelUpload(){
		var url = String.format("/groupware/tf/goTFTaskExcelUploadPopup.do?bizSection=TF&mode=C&CU_ID={0}",communityId );
		var titlemessage = Common.getDic("btn_ExcelUpload");
		
		if(!g_hasAuthActivity){
			Common.Warning("<spring:message code='Cache.msg_WriteAuth' />"); // 작성 권한이 없습니다.
			return false;
		}
		
		Common.open("","target_pop", titlemessage,url,"499px","250px","iframe",true,null,null,true);
	}
	
	// 템플릿 파일 다운로드
	function ExcelDownload() {
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var headerName = getHeaderNameForExcel();
    			var headerKey = getHeaderKeyForExcel();
    			var sortInfo = chartgrid.getSortParam("one").split("=");
    			var sortBy = sortInfo.length > 1 ? sortInfo[1] : "";
    			var url = String.format("/groupware/tf/ExcelDownload.do?bizSection={0}&headerName={1}&headerKey={2}&CU_ID={3}", 
    					'TF', 
    					encodeURI(headerName),
    					headerKey, 
    					communityId,
    					sortBy);
    			location.href = url;
       		}
		});
	}
	
	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		
		for(var i=0;i<msgHeaderData.length; i++){
			if(msgHeaderData[i].display != false &&
					msgHeaderData[i].label != '' && 
					msgHeaderData[i].key != 'FileCnt' &&
					msgHeaderData[i].key != 'chk' &&
				 	msgHeaderData[i].label != 'chk' &&
				 	msgHeaderData[i].key != 'CreatorCode' && 
				 	msgHeaderData[i].key != 'Depth' && 
					msgHeaderData[i].key != 'Step' &&
					msgHeaderData[i].key != 'Seq' &&  
					msgHeaderData[i].key != 'num' &&
					msgHeaderData[i].key != 'FolderID'){
				returnStr += msgHeaderData[i].label + "|";
			}
		}
		returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}
	
	function getHeaderKeyForExcel(){
		var returnStr = "";
		
		for(var i=0;i<msgHeaderData.length; i++){
			if(msgHeaderData[i].display != false && 
					msgHeaderData[i].label != '' && 
					msgHeaderData[i].key != 'chk' && 
					msgHeaderData[i].label != 'chk' &&
					msgHeaderData[i].key != 'FileCnt' &&
			 		msgHeaderData[i].key != 'CreatorCode' && 
			 		msgHeaderData[i].key != 'Depth' && 
					msgHeaderData[i].key != 'Step' &&
					msgHeaderData[i].key != 'Seq' &&  
					msgHeaderData[i].key != 'num' && 
					msgHeaderData[i].key != 'FolderID'){
						returnStr += msgHeaderData[i].key.replace("a.","") + ",";
			}
		}
		
		returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}
	
	function getSubFormat(pATPath){
		var returnStr = "";
		if ( pATPath.split(";").length > 1){
			for(var i=0; i < pATPath.split(";").length;i++){
				returnStr +="&nbsp;";
			}
			returnStr +="└&nbsp;";
		}
		return returnStr;
	}
	//Activity 추가 종료
</script>
