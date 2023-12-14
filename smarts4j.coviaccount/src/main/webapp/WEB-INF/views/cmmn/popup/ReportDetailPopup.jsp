<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<style>
	.pad10 {padding:10px;}
	.btnExcel {float:right; margin-top:10px;}
</style>
<body>
	<input id="ProofMonth"	type="hidden" />
	<input id="DeptCode"	type="hidden" />	
	<div class="Layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width: auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="eaccountingCont">
						<div>
							<span id="popupTit" class="squaregragh_Title"></span>					
							<!-- 엑셀저장 -->
							<a class="btnTypeDefault btnExcel" href="#" onclick="ReportDetailPopup.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
						</div>
						<!-- 검색 내용 -->
						<div id="topitembar02" class="bodysearch_Type01">
							<div class="inPerView type08">
								<div style="width: 1100px;">
									<div class="inPerTitbox">
										<!-- 기안자 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_aprvWriter'/> </span> 
										<input id="RegisterName" class="w100p" onkeydown="ReportDetailPopup.onenter()" type="text" placeholder="">
									</div>
									<div class="inPerTitbox" style="display:none;" name="costCenterArea">
										<!-- 코스트센터 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_costCenter'/> </span>
										<div class="name_box_wrap">
											<span class="name_box" id="CostCenterName" ></span>
											<a class="btn_del03" onclick="ReportDetailPopup.deleteInfo('CostCenter')"></a>
										</div>
										<a class="btn_search03" onclick="ReportDetailPopup.openSearchPopup('CostCenter')"></a>
										<input type="hidden" id="CostCenterCode" >
									</div>
									<div class="inPerTitbox">
										<!-- 계정과목 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_account'/> </span>
										<div class="name_box_wrap">
											<span class="name_box" id="AccountName" name="popaccNameBox" ></span>
											<a class="btn_del03" onclick="ReportDetailPopup.accdeleteInfo()"></a>
										</div>
										<a class="btn_search03" onclick="ReportDetailPopup.accSearchPopup()"></a>
										<input type="hidden" name="searchParam" tag="AccountCode" id="AccountCode" >
									</div>
									<div class="inPerTitbox">
										<!-- 표준적요 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_standardBrief'/> </span>
										<div class="name_box_wrap">
											<span class="name_box" id="StandardBriefName" ></span>
											<a class="btn_del03" onclick="ReportDetailPopup.deleteInfo1()"></a>
										</div>
										<a class="btn_search03" onclick="ReportDetailPopup.openSearchPopup1()"></a>
										<input type="hidden" id="StandardBriefID" name="searchName" tag="ReportPopCode" >
									</div>
								</div>
							</div>
							<div class="inPerView type08" style="margin-top: 10px;">
								<div style="width: 1100px;">
									<div class="inPerTitbox">
										<!-- 적요 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_useHistory2'/> </span> 
										<input id="UsageComment" class="w100p" onkeydown="ReportDetailPopup.onenter()" type="text">
									</div>
									<div class="inPerTitbox">
										<!-- 청구금액 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_billReqAmt'/> </span> 
										<input id="SearchAmtSt" target="SearchAmtEd" class="w100p right" onkeydown="ReportDetailPopup.onenter()" type="text"										
												onkeydown="ReportDetailPopup.onCkNum(this)"
												onkeyup="ReportDetailPopup.onSetNum(this);"
												onblur="ReportDetailPopup.onBlurNum(this);">
										~										 
										<input id="SearchAmtEd" target="SearchAmtSt" class="w100p right" onkeydown="ReportDetailPopup.onenter()" type="text"										
												onkeydown="ReportDetailPopup.onCkNum(this)"
												onkeyup="ReportDetailPopup.onSetNum(this);"
												onblur="ReportDetailPopup.onBlurNum(this);">
									</div>
									<a class="btnTypeDefault  btnSearchBlue" onclick="ReportDetailPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
								</div>
							</div>	
						</div>
						<div id="gridArea" class="pad10">
						</div>
					</div>
				</div>
				<div class="popBtnWrap bottom">
					<!-- 닫기 -->
					<a onclick="ReportDetailPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	
	if (!window.ReportDetailPopup) {
		window.ReportDetailPopup = {};
	}
	
	(function(window) {
		var ReportDetailPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function(){
					var me = this;

					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					//상단 Title 세팅
					$("#popupTit").html(parent.$("span.divpop_header_ico").html());
					
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;


					me.params.headerData = [{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",	width:'100',	align:'center'},	//CostCenter명
											{	key:'RegisterName',			label:"<spring:message code='Cache.ACC_lbl_aprvWriter' />",		width:'50',		align:'center'},	//기안자
											{	key:'ProofDate',			label:"<spring:message code='Cache.ACC_lbl_proofDate' />",		width:'50',		align:'center'},	//증빙일자
											{	key:'AccountName',			label:"<spring:message code='Cache.ACC_lbl_account' />",		width:'50',		align:'center'},	//계정과목
											{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_standardBrief' />",		width:'100',	align:'center'},	//표준적요
											{	key:'UsageComment',			label:"<spring:message code='Cache.ACC_lbl_useHistory2' />",	width:'150',	align:'center'},	//적요
											{	key:'Amount',				label:"<spring:message code='Cache.ACC_billReqAmt' />",			width:'50',		align:'right',
												formatter: function () { 
													return CFN_AddComma(this.item.Amount+"");
												}
											} //청구금액
										]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
						
					var ProofMonth		= $('#ProofMonth').val();
					var RegisterName	= $('#RegisterName').val();
					var CostCenterCode	= $('#CostCenterCode').val();
					var DeptCode		= $('#DeptCode').val();
					var AccountCode		= $('#AccountCode').val();
					var AccountName		= $('#AccountName').text();
					var StandardBriefID	= $('#StandardBriefID').val();
					var StandardBriefName	= $('#StandardBriefName').text();
					var UsageComment 	= $('#UsageComment').val();
					var SearchAmtSt 	= $('#SearchAmtSt').val().replace(/,/gi, '');
					var SearchAmtEd 	= $('#SearchAmtEd').val().replace(/,/gi, '');
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountPortal/getReportDetailList.do";
					var ajaxPars		= {
											"ProofMonth"		: ProofMonth
					 					,	"CostCenterCode"	: CostCenterCode
					 					,	"DeptCode"			: DeptCode
										,	"RegisterName"		: RegisterName
				 						,	"AccountCode"		: AccountCode
				 						,	"AccountName"		: AccountName
				 						,	"StandardBriefID"	: StandardBriefID
				 						,	"StandardBriefName"	: StandardBriefName
				 						,	"UsageComment"		: UsageComment
				 						,	"SearchAmtSt"		: SearchAmtSt
				 						,	"SearchAmtEd"		: SearchAmtEd
				 						};
					
					var pageSizeInfo	= 200;
					var pageNoInfo		= 1;
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: 'Y'
									, 	"pagingTF"		: false
									,	"height"		: "480px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
				
				tempObj : {},
				
				pageOpenerIDStr : "openerID=ReportDetailPopup&",
				
				//계정과목
				accdeleteInfo : function() {
					var me = this
					$("#AccountName").text("");
					$("#AccountCode").val("");
				},
				//계정과목 팝업
				accSearchPopup : function() {
					var me = this;
					var popupID		=	"accountSearchPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
					var popupName	=	"AccountSearchPopup";
					var callBack	=	"mthAccSum_accSearchComp";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	me.pageOpenerIDStr
									+	"callBackFunc="	+	callBack;
					Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);				
				},
				 mthAccSum_accSearchComp : function(value) {
					var me = this
					$("#AccountName").text(value.AccountName);
					$("#AccountCode").text(value.AccountCode);
				}, 
			
				
				//표준적요
				deleteInfo1 : function() {
					var me = this
					$("#StandardBriefName").text("");
					$("#StandardBriefID").text("");
					
					/* var labelField = accountCtrl.getInfoName("accNameBox").text("");
					var cdField = accountCtrl.getInfoStr("[name=searchName][tag=ReportPopCode]").val(""); */
				},
				
				//표준적요 입력 팝업 호출
				openSearchPopup1 : function(StandardBrief) {
					var me = this;
					
					var popupID		=	"standardBriefSearchPopup";
					var popupTit	=	"표준적요";
					var popupName	=	"StandardBriefSearchPopup";
					var callBack	=	"combiCostApp_setDivSBVal";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
					//				+	"StandardBriefSearchStr="	+	Base64.utf8_to_b64(accComm[requestType].pageExpenceFormInfo.StandardBriefSearchStr)	+	"&" //CEO대쉬보드에서는 필요없음
									+	me.pageOpenerIDStr
									+	"includeAccount=N&"
									+	"companyCode="	+	me.CompanyCode	+ "&"
									+	"callBackFunc="	+	callBack;
					Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				},
				
				combiCostApp_setDivSBVal : function(value) {
					var me = this
					$("#StandardBriefName").text(value.StandardBriefName);
					$("#StandardBriefID").text(value.StandardBriefID);
					
				}, 
				
				excelDownload : function() {
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
				       		var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var headerType	= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							
							var ProofMonth		= $('#ProofMonth').val();
							var RegisterName	= $('#RegisterName').val();
							var CostCenterCode	= $('#CostCenterCode').val();
							var DeptCode		= $('#DeptCode').val();
							var AccountCode		= $('#AccountCode').val();
							var StandardBriefID	= $('#StandardBriefID').val();
							var UsageComment 	= $('#UsageComment').val();
							var SearchAmtSt 	= $('#SearchAmtSt').val().replace(/,/gi, '');
							var SearchAmtEd 	= $('#SearchAmtEd').val().replace(/,/gi, '');
							
							var title			= $("#popupTit").html().split(" (")[0]; //금액 부분 제거 (컴마가 들어가면 크롬에서 다운로드 불가)
							
							var	locationStr		= "/account/accountPortal/getReportDetailListExcel.do?"
												//+ "headerName="				+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="				+ encodeURI(headerKey)
												+ "&headerType=" 			+ encodeURI(headerType)
												//+ "&title="					+ encodeURI(title)
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&ProofMonth="			+ encodeURI(ProofMonth)
												+ "&RegisterName="			+ encodeURI(RegisterName)
												+ "&CostCenterCode="		+ encodeURI(CostCenterCode)
												+ "&DeptCode="				+ encodeURI(DeptCode)
												+ "&AccountCode="			+ encodeURI(AccountCode)
												+ "&UsageComment="			+ encodeURI(UsageComment)
												+ "&SearchAmtSt="			+ encodeURI(SearchAmtSt)
												+ "&SearchAmtEd="			+ encodeURI(SearchAmtEd);
							
							parent.location.href = locationStr;
						}
					});
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				},
				onCkNum : function(obj){
					var me = this;
					
					var preVal = obj.value;
					var keyCd = event.keyCode;
					
					var keyList = [
					               8,46//삭제
					               ,9//tab
					               ,16,17,18 //alt,ctrl,shift
					               ,27//esc
					               ,37,38,36,40//방향키
					               ,112,113,114,115,116,117,118,119,120,121,122,123//펑션키
					               ];
					
					if(keyCd=="13"){
						me.searchList();
					} else if(keyList.indexOf(keyCd) != -1) {
						return;
					} else if(!((keyCd>=48 && keyCd<=57) || (keyCd>=96 && keyCd<=105) || keyCd==188)) {
						event.preventDefault();
						event.returnValue = false;
					}
				},
				onSetNum : function(obj){
					var me = this;
					var objVal = obj.value;
					var objVal = objVal.replace(/[^0-9,-.]/g, "");
					obj.value = objVal;
				},				
				onBlurNum : function(obj) {
					var me = this;
					
					var numVal = AmttoNumFormat(obj.value);					
					if(isNaN(numVal) || isEmptyStr(numVal)){
						obj.value = "";
						return;
					}
					numVal = ckNaN(numVal);
					
					var targetField = obj.getAttribute("target");
					var numTargetVal = AmttoNumFormat($("#"+targetField).val());
					if(isNaN(numTargetVal) || isEmptyStr(numTargetVal)){
						obj.value = toAmtFormat(numVal);
						return;
					}
					numTargetVal = ckNaN(numTargetVal);
					
					if(targetField == "SearchAmtEd" && numVal > numTargetVal){
						obj.value = toAmtFormat(numTargetVal);
					} else if(targetField == "SearchAmtSt" && numVal < numTargetVal){
						obj.value = toAmtFormat(numTargetVal);
					} else {
						obj.value = toAmtFormat(numVal);
					}
				}
				
		}
		window.ReportDetailPopup = ReportDetailPopup;
	})(window);
	
	ReportDetailPopup.pageInit();
</script>
