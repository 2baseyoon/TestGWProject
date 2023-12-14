var passwordExpirationDate = {
		init: function(data, ext, caller){
			$.ajax({
				type: "POST",
				url: "/groupware/pnPortal/getPasswordExpirationDate.do",
				success: function(data){
					var daysLeft;
					if(data.status == "SUCCESS"){
						daysLeft = data.result;
					}else{
						daysLeft = 999;
					}
					$("#PN_pwInfo_DaysLeft").text(Common.getDic("lbl_days_left").replace("{0}",daysLeft));
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/pnPortal/getPasswordExpirationDate.do", response, status, error);
		    	}
			});
			
		}
}