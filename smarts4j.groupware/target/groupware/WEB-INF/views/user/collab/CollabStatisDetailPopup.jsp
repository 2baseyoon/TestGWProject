<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="layer_divpop cRContCollabo" style="width:100%; left:0; top:0; z-index:104;" id="collabStatisPopup">
	<div class='cRConTop titType'>
		<h2 class="title">
		<span>${prjData.PrjName}</span><!-- T/F 팀룸 -->
		<div class="searchBox02">
			<select id="searchType" class="selectType02">
				<option value="1"><spring:message code='Cache.lbl_subject'/></option> <!-- 제목 -->
				<option value="2"><spring:message code='Cache.lbl_Contents' /></option> <!-- 내용 -->
				<option value="3"><spring:message code='Cache.lbl_Tag' /></option> <!-- 태그 -->
				<option value="4"><spring:message code='Cache.lbl_subject' /> + <spring:message code='Cache.lbl_Contents' /> + <spring:message code='Cache.lbl_Tag' /></option> <!-- 제목 + 내용 + 태그 -->
			</select>
			<span><input type="text" id="seValue"  />
			<button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.lbl_search'/></button></span>
		</div>
	</div>
	<div class="Project_list_co modern" style="display: block;">
		<div class="Project_list_01">
			<p class="Project_tit"><spring:message code='Cache.lbl_Urgency' />/<spring:message code='Cache.lbl_Delay' />/<spring:message code='Cache.lbl_importance' /></p>
				<ul>
					<li class="bg01 bg01_1">
						<a href="#" class="">
							<span class="txt"><spring:message code='Cache.lbl_Urgency' /></span> </span>
							<strong class="num"><span class="pro_urgent" id="enum">${prjStat.EmgCnt}</span></strong>
						</a>
					</li>
					<li class="bg01 bg01_2">
						<a href="#" class="">
							<span class="txt"><spring:message code='Cache.lbl_Delay' /></span></span>
							<strong class="num" id=dnum><span class="pro_important">${prjStat.DelayCnt}</span></strong>
						</a>
					</li>
					<li class="bg02">
						<a href="#" class="">
							<span class="txt"><spring:message code='Cache.lbl_importance' /></span>
							<div class="num_case_area">
								<span class="num_case num_up" id="lvlhnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_2' /></span><strong class="num">${prjStat.LvlHCnt}</strong></span>
								<span class="num_case num_equal" id="lvlmnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_3' /></span><strong class="num">${prjStat.LvlMCnt}</strong></span>
								<span class="num_case num_down" id="lvllnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_4' /></span><strong class="num">${prjStat.LvlLCnt}</strong></span>
							</div>
						</a>
					</li>						
				</ul>	
			</div>							
			<div class="Project_list_02">
				<ul>
					<p class="Project_tit"><spring:message code='Cache.btn_All'/></p>
					<div class="total_progress">
						<strong class="num" id="tnum">${prjStat.TotCnt }</strong>
					</div>
					<li class="bg03">
						<a href="#" class="">
							<div class="total_num_case">
								<ul>
									<li class="tnum01" id="wnum"><span><spring:message code='Cache.lbl_Ready' /></span><strong>${prjStat.WaitCnt }</strong></li>
									<li class="tnum02" id="pnum"><span><spring:message code='Cache.lbl_Progress' /></span><strong>${prjStat.ProcCnt }</strong></li>
									<li class="tnum03" id="hnum"><span><spring:message code='Cache.lbl_Hold' /></span><strong>${prjStat.HoldCnt }</strong></li>
									<li class="tnum04" id="cnum"><span><spring:message code='Cache.lbl_Completed' /></span><strong>${prjStat.CompCnt }</strong></li>
								</ul>
							</div>
						</a>
					</li>
				</ul>
			</div>		
			<div class="Project_list_03">
				<ul>
					<li class="bg04">
						<a href="#" class=""> 
							<span class="txt"><spring:message code='Cache.lbl_Project' /><Br>
								<spring:message code='Cache.lbl_TFProgressing' />
							</span> <!-- 프로젝트 진행률 -->
							<div class="Project_cycleCont">
								<div class="cycleBg">
									<div class="pie"></div>
									<div class="cycleTxt">
										<div class="inner">
											<strong class="cNum"><fmt:parseNumber value="${prjStat.ProjRate}" pattern=".0"/><span>%</span></strong>
										</div>
									</div>
								</div>
								<div id="slice" ${prjStat.ProjRate>49?"class='gt50'":"" }>
									<div class="pie" id="pieDiv" style="transform: rotate( ${360 - 360 * (prjStat.ProjRate/100)}deg);"></div>
									<div class="pie fill"></div>
								</div>
							</div>
						</a>
					</li>
				</ul>
			</div>	
	</div>
		<div class="selectBox" id="selectBoxDiv">
			<span>	
				<div class="chkStyle10">
					<input type="checkbox" class="check_class" id="chk_p" value="Section" checked>
					<label for="chk_p"><span class="s_check"></span><spring:message code='Cache.lbl_BySection' /></label> <!-- 섹션별 -->
				</div>
				<div class="chkStyle10">
					<input type="checkbox" class="check_class" id="chk_w" value="TaskStatus" >
					<label for="chk_w"><span class="s_check"></span><spring:message code='Cache.lbl_ByCondition' /></label> <!-- 상태별 -->
				</div>
				<div class="chkStyle10">
					<input type="checkbox" class="check_class" id="chk_h" value="Member" >
					<label for="chk_h"><span class="s_check"></span><spring:message code='Cache.lbl_ByPerson' /></label> <!-- 담당자별 -->
				</div>	
			</span>	
			<select class="selectType01" id="selectSize">
				<option>10</option>
				<option>20</option>
				<option>30</option>
			</select>
			<button href="#" class="btnMoreStyle01 btnExcel" id="btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></button> 
			<button href="#" class="btnRefresh" type="button"></button>							
		</div>
		<div class="tblList tblCont">
			<form id="form1">
				<div id="collabStatisPopupDiv">
				</div>
			</form>
		</div>
	</div>
</div>
<script type="text/javascript">
var collabStatisPopup = {
		grid:'',
		objectInit : function(){		
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
		}	,
		makeGrid :function(){
			var configObj = {	targetID : "collabStatisPopupDiv",height : "auto",
					page : {pageNo: 1,pageSize: 10,},
					paging : true};
			var headerData = [
					{key:'GroupName', label:collabStatisPopup.checkedBoxName(),width:'2', align:'left', display:true}, //이름
					{key:'TotCnt',  label:"<spring:message code='Cache.lbl_TotalNumber' />",width:'1',align:'center',display:true,formatter:function(){ //총건수
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'WaitCnt',  label:"<spring:message code='Cache.lbl_Ready' />",width:'1',align:'center',display:true,formatter:function(){ //대기
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'ProcCnt',  label:"<spring:message code='Cache.lbl_Progress' />",width:'1',align:'center',display:true,formatter:function(){ //진행
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'HoldCnt',  label:"<spring:message code='Cache.lbl_Hold' />",width:'1',align:'center',display:true,formatter:function(){ //보류
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'CompCnt',  label:"<spring:message code='Cache.lbl_Completed' />",width:'1',align:'center',display:true,formatter:function(){ //완료
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'DelayCnt',  label:"<spring:message code='Cache.lbl_Delay' />",width:'1',align:'center',display:true,formatter:function(){ //지연
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'EmgCnt',  label:"<spring:message code='Cache.lbl_Urgency' />",width:'1',align:'center',display:true,formatter:function(){ //긴급
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'ImpCnt',  label:"<spring:message code='Cache.lbl_Important' />",width:'1',align:'center',display:true,formatter:function(){ //중요
						return this.item.TotCnt=="0"?"":"<a href='#' id='btnStatic' mode='"+this.key+"'>"+this.item[this.key]+"</a>";   
					}}, 
					{key:'ProcRate',  label:"<spring:message code='Cache.lbl_TFProgressing' />",width:'2',align:'center',display:true}  //진행률
     		];
			this.grid = new coviGrid();
			this.grid.setGridHeader(headerData);
			this.grid.setGridConfig(configObj);
		},
		addEvent : function(){
			$('#collabStatisPopup #seValue' ).on( 'keypress', function(e){
				if(event.keyCode==13) {collabStatisPopup.searchData(1); return false;}
			});
			$('#collabStatisPopup #selectSize' ).on( 'change', function(e){
				collabStatisPopup.searchData(1);
			});
			
			$('#collabStatisPopup #btnSearch, #collabStatisPopup .btnRefresh' ).on( 'click', function(e){
				collabStatisPopup.searchData(1);
			});
			
			$('#collabStatisPopup #btnExcel').on( 'click', function(e){
				collabStatisPopup.exportExcel();
			});
			
			$(".check_class").click(function() {
				 $('.check_class').not(this).prop("checked", false);
				 
				 if(!$('.check_class').is(':checked')) {
					 $("input:checkbox[id='chk_p']").prop("checked", true);
				 }
				 
				 collabStatisPopup.searchData(1);
			});
			//통계보기
			$(document).on("click","#collabStatisPopupDiv #btnStatic",function(){
				var obj = collabStatisPopup;
				var gridData =obj.grid.getSelectedItem()["item"];
				var gridCol = obj.grid._colGroup;
				var colKey = $(this).attr("mode");
				var colLabel 
				$.each(gridCol, function( idx, item ){
					if (item.key == colKey){
						colLabel= item.label;
						return;
					}	
				});
				
				var popupID	= "CollabStatisPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabStatis/CollabStatisPopup.do?"
		 						+ "groupKey="+$('.check_class:checked').val()
		 						+ "&groupCode="+gridData.GroupCol
		 						+ "&groupName="+encodeURIComponent(gridData.GroupName)
		 						+ "&prjType=${prjType}"
		 						+ "&prjSeq=${prjSeq}"
		 						+ "&prjName="+encodeURIComponent("${prjData.PrjName}")
		 						+ "&searchOption="+$("#searchType").val()
		 						+ "&searchKeyword="+encodeURIComponent($("#seValue").val())
		 						+ "&mode="+colKey
		 						+ "&modeName="+encodeURIComponent(colLabel)
		 						+ "&popupID="	 + popupID;

				parent.Common.open("", popupID, "<spring:message code='Cache.lbl_apv_processState'/>", popupUrl, "850", "650", "iframe", true, null, null, true);
			});		
			
		},
		searchData:function(pageNo){
			this.makeGrid();
			var trgArr = new Array();
			
			var params = {"mode" : "L","prjType":"${prjType}","prjSeq":"${prjSeq}", "groupBy":$('.check_class:checked').val()
					, "searchKeyword" : $("#seValue").val(), "searchOption" : $("#searchType").val()};
			if (pageNo !="-1"){
				this.grid.page.pageNo =pageNo;
				this.grid.page.pageSize = $('#collabStatisPopup #selectSize').val();
			}	
			// bind
			this.grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabStatis/getCurstList.do"
			});

		},//엑설
		exportExcel:function(){
			var params = "mode=L&"
				+"&prjName="+encodeURIComponent("${prjData.PrjName}")
				+"&prjType="+"${prjType}"
				+"&prjSeq="+"${prjSeq}"
				+"&groupBy="+$('.check_class:checked').val()
				+"&searchKeyword="+encodeURIComponent($("#seValue").val());

		        if (confirm(Common.getDic("msg_WantToDownload"))) { //다운로드 하시겠습니까?
	            location.href= '/groupware/collabStatis/exportCurstList.do?'+params;
	        }
		},
		checkedBoxName:function() {
			if($('.check_class:checked').val() == "Section") {
				return "<spring:message code='Cache.lbl_sectionName'/>"; // 섹션명
			}
			if($('.check_class:checked').val() == "TaskStatus") {
				return "<spring:message code='Cache.lbl_State'/>"; // 상태
			}
			if($('.check_class:checked').val() == "Member") {
				return "<spring:message code='Cache.lbl_charge'/>"; // 담당자
			}
		}
	}
$(document).ready(function(){
	collabStatisPopup.objectInit();
});
</script>