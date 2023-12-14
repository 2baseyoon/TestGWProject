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
							<p class="total_acooungting_table_tit"><spring:message code='Cache.ACC_lbl_dailyExpenceList'/></p>
							<a ViewShow="Y" class="btn_add" style="vertical-align:middle;" onClick="ExpenceApplicationDailyPopup.addDailyExpence()"></a>
							<a ViewShow="Y" class="btn_del" style="vertical-align:middle;" onClick="ExpenceApplicationDailyPopup.deleteDailyExpence()"></a>
						</div>
					</div>
					<table class="total_acooungting_table" style="font-size: 14px;">
						<colgroup>
							<col style="width: 30px;">
							<col style="width: 240px;">
							<col style="width: 100px;">
							<col style="width: 130px;">
						</colgroup>
						<thead>
							<tr>
								<th width="30"><div class="chkStyle01"><input type="checkbox" id="expApp_dailyChkAll"><label for="expApp_dailyChkAll"><span></span></label></div></th>
								<th><spring:message code='Cache.ACC_lbl_bizTripDate'/></th> <!-- 출장일자 -->
								<th><spring:message code='Cache.ACC_lbl_dailyType'/></th> <!-- 일비유형 -->
								<th><spring:message code='Cache.ACC_lbl_amt'/></th> <!-- 금액 -->
							</tr>
						</thead>
						<tbody>
							<tr id="dailyExpenceList_trSum" >
								<th colspan="3" align="center" class="tfootbg"><spring:message code='Cache.ACC_lbl_itemSum'/></th> <!-- 합계 -->
								<td align="right" id="dailyAmountTotalSum">0</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<div style="font-size: 13px; margin-bottom: 10px;">
						<span class="txt_send_r">*</span>&nbsp;<spring:message code='Cache.ACC_msg_inputProofDateForDaily'/>
					</div>
					<a ViewShow="Y" onclick="ExpenceApplicationDailyPopup.CheckValidation();" id="btnSave" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a ViewShow="Y" onclick="ExpenceApplicationDailyPopup.closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
function fn_findListItem(inputList, field, val) {
	var retVal = null;
	var arrCk = Array.isArray(inputList);
	if(arrCk){
		retVal = accFind(inputList, field, val);
	}
	return retVal;
}
function fn_getProofKey(ProofCode) {
	var KeyField = "";
	if(ProofCode=='CorpCard'){
		KeyField = "CardUID";
	}else if(ProofCode=='PrivateCard'){
		KeyField = "ExpAppPrivID";
	}else if(ProofCode=='EtcEvid'){
		KeyField = "ExpAppEtcID";
	}else if(ProofCode=='Receipt'){
		KeyField = "ReceiptID";
	}
	return KeyField
}

//증빙 코드를 통해 각 증빙페이지의 list 반환
function fn_getPageList(ProofCode){
	var returnVal;
	if(ProofCode=="CorpCard"){
		return 'cardPageExpenceAppList';
	}
	else if(ProofCode=="TaxBill"){
		return 'taxBillPageExpenceAppList';
	}
	else if(ProofCode=="PaperBill"){
		return 'paperBillPageExpenceAppList';
	}
	else if(ProofCode=="CashBill"){
		return 'cashBillPageExpenceAppList';
	}
	else if(ProofCode=="PrivateCard"){
		return 'privateCardPageExpenceAppList';
	}
	else if(ProofCode=="EtcEvid"){
		return 'etcEvidPageExpenceAppList';
	}
	else if(ProofCode=="Receipt"){
		return 'receiptPageExpenceAppList';
	}
}
if (!window.ExpenceApplicationDailyPopup) {
	window.ExpenceApplicationDailyPopup = {};
}

(function(window) {
	var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
	
	var ExpenceApplicationDailyPopup = {
			DailyInputForm : '',
			DailyExpenceTypeHtml : '',
			DailyExpenceAppEvidList : [],
			
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
				} else{
					var List = me.parentMe[me.targetList];
					List = fn_findListItem(List, KeyField, me.KeyNo); 
				}
				
				var divItem;
				if(me.parentMe.ApplicationType=="CO") {
					divItem = fn_findListItem(List.divList, "Rownum", me.Rownum);
				} else {
					//divItem = List.divList[0];
					divItem = fn_findListItem(List.divList, "Rownum", 'Rownum' in me ? me.Rownum : me.parentMe.tempVal.Rownum);
				}
				
				var codeJson = divItem.ReservedStr3_Div;
		        codeJson = codeJson[me.jsonCode];
		       
		        if ($.isEmptyObject(codeJson) || codeJson=='') {
		        	codeJson['DailyExpenceAppEvidList']= [];
		        } else {
		        	if(typeof codeJson =='string') codeJson = JSON.parse(codeJson);
		        }
			  	
			  	me.codeJson_DailyExpenceAppEvidList = codeJson['DailyExpenceAppEvidList']
			  	
			  	me.DailyExpenceAppEvidList = $.extend([], me.codeJson_DailyExpenceAppEvidList);
				me.popupFormInit();
				me.getDailyExpenceInfo();
				
				if (me.IsView == 'Y') {
					$("input").attr('disabled', 'disabled');
					$("[ViewShow=Y]").css('display', 'none');
					$("select").attr('disabled', 'disabled');
					$(".icnDate").remove();
				}
			},
			
			popupFormInit : function(){
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				$.get(formPath + "ExpAppPopupInputForm_Daily.html" + resourceVersion, function(val){
					me.DailyInputForm = val;
				});
			},
			
			//팝업 정보
			getDailyExpenceInfo : function(){
				var me = this;
				if(me.DailyExpenceAppEvidList.length == 0) {
					me.addDailyExpence();
				} else {
					for(var i = 0; i < me.DailyExpenceAppEvidList.length; i++){
						me.addDailyExpence(i, me.DailyExpenceAppEvidList[i]);
					}		
				}
			},
			
			//일비 추가
			addDailyExpence : function(Rownum, InputItem) {
				var me = this;
				var DailyForm = me.DailyInputForm;
				var isAdd = (Rownum == undefined ? true : false);
				
				if(isAdd) {
					if(me.DailyExpenceAppEvidList.length > 0)
						Rownum = me.DailyExpenceAppEvidList[me.DailyExpenceAppEvidList.length-1].Rownum + 1;
					else
						Rownum = 0;
				}
				
				var valMap = {
					ProofCode : me.ProofCode,
					KeyNo : me.KeyNo,
					Rownum : Rownum
				};
				if(InputItem != undefined) {
					valMap.BizTripDateSt = nullToBlank(InputItem.BizTripDateSt);
					valMap.BizTripDateEd = nullToBlank(InputItem.BizTripDateEd);
					valMap.DailyType = nullToBlank(InputItem.DailyType);
					valMap.DailyTypeNM = nullToBlank(InputItem.DailyTypeNM);
					valMap.DailyAmount = toAmtFormat(nullToBlank(InputItem.DailyAmount));
				}
				
				if(isAdd) {
					me.DailyExpenceAppEvidList.push(valMap);
				}
				
				DailyForm = accComm.accHtmlFormSetVal(DailyForm, valMap);
				DailyForm = accComm.accHtmlFormDicTrans(DailyForm);
				
				$("#dailyExpenceList_trSum").before(DailyForm);
				
				me.makeDateField(valMap.ProofCode, valMap.KeyNo, Rownum);
				var areaId = $("[name=BizTripDateArea][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").attr("id");
				$("#"+areaId+"_St").val(valMap.BizTripDateSt);
				$("#"+areaId+"_Ed").val(valMap.BizTripDateEd);
				
				me.setSelectCombo(valMap.ProofCode, valMap.KeyNo, Rownum);
				$("[name=DailyTypeSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").val((valMap.DailyType == undefined ? "" : valMap.DailyType));
				
				me.setDailyAmount(false, Rownum);
			},
			
			//콤보 설정
			setSelectCombo : function(ProofCode, KeyNo, Rownum){
				var me = this;
				
				if(me.DailyExpenceTypeHtml != '') {
					$("[name=DailyTypeSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(me.DailyExpenceTypeHtml);
				} else {
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeDataAll.do",
						data:{
							codeGroups : "DailyExpenceType,DailyExpenceTypeOversea,DailyExpenceTypeNormal",
							CompanyCode : CompanyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var dailyTypeList = "";
								if ("<%=requestType%>" == "BIZTRIP") { 				//국내출장
									dailyTypeList = data.list.DailyExpenceType;
								} else if ("<%=requestType%>" == "OVERSEA") {	 	//해외출장
									dailyTypeList = data.list.DailyExpenceTypeOversea;
								} else {
									dailyTypeList = data.list.DailyExpenceTypeNormal;
								}
								
								var optionHtml = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
								for(var i = 0; i < dailyTypeList.length; i++) {
									optionHtml += "<option value='"+dailyTypeList[i].Code+"' amount='"+dailyTypeList[i].ReservedInt+"'>"+dailyTypeList[i].CodeName+"</option>";
								}
								
								me.DailyExpenceTypeHtml = optionHtml;
								
								$("[name=DailyTypeSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(optionHtml);
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
			},
			
			makeDateField : function(ProofCode, KeyNo, Rownum) {
				var dateArea = $("[name=BizTripDateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var areaID = $(dateArea).attr("id");
					
				makeDatepicker(areaID, areaID+"_St", areaID+"_Ed", null, null, 100);
			},
			
			deleteDailyExpence : function() {
				var me = this;
				var fieldList = $("input[type=checkbox][name=RowCk]:checked");
				 
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
				for(var i=0;i<fieldList.length; i++){
			   		var checkedItem = fieldList[i];
					var Rownum = checkedItem.getAttribute("rownum");
					$("tr[name=DailyRowTR][rownum="+Rownum+"]").remove();
					
					var index = -1;
					$(me.DailyExpenceAppEvidList).each(function(i, obj) {
					    if($(obj).Rownum == Rownum) {
					        index = i;
					    }
					});
					me.DailyExpenceAppEvidList.splice(index, 1);
			   	}
			},
			
			//일비 증빙 list에 값을 세팅
			setListVal : function(obj, Field, Rownum) {
				var me = this;
				var val = obj.value;
				var getItem = fn_findListItem(me.DailyExpenceAppEvidList, "Rownum", Rownum);
				
				if(Field != "BizTripDate") {
					getItem[Field] = val;
				}
				
				if(Field == "DailyType" || Field == "BizTripDate") {
					me.setDailyAmount(true, Rownum, getItem);
					if(Field == "DailyType") {
						var dailyTypeNm = $(obj).find("option:selected").text();
						getItem["DailyTypeNM"] = dailyTypeNm;
					}
				}
			},
			
			setDailyAmount : function(isNew, Rownum, getItem) {
				var me = this;
				var stDt = $("[name=BizTripDateArea][rownum="+Rownum+"]").find("input[id$=_St]").val()
				var edDt = $("[name=BizTripDateArea][rownum="+Rownum+"]").find("input[id$=_Ed]").val();
				
				var diff = Math.abs(new Date(stDt).getTime() - new Date(edDt).getTime());
				if(_ie || _edge) { 
					diff = Math.abs(new Date(stDt.replace(/\./gi, "-")).getTime() - new Date(edDt.replace(/\./gi, "-")).getTime());
				}
				diff = Math.ceil(diff / (1000 * 3600 * 24));
				diff = diff + 1; //1일 차이 = 2일 근무
				if(isNaN(diff)) {
					diff = 0;
				}
				
				var amount = Number($("[name=DailyTypeSelectField][rownum="+Rownum+"]").find("option:selected").attr("amount"));
				if(isNaN(amount)) {
					amount = 0;
				}
				
				$("[name=DailyAmountField][rownum="+Rownum+"]").val(toAmtFormat(diff * amount));
				
				if(isNew) {
					getItem["BizTripDateSt"] = stDt;
					getItem["BizTripDateEd"] = edDt;
					getItem.DailyAmount = diff * amount;
					getItem.WorkingDays = diff;
				}
				
				me.setDailyAmountTotal();				
			},
			
			setDailyAmountTotal : function() {				
				var sum = 0;
				for(var i = 0; i < $("[name=DailyAmountField]").length; i++) {
					sum += Number($("[name=DailyAmountField]").eq(i).val().replace(/,/gi, ''));
				}
				$("#dailyAmountTotalSum").html(toAmtFormat(sum));
			},
			
			CheckValidation : function(){						
				var me = this;
				for(var i=0; i<me.DailyExpenceAppEvidList.length; i++)
				{
					var item = me.DailyExpenceAppEvidList[i];
					if(isEmptyStr(item.BizTripDateSt) || isEmptyStr(item.BizTripDateEd)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_BizTripDate' />"; //출장일자를 입력하세요.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.DailyType)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_DailyType' />"; //일비유형을 선택하세요.
						Common.Inform(msg);
						return;
					}
				}
				me.applyDailyInfo();
			},
			
			applyDailyInfo : function(){
				var me = this;
				var returnObj = [];
				var DailyExpenceAppEvidList = me.DailyExpenceAppEvidList;
				if(DailyExpenceAppEvidList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noApplyData' />");		//반영할 데이터가 없습니다.
					return;
				}
				returnObj['DailyExpenceAppEvidList'] = DailyExpenceAppEvidList;
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
	window.ExpenceApplicationDailyPopup = ExpenceApplicationDailyPopup; 
})(window);

ExpenceApplicationDailyPopup.popupInit();
	
</script>