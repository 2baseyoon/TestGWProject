
/**
 * 모바일 포탈현황 조회 웹파트
 */
var MWP_SummaryBox = {
	
	init: function(pData,ext){
		var isUseMail = mobile_comm_getSession('UR_UseMailConnect');		// CP메일 미사용자는 모바일 요약화면에서 메일 영역 보이지 않게 처리
		if (isUseMail == 'Y'){
			$(".metroviewL [class^=m_]").show();
		}
		else {
			$(".metroviewL .m_schedule a").height('225px');
			$(".metroviewL .m_schedule").show();
		}
		
		try {
			/////// 카운트 처리  START ////////
			// QuickData - 메일, 일정, 미결함 카운트
			
			var url = "/groupware/longpolling/getQuickData.do";
		    $.ajax({ 
		    	type : "POST",
				url: url,
				data : { "menuListStr" : "Mail;Approval;Schedule;" },
				success: function(data){
					// 메일
					if(data.countObj.Mail > 0) {
						if(data.countObj.Mail > 99) {
							$("#pCntMailNew").html("99+");
						} else {
							$("#pCntMailNew").html(data.countObj.Mail)
						}					
					}
					// 일정
					if(data.countObj.Schedule > 0) {
						if(data.countObj.Schedule > 99) {
							$("#pCntScheduleNew").html("99+");
						} else {
							$("#pCntScheduleNew").html(data.countObj.Schedule)
						}				
					}
					// 결재
					if(data.countObj.Approval > 0) {
						if(data.countObj.Approval > 99) {
							$("#pCntAppval").html("99+");
						} else {
							$("#pCntAppval").html(data.countObj.Approval)
						}
					}			
				}, 
				error:function(response, status, error){
					mobile_comm_ajaxerror(url, response, status, error);
				},
				dataType: "json"
		    });
		    
			// 진행함 카운트 - pCntAppIng
			url = "/approval/user/getProcessCnt.do";
		    $.ajax({ 
		    	type : "POST",
				url: url,
				success: function(data){
					// 메일
					if(data.cnt > 0) {
						if(data.cnt > 99) {
							$("#pCntAppIng").html("99+");
						} else {
							$("#pCntAppIng").html(data.cnt)
						}					
					}
				}, 
				error:function(response, status, error){
					mobile_comm_ajaxerror(url, response, status, error);
				},
				dataType: "json"
		    });
		    
		    //참조/회람함 카운트 - pCntAppRe
			url = "/approval/user/getTCInfoNotDocReadCnt.do";
		    $.ajax({ 
		    	type : "POST",
				url: url,
				success: function(data){
					// 메일
					if(data.cnt > 0) {
						if(data.cnt > 99) {
							$("#pCntAppRe").html("99+");
						} else {
							$("#pCntAppRe").html(data.cnt)
						}					
					}
				}, 
				error:function(response, status, error){
					mobile_comm_ajaxerror(url, response, status, error);
				},
				dataType: "json"
		    });
		    ///// 카운트 처리  END ////////
		}
		catch(e){mobile_comm_log(e);}
	}	
}