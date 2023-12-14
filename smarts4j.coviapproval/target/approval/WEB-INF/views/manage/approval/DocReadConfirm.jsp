<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_DocReadCheck"/></span> <!-- 문서 읽음확인 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ searchConfig(2); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig(2);" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>



<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02" id="DetailSearch">
		<div style="width:900px;">
			<!-- <select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select> -->
			<!-- <spring:message code="Cache.lbl_apv_readType"/>: -->
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w90p" name="sel_State" id="sel_State" >
					<option selected="selected" value=""><spring:message code="Cache.lbl_apv_total"/></option>
					<option value="Y"><spring:message code="Cache.lbl_apv_admin"/></option>
					<option value="N"><spring:message code="Cache.lbl_apv_normal"/></option>
					<option value="A"><spring:message code="Cache.lbl_apv_audit"/></option>	
				</select>
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option value=""><spring:message code="Cache.lbl_apv_searchcomment"/></option>
					<option value="Subject"><spring:message code="Cache.lbl_apv_subject"/></option>
					<option value="InitiatorName"><spring:message code="Cache.lbl_apv_writer"/></option>					
					<option value="FormName"><spring:message code="Cache.lbl_apv_formname"/></option>	
					<option value="UserName"><spring:message code="Cache.lbl_apv_reader"/></option>	
				</select>
				
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" disabled="disabled" /> <!-- cmdSearch(); -->
			</div>
			<div class="selectCalView">
				<select class="selectType02" name="sel_Date" id="sel_Date">
					<option value=""><spring:message code="Cache.lbl_Date_Select"/></option>
					<option value="InitiatedDate"><spring:message code="Cache.lbl_DraftDate"/></option>
					<option value="ReadDate"><spring:message code="Cache.lbl_apv_ReadDate"/></option>
				</select>
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled" />
					<span>~</span>
					<input class=" adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" disabled="disabled" />
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

	initDocReadConfirm();
	
	function initDocReadConfirm(){
		setControl(); // 초기 셋팅
		setGrid();			// 그리드 세팅			
	}
	
	// 초기 셋팅
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
		
		// 읽기타입 select 이벤트 셋팅
		$("#sel_State").change(function(){
			searchConfig();
	    });		
		
		//검색조건 select 이벤트 셋팅
		$("#sel_Search").change(function(){
			if($("#sel_Search").val() != ''){
				$("#search").attr("disabled",false);
			}else{
				$("#search").attr("disabled",true);
			}
	    });	
		
		//날짜검색 select 이벤트 셋팅
		$("#sel_Date").change(function(){
			if($("#sel_Date").val() != ''){
				$("#startdate").attr("disabled",false);
				$("#enddate").attr("disabled",false);
			}else{
				$("#startdate").attr("disabled",true);
				$("#enddate").attr("disabled",true);
			}
	    });	
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'100', align:'center'
		                	  , formatter:function(){return CFN_GetDicInfo(this.item.FormName)} },
		                  {key:'Subject',  label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'300', align:'left'},
		                  {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'100', align:'center',
		                	  formatter:function () {
									if (this.item.InitiatorName != undefined) {
										return "<div class=\"tableTxt\"<span>" + CFN_GetDicInfo(this.item.InitiatorName) + "</span></div>";
									}
								}
						  },
		                  {key:'InitiatedDate',  label:'<spring:message code="Cache.lbl_DraftDate"/>', width:'120', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InitiatedDate, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'UserName',  label:'<spring:message code="Cache.lbl_apv_reader"/>', width:'100', align:'center'},
		                  {key:'ReadDate',  label:'<spring:message code="Cache.lbl_apv_ReadDate"/>', width:'120', align:'center' , sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.ReadDate, "yyyy-MM-dd HH:mm:ss")} },
		                  {key:'AdminYN', label:'<spring:message code="Cache.lbl_apv_readType"/>', width:'100', align:'center'
		                	  , formatter:function(){
		                		  var AdminYN;
		                		  if(this.item.AdminYN=='Y'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_admin"/>(Y)';
		                		  }else if(this.item.AdminYN=='N'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_normal"/>(N)';
		                		  }else if(this.item.AdminYN=='A'){
		                			  AdminYN='<spring:message code="Cache.lbl_apv_audit"/>(A)';
		                		  }
		                		return AdminYN;
		                	  }
		                  }	                  
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
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
	
	// baseconfig 검색
	function searchConfig(flag){		
		if(flag=='1'&& $("#sel_Search").val()==''&& $("#sel_Date").val()==''){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_criteria' />"); //검색 조건 또는 날짜검색 조건을 선택하세요.
			return;			
		}else if(flag=='2'&& $("#searchText").val()==''){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_criteria' />"); //검색 조건 또는 날짜검색 조건을 선택하세요.
			return;		
		}
		
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		var EntCode = $("#hidden_domain_val").val(); 
		var sel_State = $("#sel_State").val();	
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var sel_Date = isDetail ? $("#sel_Date").val() : "";
		var startdate = isDetail ? $("#startdate").val() : "";
		var enddate = isDetail ? $("#enddate").val() : "";
		var icoSearch = $("#searchText").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getDocReadConfirmList.do",
				ajaxPars: {
					"EntCode":EntCode,
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":startdate,
					"endDate":enddate,
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

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
</script>