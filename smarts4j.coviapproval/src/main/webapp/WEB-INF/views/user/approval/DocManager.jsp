<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>
	
<div class="cRConTop titType">
	<h2 class="title" id="govDocsTit"><spring:message code='Cache.lbl_apv_govdoc_manager' /></h2>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<!-- 임시 -->					
				<a id="addUser" class="btnTypeDefault" >추가</a>
			</div>
			<div class="buttonStyleBoxRight">	
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>									
				<button class="btnRefresh" id="refresh"></button><!-- 새로고침 -->
			</div>
		</div>
		<!-- grid -->
		<div class="apprvalBottomCont">
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list" style="width:100%;">
						<div id="approvalListGrid"></div>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>

<script>	
	var ListGrid = new coviGrid();
	var initData={};
	var Constants  = {			
		HEADER : [
			 	 /* {key:'R_NUM'  			,label:'정렬'		,width:'10'		,align:'center'} */
			 	{key:'AUTHORITY_NAME'  ,label:'권한 사용자',width:'20'		,align:'center'
			 		,formatter: function(){
			 			var item =  this.item;
			 			return $("<a>", { "id" : "authName"	, "text" :  item.YN_ADMIN === 'Y' ? '관리자' :  item.AUTHORITY_NAME }).get(0).outerHTML			 			
			 		}	
			 	}
			 	,{key:'LIST_UNIT_NM'  	,label:'담당부서'	,width:'70'		,align:'left'}		    
			]
	}

	var govDocFunction = {		 	
		init : function(){	
			/* grid */
			ListGrid.setGridHeader(Constants.HEADER);
			ListGrid.setGridConfig({
				targetID : "approvalListGrid",
				height:"auto",
				page: {
					pageNo: 1,
					pageSize: $("#selectPageSize").val()
				},
				paging: true,
				//notFixedWidth : 4,
				sort        : false,
				overflowCell : [],
				body: {
			        onclick  : function(){
			        	var id = $( event.target ).attr('id');				
						if( !id ) return;
						
						switch( id ){
							case "authName" :
								Common.open("", "addUser", "특정 사용자에게 대외공문 관리자 및 담당자 권한을 부여합니다."
										,"/approval/user/govDocUserAdd.do?authorityId="+this.item.AUTHORITYID, '650px', '400px', "iframe", true, null, null, true);
								break;
						}
			        }
			    }
			});
			ListGrid.bindGrid({ ajaxUrl : "/approval/user/getGovManager.do",ajaxPars: {} });			
			
			/* event */
			$("#refresh").on('click',function(){ ListGrid.reloadList(); });
			
			$('#addUser').on('click',function(){								
				Common.open("", "addUser", "특정 사용자에게 대외공문 관리자 및 담당자 권한을 부여합니다."
						,"/approval/user/govDocUserAdd.do", '650px', '400px', "iframe", true, null, null, true);
			});
		}		
	}

	//일괄 호출 처리
	initApprovalListComm(govDocFunction.init, govDocFunction.setGrid);
</script>