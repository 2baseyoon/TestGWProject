<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	

	<div class="collabo_popup_wrap">
	
		<div class="selectCalView">
			<select class="selectType02" id="seColumn" style="width:130px;"></select>
			<div class="dateSel type02">
				<input type="text" id="seValue">
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch"><spring:message code='Cache.btn_search'/></a>	<!-- 검색 -->
		</div>
		
		<div class="c_titBox">
			<h3 class="cycleTitle2"><spring:message code='Cache.lbl_progressproject'/></h3>	<!-- 진행중인 프로젝트 -->
		</div>
		<div class="tblList tblCont boradBottomCont StateTb">
			<div id="collabGridDiv"></div>
		</div>
		
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
			
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnCancel"><spring:message code='Cache.btn_apv_apvlist_default_n'/></a>
			
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Close'/></a>
		</div>
		
		<div class="collabo_help">
			<p> <spring:message code='Cache.msg_collab10'/> </p>	<!-- 알림을 받을 프로젝트만 선택할 수 있습니다. -->
		</div>
		
	</div>
</body>
<script type="text/javascript">
var collabProjectAlarm = {
		grid:'',
		objectInit : function(){	
			this.setSelect();
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
		}	,
		makeGrid :function(){
			var configObj = {	
					targetID : "collabGridDiv",
					height : "auto",
					page : {
						pageNo: 1, 
						pageSize: 5
						},
					paging : true
			};
			var headerData =  [ 
				       {key:'chk', label:'chk', width:'46', align:'center', formatter:'checkbox', sort:false,
				    	   checked: function (){
				        	 //   return this.item.IsAlarm != null && this.item.IsAlarm != '';
				           }
				    	},
				       {key:'PrjName',  label:"<spring:message code='Cache.lbl_project_name'/>",width:'180',align:'left'},
				       {key:'PmUser',  label:"<spring:message code='Cache.lbl_admin'/>", width:'110', align:'left'},
				       {key:'Remark',  label:"<spring:message code='Cache.msg_collab11'/>", width:'*', align:'left'},
				       {key:'IsAlarm',  label:"<spring:message code='Cache.lbl_Alram'/>", width:'60', align:'left',
				    	   formatter : function () {
							 if (this.item.IsAlarm == null || this.item.IsAlarm == '')
								 return '<div class="bodyNode bodyTdText" align="center" id="" title=""><span class="collabo_alart"></span></div>';
							 else
								 return '<div class="bodyNode bodyTdText" align="center" id="" title=""><span class="collabo_alart on"></span></div>';
							}
				       },
				       {key:'PrjSeq',  label:'PrjSeq', display:false}
				];
			
			collabProjectAlarm.grid = new coviGrid();
			collabProjectAlarm.grid.setGridHeader(headerData);
			collabProjectAlarm.grid.setGridConfig(configObj);
		},
		addEvent : function(){	
			
			$("#btnSearch").on('click', function(){
				collabProjectAlarm.searchData(1);
			});
			
			$("#seValue").on('keydown', function(key){
				if (key.keyCode == 13)
					collabProjectAlarm.searchData(1);
			});
			
			$("#btnSave").on('click', function(){
				var prjSeqArr = '';
				$.each(collabProjectAlarm.grid.getCheckedList(0), function(i, v) {
					if (i > 0) prjSeqArr += ',';
					prjSeqArr += v.PrjSeq;
				});
				
				$.ajax({
					type : "POST",
					data : {prjSeqArr : prjSeqArr},
					async: false,
					url : "/groupware/collabProject/saveProjectAlarm.do",
					success: function (list) {
						collabProjectAlarm.searchData(1);
					},
					error: function(response, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			});
			
			$("#btnCancel").on('click', function(){
				var prjSeqArr = '';
				$.each(collabProjectAlarm.grid.getCheckedList(0), function(i, v) {
					if (i > 0) prjSeqArr += ',';
					prjSeqArr += v.PrjSeq;
				});
				
				$.ajax({
					type : "POST",
					data : {prjSeqArr : prjSeqArr},
					async: false,
					url : "/groupware/collabProject/cencelProjectAlarm.do",
					success: function (list) {
						collabProjectAlarm.searchData(1);
					},
					error: function(response, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
		},
		searchData:function(pageNo){
			var params = {
				 "seColumn": $("#seColumn").val()
				 ,"seValue": $("#seValue").val()
			};
			
			if (pageNo !="-1"){
				collabProjectAlarm.grid.page.pageNo =pageNo;
				collabProjectAlarm.grid.page.pageSize = 5;
			}	
			
			// bind
			collabProjectAlarm.grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabProject/getGoingProject.do"
			});

		},
		setSelect:function(){
			
			// Select Box 바인드
			var initInfos = [
				{
					target : 'seColumn',
					codeGroup : 'ProjectAlarmUse',
					defaultVal : 'PrjName',
					width : '130',
					onchange : ''
				}
			];
			
			coviCtrl.renderAjaxSelect(initInfos, '', lang);
			
		}
}

$(document).ready(function(){
	collabProjectAlarm.objectInit();
});

</script>