<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">양식 관리</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input id="btnFormAdd" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);" style="display:none;"/>	
			&nbsp;&nbsp;
			<spring:message code='Cache.lbl_UseAuthority'/>:
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;		
			<select class="AXSelect" name="sel_Search" id="sel_Search" >
				<option selected="selected" value="FormName"><spring:message code='Cache.lbl_FormNm'/></option>
				<option value="FormPrefix"><spring:message code='Cache.lbl_FormID'/></option>
				<option value="FormClassName"><spring:message code='Cache.lbl_classNm'/></option>	
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />				
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
			&nbsp;&nbsp;&nbsp;&nbsp;                  
			<input name="rdblUseYN" id="rdblUseYN_0" type="radio" value="">
			<label for="rdblUseYN_0"><spring:message code='Cache.lbl_Whole'/></label>
			<input name="rdblUseYN" id="rdblUseYN_1" type="radio" checked="checked" value="Y">
			<label for="rdblUseYN_1"><spring:message code='Cache.lbl_UseY'/></label>					
			<input name="rdblUseYN" id="rdblUseYN_2" type="radio" value="N">
			<label for="rdblUseYN_2"><spring:message code='Cache.lbl_UseN'/></label>
			
		</div>	
		<div id="GridViewFormList"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>
<script type="text/javascript">
	const _isCstfList = "${param.isCstf}"; // 앱스토어(Covision STored Form list) 여부
	
	var myGrid = new coviGrid();
	initAdminFormList();

	function initAdminFormList(){
		
		// 앱스토어 양식리스트는 추가버튼 없음
		if(_isCstfList == "Y") $("#btnFormAdd").remove();
		else $("#btnFormAdd").show();
		
		setSelect();		
		setGrid();			// 그리드 세팅			
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정 - 첫 컬럼은 앱스토어 여부에따라 하단에서 추가(unshift)
		var headerData =[	            
		                  {key:'FormName',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE03'/>', width:'180', align:'left',
		                	  formatter:function(){return CFN_GetDicInfo(this.item.FormName);}
		                  },	                  
		                  {key:'FormPrefix',  label:'<spring:message code='Cache.lbl_FormID'/>', width:'170', align:'left'},
		                  {key:'Revision', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE06'/>', width:'45', align:'center'},
		                  {key:'IsUse',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE12'/>', width:'45', align:'center', sort:"desc"},
		                  {key:'SchemaName', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE04'/>', width:'150', align:'left'},
		                  {key:'SortKey',  label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE07'/>', width:'45', align:'center'},	                  
		                  {key:'EntName',  label:'<spring:message code='Cache.lbl_aclTarget'/>', width:'100', align:'left'},
		                  {key:'RegDate', label:'<spring:message code='Cache.lbl_apv_formcreate_LCODE15'/>', width:'80', align:'center',
		                	  formatter:function(){return CFN_TransLocalTime(this.item.RegDate, "yyyy-MM-dd");}
						  },
		                  {key:'FormID',  label:' ', width:'80', align:'center',
		                	  formatter:function () {
		                		  return "<input class='smButton' type='button' value='<spring:message code='Cache.lbl_VersionUp'/>'  onclick='updateVersion(true, \""+ this.item.FormID +"\",\"" + this.item.ModifyAcl + "\")'; return false;'>";
			      				}
		                	  },
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
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){
					     //toast.push(Object.toJSON({index:this.index, r:this.r, c:this.c, item:this.item}));					    
					    if(!(Object.toJSON(this.c).replaceAll("\"", "")=='9')){
					    	updateConfig(true,Object.toJSON(this.item.FormID).replaceAll("\"", ""), this.item.ModifyAcl);
					    }
					    
					 }			
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	

	
	// baseconfig 검색
	function searchConfig(flag){
		var EntCode = $("#selectUseAuthority").val();	
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var IsUse = $("input[name=rdblUseYN]:checked").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getAdminFormListData.do",
				ajaxPars: {
					"EntCode":EntCode,
					"sel_Search":sel_Search,
					"search":search,
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

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey, pModifyAcl){		
		var FormID = configkey;
		if(pModifyAcl == "Y"){
			objPopup = parent.Common.open("","updateConfig","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_EditMode'/>","/approval/admin/goAdminFormPopup.do?mode=modify&FormID="+FormID,"965px","800px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
	}
	
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateVersion(pModal, configkey, pModifyAcl){		
		var FormID = configkey;		
		if(pModifyAcl == "Y"){
			objPopup = parent.Common.open("","updateVersion","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_VersionUp'/>","/approval/admin/goAdminFormPopup.do?mode=SaveAs&FormID="+FormID,"965px","800px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// Select box 바인드
	function setSelect(){
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
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do");
		$("#selectUseAuthority").bindSelect({			
			onchange: function(){
				searchConfig();
			}
		});
		
		
		
		
		//라디오버튼변경시
		$('input[type=radio][name=rdblUseYN]').change(function() {			
			 searchConfig();
		});
		
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){
		var paramEntCode = $("#selectUseAuthority").val();
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_FormManage_instruction'/>|||<spring:message code='Cache.lbl_AddMode'/>","/approval/admin/goAdminFormPopup.do?mode=add&paramEntCode="+paramEntCode,"965px","800px","iframe",pModal,null,null,true);
	}
	
</script>