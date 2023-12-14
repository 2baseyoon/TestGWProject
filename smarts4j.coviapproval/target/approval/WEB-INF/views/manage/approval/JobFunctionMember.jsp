<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramJobFunctionID =  param[1].split('=')[1];
	var doublecheck = false;
	$(document).ready(function (){
		setGrid();			// 그리드 세팅			
	});	
	// 헤더 설정
	var headerData =[
	                  {key:'UR_Name',  label:'<spring:message code="Cache.lbl_apv_AdminName"/>', width:'150', align:'center',
	                	  formatter:function () {		
					   			return "<a href='#' class='txt_underline'>"+ this.item.UR_Name + "</a>";
						  }
	                  },
	                  {key:'UserCode',  label:'<spring:message code="Cache.lbl_apv_AdminID"/>', width:'150', align:'center'},	                  
	                  {key:'DEPT_NAME',  label:'<spring:message code="Cache.lbl_apv_AdminDept"/>', width:'150', align:'center'},	                
	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>', width:'100', align:'center', sort:"asc"}	                  
		      		];
	
	var JobFunctionMemberGrid = new coviGrid();
	JobFunctionMemberGrid.config.fitToWidthRightMargin = 0;
	
	//그리드 세팅
	function setGrid(){
		JobFunctionMemberGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "JobFunctionMembergrid",
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
						updateConfig(true,this.item.JobFunctionMemberID);
				    }
			}
		};
		
		JobFunctionMemberGrid.setGridConfig(configObj);
	}
	
	// baseconfig 검색
	function searchConfig(flag){
		JobFunctionMemberGrid.page.pageNo = "1";
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
	
		JobFunctionMemberGrid.bindGrid({
				ajaxUrl:"getJobFunctionMemberList.do",
				ajaxPars: {
					"JobFunctionID":paramJobFunctionID,
					"sel_Search":sel_Search,
					"search":search,
					
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
// 					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
// 					JobFunctionMemberGrid.fnMakeNavi("JobFunctionMemberGrid");
// 					$("#sel_Search").bindSelect();
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){		
		Common.open("","updateConfig","<spring:message code='Cache.lbl_apv_chargedocSet'/>|||<spring:message code='Cache.lbl_apv_charge_person'/>","goJobFunctionMemberDetailPopup.do?mode=modify&key="+configkey,"530px","300px","iframe",pModal,null,null,true);
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
	
	parent._CallBackMethod2 = setJFMemberList;
	
	function setJFMemberList(peopleValue){
		var gridMemberData = {"members" : JobFunctionMemberGrid.list};
		var duplicationChk = false;
		
		var JobFunctionMemberArray = new Array();
		jQuery.ajaxSettings.traditional = true;
		
		var dataObj = $.parseJSON(peopleValue);	
		
		$(dataObj.item).each(function(i){
			duplicationChk = false;
			
			if($$(gridMemberData).find("members[UserCode="+dataObj.item[i].AN+"]").length > 0){
				duplicationChk = true;
			}
			
			if(!duplicationChk){
				if(dataObj.item[i].AN != undefined){
					var JobFunctionMemberObj = new Object();				
					JobFunctionMemberObj.JobFunctionID = paramJobFunctionID;
					JobFunctionMemberObj.UserCode = dataObj.item[i].AN;
					JobFunctionMemberObj.SortKey = "0";
					JobFunctionMemberObj.Weight = i;
					JobFunctionMemberArray.push(JobFunctionMemberObj);
				}
			}
		});	
		
		//jsavaScript 객체를 JSON 객체로 변환
		JobFunctionMemberArray = JSON.stringify(JobFunctionMemberArray);		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"jobFunctionMember" : JobFunctionMemberArray
			},
			url:"insertJobFunctionMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				searchConfig();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertJobFunctionMember.do", response, status, error);
			}
		});
	}
</script>
<div class="sadmin_pop sadminContent">
	<div class="selectCalView mb10">			
		<label>
			<select class="selectType02 w150p"  name="sel_Search" id="sel_Search" >
				<option selected="selected" value="DEPT_NAME"><spring:message code="Cache.lbl_apv_AdminDept"/></option>
				<option value="UR_Name"><spring:message code="Cache.lbl_apv_AdminName"/></option>
				<option value="UserCode"><spring:message code="Cache.lbl_apv_AdminID"/></option>														
			</select>
			<div class="dateSel type02">
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="w200p" />
			</div>
			<a onclick="searchConfig(1);" class="btnTypeDefault btnSearchBlue nonHover" ><spring:message code="Cache.btn_search"/></a>
		</label>			
	</div>
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addConfig(true);"><spring:message code="Cache.btn_Add" /></a>
		</div>
		<div class="buttonStyleBoxRight">
			<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
		</div>
	</div>
	<div id="JobFunctionMembergrid" class="tblList tblCont"></div>
</div>
<!-- 	<input type="hidden" id="hidden_domain_val" value=""/> -->
<!-- 	<input type="hidden" id="hidden_worktype_val" value=""/> -->
