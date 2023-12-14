<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<form>
	<div id="content" style="padding:20px;">
		<h3 class="con_tit_box">
			<span class="con_tit"><spring:message code="Cache.lbl_executive_inform"/></span>
		</h3>
	
		<div style="width:100%;min-height: 200px">
			<!-- Grid -->
			<div id="resultBoxWrap">
				<div id="orgGrid"></div>
			</div>
		</div>
	</div>
</form>

<style>
	.con_tit_box{height:40px; padding-left:0px;}
	.con_tit_box .con_tit{font:normal 22px '맑은 고딕', Malgun Gothic,Apple-Gothic,dotum,돋움,sans-serif; color:#222; line-height:20px; padding-left:20px; background:url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/zadmin/ico_collection.gif) no-repeat 0 -88px; }
</style>

<script>
	var orgGrid = new coviGrid();
	var isMailDisplay = true;
	var lang = Common.getSession("lang");
	
	window.onload = initContent();

	function initContent(){		
		
		$.ajaxSetup({
			cache : false
		});
		setGrid(); 
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		orgGrid.setGridHeader([
// 							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'sort',  label:"<spring:message code='Cache.lbl_Number'/>", width:'30', align:'center'}, //우선순위
			                  {key:'DisplayName',  label:"<spring:message code='Cache.lbl_DisplayName'/>", width:'70', align:'center'}, //표시이름
			                  {key:'JobTitleName',  label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'50', align:'center'}, //직책			                  			                 
 			                  {key:'Secretarys',  label:"<spring:message code='Cache.btn_charge'/>", width:'150', align:'center', formatter : function() { //사용여부
			                	    var str =  '<span style="width:50px;height:20px;border:0px none;" id="Secretarys_';
			                  	    	str += this.item.UserCode;
			                  	    	str += '" >' + getArrangement(this.item.Secretarys) + '</span>';
			                		return  str;
			                  }},			                  
			                  {key:'StateName', label:"<spring:message code='Cache.lbl_prj_taskStatus'/>", width:'70', align:'center', formatter : function() { //사용여부
			                	  	var str =  '<select   onchange="stateChange(\'' + this.item.UserCode + '\',this)"  id="StateSelect_';
			                  	    	str += this.item.UserCode;
			                  	    	str += '" >';
			                  	    	str += selectString(this.item.State);
			                  	    	str += '</select>';
			                		return  str;
			                  }}
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//상태 변경 이벤트
	function stateChange(UserCode, Sel)
	{	
		$.ajax({
			type : "POST"
			, url : "/groupware/webpart/updateOfficerState.do"
			, data : { "UserCode":UserCode , "State": Sel.value}
			, success : function(data){
				if(data.status == "SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
					parent.ExecutiveOffice.getOfficerList();
				} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
			}
			, error : function(response, status, error){
	            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
	      	}
		});
	}
	
	// 리스트 셀렉트박스 생성
	function selectString(sel)
	{	
		var vRtn = "";
		$(Common.getBaseCode("AbsenceCode").CacheData).each(function(idx, obj){
	    	if( obj.Code == sel)
			{
	    		vRtn += '<option selected value="'+ obj.Code +'">' + obj.CodeName + '</option>';
	    	}			                  	    			
			else
			{
				vRtn += '<option value="'+ obj.Code +'">' + obj.CodeName + '</option>';
			}
		});
		
		return vRtn;
	}
	
	// 담당자 다국어 처리
	function getArrangement(pNames){
		var vResult = "";
		
		if (pNames.startsWith(';'))
			vResult = pNames.substring(1);
		
		if (pNames.endsWith(';'))
			vResult = vResult.substring(0, pNames.length - 2);
		
		return vResult.replace(/;/g ,',')
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "orgGrid",
			height:"auto",
			xscroll:true,
			paging : false
		};
		
		// Grid Config 적용
		orgGrid.setGridConfig(configObj);
	}	

	function bindGridData() {
		
		orgGrid.page.pageNo = 1;
		orgGrid.bindGrid({
			ajaxUrl:"/groupware/webpart/getOfficerTargetList.do"
 		});		
	}
</script>