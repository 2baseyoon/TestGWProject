<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span id="spn_title"></span> 
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig();" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02 active" id="DetailSearch">
		<div>
			<div class="selectCalView" style="margin:0;">
				<!--<spring:message code='Cache.lbl_UseAuthority'/>
				<select  name="selectUseAuthority" class="selectType02 w120p" id="selectUseAuthority"></select>-->
				
				<!--<spring:message code='Cache.lbl_apv_formcreate_LCODE12'/> -->
				<select class="selectType02 w90p" name="sel_lUseYN" id="sel_lUseYN" >
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
					<option selected="selected" value="Y"><spring:message code='Cache.lbl_UseY'/></option>
					<option value="N"><spring:message code='Cache.lbl_UseN'/></option>	
				</select>
				
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option selected="selected" value="FormName"><spring:message code='Cache.lbl_FormNm'/></option>
					<option value="FormPrefix"><spring:message code='Cache.lbl_FormID'/></option>
					<option value="FormClassName"><spring:message code='Cache.lbl_classNm'/></option>	
				</select>
				
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" />
				
				<!-- <input name="rdblUseYN" id="rdblUseYN_0" type="radio" value="">
					<label for="rdblUseYN_0"><spring:message code='Cache.lbl_Whole'/></label>
				<input name="rdblUseYN" id="rdblUseYN_1" type="radio" checked="checked" value="Y">
					<label for="rdblUseYN_1"><spring:message code='Cache.lbl_UseY'/></label>					
				<input name="rdblUseYN" id="rdblUseYN_2" type="radio" value="N">
					<label for="rdblUseYN_2"><spring:message code='Cache.lbl_UseN'/></label> -->
				
				<input type="hidden" id="hidden_domain_val" value=""/>
				<input type="hidden" id="hidden_worktype_val" value=""/>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnFormAdd" class="btnTypeDefault btnPlusAdd" href="#" onclick="addConfig(true);" style="display:none;"><spring:message code="Cache.btn_Add"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="GridViewFormList"></div>
		</div>
	</div>
</div>

<script type="text/javascript">
	const _isCstfList = "${param.isCstf}"; // 앱스토어(Covision STored Form list) 여부
	
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initAdminFormList();

	function initAdminFormList(){
		setControl();		
		setGrid();			// 그리드 세팅	
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	      
		                  {key:'FormName',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE03'/>', width:'180', align:'left', sort:"asc",
		                	  formatter:function(){return "<a class='txt_underline' onclick='updateConfig(true,\"" + this.item.FormID + "\",\"" + this.item.ModifyAcl + "\")'>"+CFN_GetDicInfo(this.item.FormName) + "</a>";}
		                  },	                  
		                  {key:'FormPrefix',  label:'<spring:message code='Cache.lbl_FormID'/>', width:'170', align:'left'},
		                  {key:'Revision', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE06'/>', width:'45', align:'center'},
		                  {key:'IsUse',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE12'/>', width:'45', align:'center'},
		                  {key:'SchemaName', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE04'/>', width:'150', align:'left'},
		                  {key:'SortKey',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE07'/>', width:'45', align:'center'},	                  
		                  {key:'EntName',  label:'<spring:message code='Cache.lbl_aclTarget'/>', width:'100', align:'left'},
		                  {key:'RegDate', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE15'/>', width:'80', align:'center',
		                	  formatter:function(){return CFN_TransLocalTime(this.item.RegDate, "yyyy-MM-dd");}
						  },
		                  {key:'FormID',  label:'<spring:message code='Cache.lbl_VersionUp'/>', width:'80', align:'center', sort: false,
		                	  formatter:function () {
		                		  return "<a class='btnTypeDefault' onclick='updateVersion(true, \"" + this.item.FormID + "\",\"" + this.item.ModifyAcl + "\")'><spring:message code='Cache.lbl_VersionUp'/></a>";
			      				}
		                	  }
			      		];
		
		var firstHeader = {};
		if(_isCstfList == "Y"){
		    firstHeader.key = "IsFree";
		    firstHeader.formatter = function(){
		    		if(this.item.IsFree == "Y") return "<spring:message code='Cache.lbl_price_charged'/>"; // 무료
		    		else return "<spring:message code='Cache.lbl_price_free'/>"; // 유료
		    	};
		    firstHeader.label = "<spring:message code='Cache.lbl_apv_gubun'/>"; // 구분
		}else{
			firstHeader.key = "FormClassName";
		    firstHeader.formatter = function(){return CFN_GetDicInfo(this.item.FormClassName);};
		    firstHeader.label = "<spring:message code='Cache.lbl_classNm'/>"; // 분류명
		}
		firstHeader.width = 90;
		firstHeader.align = "left";
		headerData.unshift(firstHeader);
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();			
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridViewFormList",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{}
		};
		
		myGrid.setGridConfig(configObj);
	}
	

	
	// 리스트 조회
	function searchConfig(){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var EntCode = $("#hidden_domain_val").val(); //$("#selectUseAuthority").val();	
		EntCode = (EntCode == "ORGROOT" ? "" : EntCode); // 그룹사공용이면 회사전체 검색
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var icoSearch = $("#searchText").val();
		//var IsUse = $("input[name=rdblUseYN]:checked").val();
		var IsUse = $("#sel_lUseYN").val();
		
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getAdminFormListData.do",
				ajaxPars: {
					"EntCode":EntCode,
					"sel_Search":sel_Search,
					"search":search,
					"icoSearch":icoSearch,
					"IsUse":IsUse,
					"IsCstf":_isCstfList
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
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// Select box 및 이벤트 바인드
	function setControl(){
		/*
		$.ajax({
			url:"/approval/common/getEntInfoListDefaultData.do",
			type:"post",
			async:false,
			success:function (data) {				
				$("#selectUseAuthority").append("<option value=''>전체</option>");
				$(data.list).each(function(index){
					$("#selectUseAuthority").append("<option value='"+this.optionValue+"'>"+this.optionText+"</option>");
				});					
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/common/getEntInfoListDefaultData.do", response, status, error);
			}
		});
		*/
		// EntCode 기반으로 (not DomainID)
		/*
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do");
		$("#selectUseAuthority").bindSelect({			
			onchange: function(){
				searchConfig();
			}
		});
		*/
		
		//사용유무 select 변경시
		//$("#sel_lUseYN").change(function(){ //$('input[type=radio][name=rdblUseYN]').change(function() {
		//	 searchConfig();
		//});
		
		//$("#sel_Search").bindSelect({
        //	onChange: function(){
        //		//toast.push(Object.toJSON(this));
        //	}
        //});
		
		// 앱스토어 양식리스트는 추가버튼 없음
		if(_isCstfList == "Y") {
			$("#btnFormAdd").remove();
			$("#spn_title").text('<spring:message code="Cache.lbl_appStoreFormManage"/>'); // 앱스토어 양식 관리
		}
		else {
			$("#btnFormAdd").show();
			$("#spn_title").text('<spring:message code="Cache.lbl_apv_FormManage"/>'); // 양식 관리
		}
		
		// 페이지 개수 변경
		$("#selectPageSize").on('change', function(){
			setGridConfig();
			searchConfig();
		});
		
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
		
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){
		var paramEntCode = $("#hidden_domain_val").val(); //$("#selectUseAuthority").val();
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_AddMode'/>","/approval/manage/goAdminFormPopup.do?mode=add&paramEntCode="+paramEntCode,"994px","800px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey, pModifyAcl){		
		var FormID = configkey;
		if(pModifyAcl == "Y"){
			objPopup = parent.Common.open("","updateConfig","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_EditMode'/>","/approval/manage/goAdminFormPopup.do?mode=modify&FormID="+FormID,"994px","800px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateVersion(pModal, configkey, pModifyAcl){		
		var FormID = configkey;		
		if(pModifyAcl == "Y"){
			objPopup = parent.Common.open("","updateVersion","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_VersionUp'/>","/approval/manage/goAdminFormPopup.do?mode=SaveAs&FormID="+FormID,"994px","800px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
	}
	
</script>