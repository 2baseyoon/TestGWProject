var groupManage = {
	pageObjName				:	''
,	sessionObj				:	''
,	isSyncMail				:	''
,	isSyncIndi				:	''
,	gr_code 				:	''
,	memberOf 				:	''
,	domainId 				:	''
,	mode 					:	''
,	grouptype 				:	''
,	check_dupMail 			:	''
,	check_dup				:	'N'
,	containPrimaryMail 		: 	false
,	isArbitraryGroup 		:	false
,	sFieldName				:	''
,	initContent				:	function(){
									var me = this;
									if(me.grouptype=='JobTitle'||me.grouptype=='JobPosition'||me.grouptype=='JobLevel'||me.grouptype=='Region'){
										me.isArbitraryGroup = true;
									}
									else {
										$("[name=trGroupInfo]").show();
										$('#thTitle').prepend("<span class='thstar'>*</span>");
										$('#thName').prepend("<span class='thstar'>*</span>");
									}
									if(me.isArbitraryGroup)
									{	
										$('#thTitle').text(Common.getDic("lbl_" + me.grouptype + "_Code"));
										$('#thTitle').prepend("<span class='thstar'>*</span>");
										$('#thName').text(Common.getDic("lbl_" + me.grouptype + "Name"));
										$('#thName').prepend("<span class='thstar'>*</span>");
									}
									if(Common.getGlobalProperties("isSaaS") == "Y")
										$("#txtMailID").attr("readonly", "readonly");
									if(me.mode == "add"){
										me.setDefaultInfo();
									}
									
									if(me.mode == "modify"){
										me.getGroupInfoData(me.gr_code);
										$("#txtMailID").attr("readonly", "readonly");
										$("#selMailDomain").attr("disabled","disabled");
										$("#btnIsDuplicateMail").hide();
									}
									
									if ((me.grouptype.toUpperCase().indexOf("DIVISION") != -1 && me.gr_code != "") || me.grouptype.toUpperCase().indexOf("COMPANY") != -1) 
									{
										$("input[type=text]").attr('readonly',true)
										$("select").attr('disabled',true)
										//$("input[type=button][id!=btnClose]").hide()
										$("form").find('a[id!=btnClose]').hide();
									}
									
									//기초설정에 따른 메일 표기 여부
									if(me.isSyncIndi == "Y"){
										$("#GroupAddSetTab").css("display","none");
									}
									else if(me.isSyncMail == "Y"){
										$("#trIndiMail").css("display", "none");
									}
									else {
										var trMail = $('#selIsMail').closest('tr');
										trMail.children('td:first').attr('colspan', '3');
										trMail.children('th:nth-of-type(2)').css("display","none");
										trMail.children('td:nth-of-type(2)').css("display","none");
									}
									
									$(Common.getBaseCode('MailDomain').CacheData).each(function(idx, obj) {
										if (obj.Code == 'MailDomain'){
											return true;
										}
										$('#selMailDomain').append($('<option>', { 
											value: obj.CodeName,
											text: obj.CodeName
										}));
									});
									me.fnMailUse();
									// 그룹유형 정의
									if(me.grouptype == "Dept") {
										$("#hidGroupType").val("Dept");
									}
									else if (me.grouptype == "Company") {
										if (me.gr_code != "") {
											$("#hidGroupType").val("Company");
										}
										else {
											$("#hidGroupType").val("Dept");
										}
									}
									else if (me.grouptype == "Division") {
										if (me.gr_code != "") {
											$("#hidGroupType").val("Division");
										}
										else {
											$("#hidGroupType").val(me.memberOf.split('_')[1]);
										}
									}
									else {
										$("#hidGroupType").val(me.grouptype);
									}
									
								}	
,	setDefaultInfo			:	function(){
									var me = this;
									$.ajax({
										type: "POST",
										data: {
											"memberOf": me.memberOf,
											"domainId": me.domainId
										},
										url: "/covicore/manage/conf/getDefaultsetInfoGroup.do",
										success: function (data) {
											$("#txtCompanyName").val(data.list[0].CompanyName);
											$("#hidCompanyCode").val(data.list[0].CompanyCode);
											$("#txtParentGroupName").val(data.list[0].GroupName);
											$("#hidParentGroupCode").val(me.memberOf);
											$("#selMailDomain").val(data.list[0].MailDomain);
											
											if(me.isArbitraryGroup)
											{
												if(Common.getGlobalProperties("disablePrefix") != "Y") {
													if (me.grouptype == "JobTitle")
														$("#txtPfx").text("T"); 
													else if (me.grouptype == "JobPosition") 
														$("#txtPfx").text("P");
													else if (me.grouptype == "JobLevel")
														$("#txtPfx").text("L");
													else if (me.grouptype == "Region")
														$("#txtPfx").text("R");
												}
												if(Common.getGlobalProperties("isSaaS") == "Y") {
													$("#txtSfx").text("_" + me.domainId);	
												}
											}
											else{
												$("#txtPfx").text(me.domainId + "_");
											}
											
										},
										error: function(response, status, error){
											CFN_ErrorAjax("/covicore/manage/conf/getDefaultsetInfoGroup.do", response, status, error);
										}
									});
								}
,	dictionaryLayerPopup	:	function(hasTransBtn, dicCallback){
									var me = this;
									me.sFieldName = dicCallback;
			
									var option = {
											lang : 'ko',
											hasTransBtn : hasTransBtn,
											allowedLang : 'ko,en,ja,zh',
											useShort : 'false',
											dicCallback :  me.pageObjName+"."+dicCallback,
											popupTargetID : 'DictionaryPopup',
											init : me.pageObjName+'.initDicPopup'
									};
									
									var url = "";
									url += "/covicore/control/calldic.do?lang=" + option.lang;
									url += "&hasTransBtn=" + option.hasTransBtn;
									url += "&useShort=" + option.useShort;
									url += "&dicCallback=" + option.dicCallback;
									url += "&allowedLang=" + option.allowedLang;
									url += "&popupTargetID=" + option.popupTargetID;
									url += "&init=" + option.init;
									url += "&styleType=" + "U";
									url += "&openerID=" + "divgroupInfo";
									
									parent.Common.open("", "DictionaryPopup", Common.getDic("lbl_MultiLangSet"), url, "720px", "300px", "iframe", true, null, null, true);
								}
,	initDicPopup			:	function(){
									var me = this;
									var sHiddenName = me.sFieldName == "txtGroupName" ? "GroupNameHidden" :  "GroupShortNameHidden";
									if(me.sFieldName==''){
										return "";
									}
									return $("#"+sHiddenName).val()==''? $("#"+me.sFieldName).val() : $("#"+sHiddenName).val();
								}
,	txtGroupName			:	function(data){
									var me = this;
									data = JSON.parse(data);
									$('#txtGroupName').val(data.KoFull);
									$('#GroupNameHidden').val(coviDic.convertDic(data))
								}
							
,	txtGroupShortName		:	function(data){
									var me = this;
									data = JSON.parse(data);
									$('#txtGroupShortName').val(data.KoFull);
									$('#GroupShortNameHidden').val(coviDic.convertDic(data))
								}
,	setDictionaryData	:		function(nameValue){
									var me = this;
									var koData = nameValue.split(';')[0];
									if(koData == $("#txtGroupName").val())
										$("#GroupNameHidden").val(nameValue);
									if(koData == $("#txtGroupShortName").val())
										$("#GroupShortNameHidden").val(nameValue);
								}
,	resetDicData			:	function(thisObj){
									var me = this;
									if($(thisObj)[0].id == "txtGroupName"){
										$("#GroupNameHidden").val("");
									}else if($(thisObj)[0].id == "txtGroupShortName"){
										$("#GroupShortNameHidden").val("");
									}
								}
,	clickTab				:	function(pObj){
									var me = this;
									$("#divTabTray li.active").removeClass('active')
									$(pObj).parent().addClass('active')
									var str = $(pObj).attr("value");
									
									$("#divGroupDefault").hide();
									$("#divGroupAdd").hide();
									
									$("#" + str).show();
								}
,	getGroupInfoData		:	function(){
									var me = this;
									var lang = me.sessionObj["lang"];
									$.ajax({
										type:"POST",
										data:{
											"gr_code" : me.gr_code
										},
										url:"/covicore/manage/conf/getGroupInfo.do",
										success:function (data) {
											$("#txtGroupCode").val(data.list[0].GroupCode);
											$("#txtGroupName").val(CFN_GetDicInfo(data.list[0].MultiDisplayName, lang));
											$("#GroupNameHidden").val(data.list[0].MultiDisplayName);
											$("#txtGroupShortName").val(CFN_GetDicInfo(data.list[0].MultiShortName, lang));
											$("#GroupShortNameHidden").val(data.list[0].MultiShortName);
											$("#txtCompanyName").val(CFN_GetDicInfo(data.list[0].CompanyName, lang));
											$("#hidCompanyCode").val(data.list[0].CompanyCode);
											$("#txtParentGroupName").val(CFN_GetDicInfo(data.list[0].ParentName, lang));
											$("#hidParentGroupCode").val(data.list[0].MemberOf);
											$("#selIsUse").val(data.list[0].IsUse == "" ? "N" : data.list[0].IsUse);
											$("#selIsHR").val(data.list[0].IsHR == "" ? "N" : data.list[0].IsHR);
											$("#txtPriorityOrder").val(data.list[0].SortKey);		
											$("#selIsMail").val(data.list[0].IsMail == "" ? "N" : data.list[0].IsMail);
											$("#hidtxtUseMailConnect").val(data.list[0].IsMail == "" ? "N" : data.list[0].IsMail);

											var txtPrimaryMail = data.list[0].PrimaryMail;
											me.fnMailUse();
											if(txtPrimaryMail != ""&& txtPrimaryMail !="@"){
												$("#txtMailID").val(txtPrimaryMail.split("@")[0]);
												$("#selMailDomain").val(txtPrimaryMail.split("@")[1]);
												$("#hidtxtMailID").val(txtPrimaryMail);
												
												$("#txtMailID").attr("readonly", "readonly");
												$("#selMailDomain").attr("disabled","disabled");
												me.containPrimaryMail = true;
											}
											
											if(data.list[0].PrimaryMail != ""){
												$("#hidMailAddressInfo").val(data.list[0].PrimaryMail);	
											}
											if(data.list[0].SecondaryMail != ""){
												$("#hidMailAddressInfo").val($("#hidMailAddressInfo").val() + "," + data.list[0].SecondaryMail);
											}
											
											if ($("#hidMailAddressInfo").val() != "" && me.isSyncMail == "Y") {
												var sMailAttributeInfo = $("#hidMailAddressInfo").val();
												if (sMailAttributeInfo.indexOf(';') != -1) {
													sMailAttributeInfo = sMailAttributeInfo.replace(';', ',');
												}
												var sAttributeID = "";
												var sMailID = "";
												var sXML = "<Attribute>";
												if (sMailAttributeInfo.indexOf(',') != -1) {
													var aMailAttributeInfo = sMailAttributeInfo.split(',');
													for (var i = 0; i < aMailAttributeInfo.length; i++) {
														if (aMailAttributeInfo[i].indexOf('|') != -1) {
															var aMailAttributeInfo_Secondary = aMailAttributeInfo[i].split('|');
															for (var j = 0; j < aMailAttributeInfo_Secondary.length; j++) {
																sXML += "<Mail><![CDATA[" + aMailAttributeInfo_Secondary[j] + "]]></Mail>";
																sXML += "<AttributeID><![CDATA[" + aMailAttributeInfo_Secondary[j] + "]]></AttributeID>";
															}
														} else {
															sXML += "<Mail><![CDATA[" + aMailAttributeInfo[i] + "]]></Mail>";
															sXML += "<AttributeID><![CDATA[" + sAttributeID + "]]></AttributeID>";
														}
													}

												} else {
													sXML += "<Mail><![CDATA[" + sMailAttributeInfo + "]]></Mail>";
													sXML += "<AttributeID><![CDATA[" + sAttributeID + "]]></AttributeID>";
												}
												sXML += "</Attribute>";
												me.btnAttributeAdd_OnClick_After(sXML);
											}

											$("#txtDescription").val(data.list[0].Description); //data.list[0].Description
											
											$("#btnIsDuplicate").css("display", "none");
											$("#txtGroupCode").attr("readonly", "readonly");
											
										},
										error:function(response, status, error){
											CFN_ErrorAjax("/covicore/manage/conf/getgroupinfo.do", response, status, error);
										}
									});
								}
,	checkDuplicate			:	function(){
									var me = this;
									if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
									var stringRegx = /[\s\{\}\[\]?.,;:|\)*~`!^\-+┼<>@\#$%&\\(\=\'\"]/;
									var stringRegx2 = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
									var blank_pattern = /[\s]/g;
									
									if(me.mode == "add") {
										var groupCode = $('#txtGroupCode').val();
										if(groupCode == "") {
											if(me.grouptype == 'JobTitle'){
												Common.Warning(Common.getDic("msg_JobTitle_01"));
											}else if(me.grouptype == 'JobPosition'){
												Common.Warning(Common.getDic("msg_JobPosition_01"));
											}else if(me.grouptype == 'JobLevel'){
												Common.Warning(Common.getDic("msg_JobLevel_01"));
											}else if(me.grouptype == 'Region'){
												Common.Warning(Common.getDic("msg_Region_01"));
											}else{
												Common.Warning(Common.getDic("msg_Manage_01"));
											}
										} else{
											if(stringRegx.test($("#txtGroupCode").val())) {
												Common.Warning(Common.getDic("msg_specialNotAllowed"), 'Warning Dialog', function() {
													$("#txtGroupCode").focus();
												});
												return false;
											} else if(stringRegx2.test($("#txtGroupCode").val())) {
												Common.Warning(Common.getDic("msg_KoreanNotAllowed"), 'Warning Dialog', function() {
													$("#txtGroupCode").focus();
												});
												return false;
											} else if(blank_pattern.test($("#txtGroupCode").val()) == true ){
												Common.Warning(Common.getDic("msg_apv_146"), 'Warning Dialog', function() {
													$("#txtDeptCode").focus();
												});
												return false;
											}
											
											if($("#txtSfx").text() != "")groupCode =  groupCode+$("#txtSfx").text() ;
											if($("#txtPfx").text() != "")groupCode = $("#txtPfx").text() + groupCode;
												
											$.ajax({
												type:"POST",
												data:{
													"GroupCode" : groupCode
												},
												url:"/covicore/manage/conf/getIsduplicateGroupcode.do",
												success:function (data) {
													if(data.status != "FAIL") {
														if(data.list[0].isDuplicate > 0) {
															Common.Warning(Common.getDic("msg_EXIST_GRCODE"));
															$('#txtGroupCode').focus();
															me.check_dup = "N";
														} else {
															Common.Inform(Common.getDic("msg_Not_Duplicate"));
															me.check_dup = "Y";
															
															if(Common.getGlobalProperties("isSaaS") == "Y"&&$("#selIsMail").val()=="Y") {
																$("#txtMailID").val(groupCode);
																me.gr_code = groupCode;
															}
														}
													} else {
														Common.Warning(data.message);
														me.check_dup = "N";
													}
												},
												error:function(response, status, error){
													CFN_ErrorAjax("/covicore/manage/conf/getIsduplicateGroupcode.do", response, status, error);
												}
											});
										}
									}
								}
,	checkDuplicateMail		:	function(){
									var me = this;
									var stringRegx = /[\s\{\}\[\]?.,;:|\)*~`!^\+┼<>@\#$%&\\(\=\'\"]/;
									var stringRegx2 = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
									
									if($('#txtMailID').val() == "" || $('#selMailDomain').val() == "") {
										Common.Warning(Common.getDic("msg_NeedMailUrl") );//Mail 주소를 입력해 주십시오.
										me.check_dupMail = "N";
									} else{
										if(stringRegx.test($("#txtMailID").val())) {
											Common.Warning(Common.getDic("msg_specialNotAllowed"), 'Warning Dialog', function() {
												$("#txtMailID").focus();
											});
											return false;
										} else if(stringRegx2.test($("#txtMailID").val())) {
											Common.Warning(Common.getDic("msg_KoreanNotAllowed"), 'Warning Dialog', function() {
												$("#txtMailID").focus();
											});
											return false;
										} 
										
										var mailAddress= $('#txtMailID').val() + '@' + $('#selMailDomain').val();
										$.ajax({
											type:"POST",
											data:{
												"MailAddress" : mailAddress,
												"Code" : me.mode == "add"? '' :  $('#txtGroupCode').val()
											},
											url:"/covicore/manage/conf/getIsduplicateMail.do",
											success:function (data) {
												if(data.status != "FAIL") {
													if(data.list[0].isDuplicate > 0) {
														Common.Warning(Common.getDic("msg_exist_mailaddress") );//이미 존재하는 메일주소 입니다.
														$('#txtGroupCode').focus();
														me.check_dupMail = "N";
													} else {
														Common.Inform(Common.getDic("msg_allow_mail") );//사용 가능한 메일 주소 입니다.
														me.check_dupMail = "Y";
													}
												} else {
													Common.Warning(data.message);
													me.check_dupMail = "N";
												}
											},
											error:function(response, status, error){
												CFN_ErrorAjax("/covicore/manage/conf/getIsduplicateMail.do", response, status, error);
											}
										});
									}
								}
,	CheckValidation			:	function(){
									var me = this;
									if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
									
									if($("#txtGroupCode").val() == "") {
										if(me.grouptype == 'JobTitle'){
											Common.Warning(Common.getDic("msg_JobTitle_01"), 'Warning Dialog', function() {  //직책 코드를 입력하세요.
												$("#txtGroupCode").focus();
											});
											return false;
										}else if(me.grouptype == 'JobPosition'){
											Common.Warning(Common.getDic("msg_JobPosition_01"), 'Warning Dialog', function() {  //직위 코드를 입력하세요.
												$("#txtGroupCode").focus();
											});
											return false;
										}else if(me.grouptype == 'JobLevel'){
											Common.Warning(Common.getDic("msg_JobLevel_01"), 'Warning Dialog', function() {  //직급 코드를 입력하세요.
												$("#txtGroupCode").focus();
											});
											return false;
										}else if(me.grouptype == 'Region'){
											Common.Warning(Common.getDic("msg_Region_01"), 'Warning Dialog', function() {  //직급 코드를 입력하세요.
												$("#txtGroupCode").focus();
											});
											return false;
										}else{
											Common.Warning(Common.getDic("msg_Manage_01"), 'Warning Dialog', function() {  //그룹 코드를 입력하세요.
												$("#txtGroupCode").focus();
											});
											return false;
										}
									} 
									if(me.mode == "add" && me.check_dup == "N") {
										Common.Warning(Common.getDic("msg_BaseCode_04")); //코드 중복을 확인하여 주십시오.
										return false;
									}
									if($("#txtGroupName").val() == "") {
										if(me.grouptype == 'JobTitle'){
											Common.Warning(Common.getDic("msg_JobTitle_02"), 'Warning Dialog', function() {  //직책명을 입력하세요.
												$("#txtGroupName").focus();
											});
											return false;
										}else if(me.grouptype == 'JobPosition'){
											Common.Warning(Common.getDic("msg_JobPosition_02"), 'Warning Dialog', function() {  //직위명을 입력하십시오.
												$("#txtGroupName").focus();
											});
											return false;
										}else if(me.grouptype == 'JobLevel'){
											Common.Warning(Common.getDic("msg_JobLevel_02"), 'Warning Dialog', function() {  //직급명을 입력하세요.
												$("#txtGroupName").focus();
											});
											return false;
										}else if(me.grouptype == 'Region'){
											Common.Warning(Common.getDic("msg_Region_02"), 'Warning Dialog', function() {  //지역이름을 입력하여 주십시오.
												$("#txtGroupName").focus();
											});
											return false;
										}else{
											Common.Warning(Common.getDic("msg_EnterGroupName"), 'Warning Dialog', function() {  //그룹명을 입력하세요.
												$("#txtGroupName").focus();
											});
											return false;
										}
									}
									if($("#GroupNameHidden").val() == "") {
										if(me.grouptype == 'JobTitle'){
											Common.Warning(Common.getDic("msg_GRNAME_06"), 'Warning Dialog', function() {  //직책명의 다국어 처리를 변경하십시오.
												$("#txtDeptName").focus();
											});
											return false;
										}else if(me.grouptype == 'JobPosition'){
											Common.Warning(Common.getDic("msg_GRNAME_05"), 'Warning Dialog', function() {  //직위명의 다국어 처리를 변경하십시오.
												$("#txtDeptName").focus();
											});
											return false;
										}else if(me.grouptype == 'JobLevel'){
											Common.Warning(Common.getDic("msg_GRNAME_07"), 'Warning Dialog', function() {  //직급명의 다국어 처리를 변경하십시오.
												$("#txtDeptName").focus();
											});
											return false;
										}else if(me.grouptype == 'Region'){
											Common.Warning(Common.getDic("msg_GRNAME_08"), 'Warning Dialog', function() {  //지역명의 다국어 처리를 변경하십시오.
												$("#txtDeptName").focus();
											});
											return false;
										}else{
											Common.Warning(Common.getDic("msg_GRNAME_04"), 'Warning Dialog', function() {  //그룹명의 다국어 처리를 변경하십시오.
												$("#txtDeptName").focus();
											});
											return false;
										}
									}
									if(!me.isArbitraryGroup){
										if($("#txtGroupShortName").val() == "") {
											Common.Warning(Common.getDic("msg_ShortName_Req"), 'Warning Dialog', function() { //간략명칭을 입력하세요.
												$("#txtGroupShortName").focus();
											});
											return false;
										}
										if($("#GroupShortNameHidden").val() == "") {
											Common.Warning(Common.getDic("msg_GRNAME_03"), 'Warning Dialog', function() { //간략명칭의 다국어 처리를 변경하십시오.
												$("#txtGroupShortName").focus();
											});
											return false;
										}
									}
									if($("#txtPriorityOrder").val() == "") {
										Common.Warning(Common.getDic("msg_EnterPriorityNumber"), 'Warning Dialog', function() { //우선순위를 입력하세요.
											$("#txtPriorityOrder").focus();
										});
										return false;
									}
									
									
									//추가속성 :: Primary, Secondary값 HiddenField에 저장합니다.
									var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
									var nLength = aObjectTR.length;
									for (var i = 1; i < nLength; i++) {
										if (i == nLength - 1) {
											$("#hidSecondary").val($("#hidSecondary").val() +aObjectTR.filter(":eq(" + i.toString() + ")").text());
										} else {
											$("#hidSecondary").val($("#hidSecondary").val() + aObjectTR.filter(":eq(" + i.toString() + ")").text() + "|");
										}
									}
									$("#hidPrimary").val(aObjectTR.filter(":eq(0)").text());
									if (me.isSyncMail == "Y") { //[2012-09-14 Modi] 기초 설정 메일 연동 여부에 따른 필수값 패스
										if ($("#selUseMail").val() == "Y") {
											if (aObjectTR.filter(":eq(0)").text() == "") {
												parent.Common.Warning(Common.getDic("msg_37"), "Warning Dialog", function () {                       // 메일주소를 입력하여 주십시오.
													me.clickTab($("#GroupAddSetTab"));
												});
												return false;
											}
										}
									}
									
									if(me.isSyncMail == 'Y') {
										//Exch 메일 사용
									} 
									else if(me.isSyncIndi == "Y"){
										if ($("#txtMailID").val() == "" ) {
											Common.Warning(Common.getDic("msg_insert_MailAddress"), 'Warning Dialog', function() { // 메일주소를 입력해 주십시오.
												$("#txtMailID").focus();
											});
											return false;
										}
										if($("#selMailDomain option:selected").val() == "") {
											Common.Warning(Common.getDic("msg_insert_MailAddress"), 'Warning Dialog', function() { // 메일 도메인을 선택해 주십시오.
												$("#selMailDomain").focus();
											});
											return false;
										}
										if(me.mode == "add" && me.check_dupMail == "N") {
											Common.Warning(Common.getDic("msg_Check_Duplicate_Mail"), 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
												$("#txtMailID").focus();
											});
											return false;
										}
									} 
									
									//////////////////////////////////////////////////////
									var now = new Date();
									now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
									
									var url = "/covicore/manage/conf/insertgroupinfo.do";
									var message = Common.getDic("msg_117");
									if(me.mode == "modify") {
										url = "/covicore/manage/conf/updategroupinfo.do";
										message = Common.getDic("msg_137")
									}
									
									var pGroupCode = $("#txtGroupCode").val();
									if(me.mode == "add"){
										if($("#txtSfx").text() != "")pGroupCode =  pGroupCode+$("#txtSfx").text() ;
										if($("#txtPfx").text() != "")pGroupCode = $("#txtPfx").text() + pGroupCode;
									}
									var PrimaryMail=($("#txtMailID").val() + "@" + $("#selMailDomain").val())
									PrimaryMail = PrimaryMail=='@'?'':PrimaryMail;
									
									Common.Progress(Common.getDic('msg_apv_008'));
									
									$.ajax({
										type:"POST",
										data:{
											"GroupType" : $("#hidGroupType").val(),
											"GroupCode" : pGroupCode,
											"DisplayName" : $("#txtGroupName").val(),
											"MultiDisplayName" : $("#GroupNameHidden").val(),
											"ShortName" : $("#txtGroupShortName").val(),
											"MultiShortName" : $("#GroupShortNameHidden").val(),
											//"PrimaryMail" : ($("#txtMailID").val() + "@" + $("#selMailDomain").val()),
											"PrimaryMail" : PrimaryMail,
											"CompanyCode" : $("#hidCompanyCode").val(),
											"MemberOf" : $("#hidParentGroupCode").val(),
											"IsUse" : $("#selIsUse option:selected").val(),
											"IsHR" : $("#selIsHR option:selected").val(),
											"IsMail" : $("#selIsMail").val(),
											"hidtxtUseMailConnect" : $("#hidtxtUseMailConnect").val(),
											"SortKey" : $("#txtPriorityOrder").val(),
											"Description" : $("#txtDescription").val(),
											//"RegistID" : me.sessionObj["UR_Code"],
											"RegistDate" : now,
											"EX_PrimaryMail" : $("#hidPrimary").val(),
											"SecondaryMail" : $("#hidSecondary").val(),
											"CompanyName" : $("#txtCompanyName").val(),
											"OUName" : $("#txtGroupName").val()
											//ManagerCode
											//ReceiptUnitCode
											//ApprovalUnitCode
											//Receivable
											//Approvable
											//RegionCode
											//IsScheduleCreate
											//DN_ID
										},
										url:url,
										success:function (data) {
											if(data.status == "FAIL") {
												if(data.message.indexOf("|")) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
												else Common.Warning(data.message);
											} else
												Common.Inform(message, "Information Dialog", function(result) {
													if(result) {
														parent.pageRefresh()
														Common.Close();
													}
												});
										},
										error:function(response, status, error){
											CFN_ErrorAjax(url, response, status, error);
										}
									});
								}
,	btnMailAdd_OnClick		:	function(){
									var me = this;
									var sMailID = $("#txtGroupCode").val();
									$("#hidMailAddressInfo").val("");
									me.ShowMailAttributeSetting(sMailID, "0", "Add");
								}
,	ShowMailAttributeSetting:	function(sMail, nIndex, sMode){
									var me = this;
									var sOpenName = "divAttribute";
									var sURL = "/covicore/mailaddressattributepop.do";
									sURL += "?iframename=divgroupInfo";
									sURL += "&openname=" + sOpenName;
									sURL += "&mailaddress=hidMailAddressInfo";
									sURL += "&mail=" + sMail;
									sURL += "&index=" + nIndex;
									sURL += "&mode=" + sMode;
									sURL += "&callbackmethod="+me.pageObjName+".btnAttributeAdd_OnClick_After";
									
									 var aStrDictionary = null;
									 var sTitle = "";
									 if ($("#hidMailAddressInfo").val() == "") {
										 sTitle = Common.getDic("lbl_ResourceManage_06") + " ||| " + Common.getDic("msg_ResourceManage_06");
									 }
									 else {
										 sTitle = Common.getDic("lbl_ResourceManage_07") + " ||| " + Common.getDic("msg_ResourceManage_07");
									 }

									parent.Common.open("", "divAttribute", sTitle, sURL, "500px", "150px", "iframe", true, null, null, true);
								}
,	btnAttributeAdd_OnClick_After:	function(pStrAttributeInfo){
										var me = this;
										var sHTML = "";

										if ((pStrAttributeInfo != null) && (pStrAttributeInfo != "")) {

											$($.parseXML(pStrAttributeInfo)).find("Attribute").find("Mail").each(function () {
												sHTML = "";

												var sMail = $(this).text();
												var sAttributeID = $(this).parent().find("AttributeID").text();
												var sIndex = $(this).parent().find("Index").text();
												var sMode = $(this).parent().find("Mode").text();

												var nIndex = $("#divAttributeList").children("TABLE").children("TBODY").children("TR").length;
												var oTR = $("#divAttributeList").children("TABLE").children("TBODY").children("TR");
												var oTD = $("#divAttributeList").children("TABLE").children("TBODY").children("TR").children("TD");

												if (sMode == "Add") {
													for (var i = 0; i < oTR.length; i++) {
														if ($(oTD[i]).children("A").text() == sMail) {
															Common.Warning(Common.getDic("lbl_EmailAddresSame.") , "Warning Dialog");
															return;
														}
													}
												}
												else if (sMode == "Edit") {
													for (var i = 0; i < oTR.length; i++) {
														if ($(oTD[i]).children("A").text() == sMail) {
															if (sIndex != "0") {
																$(oTD[i]).children("A")[0].href = "javascript:"+me.pageObjName+".ShowMailAttributeSetting('" + sMail + "', '" + i + "', 'Edit');"
																$(oTD[i]).children("A").text(sMail);
																$("TD[Index=" + sIndex + "]").remove();
																return;
															}
														}
													}
													if (sIndex != "") {
														$(oTD[sIndex]).children("A")[0].href = "javascript:"+me.pageObjName+".ShowMailAttributeSetting('" + sMail + "', '" + sIndex + "', 'Edit');"
														$(oTD[sIndex]).children("A").text(sMail);
														return;
													}
												}

												if ($("#divAttributeList").children().length == 0) {
													sHTML += "<tr Mail=\"Primary\">";
													sHTML += "<td class=\"t_back01_line\" width=\"10\" Index='" + nIndex + "'>";
													sHTML += "<input id=\"chkAttribute_" + nIndex + "\" type=\"checkbox\" style=\"cursor: pointer;\" class=\"input_check\" />";
													sHTML += "<a href=\"javascript:"+me.pageObjName+".ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-weight:bold\">";
													sHTML += sMail;
													sHTML += "</a>";
													sHTML += "</td>";
												}
												else {
													sHTML += "<tr Mail=\"Secondary\">";
													sHTML += "<td class=\"t_back01_line\" width=\"10\" Index='" + nIndex + "'>";
													sHTML += "<input id=\"chkAttribute_" + nIndex + "\" type=\"checkbox\" style=\"cursor: pointer;\" class=\"input_check\" />";
													sHTML += "<a href=\"javascript:"+me.pageObjName+".ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-weight:\">";
													sHTML += sMail;
													sHTML += "</a>";
													sHTML += "</td>";
												}
												sHTML += "</tr>";

												if ($("#divAttributeList").children().length <= 0) {
													sHTML = "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">" + sHTML + "</table>";
													$("#divAttributeList").append(sHTML);
												}
												else {
													$("#divAttributeList").children("TABLE").children("TBODY").append(sHTML);
												}
											});
										}
									}
,	btnMailDel_OnClick		:	function(){
									var me = this;
									if ($("input[id^='chkAttribute_']:checked").length > 0) {
										Common.Confirm(Common.getDic("msg_Common_08"), 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
											if (result) {
												$("input[id^='chkAttribute_']:checked").each(function () {
													$(this).parent().parent().remove();
												});
											}
											if ($("#divAttributeList > TABLE > TBODY >TR").length == 0) {
												$("#divAttributeList").html("");
											}
										});
									}
									else {
										Common.Warning(Common.getDic("msg_Common_03"), "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
										return;
									}
								}
,	btnMailUp_OnClick		:	function(){
									var me = this;
									var bSelected = false;
									$("input[id^='chkAttribute_']:checked").each(function () {
										bSelected = true;
									});

									if (!bSelected) {
										Common.Warning(Common.getDic("msg_Common_09"), "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
										return;
									}

									var oPrevTR = null;
									var oNowTR = null;

									var oResult = null;
									var bSucces = true;
									var sResult = "";
									var sErrorMessage = "";

									var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
									var nLength = aObjectTR.length;
									for (var i = 0; i < nLength; i++) {
										if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")) {
											continue;
										}

										// 현재 행: 위에서부터 선택 되어 있는 행 찾기
										oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");

										// 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
										oPrevTR = null;
										for (var j = i - 1; j >= 0; j--) {
											if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")) {
												continue;
											}
											oPrevTR = aObjectTR.filter(":eq(" + j.toString() + ")");
											break;
										}
										if (oPrevTR == null) {
											continue;
										}

										oPrevTR.insertAfter(oNowTR);

										if (oPrevTR.attr("Mail") == "Primary") {
											oPrevTR.removeAttr("Mail");
											oPrevTR.attr("Mail", "Secondary");
											oNowTR.removeAttr("Mail");
											oNowTR.attr("Mail", "Primary");

											$(oNowTR).children("TD").children("a").css({ "font-weight": "bold" });
											$(oPrevTR).children("TD").children("a").css({ "font-weight": "" });
										}
									}
									if (sErrorMessage != "") {
										Common.Error(sErrorMessage, "Error Dialog", function () { });
									}
								}
,	btnMailDown_OnClick		:	function(){
									var me = this;
									var bSelected = false;
									$("input[id^='chkAttribute_']:checked").each(function () {
										bSelected = true;
									});

									if (!bSelected) {
										Common.Warning(Common.getDic("msg_Common_09"), "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
										return;
									}

									var oNextTR = null;
									var oNowTR = null;

									var oResult = null;
									var bSucces = true;
									var sResult = "";
									var sTemp = "";
									var sErrorMessage = "";

									var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
									var nLength = aObjectTR.length;
									for (var i = nLength; i >= 0; i--) {
										if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")) {
											continue;
										}

										// 현재 행: 아래에서부터 선택되어 있는 행 찾기
										oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");

										// 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
										oNextTR = null;
										for (var j = i + 1; j < nLength; j++) {
											if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")) {
												continue;
											}
											oNextTR = aObjectTR.filter(":eq(" + j.toString() + ")");
											break;
										}
										if (oNextTR == null) {
											continue;
										}

										oNowTR.insertAfter(oNextTR);

										if (oNowTR.attr("Mail") == "Primary") {
											oNowTR.removeAttr("Mail");
											oNowTR.attr("Mail", "Secondary");
											oNextTR.removeAttr("Mail");
											oNextTR.attr("Mail", "Primary");

											$(oNextTR).children("TD").children("a").css({ "font-weight": "bold" });
											$(oNowTR).children("TD").children("a").css({ "font-weight": "" });
										}
									}
									if (sErrorMessage != "") {
										Common.Error(sErrorMessage, "Error Dialog", function () { });
									}
								}
,	btnMailAttributeAdd_OnClick:function(){
									var me = this;
									var sOpenName = "divMailAttribute";
									var sURL = "/covicore/mailattributepop.do";
									sURL += "?iframename=divgroupInfo";
									sURL += "&openname=" + sOpenName;
									sURL += "&attributes=hidMailAttribute";
									sURL += "&callbackmethod=pageObj.btnMailAttributeAdd_OnClick_After";

									var aStrDictionary = null;
									var sTitle = "";
									if ($("#hidMailAddressInfo").val() == "") {
										sTitle = Common.getDic("lbl_ResourceManage_06") + " ||| " + Common.getDic("msg_ResourceManage_06");
									}
									else {
										sTitle = Common.getDic("lbl_ResourceManage_07") + " ||| " + Common.getDic("msg_ResourceManage_07");
									}
									parent.Common.open("", "divMailAttribute", sTitle, sURL, "380px", "550px", "iframe", true, null, null, true);
								}
,	btnMailAttributeAdd_OnClick_After:	function(){
											var me = this;
											var sHTML = "";

											if ((pStrAttributeInfo != null) && (pStrAttributeInfo != "")) {
												$("#hidMailAttribute").val(pStrAttributeInfo);
												$("#hidMailAttribute1").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_1").text());
												$("#hidMailAttribute2").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_2").text());
												$("#hidMailAttribute3").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_3").text());
												$("#hidMailAttribute4").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_4").text());
												$("#hidMailAttribute5").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_5").text());
												$("#hidMailAttribute6").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_6").text());
												$("#hidMailAttribute7").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_7").text());
												$("#hidMailAttribute8").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_8").text());
												$("#hidMailAttribute9").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_9").text());
												$("#hidMailAttribute10").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_10").text());
												$("#hidMailAttribute11").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_11").text());
												$("#hidMailAttribute12").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_12").text());
												$("#hidMailAttribute13").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_13").text());
												$("#hidMailAttribute14").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_14").text());
												$("#hidMailAttribute15").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_15").text());
											}
										}
,	fnMailUse				:	function(){
									var me = this;
									//메일사용여부 무관하게 메일ID, 도메인 무조건 받는걸로..
									//수정팝업에서는 해당정보들 수정불가
								}
,	fnMailUseOld			:	function(){
									var me = this;
									if($("#selIsMail option:selected").val() == "N") {
										$("#txtMailID").attr("readonly", "readonly");
										$("#selMailDomain").attr("disabled","disabled");
										if(!me.containPrimaryMail){
											$("#txtMailID").val('');
											$("#selMailDomain").val('');
										}
										if (me.isSyncMail == "Y") {
											$("#deptAddSetTab").css("display","none");
										}
									}else {
										if(!me.containPrimaryMail){
											$("#txtMailID").removeAttr("readonly");
											$("#selMailDomain").removeAttr("disabled");
										}
										if(!me.containPrimaryMail&&Common.getGlobalProperties("isSaaS") == "Y"){
											$("#txtMailID").val(me.gr_code);
											$("#selMailDomain").val('');
										}
										if(me.isSyncMail == "Y") {
											$("#deptAddSetTab").css("display","");
										}
									}
									
									if(Common.getGlobalProperties("isSaaS") == "Y")
										$("#txtMailID").attr("readonly", "readonly");
								}
}

// 다국어 값 바인드 및 처리
//parent._CallBackMethod = me.setDictionaryData;



function _closePopup() {
	Common.Close();
} 
var _writeNum = function(obj) {
	// Validation Chk
	var inputKey = event.key;
	var inputBox = $(obj);
	var value = inputBox.val();
	
	
	if(_ie) {
		if(inputKey == "Decimal")
			inputKey = ".";
	}
	
	// 숫자 및 소수점이 아닌 문자 치환
	value = value.replace(/[^0-9.]/g, '');
	
	value = value == "" ? "0" : value;

	// 숫자형식으로 변경
	// 숫자형식이거나 event에 바인딩되어 넘어오지 않은경우
	if(inputKey != ".") {
		//반올림 첫번째자리까지			
		value = parseFloat(value);
		
		inputBox.val(value);
		
	} else if(inputKey == ".") {
		inputBox.val(value);
	}
	return false;
};
