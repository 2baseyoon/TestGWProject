<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.album.js<%=resourceVersion%>"></script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_apv_FormManage' /></h2> <!-- 양식관리 -->	
	<div class="searchBox02">
		<span><input type="text" class="sm" id="simpleSearchKeyword" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button id="simpleSearchBtn"  type="button" onclick="onClickSearchButton(this);" class="btnSearchType01">검색</button></span><a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>	
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div>
			<div class="selectCalView">
				<select class="selectType02" id="selectSearchType">
					<option value="FormName"><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></option> <!-- 양식명 -->
					<option value="FormPrefix"><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></option><!-- 양식키(영문) -->
					<option value="CategoryName"><spring:message code="Cache.btn_apv_class_by"/></option> <!-- 분류 -->
					<option value="RevisionNo"><spring:message code="Cache.lbl_apv_formcreate_LCODE06"/></option> <!-- 버전 -->
				</select>
				<input type="text" id="detailSearchKeyword" style="width: 215px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				<a id="detailSearchBtn"  onclick="onClickSearchButton(this)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent appstoreContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addFormInsert(true);"><spring:message code='Cache.btn_addForm' /></a><!-- 양식추가 -->
<!-- 				<a class="btnTypeDefault btnSaRemove" href="#">삭제</a> -->
				<a class="btnTypeDefault btnExcel" onclick="downloadExcel();"><spring:message code="Cache.btn_SaveToExcel"/></a><!-- 엑셀저장 -->
			</div>
			<div class="buttonStyleBoxRight">
				<div class="radio_optionBox">
					<div>
						<span><spring:message code="Cache.lbl_IsUse"/> : </span> <!-- 사용여부 -->
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsUseAll" name="chkFilterIsUse" value="" checked=""><label for="chkFilterIsUseAll"><spring:message code="Cache.btn_All"/></label> <!-- 전체 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsUseY" name="chkFilterIsUse" value="Y"><label for="chkFilterIsUseY"><spring:message code="Cache.lbl_apv_formcreate_LCODE13"/></label> <!-- 사용 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsUseN" name="chkFilterIsUse" value="N"><label for="chkFilterIsUseN"><spring:message code="Cache.lbl_apv_formcreate_LCODE14"/></label> <!-- 미사용 -->
						</div>
					</div>
					<div>
						<span><spring:message code="Cache.lbl_apv_gubun"/> : </span> <!-- 구분 -->
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsFreeAll" name="chkFilterIsFree" value="" checked=""><label for="chkFilterIsFreeAll"><spring:message code="Cache.btn_All"/></label> <!-- 전체 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsFreeN" name="chkFilterIsFree" value="N"><label for="chkFilterIsFreeN"><spring:message code="Cache.lbl_price_charged"/></label> <!-- 유료 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterIsFreeY" name="chkFilterIsFree" value="Y"><label for="chkFilterIsFreeY"><spring:message code="Cache.lbl_price_free"/></label> <!-- 무료 -->
						</div>
					</div>
				</div>
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<a onclick="onClickListView(this)" id="listView" class="btnListView listViewType01 active"></a>
				<a onclick="onClickListView(this)" id="albumView" class="btnListView listViewType02"></a>
				<button class="btnRefresh" type="button" onclick="Refresh();"></button>
			</div>
		</div>
		<!-- 상단 버튼 끝 -->
		<div id="formCategoryList" class="form_listBox"></div>
		<!-- 그리드 컨트롤 사용 영역입니다. -->
		<div id="divGridView" class="tblList tblCont">
			<div id="storeFormsListGrid" class="tblList"></div>									
		</div>
		<div id="divAlbumView" class="tblList abList boradBottomCont appstoreList" style="display:none;">
			<div id="albumContent" class="albumContent">
			</div>
		</div>
	</div>
</div>	
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	var headerData; // global , for Excel download.
	initStoreFormList();

	function initStoreFormList(){
		selectBoxInit();
		//selectCategoryInit();	//양식분류
		setSchemaGridData();
	}
	
	function selectCategoryInit(param){
		$.ajax("/approval/manage/selectFormsCategoryList.do", {data : param, method : "POST", async : true})
			.done(function(list){
				var totalCnt = 0;
				
				searchHtml = '<ul>';
				searchHtml += '<li categoryId="" class="'+ (!param || !param.filterCategoryID || param.filterCategoryID == "" ? "active" : "") + '"><a onclick="filterCategory(this);"><span class="f_txt"><spring:message code="Cache.lbl_ViewAll"/></span><span class="f_num" id="categoryTotalCnt"></span></a></li>';
				$(list.data).each(function(i){
					var selected = false;
					if(param && param.filterCategoryID && param.filterCategoryID == this.CategoryID){
						selected = true;
					}
					searchHtml += '<li categoryId="' + this.CategoryID + '" class="' + (selected ? "active" : "") + '"><a onclick="filterCategory(this);"><span class="f_txt">'+CFN_GetDicInfo(this.CategoryName)+'</span><span class="f_num">('+this.FormsCnt+')</span></a></li>';
					totalCnt += Number(this.FormsCnt);
				});
				searchHtml += '</ui>';
				
				$("#formCategoryList").html(searchHtml);
				$("#categoryTotalCnt", "#formCategoryList").html("(" + totalCnt + ")");
			})
			.fail(function(e){  
				//console.log(e);
			});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		headerData =[
		                  {key:'CategoryName', label:'<spring:message code="Cache.btn_apv_class_by"/>', width:'100', align:'center',
		                	  formatter:function () {
									return CFN_GetDicInfo(this.item.CategoryName);
		                	  }}, //분류
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>',   width:'200', //양식명
		                	  formatter:function () {
		                		  return "<a class='txt_underline' onclick='viewStoreForm(true, \""+ this.item.StoredFormRevID +"\");'>"+CFN_GetDicInfo(this.item.FormName)+"</a>";
			      			  }},
		                  {key:'RevisionNo', label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE06"/>',   width:'100', align:'center'},//버전
			      		  {key:'ModifyDate', label:'<spring:message code="Cache.lbl_apv_moddate"/>',   width:'100', align:'center',
		                	  formatter:function () {
								return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.ModifyDate);
	                	  	}},//수정일자
	                	  {key:'PurchasedCnt', label:'<spring:message code="Cache.lbl_purchasedCnt"/>',   width:'80', align:'center',
	                	  		formatter:function () {
				      				if (this.item.PurchasedCnt > 0){
										return "<a href='#' class='txt_underline' onClick='goPurchaseList(\""+this.item.StoredFormID+"\", \""+this.index+"\")'>"+this.item.PurchasedCnt+"</a>";
				      				} else { return this.item.PurchasedCnt; }
		                	  }},//구매수
			      		  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>',   width:'80', align:'center', 
			      			  formatter : function(){
									var onOffClass = this.item.IsUse == "Y" ? "on" : "off";
									return "<div class='alarm type01'><a class='onOffBtn "+ onOffClass +"' onclick='updateIsUse(this, \""+this.item.StoredFormID+"\")'><span></span></a></div>";
			      			  }},//사용여부
			      		  {key:'IsFree', label:'<spring:message code="Cache.lbl_apv_gubun"/>',   width:'80', align:'center',
			      			formatter:function () {
		                		  return this.item.IsFree == 'Y' ? '<spring:message code="Cache.lbl_price_free"/>' : '<spring:message code="Cache.lbl_price_charged"/>';
			      			  }}//구분
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "storeFormsListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// data bind
	function setSchemaGridData(params){
		var param = params || {};
		
		// Category 건수갱신
		selectCategoryInit(param);
		
		var isGridView = $("#divGridView").is(":visible");
		
		if(isGridView){
			setGrid();
			myGrid.bindGrid({
	 			ajaxUrl:"/approval/manage/selectStoreFormList.do",
	 			ajaxPars:param
			});
		}else{
			// Album view
			// render function override.
			var pageSize = $("#selectPageSize").val();
			if(pageSize != undefined && pageSize != ''){
				coviAlbum.page.pageSize = pageSize;
			}
			
			coviAlbum.renderAlbumList = setAlbumListData;
			coviAlbum.target = 'albumContent';
			coviAlbum.url = "/approval/manage/selectStoreFormList.do";
			coviAlbum.setList(param, {});
		}
	}
	
	// 양식추가
	function addFormInsert(pModal){
		Common.open("","StoreAddFormPopup","<spring:message code='Cache.lbl_addForm'/>","/approval/manage/StoreAddFormPopup.do?mode=add","904px","740px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function viewStoreForm(pModal, storedFormRevID){
		Common.open("","StoreUpdateFormPopup","<spring:message code='Cache.lbl_viewForm'/>","/approval/manage/StoreAdminFormViewPopup.do?id="+storedFormRevID,"904px","790px","iframe",pModal,null,null,true);
	}
	
	//구매고객 리스트 팝업
	function goPurchaseList(pStoredFormID, index){
		var item = myGrid.list[index];
		Common.open("","StoreAdminPurchaseListPopup",item.FormName+" <spring:message code='Cache.lbl_FormCustomer'/>","/approval/manage/StoreAdminPurchaseListPopup.do?id="+pStoredFormID,"740px","530px","iframe-ifNoScroll",true,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			//$('#groupLiestDiv').hide();
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		//coviInput.setDate();
	}
	
	function selectBoxInit(){
		$("[name=chkFilterIsUse]").on("click", function(){
			chkFilter();
		});
		
		$("[name=chkFilterIsFree]").on("click", function(){
			chkFilter();
		});
		
		$("[id=selectPageSize]").on("change", function() {
			chkFilter();
        });
	}
	
	function chkFilter(){
		setSchemaGridData(getFilterParams());
	}
	
	function getFilterParams () {
		// search parameters.
		var searchType = $("#selectSearchType").val();
		var searchKeyword = $("#detailSearchKeyword").val();
		
		var chkItem1 = $("[name=chkFilterIsUse]:checked");
		var chkItem2 = $("[name=chkFilterIsFree]:checked");
		// category
		
		var categoryItem = $("#formCategoryList").find("li[class=active]");
		var categoryId = categoryItem.attr("categoryId");
		return {
			searchType : searchType
			,searchKeyword : searchKeyword 
			,filterIsUse : chkItem1.val() 
			,filterIsFree : chkItem2.val() 
			,filterCategoryID : categoryId 
		};
	}
	
	function filterCategory(obj) {
		var $item = $(obj).closest("li");
		$item.siblings().removeClass("active");
		$item.addClass("active");
		chkFilter();
	}
	
	function Refresh() {
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	/*
	* 목록형태 변경
	*/
	function onClickListView(obj) {
		// listView / albumView
		switch(obj.id){
		case "listView" :
			$("#divAlbumView").hide();
			$("#divGridView").show();
			$("a#listView").siblings("a").removeClass("active");
			$("a#listView").addClass("active");
			chkFilter();
			break
		case "albumView" : 
			$("#divGridView").hide();
			$("#divAlbumView").show();
			$("a#albumView").siblings("a").removeClass("active");
			$("a#albumView").addClass("active");
			chkFilter();
			break;
		default :
			return;
			break;
		}
	}
	
	function StringBuilder (init){
		var buf = init || "";
		this.appendln = function (str) {
			this.append(str + "\n");
		}
		this.append = function (str) {
			buf += str;
		}
		this.clear = function () {
			buf = "";
		}
		this.toString = function () {
			return buf;
		};
	}
	
	function setAlbumListData(result) {
		var data = result.list;
		var buf = new StringBuilder();
		if(data && data.length > 0){
			buf.appendln("<ul class='clearFloat'>");
			for(var i = 0; i < data.length; i++){
				
				buf.appendln("<li>");
				buf.appendln('<div class="albumBox">');
				
				buf.appendln('<div class="titImg">');
				buf.appendln('<a onclick="" style="cursor: default;">');
				buf.appendln('<img src="' + coviCmn.loadImageId(data[i].ThumbnailFileID) + '" onerror="coviCmn.imgError(this)" >');
				buf.appendln('</a>');
				buf.appendln('</div>');
				
				buf.appendln('<div class="abTxt">');
				buf.appendln('<p class="abTitle">');
				buf.appendln('<a onclick="viewStoreForm(true, \'' + data[i].StoredFormRevID + '\')">' + CFN_GetDicInfo(data[i].FormName) + '</a>');
				buf.appendln('</p>');
				buf.appendln('<p class="abInfo">' + data[i].ModifyDate + '</p>');
				buf.appendln('<p class="abNum">' + data[i].PurchasedCnt + '</p>');
				buf.appendln('</div>');
				
				buf.appendln('</div>');
				buf.appendln('</li>');
			}
			buf.append("</ul>");
		}else{
			buf.appendln("<div align='center' style='width:100%;padding:20px;margin-bottom: 20px;'>"+coviDic.dicMap["msg_NoDataList"]+"</div>");
		}
		
		$("#albumContent").html(buf.toString());
		coviAlbum.fnMakeNavi(coviAlbum.target, result.page);
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(obj, pStoredFormID){
		$(obj).toggleClass("on");
		var isUse = $(obj).hasClass("on");
		
		var isUseValue = isUse ? "Y" : "N";
		var sURL = "/approval/manage/updateIsUseStoredForm.do";
		
		$.ajax({
			type:"POST",
			data:{
				"StoredFormID" : pStoredFormID,
				"IsUse" : isUseValue,
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform(data.message, "Information Dialog", function() {
						chkFilter(); // refresh
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	function downloadExcel(){			
		var headerArr = getHeaderDataForExcel();
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm", function(){
			
			var params = getFilterParams();
			
			location.href = "/approval/manage/storeFormListExcelDownload.do?"
				+jQuery.param(params)
				+"&title="+"StoredFormList"
				+"&headerkey="+ encodeURIComponent(headerArr[0])
				+"&headername="+ encodeURIComponent(headerArr[1]);
		});
	}
	
	function getHeaderDataForExcel(){
		var returnArr = [];
		var headerKey = "";
		var headerName = "";

		for(var i=0;i<headerData.length; i++){
			if(headerData[i].formatter != "checkbox"){
				headerKey += headerData[i].key + ",";
				headerName += headerData[i].label + ";";
			}
		}
		returnArr.push(headerKey.slice(0,-1));
		returnArr.push(headerName);

		return returnArr;
	}
	
	/**
	* 검색 (상세 필터는 초기화)
	*/
	function onClickSearchButton(obj) {
		if(obj && obj.id == 'simpleSearchBtn'){
			$("#detailSearchKeyword").val($("#simpleSearchKeyword").val());
		}
		// sub filter initialize.
		$("[name=chkFilterIsUse]:eq(0)").prop("checked", true);
		$("[name=chkFilterIsFree]:eq(0)").prop("checked", true);

		// category
		var categoryFirstItem = $("#formCategoryList").find("li:eq(0)");
		categoryFirstItem.siblings().removeClass("active");
		categoryFirstItem.addClass("active");
		
		// list view type 초기화
// 		$("#divAlbumView").hide();
// 		$("#divGridView").show();
// 		$("a#listView").siblings("a").removeClass("active");
// 		$("a#listView").addClass("active");
		
		chkFilter();
	}
</script>