<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
%>
<link rel="stylesheet" type="text/css" href="<%=cssPath %>/moduleLicense/resources/css/moduleLicense.css">

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.lbl_license_user_manage"/></h2> 	<!-- 라이선스 사용자 관리 -->
</div>		

<div class="cRContBottom mScrollVH">
<!-- 컨탠츠 시작 -->
	<div class="moduleLC sadminContent">
		<table style="width:100%">
			<tbody>
				<tr>
					<td id="td01TblCodeGroup" style="vertical-align: top; width:450px; border-right-style: solid;">
						<!-- 라이선스 정보 grid -->
						<div id="divLicenseInfo" class="tblList tblCont" style="height: auto;"></div>
					</td>
					
					<td style="vertical-align: top;">
						<div style="margin-left: 5px; height: auto;">
							<a href="#axtree"></a>

							<table class="license_table">
								<tbody>
									<tr>
										<th><spring:message code="Cache.lbl_att_approval"/><spring:message code="Cache.ACC_lbl_quantity"/></th> 	<!-- 신청수량 -->
										<th><spring:message code="Cache.lbl_tempCnt"/></th> <!-- 임시수량 -->
										<th><spring:message code="Cache.lbl_tempDeadline"/></th> 	<!-- 임시기한 -->
										<th><spring:message code="Cache.lbl_usedCount"/></th> 	<!-- 사용수량 -->
										<th><spring:message code="Cache.lbl_n_att_remain"/><spring:message code="Cache.ACC_lbl_quantity"/></th> 	<!-- 잔여수량 -->
									</tr>
									<tr>
										<td id="approvalCnt">0</td> 	<!-- 신청수량 -->
										<td id="tempCnt">0</td> 	<!-- 임시수량 -->
										<td id="tempDeadline">0000-00-00</td> 	<!-- 임시기한 -->
										<td id="usedCnt">0</td> 	<!-- 사용수량 -->
										<td id="remainCnt">0</td> 	<!-- 잔여수량 -->
									</tr>
								</tbody>
							</table>
							
							<!-- 검색영역 -->
							<div class="selectCalView mb10"> 	
								<select class="selectType02 w150p" id="searchCategory"> 	<!-- 검색 카테고리 -->
									<option value="name" selected><spring:message code="Cache.CPMail_UserName"/></option> 	<!-- 사용자명 -->
									<option value="dept"><spring:message code="Cache.lbl_User"/><spring:message code="Cache.lbl_dept"/></option> 	<!-- 사용자 부서-->
								</select>
								<div class="dateSel type02">
									<input type="text" id="searchText" value="" class="w200p"> 	<!-- 검색어 -->
								</div>
								<!-- 검색 버튼 -->
								<a href="#" id="searchBtn" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.lbl_search"/></a>
							</div>
						
							<!-- 버튼 -->
							<div class="sadminMTopCont">
								<div class="pagingType02 buttonStyleBoxLeft">
									<a id="btnAdd" class="btnTypeDefault btnPlusAdd" href="#"><spring:message code="Cache.btn_Add" /></a> 	<!-- 추가 -->
									<a id="btnDel" class="btnTypeDefault btnSaRemove" href="#"><spring:message code="Cache.btn_delete" /></a>  	<!-- 삭제 -->
								</div>
								<div class="buttonStyleBoxRight">
									<button id="btnRefresh" class="btnRefresh" type="button" href="#"></button>
								</div>
							</div>
						
							<!-- UserGrid -->
							<div class="tblList tblCont">
								<div class="AXGrid" id="divUserInfo" style="overflow:hidden;height:auto;width:100%;"></div>
							</div>
							
						</div>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
<!-- 컨탠츠 끝 -->
</div>


<script type="text/javascript">
//# LicenseUserManage.jsp (그룹웨어설정, 시스템관리, 라이선스 사용자 관리)

var confLicense = {
		
	gridLicenseInfo : new coviGrid(),
	licHeaderData : [
		{key:'IsOpt', label:'<spring:message code="Cache.lbl_Standard"/>', width:'50', align:'center', formatter : function() {
			// 기준이 'Y'인 것만 글로 보여준다.
			var strOpt = "";
			if (this.item.IsOpt === 'Y') {
				strOpt = this.item.IsOpt;
			}
			return strOpt;
		}}		<!-- 기준 -->
		, {key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'150', align:'center'} 	<!-- 라이선스 -->
		, {key:'Description', label:'<spring:message code="Cache.lbl_licenseDescription"/>', width:'200', align:'left'}		<!-- 라이선스 설명 -->
	],
	
	gridUserInfo : new coviGrid(),
	userHeaderData : [
		{key:'chk', label:'chk', width:'30', align:'center', formatter:'checkbox'}
		, {key:'UserName', label:'<spring:message code="Cache.CPMail_UserName"/>', width:'100', align:'center'
			/*, formatter : function() {
				var licUserCount = parseInt(confLicense.gridLicenseInfo.getSelectedItem().item.LicUserCount);
				var rowNumber = parseInt(this.item.RNUM);
				if (rowNumber > licUserCount ) {
					return "<p style='color: red;'>" + this.item.UserName + "</p>";
				} else {
					return this.item.UserName;
				}
			}*/} 	<!-- 사용자명 -->
		, {key:'LogonID', label:'<spring:message code="Cache.lbl_UserID"/>', width:'*', align:'center'
			/*, formatter : function() {
				var licUserCount = parseInt(confLicense.gridLicenseInfo.getSelectedItem().item.LicUserCount);
				var rowNumber = parseInt(this.item.RNUM);
				if (rowNumber > licUserCount ) {
					return "<p style='color: red;'>" + this.item.LogonID + "</p>";
				} else {
					return this.item.LogonID;
				}
			}*/}		<!-- 사용자ID -->
		, {key:'DeptName', label:'<spring:message code="Cache.lbl_User"/><spring:message code="Cache.lbl_dept"/>', width:'200', align:'center'}	<!-- 사용자부서 -->
		, {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center'}	<!-- 사용여부 -->
		, {key:'UserCode', display:false}
		, {key:'LicSeq', display:false}
		, {key:'DomainID', display:false}
		, {key:'RNUM', display:false}
	],
	
	setConfigGrid : function() {
		// 라이선스 정보 grid set.
		this.gridLicenseInfo.setGridHeader(this.licHeaderData);
		this.gridLicenseInfo.setGridConfig({
			targetID : "divLicenseInfo",
			height : "auto",
			width : "auto",
			body : {
				onclick: function() {
					// 선택한 라이선스의 수량 및 기한 보여줌.
					confLicense.setCntInfo(confLicense.gridLicenseInfo.getSelectedItem().item);
					// 사용자 조회
					var strLicSeq = "";
					var strIsOpt = "";
					strLicSeq = confLicense.gridLicenseInfo.getSelectedItem().item.LicSeq;
					strIsOpt = confLicense.gridLicenseInfo.getSelectedItem().item.IsOpt;
					
					confLicense.searchUser(strLicSeq, strIsOpt);
				}			},
			page : false
		});
		// 라이선스 사용자 정보 grid set.
		this.gridUserInfo.page.pageNo = 1;
		this.gridUserInfo.setGridHeader(this.userHeaderData);
		this.gridUserInfo.setGridConfig({
			targetID : "divUserInfo"
			, height : "auto"
			, sort : true
			, body:{
		        addClass: function() {
		        	var licUserCount = parseInt(confLicense.gridLicenseInfo.getSelectedItem().item.LicUserCount);
		        	var rowNumber = parseInt(this.item.RNUM);
					if (rowNumber > licUserCount ) {
						return "red";
					}
		        }}
		});
	},
	
	getLicenseInfo : function() {
		var licSeq;
		var strIsOpt = "";
		
		this.gridLicenseInfo.bindGrid({
			ajaxUrl: "/covicore/manage/domain/getLicenseInfo.do",
			ajaxPars: {
				"domainId" : confMenu.domainId
			},
			onLoad : function() {
				// 선택하지 않은 초기 상태에서는 첫번째 라이선스의 수량 및 기한을 보여줌.
				if (confLicense.gridLicenseInfo.list.length > 0) {
					if ( confLicense.gridLicenseInfo.getSelectedItem().item === undefined ) {
						confLicense.setCntInfo(confLicense.gridLicenseInfo.list[0]);
						licSeq = confLicense.gridLicenseInfo.list[0].LicSeq;
						strIsOpt = confLicense.gridLicenseInfo.list[0].IsOpt;
						
						confLicense.gridLicenseInfo.setFocus(0);
						
					} else {
						licSeq = confLicense.gridLicenseInfo.getSelectedItem().item.LicSeq;
						strIsOpt = confLicense.gridLicenseInfo.getSelectedItem().item.IsOpt;
					}
				}
				// 결과값으로 자동 조회.
				confLicense.searchUser(licSeq, strIsOpt);			
			}
		});
	},
	
	setCntInfo : function(item) {
		
		$("#approvalCnt").text(item.LicUserCount);
		$("#tempCnt").text(item.ExtraServiceUser);
		
		// 날짜 포맷.
		var extraDate = item.ExtraExpiredate;
		if (extraDate.length === 8) {
			$("#tempDeadline").text(extraDate.substr(0,4) + "-" + extraDate.substr(4,2) + "-" + extraDate.substr(6,2));
		} else {
			$("#tempDeadline").text(item.ExtraExpiredate);
		}
		
		$("#usedCnt").text(item.LicUsingCnt);
		$("#remainCnt").text(item.RemainCnt);
		
		// 부가 라이선스(IsOpt == 'Y')의 경우에만 사용자 추가/삭제 버튼 보여짐. 
		if (item.IsOpt !== 'Y') {
			$('.btnPlusAdd').hide();
			$('.btnSaRemove').hide();
		} else {
			$(".btnPlusAdd").show();
			$(".btnSaRemove").show();
		}
	},
	// 사용자 조회
	searchUser : function(pLicSeq, pIsOpt) {
		var lang = Common.getSession("lang");
		
		if ( $("#divUserInfo").length > 0 ) {
			if (confLicense.gridLicenseInfo.list.length > 0) {
				this.gridUserInfo.bindGrid({
					ajaxUrl : "/covicore/manage/domain/getUserInfo.do"
					, ajaxPars : {
						"licSeq" : pLicSeq
						, "isOpt" :pIsOpt
						, "lang" : lang
						, "category" : $("#searchCategory option:selected").val()
						, "searchText" : $("#searchText").val()
						, "pageSize" : "10"
						, "domainId" : confMenu.domainId
					}
				});
			}
		}
	}

	// 사용자 추가 팝업
	, addUserPopup : function(callBackFunc) {
		if (callBackFunc === undefined || callBackFunc === '') {
			callBackFunc = "licenseUserManagePopup";
		}
		var licSeq;
		// 선택한 행이 없을 때는 첫번째 행의 LicSeq로 조회.
		if ( (confLicense.gridLicenseInfo.getSelectedItem().item === undefined) && (confLicense.gridLicenseInfo.list.length > 0) ) {
			licSeq = confLicense.gridLicenseInfo.list[0].LicSeq;
		} else {
			licSeq = confLicense.gridLicenseInfo.getSelectedItem().item.LicSeq;
		}
		
		var popupUrl = "/covicore/manage/domain/LicenseUserManagePopup.do?";
		var title = '<spring:message code="Cache.lbl_User"/><spring:message code="Cache.lbl_Add"/>'; 	// 사용자 추가
		var w = "500";
        var h = "650";
        var params = "domainId="+confMenu.domainId+"&licSeq="+licSeq+"&callback="+callBackFunc;
        
        CFN_OpenWindow(popupUrl+params, "", w, h, "");
	}
	, setEvent : function() {
		// 검색 버튼 이벤트
		$("#searchBtn").on("click", function() {
			var licSeq;
			var strIsOpt = "";
			
			// 선택한 행이 없을 때는 첫번째 행의 LicSeq로 조회.
			if ( (confLicense.gridLicenseInfo.getSelectedItem().item === undefined) && (confLicense.gridLicenseInfo.list.length > 0) ) {
				licSeq = confLicense.gridLicenseInfo.list[0].LicSeq;
				strIsOpt = confLicense.gridLicenseInfo.list[0].IsOpt;
				
			} else {
				licSeq = confLicense.gridLicenseInfo.getSelectedItem().item.LicSeq;
				strIsOpt = confLicense.gridLicenseInfo.getSelectedItem().item.IsOpt;
			}

			confLicense.searchUser(licSeq, strIsOpt);
		});
		$("#searchText").on("keydown", function(event) {
			if (event.keyCode === 13) {
				event.preventDefault();
				$("#searchBtn").trigger('click');
			}
		});
		
		// 추가 버튼 이벤트
		$("#btnAdd").on("click", function() {
			// 회사 내 사용자 조회.
			confLicense.addUserPopup(); 
		});
		
		// 삭제 버튼 이벤트
		$("#btnDel").on("click", function() {
			if ( confLicense.gridUserInfo.getCheckedList(0).length > 0 ) {
				confLicense.delUserLicense(confLicense.gridUserInfo.getCheckedList(0));
			} else {
				Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />"); 	// 선택된 항목이 없습니다.
			}
		});
		
		// 새로고침 이벤트
		$("#btnRefresh").on("click", function() {
			$("#searchBtn").trigger('click');
		});
		
		// postMessage callback event(사용자 라이선스 추가)
		window.addEventListener('message', function(e) {
			switch (e.data.functionName) {
				case "licenseUserManagePopup":
					$("#searchBtn").trigger('click');
					break;
			}
		});
	}
	, delUserLicense : function(item) {
		var strParam = "";
		var strTemp = "";
		for (var i=0; item.length > i; i++) {
			
			strParam += item[i].UserCode + ":"+item[i].LicSeq+":"+item[i].DomainID+",";
		}
		
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "<spring:message code='Cache.lbl_Confirm'/>", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					type : "POST",
					url : "/covicore/manage/domain/deleteUserLicense.do",
					data : {"list" : strParam},
					success : function (data) {
						if (data.status === "SUCCESS") {
							$("#searchBtn").trigger('click');
						} else {
							Common.Warning("<spring:message code='Cache.msg_apv_030' />"); 	// 오류가 발생했습니다.
						}
					},
					error:function(response, status, error) {
                        CFN_ErrorAjax("", response, status, error);
                  	}
				});
			} else {
				return false;
			}
		});
		
	}
	, initContent : function() {
		this.setEvent();
		
		// gridSetting.
		this.setConfigGrid();
		// 라이선스 정보 가져오기
		this.getLicenseInfo();
	},

}
	
$(document).ready(function(){
	confLicense.initContent();
});
	
</script>