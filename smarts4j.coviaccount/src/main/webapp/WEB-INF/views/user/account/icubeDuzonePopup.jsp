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
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 30%;" />
						<col style="width: 70%;" />
						
					</colgroup>
					<tbody>
						<tr>

							<th>	<!-- 전표일자 -->
								<spring:message code='Cache.ACC_slipYearMonth'/>
								<span class="star"></span>
							</th>
							<td>
								<div class="box">
									<div id="issueDateArea" class="dateSel type02">
									</div>
									<!-- 
									* yyyy-MM-dd 형식으로 입력하세요.
									 -->
								</div>
							</td>
						</tr>				
						<tr>
							<th colspan="2">
								<div style="size: 15px">선택 항목</div>
								
							</th>
						</tr>	
						<tr>
							<td colspan="2" style="border-left: 0px;">
								<div id="columnList"></div>
							</td>
						</tr>
					</tbody>
				</table>
				<div style="height:10px">
				</div>								
				<div class="popBtnWrap bottom">
					<a onclick="icubeDuzon.excelDown();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>
	
	if (!window.icubeDuzon) {
		window.icubeDuzon = {};
	}
	
	(function(window) {
		var icubeDuzon = {
				pageColumnData : [		
						{ key:'CO_CD',		label : '<spring:message code="Cache.ACC_lbl_companyCode"/>',			width:'70', align:'left'},
						{ key:'IN_DT',			label : '<spring:message code="Cache.ACC_lbl_TransactionDate"/>',			width:'70', align:'center'},
						{ key:'IN_SQ',			label :  '<spring:message code="Cache.ACC_lbl_ListNo"/>',			width:'70', align:'center'},
						{ key:'LN_SQ',			label : '<spring:message code="Cache.ACC_lbl_DivNo"/>',			width:'70', align:'center'},
						{ key:'DIV_CD',		label : '<spring:message code="Cache.ACC_lbl_accUnit"/>',				width:'70', align:'center'},
						{ key:'DRCR_FG',		label : '<spring:message code="Cache.ACC_lbl_drcrType"/>',			width:'70', align:'center'},
						{ key:'ACCT_CD',		label : '<spring:message code="Cache.ACC_lbl_accountCode"/>',		width:'70', align:'right'},
						{ key:'REG_NB',		label : '<spring:message code="Cache.ACC_lbl_vendorBusinessNo"/>',		width:'70', align:'center'},
						{ key:'ACCT_AM',				label : '<spring:message code="Cache.ACC_lbl_amt"/>',		width:'70', align:'center'},
						{ key:'RMK_DC',			label : '<spring:message code="Cache.ACC_lbl_useHistory2"/>',			width:'70', align:'center'},
						{ key:'PJT_CD',			label : '<spring:message code="Cache.ACC_lbl_projectCode"/>',				width:'70', align:'center'},
						{ key:'CT_AM',			label : '<spring:message code="Cache.ACC_lbl_supplyValue"/>',			width:'70', align:'center'}, 
						{ key:'CT_DEAL',				label : '<spring:message code="Cache.ACC_taxType"/>',				width:'70', align:'center'},
						{ key:'NONSUB_TY',			label : '<spring:message code="Cache.ACC_subType"/>',				width:'70', align:'center'},
						{ key:'FR_DT',		label : '<spring:message code="Cache.ACC_lbl_decDate"/>',			width:'70', align:'center'},
						{ key:'ISU_DOC',		label : '<spring:message code="Cache.ACC_lbl_comment"/>',	width:'70', align:'center'},
						{ key:'JEONJA_YN',	label : '<spring:message code="Cache.ACC_lbl_taxbillYN"/>',		width:'70', align:'center'},
						{ key:'CT_NB',		label : '<spring:message code="Cache.ACC_lbl_operNo"/>',		width:'70', align:'center'},
						{ key:'TR_CD',		label : '<spring:message code="Cache.ACC_lbl_vendorCode"/>',		width:'70', align:'center'},
						{ key:'TR_NM',		label :  '<spring:message code="Cache.ACC_lbl_vendorName"/>',		width:'70', align:'center'}						
				],
				params : {
					pageDataObj				: {},
					pageCardApplicationID	: "${CardApplicationID}",
					cardList				: [],
					cardMap					: {}
				},				
				popupInit : function(){
					var me = this;
					makeDatepicker('issueDateArea','issueDate','','','','');
					me.makeColumnField();
				},				
				makeColumnField : function() {
					var me = this;
					var chkStr = "";			      				
					for(var i=0; i<me.pageColumnData.length; i++) {
						chkStr +=  "<input type='checkbox' name='headerData' value='" + me.pageColumnData[i].key + "' style='margin: 5px;' label='" + me.pageColumnData[i].label + "' checked='checked'>" + me.pageColumnData[i].label  + "<br>";
					}				
					$("#columnList").html(chkStr);				
				},
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				excelDown : function(type){
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }				    
					var me  = this;
					
					if($("input:checkbox[name=headerData]:checked").length == 0 ) {
						Common.Inform("<spring:message code='Cache.ACC_msg_chkCheck'/>");	 // 내려받을 항목을 선택해주세요.
						return false;
					}
					// 체크한것들 객체로 만들고
					var headArr = new Array();					
					$("input:checkbox[name=headerData]:checked").each(function(i, chk) {
						
						var obj = new Object();
						obj.key = $(chk).attr("value");
						obj.label = $(chk).attr("label");
						obj.width ="70";
						obj.align = "left";
						headArr.push(obj);						
					});
					
					// 헤더 뽑고 키 뽑고
					var headerName		= accountCommon.getHeaderNameForExcel(headArr);
					var headerKey		= accountCommon.getHeaderKeyForExcel(headArr);
					
					var slipDate 		= $("#issueDate").val();
					
					if(slipDate == "") {
						Common.Inform("<spring:message code='Cache.ACC_msg_slipdateSel'/>");	 // 전표월을 선택해주세요.
						return false;
					}					
					// 날려
					var	locationStr		= "/account/expenceApplication/excelDownloadERP.do?"
						//+ "headerName="								+ nullToBlank(headerName)
						+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
						+ "&headerKey="								+ nullToBlank(headerKey)
						+ "&slipDate="								+ slipDate
						+ "&title="									+ 'douzoneiCube' 
						+ "&searchType="							+ 'douzone';						
					location.href = locationStr;					
				}
		}
		window.icubeDuzon = $.extend(window.icubeDuzon, icubeDuzon);
	})(window);
	
	icubeDuzon.popupInit();
	
</script>