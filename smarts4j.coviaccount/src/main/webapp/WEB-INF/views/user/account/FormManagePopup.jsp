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
	<input id="mode"			type="hidden" />
	<input id="expenceFormID"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<ul class="tabDesign">
					<li class="tab tabOn"><a id="aDefaultArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;" onclick="FormManagePopup.clickTab(this);" value="Default"><spring:message code='Cache.ACC_lbl_baseInfo'/></a></li> <!-- 기본정보 -->
					<li class="tab"><a id="aAccountArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;"  onclick="FormManagePopup.clickTab(this);" value="Account"><spring:message code='Cache.ACC_lbl_accountInfo'/></a></li> <!-- 계정과목 정보 -->
					<li class="tab"><a id="aStandardBriefArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;" onclick="FormManagePopup.clickTab(this);" value="StandardBrief"><spring:message code='Cache.ACC_lbl_standardBriefInfo'/></a></li> <!-- 표준적요 정보 -->
					<li class="tab"><a id="aRuleArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;"  onclick="FormManagePopup.clickTab(this);" value="Rule"><spring:message code='Cache.ACC_lbl_ruleInfo'/></a></li> <!-- 전결규정 정보 -->
					<li class="tab"><a id="aProofArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;"  onclick="FormManagePopup.clickTab(this);" value="Proof"><spring:message code='Cache.ACC_lbl_proofInfo'/></a></li> <!-- 증빙유형 정보 -->
					<li class="tab"><a id="aAuditArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;"  onclick="FormManagePopup.clickTab(this);" value="Audit"><spring:message code='Cache.ACC_lbl_auditInfo'/></a></li> <!-- 감사규칙 정보 -->
					<!-- 세금코드 주석 처리 (임시적 사용 안 함) -->
					<%-- <li class="tab"><a id="aTaxArea" style="cursor: pointer; font-size: 15px; padding: 0 12px; margin-left: 0;"  onclick="FormManagePopup.clickTab(this);" value="Tax"><spring:message code='Cache.ACC_lbl_taxInfo'/></a></li> --%> <!-- 세금코드 정보 --> 
				</ul>
				<div class="tabCont selected">
					<div class="middle">
						<div id="DefaultArea">
							<table class="tableStyle">
								<colgroup>
									<col style = "width: 200px;">
									<col style = "width: auto;">
								</colgroup>
								<tbody>
									<tr>
										<th>	<!-- 회사코드 -->
											<spring:message code="Cache.ACC_lbl_companyCode"/>
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<span id="companyCode" class="selectType06" style="width: 100px;">
												</span>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_formCode'/>	<!-- 비용신청서 코드 -->
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<input id="formCode" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_formName'/>	<!-- 비용신청서명 -->
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<input id="formName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_sortOrder'/>	<!-- 정렬순서 -->
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<input id="sortKey" type="text" class="HtmlCheckXSS ScriptCheckXSS">
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_requestType'/>	<!-- 신청유형 -->
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<span id="expAppType" class="selectType06" style="width: 150px;">
												</span>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.lbl_menuType'/>	<!-- 메뉴유형 -->
											<span class="star"></span>
										</th>
										<td>
											<div class="box">
												<span id="menuType" class="selectType06" style="width: 150px;">
												</span>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.lbl_apv_ApprovalDoc'/>	<!-- 결재문서 -->
										</th>
										<td>
											<div class="box">
												<select id="approvalForm" name="SelectArea" style="width: 150px;">
												</select>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_chargeJob'/>	<!-- 담당업무 -->
										</th>
										<td>
											<div class="box">
												<select id="accountCharge" name="SelectArea" style="width: 150px;">
												</select>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<spring:message code='Cache.ACC_lbl_isUse'/>	<!-- 사용여부 -->
										</th>
										<td>
											<div class="box">
												<span id="isUse" class="selectType06" style="width: 70px;">
												</span>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											Icon <spring:message code='Cache.ACC_lbl_className'/>	<!-- Icon 클래스명 -->
										</th>
										<td>
											<div class="box">
												<input id="reservedStr1" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
											</div>
										</td>
									</tr>
									<tr style="display: none;">
										<th>
											<!-- 웹 에디터 사용여부 -->
											<spring:message code='Cache.CN_163'/> <spring:message code='Cache.ACC_lbl_isUse'/> 
										</th>
										<td>
											<span id="noteIsUse" class="selectType06" style="width: 80px;">
											</span>
										</td>
									</tr>
									<tr>
										<th>
											<!-- 환율 사용여부 -->
											<spring:message code='Cache.ACC_lbl_exchangeIsUse'/>
										</th>
										<td>
											<span id="reservedStr2" class="selectType06" style="width: 80px;">
											</span>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div id="AccountArea" style="display: none; margin-top: 10px;">
							<div id="AccountInfoDiv" style="overflow-y: auto; height: 500px;"></div>
						</div>
						<div id="StandardBriefArea" style="display: none; margin-top: 10px;">
							<table>
								<tbody>
									<tr>
										<td colspan="3" style="padding-bottom: 10px;">
											<input id="searchStr" type="text" placeholder="" onkeyup="FormManagePopup.onenter()" style="margin-right: 5px;">
											<a class="btnTypeDefault btnSearchBlue" onclick="FormManagePopup.searchList()">검색</a>
										</td>
									</tr>
								<tr>
									<td style="width: 46%; border : 1px solid #c9c9c9;">
										<span style="font-weight:bold; font-size: 14px; border-bottom: 1px solid #c9c9c9; line-height: 30px; padding-left: 10px;"><spring:message code="Cache.ACC_lbl_AllStandardBrief"/></span><!-- 전체 표준적요 목록 -->
										<div id="StandardBriefInfoDiv" style="overflow-y: scroll;height: 500px;"></div>
									</td>
									<td style="width: 8%;">
										<div style="width:50px; display:inline-block; height:430px; float:left;">
											<button type="button" style="margin:160px 0 5px 13px!important;" class="btnRight" onclick="FormManagePopup.setStandardBrief()">&lt;</button>
								      		<button type="button" style="margin:0 0 0 13px!important;" class="btnLeft" onclick="FormManagePopup.deleteStandardBrief()">&gt;</button>
										</div>
									</td>
									<td style="width: 46%; border : 1px solid #c9c9c9;;">
										<div style="width:100%; height:30px;background-color : #fafbfd;border-bottom : 1px solid #c9c9c9;line-height:30px;padding-left : 10px;">
											<span style="font-weight:bold; font-size: 14px;"><spring:message code="Cache.ACC_lbl_SelectedStandardBrief"/></span><!-- 선택 표준적요 목록 -->
										</div>
										<div id="checkResult" style="font-size: 14px; overflow-y: auto; height: 500px;"></div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div id="RuleArea" style="display: none; margin-top: 10px;">
							<select id="selectEntList" name="SelectArea" onchange="FormManagePopup.setInfoListDiv('Rule', this, 'selected')"></select>
							<div id="RuleInfoDiv" style="overflow-y: auto; height: 500px; margin-top: 10px;"></div>
						</div>
						<div id="ProofArea" style="display: none; margin-top: 10px;">
							<div id="ProofInfoDiv" style="overflow-y: auto; height: 500px;"></div>
						</div>
						<div id="AuditArea" style="display: none; margin-top: 10px;">
							<div id="AuditInfoDiv" style="overflow-y: auto; height: 500px;"></div>
						</div>
						<div id="TaxArea" style="display: none; margin-top: 10px;">
							<div id="TaxInfoDiv" style="overflow-y: auto; height: 500px;"></div>
						</div>
					</div>
					<div class="bottom">
						<a onclick="FormManagePopup.CheckValidation();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
						<a onclick="FormManagePopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>			<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.FormManagePopup) {
	window.FormManagePopup = {};
}

(function(window) {
	var FormManagePopup = {
			AccountInfoLists : [],
			StandardBriefInfoLists : [],
			RuleInfoLists : [], 
			ProofInfoLists : [],
			AuditInfoLists : [],
			TaxInfoLists : [],
			
			popupInit : function() {
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					$("#"+paramKey).val(paramValue);
				}
				
				me.setSelectCombo();
				me.setPopupEdit();
				me.getPopupInfo();
				
				$("#selectEntList").css("visibility", "unset"); //bindSelect 후 visibility가 hidden이 되는 현상 방지
				
				$("#companyCode").attr("onchange", "FormManagePopup.changeCompanyCode()");
			},
			
			clickTab : function(obj) {
				var me = this;
				
				$("ul.tabDesign").find("li.tabOn").removeClass("tabOn");
				$(obj).parent("li").addClass("tabOn");
				
				$(".tabCont .middle").children().hide();
				var TargetType = $(obj).attr("value");
				$("#"+TargetType+"Area").show();
				
				if(TargetType != "Default" && $("#"+TargetType+"InfoDiv").html().trim() == "") {
					if(TargetType == "Rule") {
						me.setInfoListDiv(TargetType, null, "load");
					} else {
						me.setInfoListDiv(TargetType);
					}
				}
			},
			
			//콤보 설정
			setSelectCombo : function(pCompanyCode){
				var me = this;

				$("#expAppType").children().remove();
				$("#menuType").children().remove();
				$("#isUse").children().remove();
				$("#approvalForm").children().remove();
				$("#accountCharge").children().remove();
				$("#noteIsUse").children().remove();
				$("#reservedStr2").children().remove();
				$("#selectEntList").children().remove();
				
				var AXSelectMultiArr = [	
					{'codeGroup':'ExpAppType',		'target':'expAppType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.lbl_Select' />"},	
					{'codeGroup':'MenuType',		'target':'menuType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.lbl_Select' />"},	
					{'codeGroup':'IsUse',			'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
					{
						'codeGroup':'IsUse',
						'target':'noteIsUse',
						'lang':'ko',
						'onchange':'',
						'oncomplete':'',
						'defaultVal':'N'
					},
					{
						'codeGroup':'IsUse',
						'target':'reservedStr2',
						'lang':'ko',
						'onchange':'',
						'oncomplete':'',
						'defaultVal':'N'
					},
					{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
				]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop();
				}
				
           		accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				
				for(var i = 0; i < $("select[name=SelectArea]").length; i++) {
					me.getSelectData($("select[name=SelectArea]").eq(i).attr("id"));
				}

				me.setItem();
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				// 
			},
			
			getSelectData : function(targetId){
				var me = this;
				
				var url = "/account/formManage/getInfoListData.do";
				var params = {};
				var str = "<option value=''><spring:message code='Cache.lbl_Select' /></option>";
				
				if(targetId == "selectEntList") {
					url = "/approval/common/getEntInfoListAssignData.do";
					str = "<option value=''><spring:message code='Cache.lbl_all' /></option>";
				} else {
					params.CompanyCode = accountCtrl.getComboInfo("companyCode").val();
					params.TargetArea = "SELECT";
					params.TargetType = targetId.charAt(0).toUpperCase() + targetId.slice(1);
				}
				
				$.ajax({
					type:"POST",
					data:params,
					url:url,
					async:false,
					success:function (data) {
						$("#"+targetId).append(str);
						$(data.list).each(function(index){					
							$("#"+targetId).append("<option value='"+this.optionValue+"'>"+this.optionText+"</option>");
						});
					},
					error:function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			},
			
			setInfoListDiv : function(TargetType, obj, reqType) { //계정과목, 표준적요, 전결규정, 증빙유형, 감사규칙, 세금코드 리스트 셋팅
				var me = this;
				var params = {};
				var url = "";
				var infoList = me[TargetType+"InfoLists"];
				var selEntCode = (obj != null) ? $(obj).val() : "";
				
				if(TargetType == "Rule") {
					if ($("#mode").val() == "modify" && reqType == "load" && infoList.length == 1) {
						$("#selectEntList").val(me.RuleInfoLists[0].DNCode);
					} else {
						$("#selectEntList").val(selEntCode);
					}
					
					var selectedEnt = $("#selectEntList").val();
					params.entCode = selectedEnt;
					params.itemType = "ACCOUNT";
					
					//전체 전결규정 조회 시 소속회사 목록
					if(selectedEnt == "") {
						var entArr = [];
						
						$.each($("#selectEntList > option"), function(index, item) {
							if(item.value == "") return true;
							entArr.push(item.value);
						})
						
						if(entArr.length > 1) params.entCodeList = entArr.join();
						else params.entCode = entArr[0];
					}
					
					url = "/approval/admin/getRuleForForm.do";
				} else {
					params.CompanyCode = accountCtrl.getComboInfo("companyCode").val();
					if(params.CompanyCode == "") {
						Common.Inform("[기본정보] 탭의 회사코드를 선택하세요.");
						me.clickTab($("#aDefaultArea"));
						return;
					}
					
					params.TargetArea = "DIV";
					if(TargetType == "Proof" || TargetType == "Tax") {
						params.TargetType = "BaseCode";
						params.CodeGroup = TargetType+"Code";
					} else {
						params.TargetType = TargetType;
					}
					
					url = "/account/formManage/getInfoListData.do";
				}
				
				$.ajax({
					type:"POST",
					data:params,
					url:url,
					async:false,
					success:function (data) {
						$("#"+TargetType+"InfoDiv").empty();
						
						// 목록 html 템플릿
						var tableTemplate = "<table style='font-size: 14px;'><tbody>{tbody}</tbody></table>";
						var tbodyContent = "";			// 전체 목록
						var sbSeletedTbodyContent = "";	// 선택 표준적요 목록
						
						var trTemplate = "";
						trTemplate += "<tr>";
						trTemplate += 	"<td style='padding: 4px; padding-left: 8px;'>{chkboxTd}</td>";
						trTemplate += 	"<td style='padding: 4px;'>{contentTd}</td>";
						trTemplate += "</tr>";
						
						var chkTemplate = "<input style='margin-right:2px;' type='checkbox' name='{name}' value='{itemCode}' dncode='{dnCode}' {check}>";
						var contentTemplate = "[{companyName}] {itemName}({itemCode}){description}";
						
						if(TargetType == "StandardBrief") {
							contentTemplate = contentTemplate.replace("{description}", "<br/><span style='color: gray'>{description}</span>");
						}
						
						// 전체선택
						var allSelectTd = trTemplate
							.replace("{chkboxTd}", "<input style='margin-right:2px;' type='checkbox' id='{id}' onchange='FormManagePopup.ToggleCheckBoxAll(this)' value=''>")
							.replace("{contentTd}", "<spring:message code='Cache.lbl_selectall'/>");
						
						tbodyContent += allSelectTd
							.replace("{id}", TargetType+"ItemAll");
						
						sbSeletedTbodyContent += allSelectTd
							.replace("{id}", "selected" + TargetType+"ItemAll");
						
						// 목록 항목 추가
						$(data.list).each(function(idx, obj) {
							var checked = false;
							
							if(infoList.length > 0) {
								var selectedItemArr = infoList[0].item
									.filter(item => item == obj.ItemCode);
								if(selectedItemArr.length > 0) {
									checked = true;
								}
							}
							
							var chkItem = chkTemplate
								.replace("{name}", TargetType+"Item")
								.replace("{itemCode}", obj.ItemCode)
								.replace("{dnCode}", (TargetType == "Rule") ? obj.EntCode : obj.CompanyCode)
								.replace("{check}", (checked) ? "checked" : "");
							
							var contentItem = contentTemplate
								.replace("{companyName}", obj.CompanyName)
								.replace("{itemName}", obj.ItemName)
								.replace("{itemCode}", obj.ItemCode)
								.replace("{description}", (obj.Description && obj.Description!="") ? " - "+obj.Description : "");
							
							if(TargetType == "Rule") {
								var moneyStr = "";
								if(obj.MaxAmount && obj.MaxAmount.split(".")[0] != "0") {
									moneyStr = " ~" + CFN_AddComma(obj.MaxAmount.split(".")[0]) + " " + Common.getDic("lbl_below");	
								}
								contentItem = obj.path + moneyStr;
							}
							
							// 전체 목록 html 쌓기
							tbodyContent += trTemplate
								.replace("{chkboxTd}", chkItem)
								.replace("{contentTd}", contentItem);
							
							// 선택 표준적요 목록 html 쌓기
							if(TargetType == "StandardBrief" && checked) {
								sbSeletedTbodyContent += trTemplate
									.replace("{chkboxTd}", chkItem)
									.replace("{contentTd}", contentItem);
							}
						});

						// 전체 목록 html 뿌리기
						$("#"+TargetType+"InfoDiv").append(tableTemplate.replace("{tbody}", tbodyContent));
						
						// 표준적요 목록 후처리
						if(TargetType == "StandardBrief") {
							// 선택 표준적요 목록 - html 뿌리기
							$("#checkResult").append(tableTemplate.replace("{tbody}", sbSeletedTbodyContent));
							
							// 선택된 표준적요 - name 변경
							$("#checkResult tr").find("input[name=StandardBriefItem]")
								.attr("name", "selectedStandardBriefItem");
							
							// 전체 표준적요 목록 - 선택된 체크박스 disabled
							$("#StandardBriefInfoDiv tr").find("input[name=StandardBriefItem]:checked")
								.attr("checked", false)
								.attr("disabled", true);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			},
			
			ToggleCheckBoxAll : function(obj) {
				var cbName = $(obj).attr("id").replace("All", "");
				$("input[type=checkbox][name="+cbName+"]").prop("checked", $(obj).is(":checked"));
				
				getCheckboxValue(event);
			},
			
			//팝업 수정
			setPopupEdit : function(){
				if ($("#mode").val() == 'modify') {
					$("#formCode").attr("disabled", true);
				}
			},
			
			//팝업 정보
			getPopupInfo : function(){
				var me = this;
				var mode			= $("#mode").val();
				var expenceFormID	= $("#expenceFormID").val();
				var formCode		= $("#formCode").val();
				
				if (mode == 'modify') {
					$.ajax({
						url	:"/account/formManage/getFormManageDetail.do",
						type: "POST",
						data: {
							"expenceFormID"	: expenceFormID, 
							"formCode"		: formCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var info = data.list[0];
								$("#expenceFormID").val(info.ExpenceFormID);
								$("#formCode").val(info.FormCode);
								$("#formName").val(info.FormName);
								$("#sortKey").val(info.SortKey);
								accountCtrl.getComboInfo("companyCode").bindSelectSetValue(info.CompanyCode);
								me.changeCompanyCode();
								accountCtrl.getComboInfo("expAppType").bindSelectSetValue(info.ExpAppType);
								accountCtrl.getComboInfo("menuType").bindSelectSetValue(info.MenuType);
								accountCtrl.getComboInfo("isUse").bindSelectSetValue(info.IsUse);
								accountCtrl.getComboInfo("noteIsUse").bindSelectSetValue(info.NoteIsUse);
								accountCtrl.getComboInfo("reservedStr2").bindSelectSetValue(info.ReservedStr2);
								$("#approvalForm").val(info.ApprovalFormInfo);
								$("#accountCharge").val(info.AccountChargeInfo);
								$("#reservedStr1").val(info.ReservedStr1);
								
								me.AccountInfoLists = info.AccountInfo;
								me.StandardBriefInfoLists = info.StandardBriefInfo;
								me.RuleInfoLists = info.RuleInfo;
								me.ProofInfoLists = info.ProofInfo;
								me.AuditInfoLists = info.AuditInfo;
								me.TaxInfoLists = info.TaxInfo;
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				
			},
			
			CheckValidation : function(){
				var me = this;
			    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				me.getInfoListForSave();
				
				//default
				var expenceFormID		= $("#expenceFormID").val();		//비용신청서 ID
				var companyCode			= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var formCode			= $("#formCode").val();				//비용신청서 코드
				var formName			= $("#formName").val();				//비용신청서명
				var sortKey				= $("#sortKey").val();				//정렬순서
				var expAppType			= accountCtrl.getComboInfo("expAppType").val();		//신청유형
				var menuType			= accountCtrl.getComboInfo("menuType").val();		//메뉴유형
				var isUse				= accountCtrl.getComboInfo("isUse").val();			//사용 여부
				var approvalFormInfo	= $("#approvalForm").val();		//결재문서
				var accountChargeInfo	= $("#accountCharge").val();	//담당업무
				var reservedStr1		= $("#reservedStr1").val();		//Icon 클래스명
				var noteIsUse 			= accountCtrl.getComboInfo("noteIsUse").val();
				var reservedStr2		= accountCtrl.getComboInfo("reservedStr2").val();	//환율 사용여부
				
				var accountInfo			= JSON.stringify(me.AccountInfoLists);
				var standardBriefInfo	= JSON.stringify(me.StandardBriefInfoLists);
				var ruleInfo			= JSON.stringify(me.RuleInfoLists);
				var proofInfo			= JSON.stringify(me.ProofInfoLists);
				var auditInfo			= JSON.stringify(me.AuditInfoLists);
				var taxInfo				= JSON.stringify(me.TaxInfoLists);
				
				if(chkInputCode(formCode) || chkInputCode(formName)){
					Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");	// <는 사용할수 없습니다.
					return;
				}
				
				if(isEmptyStr(companyCode)){
					Common.Inform("회사코드를 선택하세요.")	//회사코드를 선택하세요.
					return;
				}
				
				if(isEmptyStr(formCode)){
					Common.Inform("<spring:message code='Cache.ACC_msg_noFormCode' />")	//비용신청서 코드를 입력해주세요.
					return;
				}
				
				if(isEmptyStr(formName)){
					Common.Inform("<spring:message code='Cache.ACC_msg_noFormName' />")	//비용신청서명을 입력해주세요.
					return;
				}
				
				if(isEmptyStr(sortKey)){
					sortKey = 0;
				}
				
				$.ajax({
					url	: "/account/formManage/saveFormManageInfo.do",
					type: "POST",
					data: {
							"expenceFormID"		: expenceFormID
						,	"companyCode"		: companyCode
						,	"formCode"			: formCode
						,	"formName"			: formName
						,	"sortKey"			: sortKey
						,	"expAppType"		: expAppType
						,	"menuType"			: menuType
						,	"isUse"				: isUse
						,	"approvalFormInfo"	: approvalFormInfo
						,	"accountChargeInfo"	: accountChargeInfo
						,	"reservedStr1"		: reservedStr1
						,	"accountInfo"		: accountInfo
						,	"standardBriefInfo"	: standardBriefInfo
						,	"ruleInfo"			: ruleInfo
						,	"proofInfo"			: proofInfo
						,	"auditInfo"			: auditInfo
						,	"taxInfo"			: taxInfo
						,	"noteIsUse"			: noteIsUse
						,	"reservedStr2"		: reservedStr2
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(data.result == 'code'){
								Common.Inform("<spring:message code='Cache.ACC_msg_existFormCode' />");		//이미 존재하는 비용신청서 코드입니다.
							}else{
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								FormManagePopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							}
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			getInfoListForSave : function() {
				var me = this;
				
				$("ul.tabDesign").children().each(function(i, obj) {
					var TargetType = $(obj).find("a").attr("value");
					if(TargetType != "Default" && $("#"+TargetType+"InfoDiv").html().trim() != "") {
						var objArr = new Array();
						var saveTarget = $("input[type=checkbox][name="+TargetType+"Item]:checked");
						
						// 표준적요는 체크된 항목이 아닌 선택 목록이 저장되어야 함
						if(TargetType == "StandardBrief") {
							saveTarget = $("input[type=checkbox][name=selected"+TargetType+"Item]");
						}
						
						$(saveTarget).each(function() {
							var entCode = $(this).attr("dncode");
							var ItemCode = $(this).val();
							var obj = new Object();
							var tempObjArr = new Array();
							var len = objArr.length;
							
							if (len > 0) {
								for (var i=0; i<len; i++) {
									if (entCode == objArr[i].DNCode) {
										objArr[i].item.push(ItemCode);
									} else {
										if (i == len-1) {
											obj.DNCode = entCode;
											tempObjArr.push(ItemCode);
											obj.item = tempObjArr;
											objArr.push(obj);
											break;
										}
									}
								}
							} else {
								obj.DNCode = entCode;
								tempObjArr.push(ItemCode);
								obj.item = tempObjArr;
								objArr.push(obj);
							}
						});
						me[TargetType+"InfoLists"] = objArr;
					}
				});
			},
			
			closeLayer : function(){
				var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
				var popupID		= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			},
			setItem: function() {
				// 웹에디터 사용여부
				
				var domainID = accComm.getDomainID(accountCtrl.getComboInfo("companyCode").val());
				var eAccNoteIsUse = Common.getBaseConfig("eAccNoteIsUse", domainID);
				if(eAccNoteIsUse == "Y") {
					$("#noteIsUse").parent().parent().show();
				} else {
					$("#noteIsUse").parent().parent().hide();
				}
			},
			
			//표준적요 검색
			onenter : function(){
				var me = this;
				if(window.event.keyCode == 13){
					me.searchList();
				}
			},
			
			searchList : function(){
				var me = this;
				var searchStr = document.getElementById("searchStr").value; //검색한 단어
				
				$("#StandardBriefInfoDiv tr").each(function(idx, obj) {
				    var objTxt = $(obj).find("td:eq(1)").text();
				    
				    if(objTxt.indexOf(searchStr) == -1) {
				        $(obj).css("display", "none");
				    }
				    if(objTxt.indexOf(searchStr) > -1) {
				        $(obj).css("display", "block");
				    }
				});
			},
			
			setStandardBrief: function(){ //선택한 표준적요 추가
				// 추가할 표준적요
				var sbArr = $("#StandardBriefInfoDiv tr").has("input[name=StandardBriefItem]:checked");
				
				for(var i = 0; i < sbArr.length; i++) {
					// 전체 표준적요 목록 - 체크박스 disabled
					$(sbArr[i]).find("input[name=StandardBriefItem]")
						.attr("checked", false)
						.attr("disabled", true);
					
					// 표준적요 복사
					var sbCopy = $(sbArr[i]).clone();
					$(sbCopy).find("input[name=StandardBriefItem]")
						.attr("name", "selectedStandardBriefItem")
						.attr("disabled", false)
						.attr("checked", true);

					// 표준적요 추가
					$("#checkResult tbody").append($(sbCopy));
				}
			},
			
			deleteStandardBrief: function(){ //선택한 표준적요 삭제
				// 삭제할 표준적요
				var sbArr = $("#checkResult tr").has("input[name=selectedStandardBriefItem]:checked");
				
				for(var i = 0; i < sbArr.length; i++) {
					// 전체 표준적요 목록 - 체크박스 disabled 해제
					var sbChkbox = $(sbArr[i]).find("input[name=selectedStandardBriefItem]");
					$("#StandardBriefInfoDiv tr").find("input[name=StandardBriefItem][value=" + $(sbChkbox).val() + "]")
						.attr("disabled", false);
					
					// 표준적요 삭제
					$(sbArr[i]).remove();
				}
			}
	}
	window.FormManagePopup = FormManagePopup;
})(window);

FormManagePopup.popupInit();
	
</script>