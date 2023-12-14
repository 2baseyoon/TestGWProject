<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
#JobFunctionInsertMemberPopup {
	background-color:white;
	border: 1px solid black;
	display: none;
	position: fixed;
	_position: absolute;
	top: 100px;
	left: 50px;
	z-index: 100;
	height: auto;
	width: 410px;
}
#JobFunctionInsertMemberPopup.open {
	display: block
}

</style>

<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar" class="topbar_grid">
			<label>
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="refresh();"/>	<!--새로고침-->
				&nbsp;&nbsp;
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_Additional"/>" onclick="OrgMap_Open();"/> <!--추가-->
			</label>
		</div>
		<div id="jobFunctionMemberGrid"></div>
	</div>
</form>

<!-- 추가 팝업  -->
<div id="JobFunctionInsertMemberPopup" name="JobFunctionInsertMemberPopup">
	<form>
		<div class="pop_body1">
		    <div class="ztable_list">
	            <table class="AXFormTable" id="tableNewMember"  border="0" cellpadding="0" cellspacing="0" style="width:95%; font-size:12px;">
	            	<tbody id="tableNewMemberBody">
	                <tr>
	                    <th width="100" style="text-align:center;"><span class="table_top_last" style="text-align: center;"><spring:message code='Cache.lbl_apv_ChargerName'/></span></th> <!--담당자 명칭-->
	                    <th width="100" style="text-align:center;"><span class="table_top_last"  style="text-align: center;"><spring:message code='Cache.lbl_apv_ChargerCode'/></span></th> <!--담당자 코드-->
	                    <th width="100" style="text-align:center;"><span class="table_top_last"  style="text-align: center;"><spring:message code='Cache.lbl_apv_AdminDept'/></span></th>
	                    <th width="50" style="text-align:center;"><span class="table_top_last"  style="text-align: center;"><spring:message code='Cache.lbl_Sort'/></span></th> <!--정렬-->
	                </tr>
	                </tbody>
	            </table>
	       </div>
	       <br>
		   <div align="center" style="padding-top: 10px">
				<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton" /><!--저장-->
				<input type="button" value="<spring:message code='Cache.lbl_close'/>" onclick="closeLayer();"  class="AXButton" /><!--닫기-->
		   </div>
	    </div>
	</form>
</div>
<script>
	var param = location.search.substring(1).split('&');
	var jobFunctionID =param[0].split('=')[1];

	var myGrid = new coviGrid();

	// 그리드 헤더 설정
	var headerData =[
	                  {key:'UR_Name', label:'<spring:message code='Cache.lbl_apv_AdminName'/>', width:'100', align:'center',sort:"asc"},
	                  {key:'UserCode',  label:'<spring:message code='Cache.lbl_apv_AdminID'/>', width:'50', align:'center',sort:"asc"},
			      	  {key:'', label:'<spring:message code='Cache.btn_apv_delete'/>', width:'30', align:'center', //삭제
	                	  formatter:function () {
	                 		  return "<button type='button' class='AXButton' value='<spring:message code='Cache.btn_apv_delete'/>'  onclick='deleteMember("+ this.item.JobFunctionMemberID +"); return false;'><spring:message code='Cache.btn_apv_delete'/></button>"; //삭제
	                	  }
		      		  }
		      		];

	initRightJobFunction();
	
	function initRightJobFunction(){
		setGrid(); // 그리드 세팅
	}

	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
		gridDataBind();
	}

	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "jobFunctionMemberGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};

		myGrid.setGridConfig(configObj);
	}

	//그리드에 담당자 데이터 바인딩
	function gridDataBind(){
		//관리자페이지 - 결재업무담당자 페이지의 API 사용
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getJobFunctionMemberList.do",
	 			ajaxPars: {
	 				"JobFunctionID": jobFunctionID
	 			},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			   		myGrid.fnMakeNavi("myGrid");
				}
		});
	}

	// 새로고침
	function refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}

	function deleteMember(jobFunctionMemberID){
		//delete 호출
		//다국어 : 해당 담당자를 삭제하시겠습니까?, 담당자지정
		Common.Confirm("<spring:message code='Cache.msg_apv_392'/>","<spring:message code='Cache.lbl_apv_Charger'/>",function(result){
			if(result==true){
				$.ajax({
					type:"POST",
					data:{
						"JobFunctionMemberID" : jobFunctionMemberID
					},
					url:"/approval/admin/deleteJobFunctionMember.do",
					success:function (data) {
						if(data.result == "ok"){
							alert(data.message);
							refresh();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/admin/deleteJobFunctionMember.do", response, status, error);
					}
				});
			}
		});

	}

	function closeLayer(){
		var layerWindow = $('#JobFunctionInsertMemberPopup');
		layerWindow.removeClass('open');
	}

	function OrgMap_Open(){
		//다국어: 조직도
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=setMGRDEPTLIST&type=B1","1000px","580px","iframe",true,null,null,true);
	}

	//조직도선택후처리관련
	var peopleObj = {};
	//parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){
			var dataObj = $.parseJSON(peopleValue);
			if(dataObj[0].people.length > 0){
				$(dataObj[0].people).each(function(i){
					$("#tableNewMemberBody").append("<tr>");
					$("#tableNewMemberBody").append("<td align='center' id='UR_Name"+i+"'>"+dataObj[0].people[i].UR_Name+"</td>");
					$("#tableNewMemberBody").append("<td align='center' id='UR_Code"+i+"'>"+dataObj[0].people[i].UR_Code+"</td>");
					$("#tableNewMemberBody").append("<td align='center' id='DN_Name"+i+"'>"+dataObj[0].people[i].DN_Name+"</td>");
					$("#tableNewMemberBody").append("<td align='center' id='SortKey"+i+"'><input id='iptSortKey"+i+"' name='iptSortKey"+i+"' type='text' mode='numberint'  num_max='32767' class='AXInput'  onkeydown='CFN_NumberOnly(event);'  style='width:60px; height:17px; line-height:17px;'/></td>");
					$("#tableNewMemberBody").append("</tr>");
				})
				//팝업 표시
				$('#JobFunctionInsertMemberPopup').addClass('open');
			}else if(dataObj[0].dept.length > 0){
			}else{
			}
	}

	function saveSubmit(){
		//data셋팅

		var jobFunctionMemberArray = new Array();
		jQuery.ajaxSettings.traditional = true;
		$("#tableNewMemberBody tr:not(:first)").each(function(i){
		 	var jobFunctionMemberObj = new Object();
			jobFunctionMemberObj.JobFunctionID = jobFunctionID;
			jobFunctionMemberObj.Weight = '';
			jobFunctionMemberObj.UserCode = $("#UR_Code"+i).text();
			jobFunctionMemberObj.SortKey = $("#iptSortKey"+i).val();
			jobFunctionMemberArray.push(jobFunctionMemberObj);
		});


		//jsavaScript 객체를 JSON 객체로 변환
		jobFunctionMemberArray = JSON.stringify(jobFunctionMemberArray);

		$.ajax({
			type:"POST",
			data:{
				"jobFunctionMember" : jobFunctionMemberArray
			},
			url:"/approval/admin/insertJobFunctionMember.do",
			success:function (data) {
				if(data.result == "ok"){
					//다국어: 추가되었습니다. 담당자지정
					Common.Inform("<spring:message code='Cache.msg_AddXmlValue'/>.","<spring:message code='Cache.lbl_apv_Charger'/>",function(){
						closeLayer();
						refresh();
					})
				}

			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/insertJobFunctionMember.do", response, status, error);
			}
		});
	}

</script>