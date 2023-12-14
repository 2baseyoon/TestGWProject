<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 발송완료 -->

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

<script>
	
	/* 그리드 헤더 */
	var gridHeader =[
		 {key:'DOC_NUMBER'  ,label:'문서번호'	,width:'50'		,align:'center'}
		,{key:'RECEIVER_NAME'  ,label:'이력보기'	,width:'50'		,align:'center'}
		/* ,{key:''  ,label:'수신처'		,width:'50'		,align:'center'} */
		,{key:'PROCESS_SUBJECT'  ,label:'제목'		,width:'100'	,align:'center'}
		/* ,{key:'E'  ,label:'작성자'		,width:'50'		,align:'center'} */
		,{key:'SEND_DATE'  ,label:'완료일시'	,width:'50'		,align:'center'}
		/* ,{key:'G'  ,label:'발송번호'	,width:'50'		,align:'center'} */
		,{key:'SEND_STATUS'  ,label:'문서상태'	,width:'50'		,align:'center'}		    
	];
	
	/* 그리드 설정 */
	var gridConfig = {
		targetID : "approvalListGrid",
		height:"auto",		
		paging : true,
		notFixedWidth : 4,
		overflowCell : []
	}
	/* init */
	var contentInit = function(){
		ListGrid.setGridHeader(gridHeader);
		ListGrid.setGridConfig(gridConfig);		
		ListGrid.bindGrid({ ajaxUrl:"/approval/user/getGovApvListCmpl.do" ,ajaxPars: {} });
	}
</script>