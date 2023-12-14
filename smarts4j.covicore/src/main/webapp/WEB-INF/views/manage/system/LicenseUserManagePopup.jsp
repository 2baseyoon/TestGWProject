<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.AXGrid input:disabled{background-color:#Eaeaea}
</style>

<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent taskAppointedContent">
			<!--팝업 내부 시작 -->
			<div class="selectSearchBox">
				<select class="selectType02 w150p" id="popupCategory"> 	<!-- 검색 카테고리 -->
					<option value="name" selected><spring:message code="Cache.CPMail_UserName"/></option> 	<!-- 사용자명 -->
					<option value="dept"><spring:message code="Cache.lbl_User"/><spring:message code="Cache.lbl_dept"/></option> 	<!-- 사용자 부서-->
				</select>
				
				<span>
					<input id="searchText" type="text">
					<a id="btnSearch" class="btnSearchType01"></a>
				</span>
				<!-- 새로고침 -->
				<button id="btnRefresh" class="btnRefresh" type="button"></button>					
			</div>
			<div class="surTargetBtm">
				<div class="tblList">
					<div id="grid"></div>
				</div>
			</div>
			
			<div class="bottom">
				<a id="btnConfirm" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_Confirm'/></a> <!-- 확인 -->
				<a id="btnCancel" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
			<!--팝업 내부 끝 -->
		</div>
	</div>
</div>

<script>
	//# sourceURL=LicenseUserManagePopup.jsp
	
	(function(param){
		var grid = new coviGrid();
		
		var init = function(){
			setEvent();
			setGridConfig();
			setGrid();
		}
		
		var setEvent = function(){
			$("#searchText").on("keypress", function(){
				if(event.keyCode === 13) search();
			});
			
			$("#btnSearch").on("click", search);
			
			$("#btnRefresh").on("click", refresh);
			
			$("#btnConfirm").on("click", function(){
				if ( grid.getCheckedList(0).length > 0 ) {
					grantLicense();
				} else {
					Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />"); 	// 선택된 항목이 없습니다.
				}
			});
			
			$("#btnCancel").on("click", function(){
				Common.Close();
			});
		}
		
		// 그리드 Config 설정
		var setGridConfig = function(){
			grid.setGridHeader([	            
				{key:'chk', label:'chk', width:'30', align:'center', formatter:'checkbox'}
				, {key:'UserName', label:'<spring:message code="Cache.CPMail_UserName"/>', width:'100', align:'center'} 	<!-- 사용자명 -->
				, {key:'LogonID', label:'<spring:message code="Cache.lbl_UserID"/>', width:'*', align:'center'} 			<!-- 사용자ID -->
				, {key:'DeptName', label:'<spring:message code="Cache.lbl_User"/><spring:message code="Cache.lbl_dept"/>', width:'100', align:'center'}	<!-- 사용자부서 -->
				, {key:'UserCode', display: false}
			]);
			
			var configObj = {
				targetID: "grid",
				height: "auto",
				paging: true,
				page: {
					pageNo: 1,
					pageSize: 8
				}
			};
			
			grid.setGridConfig(configObj);
		}
		
		//그리드 세팅
		var setGrid = function(){
			
			var domainId = CFN_GetQueryString("domainId");
			var licSeq = CFN_GetQueryString("licSeq");
			
			grid.bindGrid({
				ajaxUrl: "/covicore/manage/domain/getLicenseAddUser.do",
				ajaxPars: {
					"domainId"	: CFN_GetQueryString("domainId"),
					"licSeq"	: CFN_GetQueryString("licSeq"),
					"searchText": $("#searchText").val(),
					"category" : $("#popupCategory option:selected").val(),
					"lang" : Common.getSession("lang"),
				}
			});	
		}
		
		var refresh = function(){
			grid.reloadList();
		}
		
		var search = function(){
			grid.page.pageNo = 1;
			setGrid();
		}
		
		var grantLicense = function() {
			
			var paramList = "";
			var checkedList = grid.getCheckedList(0);
			
			for (var i=0; checkedList.length > i; i++) {
				paramList += checkedList[i].UserCode + ",";
			}
			
			var callback = CFN_GetQueryString("callback");
			
			// 저장하시겠습니까?
			Common.Confirm("<spring:message code='Cache.msg_155' />", "<spring:message code='Cache.lbl_Confirm'/>", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						type : "POST",
						url : "/covicore/manage/domain/grantLicense.do",
						data : {"list" : paramList, "licSeq" : CFN_GetQueryString("licSeq"), "domainId" : CFN_GetQueryString("domainId")},
						success : function (data) {
							if (data.status === "SUCCESS") {
								// 저장완료 후 부모창 사용자목록 새로고침 및 팝업 닫기(grantLicenseCallback).
								window.opener.postMessage({
									"functionName" : callback
									, "param" : CFN_GetQueryString("licSeq")
								}, '*');
								Common.Close();
							} else {
		                    	Common.Warning("<spring:message code='Cache.msg_apv_030' />"); 	// 오류가 발생했습니다.
		                    }
						},
						error:function(response, status, error) {
	                        CFN_ErrorAjax("/covicore/manage/domain/grantLicense.do", response, status, error);
	                  	}
					});
				} else {
					return false;
				}
			});

		}
		
		init();
		
	})
	({})
</script>