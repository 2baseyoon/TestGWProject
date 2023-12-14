<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!-- 컨텐츠앱 추가 -->
	<script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script>
	<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>  
<div id='wrap'>
<c:set var="cols" value="${fn:split(sortCols,',')}" />
	<section id='ca_container'>
		<jsp:include page="ContentsLeft.jsp"></jsp:include>
		<div class='commContRight'>
			<div id="content">
				<div class="cRConTop titType">
					<h2 class="title"><spring:message code='Cache.lbl_viewContentApps'/></h2>
					<div class="searchBox02">
						<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.btn_search'/></button></span>
					</div>
				</div>
				<div class="cRContBottom mScrollVH ">
					<div id="contentDiv" class="caContent">
						<div class="caMakeTitle listBox_app">
						
						<c:if test="${folderData.UseIcon ne null && folderData.UseIcon ne '' }">
							<c:if test="${fn:startsWith(folderData.UseIcon,'app')}">
								<div class="icon ${folderData.UseIcon}">
								</div>
							</c:if>
							<c:if test="${not fn:startsWith(folderData.UseIcon,'app')}">
								<div class="icon custom" data-icon="${folderData.UseIcon}">
								</div>
								
								<script type="text/javascript">
									var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
									$(".custom").attr("style", "background: url('"+coviCmn.loadImage(BackStorage +"${folderData.UseIcon}")+"') no-repeat center;");
								</script>
							</c:if>
						</c:if>
						<span class="appname">${folderData.DisplayName}</span>
						</div>
						<div class="caMakeSavePath">
							<strong>저장위치</strong>
							<input type="text" id="folderPathName" value="${fn:replace(folderData.FolderPathName,';','\\')}" disabled="">
							<a class="btnTypeDefault" href="#" id="btnFolderMove"><spring:message code='Cache.lbl_Folder'/><spring:message code='Cache.lbl_Move'/></a>
							<div class="viewbutton">
								<c:if test="${fn:length(chartList)>0}">
									<a class="btnTypeDefault btnTypeBg" href="#" id="btnChartView"><spring:message code='Cache.lbl_chartView'/></a>
									<div class="column_menu" style="top:125px;right:323px">
										<c:forEach items="${chartList}" var="list" varStatus="status">
							                <a href="#" class="btnGoChart" data-id="${list.ChartID}">${list.ChartName}</a>
										</c:forEach>
						             </div>
								</c:if>	
								<a class="btnTypeDefault" href="#" id="btnChartConf"><spring:message code='Cache.lbl_chartSettings'/></a>
								<a class="btnTypeDefault" href="#" id="btnACL"><spring:message code='Cache.lbl_ACLManage'/></a>
								<a class="btnTypeDefault" href="#" id="btnManage" ><spring:message code='Cache.lbl_SettingDefault'/></a>
								<a class="btnTypeDefault" href="ContentsUserForm.do?folderID=${folderID}"><spring:message code='Cache.lbl_Set'/></a>
							</div>
						</div>
						<div class="caViewComponent">
							<div class="caChart_wrap" style="display:none">
								<c:forEach items="${chartList}" var="chartItem" varStatus="status">
									<div class="caChart makeChart" id="divChart_${chartItem.ChartID}">
										<div class="item">
											<span class="title"><spring:message code='Cache.lbl_chartName'/></span><input type="text" id="chartName" value="${chartItem.ChartName}">
										</div>
										<div class="item">
											<span class="title"><spring:message code='Cache.lbl_chartType'/></span>
											<select class="selectType02 chartType1" id="chartType">
												<option value="Bar"  ${chartItem.ChartType eq 'Bar'?'selected':''}><spring:message code='Cache.lbl_stickFigure'/></option>
												<option value="Line" ${chartItem.ChartType eq 'Line'?'selected':''}><spring:message code='Cache.lbl_lineType'/></option>
												<option value="Pie"  ${chartItem.ChartType eq 'Pie'?'selected':''}><spring:message code='Cache.lbl_circleType'/></option>
												<option value="Doughnut" ${chartItem.ChartType eq 'Doughnut'?'selected':''}><spring:message code='Cache.lbl_doughnutType'/></option>
											</select>
										</div>
										<div class="item">
											<span class="title"><spring:message code='Cache.lbl_statisticsByGroup'/></span>
											<select class="selectType02" id="chartCol">
												<option value="CreatorCode" ${chartItem.ChartCol eq 'CreatorCode'?'selected':''}><spring:message code='Cache.lbl_Register'/></option>
												<option value="CreateMonth" ${chartItem.ChartCol eq 'CreateMonth'?'selected':''}><spring:message code='Cache.lbl_registrationMon'/></option>
												<c:forEach items="${formList}" var="list" varStatus="status">
													<c:set var="key" value="UserForm_${list.UserFormID}"/>
													<option value="UserForm_${list.UserFormID}"  ${chartItem.ChartCol eq key?'selected':''}>${list.FieldName}</option>
												</c:forEach>
											</select>
										</div>
										<div class="item">
											<span class="title"><spring:message code='Cache.lbl_countingMethod'/></span>
											<select class="selectType02 chartType1"  id="chartMethod">
												<option value="COUNT" ${chartItem.ChartMethod eq 'COUNT'?'selected':''}><spring:message code='Cache.lbl_cntNum'/></option>
												<option value="SUM" ${chartItem.ChartMethod eq 'SUM'?'selected':''}><spring:message code='Cache.lbl_sum'/></option>
												<option value="AVG" ${chartItem.ChartMethod eq 'AVG'?'selected':''}><spring:message code='Cache.lbl_Average'/></option>
											</select>
											<select class="selectType02 chartType2" id="chartSubCol">
												<option value=""></option>
												<c:forEach items="${formList}" var="list" varStatus="status">
													<c:if test="${list.FieldType == 'Number'}">
														<c:set var="key" value="UserForm_${list.UserFormID}"/>
														<option value="UserForm_${list.UserFormID}" ${chartItem.ChartSubCol eq key?'selected':''}>${list.FieldName}</option>
													</c:if>
												</c:forEach>
											</select>
										</div>
										<div class="bottomBtnWrap">
											<a href="#" class="btnTypeDefault btnTypeBg btnSaveChart" data-id="${chartItem.ChartID}"><spring:message code='Cache.btn_save'/></a>
											<a href="#" class="btnTypeDefault btnDeleteChart" data-id="${chartItem.ChartID}"><spring:message code='Cache.btn_remove'/></a>
										</div>
									</div>
								</c:forEach>
								<div class="caChart makeChart" id="addChart" style="display:none">
									<div class="item">
										<span class="title"><spring:message code='Cache.lbl_chartName'/></span><input type="text" value="" id="chartName">
									</div>
									<div class="item">
										<span class="title"><spring:message code='Cache.lbl_chartType'/></span>
										<select class="selectType02 chartType1" id="chartType">
											<option value="Bar"><spring:message code='Cache.lbl_stickFigure'/></option>
											<option value="Line"><spring:message code='Cache.lbl_lineType'/></option>
											<option value="Pie"><spring:message code='Cache.lbl_circleType'/></option>
											<option value="Doughnut"><spring:message code='Cache.lbl_doughnutType'/></option>
										</select>
										<!--  <select class="selectType02 chartType2">
											<option>기본형</option>
											<option>누적형</option>
										</select>-->
									</div>
									<div class="item">
										<span class="title"><spring:message code='Cache.lbl_statisticsByGroup'/></span>
										<select class="selectType02" id="chartCol">
											<option value="CreatorCode"><spring:message code='Cache.lbl_Register'/></option>
											<option value="CreateMonth"><spring:message code='Cache.lbl_registrationMon'/></option>
											<c:forEach items="${formList}" var="list" varStatus="status">
												<option value="UserForm_${list.UserFormID}">${list.FieldName}</option>
											</c:forEach>
										</select>
									</div>
									<div class="item">
										<span class="title"><spring:message code='Cache.lbl_countingMethod'/></span>
										<select class="selectType02 chartType1"  id="chartMethod">
											<option value="COUNT"><spring:message code='Cache.lbl_cntNum'/></option>
											<option value="SUM"><spring:message code='Cache.lbl_sum'/></option>
											<option value="AVG"><spring:message code='Cache.lbl_Average'/></option>
										</select>
										<select class="selectType02 chartType2" id="chartSubCol">
											<option value=""></option>
											<c:forEach items="${formList}" var="list" varStatus="status">
												<c:if test="${list.FieldType == 'Number'}">
													<option value="UserForm_${list.UserFormID}">${list.FieldName}</option>
												</c:if>
											</c:forEach>
										</select>
									</div>
									<!-- <div class="item">
										<span class="title">테마 지정 </span>
										<ul class="colorchip">
											<li class="radioStyle01"><input id="theme01" name="theme" type="radio" value="orange" checked=""><label for="theme01"><span class="color01"></span></label></li>
											<li class="radioStyle01"><input id="theme02" name="theme" type="radio" value="purple"><label for="theme02"><span class="color02"></span></label></li>
											<li class="radioStyle01"><input id="theme03" name="theme" type="radio" value="blue"><label for="theme03"><span class="color03"></span></label></li>
											<li class="radioStyle01"><input id="theme04" name="theme" type="radio" value="black"><label for="theme04"><span class="color04"></span></label></li>
										</ul>
									</div>-->
									<!-- 콤보차트 체크표시일 경우 보여짐 

									<div class="combochart_detail active">
										<h3>콤보차트</h3>
										<div class="item">
											<span class="title">차트 타입</span>
											<select class="selectType02 chartType1">
												<option>꺾은선형</option>
												<option>막대형</option>
											</select>
											<select class="selectType02 chartType2">
												<option>기본형</option>
												<option>기본형</option>
											</select>
										</div>
										<div class="item">
											<span class="title">집계방식</span>
											<select class="selectType02">
												<option>개수</option>
											</select>
										</div>
									</div>
									<div class="item">
										<div class="chkStyle01 combochart">
											<input type="checkbox" id="ccc13" checked=""><label for="ccc13"><span></span>콤보차트</label>
										</div>
										<a class="btnTypeDefault btnPreview" href="#">차트 미리보기</a>
									</div>-->
									<div class="bottomBtnWrap">
										<a href="#" class="btnTypeDefault btnTypeBg" id="btnAddChart"><spring:message code='Cache.btn_save'/></a>
										<a href="javascript:$('#addChart').toggle();" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>
									</div>
								</div>
								
								<div class="caChart addChart">
									<div class="icon" onclick="$('#addChart').toggle();"></div>
									<h3><spring:message code='Cache.lbl_addingCharts'/></h3>
									<p><spring:message code='Cache.msg_dataNumInChart'/><br><spring:message code='Cache.msg_checkCharkInList'/></p>
								</div>
								
							</div>
							<div class="caMTopCont">
								<div class="pagingType02 buttonStyleBoxLeft">
									<a class="btnTypeDefault btnPosChange" href="#" id="btnAdd"><span><spring:message code='Cache.btn_register'/></span></a>
									<a class="btnTypeDefault btnSaRemove" href="#" id="btnDel"><spring:message code='Cache.btn_remove'/></a>
									<a class="btnTypeDefault btnExcel_upload" href="#" id="btnUpload" style="display:none"><spring:message code='Cache.btn_allRegistration'/></a>
									<a class="btnTypeDefault btnExcel" id="btnExcel" href="#"><spring:message code='Cache.btn_downloadList'/></a>
									<a class="btnTypeDefault btnPosChange" href="#" id="btnSaveList"><span><spring:message code='Cache.btn_saveList'/></span></a>
									<a class="btnTypeDefault btnPlusAdd" href="#" id="caAddpopbtn" ><spring:message code='Cache.btn_addComponentToList'/></a>
									<div class="caAddpop" style='display:none'>
										<div class="listbox">
											<div class="chkStyle01"><input type="checkbox" id="chk_MessageID" title="<spring:message code='Cache.lbl_Num'/>" checked><label for="chk_MessageID"><span></span><spring:message code='Cache.lbl_Num'/></label></div>
											<div class="chkStyle01"><input type="checkbox" id="chk_Subject" title="<spring:message code='Cache.lbl_subject'/>"  checked><label for="chk_Subject"><span></span><spring:message code='Cache.lbl_subject'/></label></div>
											<div class="chkStyle01"><input type="checkbox" id="chk_CreatorName" title="<spring:message code='Cache.lbl_Register'/>"  checked><label for="chk_CreatorName"><span></span><spring:message code='Cache.lbl_Register'/></label></div>
											<div class="chkStyle01"><input type="checkbox" id="chk_RegistDate" title="<spring:message code='Cache.lbl_RegistDate'/>"  checked><label for="chk_RegistDate"><span></span><spring:message code='Cache.lbl_RegistDate'/></label></div>
										</div>
									</div>
								</div>
								<div class="buttonStyleBoxRight">
									<select class="selectType02 listCount" id="selectPageSize">
										<option>10</option>
										<option>20</option>
										<option>30</option>
									</select>
									<button class="btnRefresh" type="button" id="btnRefresh" href="#"></button>
								</div>
							</div>
							<div class="tblList tblCont">
								<div id="messageGridDiv"></div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>
</div>
<input id=hiddenComment type="hidden">
<script>
var msgHeaderData ;
var messageGrid = new coviGrid();		//게시글 Grid

(function(param){
	//폴더 그리드 세팅
	var bizSection="Board";
	var boardType ="Normal";
	var viewType = "List";
	var page;
	var pageSize;
	var grCode;
	var sortBy;
	var boxType="";

	var setInit = function(){
		$("#btnChartView").click(function () { //차트보기
			$(".column_menu").toggle();
		});
		$(".btnGoChart").click(function () { //차트보기
			$(".column_menu").toggle();
			var title = $(".appname").text()+ " ["+$(this).text()+"]";
			var url =  "/groupware/contents/ContentsChartView.do";
				url += "?folderID="+param.folderID;
				url += "&chartID="+$(this).data("id");
			Common.open("", "setBoard", title, url, "800px", "740px", "iframe", false, null, null, true);
		});

		$("#btnChartConf").click(function () { //차트설정
			$('.caChart_wrap').toggle()
		});

		//권한관리
		$("#btnACL").click(function () {
			var popupID	= "ContentsFolderACLPopup";
			var openerID	= "";
			var popupTit	= Common.getDic("lbl_ACLManage");
			var popupYN		= "N";
			var popupUrl	= "/groupware/contents/ContentsFolderACLPopup.do?"
							+ "&folderID="    	+ param.folderID
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&popupYN="		+ popupYN ;
			Common.open("", popupID, popupTit, popupUrl, "885px", "500px", "iframe", true, null, null, true);
		});
		
		$("#btnManage").click(function () { //기본설정
			var title = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
			var url =  "/groupware/board/manage/goFolderManagePopup.do";
				url += "?folderID="+param.folderID;
				url += "&mode=edit";
				url += "&bizSection=" + bizSection;
				url += "&domainID=" + Common.getSession("DN_ID");
				url += "&isContentsApp=Y";
			
			Common.open("", "setBoard", title, url, "700px", "540px", "iframe", false, null, null, true);
		});
		
		$("#btnFolderMove").click(function () {//폴더이동
   			var popupID	= "ContentsFolderChangePopup";
   			var openerID	= "";
   			var popupTit	= Common.getDic("btn_apv_userfoldermove_2");
   			var popupYN		= "N";
   			var popupUrl	= "/groupware/contents/ContentsFolderMovePopup.do?"
   							+ "&fId="    	+ param.folderID
   							+ "&popupID="		+ popupID	
   							+ "&openerID="		+ openerID	
   							+ "&popupYN="		+ popupYN ;
   			Common.open("", popupID, popupTit, popupUrl, "380px", "480px", "iframe", true, null, null, true);
		});
		
		$("#btnAdd").click(function () { //등록
			sessionStorage.setItem("urlHistory", location.href);
			var url = "/groupware/board/goBoardWritePopup.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuID=${folderData.MenuID}&folderID="+param.folderID+"&mode=create&isPopup=Y";
			CFN_OpenWindow(url, "viewerPopup",1550, 800,"resize")
		});
		
		$("#btnUpload").click(function () { //일괄등록
			var url = "/groupware/contents/ContentsFolderUpload.do?folderID="+param.folderID;
			Common.open("", "viewerPopup", "", url, "1550px", "800px", "iframe", true, null, null, true);
		});
		
		$("#caAddpopbtn").click(function () { //등록
			$('.caAddpop').toggle();
		});
		
		$(".btnSaveChart").click(function () {//차트 수정
			var objId = "divChart_"+$(this).data("id");
		
			$.ajax({
				type: "POST",
				url: "/groupware/contents/saveFolderChart.do",
				data:  {"folderID": param.folderID,
					"chartID": $(this).data("id"),
					"chartName": $("#"+objId+" #chartName").val(), 
					"chartType": $("#"+objId+" #chartType").val(), 
					"chartCol": $("#"+objId+" #chartCol").val(), 
					"chartMethod": $("#"+objId+" #chartMethod").val(),
					"chartSubCol": $("#"+objId+" #chartSubCol").val()
				},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_37'/>"); // 저장되었습니다.
						location.reload();
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
					}
				}, 
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			});
		
		});
		
		$(".btnDeleteChart").click(function () {//차트삭제
			var delChartID = $(this).data("id");
			Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
	    		if (confirmResult) {
					$.ajax({
						type: "POST",
						url: "/groupware/contents/deleteFolderChart.do",
						data:  {"chartID": delChartID},
						success: function(data){
							if(data.status=='SUCCESS'){
								location.reload();
							}else{
								Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
							}
						}, 
						error: function(error){
							Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
						}
					});
	    		}
			});	
		});
		
		
		$("#btnAddChart").click(function () {//차트 추가
			$.ajax({
				type: "POST",
				url: "/groupware/contents/addFolderChart.do",
				data:  {"folderID": param.folderID,
					"chartName": $("#addChart #chartName").val(), 
					"chartType": $("#addChart #chartType").val(), 
					"chartCol": $("#addChart #chartCol").val(), 
					"chartMethod": $("#addChart #chartMethod").val()},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_37'/>"); // 저장되었습니다.
						location.reload();
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
					}
				}, 
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			});
		});
		
		
		$("#btnSaveList").click(function () {//목록 저장
			var gridColInfo = []
			
			$.each(msgHeaderData, function(i, item){
				if (item.display == true && item.key != "chk"){
					gridColInfo.push( {
						key :  item.id==undefined?item.key:item.id,
	            		//isUserForm : item.id==undefined?"N":"Y"
						isUserForm : "Y"
	             });
				}	
    		});

			$.ajax({
				type: "POST",
				url: "/groupware/contents/saveUserFormList.do",
				dataType: 'json',
				data:  {
					"domainID": Common.getSession("DN_ID"),
					"folderID": param.folderID,
					"colsInfo": JSON.stringify(gridColInfo)},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_37'/>"); // 저장되었습니다.
						location.reload();
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
					}
				}, 
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			});
		});
		
		$("#btnRefresh").click(function () {//목록 저장
			selectMessageGridList("${folderData.MenuID}", param.folderID);	;//setMessageGridConfig(param.folderID);
		});
		
		$('#searchText').off('keypress').on('keypress', function(e){ 
			if (e.which == 13) {
	        	selectMessageGridList("${folderData.MenuID}", param.folderID);	
		    }
		});

		$("#btnSearch").click(function () {//검색 클릭시
			selectMessageGridList("${folderData.MenuID}", param.folderID);	;//setMessageGridConfig(param.folderID);
		});
		
		$("#btnDel").click(function(){	//삭제
			if(messageGrid.getCheckedList(0).length == 0){
				Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); // 게시글이 선택되지 않았습니다.
				return;
			}
			
			_CallBackMethod = new Function("deleteMessage()");
			
			Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/message/manage/goCommentPopup.do?mode=delete", "300px", "220px", "iframe", true, null, null, true);

		});


		$("#btnExcel").click(function(){	//엑셀
			Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
	       		if(result){
	       			var useUserForm = "Y";
					var url = "/groupware/board/messageListExcelDownload.do?boardType=Normal&bizSection=Board&folderType=Board&folderID="+param.folderID+"&searchText="+$('#searchText').val()+"&searchType=Total&excelTitle=${folderData.DisplayName}&useUserForm=Y&useReadCnt=N"; 
					location.href = url;
	       		}
			});
		});
		
		$("#selectPageSize").change(function(){	//갯수 변경
			selectMessageGridList("${folderData.MenuID}", param.folderID);
		});
		
        $(document).off('click','.listbox').on('click','.listbox',function(e){
        	$('.caAddpop').toggle();
        });
        
        $(document).off('click','.listbox input[type=checkbox]').on('click','.listbox input[type=checkbox]',function(e){
        	e.stopPropagation();
        	if ($(this).prop("checked")){
        		msgHeaderData.push({key:"userForm_"+$(this).attr("id").substring(4),	label:$(this).attr("title"), width:'100', hideFilter : 'N', align:'center', id:$(this).attr("id").substring(4)});
        	}
        	else{	//리스트 제거
        		var key = $(this).attr("id").substring(4);
        		var tmpHeaderData = [];
        		$.each(msgHeaderData, function(i, item){
        			if (key != item.id && key != item.key){
        				tmpHeaderData.push(item);
        			}
        		});
            	msgHeaderData=tmpHeaderData
        	}
	    	reloadGridConfig(msgHeaderData);
	    	$('.caAddpop').toggle()
        });
	};
	
	var setEvent=function(){
		board.getBoardConfig(param.folderID);	//게시판별 옵션 조회 (board_config)
		setMessageGridConfig(param.folderID);
		selectMessageGridList("${folderData.MenuID}", param.folderID);	

	};

	var setMessageGridConfig=function(folderID){
		//사용자 정의 필드 이전의 컬럼헤더
		var beforeUserDefField = [ 
         	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
        	{key:'MessageID',	label:Common.getDic("lbl_no2"), width:'5', align:'center',
         		formatter:function(){
         			return board.formatTopNotice(this, g_boardConfig.UseTopNotice);	//상단공지 사용 여부 
         		}
        	},		//번호
        	{key:'Subject',  	label:Common.getDic("lbl_subject"), width:'12', align:'left',		//제목
        		formatter:function(){ 
        			return formatSubjectName(this, g_boardConfig.UseIncludeRecentReg, g_boardConfig.RecentlyDay); //최근게시 사용여부, 최근 게시 기준일
        		}        		
        	},
        ];
		
		//사용자 정의 필드 이후의 컬럼 헤더
		var afterUserDefField = [
			{key:'CreatorName',  label:Common.getDic("lbl_Register"), width:'5', align:'center',addClass:"bodyTdFile",
				formatter: function(){
					if(this.item.UseAnonym == "Y"){
						return this.item.CreatorName;							
					}else{
						return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
					}
				}
			},
			{key:'RegistDate',	label:Common.getDic("lbl_RegistDate") + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
				return (this.item.RegistDate);
			}, dataType:'DateTime'}
		];
		
		msgHeaderData = beforeUserDefField;
		msgHeaderData = msgHeaderData.concat(board.getUserDefFieldHeader(folderID));
		msgHeaderData = msgHeaderData.concat(afterUserDefField);
		
		<c:if test="${sortCols ne ''}">
			$(".caAddpop .listbox input[type=checkbox]").prop("checked", false);
		</c:if>
		<c:forEach items="${formList}" var="list" varStatus="status">
			$(".caAddpop .listbox").append($("<div>",{"class":"chkStyle01"})
										.append($("<input>",{"type":"checkbox", "id":"chk_${list.UserFormID}", "checked":"${list.IsList}"== "Y"?true:false, "title":"${list.FieldName}"}))
										.append($("<label>",{"for":"chk_${list.UserFormID}"})	
											.append($("<span>"))
											.append("${list.FieldName}")
										));
		</c:forEach>
		<c:if test="${sortCols ne ''}">
			var tmpHeaderData = [];
			tmpHeaderData.push(msgHeaderData[0]);
			<c:forEach items="${cols}" var="list" varStatus="status">
				var key = "${list}";
				$.each(msgHeaderData, function(i, item){
	    			if (key == item.id || key == item.key){
	    				tmpHeaderData.push(item);
	    				$(".caAddpop .listbox #chk_"+item.key).prop("checked", true);
	    			}
	    		});
			</c:forEach>
	    	msgHeaderData=tmpHeaderData;
		</c:if>

		
		
		messageGrid.setGridHeader(msgHeaderData);
		messageGrid.setGridConfig({
			targetID : "messageGridDiv",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			fitToWidth:true,
			colHeadTool:false,
			page : {
				pageNo: 1,
				pageSize: 10,
			}
		});
		
		//reloadGridConfig(msgHeaderData);
		//헤더 이벤트
		$( ".colHeadTable tr:eq(0)" ).sortable({
			connectWith: ".colHeadTd",
	        start:function(event, ui ) {
		        currentObj = $(".ui-draggable-dragging");
		    },
		    stop: function(event, ui) {
		    	moveGridHeader(ui);
		    },
	    });	
	};
	
	var moveGridHeader=function(obj){
		var orgIds = obj.item.attr("id").split("_");
		var orgIdx = orgIds[orgIds.length-1];
		var destIdx = obj.item.index();
		
		msgHeaderData.splice(destIdx, 0, msgHeaderData.splice(orgIdx, 1)[0]);
    	reloadGridConfig(msgHeaderData);
	};
	
	var reloadGridConfig=function(msgHeader){
		
    	messageGrid.setConfig({colGroup :msgHeader});
    	messageGrid.redrawGrid();
    	
		$( ".colHeadTable tr:eq(0)" ).sortable({
			connectWith: ".colHeadTd",
	        start:function(event, ui ) {
		        currentObj = $(".ui-draggable-dragging");
		    },
		    stop: function(event, ui) {
		    	moveGridHeader(ui);
		    },
	    });	
		
	};
	
	//게시글 Grid 조회 
	var selectMessageGridList=function(pMenuID, pFolderID){
		var searchParam = setParameter(pMenuID, pFolderID);
		messageGrid.page.pageNo = 1;
		
		messageGrid.bindGrid({
			ajaxUrl:"/groupware/board/selectMessageGridList.do",
			ajaxPars: searchParam
		});
	};

	var setParameter=function(pMenuID, pFolderID) {
		var searchParam = {
			"bizSection": "Board",
			"boardType":"Normal",
			"menuID": pMenuID,
			"folderID": (pFolderID == "undefined" ? "": pFolderID),
			"folderType": (g_boardConfig.FolderType ? g_boardConfig.FolderType : ""),
			"searchType":"Total",
			"searchText":$("#searchText").val(),
			"useTopNotice": (g_boardConfig.UseTopNotice == undefined || g_boardConfig.UseTopNotice == "N")?"":"Y",
			"useUserForm": (g_boardConfig.UseUserForm == undefined || g_boardConfig.UseUserForm == "N")?"":"Y",
		}
		
		if(searchParam.searchType == "UserForm"){
			searchParam['ufColumn'] = $("#searchType option:selected").attr("ufcolumn");
		}
		
		if($('.btnDetails').hasClass('active')){
			searchParam['startDate'] = $("#startDate").val();
			searchParam['endDate'] = $("#endDate").val();
		} else {
			searchParam['startDate'] = "";
			searchParam['endDate'] = "";
		}
/*		
		if(sortBy != "undefined" && sortBy != ""){
			var sortColumn = sortBy.split(" ")[0];
			var sortDirection = sortBy.split(" ")[1];
			var colIndex = '';
			$.each(messageGrid.config.colGroup, function(i, item){ 
				if(item.key == sortColumn){
					colIndex = i; 
					return false; 
				};
			});
			messageGrid.config.colGroup[colIndex].sort = sortDirection;
			searchParam['sortBy'] = sortBy;
		}
	*/	
		return searchParam;
	};
	
	var formatSubjectName=function( pObj, pRecentlyFlag, pRecentlyDay){
		
		var	sortBy = messageGrid.getSortParam("one").split("=")[1] != undefined?messageGrid.getSortParam("one").split("=")[1]:"";
		var page = messageGrid.page.pageNo;
		var pageSize = $("#selectPageSize").val();
		var clickBox = $("<div class='tblClickBox' />");	//제목 우측에 새글 표시 및 댓글 카운트 표시
		var recentlyBadge = $("<span />").addClass("cycleNew new").text("N");	//새글 표시 뱃지
		var replyFlag = false;		//답글 flag
		var recentFlag = false;		//최신글 flag
		
		//Subject항목 내부 <, >가 존재할경우 문자열로 치환(HTML DOM Element To String)
		var returnStr = pObj.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
		//댓글이 있을 경우 clickbox 추가
		if(pObj.item.CommentCnt > 0 && g_boardConfig.UseComment == "Y"){
			//답글 팝업
			clickBox.append("<span  style='color:black;cursor:pointer;' onclick='javascript:board.replyPopup("+pObj.item.FolderID+","+pObj.item.MessageID+","+pObj.item.Version+",\""+bizSection+"\");'>(" + pObj.item.CommentCnt + ")</span>");
			replyFlag = true;
		}
		
		//g_boardConfig.UseIncludeReg, g_boardConfig.RecentlyDay
		if(pRecentlyFlag == "Y" && pRecentlyDay > 0){
			var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
			var registDate = new Date(CFN_TransLocalTime(pObj.item.CreateDate));
			if(today < registDate.setDate(registDate.getDate()+ pRecentlyDay)){
				recentFlag = true;
			}
		}
		
		//문서관리 바인더일 경우 표시
		if(bizSection == "Doc" && pObj.item.MsgType == "B"){
			returnStr = "<span class='btnType02'>" + coviDic.dicMap["lbl_Binder"] + "</span>" + returnStr;
		}
		
		var subject = String.format("<a onclick='javascript:board.goViewPopup(\"{1}\", {2}, {3}, {4}, {5},\"W\", \"{16}\");' class='newWindowPop'></a>&nbsp;{0}", 
			returnStr,
			bizSection,
			pObj.item.MenuID,
			pObj.item.Version,
			pObj.item.FolderID,
			pObj.item.MessageID,
			$("#startDate").val(),
			$("#endDate").val(),
			sortBy,
			$("#searchText").val(),
			$("#searchType").val(),
			viewType,
			boardType,
			page,
			pageSize, 
			pObj.item.RNUM,
			pObj.item.MultiFolderType ? pObj.item.MultiFolderType : "",
			grCode,
			$("#searchType").val() === "UserForm" ? $("#searchType option:selected").attr("ufcolumn") : "");
		
		returnStr = subject;
		
		return returnStr;
		if(recentFlag){
			returnStr += clickBox.append( recentlyBadge ).prop('outerHTML');
		} else if(replyFlag){
			returnStr += clickBox.prop('outerHTML');
		}
		//삭제된 게시글의 경우 취소선 표시
		if(pObj.item.DeleteDate != "" && pObj.item.DeleteDate != undefined){
			returnStr = $("<strike/>").append(returnStr);
		}
		
		if(pObj.item.Depth!="0" && pObj.item.Depth!=undefined){
			returnStr = $("<div class='tblLink re' style='margin: 0 0 0 "+(pObj.item.Depth*12)+"px'>").append(returnStr);
			//답글 게시글 화살표 표시
		} else {
			returnStr = $("<div class='tblLink'>").append(returnStr);
		}
		
		returnStr.attr('title', returnStr.text());	// tooltip 추가
		
		//읽지않은 게시글 굵게
		if(pObj.item.IsRead != "Y"){
			returnStr = $("<strong />").append(returnStr);
		}
		
		return returnStr.prop('outerHTML');
	};
	
	

	var init = function(){
		setInit();
		setEvent();
	};
	
	init();
})({
	folderID: "${folderID}"
});
	

//게시글 삭제
function deleteMessage(){
	var messageIDs = '';

	$.each(messageGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';'
	});
	
	if(messageIDs == ''){
		Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); // 삭제할 항목을 선택하여 주십시오.
		return;
	}
	
	$.ajax({
		type: "POST",
		url: "/groupware/message/manage/deleteMessage.do",
		data: {
			  "messageID": messageIDs
			, "comment": $("#hiddenComment").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
				$("#hiddenComment").val("");
				$("#btnSearch").trigger('click');
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/deleteMessage.do", response, status, error);
		}
	});

}
</script>
