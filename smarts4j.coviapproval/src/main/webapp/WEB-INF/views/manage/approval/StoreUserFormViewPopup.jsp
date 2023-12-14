<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>
var mode = "${param.mode}";
var paramStoredFormRevID = "${param.id}"; 

$(document).ready(function(){
	selectPurchaseFormData();
	getFormData();
});

function selectPurchaseFormData(){
	$.ajax("/approval/user/getPurchaseFormData.do", {method : "POST", async : true})
	.done(function(list){
		$("#ApvFormsFreeCount").text(list.data.ApvFormsFreeCount);
		$("#IsCouponY").text(list.data.CouponUseCnt);
		$("#IsCouponN").text(list.data.CouponRemainCnt);
	})
	.fail(function(e){  
		//console.log(e);
	});
}

// 레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}

function makeNode(sName, vVal) {
    var jsonObj = {};
    
    if(vVal == null || vVal == undefined){
    	vVal = "";
    }
    jsonObj[sName] = vVal;

    return jsonObj;
}

function getFormData(){
	//data 조회
	$.ajax({
		type:"POST",
		data:{
			"StoredFormRevID" : paramStoredFormRevID				
		},
		url:"/approval/user/getStoreUserFormData.do",
		success:function (data) {					
			if(Object.keys(data.info).length > 0){			
				var getPurchaseYN = data.info.PurchaseYN;
				var getIsFree = data.info.IsFree;
				if(getPurchaseYN == "Y") $("#btnPurchaseForm").css("display","none");

				$("#formName").html(CFN_GetDicInfo(data.info.FormName));
				$("#PurchasedCnt").html(toAmtFormat(data.info.PurchasedCnt));
				$("#purchaseYN").html(getPurchaseYN == "N" ? '<spring:message code="Cache.lbl_PurchaseN"/>' : '<spring:message code="Cache.lbl_PurchaseY"/>');
				$("#purchaseDate").html(getStringDateToString("yyyy.MM.dd",data.info.PurchaseDate));
				$("#isFree").html(getIsFree=="Y" ? '<spring:message code="Cache.lbl_price_free"/>' : '<spring:message code="Cache.lbl_price_charged"/>');
				$("#isFree").attr("getIsFree", getIsFree);
				$("#formPrice").html(toAmtFormat(data.info.Price));
				$("#mobileFormYN").html(data.info.MobileFormYN == "Y" ? '<spring:message code="Cache.lbl_Include"/>' : '<spring:message code="Cache.lbl_Exclude"/>');
				$("#mobileFormYN").attr("getMobileFormYN", data.info.MobileFormYN);
				$("#formDesc").html(data.info.FormDescription.replace(/\n/gi, "<br \/>"));

				setImageInfo(data.info);
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getStoreUserFormData.do", response, status, error);
		}
	});
}

function setImageInfo(data){
	$("#imgPreThumb").prop("src", coviCmn.loadImageId(data.ThumbnailFileID)).css("max-height", "200px");;
	
}

function toAmtFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			retVal = val.toString();
			if(!isNaN(retVal.replaceAll(",", ""))){
				var splitVal = retVal.split(".");
				if(splitVal.length==2){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
					retVal = retVal +"."+ splitVal[1];
				}
				else if(splitVal.length==1){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
				}else{
					retVal = "";
				}
			}
		}
	}
	return retVal
}

function goPurchaseForm(){
	if($("#isFree").attr("getIsFree")=="N" && $("#CouponRemainCnt").text() == "0"){
		Common.Warning("<spring:message code='Cache.msg_NoCoupon' />")//"잔여쿠폰이 없습니다. 관리자에게 문의하세요."
	}else{
		Common.open("","StoreFormBuyPopup","<spring:message code='Cache.lbl_purchaseFormAS'/>","/approval/user/goStoreFormBuyPopup.do?id="+paramStoredFormRevID+"&isFree=" + $("#isFree").attr("getIsFree") +"&MobileFormYN="+$("#mobileFormYN").attr("getMobileFormYN"),"420px","230px","iframe",true,null,null,true);
	}
}

function previewForm(){
	CFN_OpenWindow("/approval/approval_CstfForm.do?cstfRevID=" + paramStoredFormRevID, "", 790, (window.screen.height - 100), "resize", "false");
}
</script>
<div class="divpop_contents">
	<div class="sadmin_pop">
		<h3 class="cycleTitle"><spring:message code="Cache.lbl_paidForm"/> : 
			<spring:message code="Cache.btn_All"/><span class="s_num s_num01" id="ApvFormsFreeCount"></span> <!-- 전체 -->
			<spring:message code="Cache.lbl_IsCouponY"/><span class="s_num s_num02" id="IsCouponY"></span> <!-- 사용 -->
			<spring:message code="Cache.lbl_IsCouponN"/><span class="s_num s_num03" id="IsCouponN"></span> <!-- 잔여 -->
		</h3>
		<table class="sadmin_table sa_menuBasicSetting">
			<colgroup>
				<col width="110px;">
				<col width="*">
				<col width="110px;">
				<col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th><spring:message code='Cache.lbl_apv_formcreate_LCODE03'/></th><!-- 양식명 -->
					<td><span id="formName"></span></td>
					<th><spring:message code="Cache.lbl_purchasedCnt"/></th>
					<td><span id="PurchasedCnt"></span></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_PurchaseY"/></th>
					<td><span id="purchaseYN"></span></td>
					<th><spring:message code="Cache.lbl_PurchaseDate"/></th>
					<td><span id="purchaseDate"></span></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_gubun'/></th>
					<td><span id="isFree"></span></td>
					<th><spring:message code='Cache.lbl_amount'/></th>
					<td><span id="formPrice"></span></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_isMobileForm'/></th>  <!--모바일양식-->
					<td colspan="3">
						<span id="mobileFormYN">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_formDesc"/></th>
					<td colspan="3"><span id="formDesc"></span></td>
				</tr>
				<tr>
		            <th><spring:message code="Cache.msg_RepresentativeImg"/></th>
		            <td>
		            	<div class="form_img">
		            		<img id="imgPreThumb" onerror="coviCmn.imgError(this)" />
		            	</div>                   
		            </td>
		        </tr>                    
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a href="javascript:previewForm();" class="btnTypeDefault btnBlueBoder"><spring:message code="Cache.lbl_preview"/></a> <!-- 미리보기 -->
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnPurchaseForm" onClick="goPurchaseForm();"><spring:message code="Cache.lbl_PurchaseY"/></a> <!-- 구매 -->  
			<a href="javascript:closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_att_close"/></a>
		</div>
	</div>
</div>