<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var isUseSB = Common.getBaseConfig("IsUseStandardBrief");

	var mode = CFN_GetQueryString("mode");
	var entCode = CFN_GetQueryString("entCode");
	var type = CFN_GetQueryString("type"); //시스템 타입 (APPROVAL, ACCOUNT ...)
    var depth = CFN_GetQueryString("depth");//선택한 node depth
	
	var jsonData = $.parseJSON(Base64.b64_to_utf8(decodeURIComponent(CFN_GetQueryString("data"))));
	var itemId = jsonData.itemId;
	var itemName = jsonData.itemName;
	var upperItemId = jsonData.upperItemId;
	var docKind = jsonData.docKind;
	var itemDesc = jsonData.itemDesc;
	var itemType = jsonData.itemType;
	var itemCode = jsonData.itemCode;
	var upperItemCode = jsonData.upperItemCode; 
	var sortnum = jsonData.sortnum;
 
	
	$(document).ready(function() {
		init();		// 초기화
	});

	// 초기화
	function init() {		
		$("#itemType").find("option").remove();
		var tmpType = Common.getBaseCode("JobFunctionType").CacheData;
		if(tmpType && tmpType.length > 0){
			for(var i=0;i<tmpType.length;i++){
				$("#itemType").append("<option value='" + tmpType[i].Code + "'>" + CFN_GetDicInfo(tmpType[i].MultiCodeName) + "</option>");
			}
		}
		
		if(Common.getBaseConfig("UseRuleManageExcel") == "Y"){
			setCodeContext(upperItemCode,itemCode,depth,mode);
			$("#trCode").hide();
			$("#trCode2").show();		
		}
		else{
			$("#trCode").show();
			$("#trCode2").hide();
		}
			
		$("#itemType").change(function(){
			switch($("#itemType").val()){
				case "APPROVAL":
					$("#AccountInfo").hide();
					$("#AccountInfo").find("#GroupList input").each(function(){$(this).parent().remove();});
					$("#AccountInfo").find("input[type='text']").each(function(){$(this).val("");});
					type = "APPROVAL";
					break;
				case "ACCOUNT":
					$("#AccountInfo").show();
					type = "ACCOUNT";
					break;
			}
		});
		
		if(type == "ACCOUNT") {
			$("#AccountInfo").show();
			$("#itemType").val(type);
			$("#itemType").attr("disabled",true);
			if(isUseSB == "N") {
				$("tr[name=StandardBriefArea]").hide();
			} else {
				$("#AccountCode").siblings("input[type=button]").hide();
			}
		}
		
		// 넘어온 데이터 처리, 버튼
		if (mode == "add") {
			$("#updBtn").css("display", "none");
			$("#delBtn").css("display", "none");
			$("#upperItemCode").val(upperItemCode);
			$("#upperItemCode").prop("readonly", true);
		} else if (mode == "upd") {
			$("#itemName").val(itemName);
			$("#docKind").val(docKind);
			$("#itemDesc").val(itemDesc);
			$("#itemType").val(itemType);
			$("#itemCode").val(itemCode);
			$("#itemCode").prop("readonly", true);
			$("#itemSort").val(sortnum);
			$("#upperItemCode").val(upperItemCode);
			$("#upperItemCode").prop("readonly", true);
			
			if(type == "ACCOUNT") {
				$.ajax({
					type:"POST",
					url:"/approval/manage/getItemMoreInfo.do",
					data:{
						itemCode : itemCode,
						entCode : entCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							var item = data.list[0];
							
							$("#AccountCode").val(item.AccountCode);
							$("#AccountName").val(item.AccountName);
							if(isUseSB == "Y") {
								$("#StandardBriefID").val(item.StandardBriefID);
								$("#StandardBriefName").val(item.StandardBriefName);
							}
							
							var grCDArr = item.GroupCode.split("||");
							var grNMArr = item.GroupName.split("||");
							for(var i = 0; i < grCDArr.length; i++) {
								if(grCDArr[i] != "") {
									addGroup(grCDArr[i], grNMArr[i]);
								}
							}
							
							$("input[name=RuleMaxAmount]").parent().parent().hide();
							$("#RuleMaxAmount1").parent().siblings("th").text("<spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>");
							$("#RuleMaxAmount1").parent().parent().show();
							if(item.MaxAmount.split(".")[0] != "0") {
								$("#RuleMaxAmount1").val(CFN_AddComma(item.MaxAmount.split(".")[0])); //.0000 지우기
							}
						}
						else{
							parent.Common.Error(data);
						}
					},
					error:function (error){
						parent.Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			}
			
			$("#addBtn").css("display", "none");
		}
	}
	
	
	function getNextItemCode(upperItemCode,depth){
		var nextCode = 0; 
		var sDepth = parseInt(depth)+1;
		
		$.ajax({
			type:"POST",
			url:"/approval/manage/getNextItemCode.do",
			data:{
				upperItemCode : upperItemCode,
				depth : sDepth,
				entCode : entCode
			},
			async:false,
			success:function (data) {
				if(data.result == "ok"){
					var item;
					if(data.list[0] == undefined){
						nextCode = "none"
					}
					else{
						item = data.list[0].NextItemCode;
						nextCode = parseInt(item);
						if(nextCode<10) nextCode = "0"+nextCode;
					}								 
				}
				else{
					parent.Common.Error(data);
				}
			},
			error:function (error){
				parent.Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
			}
		});
		
		return nextCode;
	}
	
	// 추가 버튼
	function clickBtn(btn) {
		var text = "";
		var params = new Object();
		var url = "";		
		var itemCode = "";
		
		if(Common.getBaseConfig("UseRuleManageExcel")=="Y"){
			itemCode = $('#code01').val() + $('#code02').val() + $('#code03').val() + $('#code04').val() + $('#code05').val();
		}
		else{
			itemCode = $("#itemCode").val();
		}
		
		if(itemCode == ""){//코드 필수입력
			alert("<spring:message code='Cache.msg_RuleManage_01' />")
			return;
		}
		
		params.itemId = itemId;
		params.itemCode = itemCode;//ItemCode 추가	

		if($("#itemName").val()==""){//명칭 필수입력
			alert("<spring:message code='Cache.msg_RuleManage_02' />")
			return;
		}

		if($("#itemSort").val()==""){
			$("#itemSort").val("0");
		}
		
		
		if(btn == "add" || btn == "upd") {
			params.entCode = entCode;
			params.upperItemId = upperItemId;		
			params.itemType = $("#itemType").val();
			params.itemName = $("#itemName").val();
			params.docKind = $("#docKind").val();
			params.itemDesc = $("#itemDesc").val();
			params.itemType = $("#itemType").val();
			params.sortnum = $("#itemSort").val();
			params.upperItemCode = upperItemCode;
			params.type = type;
			
			if(type == "ACCOUNT") {				
				var strGroupCode = "";
				var strGroupName = "";
				$("input[name=GroupCode]").each(function(i) {
					strGroupCode += $("input[name=GroupCode]").eq(i).val() + "||";
					strGroupName += $("input[name=GroupName]").eq(i).val() + "||";
				});
				strGroupCode = strGroupCode.substring(0, strGroupCode.length-2);
				strGroupName = strGroupName.substring(0, strGroupName.length-2);
				
				var strMaxAmount = "";
				$("input[name=RuleMaxAmount]").each(function(i, obj) {
					if($(obj).val() != "") {
						strMaxAmount += $(obj).val().replace(/,/gi, '') + ";";
					}
				});
				strMaxAmount = strMaxAmount.substring(0, strMaxAmount.length-1);
				
				params.AccountCode = $("#AccountCode").val();
				params.AccountName = $("#AccountName").val();
				params.StandardBriefID = $("#StandardBriefID").val();
				params.StandardBriefName = $("#StandardBriefName").val();
				params.GroupCode = strGroupCode;
				params.GroupName = strGroupName;
				params.MaxAmount = strMaxAmount;
			}
		}
		
		if (btn == "add") {
			text = "<spring:message code='Cache.msg_RURegist'/>";
			url = "insertRuleTree.do";
		} else if (btn == "upd") {
			text = "<spring:message code='Cache.msg_apv_294'/>";
			url = "updateRuleTree.do";
		} else {
			text = "<spring:message code='Cache.apv_msg_rule02'/>";
			url = "deleteRuleTree.do";
		}
		
		parent.Common.Confirm(text, "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : url,
					success:function (data) {
						if(data.result == "ok") {
							Common.Close();
							parent.setTree();
						} else {
							parent.Common.Error(data.message);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}

	// 팝업 닫기
	function closeLayer() {
		Common.Close();
		//parent.search();
	}

	function SelectPopup_Open(target) {
		var popupID = popupTit = width = height = "";
		
		if(target == "Account") {
			popupID		=	"accountSearchPopup";
			popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
			width = "740px"; height = "690px";
		} else if(target == "StandardBrief") {
			popupID		=	"standardBriefSearchPopup";
			popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//계정과목
			width = "1000px"; height = "700px";
		}
		
		var url = "/account/accountCommon/accountCommonPopup.do?popupID="+popupID+"&popupName="+target+"SearchPopup&openerID=manageTreeItem&callBackFunc=callBackSelectPopup&popupYN=Y";
		parent.Common.open(	"",popupID,popupTit,url,width,height,"iframe",true,null,null,true);
	}
	
	parent.callBackSelectPopup = callBackSelectPopup;
	function callBackSelectPopup(value) {
		$("#AccountCode").val(value.AccountCode);
		$("#AccountName").val(value.AccountName);
		$("#itemName").val(value.AccountName);
		$("#itemDesc").val(value.AccountName);
		if(isUseSB == "Y") {
			$("#StandardBriefID").val(value.StandardBriefID);
			$("#StandardBriefName").val(value.StandardBriefName);
			$("#itemName").val(value.StandardBriefName);
			$("#itemDesc").val(value.StandardBriefName);
		}
	}
	
	function OrgMap_Open() {
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C9","1060px","580px","iframe",true,null,null,true);
	}
	
	parent._CallBackMethod2 = setGroupList;
	function setGroupList(groupValue){		
	    var dataObj = $.parseJSON(groupValue);			
		if(dataObj.item.length > 0){			
			$(dataObj.item).each(function(i){	
				//기존리스트에 포함되어있는지 확인
                if($("input[name='chkdept'][value='" + dataObj.item[i].AN + "']").length > 0){
                	parent.Common.Warning(dataObj.item[i].DN+"(" + dataObj.item[i].AN + ")"+"<spring:message code='Cache.msg_AlreadyAdd' />");		//은(는) 이미 추가 되었습니다
                	return;
                }
                addGroup(dataObj.item[i].AN, dataObj.item[i].DN);
			});
		}
	}
	
	function addGroup(GroupCode, GroupName) {
		$("#GroupList").append("<div><input type='checkbox' name='GroupCode' id='chk_"+GroupCode+"' value='"+GroupCode+"'> "
			+"<input type='hidden' name='GroupName' id='hid_"+GroupCode+"' value='"+GroupName+"'> "
			+"<label for='chk_"+GroupCode+"'>"+CFN_GetDicInfo(GroupName)+"("+GroupCode+")</label></div>");
	}

	function delGroup() {
		$("#GroupList input:checked").each(function() {
			$(this).parent().remove();
		});
	}
	
	function onSetNum(obj){
		var me = this;
		var objVal = obj.value;
		var objVal = objVal.replace(/[^0-9,-.]/g, "");
		obj.value = objVal;
	} 
	
	function AddInputComma(obj) {
        obj.value = CFN_AddComma(obj.value);
    }
	
	function setCodeContext(sUpperItemCode,itemCode,depth,mode) {
	    var nCodeAll = 99;
        var codetmp ='';     
        var resusultTmp= '';
        var resusult1= '';
        var resusult2= '';
        var resusult3= '';
        var resusult4= '';
        var resusult5= '';  
        
        if(mode =="add" && depth>=5){
        	alert("<spring:message code='Cache.msg_RuleManage_02' />");//5 depth 이상은 추가할 수 없습니다.
        	Common.Close();
        	return;
        }
        
        
        if(mode =="add"){
        	 resusultTmp = getNextItemCode(sUpperItemCode,depth);
        	 if(resusultTmp=="none")resusultTmp = '01';

        	 if(depth==0)resusult1 = resusultTmp;
        	 else resusult1 = sUpperItemCode.substr(0, 2);
        	 
        	 if(depth==1)resusult2 = resusultTmp;
        	 else resusult2= sUpperItemCode.substr(2, 2);
        	 
        	 if(depth==2)resusult3 = resusultTmp;
        	 else resusult3= sUpperItemCode.substr(4, 2);
        	 
        	 if(depth==3)resusult4 = resusultTmp;
        	 else resusult4= sUpperItemCode.substr(6, 2);   
        	 
        	 if(depth==4)resusult5 = resusultTmp;
        	 else resusult5= sUpperItemCode.substr(8, 2);         	 
 
        }
        else{
            resusult1= itemCode.substr(0, 2);
            resusult2= itemCode.substr(2, 2);
            resusult3= itemCode.substr(4, 2);
            resusult4= itemCode.substr(6, 2);
            resusult5= itemCode.substr(8, 2);   
        } 
        
	    for(var i = 0 ; i <= nCodeAll ; i++) {
	    	if(i<10)codetmp= '0'+i;
	    	else codetmp= i;
	    	
	    	
	    	if(resusult1==codetmp){
	    		$('#code01').append('<option value="' + codetmp + '" selected>' + codetmp + '</option>');
	    	}
	    	else{
	    		$('#code01').append('<option value="' + codetmp + '" >' + codetmp + '</option>');
	    	}
	    	
	    	if(resusult2==codetmp){
	    		$('#code02').append('<option value="' + codetmp + '" selected>' + codetmp + '</option>');
	    	}
	    	else{
	    		$('#code02').append('<option value="' + codetmp + '" >' + codetmp + '</option>');
	    	}
	    	
	    	if(resusult3==codetmp){
	    		$('#code03').append('<option value="' + codetmp + '" selected>' + codetmp + '</option>');
	    	}
	    	else{
	    		$('#code03').append('<option value="' + codetmp + '" >' + codetmp + '</option>');
	    	}
	    	
	    	if(resusult4==codetmp){
	    		$('#code04').append('<option value="' + codetmp + '" selected>' + codetmp + '</option>');
	    	}
	    	else{
	    		$('#code04').append('<option value="' + codetmp + '" >' + codetmp + '</option>');
	    	}
	    	
	    	if(resusult5==codetmp){
	    		$('#code05').append('<option value="' + codetmp + '" selected>' + codetmp + '</option>');
	    	}
	    	else{
	    		$('#code05').append('<option value="' + codetmp + '" >' + codetmp + '</option>');
	    	} 
	    }
	    
		$("#code01").attr("disabled", "disabled");
		$("#code02").attr("disabled", "disabled");
		$("#code03").attr("disabled", "disabled");
		$("#code04").attr("disabled", "disabled");
		$("#code05").attr("disabled", "disabled");
	    
	}
</script>
<form>
	<div class="sadmin_pop">
		<div>
			<table class="sadmin_table sa_menuBasicSetting mb20">
			  <tbody>
			    <tr>
			      <th style="width:150px;"><span style="color:red">*</span><spring:message code='Cache.lbl_upper_Codes'/></th>
				  <td><input id="upperItemCode" name="upperItemCode" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>				  
			    <tr id="trCode">
			      <th style="width:150px;"><span style="color:red">*</span><spring:message code='Cache.lbl_Codes'/></th>
				  <td><input id="itemCode" name="itemCode" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>
			    <tr id="trCode2">
					<th style="width:150px;"><span style="color:red">*</span><spring:message code='Cache.lbl_Codes'/></th>					
					<td>
						<select id="code01" style="width: 40px" >
						</select>
						<select id="code02" style="width: 40px" >
						</select>
						<select id="code03" style="width: 40px" >
						</select>
						<select id="code04" style="width: 40px" >
						</select>
						<select id="code05" style="width: 40px" >
						</select>												
					</td>			    
			    </tr>			  
			    <tr>
			      <th style="width:150px;"><span style="color:red">*</span><spring:message code='Cache.lbl_apv_Name'/></th>
				  <td><input id="itemName" name="itemName" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.lbl_apv_desc'/></th>
				  <td><input id="itemDesc" name="itemDesc" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.lbl_apv_DocboxFolder'/></th>
				  <td><input id="docKind" name="docKind" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>	
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.lbl_BizSection'/></th>
				  <td><select id="itemType" name="itemType" class="selectType02 w200p"></select></td>
			    </tr>	
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_sortOrder'/></th>
				  <td><input id="itemSort" name="itemSort" class="" type="number" maxlength="64" style="width:100px;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"/></td>
			    </tr>			    	    
		      </tbody>
			</table>
			<table class="sadmin_table sa_menuBasicSetting mb20" id="AccountInfo" style="margin-top: 10px; display:none;">
			  <tbody>
			    <tr name="AccountArea">
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_accountCode'/></th>
				  <td>
				  	<input id="AccountCode" name="AccountCode" class="" type="text" style="width:200px;" readonly="readonly"/>
				  	<a href="#" class="btnTypeDefault" onclick="SelectPopup_Open('Account');"><spring:message code='Cache.lbl_Select'/></a>
				  </td>
			    </tr>
			    <tr name="AccountArea">
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_accountName'/></th>
				  <td><input id="AccountName" name="AccountName" class="" type="text" style="width:200px;" readonly="readonly"/></td>
			    </tr>
			    <tr name="StandardBriefArea">
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_standardBriefID'/></th>
				  <td>
				  	<input id="StandardBriefID" name="StandardBriefID" class="" type="text" style="width:200px;" readonly="readonly"/>
				  	<a href="#" class="btnTypeDefault" onclick="SelectPopup_Open('StandardBrief');"><spring:message code='Cache.lbl_Select'/></a>
				  </td>
			    </tr>
			    <tr name="StandardBriefArea">
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_standardBriefName'/></th>
				  <td><input id="StandardBriefName" name="StandardBriefName" class="" type="text" style="width:200px;" readonly="readonly"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_dept'/></th>
				  <td>
				  	<a href="#" class="btnTypeDefault" onclick="OrgMap_Open();"><spring:message code='Cache.lbl_Select'/></a>
				  	<a href="#" class="btnTypeDefault" onclick="delGroup();"><spring:message code='Cache.lbl_delete'/></a>
				  	<div style="margin-top: 5px;" id="GroupList"></div>
				  </td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>1</th>
				  <td><input id="RuleMaxAmount1" name="RuleMaxAmount" class="" type="text" style="width:200px; text-align:right;" onkeyup="onSetNum(this);AddInputComma(this);"/></td>
			    </tr>	
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>2</th>
				  <td><input id="RuleMaxAmount2" name="RuleMaxAmount" class="" type="text" style="width:200px; text-align:right;" onkeyup="onSetNum(this);AddInputComma(this);"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>3</th>
				  <td><input id="RuleMaxAmount3" name="RuleMaxAmount" class="" type="text" style="width:200px; text-align:right;" onkeyup="onSetNum(this);AddInputComma(this);"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>4</th>
				  <td><input id="RuleMaxAmount4" name="RuleMaxAmount" class="" type="text" style="width:200px; text-align:right;" onkeyup="onSetNum(this);AddInputComma(this);"/></td>
			    </tr>
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.ACC_lbl_ruleMaxAmount'/>5</th>
				  <td><input id="RuleMaxAmount5" name="RuleMaxAmount" class="" type="text" style="width:200px; text-align:right;" onkeyup="onSetNum(this);AddInputComma(this);"/></td>
			    </tr>		    
		      </tbody>
			</table>
		</div>
		<div class="bottomBtnWrap">
			<a id="addBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="clickBtn('add');" ><spring:message code="Cache.btn_apv_add"/></a>
			<a id="updBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="clickBtn('upd');" ><spring:message code="Cache.btn_apv_update"/></a>
			<a id="delBtn" href="#" class="btnTypeDefault" onclick="clickBtn('del');"><spring:message code="Cache.btn_apv_delete"/></a>
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
	</div>
</form>