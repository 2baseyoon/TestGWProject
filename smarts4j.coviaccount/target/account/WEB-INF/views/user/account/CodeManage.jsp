<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.pad10 { padding:10px;}
</style>
<!-- 상단 끝 -->
<div class="cRConTop titType">
	<h2 id="headerTitle" class="title"></h2>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="eaccountingCont">
		<div id="topitembar02" class="bodysearch_Type01">
			<div class="inPerView type07">
				<div style="width:800px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 회사코드 -->
							<spring:message code='Cache.ACC_lbl_companyCode'/>
						</span>
						<span id="companyCode" class="selectType02" style="width:200px;" onchange="CodeManage.companyCodeChange()">
						</span>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 증빙 -->
							<spring:message code='Cache.ACC_lbl_proofCode'/>
						</span>
						<span id="proofCode" class="selectType02" style="width:200px;" onchange="CodeManage.proofCodeChange()">
						</span>
					</div>
				</div>
			</div>
		</div>
		
		<div class="codemapping_wrap">
			<div class="codemapping_conin">
				<div class="codemapping_left">
					<div class="codemapping_tit">	<!-- 과세유형 -->
						<h3><spring:message code='Cache.ACC_lbl_taxCode'/></h3>
					</div>
					<div class="codemapping_list_wrap typecode">
						<table cellpadding="0" cellspacing="0" border="0" class="codemapping_list">
							<tbody id="codemappingLeftList">
							</tbody>
						</table>
					</div>
				</div>
				<div class="codemapping_middle">
					<input name="cbBTN" class="btn_send sizetype01" 	onclick="CodeManage.addCode('Y')" type="button" value=<spring:message code='Cache.ACC_btn_addDeduction_1'/>> <!-- 추가(공제) -->
					<input name="cbBTN" class="btn_send sizetype01" 	onclick="CodeManage.addCode('N')" type="button" value=<spring:message code='Cache.ACC_btn_addDeduction_2'/>> <!-- 추가(불공제) -->
				</div>
				<div class="codemapping_right">
					<div class="codemapping_tit">	<!-- 매핑 -->
						<h3><spring:message code='Cache.ACC_lbl_mapping'/></h3>
						<div class="codemapping_tit_btn">
							<a class="btnTypeDefault btnTypeChk"	onclick="CodeManage.saveInfo()"><spring:message code='Cache.ACC_btn_save'/></a>
							<a class="btnTypeDefault"				onclick="CodeManage.delCode('S','Right')"><spring:message code='Cache.ACC_btn_delete'/></a>
							<a class="btnTypeDefault btnRepeatGray"	onclick="CodeManage.delCode('A','Right')"><spring:message code='Cache.ACC_btn_reset'/></a>  <!-- 초기화 -->
						</div>
					</div>
					<div class="codemapping_list_wrap typecode">
						<table cellpadding="0" cellspacing="0" border="0" class="codemapping_list">
							<tbody id="codemappingRightList">
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
<script>

	if (!window.CodeManage) {
		window.CodeManage = {};
	}
	
	(function(window) {
		var CodeManage = {
				params	:{
					_searchCode		: true,
					_searchCodeGrp	: true,
					_delArr			: [],
					_rightKeyArr	: []
				},
				
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.codeSearchGroup();
				},

				pageView : function() {
					var me = this;
					me.refreshSelectCombo();
					me.codeSearchGroup();
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("proofCode").children().remove();
					accountCtrl.getInfo("proofCode").addClass("selectType02").css("width", "200px").attr("onchange", "CodeManage.proofCodeChange()");
					
					accountCtrl.renderAXSelect('ProofCode',		'proofCode',	'ko','','','',"<spring:message code='Cache.ACC_lbl_comboSelect' />",null,pCompanyCode); //
					
					if(pCompanyCode == undefined) {
						accountCtrl.renderAXSelect('CompanyCode',	'companyCode',	'ko','','','',null,pCompanyCode);
					}
				},
				
				refreshSelectCombo : function(){
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("proofCode");
				},

				companyCodeChange : function(){
					var me = this;
					var companyCode = accountCtrl.getComboInfo('companyCode').val();
					if(companyCode == null || companyCode == ''){
						me.delCode('A','Left');
					}else{
						me.setSelectCombo(companyCode);
						me.codeSearchGroup();
					}
				},
				
				proofCodeChange : function(){
					var me = this;
					me.codeSearchGroup();
					var proofCode = accountCtrl.getComboInfo('proofCode').val();
					if(proofCode == null || proofCode == ''){
						me.delCode('A','Right');
					}else{
						me.codeSearch();
					}
				},
				
				codeSearch : function(){
					var me = this;
					
					var companyCode = accountCtrl.getComboInfo("companyCode").val();
					
					var proofCode = accountCtrl.getComboInfo('proofCode').val();
					if(proofCode == null || proofCode == ''){
						return;
					}
					
					me.delCode('A','Right');
					
					if(me.params._searchCode){
						me.params._searchCode = false;
						$.ajax({
							url	:"/account/codemanage/getCodeSearchList.do",
							type: "POST",
							data: {
								"proofCode" : proofCode,
								"companyCode" : companyCode
							},
							success:function (data) {
								if(data.status == "SUCCESS"){
									for(var i=0; i<data.list.length; i++){
										var LR		= 'Right';
										var info	= data.list[i];
										var len		= i+1;
										CodeManage.addRow(len,info,LR);
										
										var nowViewName			= "viewName"		+ LR+len;
										var nowDeductionType	= "deductionType"	+ LR+len;
										var nowCodeGroup		= "codeGroup"		+ LR+len;
										var nowCode				= "code"			+ LR+len;
										var nowCodeName			= "codeName"		+ LR+len;
										var nowProofTaxMappID	= "proofTaxMappID"	+ LR+len;
										
										accountCtrl.getInfo(nowViewName).val(info.ViewName);
										accountCtrl.getInfo(nowDeductionType).val(info.DeductionType);
										accountCtrl.getInfo(nowCodeGroup).val(info.CodeGroup);
										accountCtrl.getInfo(nowCode).val(info.Code);
										accountCtrl.getInfo(nowCodeName).val(info.CodeName);
										accountCtrl.getInfo(nowProofTaxMappID).val(info.ProofTaxMappID);
										CodeManage.params._rightKeyArr.push({"key":len});
										CodeManage.params._delArr = [];
									}
									me.params._searchCode = true;
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}
				},
				
				codeSearchGroup : function(){
					var me = this;
					me.delCode('A','Left');
					
					var companyCode = accountCtrl.getComboInfo("companyCode").val();
					
					if(me.params._searchCodeGrp){
						me.params._searchCodeGrp = false;
						$.ajax({
							url	:"/account/codemanage/getCodeSearchGroupList.do",
							data:{
								"companyCode" : companyCode
							},
							type: "POST",
							success:function (data) {
								if(data.status == "SUCCESS"){
									for(var i=0; i<data.list.length; i++){
										var LR		= 'Left';
										var info	= data.list[i];
										var len		= i+1;
										CodeManage.addRow(len,info,LR);
										
										var nowViewName			= "viewName"		+ LR+len;
										var nowDeductionType	= "deductionType"	+ LR+len;
										var nowCodeGroup		= "codeGroup"		+ LR+len;
										var nowCode				= "code"			+ LR+len;
										var nowCodeName			= "codeName"		+ LR+len;
										
										accountCtrl.getInfo(nowViewName).val(info.ViewName);
										accountCtrl.getInfo(nowDeductionType).val(info.DeductionType);
										accountCtrl.getInfo(nowCodeGroup).val(info.CodeGroup);
										accountCtrl.getInfo(nowCode).val(info.Code);
										accountCtrl.getInfo(nowCodeName).val(info.CodeName);
									}
									CodeManage.params._searchCodeGrp = true;
									CodeManage.params._delArr = [];
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}
				},
				
				addRow : function(len,info,LR){
					var appendTableID	= "codemapping"+LR+"List";
					var appendStr	=  "<tr>"
									+		"<td class='codemapping_td01'>"
									+			"<div class='chkStyle04 chkType01'>"
									+				"<input type='checkbox' id='chk"+LR+len+"'>"
									+				"<label for='chk"+LR+len+"'>"
									+					"<span></span>"
									+				"</label>"
									+			"</div>"
									+		"</td>"
									+		"<td class='codemapping_td02'>"
									+			"<div class='codemapping_list_con' id='viewName"+LR+len+"'>"
									+				info.ViewName
									+			"</div>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='viewName"+LR+len+"' readOnly>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='deductionType"+LR+len+"' readOnly>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='codeGroup"+LR+len+"' readOnly>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='code"+LR+len+"' readOnly>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='codeName"+LR+len+"' readOnly>"
									+		"</td>"
									+		"<td hidden>"
									+			"<input id='proofTaxMappID"+LR+len+"' readOnly>"
									+		"</td>"
									+	"</tr>"
									
					accountCtrl.getInfo(appendTableID).append(appendStr);
				},
				
				saveInfo : function(){
					var me = this;
					var params	= new Object();
					var infoArr	= [];
					
					var rightTabelList	= accountCtrl.getInfo("codemappingRightList").children('tr');
					var rightLen		= rightTabelList.length;
					var proofCode		= accountCtrl.getComboInfo('proofCode').val();
					var companyCode		= accountCtrl.getComboInfo('companyCode').val();
					
					if(proofCode == null || proofCode == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_selectProofCode' />");	//증빙을 선택하세요.
						return;
					}
					
					for(var i=0; i<me.params._rightKeyArr.length; i++){
						var rKey	= me.params._rightKeyArr[i].key;
						var LR		= 'Right';
						
						var nowCode				= "code"			+ LR+rKey;
						var nowCodeGroup		= "codeGroup"		+ LR+rKey;
						var nowDeductionType	= "deductionType"	+ LR+rKey;
						var nowProofTaxMappID	= "proofTaxMappID"	+ LR+rKey;
						
						var code			= accountCtrl.getInfo(nowCode).val();
						var codeGroup		= accountCtrl.getInfo(nowCodeGroup).val();
						var deductionType	= accountCtrl.getInfo(nowDeductionType).val();
						var proofTaxMappID	= accountCtrl.getInfo(nowProofTaxMappID).val();
							
						var obj = {	"code"				: code
								,	"codeGroup"			: codeGroup
								,	"deductionType"		: deductionType
								,	"proofTaxMappID"	: proofTaxMappID};
						infoArr.push(obj)
					}
					
					params.proofCode	= proofCode;
					params.infoArr		= infoArr;
					params.delArr		= me.params._delArr;
					params.companyCode	= companyCode;
					
					$.ajax({
						url			: "/account/codemanage/saveCodeManageInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								CodeManage.codeSearch();
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");	// 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	// 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				addCode : function(deductionType){
					var me = this;
					
					var proofCode		= accountCtrl.getComboInfo('proofCode').val();
					var addArr			=[];
					var leftTabelList	= accountCtrl.getInfo("codemappingLeftList").children('tr');
					var leftLen			= leftTabelList.length;
					var noChkCnt		= 0;
					
					if(proofCode == null || proofCode == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_selectProofCode' />");
						return;
					}
					
					for(var i=0; i<leftLen; i++){
						var len				= i+1;
						var nowChkLeft 		= "chkLeft" + (len);
						var nowChkLeftVal	= accountCtrl.getInfo(nowChkLeft).prop("checked") ? "Y" : "N";
						
						if(nowChkLeftVal == 'Y'){
							var nowViewNameLeft 		= "viewNameLeft"		+ (len);
							var nowDeductionTypeLeft	= "deductionTypeLeft"	+ (len);
							var nowCodeGroupLeft		= "codeGroupLeft"		+ (len);
							var nowCodeLeft				= "codeLeft"			+ (len);
							var nowCodeNameLeft			= "codeNameLeft"		+ (len);
							
							var nowViewNameLeftVal		= accountCtrl.getInfo(nowViewNameLeft).val();
							var nowCodeGroupLeftVal		= accountCtrl.getInfo(nowCodeGroupLeft).val();
							var nowCodeLeftVal			= accountCtrl.getInfo(nowCodeLeft).val();
							var nowCodeNameLeftVal		= accountCtrl.getInfo(nowCodeNameLeft).val();
							
							if(deductionType == 'Y'){
								addStr	= "<spring:message code='Cache.ACC_lbl_deduction_1' />";	//공제
							}else{
								addStr	= "<spring:message code='Cache.ACC_lbl_deduction_2' />";	//불공제
							}
							obj = {	"CodeGroup"		: nowCodeGroupLeftVal
								,	"Code"			: nowCodeLeftVal
								,	"CodeName"		: nowCodeNameLeftVal
								,	"ViewName"		: addStr+nowViewNameLeftVal
								,	"DeductionType"	: deductionType};
							
							if(me.params._rightKeyArr.length == 0){
								var LR		= 'Right';
								var addLen	= me.params._rightKeyArr.length+1;
								me.addRow(addLen,obj,LR);
								
								var nowViewName			= "viewName"		+ LR+addLen;
								var nowDeductionType	= "deductionType"	+ LR+addLen;
								var nowCodeGroup		= "codeGroup"		+ LR+addLen;
								var nowCode				= "code"			+ LR+addLen;
								var nowCodeName			= "codeName"		+ LR+addLen;
								
								accountCtrl.getInfo(nowViewName).val(obj.ViewName);
								accountCtrl.getInfo(nowDeductionType).val(obj.DeductionType);
								accountCtrl.getInfo(nowCodeGroup).val(obj.CodeGroup);
								accountCtrl.getInfo(nowCode).val(obj.Code);
								accountCtrl.getInfo(nowCodeName).val(obj.CodeName);
								me.params._rightKeyArr.push({"key":addLen})
							}else{
								var cnt = 0;
								for(var r=0; r<me.params._rightKeyArr.length; r++){
									var rKey				= me.params._rightKeyArr[r].key;
									var chkCode				= "codeRight"			+ (rKey);
									var chkDeductionType	= "deductionTypeRight"	+ (rKey);
									var chkCodeVal			= accountCtrl.getInfo(chkCode).val();
									var chkDeductionTypeVal	= accountCtrl.getInfo(chkDeductionType).val();
									
									if(	nowCodeLeftVal	== chkCodeVal){
										if(deductionType	== chkDeductionTypeVal){
											cnt += 1
										}
									}
								}
								if(cnt == 0){
									var rSortArr	= me.params._rightKeyArr.sort(function(a,b){ return b.key - a.key});
									var maxKey		= rSortArr[0].key;
									var LR			= 'Right';
									var addLen		= maxKey+1;
									
									me.addRow(addLen,obj,LR);
									
									var nowViewName			= "viewName"		+ LR+addLen;
									var nowDeductionType	= "deductionType"	+ LR+addLen;
									var nowCodeGroup		= "codeGroup"		+ LR+addLen;
									var nowCode				= "code"			+ LR+addLen;
									var nowCodeName			= "codeName"		+ LR+addLen;
									
									accountCtrl.getInfo(nowViewName).val(obj.ViewName);
									accountCtrl.getInfo(nowDeductionType).val(obj.DeductionType);
									accountCtrl.getInfo(nowCodeGroup).val(obj.CodeGroup);
									accountCtrl.getInfo(nowCode).val(obj.Code);
									accountCtrl.getInfo(nowCodeName).val(obj.CodeName);
									
									me.params._rightKeyArr.push({"key":addLen})
								}
							}
							accountCtrl.getInfo(nowChkLeft).attr("checked", false);
						}else{
							noChkCnt += 1;
						}
					}
					
					if(leftLen == noChkCnt){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 내역이 없습니다.
					}
				},
					
				delCode : function(type,LR){
					/*	TYPE - A = ALL
						TYPE - S = SELECT*/
					var me = this;
					var tableId		= "codemapping"+LR+"List"
					var tabelList	= accountCtrl.getInfo(tableId).children('tr');
					var rightLen	= tabelList.length;
					var removeArr	= [];
					if(type == 'A'){
						if(LR=='Right'){
							for(var k=0; k<me.params._rightKeyArr.length; k++){
								var rKey = me.params._rightKeyArr[k].key;
								
								var proofTaxMappID 		= "proofTaxMappID" + LR + (rKey);
								var proofTaxMappIDVal	= accountCtrl.getInfo(proofTaxMappID).val();
								
								if(proofTaxMappIDVal != null && proofTaxMappIDVal != ''){
									me.params._delArr.push({"proofTaxMappID":proofTaxMappIDVal})
								}
							}
						}
						tabelList.remove();
						me.params._rightKeyArr = [];
					}else{
						var sortArr = me.params._rightKeyArr.sort(function(a,b){return a.key - b.key});
						for(var k=sortArr.length-1; k>=0; k--){
							var rKey			= sortArr[k].key;
							
							var nowChkRight 	= "chk"		 	+ LR + (rKey);
							var proofTaxMappID 	= "proofTaxMappID"	+ LR + (rKey);
							
							var nowChkRightVal		= accountCtrl.getInfo(nowChkRight).prop("checked") ? "Y" : "N";
							var proofTaxMappIDVal	= accountCtrl.getInfo(proofTaxMappID).val();
							
							if(nowChkRightVal == 'Y'){
								tabelList.eq(k).remove();
								removeArr.push(rKey);
								if(proofTaxMappIDVal != null && proofTaxMappIDVal != ''){
									me.params._delArr.push({"proofTaxMappID":proofTaxMappIDVal})
								}
							}
						}
						if(removeArr.length > 0){
							for(var ra=0; ra<removeArr.length; ra++){
								for(var rka=0; rka<me.params._rightKeyArr.length; rka++){
									if(removeArr[ra] == me.params._rightKeyArr[rka].key){
										me.params._rightKeyArr.splice(rka,1);
									}
								}
							}
						}
					}
				}
				
		}
		window.CodeManage = CodeManage;
	})(window);
</script>