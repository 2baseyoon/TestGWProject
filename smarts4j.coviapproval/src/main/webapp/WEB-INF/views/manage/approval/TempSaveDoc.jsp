<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_tempsaveList"/></span> <!-- 임시저장 문서보기 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig(1);" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>

<div class="cRContBottom mScrollVH">
	<!-- 상세검색 -->
	<div class="inPerView type02 sa04" id="DetailSearch">
		<div style="width:900px;">
		<!-- <select name="" class="AXSelect" id="selectEntinfoListData"></select>  -->
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w90p" name="sel_State" id="sel_State" >
					<option selected="selected" value=""><spring:message code='Cache.lbl_apv_state'/></option>
					<option value="W"><spring:message code='Cache.btn_apv_Withdraw'/></option>
					<option value="T"><spring:message code='Cache.lbl_apv_Temporary'/></option>	
				</select>
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option value=""><spring:message code="Cache.lbl_apv_searchcomment"/></option>
					<option value="Subject"><spring:message code="Cache.lbl_apv_subject"/></option>
					<option value="DEPT_Name"><spring:message code="Cache.lbl_apv_writedept"/></option>
					<option value="UR_Name"><spring:message code="Cache.lbl_apv_writer"/></option>
					<option value="FormName"><spring:message code="Cache.lbl_apv_formname"/></option>
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" />
			</div>
			<div class="selectCalView">
				<select class="selectType02" name="sel_Date" id="sel_Date">
					<option value=""><spring:message code="Cache.lbl_Date_Select"/></option>
					<option value="CREATED"><spring:message code="Cache.lbl_DraftDate"/></option>
				</select>
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" />
					<span>~</span>
					<input class=" adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig(1);"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="setGridConfig();searchConfig();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="baseconfiggrid"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>	
	</div>
</div>

<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initTempSaveDoc();

	function initTempSaveDoc(){
		setControl(); // 초기화
		setGrid();			// 그리드 세팅			
	}
	
	function setControl(){
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		// 상세버튼 열고닫기
		$('.btnDetails').off('click').on('click', function(){
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			coviInput.setDate();
		});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center',
		                	  formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },
		                  {key:'Subject',  label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'300', align:'left',
		                	  formatter:function () {
		                		  return "<a onclick='onClickPopButton(\""+this.item.FormID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormTempInstBoxID+"\",\""+this.item.FormInstTableName+"\",\""+this.item.FormPrefix+"\"); return false;'>"+this.item.Subject+"</a>";
			      		  }},	                  
		                  {key:'DEPT_Name',  label:'<spring:message code="Cache.lbl_apv_writedept"/>', width:'100', align:'center',
							formatter:function () {
								if (this.item.DEPT_Name != undefined) {
									return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.DEPT_Name) + "</span></div>";
								}
							}
		                  },
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'100', align:'center',
								formatter:function () {
									if (this.item.UR_Name != undefined) {
										return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.UR_Name) + "</span></div>";
									}
								}
		                  },
		                  {key:'WORKDT',  label:'<spring:message code="Cache.lbl_DraftDate"/>', width:'100', align:'center', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.WORKDT, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'Kind', label:'<spring:message code="Cache.lbl_apv_state"/>', width:'100', align:'center'}	                  
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
		$("#sel_State").change(function(){
			searchConfig();
	    });		
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "baseconfiggrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}

	// 리스트 조회
	function searchConfig(flag){		
		/*if(flag=='1'&& $("#sel_Search").val()==''&& $("#sel_Date").val()==''){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_criteria' />");	//검색 조건 또는 날짜검색 조건을 선택하세요.
			return;			
		}*/		
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var sel_State = $("#sel_State").val();	
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var sel_Date = $("#sel_Date").val();
		var startdate = isDetail ? $("#startdate").val() : "";
		var enddate = isDetail ? $("#enddate").val() : "";
		var icoSearch = $("#searchText").val();
		
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getTempSaveDocList.do",
				ajaxPars: {
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":startdate,
					"endDate":enddate,
					"selectEntinfoListData":$("#hidden_domain_val").val(),
					"icoSearch":icoSearch
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    	myGrid.fnMakeNavi("myGrid");
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function onClickPopButton(FormID,FormInstID,FormTempInstBoxID,FormInstTableName,FormPrefix){		
		var width = "790";
		if(IsWideOpenFormCheck(FormPrefix, FormID)) width = "1070";
		else width = "790";
		
		CFN_OpenWindow("/approval/approval_Form.do?mode=TEMPSAVE"+"&processID=&workitemID&performerID=&processdescriptionID=&userCode=&gloct=ADMTEMPSAVE&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=ADMIN&archived=false&usisdocmanager=true&subkind=", "", width, (window.screen.height - 100), "resize");

	}
	
</script>