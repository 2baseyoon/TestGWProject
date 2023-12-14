<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String lang = SessionHelper.getSession("lang");

	String fmtDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
	
	SimpleDateFormat formatter = new SimpleDateFormat("yyyy.MM.dd");

	int year = Integer.parseInt(fmtDate.split("-")[0]);
	int month = Integer.parseInt(fmtDate.split("-")[1]);
	int date = Integer.parseInt(fmtDate.split("-")[2]);
	
	Calendar cal = Calendar.getInstance ();
	cal.set(year,month-1,date);
	cal.add(Calendar.DATE, 1);

	String StartDate = formatter.format(cal.getTime());
	
%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">

$(document).ready(function() { 
	var addUserArry = new Array();
	var lang = "<%=lang%>";
	init();
});

function init(){
	 
	//setDateConResource();
	
	var stDate = "<%=StartDate%>";
	var edDate = '${params.EndDate}';
	
	$("#simpleResDateCon_StartDate").val(stDate);
	
	$("#simpleResDateCon_StartDate").datepicker({
		dateFormat: 'yy.mm.dd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(selected){
        	var $start = $("#simpleResDateCon_StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "/"));
        	var baseDate = new Date(stDate.replaceAll(".", "/"));

        	if (startDate.getTime() < baseDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance51' />");	//당일 보다 이전 일 수 없습니다.
        		$("#simpleResDateCon_StartDate").val(baseDate.format('yyyy.MM.dd'));
        	}
        }
	});
	$("#simpleResDateCon_EndDate").datepicker({
		dateFormat: 'yy.mm.dd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(selected){
        	var $start = $("#simpleResDateCon_StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "/"));
        	var endDate = new Date(selected.replaceAll(".", "/"));

        	if (startDate.getTime() > endDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance19' />"); //시작일 보다 이전 일 수 없습니다.
        		$("#simpleResDateCon_EndDate").val(startDate.format('yyyy.MM.dd'));
        	}
        }
	});
	
	$("#btnSetTerm").click(function(){
		if ($("#btnSetTerm").attr("data") == "1"){
			$('#simpleResDateCon_EndDate').val('');
			$("#btnSetTerm").attr("data", "0");
			$("#btnSetTerm").text("<spring:message code='Cache.mag_Attendance52' />");	//영구지정
		}
		else{
			$('#simpleResDateCon_EndDate').val('9999.12.31');
			$("#btnSetTerm").attr("data", "1");
			$("#btnSetTerm").text("<spring:message code='Cache.mag_Attendance53' />");	//지정해제
		}	
	});
	
	//getMemList();
	addUserArry = new Array();

}

function delMemList(o){
	var userCode = $(o).data("user-code");
	
	for(var j=0;j<addUserArry.length;j++){
		if(addUserArry[j][0]==userCode){
			addUserArry.splice(j,1);
			break;
		}
	}
	
	setAddListView();
}

function setDateConResource(){
	target = 'simpleResDateCon';
	
	var timeInfos = {
			width : "0",
			H : "1,2,3,4",
			W : "1,2", //주 선택
			M : "1,2", //달 선택
			Y : "1,2" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'Y',
			useTimePicker : 'N',
			useBar : 'Y',
			useSeparation : 'Y',
			minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
			timePickerwidth : '50',
			height : '200',
			use59 : 'Y'
		};
	
	coviCtrl.renderDateSelect2(target, initInfos);
	
	// onchange 함수 세팅
	$("#resourceSimpleMake").find("input,select").attr("onchange", "funcRESOnChange();");
}


/* function getMemList(){
	
	var param = {
				"SchSeq":"${SchSeq}"
				,"StartDate":$("#simpleResDateCon_StartDate").val()
				,"EndDate":$("#simpleResDateCon_EndDate").val()
			}
	$.ajax({
		type:"POST",
		url:"/groupware/layout/getAttendanceSchMemList.do",
		data : param,
		dataType : "json",
		success:function (data) {
			var schMemList = data.schMemList;
		}
	});
}
 */


//레이어 팝업 닫기
function closeLayer(){
	parent.Common.Close("SchMemAddPop");
	parent.openSchMemPopup("${SchSeq}");
}


function openGroupLayer(){

/* 	var config ={
 	    	targetID: 'orgChart',
	    	drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
	    	type: 'B9',
	    	callbackFunc: callbackSchMember, 
	    	openerID: 'openGroupLayerPop' 
	};
	coviOrg.render(config);
	window.open
 */
 	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callbackSchMember&type=B9&targetID=orgChart","openGroupLayerPop",1010,580,"");

	/* var url = "/groupware/layout/goAttHrList.do";		
	var title = "<spring:message code='Cache.lbl_att_specifier'/>"; // 지정자
	parent.Common.open("orgChart","openGroupLayerPop",title,url,1060,580,"iframe",true,null,null,true); */
	
/* 	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callbackSchMember&type=B1&drawOpt=_____&targetID=orgChart","openGroupLayerPop",1060,580,""); */
	//CFN_OpenWindow("/covicore/control/goOrgChart.do","openGroupLayerPop",1060,580,"");

}


function callbackSchMember(result){
	var cbData =  $.parseJSON(result);
	
	var companyCode = '${params.CompanyCode}';
	var item = cbData.item;
	var flag = true;
	for(var i=0;i<item.length;i++){
		if(companyCode!= item[i].ETID){
			flag = false;
			Common.Inform("<spring:message code='Cache.mag_Attendance54' />","warning","");	//동일 그룹사 사원만 등록 가능합니다.
			break;
		}
		
		
		for(var j=0;j<addUserArry.length;j++){
			if(addUserArry[j][0]==item[i].UserCode){
				flag = false;
				Common.Inform("<spring:message code='Cache.mag_Attendance55' />","warning","");	//이미 추가 된 사용자입니다.
				break;
			}
		}
	} 
	
	
	
	if(flag){
		//등록
		var liStr = "";
		for(var i=0;i<item.length;i++){
			
			var name = item[i].DN;	
			var chargeBusiness = item[i].ChargeBusiness;
			
			if(lang=="ko"){
				name = name.split(";")[0];
				chargeBusiness = chargeBusiness.split(";")[0];
			}else if(lang=="en"){
				name = name.split(";")[1];
				chargeBusiness = chargeBusiness.split(";")[1];				
			}else if(lang=="ja"){
				name = name.split(";")[2];
				chargeBusiness = chargeBusiness.split(";")[2];										
			}else if(lang=="zh"){
				name = name.split(";")[3];
				chargeBusiness = chargeBusiness.split(";")[3];
			}
			/* 
			liStr +="<li>";
			liStr +="	<div class='tblParticipant'>";
			liStr +="		<img src='"+item[i].PhotoPath+"' alt='프로필사진' style='width:30px;height:30px;border-radius:15px;''>";
			liStr +="		<span class='fcStyle'>"+name+" ["+chargeBusiness+"]</span>";
			liStr +="		<a href='#' class='visit_cancel'>취소</a>";
			liStr +="	</div>";
			liStr +="</li>"; */
			var userArry = new Array();
			userArry.push(item[i].UserCode);
			userArry.push(item[i].PhotoPath);
			userArry.push(name);
			userArry.push(chargeBusiness);
			
			addUserArry.push(userArry);	
		}
		setAddListView();
	}
}

function setAddListView(){
	var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
	var liStr = "";
	for(var i=0;i<addUserArry.length;i++){
		liStr +="<li>";
		liStr +="	<div class='tblParticipant'>";
		liStr +="		<img src='"+addUserArry[i][1]+"' alt='"+lbl_ProfilePhoto+"' style='width:30px;height:30px;border-radius:15px;' onerror=\"coviCmn.imgError(this, true)\" >";
		liStr +="		<span class='fcStyle'>"+addUserArry[i][2]+(addUserArry[i][3]!=""?" ["+addUserArry[i][3]+"]":addUserArry[i][3])+"</span>";
		liStr +="		<a href='#' data-user-code='"+addUserArry[i][0]+"' class='visit_cancel' onclick='delMemList(this);'>취소</a>";
		liStr +="	</div>";
		liStr +="</li>";
	}
	$("#ulMem").html(liStr);
}



function returnList(s){
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if(s=="cancle"){
		
	}else if(s=="add"){
		if($("#simpleResDateCon_StartDate").val()==""){
			Common.Inform("<spring:message code='Cache.mag_Attendance56' />","warning","");		//시작일을 입력하세요
			return false;
		}else if($("#simpleResDateCon_EndDate").val()==""){
			Common.Inform("<spring:message code='Cache.mag_Attendance57' />","warning","");		//종료일을 입력하세요
			return false;
		}else if(addUserArry.length==0){
			Common.Inform("<spring:message code='Cache.mag_Attendance58' />","warning","");		//추가할 사용자가 없습니다
			return  false;
		}else{

			var paramsArry = new Array();
			for(var i=0;i<addUserArry.length;i++){
				paramsArry.push({"UserCode":addUserArry[i][0]});
			}
			
			var param = {
				"SchSeq":"${SchSeq}"
				,"StartDtm":$("#simpleResDateCon_StartDate").val()
				,"EndDtm":$("#simpleResDateCon_EndDate").val()
				,"paramsArry":JSON.stringify(paramsArry)
			}

			$.ajax({
				type:"POST",
				url:"/groupware/attendSchedule/setAttendSchMember.do",
				data : param,
				dataType : "json",
				success:function (data) {
					if(data.status == "SUCCESS"){
						var returnList = data.returnList;
						if(returnList.length>0){
							var infoStr = "";
							for(var i=0;i<returnList.length;i++){
								infoStr += returnList[i].userMulti+" <spring:message code='Cache.mag_Attendance59' />"+returnList[i].nAddSchName+" <spring:message code='Cache.mag_Attendance60' /> \n";	//님은 지정일이 nAddSchName 근무제와 중복됩니다.
							}
							Common.Warning(infoStr);/* 저장 중 오류가 발생하였습니다. */	
						}else{
							
							Common.Inform("<spring:message code='Cache.msg_37' />","Information",function(){	//저장되었습니다.
								closeLayer();
							});
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */	
					}
					
				}
			});
			
		}
		
		
	}
}

function getAjaxMem(o){
	
	var param = {
		"companyCode" : "${params.CompanyCode}"
		,"searchType": "name"
		,"hasChildGroup" :"N"
		,"groupType":"dept"
		,"searchText": $(o).val()
	}
	
	$("#ajMem").html("");
	$("#ajMemDiv").hide();
	
	if($(o).val().length>1){
		
		if(Number($(o).val()).toString() != "NaN"){
			param = {
					"companyCode" : "${params.CompanyCode}"
					,"searchType": "phone"	
					,"hasChildGroup" :"N"
					,"groupType":"dept"
					,"searchText": $(o).val()
			}
		}
	
		$.ajax({
			type:"POST",
			url:"/covicore/control/getUserList.do",
			data : param,
			dataType : "json",
			success:function (data) {
				var liStr = ""; 
				
				if(data.list.length>0){
					for(var i=0;i<data.list.length;i++){
						var name = data.list[i].DN;	
						var chargeBusiness = data.list[i].ChargeBusiness;
						
						if(lang=="ko"){
							name = name.split(";")[0];
							chargeBusiness = chargeBusiness.split(";")[0];
						}else if(lang=="en"){
							name = name.split(";")[1];
							chargeBusiness = chargeBusiness.split(";")[1];				
						}else if(lang=="ja"){
							name = name.split(";")[2];
							chargeBusiness = chargeBusiness.split(";")[2];										
						}else if(lang=="zh"){
							name = name.split(";")[3];
							chargeBusiness = chargeBusiness.split(";")[3];
						}
						
						liStr += "<li style='cursor:pointer' onclick=\"setAjaxValue('"+data.list[i].UserCode+"','"+data.list[i].PhotoPath+"','"+name+"','"+chargeBusiness+"')\">"+name+" ["+chargeBusiness+"]</li>"; 					
					}
					$("#ajMem").html(liStr);
					$("#ajMemDiv").show();
				}else{
					$("#ajMem").html("");
					$("#ajMemDiv").hide();
				}
			}
		});
	}
	
	/* $(o).focusout(function() {
		clear(); 
	}); */
}


function clear(){
	$("#ajMem").html("");
	$("#ajMemDiv").hide();	
}

function setAjaxValue(uc,pp,cb,nm){
	
	var flag = true;
	for(var j=0;j<addUserArry.length;j++){
		if(addUserArry[j][0]==uc){
			flag = false;
			Common.Inform("<spring:message code='Cache.mag_Attendance61' />","warning","");	//이미 추가 된 사용자입니다.
			break;
		}
	}
	
	if(flag){
		var userArry = new Array();
		userArry.push(uc);
		userArry.push(pp);
		userArry.push(cb);
		userArry.push(nm);
		
		addUserArry.push(userArry);	
		
		$("#ajMemDiv").hide();
	}
		setAddListView();	
}
	
</script>
<style type="text/css">
.txtDate { width : 120px;}
</style>
</head>
<body>
<div id="content">
	<div class="layer_divpop ui-draggable" style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
			
				<div class="top">
					<p class="visit_title"><spring:message code='Cache.lbl_board_settingPeriod' /></p> <!-- 기간 설정 -->
					<div class="dateSel type02">
						<input class="txtDate" id="simpleResDateCon_StartDate" type="text" readonly="" value="<%=StartDate%>">							
						<input class="txtDate" id="simpleResDateCon_EndDate" type="text" readonly="" value="">							
						<a class="btnTypeDefault" href="#" id="btnSetTerm"><spring:message code='Cache.mag_Attendance52' /></a>	<!-- 영구지정 -->		
					</div>
				</div>
				<div class="top type02">
					<p class="visit_title"><spring:message code='Cache.lbl_att_specifier' /> <spring:message code='Cache.btn_apv_input' /></p> <!-- 지정자 입력 -->
					<input type="text" placeholder="<spring:message code='Cache.lbl_Mail_DirectInput' /> (<spring:message code='Cache.lbl_name' />/<spring:message code='Cache.lbl_hr_phone_num' />)" class="visit_input bindSelectorNodes HtmlCheckXSS ScriptCheckXSS" onkeyup="getAjaxMem(this);">	<!-- 직접입력 (이름/휴대폰 번호) -->
					<div class="visit_list_wrap" id="ajMemDiv" style=" display:none; width: 285px;   vertical-align: top; margin-right: 5px; margin: 0 0;position: absolute;z-index: auto;height: 100px;overflow-y: auto;">
						<ul class="visit_list" id="ajMem"  style="background: white;">
						</ul>				
					</div>
						<a href="#" onclick="openGroupLayer();" class="btnTypeDefault nonHover type01"><spring:message code='Cache.lbl_DeptOrgMap'/></a>
				</div>				
				<div class="">
					<div class="visit_list_wrap">
						<ul class="visit_list" id="ulMem">
							
						</ul>
					</div>
				</div>
				<div class="bottom">
					<a href="#" class="btnTypeDefault btnTypeBg" onclick="returnList('add');"><spring:message code='Cache.lbl_Confirm'/></a><!-- 확인  -->
					<a href="#" class="btnTypeDefault " onclick="closeLayer();"><spring:message code='Cache.lbl_Cancel'/></a><!-- 취소  -->
				</div>
			</div>
		</div>	
	</div>
</div>
</body>
</html>
