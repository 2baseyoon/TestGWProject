/**
 * approvalBox - 전자결재 - 결재함
 */
// 회사별 휴가자 값 세팅
function changeCompany(){
	$.ajax({
		url	: "/groupware/ceoPortal/getDeptVacationList.do",
		type: "POST",
		data: {
				"companycode"  :$("#selectCompany").val()
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				var cnt = data.Cnt;
				$("#ceoVaction .ProjectCEO_Cont .personnelC font").text(data.Cnt);
				$("#ceoVaction .VacationerList_Scroll ul").html("");
				
				var iVacCnt = 0;
				$.each( data.list, function(index, value) {
					iVacCnt = iVacCnt + parseInt(value.Cnt);
					$("#ceoVaction .VacationerList_Scroll ul").append('<li><span class="CEOBbullet"></span><span class="VTitle">'+value.DeptName+'</span><span class="VPer"><strong>'+value.Cnt+'</strong>명</span></li>');
				});	
				$("#ceoVaction .ProjectCEO_Cont .personnelT .ST").text(iVacCnt);
				var rotate = 0;
				if (data.Cnt > 0)
				{	
					rotate = 360*(Math.round(iVacCnt/data.Cnt*100)/100);
				}	
				$("#ceoVaction .ProjectCEO_Cont .cyclePrograssBar #slice .pie").css('transform','rotate('+rotate+'deg)');

			}else{
				Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
			}
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
		}
	});
	
}
	
var ceoVacationBox ={
		webpartType: '', 
		init: function (data,ext){
			coviCtrl.renderCompanyAXSelect('selectCompany', 'ko',false, 'changeCompany', '', Common.getSession("DN_Code"));
			$("#selectCompany").bindSelectRemoveOptions([{optionValue:"ORGROOT", optionText:"액시스제이"}]);
			$("#ceoVaction .ProjectCEO_Toptitle").text(CFN_GetLocalCurrentDate("MM.dd")+" 휴가자 현황");
			if (data[0].length == undefined || data[0].length ==0) $("#ceoVaction .ProjectCEO_none").show();
			var iVacCnt = 0;	

			$.each( data[0], function(index, value) {
				iVacCnt = iVacCnt + parseInt(value.Cnt);
				$("#ceoVaction .VacationerList_Scroll ul").append('<li><span class="CEOBbullet"></span><span class="VTitle">'+value.DeptName+'</span><span class="VPer"><strong>'+value.Cnt+'</strong>명</span></li>');
			});	
			$("#ceoVaction .ProjectCEO_Cont .personnelC font").text(data[1][0].Cnt);
			$("#ceoVaction .ProjectCEO_Cont .personnelT .ST").text(iVacCnt);
			var rotate = 0;
			if (data[1][0].Cnt > 0)
			{	
				rotate = 360*(Math.round(iVacCnt/data[1][0].Cnt*100)/100);
			}	
			$("#ceoVaction .ProjectCEO_Cont .cyclePrograssBar #slice .pie").css('transform','rotate('+rotate+'deg)');

			
		}
}

