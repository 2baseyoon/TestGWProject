<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	String requestType = request.getParameter("RequestType");
%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<div class="layer_divpop ui-draggable docPopLayer" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<div class="cnrl_bot">
						<div class="total_acooungting_table_btn">
							<div style="float:left">
								<a viewshow="Y" class="AXButton" style="vertical-align:middle;" onclick="AttendantPopup.clickAttendantBtn('I')"><spring:message code='Cache.ACC_lbl_innerAttendant'/></a> <!-- 내부 사용자 -->							
								<a viewshow="Y" class="AXButton" style="vertical-align:middle;" onclick="AttendantPopup.clickAttendantBtn('O')"><spring:message code='Cache.ACC_lbl_outerAttendant'/></a> <!-- 외부 사용자 -->
							</div>
							<a viewshow="Y" class="AXButton" style="vertical-align:middle;" onclick="AttendantPopup.deleteAttendant()"><spring:message code='Cache.ACC_btn_delete'/></a> <!-- 삭제 -->
						</div>
					</div>
					<table class="total_acooungting_table" style="font-size: 14px;">
						<colgroup>
							<col style="width: 3%">
							<col style="width: 14%;">
							<col style="width: 14%;">
							<col style="width: 14%;">
							<col style="width: 14%;">
							<col style="width: 14%;">
							<col style="width: 14%;">
							<col style="width: 13%;">
						</colgroup>
						<thead>
							<tr>
								<th width="30"><div class="chkStyle01"><input type="checkbox" id="simpApp_attendChkAll"><label for="simpApp_attendChkAll"><span></span></label></div></th>
								<th><spring:message code='Cache.ACC_lbl_attendantType'/></th> <!-- 대상자구분 -->
								<th><spring:message code='Cache.ACC_lbl_attendantSolicit'/></th> <!-- 청탁금지법 대상 -->
								<th><spring:message code='Cache.ACC_lbl_attendantCapital'/></th> <!-- 자본시장법 대상 -->
								<th><spring:message code='Cache.ACC_lbl_vendorName'/></th> <!-- 거래처명 -->
								<th><spring:message code='Cache.ACC_lbl_deptName'/></th> <!-- 부서명 -->
								<th><spring:message code='Cache.ACC_lbl_displayName'/></th> <!-- 성명 -->
								<th><spring:message code='Cache.ACC_lbl_perAmount'/></th> <!-- 1인당 지출금액 -->
							</tr>
						</thead>
						<tbody id="attendantTbody">
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a ViewShow="Y" onclick="AttendantPopup.CheckValidation();" id="btnSave" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a ViewShow="Y" onclick="AttendantPopup.closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>

<script>

function fn_findListItem(inputList, field, val) {
	var retVal = null;
	var arrCk = Array.isArray(inputList);
	if(arrCk) {
		retVal = accFind(inputList, field, val);
	}
	return retVal;
}
function fn_getProofKey(ProofCode) {
	var KeyField = "";
	
	switch(ProofCode) {
	case 'CorpCard':	KeyField = "CardUID"; break;
	case 'PrivateCard':	KeyField = "ExpAppPrivID"; break;
	case 'EtcEvid':		KeyField = "ExpAppEtcID"; break;
	case 'Receipt':		KeyField = "ReceiptID"; break;
	}
	
	return KeyField;
}
function fn_getPageList(ProofCode){
	var pageList;
	
	switch(ProofCode) {
	case "CorpCard":	pageList = 'cardPageExpenceAppList'; break;
	case "TaxBill":		pageList = 'taxBillPageExpenceAppList'; break;
	case "PaperBill":	pageList = 'paperBillPageExpenceAppList'; break;
	case "CashBill":	pageList = 'cashBillPageExpenceAppList'; break;
	case "PrivateCard":	pageList = 'privateCardPageExpenceAppList'; break;
	case "EtcEvid":		pageList = 'etcEvidPageExpenceAppList'; break;
	case "Receipt":		pageList = 'receiptPageExpenceAppList'; break;
	}
	
	return pageList;
}

if (!window.AttendantPopup) {
	window.AttendantPopup = {};
}

(function(window) {
	var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
	
	var AttendantPopup = {
			AttendInputForm : '',
			DailyExpenceTypeHtml : '',
			AttendantList : [],
			
			parentNM : '',
			parentMe : {},
			targetList : '',
			ProofCode : '',
			KeyNo : '',			
			
			popupInit : function() {
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					me[paramKey] = paramValue;
					if(paramKey == "ProofCode") {
						me.targetList = "pageExpenceApp"+paramValue+"List";
					}
				}

				var KeyField = fn_getProofKey(me.ProofCode);
				me.parentMe = window.parent[me.parentNM];
				
				if(me.parentMe.ApplicationType=="CO") {
					KeyField = 'KeyNo'; 
					me.targetList = fn_getPageList(me.ProofCode);//거래처정산서 작성시 아래로 안내린애들때문에
				}
				else {
					me.targetList = "pageExpenceApp"+me.ProofCode+"List";
				}
					
				if(me.IsView =='Y') {//수정시와 결재문서에서 오픈했을때 다른 targetList가 필요
					me.targetList = 'pageExpenceAppEvidList';	
					KeyField = 'ViewKeyNo';
				}
				
				var List;
				if(me.IsEditPopup =='Y') {
					me.targetList = 'pageExpenceAppTarget';	
					KeyField = 'KeyNo'; 
					List = me.parentMe[me.targetList];
				} else {
					var List = me.parentMe[me.targetList];
					List = fn_findListItem(List, KeyField, me.KeyNo); 
				}
				
				//var divItem = List.divList[0];
				
				var divItem;
				if(me.parentMe.ApplicationType=="CO") {
					divItem = fn_findListItem(List.divList, "Rownum", 'Rownum' in me ? me.Rownum : me.parentMe.tempObj.Rownum);
				} else { //SC
					divItem = fn_findListItem(List.divList, "Rownum", 'Rownum' in me ? me.Rownum : me.parentMe.tempVal.Rownum);
				}
				
				var codeJson = divItem.ReservedStr3_Div;
		        codeJson = codeJson[me.jsonCode];
		       
		        if ($.isEmptyObject(codeJson) || codeJson=='') {
		        	codeJson['AttendantList']= [];
		        } else {
		        	if(typeof codeJson =='string') codeJson = JSON.parse(codeJson);
		        }
		        
			  	me.AttendantList = $.extend([], codeJson['AttendantList']);
				me.popupFormInit();
				me.getAttendantInfo();
				
				if (me.IsView == 'Y') {
					$("input").attr('disabled', 'disabled');
					$("[ViewShow=Y]").css('display', 'none');
					$("select").attr('disabled', 'disabled');
					$(".icnDate").css('display', 'none');
				}
			},
			
			popupFormInit : function(){
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				$.get(formPath + "SimpAppPopupInputForm_Attend.html" + resourceVersion, function(val){
					me.AttendInputForm = val;
				});
			},
			
			//팝업 정보
			getAttendantInfo : function() {
				var me = this;
				if(me.AttendantList.length > 0) {
					for(var i = 0; i < me.AttendantList.length; i++){
						me.addAttendant(i, me.AttendantList[i]);
					}		
				}
			},
			
			//내부/외부 사용자 버튼 클릭
			clickAttendantBtn : function(attType) {
				var me = this;
				
				if(attType == "I"){
					var popupID		= "orgmap_pop";
					var openerID	= "AttendantPopup";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />"; //조직도
					var callBackFn	= "goOrgChart_CallBack";
					var type		= "B1";
					var popupUrl	= "/covicore/control/goOrgChart.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "callBackFunc="	+ callBackFn	+ "&"
									+ "type="			+ type;
					
					parent.window[callBackFn] = window[openerID][callBackFn];
					parent.Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
				} else if(attType == "O") {
					var InputItem = {
						AttendTypeCode : attType,
						AttendTypeName : "<spring:message code='Cache.ACC_lbl_customer'/>"
					};
					
					me.addAttendant(null, InputItem);
				}
			},
			
			goOrgChart_CallBack : function(orgData){
				var items	= JSON.parse(orgData).item;
				
				var InputItem = {
					AttendTypeCode	: "I",
					AttendTypeName	: "<spring:message code='Cache.ACC_lbl_employee'/>",
					CompanyCode		: items[0].ETID,
					CompanyName		: CFN_GetDicInfo(items[0].ETNM),
					DeptCode		: items[0].RG,
					DeptName		: CFN_GetDicInfo(items[0].RGNM),
					UserCode		: items[0].UserCode,
					UserName		: CFN_GetDicInfo(items[0].DN)
				}
				
				AttendantPopup.addAttendant(null, InputItem);
			},
			
			//참석자 행 추가
			addAttendant : function(Rownum, InputItem) {
				var me = this;
				var AttendForm = me.AttendInputForm;
				var isAdd = (Rownum == undefined ? true : false);
				
				if(isAdd) {
					if(me.AttendantList.length > 0)
						Rownum = me.AttendantList[me.AttendantList.length-1].Rownum + 1;
					else
						Rownum = 0;
				}
				
				var valMap = {
					ProofCode : me.ProofCode,
					KeyNo : me.KeyNo,
					Rownum : Rownum
				};
				
				if(InputItem != undefined) {
					valMap.AttendTypeCode = nullToBlank(InputItem.AttendTypeCode);
					valMap.AttendTypeName = nullToBlank(InputItem.AttendTypeName);
					valMap.Solicit = (InputItem.Solicit ? InputItem.Solicit : "N");
					valMap.Capital = (InputItem.Capital ? InputItem.Capital : "N");
					valMap.CompanyCode = nullToBlank(InputItem.CompanyCode);
					valMap.CompanyName = nullToBlank(InputItem.CompanyName);
					valMap.DeptCode = nullToBlank(InputItem.DeptCode);
					valMap.DeptName = nullToBlank(InputItem.DeptName);
					valMap.UserCode = nullToBlank(InputItem.UserCode);
					valMap.UserName = nullToBlank(InputItem.UserName);
					valMap.Amount = toAmtFormat(nullToBlank(InputItem.Amount));
				}
				
				if(isAdd) {
					me.AttendantList.push(valMap);
				}
				
				AttendForm = accComm.accHtmlFormSetVal(AttendForm, valMap);
				AttendForm = accComm.accHtmlFormDicTrans(AttendForm);
				
				$("#attendantTbody").append(AttendForm);
				
				$("[name=SolicitSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").val(valMap.Solicit);
				$("[name=CapitalSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").val(valMap.Capital);
				
				if(valMap.AttendTypeCode == "O") {
					$("[name=CompanyNameField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").removeAttr("readonly");
					$("[name=DeptNameField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").removeAttr("readonly");
					$("[name=UserNameField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").removeAttr("readonly");
				}
			},
			
			deleteAttendant : function() {
				var me = this;
				var fieldList = $("input[type=checkbox][name=RowCk]:checked");
				 
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
				
				for(var i=0;i<fieldList.length; i++){
			   		var checkedItem = fieldList[i];
					var Rownum = checkedItem.getAttribute("rownum");
					$("tr[name=AttendRowTR][rownum="+Rownum+"]").remove();
					
					var index = -1;
					$(me.AttendantList).each(function(i, obj) {
					    if($(obj).Rownum == Rownum) {
					        index = i;
					    }
					});
					me.AttendantList.splice(index, 1);
			   	}
			},
			
			//증빙 list에 입력된 값을 세팅
			setListVal : function(obj, Field, Rownum) {
				var me = this;
				var val = obj.value;
				var getItem = fn_findListItem(me.AttendantList, "Rownum", Rownum);
				getItem[Field] = val;
			},
			
			CheckValidation : function(){						
				var me = this;
				for(var i=0; i<me.AttendantList.length; i++) {
					var item = me.AttendantList[i];
					if(isEmptyStr(item.CompanyName)){
						var msg = "<spring:message code='Cache.ACC_msg_enterVendorName' />"; //거래처명을 입력해주세요
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.DeptName)){
						var msg = "<spring:message code='Cache.msg_GRNAME_01' />"; //부서명을 입력하십시오.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.UserName)){
						var msg = "<spring:message code='Cache.msg_ObjectUR_08' />"; //성명을 입력해 주십시오.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.Amount)){
						var msg = "<spring:message code='Cache.ACC_msg_inputAmount' />"; //금엑을 입력하세요.
						Common.Inform(msg);
						return;
					}
				}
				me.applyAttendInfo();
			},
			
			applyAttendInfo : function(){
				var me = this;
				var returnObj = [];
				var AttendantList = me.AttendantList;
				if(AttendantList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noApplyData' />");		//반영할 데이터가 없습니다.
					return;
				}
				
				returnObj['AttendantList'] = AttendantList;
				
				Common.Confirm(Common.getDic("ACC_msg_ckApply"), "Confirmation Dialog", function(result){	//반영하시겠습니까?
		       		if(result){
		       			me.closeLayer();
						try{
							accountCtrl.popupCallBackStrObj([returnObj]);
						}catch (e) {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
						}
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
	window.AttendantPopup = AttendantPopup; 
})(window);

AttendantPopup.popupInit();
	
</script>