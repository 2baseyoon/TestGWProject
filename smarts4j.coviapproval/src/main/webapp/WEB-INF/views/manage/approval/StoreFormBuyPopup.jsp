<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>
var paramStoredFormRevID = "${param.id}";
var paramIsFreeForm = "${param.isFree}";// 쿠폰선택 화면 처리용. 서버에서 변조방지 체크를 한번더 한다.
var paramMobileFormYN = "${param.MobileFormYN}";
$(document).ready(function(){
	getStoreFormClassList();
	
	if("N" == paramIsFreeForm) {
		$("#CouponSelectTR").show();
	}
});

function getStoreFormClassList(){
	$.ajax({
		url:"getStoreFormClassList.do",
		type:"post",
		async:false,
		success:function (data) {
			$("#selclass").append("<option value=''>"+Common.getDic('lbl_apv_selection')+"</option>");
			for(var i=0; i<data.classlist.length;i++){
				$("#selclass").append("<option value='"+data.classlist[i].optionValue+"'>"+data.classlist[i].optionText+"</option>");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getStoreFormClassList.do", response, status, error);
		}
	});
}

/**
 * 사용할 쿠폰선택
 */
function selectCouponPop() {
	var pModal = true;
	var pCouponType = "APPFORM";
	var width = "500px";
	var height = "660px";
	
	var win = parent.parent;
	win.CallBack_window = this;
	win.Common.open("", "CouponSelectPopup","<spring:message code='Cache.lbl_CouponEventView'/>","/groupware/store/goCouponSelectListPopup.do?CouponType=" + pCouponType, width, height,"iframe",pModal,null,null,true);
}

function callbackCouponSelect(data) {
	$("#CouponName").val(data.CouponName);
	$("#CouponID").val(data.CouponID);
	
	var win = parent.parent;
	win.CallBack_window = null;
}

function goFormSave(){
	if ($("#selclass").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_516' />"); return false; }  //  "양식분류를 선택해주세요"
	if ($("#selschema").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_517' />"); return false; }  //  "양식프로세스를 선택해주세요"
	// 유료양식일 경우만 체크
	if("N" == paramIsFreeForm) {
		if ($("#CouponID").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_selectCoupon' />"); return false; }  //  "사용할 쿠폰을 선택해주세요"
	}
	
	Common.Confirm("<spring:message code='Cache.msg_ConfirmStoreFormPurchase'/>", "Confirmation Dialog", function(result) { // 구매하시겠습니까?
		if(result) {
			$.ajax({
				type:"POST",
				data:{
					"StoredFormRevID" : paramStoredFormRevID,
					"StoredFormClass" : $("#selclass").val(),
					"StoredFormSchema" : $("#selschema").val(),
					"CouponID" : $("#CouponID").val(),
					"MobileFormYN": paramMobileFormYN
				},
				url:"/approval/user/storePurchaseForm.do",
				success:function (data) {
					if(data.buyFormYN == "true") {
						Common.Inform(data.returnMsg,"Inform",function() {
							parent.Common.Close();
							parent.parent.initStoreFormList();
						});
					}else{
						Common.Warning(data.returnMsg);
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/user/storePurchaseForm.do", response, status, error);
				}
			});
		}
	});
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}
</script>
<div class="divpop_contents">
	<div class="sadmin_pop">
		<table class="sadmin_table sa_menuBasicSetting">
			<colgroup>
				<col width="110px;">
				<col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th><spring:message code='Cache.lbl_FormCate'/></th>  <!--양식분류-->
					<td>
						<select id="selclass" name="selclass" class="selectType02" style="width:80%"></select>
					</td>				          
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_formcreate_LCODE04'/></th>  <!--양식 프로세스-->
					<td>
						<select id="selschema" name="selschema" class="selectType02" style="width:80%">
						<option value=''><spring:message code='Cache.lbl_apv_selection'/></option>
						<option value='DRAFT'><spring:message code='Cache.lbl_DraftProcess'/></option>
						<option value='REQUEST'><spring:message code='Cache.lbl_RequestProcess'/></option>
						</select>
					</td>
				</tr>
				<tr id="CouponSelectTR" style="display:none;">
					<th><spring:message code='Cache.btn_CouponChoice'/></th>  <!-- 쿠폰선택 -->
					<td>
						<input type="hidden" id="CouponID" />
						<input type="text" id="CouponName" class="readonly w100p" readonly="true">
						<a class="btnType02" onclick="selectCouponPop()"><spring:message code='Cache.btn_CouponChoice'/></a>
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnPurchaseForm" onClick="goFormSave();"><spring:message code="Cache.btn_save"/></a> <!-- 저장 -->
			<a href="javascript:closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_att_close"/></a><!-- 닫기 -->
		</div>
	</div>
</div>