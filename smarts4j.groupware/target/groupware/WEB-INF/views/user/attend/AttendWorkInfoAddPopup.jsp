<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;">
	<div class="ATMgt_popup_wrap">
		<ul class="tabMenu clearFloat">
			<li class="topToggle active"><a href="#"><spring:message code='Cache.lbl_baseInfo'/></a></li>
			<li class="topToggle "><a href="#"><spring:message code='Cache.lbl_n_att_workingRule'/></a></li>
			<li class="topToggle "><a href="#"><spring:message code='Cache.lbl_n_att_workingMaxRule'/></a></li>
		</ul>
		<div class="tabContent active" name="workinfo">
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_DeptOrgMap' /></td>
						<td>
							<div class="ATMgt_T2">
								<div class="ATMgt_T_l">
									<div id="wiUserCode" class="date_del_scroll" style="height:30px; width:180px"></div>
								</div>	
								<div class="ATMgt_T_r">
									<a class="btnTypeDefault nonHover type01" onclick="parent.openOrgMapLayerPopup()">
									<spring:message code='Cache.btn_OrgManage' /></a>
								</div>	
							</div>	
						</td>	
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_workingWeek' /></td>
						<td><div class="day_chk ">
							<span class=""><input type="checkbox" name="workWeekMon" id="workWeekMon" value="1" checked><label><spring:message code='Cache.lbl_WPMon' /></label></span>
							<span class=""><input type="checkbox" name="workWeekTue" id="workWeekTue" value="1" checked><label><spring:message code='Cache.lbl_WPTue' /></label></span>
							<span class=""><input type="checkbox" name="workWeekWed" id="workWeekWed" value="1" checked><label><spring:message code='Cache.lbl_WPWed' /></label></span>
							<span class=""><input type="checkbox" name="workWeekThu" id="workWeekThu" value="1" checked><label><spring:message code='Cache.lbl_WPThu' /></label></span>
							<span class=""><input type="checkbox" name="workWeekFri" id="workWeekFri" value="1" checked><label><spring:message code='Cache.lbl_WPFri' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSat" id="workWeekSat" value="1"><label><spring:message code='Cache.lbl_WPSat' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSun" id="workWeekSun" value="1"><label><spring:message code='Cache.lbl_WPSun' /></label></span>
						</div></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Holiday' />(<spring:message code='Cache.lbl_IHaveOne' />)</td> <!-- 유 -->
						<td><div class="day_chk ">
							<span class=""><input type="checkbox" name="workWeekMon" id="workWeekMon" value="0"><label><spring:message code='Cache.lbl_WPMon' /></label></span>
							<span class=""><input type="checkbox" name="workWeekTue" id="workWeekTue" value="0"><label><spring:message code='Cache.lbl_WPTue' /></label></span>
							<span class=""><input type="checkbox" name="workWeekWed" id="workWeekWed" value="0"><label><spring:message code='Cache.lbl_WPWed' /></label></span>
							<span class=""><input type="checkbox" name="workWeekThu" id="workWeekThu" value="0"><label><spring:message code='Cache.lbl_WPThu' /></label></span>
							<span class=""><input type="checkbox" name="workWeekFri" id="workWeekFri" value="0"><label><spring:message code='Cache.lbl_WPFri' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSat" id="workWeekSat" value="0" checked><label><spring:message code='Cache.lbl_WPSat' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSun" id="workWeekSun" value="0" checked><label><spring:message code='Cache.lbl_WPSun' /></label></span>
						</div></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_sch_holidaySts' />(<spring:message code='Cache.lbl_None' />)</td> <!-- 무 -->
						<td><div class="day_chk ">
							<span class=""><input type="checkbox" name="workWeekMon" id="workWeekMon" value="2"><label><spring:message code='Cache.lbl_WPMon' /></label></span>
							<span class=""><input type="checkbox" name="workWeekTue" id="workWeekTue" value="2"><label><spring:message code='Cache.lbl_WPTue' /></label></span>
							<span class=""><input type="checkbox" name="workWeekWed" id="workWeekWed" value="2"><label><spring:message code='Cache.lbl_WPWed' /></label></span>
							<span class=""><input type="checkbox" name="workWeekThu" id="workWeekThu" value="2"><label><spring:message code='Cache.lbl_WPThu' /></label></span>
							<span class=""><input type="checkbox" name="workWeekFri" id="workWeekFri" value="2"><label><spring:message code='Cache.lbl_WPFri' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSat" id="workWeekSat" value="2"><label><spring:message code='Cache.lbl_WPSat' /></label></span>
							<span class=""><input type="checkbox" name="workWeekSun" id="workWeekSun" value="2"><label><spring:message code='Cache.lbl_WPSun' /></label></span>
						</div></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_applicationPoint' /></td>
						<td>
							<div class="dateSel type02">
							<input type="text" class="adDate" kind="date" date_separator="." id="AXInput-4" data-axbind="date">
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="tabContent" name="workinfo">
			<div class="WRule_Box">
				<table class="WRule_table" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<th><spring:message code='Cache.lbl_n_att_workingHours' /></th>
							<th><spring:message code='Cache.lbl_invoice_unit' /></th>
							<th><spring:message code='Cache.lbl_n_att_unitTime' /></th>
							<th><spring:message code='Cache.lbl_n_att_applyDate' /></th>
						</tr>
					</head>
					<tbody>
						<tr>
							<td><input type="text" id="workTime" class="onlydecimal" value="40"></td>
							<td>
								<div class="WRule_Sel">
									<a href="#" id="workCode" class="btnSelDay workCode"><spring:message code='Cache.btn_Select' /></a>
									<ul class="SelDay_layer"></ul>
								</div>
							</td>
							<td>
								<div class="WRule_Sel">
									<a href="#" id="unitTerm" class="btnSelDay unitTerm"><spring:message code='Cache.btn_Select' /></a>
									<ul class="SelDay_layer"></ul>
								</div>
							</td>
							<td>
								<div class="dateSel type02">
									<input type="text" class="adDate" kind="date" date_separator="." id="AXInput-5" data-axbind="date" disabled>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="tabContent" name="workinfo">
			<div class="WRule_Box" style="height:120px">
				<table class="WRule_table" cellpadding="0" cellspacing="0" >
					<thead>
						<tr>
							<th><spring:message code='Cache.lbl_n_att_workingHours' /></th>
							<th><spring:message code='Cache.lbl_invoice_unit' /></th>
							<th><spring:message code='Cache.lbl_n_att_unitTime' /></th>
							<th><spring:message code='Cache.lbl_n_att_applyDate' /></th>
						</tr>
					</head>
					<tbody>
						<tr>
							<td><input type="text" id="maxWorkTime" class="onlydecimal" maxlength="" value="52"></td>
							<td>
								<div class="WRule_Sel">
									<a href="#" id="maxWorkCode" class="btnSelDay workCode"><spring:message code='Cache.btn_Select' /></a>
									<ul class="SelDay_layer"></ul>
								</div>
							</td>
							<td>
								<div class="WRule_Sel">
									<a href="#" id="maxUnitTerm" class="btnSelDay unitTerm"><spring:message code='Cache.btn_Select' /></a>
									<ul class="SelDay_layer"></ul>
								</div>
							</td>
							<td>
								<div class="dateSel type02">
								<input type="text" class="adDate" kind="date" date_separator="." id="AXInput-6" disabled>
								</div>
							</td>
						</tr>
						<tr>
							<td colspan=2><spring:message code='Cache.CPMail_1Week' /> <spring:message code='Cache.lbl_Mail_Maximum' /> <spring:message code='Cache.lbl_n_att_workingHours' /></Td> <!-- 1주 최대 연장근무시간 -->
							<td><input type="text" id="maxWeekWorkTime" class="onlydecimal" maxlength="" value="52"></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnModify" onclick="modifyWorkInfo();"><spring:message code='Cache.lbl_Modify' /></a>
			<a href="#" class="btnTypeDefault btnTypeChk" id="btnAdd" onclick="addWorkInfo();"><spring:message code='Cache.lbl_Add' /></a>
			<a href="#" class="btnTypeDefault" onclick="parent.Common.close('workInfoPop');"><spring:message code='Cache.lbl_close' /></a>
		</div>
	</div>				
</div>
<style>
/* 화면 깨짐  */
.WRule_table td .WRule_Sel .btnSelDay {width:76px} 
input[type="checkbox"] { display:inline-block; }
</style>
<script type="text/javascript">

	var baseWeek = Common.getBaseConfig('AttBaseWeek');
	$(document).ready(function(){
		init();
	});
	function init() {
		coviInput.setDate();
		
		$(".topToggle").on('click',function(){
			toggleTab($(this));
			coviInput.setDate();
		}); 
		
		$("#AXInput-4").on('change',function(){
			/*mysql db dayofweek function 날짜 동기화*/
			var st = new Date(replaceDate($(this).val())).getDay()+1;
			if(baseWeek!=st){
				Common.Warning("<spring:message code='Cache.msg_n_att_notBaseWeek' />("+baseWeek+":"+st+")");
				$("#AXInput-4").val("");
				return false;
			}

			// 소정근로규칙, 최대근로규칙 적용시점 같게 함.
			$("#AXInput-5").val($("#AXInput-4").val());
			$("#AXInput-6").val($("#AXInput-4").val());
			
		});
		$("#AXInput-5").on('change',function(){
			var ut = $("#unitTerm").data("workvalue");
			if(ut == undefined || ut==""){
				Common.Warning("<spring:message code='Cache.msg_n_att_selectUnitPeriodFirst' />");
				$("#AXInput-5").val("");
				return false;
			}else if( ut.indexOf("week") > -1){
				var st = new Date(replaceDate($(this).val())).getDay()+1;
				if(baseWeek!=st){
					Common.Warning("<spring:message code='Cache.msg_n_att_notBaseWeek' />");
					$("#AXInput-5").val("");
					return false;
				}
			}
		});
		
		$("#AXInput-6").on('change',function(){
			var ut = $("#maxUnitTerm").data("workvalue");
			if(ut == undefined || ut==""){
				Common.Warning("<spring:message code='Cache.msg_n_att_selectUnitPeriodFirst' />");
				$("#AXInput-6").val("");
				return false;
			}else if( ut.indexOf("week") > -1){
				var st = new Date(replaceDate($(this).val())).getDay()+1;
				if(baseWeek!=st){
					Common.Warning("<spring:message code='Cache.msg_n_att_notBaseWeek' />");
					$("#AXInput-6").val("");
					return false;
				}
			}
		});
		
		
		setSelectVal();
		
		$(".btnSelDay").on('click',function(){
			$(this).next(".SelDay_layer").toggle();
		});
		
		 $("input:checkbox").on('click', function(){
			var id =$(this).prop('id');
			var j = $("[id="+id+"]").index(this);  // 존재하는 모든 버튼을 기준으로 index
			if( $(this).prop('checked')){
				$("[id="+id+"]").each(function(index, item){ 
					if (j != index)
						$(this).prop('checked', false)
				})
	 		}
			else{
				j++;
				if (j>=$("[id="+id+"]").length) j=0;
				$("[id="+id+"]").eq(j).prop('checked', true);
			}
	    });
		 

		onlyNumber($(".onlyNum"));
		onlyDecimal($(".onlydecimal"));
		
		if ("${fn:length(result)}" != "0"){
			var orgArray = new Array();
			var orgMap =  new Object();
			var orgData = new Object();
			orgMap.itemType = '${result[0].ListType}';
			orgMap.UserCode= "${result[0].UserCode}";
			orgMap.GroupCode= "${result[0].UserCode}";
			if (orgMap.itemType == "OR"){
				orgMap.DN= "<spring:message code='Cache.lbl_CompanySet' />"+";";	//회사설정
				
			}else{
				orgMap.DN= "${result[0].UserName}"+";";
			}	
			orgArray.push(orgMap);
			orgData.item = orgArray;
			parent.orgMapLayerPopupCallBack( JSON.stringify(orgData));
			$("#workTime").val('${result[0].WorkTime}');
			$("#maxWorkTime").val('${result[0].MaxWorkTime}');
			$("#maxWeekWorkTime").val('${result[0].MaxWeekWorkTime}');
			$("#AXInput-5").val('${result[0].WorkApplyDate}');
			$("#AXInput-6").val('${result[0].MaxWorkApplyDate}');
			$("#AXInput-4").val('${result[0].ApplyDate}');
			
			var cacheWc = parent.Common.getBaseCode("WorkCode").CacheData;
			var cacheUt = parent.Common.getBaseCode("UnitTerm").CacheData;
			for(var i=0;i<cacheWc.length;i++){
				if (cacheWc[i].Code == "${result[0].MaxWorkCode}")
				{
					$("#maxWorkCode").text(cacheUt[i].CodeName);	
					$("#maxWorkCode").data("workvalue",'${result[0].MaxWorkCode}');	
				}
				if (cacheWc[i].Code == "${result[0].WorkCode}")
				{
					$("#workCode").text(cacheUt[i].CodeName);	
					$("#workCode").data("workvalue",'${result[0].WorkCode}');	
				}
			}
			for(var i=0;i<cacheUt.length;i++){
				if (cacheUt[i].Code == "${result[0].MaxUnitTerm}")
				{
					$("#maxUnitTerm").text(cacheUt[i].CodeName);	
					$("#maxUnitTerm").data("workvalue",'${result[0].MaxUnitTerm}');	
				}
				if (cacheUt[i].Code == "${result[0].UnitTerm}")
				{
					$("#unitTerm").text(cacheUt[i].CodeName);	
					$("#unitTerm").data("workvalue",'${result[0].UnitTerm}');	
				}
			}
			var workWeek = '${result[0].WorkWeek}';
			var weekCol = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

			for (var i=0; i < workWeek.length; i++){
				$("input[name='workWeek"+weekCol[i]+"']:input[value='"+workWeek.substring(i,i+1)+"']").prop("checked", true);
				$("input[name='workWeek"+weekCol[i]+"']:input[value!='"+workWeek.substring(i,i+1)+"']").prop("checked", false);
			}
			$("#btnModify").show();
			$("#btnAdd").hide();
			$(".ATMgt_T_r").hide();
			$(".ui-icon-close").hide();
		}
		else{
			$("#btnModify").hide();
			$("#btnAdd").show();

		}
	}

	function toggleTab(o){
		
		$(".topToggle").removeClass("active");
		$(".topToggle").eq(o.index()).addClass("active");

		$("div[name=workinfo]").removeClass("active");
		$("div[name=workinfo]").eq(o.index()).addClass("active");
	}
	
	function setSelectVal(){
		
		$(".SelDay_layer").hide();
		
		var str = ""; 
		var chacheWc = parent.Common.getBaseCode("WorkCode").CacheData;
		for(var i=0;i<chacheWc.length;i++){
			str += "<li><a href='#' onclick='setListVal(this);' data-workvalue='"+chacheWc[i].Code+"'>"+chacheWc[i].CodeName+"</a></li>";
		}
		$(".workCode").next(".SelDay_layer").html(str);
		
		str = ""; 
		var chacheUt = parent.Common.getBaseCode("UnitTerm").CacheData;
		for(var i=0;i<chacheUt.length;i++){
			str += "<li><a href='#' onclick='setListVal(this);' data-workvalue='"+chacheUt[i].Code+"'>"+chacheUt[i].CodeName+"</a></li>";
		}
		$(".unitTerm").next(".SelDay_layer").html(str);
	}
	
	function setListVal(o){
		$(o).parent().parent().prev('.btnSelDay').text($(o).html());
		$(o).parent().parent().prev('.btnSelDay').data("workvalue",$(o).data("workvalue"));
		$(o).parent().parent().hide();
	}
	
	function modifyWorkInfo(){
		saveWorkInfo("updateWorkInfo.do")
		
	}
	function addWorkInfo(){
		saveWorkInfo("insertWorkInfo.do")
	}
	function saveWorkInfo(url){
		
	
		var weekCol = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
		if(validCheck())
		{
			var workWeek = "";		
			for (var i=0; i < weekCol.length;i++)	{
				workWeek+=$("input[name=workWeek"+weekCol[i]+"]:checked").val();
			}
			var params = {
				userInfo :  JSON.stringify(parent.wiUrArry)
				,workWeek :  workWeek
				,applyDate : $("#AXInput-4").val()
				,memo : $("#memo").val()
				,workTime : $("#workTime").val()
				,workCode : $("#workCode").data("workvalue")
				,unitTerm : $("#unitTerm").data("workvalue")
				,workApplyDate : $("#AXInput-5").val()
				
				,maxWorkTime : $("#maxWorkTime").val()
				,maxWorkCode :$("#maxWorkCode").data("workvalue")
				,maxUnitTerm : $("#maxUnitTerm").data("workvalue")
				,maxWorkApplyDate : $("#AXInput-6").val()
				
				,maxWeekWorkTime : $("#maxWeekWorkTime").val()
				,orgApplyDate:"${result[0].ApplyDate}"
			};
		
			Common.Confirm("<spring:message code='Cache.msg_155' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
			 		$.ajax({
						type : "POST",
						dataType : "json",
						data : params,
						url : "/groupware/attendAdmin/"+url,
						success:function (data) {
							if(data.result == 'ok') {
								if(data.status == 'SUCCESS') {
									Common.Inform("<spring:message code='Cache.msg_37' />", "Inform", function() {
										parent.Common.close('workInfoPop');
										parent.search();
									});
				          		} else {
				          			var chkList = data.chkList;
				          			
				          			var chkUser = new Array();
				          			var chkDept = new Array();
				          			for(var i=0;i<chkList.length;i++){
				          				if(chkList[i].ListType == "UR"){
				          					chkUser.push(chkList[i].TargetName);
				          				}else if(chkList[i].ListType == "GR"){
				          					chkDept.push(chkList[i].TargetName);
				          				}
				          			}
				          			
				          			var msgStr = "";
				          			if(chkUser.length>0){
				          				
				          				msgStr += "<spring:message code='Cache.lbl_User' /> : [";
				          				for(var i=0;i<chkUser.length;i++){
				          					if(i!=0){msgStr +=","}
				          					msgStr += chkUser[i];
				          				}
				          				msgStr += "] ";
				          			}
				          			
				          			if(chkDept.length>0){
				          				
				          				msgStr += "<spring:message code='Cache.lbl_dept' /> : [";
				          				for(var i=0;i<chkDept.length;i++){
				          					if(i!=0){msgStr +=","}
				          					msgStr += chkDept[i];
				          				}
				          				msgStr += "]";
				          			}
				          			
				          			Common.Warning(msgStr+" <spring:message code='Cache.msg_n_att_applicationDateDupl' />");
				          		}
							}else{
								Common.Warning("<spring:message code='Cache.msg_apv_030' />");
							}
						},
						error:function(response, status, error) {
							CFN_ErrorAjax("/groupware/attendAdmin/insertWorkInfo.do", response, status, error);
						}
					});		 		
				} else {
					return false;
				}
			});
			
		}
	}
	
	function validCheck(){
		
		var flag = true;
		if(parent.wiUrArry.length == 0 ){
			Common.Warning("<spring:message code='Cache.msg_n_att_selectCandidateForReg' />");
			flag = false;
		}else if($("#AXInput-4").val()==""){
			Common.Warning("<spring:message code='Cache.msg_n_att_selectAppDate' />");
			flag = false;
		}else if($("#workTime").val()==""
					||$("#workCode").data("workvalue")==undefined||$("#workCode").data("workvalue")==""
					||$("#unitTerm").data("workvalue")==undefined||$("#unitTerm").data("workvalue")==""
			){
			Common.Warning("<spring:message code='Cache.msg_n_att_selectFixedWorkRule' />");
			flag = false;
		}else if($("#maxWorkTime").val()==""
					||$("#maxWorkCode").data("workvalue")==undefined||$("#maxWorkCode").data("workvalue")==""
					||$("#maxUnitTerm").data("workvalue")==undefined||$("#maxUnitTerm").data("workvalue")==""
					||$("#maxWeekWorkTime").val()==""
			){
			Common.Warning("<spring:message code='Cache.msg_n_att_selectMaximunWorkRule' />");
			flag = false;
			
		}
		<%--// AXInput-4, 5, 6 값이 동일하지 않을 시 오류. 각각의 컬럼은 다르지만, 실제로 사용될 때는 적용시점이 동일해야 한다. --%>
		else if ( $("#AXInput-4").val() != $("#AXInput-5").val() || $("#AXInput-4").val() != $("#AXInput-6").val() ) {
			Common.Warning("<spring:message code='Cache.msg_checkedDate' />"); 	<%-- // 기간을 다시 확인해주세요. --%>
			flag = false;
		}
		return flag;
	}
	
	//사용자나 부서/ 일자 삭제
	$(document).on('click', '.ui-icon-close', function(e) {
		e.preventDefault();
		$(this).parent().remove();
	});

</script>
