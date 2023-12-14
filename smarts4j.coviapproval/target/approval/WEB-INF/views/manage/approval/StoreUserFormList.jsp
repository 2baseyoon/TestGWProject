<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.album.js<%=resourceVersion%>"></script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_apv_StoreFormList' /></h2>	<!-- 결재양식목록 -->
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
				<h3 class="cycleTitle"><spring:message code="Cache.lbl_paidForm"/> : <!-- 결재양식 쿠폰 --> 
					<spring:message code="Cache.btn_All"/><span class="s_num s_num01" id="ApvFormsFreeCount"></span> <!-- 전체 -->
					<spring:message code="Cache.lbl_IsCouponY"/><span class="s_num s_num02" id="IsCouponY"></span> <!-- 사용 -->
					<spring:message code="Cache.lbl_IsCouponN"/><span class="s_num s_num03" id="IsCouponN"></span> <!-- 잔여 -->
				</h3>
			</div>
			<div class="buttonStyleBoxRight">
				<div class="radio_optionBox">
					<div>
						<span><spring:message code="Cache.lbl_purchaseStatus"/> : </span> <!-- 구매여부 -->
						<div class="radioStyle05">
							<input type="radio" id="chkFilterPurchaseAll" name="chkFilterPurchase" value="" checked=""><label for="chkFilterPurchaseAll"><spring:message code="Cache.btn_All"/></label> <!-- 전체 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterPurchaseY" name="chkFilterPurchase" value="Y"><label for="chkFilterPurchaseY"><spring:message code="Cache.lbl_PurchaseY"/></label> <!-- 구매 -->
						</div>
						<div class="radioStyle05">
							<input type="radio" id="chkFilterPurchaseN" name="chkFilterPurchase" value="N"><label for="chkFilterPurchaseN"><spring:message code="Cache.lbl_PurchaseN"/></label> <!-- 미구매 -->
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
		selectPurchaseFormData();
		setSchemaGridData(getFilterParams());
	}
	
	function selectPurchaseFormData(){
		$.ajax("/approval/user/getPurchaseFormData.do", {method : "POST", async : true})
		.done(function(list){
			$("#ApvFormsFreeCount").text(list.data.ApvFormsFreeCount);
			$("#IsCouponY").text(list.data.CouponUseCnt);
			$("#IsCouponN").text(list.data.CouponRemainCnt);
		})
		.fail(function(e){  
			//console.log(e);
		});
	}
	
	function selectCategoryInit(param){
		$.ajax("/approval/user/getFormsCategoryList.do", {data : param, method : "POST", async : true})
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
			      		  {key:'ModifyDate', label:'<spring:message code="Cache.lbl_apv_moddate"/>',   width:'100', align:'center',
		                	  formatter:function () {
									return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.ModifyDate)
			      			
		                	  }},//수정일자
			      		  {key:'PurchasedCnt', label:'<spring:message code="Cache.lbl_purchasedCnt"/>',   width:'80', align:'center'},//구매수
			      		  {key:'PurchaseYN', label:'<spring:message code="Cache.lbl_PurchaseY"/>',   width:'80', align:'center', 
			      			  formatter : function(){
									return this.item.PurchaseYN == "Y" ? '<spring:message code="Cache.lbl_PurchaseY"/>' : '<spring:message code="Cache.lbl_PurchaseN"/>';
			      			  }},//구매
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
	 			ajaxUrl:"/approval/user/getStoreUserFormList.do",
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
			coviAlbum.url = "/approval/user/getStoreUserFormList.do";
			coviAlbum.setList(param, {});
		}
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function viewStoreForm(pModal, storedFormRevID){
		Common.open("","StoreUserFormViewPopup","<spring:message code='Cache.lbl_viewForm'/>","/approval/user/StoreUserFormViewPopup.do?id="+storedFormRevID,"904px","550px","iframe",pModal,null,null,true);
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
		$("[name=chkFilterPurchase]").on("click", function(){
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
		
		var chkItem1 = $("[name=chkFilterPurchase]:checked");
		var chkItem2 = $("[name=chkFilterIsFree]:checked");
		// category
		
		var categoryItem = $("#formCategoryList").find("li[class=active]");
		var categoryId = categoryItem.attr("categoryId");
		return {
			searchType : searchType
			,searchKeyword : searchKeyword 
			,filterPurchase : chkItem1.val() 
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
	
	/**
	* 검색 (상세 필터는 초기화)
	*/
	function onClickSearchButton(obj) {
		if(obj && obj.id == 'simpleSearchBtn'){
			$("#detailSearchKeyword").val($("#simpleSearchKeyword").val());
		}
		// sub filter initialize.
		$("[name=chkFilterPurchase]:eq(0)").prop("checked", true);
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