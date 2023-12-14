<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<div class="cRConTop titType">
	<h2 class="title"> </h2><!-- 집계함 -->
	<select class="selBox selectType02" style="min-width: 300px;display:none; margin-left:10px;" id="aggregationBoxs"></select>
	<div class="searchBox02">
		<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
		<span><input type="text" class="sm" id="searchInput" onkeypress="if (event.code==='Enter'){ $(this).next().click(); return false;}"><button type="button" onclick="onClickSearchButton(this);" class="btnSearchType01"><spring:message code='Cache.lbl_search'/> <!--검색--></button></span>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02">
				<div class="selBox" style="min-width: 100px;" id="selectGroupType"></div>
				<a onclick="ExcelDownLoad(selectParams, getHeaderDataForExcel(), gridCount);"class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" onclick="initGrid();"></button><!-- 새로고침 -->
			</div>
		</div>
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<!-- 상단 고정영역 끝 -->
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list w100">
						<div id="simpleAggregationFormListGrid"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "simpleAggregation";					// 공통 사용 변수 - 결재함 종류 표현 - 
	var min = 550;
	var max = 1700;
	var right_min = 100;
    var prevClickIdx  = -1; ///// 결재 상세정보 표시하기 위해 필요한 플래그. 다른 행을 클릭했는지 동일한 행을 토글하기 위해 클릭했는지 판단할때 사용됨
    var viewsrchTop;
    var srchTop;
    var groupUrl;
    var g_mode = "SimpleAggregation";
    var bstored = "false";
    var schFrmSeSearchID = "";
    var schFrmSeGroupID = "";
    AXConfig.AXGrid.fitToWidthRightMargin = -1;
    var g_aggFormId = CFN_GetQueryString("aggFormId") == "undefined" ? "" : CFN_GetQueryString("aggFormId");
    
	//일괄 호출 처리
	initApprovalListComm(initSimpleAggregationList, refreshGrid);
	
	function initSimpleAggregationList(){
		window.onresize = function(event) {
			$(".contbox").css('top', $(".content").height());
		};
		setSelectForAggregation();
		$("#listView").addClass("active");
		$("#beforeView").removeClass("active");
		$("#searchInput").val("");
		$("#hiddenGroupWord").val("");
		$("#groupLiestDiv").css("display","none");
		setAggregationBox();
	}
	
	function setSelectForAggregation(){
		var searchTypes = [
			{
				optionValue: "InitiatorName", 
				optionText: Common.getDic("lbl_apv_writer")
			},
			{
				optionValue: "InitiatorUnitName", 
				optionText: Common.getDic("lbl_DraftDept")
			},
			{
				optionValue: "Subject", 
				optionText: Common.getDic("lbl_apv_subject")
			}
		];
		makeSelectForAggregation("selectSearchType", searchTypes, "seSearchID");
		
		var docStatus = [
			{
				optionValue: "All", 
				optionText: Common.getDic("lbl_all")
			},
			{
				optionValue: "Pending", 
				optionText: Common.getDic("lbl_Progressing")
			},
			{
				optionValue: "Completed", 
				optionText: Common.getDic("lbl_Completed")
			},
			{
				optionValue: "Rejected", 
				optionText: Common.getDic("lbl_apv_Rejected")
			}
		];
		makeSelectForAggregation("selectGroupType", docStatus, "seGroupID");
		$("#selectGroupType > div.selList > a.listTxt").on("click", refreshGrid);
	}
	
	function searchTypeEventHandler(){
		if($(this).parent().parent().find('.selList').css('display') == 'none'){
			$(this).parent().parent().find('.selList').show();
		}else{
			$(this).parent().parent().find('.selList').hide();
		}
		if($(this).attr('class')=='listTxt'||$(this).attr('class')=='listTxt select'){
			$(this).parent().find(".listTxt").attr("class","listTxt");
			$(this).attr("class","listTxt select");
			$(this).parent().parent().find(".up").html($(this).text());
			$(this).parent().parent().find(".up").attr("value",$(this).attr("value"));
		}
	}
	
	function makeSelectForAggregation(targetId, searchTypes, searchID){
		var selectSearchType = $("#" + targetId);
		var searchHtml = "<span class=\"selTit\" ><a id=\""+ searchID +"\" value=\""+searchTypes[0].optionValue+"\" class=\"up\">"+searchTypes[0].optionText+"</a></span>"
		searchHtml += "<div class=\"selList\" style=\"width:100px;display: none;\">";
		$(searchTypes).each(function(index){
			searchHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" id=\""+"sch_"+this.optionValue+"\">"+this.optionText+"</a>"
		});
		searchHtml += "</div>";
		selectSearchType.html(searchHtml);
		selectSearchType.find("a").on("click", searchTypeEventHandler);
	}
	
	function setAggregationBox(){
		var aggregationBox = $("#aggregationBoxs"); 
		$.ajax({
			type:"GET",
			url:"/approval/user/aggregation/forms.do?aggFormId=" + g_aggFormId,
			success:function (data) {
				if(data.list && data.list.length > 0){
					$(data.list).each(function(idx, form){
						var option = $("<option>");
						option.text(CFN_GetDicInfo(form.formName));
						option.val(form.aggFormId);
						aggregationBox.append(option);
					});
					if(g_aggFormId != "") {
						aggregationBox.val(g_aggFormId); //aggregationBox.bindSelectSetValue(g_aggFormId);
						if(aggregationBox.val() != null){
							$(".title").html(aggregationBox.find(":selected").text());
						}
					}else{
						$(".title").html("<spring:message code='Cache.lbl_aggregationBox' />");
						aggregationBox.show();
					}
					setGrid.call(aggregationBox);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/aggregation/forms.do", response, status, error);
			}
		});
	
		aggregationBox.off("change").on("change", setGrid);
	}
	
	function setGrid(){
		var aggFormId = $(this).val();
		setGridConfig(aggFormId);
		setApprovalListData(aggFormId);
	}
	
	function refreshGrid(){
		$("#aggregationBoxs").change();
	}
	
	function initGrid(){
		// 검색 조건 초기화
		$("#selectSearchType").find("div.selList").show();
		$("#selectGroupType").find("div.selList").show();
		$("#selectSearchType").find("div.selList > a.listTxt").first().click();
		$("#searchInput").val("");
		$("#selectGroupType").find("div.selList > a.listTxt").first().click();
	}

	function setGridConfig(aggFormId){
		var notFixedWidth = 2;
		
		headerData = getHeaderData(aggFormId);
		ListGrid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "simpleAggregationFormListGrid",
			height:"auto",
			//height:height,
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			notFixedWidth : notFixedWidth,
			body: {
				onclick: function(){
					// ListGrid.config.colGroup[this.c].key
					if(event.target.tagName === 'A'){
						if(event.target.classList.contains("formOpen")) onClickPopButton(this.item['processId'], this.item["formInstId"], null, this.item['formId']);
						else if (event.target.classList.contains("linkFile")) openFileList(event.target, this.item['formInstId']);
					}
				}
			},
			xscroll : true,
			fitToWidth : window.bFitToWidth
		};

		ListGrid.setGridConfig(configObj);
	}
	
	function getHeaderData(aggFormId){
		var headerData = [];
		var headerWidth = 0; // 헤더 전체 넓이
		$.ajax({
			type:"GET",
			url:"/approval/user/aggregation/forms/header/"+ aggFormId + ".do",
			async: false,
			success:function (data) {
				if(data.list && data.list.length > 0){
					$(data.list).each(function(idx, header){
						var formatHeader = {};
					    formatHeader.key = header.fieldId;
					    formatHeader.label = CFN_GetDicInfo(header.fieldName);
					    formatHeader.width = header.fieldWidth || "100";
					    formatHeader.align = header.fieldAlign || "center";
					    headerWidth += (header.fieldWidth || 100) * 1;
					    if(header.dataFormat){
					        formatHeader.formatter = headerFormat(header.dataFormat, header.fieldId);
					        if(header.dataFormat == "linkFile") formatHeader.addClass = "bodyTdFile";
					    }
					    headerData.push(formatHeader);
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/aggregation/forms.do", response, status, error);
			}
		});
		window.bFitToWidth = ($("#simpleAggregationFormListGrid").width()*1 > headerWidth) ? true : false;
		return headerData;
	}
	
	function headerFormat(formatType, key){
		switch(formatType){
		case "dateFormat":
			return function(){
				return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item[key]);
			};
		case "dictionary":
			return function(){
				return CFN_GetDicInfo(this.item[key]);
			};
		case "formOpen":
			return function(){
				var returnLink = document.createElement("a");
				returnLink.classList.add(formatType);
				returnLink.textContent = this.item[key];
				return returnLink.outerHTML;
			};
		case "linkFile":
			return function(){
				if(this.item[key] == "Y") return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip " + formatType + "\"><spring:message code='Cache.lbl_attach'/></a></div>";
			};
		default:
		}
	}
	
	function setApprovalListData(aggFormId){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/aggregation/forms/list/"+ aggFormId + ".do", // /forms/list/{aggFormId}.do
				ajaxPars: selectParams,
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
					$('.AXGrid').css('overflow','visible');
					gridCount = ListGrid.page.listCount;
				}
			});
		}
	}

	function openFileList(pObj,FormInstID){
		if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
			$(pObj).parent().find('.file_box').remove();
			return false;
		}
		$('.file_box').remove();
		var Params = {
				FormInstID : FormInstID
		};
		$.ajax({
			url:"/approval/getCommFileListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(data.list.length > 0){
					var vHtml = "<ul class='file_box'>";
						vHtml += "<li class='boxPoint'></li>";
					for(var i=0; i<data.list.length;i++){
						vHtml += "<li><a onclick='Common.fileDownLoad(\""+data.list[i].FileID+"\",\""+data.list[i].FileName+"\",\""+data.list[i].FileToken+"\"); '>"+data.list[i].FileName+"</a></li>";
					}
					vHtml += "</ul>";
					$(pObj).parent().append(vHtml);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/getCommFileListData.do", response, status, error);
			}
		});
	}

	function setSearchGroupWord(id){														// 공통함수에서 호출
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		
		$("#hiddenGroupWord").val(id);
		schFrmSeGroupWord = id;
		
		// 클릭 시, hover 와 동일한 css 적용되도록 추가
		$("a[id^='fieldName_']").attr("style", "");
		$("a[id='fieldName_" + id + "']").css("background", "#4497dc");
		$("a[id='fieldName_" + id + "']").css("color", "#fff");
		
		setApprovalListData();
	}

	function onClickSearchButton(){
		if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			$("#searchInput").focus();
			return false;
		}
		refreshGrid();
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchInput").val(), 'Approval');
	}
	
	function onClickPopButton(ProcessID,FormInstID,FormPrefix,FormID){
		var width;
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		CFN_OpenWindow("/approval/approval_Form.do?mode=AGGREGATION&gloct=AGGREGATION&forminstanceID=" + FormInstID + "&formID=" + FormID + "&processID=" + ProcessID, "", width, (window.screen.height - 100), "resize");
	}
</script>