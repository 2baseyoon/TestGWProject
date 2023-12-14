<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_apv_vacation_statistics' /></h2>
	<h2 class="title" id="spanDate"></h2>
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
	</div> 
	
	<a href="#" class="pre dayChg" data-paging="-"></a>
	<a href="#" class="next dayChg" data-paging="+"></a>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="extensionContent" style="margin: 20px 0 0 0;">
		<div style="text-align: right;margin: 10px 20px;">* 일정의 색이 붉은색은 <span style="color: #ed0f64;">당일 스케줄</span></div>
		<div id="tbodyDept">
			<div class="calMonWeekRow" id="divWeekScheduleForMonth" >
				<table class="calGrid" id="vacListContainer" style="margin-bottom:30px; border-collapse: separate; border-spacing:20px;">
					<tbody></tbody>
				</table>
			</div>
			
		</div>
	</div>
</div>

<style type="text/css">
.divDeptList {
	border: 1px solid #eaeaea;
    width: 100%;
    border-radius: 5px;
    margin-bottom:10px;
    padding:10px;
}
.divDeptList > table {
	border: none;
    width: 100%;
}
.divDeptList > table > tbody > tr > td {
	border: none !important;
}

.top_box {background:#daf2ff; font-size:18px !important;}
.head_box {background:#EDF8FE; font-size:16px !important;}
.team_box{background:#fff !important; font-size:14px !important;}
.etc_box{background:#f3f6fa;}
.calMonWeekRow:first-child .calGrid td {border-top:1px solid #bac9d4;}
.calMonWeekRow .calGrid td {border:1px solid #bac9d4;}
.calMonWeekRow .calGrid td:last-child {border-right:1px solid #bac9d4;}

.top_box th{font-size:18px; color:#26343d;}
.head_box th {font-size:16px; color:#26343d;}
.team_box th {font-size:14px; color:#26343d;}
 

</style>
<script>

var vacationVacationListByAll = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	var today ;
	var _targetDate;
	this.initContent=function() {
		today = new Date();
		_targetDate = today;
		getDeptList(); //부서리스트조회
		
		$(".dayChg").on('click',function(){
			if("+"==$(this).data("paging")){
				_targetDate = _targetDate.add(1, 'm');
			}else {
				_targetDate = _targetDate.add(-1, 'm');
			}
	
			getDeptList();
		});
	}
	
	function drawDeptTable(item, id)
	{
		var sHtml = '<table style="width:100%;" cellpadding="10px">';
		sHtml += '<tr style="height:40px;"><th>' + item.MultiDisplayName +'</th></tr>';
		sHtml += '<tr id="divSubDept_' + item.GroupCode + '" style="display:none;"><td id="tdSubDept_' + item.GroupCode + '" style="border:none; vertical-align:top;"></td></tr>';
		sHtml += '<tr>'
				+ '<td style="height:auto; border:none; vertical-align:top;">'
				+ '<table id="'+id+'" style="height:100%; vertical-align:top" class1="etc_box"><tbody></tbody></table>'
				+ '</td>'
				+ '</tr>';
			sHtml += '</table>';
		return sHtml;
	}
	
	// 최상위 부서 바인딩
	function getDeptList(){
		$("#spanDate").text("("+_targetDate.format('yyyy-MM-dd') + "~" + _targetDate.add(1, 'm').format('yyyy-MM-dd')+")");
		$.ajax({
			url : "/groupware/vacation/selectVacationListByAll.do",
			type: "POST",
			data:{"sDate":_targetDate.format('yyyy-MM-dd')},
			success:function (data) {
				var colSize = 5;//Common.getBaseConfig("KGVacDeptCol");
				var subDeptList = data.deptList;		
				var startDepth = 3;
				
				var sHtml = ""; // 본부
				$("#vacListContainer tbody").empty();
				if(subDeptList!=null && subDeptList.length>0) {
					for (var i = 0; i < subDeptList.length; i++) {
						var sortPaths = subDeptList[i].SortPath.split(";");
						var thisId = "";
						var parentId = "tab";
						for (var j = startDepth - 1; j < sortPaths.length - 2; j++) {
							parentId += "_" + sortPaths[j];
						}
	
						thisId = parentId + "_" + sortPaths[sortPaths.length - 2];
	
						if (startDepth == subDeptList[i].SortDepth) { //최상위값
							if (($("#vacListContainer").children("tbody").children("tr").children("td").length % colSize) == 0) {
								$("#vacListContainer").children("tbody").append($("<tr>"));
							}
							$("#vacListContainer").children("tbody").children("tr:last").append($("<td>", {
								"class": "top_box",
								"style": "vertical-align:top",
								"html": drawDeptTable(subDeptList[i], thisId)
							}));
						} else {
							$("#" + parentId).children("tbody").append($("<tr>").append($("<td>", {
								"class": sortPaths.length == startDepth + 1 ? "head_box" : "team_box",
								"style": "vertical-align:top",
								"html": drawDeptTable(subDeptList[i], thisId)
							})));
	//					drawDept(subDeptList[i], parentId, thisId)
						}
					}
				}
				
				$(data.vacList).each(function(idx, item){
					var gubun = "";
					var time = "";
					var sHtml = "";
					var todayColor = "";
					
					switch (item.Gubun) {
						case "Vac": // 휴가
							if (item.Gubun3 == "AM" || item.Gubun3 == "PM"){
								time = item.Sdate + ' (' + Common.getDic("lbl_" + item.Gubun3) + ')';
							}
							else {
								time = item.Sdate + '~' + item.Edate;
							}
							gubun = '<span class="btnType02 borderBlue" style="float:left;">' + CFN_GetDicInfo(item.Gubun2) + '</span>';
							
							if(XFN_ReplaceAllSpecialChars(item.Sdate) <= today.format('yyyyMMdd') && XFN_ReplaceAllSpecialChars(item.Edate) >= today.format('yyyyMMdd')){
								todayColor = "color:#ed0f64;font-weight: bold;";
							}
							
							break;
						case "Att": // 근무상태 (출장, 외근.....)
							gubun = '<span class="btnType02 borderBlue" style="float:left; border: 1px solid #85288f; color: #85288f;">' + CFN_GetDicInfo(item.Gubun2) + '</span>';
							time = item.Sdate + ' (' + item.Stime.substring(0,2) + ':' + item.Stime.substring(2,4) + '~' 
									+ item.Etime.substring(0,2) + ':' + item.Etime.substring(2,4) + ')';
							
							if(XFN_ReplaceAllSpecialChars(item.Sdate) == today.format('yyyyMMdd')){
								todayColor = "color:#ed0f64;font-weight: bold;";
							}
							break;
					}
					
					if($("#div_" + item.UR_Code + "_sch").length == 0) {
						sHtml += '<div class="personBox perBoxType02" style="margin-top: 10px;"><div class="name">' 
							+ '<p><strong>' + CFN_GetDicInfo(item.UR_Name) + ' ' + CFN_GetDicInfo(item.JobPositionName) + '</strong></p>'
							+ '<div id="div_' + item.UR_Code + '_sch">'
							+ '<p style="margin-top: 5px;">' + gubun 
							+ '<span style="float:left;' + todayColor + '">' + time;
						if(item.MEMO != '') {
							sHtml += '<br/>' + item.MEMO;
						}
						sHtml += '</span></p></div>'
							+ '</div></div>';
							
						$("#tdSubDept_"+item.DeptCode).append(sHtml);
						$("#divSubDept_"+item.DeptCode).css("display", "");
					} else {
						sHtml += '<p style="margin-top: 5px;">' + gubun
							+ '<span style="float:left;' + todayColor + '">' + time;
						if(item.MEMO != '') {
							sHtml += '<br/>' + item.MEMO;
						}
						sHtml += '</span></p>';
							
						$("#div_" + item.UR_Code + "_sch").append(sHtml);
					}
					
					
				});
				
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/vacation/getCompanyList.do", response, status, error);
			}
		}); 
	}	
}();

$(document).ready(function(){
	vacationVacationListByAll.initContent();
});
</script>			