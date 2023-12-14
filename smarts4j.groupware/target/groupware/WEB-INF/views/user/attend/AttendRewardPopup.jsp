<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>
	.pad10 { padding:10px;}
</style>
	<!-- 상단 끝 -->
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
		<!-- 컨텐츠 시작 -->
			<div class="popTitBox">
				<div class="popTit_l"> 	
					<strong><script>document.write(CFN_GetQueryString("StartDate")+"~"+ CFN_GetQueryString("EndDate"))</script></strong>
				</div>
				<div class="popTit_r">
					<div class="pagingType02 buttonStyleBoxRight" id="selectBoxDiv"> 	
						<a class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.btn_ExcelDownload"/></a>
						<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
						<select class="selectType02 listCount" id="listCntSel">
							<option>5</option>
							<option selected>10</option>
							<option>15</option>
							<option>20</option>
							<option>30</option>
							<option>50</option>
						</select>
					</div>
				</div>	
			</div>	
			<div class="tblList">
				<div id="gridDiv"></div>
			</div>
		</div>	
	</div>
	<!-- 컨텐츠 끝 -->
</div>
<script>
// 그리드 세팅
var grid = new coviGrid();

var headerData = [ 
		{key:'TargetDate',			label:"<spring:message code='Cache.ACC_lbl_applicationDate' />",			width:'70', align:'center'	},
		{key:'AttDayTime',			label:"<spring:message code='Cache.lbl_scope' />",			width:'150', align:'center',		//사용유무
			formatter : function () {
           		 return ""+this.item.AttDayTime+"";
			}
		},
		{key:'AttAc',  label:"<spring:message code='Cache.lbl_n_att_normalWork' />", width:'40', align:'center',
			formatter : function () {
           		 return ""+AttendUtils.convertSecToStr(this.item.AttAc,'H')+"";
			}
		},
		{key:'AttExtDayTime',			label:"<spring:message code='Cache.lbl_Add' /> <spring:message code='Cache.lbl_att_work' /> <spring:message code='Cache.lbl_scope' />",			width:'150', align:'center',		//사용유무
			formatter : function () {
           		 return ""+this.item.AttExtDayTime+"";
			}
		},
		{key:'JobStsName',  label:"<spring:message code='Cache.lbl_Gubun' />", width:'50', align:'center',
			formatter : function () {
           		 return (this.item.JobStsName=="O"?"<spring:message code='Cache.lbl_over'/>":(this.item.HolidayFlag=='2'?"<spring:message code='Cache.lbl_att_sch_holiday'/>":"<spring:message code='Cache.lbl_Holiday'/>"));
			}
		},
		{key:'ExtenAc',  label:"<spring:message code='Cache.lbl_apv_TimeTotal' />", width:'40', align:'center',
			formatter : function () {
           		 return AttendUtils.convertSecToStr(this.item.ExtenAc,'H')+"";
			}
		},
		{key:'ExtenDAc',  label:"<spring:message code='Cache.lbl_Weekly' />", width:'40', align:'center',
			formatter : function () {
           		 return ""+AttendUtils.convertSecToStr(this.item.ExtenDAc,'H')+"";
			}
		},
		{key:'ExtenNAc',  label:"<spring:message code='Cache.lbl_night' />", width:'40', align:'center',
			formatter : function () {
          		 return ""+AttendUtils.convertSecToStr(this.item.ExtenNAc,'H')+"";
			}
		},

];

$(document).ready(function(){
	var configObj = {
			targetID : "gridDiv",
			height : "auto",
			page : {
				pageNo: 1,
				pageSize: $("#listCntSel").val(),
			},
			paging : true
		};
		
	grid.setGridHeader(headerData);
	grid.setGridConfig(configObj);
	searchData();
	

	$("#listCntSel").change(function(){
		searchData();
	});
	
	//검색
	$("#btnRefresh").click(function(){
		searchData();
	});

	//excel down load
	$("#btnExcelDown").click(function(){
		var params = "StartDate="+ CFN_GetQueryString("StartDate")+
				"&EndDate="+ CFN_GetQueryString("EndDate")+
				"&UserCode="+CFN_GetQueryString("UserCode");
		AttendUtils.gridToExcel("<spring:message code='Cache.mag_Attendance44' />", headerData, params, "/groupware/attendReward/downloadExcelAttendRewardDetail.do"); //근무일정목록
	});
});

function searchData(){

	var params = {"StartDate": CFN_GetQueryString("StartDate")
				 ,"EndDate": CFN_GetQueryString("EndDate")
				, "UserCode":CFN_GetQueryString("UserCode")  };
	
	grid.page.pageNo = 1;
	grid.page.pageSize = $("#listCntSel").val();

	// bind
	grid.bindGrid({
		ajaxPars : params,
		ajaxUrl:"/groupware/attendReward/getAttendRewardDeatail.do"
	});

}

</script>