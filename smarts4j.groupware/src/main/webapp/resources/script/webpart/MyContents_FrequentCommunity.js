/**
 * myContents_FrequentCommunity - 마이 컨텐츠 - 우수 커뮤니티
 */
var myContents_FrequentCommunity ={
	init: function (data,ext){
		myContents_FrequentCommunity.setFrequent();					//우수 커뮤니티 조회
	},
	setFrequent: function(){
		var recResourceHTML = "";
		var num = 0;
		
		$.ajax({
			url:"/groupware/layout/communityFrequent.do",
			type:"POST",
			async:false,
			data:{
				
			},
			success:function (f) {
				$("#myContents_FrequentCommunity_Contents").html("");
				
				if(f.list.length > 0){
					$(f.list).each(function(i,v){
						num ++;
						recResourceHTML += "<li class='clearFloat' onclick='myContents_FrequentCommunity.goUserCommunity("+v.CU_ID+")' style='cursor:pointer;'>";
						recResourceHTML += "<a href='#'>";
						recResourceHTML += "<div class='pcPhoto'>";
						if(v.FilePath != null && v.FilePath != ''){
							if(v.FileCheck == "true"){
								recResourceHTML += "<p><img src='"+coviCmn.loadImage(v.FilePath)+"' onerror='coviCmn.imgError(this);'/></p>";
							}else{
								recResourceHTML += "<p><img src='/groupware/resources/images/img_default01.png' style='height:100%' alt='커뮤니티사진' class='mCS_img_loaded'></p>";
							}
						}else{
							recResourceHTML += "<p><img src='/groupware/resources/images/img_default01.png' style='height:100%' alt='커뮤니티사진' class='mCS_img_loaded'></p>";
						}	
						recResourceHTML += "</div>";
						recResourceHTML += "<div class='pcText'>";
						recResourceHTML += "<p>"+v.CommunityName+"</p>";
						recResourceHTML += "<p>"+v.SearchTitle+"</p>";
						recResourceHTML += "<p>"+ "<spring:message code='Cache.lbl_MemberCount'/>" +" : " + v.MemberCNT + "<spring:message code='Cache.lbl_CountMan'/>" +"</p>";
						recResourceHTML += "</div>";
						recResourceHTML += "</a></li>";
						
			    	});
				}
				
				$("#myContents_FrequentCommunity_Contents").html(recResourceHTML);
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/layout/communityFrequent.do", response, status, error); 
			}
		}); 	
	},
	goUserCommunity:function(cID){
		 var specs = "left=10,top=10,width=1050,height=900";
		 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		 window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID, "community", specs);
	}
}
