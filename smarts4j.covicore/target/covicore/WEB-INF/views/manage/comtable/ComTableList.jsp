<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title" id="tit_ComTableList"><spring:message code='Cache.lbl_ComTableList'/></h2> <!-- 공통 테이블 조회 -->
	<select class="selBox" style="min-width: 184px;display:none;" id="sel_ComTableList"></select>
	<div class="searchBox02">
		<span>
			<input id="searchText" type="text">
			<button type="button" id="icoSearch" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button>
		</span>
		<a href="#" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa02">
		<div>
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w120p" id="srch_Type" name="srch_Type" ></select>
				<input type="text" id="srch_Text" />
			</div>
			<a href="#" id="btnSearch" name="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a> <!-- 검색 -->
		</div>
	</div>
	
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault"  id="btnExcel" onclick="ExcelDownload();"><spring:message code="Cache.btn_ExcelDownload"/></a> <!-- 엑셀 다운로드 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button id="btnRefresh" class="btnRefresh" type="button"></button> <!-- 새로고침 -->
			</div>
		</div>
		<div id="GridView" class="tblList" style="overflow:hidden;"></div>
	</div>
	
	<input type="hidden" id="hidden_domain_val" value=""/>
	
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	const g_comTableID = CFN_GetQueryString("id")=="undefined"? "" : CFN_GetQueryString("id");
	var gridCount = 0;					// 전역변수(엑셀저장시사용)
	headerData = [];					// 전역변수(엑셀저장시사용)
	
	initComTable();
	
	function initComTable(){	
		setControl();		// 컨트롤 및 이벤트 셋팅
		setComTableList();	// 공통 테이블 목록 조회 및 셋팅 > 공통 테이블 상세 정보 조회 > 그리드 및 검색조건 셋팅
		//getComTableInfo();	// 공통 테이블 상세 정보 조회
		//setGrid();			// 그리드 및 검색조건 셋팅
	}
	
	// Select box 및 이벤트 바인드
	function setControl(){
		
		// 이벤트
		$("#searchText, #srch_Text").on('keydown', function(){ // 엔터검색
			if(event.keyCode == "13"){
				cmdSearch();
			}
		});
		$("#icoSearch, #btnSearch").on('click', function(){ // 버튼검색
			searchConfig();
		});
		$("#selectPageSize").on('change', function(){ // 페이징변경
			searchConfig();
		});
		$("#btnRefresh").on('click', function(){ // 새로고침
			Refresh();
		});
		$('.btnDetails').off('click').on('click', function(){ // 상세버튼 열고닫기
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			//$(".contbox").css('top', $(".content").height());
			//coviInput.setDate();
		});
		
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	}
	
	// 공통 테이블 목록 조회 및 셋팅 > 공통 테이블 상세 정보 조회 > 그리드 및 검색조건 셋팅
	function setComTableList(){
		
		$("#sel_ComTableList option").remove(); // 공통테이블 콤보 초기화
		
		$.ajax({
			type:"POST",
			data:{
				"CompanyCode":$("#hidden_domain_val").val(), //confMenu.domainId,
				"ComTableID" : g_comTableID				
			},
			async : false,
			url:"/covicore/manage/getComTableList.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.list && data.list.length > 0){
						$(data.list).each(function(idx, item){
							var option = $("<option>");
							option.text(CFN_GetDicInfo(item.ComTableName));
							option.val(item.ComTableID);
							$("#sel_ComTableList").append(option);
						});
						if(g_comTableID != "") { // 특정 공통테이블 1개 조회
							$("#sel_ComTableList").val(g_comTableID);
							if($("#sel_ComTableList").val() != null){
								$("#tit_ComTableList").html($("#sel_ComTableList").find(":selected").text());
							}
						}else{ // 전체 공통테이블 조회
							$("#tit_ComTableList").html("<spring:message code='Cache.lbl_ComTableList' />"); // 공통 테이블 조회
							$("#sel_ComTableList").show();
						}
						getComTableInfo.call($("#sel_ComTableList")); // 공통 테이블 상세 정보 조회 > 그리드 및 검색조건 셋팅
					}else{
						Common.Warning("<spring:message code='Cache.msg_ComNoData' />"); // 조회된 데이터가 없습니다.
					}
				}else{
					Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getComTableManageData.do", response, status, error);
			}
		});
	
		$("#sel_ComTableList").off("change").on("change", getComTableInfo); // 공통 테이블 상세 정보 조회 > 그리드 및 검색조건 셋팅
	}
	
	// 공통 테이블 상세 정보 조회 > 그리드 및 검색조건 셋팅
	function getComTableInfo(){
		var comTableID = $(this).val(); // sel_ComTableList
		var bSuccess = false; // bindGrid가 비동기라 프로그레스 제거되므로, bindGrid 호출된상태면 프로그레스 유지시키도록
		$.ajax({
			type:"POST",
			data:{
				"ComTableID" : comTableID				
			},
			url:"/covicore/manage/getComTableFieldData.do",
			async : false,
			success:function (data) {			
				if(data.status == "SUCCESS"){
					if(data.list && data.list.length > 0){
						setGrid(data.list); // 그리드 및 검색조건 셋팅
						bSuccess = true;
					}else{ 
						Common.Warning("<spring:message code='Cache.msg_ComNoData' />"); // 조회된 데이터가 없습니다.
					}
				}else {
                    Common.Error(data.message);
                }
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getComTableFieldData.do", response, status, error);
			}
		});
		
		if(bSuccess) $(".divpop_overlay").show();
	}
	
	// 그리드 및 검색조건 셋팅
	function setGrid(oFieldList){
		
		// 검색조건 초기화
		$("#srch_Type option").remove();
		$("#srch_Text").val("");
		$("#searchText").val("");
		
		var headerWidth = 0; // 헤더 전체 넓이
		headerData =[];
		
		$.each(oFieldList, function(i,obj){
			
			// 헤더 셋팅
			var oField = {};
		    oField.key = obj.FieldID;
		    oField.label = CFN_GetDicInfo(obj.FieldName);
		    oField.width = (obj.FieldWidth) ? obj.FieldWidth : "100";
		    oField.align = obj.FieldAlign;
		    if(obj.IsSort != "Y") oField.sort = false;
		    if(obj.IsDisplay != "Y") oField.display = false;
		    else headerWidth += (oField.width*1);
		    oField.formatter = function(){ return gridDataFormat(obj, this.item, true); }; 
		    
		    headerData.push(oField);
		    
		    // 검색조건 셋팅
		    if(obj.IsSearch == "Y"){
			    var option = $("<option>");
				option.text(CFN_GetDicInfo(obj.FieldName));
				option.val(obj.FieldID);
				$("#srch_Type").append(option);
		    }
		    
		});
		
		var bFitToWidth = ($("#GridView").width()*1 > headerWidth) ? true : false;
		
		// 그리드 셋팅 및 리스트 조회
		myGrid.setGridHeader(headerData);
		setGridConfig(bFitToWidth);	
		searchConfig();
	}
	
	// 그리드 데이터 포멧
    function gridDataFormat(oField, oItem, isHtml){
		var rtnData = oItem[oField.FieldID];
		
		// base64 decode여부
		if(oField.DecodeB64 == "Y") {
			try{ rtnData = Base64.b64_to_utf8(rtnData); }
			catch(e) { console.log(e.message); }
		}
		
		switch(oField.FieldDisplayType){
	    	case "dictionary": // 다국어 처리
	    		rtnData = CFN_GetDicInfo(rtnData);
	    		break;
	    	case "dateFormat": // 날짜포멧 처리
	    		rtnData = CFN_TransLocalTime(rtnData);
	    		break;
	    	//case "tag": // tag값 html특수문자 처리
	    	//	rtnData = XFN_ChangeInputValue(rtnData);
	    	//	break;
	    	case "json": // json string으로 변환(객체로 들어옴)
	    		if(typeof rtnData == "object"){
	    			try{ rtnData = JSON.stringify(rtnData); }
					catch(e) { console.log(e.message); }
	    		}
	    		break;
	    }
		
		// html로 리턴 여부
		if(isHtml){ 
			// 데이터 팝업 여부 처리
			var returnLink = (oField.IsPopup == "Y") ? document.createElement("a") : document.createElement("span");
			returnLink.textContent = rtnData;
			rtnData = returnLink.outerHTML;
		}
		
		return rtnData;
	}
	
	// 그리드 Config 설정
	function setGridConfig(bFitToWidth){
		var configObj = {
			targetID : "GridView",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",			
			page : {
				pageNo: 1,
				pageSize: 10
			},	
			paging : true,
			colHead:{},
			body: {
				onclick: function(){
					if(event.target.tagName === 'A'){
						showDetailPop(event.target, this);
					}
				}
			},
			xscroll : true,
			fitToWidth : bFitToWidth
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 리스트 조회
	function searchConfig(){
		//searchText
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		var comTableID = $("#sel_ComTableList").val();
		if(comTableID != null){
			myGrid.page.pageNo = 1;
			myGrid.page.pageSize = $("#selectPageSize").val();
			myGrid.bindGrid({
	 			ajaxUrl:"/covicore/manage/execComTableQuery.do",
	 			ajaxPars: {
	 				"ComTableID":comTableID,
	 				"CompanyCode":$("#hidden_domain_val").val(), //confMenu.domainId,
	 				"SearchType":isDetail ? $("#srch_Type").val() : "",
	 				"SearchText":isDetail ? $("#srch_Text").val() : "",
	 				"icoSearch":$("#searchText").val()
	 			},
	 			onLoad:function(){
	 				gridCount = myGrid.page.listCount; // 전역변수(엑셀저장시사용)
	 			}
			});
		}
	}
	
	// 데이터 상세보기 팝업
	function showDetailPop(oTarget, oThis) {
		var oHeader = myGrid.config.colGroup[oThis.c];
   		//var strData = myGrid.list[oThis.index][oHeader.key];
   		var strData = $(oTarget).text();
   		Common.open("",oHeader.key, oHeader.label, "<textarea style='font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left' readonly>"+strData+"</textarea>", "900px","530px","html",true,null,null,true);
	}
	
	// 엑셀저장
	function ExcelDownload(){
		if(gridCount > 0){
			Common.Confirm(Common.getDic("msg_ExcelDownMessage"), "Confirmation Dialog", function(result){
	       		if(result){
	       			var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
					var comTableID = $("#sel_ComTableList").val();
					var headerKey = [];
					$.each(headerData, function(i,obj){
						if(obj.display) headerKey.push(obj.key);
					});
					if(comTableID != null && headerKey.length > 0){
						location.href = "/covicore/manage/execComTableQueryExcel.do" 
							+"?ComTableID=" + comTableID
		 					+"&CompanyCode=" + $("#hidden_domain_val").val() //confMenu.domainId,
		 					+"&SearchType=" + encodeURIComponent((isDetail ? $("#srch_Type").val() : ""))
		 					+"&SearchText=" + encodeURIComponent((isDetail ? $("#srch_Text").val() : ""))
		 					+"&icoSearch=" + encodeURIComponent($("#searchText").val())
		 					+"&headerkey="+encodeURIComponent(headerKey.toString())
					}
	       		}
			});
		}else{
			Common.Warning(Common.getDic("msg_ComNoData"));							// 조회된 데이터가 없습니다.
		}
	}
	
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
</script>