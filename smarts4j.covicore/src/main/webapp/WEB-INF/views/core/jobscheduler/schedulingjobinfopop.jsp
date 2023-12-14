<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<form id="JobInfoForm">
	<div id="popBox" >
	    <div class="AXTabsLarge" id="LayoutDiv" >
		    <div id="divTabTray" class="AXTabsTray" style="border-bottom: 0px !important;">
				<a id="jobDefaultSetTab" onclick="clickTab(this);" class="AXTab on" style="border-bottom: 0px;" value="divJobDefault"><spring:message code='Cache.lbl_SettingDefault' /></a> <!-- 기본 설정 -->
				<a id="jobScheduleSetTab" onclick="clickTab(this);" class="AXTab" style="border-bottom: 0px;" value="divJobSchedule"><spring:message code='Cache.lbl_SettingSechedule'/></a> <!-- 일정 설정 -->
			</div>
	        <div id="divJobDefault" class="TabBox" style="padding-bottom: 20px !important;">
	            <table class="AXFormTable">
			      <colgroup>
				    <col id="t_tit" style="width:17%;">
				    <col id="" style="width:33%;">
				    <col id="t_tit2" style="width:17%;">
				    <col id="" style="width:33%;">
			      </colgroup>
			      <tbody>
	               <tr>
			          <th><spring:message code='Cache.lbl_JobName'/></th>
				      <td colspan="3">
	                    <input type="text" ID="txtJobTitle" class="HtmlCheckXSS ScriptCheckXSS" style="float:left; width: 98%;"> 
	                  </td>
			        </tr>
	                <tr>
			          <th scope="col"><spring:message code='Cache.lbl_JobKind'/></th>
				      <td scope="col">
				      	<select id="ddlJobType" style="width: 95%;">
		               		<option selected="selected" value="WebService"><spring:message code="Cache.lbl_WebServices"/></option>
							<option value="Procedure"><spring:message code="Cache.lbl_Storedprocedure"/></option>
	                   	</select>
	                  </td>
				      <th scope="col"><spring:message code='Cache.lbl_IsUse'/>(<spring:message code='Cache.lbl_Run'/>)</th>
				      <td scope="col">
	                    <select id="ddlIsUse" style="width: 95%;">
	                    	<option selected="selected" value="Y"><spring:message code="Cache.lbl_Use"/></option>
							<option value="N"><spring:message code="Cache.lbl_NotUse"/></option>
	                    </select>
	                  </td>
			        </tr>
	                <tr>
			          <th scope="col"><spring:message code='Cache.lbl_TimeOut'/></th>
				      <td scope="col" colspan="3">
	                  	<input type="text" ID="txtTimeOut" InputMode="Numberic" MaxLength="3" value="10" style="width:40px;"><span>(Sec)</span>
	                  </td>
			        </tr>
	                <tr>
			          <th><spring:message code='Cache.lbl_Path'/>(URL)</th>
				      <td colspan="3">
	                    <input type="text" ID="txtPath" class="HtmlCheckXSS ScriptCheckXSS" style="float:left; width:98%;"> 
	                  </td>
			        </tr>
				    <tr style="display:none;">
			          <th><spring:message code='Cache.lbl_Params'/></th>
				      <td colspan="3">
	                    <input type="text" ID="txtParams" class="HtmlCheckXSS ScriptCheckXSS" style="float:left; width:98%;"> 
	                  </td>
			        </tr>
	                <tr>
			          <th ><spring:message code='Cache.lbl_Description'/></th>
				      <td colspan="3">
	                    <textarea class="AXTextarea HtmlCheckXSS ScriptCheckXSS" ID="txtDescription" Rows="3" TextMode="MultiLine" style="width: 96%; overflow-x:hidden; resize:none;"></textarea>
	                  </td>
			        </tr>
			        <tr style="display:none"><!-- 지연, 재시도, 반복 사용안함 (추후 필요할 경우 대비 주석 kimhy2)-->
				      <th><spring:message code='Cache.lbl_DelayRun'/></th>
				      <td>
	                    <select ID="ddlDelayRun" style="width:95%;">
	                    	<option selected="selected" value="Y"><spring:message code="Cache.lbl_Use"/></option>
							<option value="N"><spring:message code="Cache.lbl_NotUse"/></option>
	                    </select>
	                  </td>
			          <th><spring:message code='Cache.lbl_FailRetryCnt'/></th>
				      <td>
	                    <input type="text" ID="txtRetryCnt" InputMode="Numberic" MaxLength="1" value="0" style="width:40px;">  <span>※ <spring:message code='Cache.msg_FailRetryCount'/></span>
	                  </td>
				      <th><spring:message code='Cache.lbl_RunCnt'/></th>
				      <td>
	                    <input type="text" ID="txtRepeatCnt" InputMode="Numberic" MaxLength="3" value="0" style="width:40px;"> <span>※ 0 : <spring:message code='Cache.lbl_NotLimite'/></span>
	                  </td>
			        </tr>
			        
		          </tbody>
			    </table> 
	        </div>
	        <div id="divJobSchedule" style="display:none; padding-bottom: 20px !important;" class="TabBox">
	            <table class="AXFormTable">
			      <colgroup>
				    <col id="Col1" style="width: 17%;">
				    <col id="Col2" style="width: 33%;">
				    <col id="Col3" style="width: 17%;">
				    <col id="Col4" style="width: 33%;">
			      </colgroup>
			      <tbody>
	               <tr>
			          <th><spring:message code='Cache.lbl_name'/></th>
				      <td colspan="3">
	                    <input type="text" ID="txtScheduleTitle" class="HtmlCheckXSS ScriptCheckXSS" style="float:left; width:98%;" > 
	                  </td>
			        </tr>
			        <tr>
			        	<th><spring:message code="Cache.lbl_Schedule"/>
			        		<input type="button" class="AXButton red" id="btnSch" value="<spring:message code="Cache.lbl_apply"/>"/>
			        		
			        		</th>
			        	<td colspan=3>
			        		 <table class="AXFormTable">
			        		 	<tr>
			        		 		<th><spring:message code="Cache.lbl_Gubun"/></th>
			        		 		<th></th>
			        		 		<th><spring:message code="Cache.lbl_SpecifictTme"/></th>
			        		 		<th><spring:message code="Cache.lbl_Repeate"/></th>
			        		 	</tr>
			        		 	<tr>
			        		 		<th><span class=cronName><spring:message code="Cache.lbl_Sec"/></span></th>
			        		 		<td><span><spring:message code="Cache.lbl_EverySecond"/><input type=checkbox name=allTime value="*" disabled="true"></span></td>
			        		 		<td>
					                    <input type="text" name="fixTime" data-max="59" InputMode="Numberic" MaxLength="3" value="0" style="width:40px;"><span> (Sec)</span>
			        		 		</td>
			        		 		<td>
						      			<select name="termTime" style="width:70px;" data-start="0" disabled="true">
											<option value=""/><spring:message code="Cache.lbl_NoRepeat"/></option>
						      				<c:forEach begin="5" end="55" var="time" step="5">
												<option value="${time}"/>${time} (Sec) <spring:message code="Cache.lbl_Repetition"/></option>
											</c:forEach>
					                   </select>
			        		 		</td>
			        		 	</tr>	
			        		 	<tr>
			        		 		<th><span class=cronName><spring:message code="Cache.lbl_Minutes"/></span></th>
			        		 		<td><spring:message code="Cache.lbl_EveryMinute"/><input type=checkbox name=allTime value="*"></td>
			        		 		<td>
					                    <input type="text" name="fixTime" data-max="59" InputMode="Numberic" MaxLength="3" value="0" style="width:40px;"><span> (Min)</span>
			        		 		</td>
			        		 		<td>
						      			<select name="termTime"  style="width:70px;" data-start="0">
											<option value=""/><spring:message code="Cache.lbl_NoRepeat"/></option>
						      				<c:forEach begin="1" end="55" var="time" step="1">
												<option value="${time}"/>${time} (Min) <spring:message code="Cache.lbl_Repetition"/></option>
											</c:forEach>
					                   </select>
			        		 		</td>
			        		 	</tr>
			        		 	<tr>
						        	<th><span class=cronName><spring:message code="Cache.lbl_Hour"/></span></th>	
			        		 		<td><spring:message code="Cache.lbl_EveryHour"/><input type=checkbox name=allTime value="*"></td>
			        		 		<td>
					                    <input type="text" name="fixTime"  data-max="23" InputMode="Numberic" MaxLength="3" value="0" style="width:40px;"><span> (Hour)</span>
			        		 		</td>
			        		 		<td>
						      			<select name="termTime"  style="width:70px;" data-start="0">
											<option value=""/><spring:message code="Cache.lbl_NoRepeat"/></option>
						      				<c:forEach begin="1" end="23" var="time" step="1">
												<option value="${time}"/>${time} (Hour) <spring:message code="Cache.lbl_Repetition"/></option>
											</c:forEach>
					                   </select>
			        		 		</td>
						         </tr> 
			        		 	<tr>
						        	<th><span class=cronName><spring:message code="Cache.lbl_day"/></span></th>	
						        	<td><spring:message code="Cache.lbl_EveryDaily"/><input type=checkbox name=allTime value="*"></td>
			        		 		<td>
					                    <input type="text" name="fixTime"  data-max="31" InputMode="Numberic" MaxLength="3" value="1" style="width:40px;"><span> (Day)</span>
			        		 		</td>
			        		 		<td>
						      			<select name="termTime"  style="width:70px;" data-start="1">
											<option value=""/><spring:message code="Cache.lbl_NoRepeat"/></option>
						      				<c:forEach begin="1" end="31" var="time" step="1">
												<option value="${time}"/>${time} (Day) <spring:message code="Cache.lbl_Repetition"/></option>
											</c:forEach>
					                   </select>
			        		 		</td>
						         </tr> 
			        		 	<tr>
						        	<th><span class=cronName><spring:message code="Cache.lbl_month"/></span></th>	
						        	<td><spring:message code="Cache.lbl_EveryMonthly"/><input type=checkbox name=allTime value="*"></td>
			        		 		<td>
					                    <input type="text" name="fixTime"  data-max="12"  InputMode="Numberic" MaxLength="3" value="1" style="width:40px;"><span> (Month)</span>
			        		 		</td>
			        		 		<td>
						      			<select name="termTime"  style="width:70px;"  data-start="1">
											<option value=""/><spring:message code="Cache.lbl_NoRepeat"/></option>
						      				<c:forEach begin="1" end="12" var="time" step="1">
												<option value="${time}"/>${time} (Month) <spring:message code="Cache.lbl_Repetition"/></option>
											</c:forEach>
					                   </select>
			        		 		</td>
						         </tr> 
			        		 </table>		
			        	</td>
			        </tr>
			        <tr id="trCron">
			       	  <th>Cron</th>
				      <td colspan="3">
	                    <input type="text" ID="txtCronExpression" class="HtmlCheckXSS ScriptCheckXSS" style="float:left; width:98%;" > 
	                  </td>
			        </tr>
	              </tbody>
			    </table>
	        </div>
			<div style="width: 100%; text-align: center;">
				<input type="button" class="AXButton red" id="btnAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="btnAdd_Click();"/>
				<input type="button" class="AXButton red" id="btnModify" value="<spring:message code="Cache.btn_Modify"/>" onclick="btnModify_Click();" style="display: none;"/>
				<input type="button" class="AXButton" id="btnClose" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"/>
			</div>
			<!-- hidden -->
			<input type="hidden" id="hidSchID">
			<input type="hidden" id="hidAgentServer">
		  </div>
	</div>
</form>
<script  type="text/javascript">	
	var paramJobID = "${JobID}";	
	var paramDomainID =  "${DomainID}";
	var mode = "${mode}";
	var doublecheck = false;
	var _cbe = new Object();
	
	$(document).ready(function(){		
		init();	
	});
	
	function init(){
		$(document).on("keyup", "input:text[InputMode]", function() {
			if($(this).attr('InputMode')=="Numberic"){
				$(this).val( $(this).val().replace(/[^0-9]/gi,"") );
			}
			if($(this).attr('InputMode')=="Alphabetic"){
			
			}
		});
		
		//매설정시 특정시간. 간격은 선택못함
		$(document).on("click", "input[name=allTime]", function(){
			var idx = $("input[name=allTime]").index($(this));
			$("input[name=fixTime]").eq(idx).attr('disabled', $(this).is(':checked'));
			$("select[name=termTime]").eq(idx).attr('disabled', $(this).is(':checked'));
		});

		//고정시간 선택시
		$(document).on("change", "input[name=fixTime]", function(){
			var idx = $("input[name=fixTime]").index($(this));
			if ($(this).val() != ""){
				$("select[name=termTime]").eq(idx).val("");
			}
		});

		//고정시간 입력시 max값 체크
		$(document).on("blur", "input[name=fixTime]", function(){
			if  (parseInt ($(this).attr("data-max"), 10) < parseInt($(this).val(),10)   ){
				Common.Warning("<spring:message code='Cache.ACC_032'/>");
				$(this).val("");
			}
		});

		
		//반복시간 선택시
		$(document).on("change", "select[name=termTime]", function(){
			var idx = $("select[name=termTime]").index($(this));
			if ($(this).val() != ""){
				$("input[name=fixTime]").eq(idx).val("");
			}
		});

		$("#btnSch").click( function(){
			var cron = "";
			var cronTitle = "";
			$("input[name=allTime]").each(function(index, item){ 
				if (index > 0) {
					cron += " ";
					cronTitle = " " + cronTitle;
				}
				if ($("input[name=allTime]").eq(index).is(':checked')){
					cron += "*";
					cronTitle = "<spring:message code='Cache.lbl_Every'/>"+$(".cronName").eq(index).text() + cronTitle;
				}
				else{
					if ($("input[name=fixTime]").eq(index).val() != ""){
						cron += $("input[name=fixTime]").eq(index).val();
						cronTitle = $("input[name=fixTime]").eq(index).val() + $(".cronName").eq(index).text() + cronTitle;
					}
					else{
						cron += $("select[name=termTime]").eq(index).attr("data-start")+"/"+$("select[name=termTime]").eq(index).val();
						cronTitle = $("select[name=termTime]").eq(index).val() + $(".cronName").eq(index).text() + "<spring:message code='Cache.lbl_Interval'/>" + cronTitle;
					}
				}
					
			})
			
			cron +=" ? *";
			Common.Confirm("["+cronTitle+"] <spring:message code='Cache.ACC_msg_ckApply' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$("#txtCronExpression").val(cron);
					$("#txtScheduleTitle").val(cronTitle);
				}	
			});				
		});
		
		if(mode == "modify"){
			setData();
			$("#btnModify").css("display", "");
		}
		
	}
	
	function setData(){
		$.ajax({
			type:"POST",
			data: {"JobID" : paramJobID},
			url:"/covicore/admin/jobscheduler/getjobschedulerdata.do",
			success:function (json) {
				var bDis = true;
				if (json.data.EventID == 0){
					bDis = false;
				}
				
				var disCol = ["txtJobTitle", "ddlJobType", "txtPath"];
				for (var i=0; i < disCol.length; i++ ){
					$("#"+disCol[i]).attr('disabled', bDis);
				}
				
				var cronExpr = json.data.Reserved1;
				if (cronExpr != ""){
					var times = cronExpr.split(" ");
					$(times).each(function(index, item){ 
						if (item == "*"){
							$("input[name=allTime]").eq(index).attr("checked", true);
							$("input[name=fixTime]").eq(index).attr('disabled', true);
							$("select[name=termTime]").eq(index).attr('disabled', true);
						}
						else{
							if (item.indexOf("/")>0){	//간격
								$("input[name=fixTime]").eq(index).val("");
								$("select[name=termTime]").eq(index).val(item.split("/")[1]);
							}
							else{
								$("input[name=fixTime]").eq(index).val(item);
								$("select[name=termTime]").eq(index).val("");
							}
						}
					});					

					
				}
				$("#txtJobTitle").val(json.data.JobTitle);
				$("#ddlJobType").val(json.data.JobType);
		        $("#ddlIsUse").val(json.data.IsUse);

		        $("#txtTimeOut").val(json.data.TimeOut);
		        $("#txtPath").val(json.data.Path);
		        $("#txtMethod").val(json.data.Method);      
		        $("#txtParams").val(json.data.Params);
		        $("#txtDescription").val(json.data.Description);
		        
		     	// 일정
		        $("#txtScheduleTitle").val(json.data.ScheduleTitle);
		     	// 일정 유형
		     	$("#txtCronExpression").val(json.data.Reserved1) // 일정 크론 표현식
		        
		        //set hidden value
		        $('#hidSchID').val(json.data.ScheduleID);
		        $('#hidAgentServer').val(json.data.AgentServer);
			},
			error:function (error){
				Common.Error(error.message);
			}
		});
	}
	
	// 탭 선택
	function clickTab(pObj){
		$("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
		
		var str = $(pObj).attr("value");
		
		$("#divJobDefault").hide();
		$("#divJobSchedule").hide();
		
		$("#" + str).show();
        coviInput.init();
		
		$("#inputBasic_AX_txtEndDate_AX_dateHandle").css("width", "");
		$("#inputBasic_AX_txtEndDate_AX_dateHandle").css("height", "");
	}
	
    // 화면 사이즈 조정
    function PageResize() {
        var nHeight = $("#LayoutDiv").height() + 10;
      	//달력 컨트롤 짤리는 현상 수정
        if(nHeight < 415) 
        	nHeight = 415; 
        
        $('#divJobInfo_pc', parent.document).height(nHeight+'px');       
    }
    
    function make_cbe(){    	
    	// 작업 정보

		_cbe.DomainID = paramDomainID != "" ? paramDomainID : "0";
		_cbe.JobID = paramJobID; 
        _cbe.JobTitle = $("#txtJobTitle").val();
        _cbe.JobType = $("#ddlJobType").val();
        _cbe.IsUse = $("#ddlIsUse").val();
        _cbe.TimeOut = $("#txtTimeOut").val();
        _cbe.Path = $("#txtPath").val();
        _cbe.Method = $("#txtMethod").val();
        _cbe.Params = $("#txtParams").val();
        _cbe.Description = $("#txtDescription").val();

        _cbe.ScheduleTitle = $("#txtScheduleTitle").val(); // 일정명
        _cbe.Reserved1 = $("#txtCronExpression").val(); // cron 표현식
        _cbe.AgentServer = $("#hidAgentServer").val();
    }
    
    // 작업 클러스터 추가
    function btnAdd_Click(){    	
    	if(!ValidationCheck()){
    		return;
    	}
    	
    	make_cbe();    
    	
      	//insert 호출
		$.ajax({
			type:"POST",
			data: _cbe,
			url:"/covicore/admin/jobscheduler/insertschedulingjob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_DeonRegist'/>", "Information", function(){
						closeLayer();
						parent.bindGridData();
					});				
				}else{
					Common.Warning("<spring:message code='Cache.CPMail_error_msg'/>");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/jobscheduler/insertschedulingjob.do", response, status, error);
			}
		}); 

    }
    
 	// 작업 클러스터 수정
    function btnModify_Click(){    	
    	if(!ValidationCheck()){
    		return;
    	}
    	
    	make_cbe();    	
    	      
    	
      	//insert 호출
		$.ajax({
			type:"POST",
			data: _cbe,
			url:"/covicore/admin/jobscheduler/updateschedulingjob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_DeonModify'/>", "Confirmation Dialog", function () {;				
						closeLayer();
						parent.bindGridData();
					});
				}else{
					Common.Warning(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/jobscheduler/updateschedulingjob.do", response, status, error);
			}
		}); 

    }

    
 	// 벨리데이션 체크
    function ValidationCheck() {
    	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

        // 작업명
        if ($("#txtJobTitle").val() == "") {
            Common.Warning("<spring:message code='Cache.msg_EnterValueInField'/>");
                $("#txtJobTitle").focus();
            
            return false;
        }

        // 타임아웃
        if ($("#txtTimeOut").val() == "" || $("#txtTimeOut").value == "0") {
            Common.Warning("<spring:message code='Cache.msg_EnterValueInField'/>");
                $("#txtTimeOut").focus();
            return false;
        }
        // 경로 체크
        if ($("#txtPath").val() == "") {
        	Common.Warning("<spring:message code='Cache.msg_EnterValueInField'/>");
                $("#txtPath").focus();

            return false;
        }
        // 일정명
        if ($("#txtScheduleTitle").val() == "") {
        	Common.Warning("<spring:message code='Cache.msg_EnterValueInField'/>");
                $("#txtScheduleTitle").focus();

            return false;
        }

        return true;
    }
 	
 	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
</script>