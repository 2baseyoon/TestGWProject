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

<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width:150px;">
							<col style="width:auto;">
						</colgroup>
						<tbody>
							<tr>
								<!-- 회사 -->
								<th><spring:message code='Cache.ACC_lbl_company'/></th>
								<td>
									<div class="box">
										<span id="companyCode" class="selectType02"></span>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 표준적요 -->
								<th><spring:message code='Cache.ACC_standardBrief'/></th>
								<td>
									<div class="box">
										<input id="accountCode" type="hidden">
										<input id="accountName" type="hidden">
										<input id="standardBriefId" type="hidden">
										<input id="standardBriefName" type="text" readOnly class="HtmlCheckXSS ScriptCheckXSS">
										<a onclick="insertMobileReceipt.standardBriefSearchPopup()" class="btnTypeDefault btnResInfo"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 가맹점명 -->
								<th><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></th>
								<td>
									<div class="box">
										<textarea id="storeName" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputFranchiseCorpName'/>"></textarea>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 청구금액 -->
								<th><spring:message code='Cache.ACC_billReqAmt'/></th>
								<td>
									<div class="box">
										<input id="amount" type="text" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<!-- 내역 -->
								<th><spring:message code='Cache.ACC_useHistory'/></th>
								<td>
									<div class="box">
										<textarea id="usageText" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputComment'/>"></textarea>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 사용일자 -->
								<th><spring:message code='Cache.ACC_lbl_approveDate'/></th>
								<td>
									<div class="box">
										<div id="useDateInput" class="dateSel type02"></div>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 사용시간 -->
								<th><spring:message code='Cache.lbl_useTime'/></th>
								<td>
									<div class="box">
										<input type="time" id="useTime" class="HtmlCheckXSS ScriptCheckXSS" style="padding: 5px;">
									</div>
								</td>
							</tr>
							<tr>
								<!-- 촬영일자 -->
								<th><spring:message code='Cache.ACC_lbl_photoDate'/></th>
								<td>
									<div class="box">
										<div id="photoDateInput" class="dateSel type02"></div>
									</div>
								</td>
							</tr>
							<tr>
								<!-- 영수증 -->
								<th>
									<div class="BC_File_btn" style="position: static; margin-top: 0px;">
										<a href="#" class="btn_Fadd" onClick="insertMobileReceipt.fileAttach('@@{ProofCode}', '@@{KeyNo}')">
											<spring:message code='Cache.ACC_lbl_receipt'/>
										</a>
									</div>
								</th>
								<td>
									<input type="hidden" id="fileName">
									<input type="hidden" id="frontAddPath">
									<input type="hidden" id="savedName">
									<input type="hidden" id="size">
									<div id="file_area" class="box">
										
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="popBtnWrap bottom">
					<a onclick="insertMobileReceipt.save();" id="btnSave" class="btnTypeDefault btnThemeLine">
						<spring:message code='Cache.ACC_btn_save' />
					</a>
					<a onclick="insertMobileReceipt.closeLayer();" id="btnClose" class="btnTypeDefault">
						<spring:message code='Cache.ACC_btn_cancel'/>
					</a>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	if (!window.insertMobileReceipt) {
		window.insertMobileReceipt = {};
	}

	(function(window) {
		var insertMobileReceipt = {
			params : {
			
			},
			popupInit: function(){
				var me = this;
				
				me.setSelectCombo();
				me.setDatepicker();
			},
			setSelectCombo: function() {
				var AXSelectMultiArr = [	
					{ 
						'codeGroup': 'CompanyCode',
						'target': 'companyCode',		
						'lang': 'ko',	
						'onchange': '',	
						'oncomplete': '',	
						'defaultVal': ''
					}
				];
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, Common.getSession("DN_Code"));
			},
			setDatepicker: function(){
				makeDatepicker('useDateInput','useDate','','','','');
				makeDatepicker('photoDateInput','photoDate','','','','');
			},
			standardBriefSearchPopup : function() {
				var popupName	=	"StandardBriefSearchPopup";
				var popupID		=	"standardBriefSearchPopup";
				var openerID	=	"insertMobileReceipt";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief' />"; //표준적요
				var popupYN		=	"Y";
				var callBack	=	"standardBriefSearchPopup_callBack";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+	"popupYN="		+	popupYN		+	"&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"1025px","725px","iframe",true,null,null,true);
			},
			standardBriefSearchPopup_callBack : function(info){
				var me = this;
				
				var accountCode = info.AccountCode;
				var accountName = info.AccountName;
				var standardBriefID = info.StandardBriefID;
				var standardBriefName = info.StandardBriefName;
				
				$("#accountCode").val(accountCode);
				$("#accountName").val(accountName);
				$("#standardBriefId").val(standardBriefID);
				$("#standardBriefName").val(standardBriefName);
			},
			fileAttach: function() {
				accountFileCtrl.callFileUpload(this, 'insertMobileReceipt.fileAttach_callBack');
			},
			fileAttach_callBack: function(data) {
				var me = window.insertMobileReceipt;
				accountFileCtrl.closeFilePopup();
				me.uploadHtml(data);
				
				$("#fileName").val(data[0].FileName);
				$("#frontAddPath").val(data[0].FrontAddPath);
				$("#savedName").val(data[0].SavedName);
				$("#size").val(data[0].Size);
			},
			uploadHtml: function(data) {
				for (var i = 0; i < data.length; i++) {
					if (i > 0) { break; }
					
					var fileHtmlStr = "<div class='file_list' name='file_Item'>"
					fileHtmlStr += "<a href='javascript:void(0);' class='btn_FileDel' style='position: relative; left: 0px;' onClick=\"insertMobileReceipt.fileDelete();\"></a>";
					fileHtmlStr += "<a href='javascript:void(0);' class='btn_File ico_file'>" + data[i].FileName;
					fileHtmlStr += "<span class='tx_size'>("+ ckFileSize(data[i].Size) +")</span></a></div>";
					
					$("#file_area").append(fileHtmlStr);
				}
			},
			fileDelete: function() {
				$("#file_area").html("");
			},
			save: function() {
				$.ajax({
					url: "/account/mobileReceipt/insertMobileReceipt/save.do",
					type: "POST",
					data: JSON.stringify({
						companyCode: accountCtrl.getComboInfo("companyCode").val(),
						accountCode: $("#accountCode").val(),
						standardBriefId: $("#standardBriefId").val(),
						amount: $("#standardBriefId").val(),
						storeName: $("#storeName").val(),
						usageText: $("#usageText").val(),
						useDate: $("#useDate").val().replace(/\./g, ''),
						useTime: $("#useTime").val(),
						photoDate: $("#photoDate").val().replace(/\./g, ''),
						fileName: $("#fileName").val(),
						frontAddPath: $("#frontAddPath").val(),
						savedName: $("#savedName").val(),
						size: $("#size").val()
					}),
					dataType: "json",
					contentType: "application/json",
					success: function (data) {
						if(data.status == "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							return;
							try{
								accountCtrl.popupCallBackStr([]);
								insertMobileReceipt.closeLayer();
							} catch (e) {
								console.log(e);
								console.log(CFN_GetQueryString("callBackFunc"));
							}
						} else {
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error: function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			closeLayer : function(){
				var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
				var popupID	= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			}
		}
		window.insertMobileReceipt = insertMobileReceipt;
	})(window);
	
	insertMobileReceipt.popupInit();
</script>