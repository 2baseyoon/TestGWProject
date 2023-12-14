<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="layer_divpop ui-draggable popBizCardView" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap contDetail">
					<dl>
						<dt><spring:message code='Cache.lbl_TFProgress' /></dt> <!-- 진행상황 -->
						<dd><span id="spnState" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFName' /></dt> <!-- T/F 팀룸 명 -->
						<dd><span id="spnTFName" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_task_folder' /></dt> <!-- 분류 -->
						<dd>
							<select class="selectType02 size102" id="ddlCategory">
							</select>
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_HeadDept' /></dt> <!-- 주관부서 -->
						<dd>
							<input type="text" class="txtInp" id="txtMajorDept" readonly="" style="float: left;">
							<input type="hidden" id="hidMajorDeptCode">
							<a onclick="addDeptAtOrgMap()" class="btnTypeDefault" style="margin-left: 10px;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFPeriod' /></dt> <!-- 수행기간 -->
						<dd>
							<div id="divCalendar" class="dateSel type02">
								<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> 
								~ 
								<input class="adDate" type="text" id="endDate" date_separator="." readonly="" kind="twindate" date_startTargetID="startDate" >
							</div>	
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFPM' /></dt> <!-- PM -->
						<dd>
							<div style="float: left;">
								<div id="txtPM" class="txtInp autoCompleteCustom" style="display: inline-block;">
									<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
								</div>
								<input type="hidden" id="hidPMCode">
								<input type="hidden" id="hidPMName">
							</div>
							<a onclick="addUserAtOrgMap('PM')" class="btnTypeDefault" style="margin-left: 10px; float: left;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFAdmin' /></dt>
						<dd>
							<div style="float: left;">
								<div id="txtAdmin" class="txtInp autoCompleteCustom" style="display: inline-block;">
									<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
								</div>
								<input type="hidden" id="hidAdminCode">
								<input type="hidden" id="hidAdminName">
							</div>
							<a onclick="addUserAtOrgMap('Admin')" class="btnTypeDefault" style="margin-left: 10px; float: left;"><spring:message code='Cache.btn_OrgMDM' /></a>
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFMember' /></dt> <!-- 팀원 -->
						<dd>
							<div style="float: left;">
								<div id="txtMember" class="txtInp autoCompleteCustom" style="display: inline-block;">
									<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
								</div>
								<input type="hidden" id="hidMemberCode">
								<input type="hidden" id="hidMemberName">
							</div>
							<a onclick="addUserAtOrgMap('Member')" class="btnTypeDefault" style="margin-left: 10px; float: left;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFContent' /></dt> <!-- 추진내용 -->
						<dd>
							<input type="hidden" id="oldtxtContent"/>
							<input type="hidden" id="editChangeNum" value = "N"/>
							
							<div class="txtEdit" id="editChange">
								<textarea id="txtContent" class="HtmlCheckXSS ScriptCheckXSS" maxlength="300"></textarea>
								<p class="editChange"><a href="#" onclick="editChange()"><spring:message code='Cache.lbl_editChange'/></a></p>
							</div>
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_apv_linkdoc' /></dt> <!-- 연결문서 -->
						<dd>
							<div id="docLinksList">
							<a onclick="openDocLinkTF()" class="btnTypeDefault"><spring:message code='Cache.lbl_apv_linkdoc' /></a><!-- 연결문서 -->
							</div>
						</dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_apv_filelist' /></dt> <!-- 첨부파일 -->
						<dd>
							<div id="fileControl"></div>
						</dd>
					</dl>
					<input type="hidden" id="txtTFCode">
					<input type="hidden" id="hidDocLinks">
				</div>
				<div class="popBtnWrap">
					<a href="#" class="btnTypeDefault" onclick="goEdit();"><spring:message code='Cache.lbl_Edit' /></a>
					<a href="#" class="btnTypeDefault" onclick="closePopup();"><spring:message code='Cache.lbl_close' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
	var CU_ID = CFN_GetQueryString("CU_ID");
	
	$(function() {
		// 구분 select box render
		coviCtrl.renderDomainAXSelect('ddlCategory', 'ko', '', '', 'ORGROOT','');
		
		// coviFile.fileInfos 초기화
		coviFile.fileInfos.length = 0; 
		
		// date field render
		coviInput.setDate();
		
		//데이터 세팅
		setData();
	});
	
	function setData() {
		$(".rowTypeWrap").find("dl > dt").attr("style", "font-weight:700 !important");
		$(".txtInp").css("width", "254px");
		$(".adDate").css("width", "30%");
		
		$.ajax({
			type:"POST",
			data:{
				"CU_ID" : CU_ID
			},
			async : false,
			url:"/groupware/layout/selectTFDetailInfo.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.TFInfo != undefined && data.TFInfo.length > 0) {
						var info = data.TFInfo[0];
						
						$("#txtTFCode").val(info.CU_Code);
						$("#spnState").html(info.AppStatusName);
						$("#spnTFName").html(info.CommunityName);
						$("#ddlCategory").bindSelectSetValue(info.TF_DN_ID);

						$("#txtMajorDept").val(info.TF_MajorDept);
						$("#hidMajorDeptCode").val(info.TF_MajorDeptCode);

						$("#startDate").val(info.TF_StartDate);
						$("#endDate").val(info.TF_EndDate);

						setTFUserInfo(info.TF_PM, "PM");
						$("#hidPMCode").val(getTFUserInfo(info.TF_PM, "C"));
						$("#hidPMName").val(getTFUserInfo(info.TF_PM, "N"));

						setTFUserInfo(info.TF_Admin, "Admin");
						$("#hidAdminCode").val(getTFUserInfo(info.TF_Admin, "C"));
						$("#hidAdminName").val(getTFUserInfo(info.TF_Admin, "N"));

						setTFUserInfo(info.TF_Member, "Member");
						$("#hidMemberCode").val(getTFUserInfo(info.TF_Member, "C"));	
						$("#hidMemberName").val(getTFUserInfo(info.TF_Member, "N"));	

						$("#txtContent").val(unescape(info.Description));		
						
						$("#hidDocLinks").val(info.TF_DocLinks);
						G_displaySpnDocLinkInfo();

						if(data.fileList != undefined && data.fileList.length > 0) {
							var fileList = JSON.parse(JSON.stringify(data.fileList));
							coviFile.renderFileControl('fileControl', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
						} else {
							coviFile.renderFileControl('fileControl', {listStyle:'table', actionButton :'add', multiple : 'true'});
						}
					} 
				}			
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/layout/selectTFDetailInfo.do", response, status, error);
			}
		});
	}
	
	function getTFUserInfo(data, type) {
		var result = "";
		var data = data.split("@");
		
		var index = 0;
		var sep = ";";
		if(type == "N"){
			index = 1;
			sep = ",";
		}
		
		for(var i = 0; i < data.length; i++) {
			if(data[i] != "") {
				var temp = data[i];
				result += temp.split("|")[index] + sep;
			}
		}
		
		if(result.length > 0) {
			result = result.substring(0, result.length-1);
		}
		
		return result;
	}
	
	function setTFUserInfo(data, userType){
		if(data != null && data != ""){
			$.each(data.split("@"), function(idx, item){
				var userCode = item.split("|")[0];
				var userName = item.split("|")[1];
				var memberObj = $("<div></div>")
			    .addClass("ui-autocomplete-multiselect-item")
			    .attr("data-json", JSON.stringify({"UserCode":userCode,"UserName":userName,"label":userName,"value":userCode}))
			    .attr("data-value", userCode)
			    .text(userName)
			    .append(
			        $("<span></span>")
			            .addClass("ui-icon ui-icon-close")
			            .click(function(){
			            	var userCodes = $("#hid"+userType+"Code").val().split(";");
			            	var userNames = $("#hid"+userType+"Name").val().split(",");
			            	var json = JSON.parse($(this).parent().attr("data-json"));
			            	userCodes = $.grep(userCodes, function(userCodes) {
		            			return userCodes != json.UserCode;
		            		});
			            	userNames = $.grep(userNames, function(userNames) {
		            			return userNames != json.UserName;
		            		});
			            	$("#hid"+userType+"Code").val(userCodes.join(";"));
			            	$("#hid"+userType+"Name").val(userNames.join(","));
			                var item = $(this).parent();
			                item.remove();
			            })
			    );
				$("#txt"+userType+" div").eq(0).append($(memberObj));
			});
		}
	}
	
	function addDeptAtOrgMap() {
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=deptAdd_CallBack&type=D1&openerID=TFInfo"+CU_ID,"1060px","580px","iframe",true,null,null,true);
	}

	function deptAdd_CallBack(orgData) {
		var deptJSON =  $.parseJSON(orgData).item[0];
		var deptCode = deptJSON.GroupCode;
		var deptName = CFN_GetDicInfo(deptJSON.GroupName);
		
	  	$("#txtMajorDept").val(deptName);
		$("#hidMajorDeptCode").val(deptCode);
	}

	var userType = "";
	function addUserAtOrgMap(level) {
		userType = level;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=userAdd_CallBack&type=B9&openerID=TFInfo"+CU_ID,"1060px","580px","iframe",true,null,null,true);
	}

	function userAdd_CallBack(orgData){
		var userJSON =  $.parseJSON(orgData);
		var lang = Common.getSession("lang");
		
		var userCode = $("#hid"+userType+"Code").val();
		if(userCode != "") userCode += ";";
		
		var userName = $("#hid"+userType+"Name").val();
		if(userName != "") userName += ",";
		
		$(userJSON.item).each(function (i, item) {
	  		sObjectType = item.itemType;
	  		if(sObjectType.toUpperCase() == "USER"){ //사용자
	  			if($("#hid"+userType+"Code").val().indexOf(item.UserCode) < 0) { //기존에 추가된 사용자 중복 추가 방지
		  			var urName = CFN_GetDicInfo(item.DN, lang);
		  			userCode += item.UserCode+";";
		  			userName += urName+",";
		  			var memberObj = $("<div></div>")
		            .addClass("ui-autocomplete-multiselect-item")
		            .attr("data-json", JSON.stringify({"UserCode":item.UserCode,"UserName":urName,"label":urName,"value":item.UserCode}))
		            .attr("data-value", userCode)
		            .text(urName)
		            .append(
		                $("<span></span>")
		                    .addClass("ui-icon ui-icon-close")
		                    .click(function(){
		                    	var userCodes = $("#hid"+userType+"Code").val().split(";");
		    	            	var userNames = $("#hid"+userType+"Name").val().split(",");
		    	            	var json = JSON.parse($(this).parent().attr("data-json"));
		    	            	userCodes = $.grep(userCodes, function(userCodes) {
		                			return userCodes != json.UserCode;
		                		});
		    	            	userNames = $.grep(userNames, function(userNames) {
		                			return userNames != json.UserName;
		                		});
		    	            	$("#hid"+userType+"Code").val(userCodes.join(";"));
		    	            	$("#hid"+userType+"Name").val(userNames.join(","));
		    	                var item = $(this).parent();
		    	                item.remove();
		                    })
		            );
					$("#txt"+userType+" div").eq(0).append($(memberObj));
	  			}else{
	  				Common.Warning("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
	  			}
	  		}
	 	});
	 	
	 	if(userCode.length > 0){
	 		userCode = userCode.substring(0, userCode.length-1);
		}
	 	
	 	if(userName.length > 0){
	 		userName = userName.substring(0, userName.length-1);
		}
	 	
		$("#hid"+userType+"Code").val(userCode);
		$("#hid"+userType+"Name").val(userName);
	}

	function editChange(type){
		$("#editChangeNum").val("Y");
		$("#oldtxtContent").val($("#txtContent").val());
		coviEditor.loadEditor(
			'editChange',
			{
				editorType : g_editorKind,
				containerID : 'edit',
				frameHeight : '311',
				focusObjID : '', 
				onLoad: function() {
					coviEditor.setBody(g_editorKind, 'edit', $("#oldtxtContent").val());
				}
			}
		);
	}
	
	function goEdit(){
		
		var txtContent = "";
		var txtContentEditer = "";
		var txtContentInlineImage = "";
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if($("#editChangeNum").val() == "N"){
			txtContent = $("#txtContent").val();
			txtContentEditer = $("#txtContent").val();
			txtContentInlineImage = "";
		}else{
			txtContent = coviEditor.getBodyText(g_editorKind, 'edit');
			txtContentEditer = coviEditor.getBody(g_editorKind, 'edit');
			txtContentInlineImage = coviEditor.getImages(g_editorKind, 'edit');
		}
		
		txtContent = escape(txtContent);
		txtContentEditer = escape(txtContentEditer);
					
		if($("#txtMajorDept").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_fillHeadDept'/>"); //주관부서를 선택해주세요.
			return ;
		}
		
		if($("#startDate").val() == "" || $("#endDate").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_fillPeriod'/>"); //수행기간을 입력해주세요.
			return ;
		}
		
		if($("#txtPM div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillPM'/>"); //PM을 선택해주세요.
			return ;
		}
		
		if($("#txtAdmin div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillViewer'/>"); //간사를 선택해주세요.
			return ;
		}
		
		if($("#txtMember div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillMember'/>"); //팀원을 선택해주세요.
			return ;
		}
		
		if(txtContent == ""){
			Common.Warning("<spring:message code='Cache.msg_fillTfContent'/>"); //추진내용을 입력해주세요.
			return ;
		}
		
		//PM, 간사, 팀원 중복 체크
        var Code = "";
        var CompareCode1 = "";
        var CompareCode2 = "";
        var Result = true;
        
        Code = $("#hidPMCode").val().split(";");
        CompareCode1 = $("#hidAdminCode").val().split(";");
        CompareCode2 = $("#hidMemberCode").val().split(";");
        for (i = 0; i < Code.length; i++) {
            for (j = 0; j < CompareCode1.length; j++) {
                if (Code[i] == CompareCode1[j]) {
                    Result = false;
                }
            }
            for (k = 0; k < CompareCode2.length; k++) {
                if (Code[i] == CompareCode2[k]) {
                    Result = false;
                }
            }
        }
        
        for (i = 0; i < CompareCode1.length; i++) {
            for (j = 0; j < CompareCode2.length; j++) {
                if (CompareCode1[i] == CompareCode2[j]) {
                    Result = false;
                }
            }
        }

        if (!Result) {
            Common.Warning("<spring:message code='Cache.msg_MemberOverlap'/>"); //팀원이 중복되었습니다.
            return false;
        }
		
		
		var formData = new FormData();
		
		formData.append("CU_ID", CU_ID);
		formData.append("Category", $("#ddlCategory").val());
		formData.append("txtTFCode", $("#txtTFCode").val());
		
		formData.append("txtMajorDeptCode", $("#hidMajorDeptCode").val());
		formData.append("txtMajorDept", $("#txtMajorDept").val());
		
		formData.append("txtStart",  $("#startDate").val());
		formData.append("txtEnd",  $("#endDate").val());
		
		formData.append("txtPMCount", $("#hidPMCode").val().split(";").length);
		formData.append("txtPMCode", $("#hidPMCode").val());
		formData.append("txtPM", $("#hidPMName").val());
		
		formData.append("txtAdminCount", $("#hidAdminCode").val().split(";").length);
		formData.append("txtAdminCode", $("#hidAdminCode").val());
		formData.append("txtAdmin", $("#hidAdminName").val());
		
		formData.append("txtMemberCount", $("#hidMemberCode").val().split(";").length);
		formData.append("txtMemberCode", $("#hidMemberCode").val());
		formData.append("txtMember", $("#hidMemberName").val());
		
		formData.append("txtDocLinks", $("#hidDocLinks").val());	
		
		formData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage").replace("{0}", Common.getSession("DN_Code"))));
		formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
	    for (var i = 0; i < coviFile.files.length; i++) {
	    	if (typeof coviFile.files[i] == 'object') {
	    		formData.append("files", coviFile.files[i]);
	        }
	    }
	    formData.append("fileCnt", coviFile.fileInfos.length);
		
		formData.append("txtContentSize", txtContent.length);
		formData.append("txtContent", txtContent); //Description
		formData.append("txtContentEditer", txtContentEditer); //DescriptionEditor
		formData.append("txtContentInlineImage", txtContentInlineImage); //DescriptionInlineImage
		formData.append("ContentOption", $("#editChangeNum").val()); //DescriptionOption
		
		var confirmMessage = "<spring:message code='Cache.msg_RUEdit'/>"; //수정하시겠습니까?
		var url = "/groupware/layout/updateTFTeamRoom.do";
		var successMessage = "<spring:message code='Cache.msg_Edited'/>"; //수정되었습니다
		var gotoUrl = '/groupware/layout/TF_TFMyList.do?CLSYS=TF&CLMD=user&CLBIZ=TF'; 
		
		Common.Confirm(confirmMessage, "Confirmation Dialog", function (confirmResult) { 
			if (confirmResult) {
				$.ajax({
					url:url,
					type:"post",
					data:formData,
					dataType:'json',
					processData:false,
					contentType:false,
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform(successMessage);
							parent.selectMyTFList();
							Common.Close();
						}else{ 
							Common.Warning("<spring:message code='Cache.msg_38'/>");
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(url, response, status, error); 
					}
				}); 
			}
		});
	}
	
	function closePopup() {
		Common.Close();
	}
	/*연결문서 시작 */
	 function openDocLinkTF(){
		var iWidth = 840; iHeight = 660; sSize = "fix";
	
	   var sUrl = "/approval/goDocListSelectPage.do";		//"/WebSite/Approval/DocList/DocListSelect.aspx";
	   CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
	}	
	function InputDocLinks(szValue) {
	    try {
	        if (document.getElementById("hidDocLinks").value == "") {
	            document.getElementById("hidDocLinks").value = szValue; G_displaySpnDocLinkInfo();
	        }
	        else {
	            adddocitem(szValue);
	        }
	    }
	    catch (e) {coviCmn.traceLog(e);
	    }
	}
	function adddocitem(szAddDocLinks) {
	    var adoclinks = document.getElementById("hidDocLinks").value.split("^^^");
	    var aadddoclinks = szAddDocLinks.split("^^^");
	    var szdoclinksinfo = "";

	    var tmp = "";
	    for (var i = 0; i < aadddoclinks.length; i++) {
	        if (aadddoclinks[i] != null) {
	            var bexitdoclinks = false;
	            for (var j = 0; j < adoclinks.length; j++) { if (aadddoclinks[i] == adoclinks[j]) { bexitdoclinks = true; } }
	            if (!bexitdoclinks) adoclinks[adoclinks.length] = aadddoclinks[i];
	        }
	    }

	    for (var k = 0; k < adoclinks.length; k++) {
	        if (adoclinks[k] != null) {
	            if (szdoclinksinfo != "") {
	                szdoclinksinfo += "^^^" + adoclinks[k];
	            } else {
	                szdoclinksinfo += adoclinks[k];
	            }
	        }
	    }
	    document.getElementById("hidDocLinks").value = szdoclinksinfo;
	    G_displaySpnDocLinkInfo();
	}
	function deleteDocLinkTF() {
	    var adoclinks = document.getElementById("hidDocLinks").value.split("^^^");
	    var szdoclinksinfo = "";
	    var chkDoc = $("#docLinksList .td_check");
	    var tmp = "";
	    if (chkDoc.length > 0) {
	        chkDoc.each(function (i, elm) {
	            if ($(elm).is(":checked")) {
	                tmp = $(elm)[0].value;
	                for (var j = adoclinks.length - 1; j >= 0; j--) {
	                    if (adoclinks[j] != null && adoclinks[j].indexOf(tmp) > -1) {
	                        adoclinks[j] = null;
	                    }
	                }
	            }
	        });
	    }
	    for (var i = 0; i < adoclinks.length; i++) {
	        if (adoclinks[i] != null) {
	            if (szdoclinksinfo != "") {
	                szdoclinksinfo += "^^^" + adoclinks[i];
	            } else {
	                szdoclinksinfo += adoclinks[i];
	            }
	        }
	    }
	    document.getElementById("hidDocLinks").value = szdoclinksinfo;
	    G_displaySpnDocLinkInfo();
	}
	function G_displaySpnDocLinkInfo() {//수정본
	    var szdoclinksinfo = "";
	    var szdoclinks =  $("#hidDocLinks").val();
	    szdoclinks = szdoclinks.replace("undefined^", "");
	    szdoclinks = szdoclinks.replace("undefined", "");
	    var bEdit = false; 
	    var bDisplayOnly = true;
	    if (document.location.href.indexOf("Info.") > -1 || document.location.href.indexOf("InfoViewPopup.") > -1) {
	        bEdit = false;
	    } else {
	        bEdit = true;bDisplayOnly=false;
	    }
       if (bEdit) {
          	szdoclinksinfo += "<a onclick='openDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_linkdoc' />"+"</a>";
          	szdoclinksinfo += "&nbsp;<a onclick='deleteDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_link_delete' />"+"</a><br />";
       }
	    if (szdoclinks != "") {
	        var adoclinks = szdoclinks.split("^^^");
	        for (var i = 0; i < adoclinks.length; i++) {

	            var adoc = adoclinks[i].split("@@@");
	            var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
	            var iWidth = 790;
	            var iHeight = window.screen.height - 82;
	            if (bEdit) {
	                    szdoclinksinfo += "<input type='checkbox' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
	                    szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
	                    szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
	                    szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
	            } else {
	                if (bDisplayOnly) {
	                    szdoclinksinfo += adoc[2];
	                } else {
	                    szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
	                    szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
	                    szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
	                }
	            }
	        }
	    }
	    $("#docLinksList").html(szdoclinksinfo);
	}
	/*연결문서 끝*/	
</script>