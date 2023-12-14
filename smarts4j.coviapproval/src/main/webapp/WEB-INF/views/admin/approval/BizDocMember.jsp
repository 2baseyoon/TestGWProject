<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocID =  param[1].split('=')[1];
	var doublecheck = false;
	$(document).ready(function (){
		setGrid();			// 그리드 세팅			
	});	
	// 헤더 설정
	var headerData =[
	                  {key:'UR_Name',  label:'<spring:message code="Cache.lbl_apv_AdminName"/>', width:'150', align:'center'},	           
	                  {key:'UR_Code',  label:'<spring:message code="Cache.lbl_apv_AdminID"/>', width:'150', align:'center'},	                  
	                  {key:'DEPT_NAME',  label:'<spring:message code="Cache.lbl_apv_AdminDept"/>', width:'150', align:'center'},	                
	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>', width:'100', align:'center', sort:"asc"}	                  
		      		];
	
	var BizDocMemberGrid = new coviGrid();
	
	//그리드 세팅
	function setGrid(){
		BizDocMemberGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "BizDocMembergrid",
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
						updateConfig(true,this.item.BizDocMemberID);
				    }
			}
		};
		
		BizDocMemberGrid.setGridConfig(configObj);
	}
	
	// baseconfig 검색
	function searchConfig(flag){		
		$(".AXPaging[value=1]").click();
		
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
	
		BizDocMemberGrid.bindGrid({
				ajaxUrl:"getBizDocMemberList.do",
				ajaxPars: {
					"BizDocID":paramBizDocID,
					"sel_Search":sel_Search,
					"search":search
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
					BizDocMemberGrid.fnMakeNavi("BizDocMemberGrid");
					$("#sel_Search").bindSelect();
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){		
		Common.open("","updateConfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","goBizDocMemberDetailPopup.do?mode=modify&key="+configkey,"530px","220px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		$("#sel_Search").val($("#sel_Search").find("option").eq(0).val());
		$("#search").val("");
		searchConfig();
	}
	
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){
		//objPopup.close(); 
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	
	parent._CallBackMethod2 = setBizMemberList;
	
	function setBizMemberList(peopleValue){
		var gridMemberData = {"members" : BizDocMemberGrid.list};
		var duplicationChk = false;
		
		var BizDocMemberArray = new Array();
		jQuery.ajaxSettings.traditional = true;
		
		var dataObj = $.parseJSON(peopleValue);	
		
		$(dataObj.item).each(function(i){
			duplicationChk = false;
			
			if($$(gridMemberData).find("members[UR_Code="+dataObj.item[i].AN+"]").length > 0){
				duplicationChk = true;
			}
			
			if(!duplicationChk){
				if(dataObj.item[i].AN != undefined){
					var BizDocMemberObj = new Object();				
					BizDocMemberObj.BizDocID = paramBizDocID;
					BizDocMemberObj.UserCode = dataObj.item[i].AN;
					BizDocMemberObj.SortKey = "0";
					BizDocMemberArray.push(BizDocMemberObj);
				}
			}
		});	
		
		//jsavaScript 객체를 JSON 객체로 변환
		BizDocMemberArray = JSON.stringify(BizDocMemberArray);		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"BizDocMember" : BizDocMemberArray
			},
			url:"insertBizDocMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				searchConfig();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertBizDocMember.do", response, status, error);
			}
		});
	}
</script>
<form id="BizDocMember">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<label>
				<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
				<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);"/>	
				&nbsp;&nbsp;											
			</label>					
		</div>	
		<div id="topitembar02" class="topbar_grid">			
			<label>
				<spring:message code="Cache.lbl_apv_search"/>
				<select class="AXSelect"  name="sel_Search" id="sel_Search" >
					<option selected="selected" value="DEPT_NAME"><spring:message code="Cache.lbl_apv_AdminDept"/></option>
					<option value="UR_Name"><spring:message code="Cache.lbl_apv_AdminName"/></option>
					<option value="UR_Code"><spring:message code="Cache.lbl_apv_AdminID"/></option>														
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
			</label>			
		</div>	
		<div id="BizDocMembergrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>