/**
 * communityBestContent - 우수커뮤니티 웹파트 
 */
var communityBestContent ={
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
				$("#bestCommunityContent").html("");
				
				if(f.list.length > 0){
					$(f.list).each(function(i,v){
						num ++;
						recResourceHTML += "<li class='clearFloat' onclick='communityBestContent.goUserCommunity("+v.CU_ID+")' style='cursor:pointer;'>";
						recResourceHTML += "<a href='#'>";
						recResourceHTML += "<div class='pcPhoto'>";
						if(v.FilePath != null && v.FilePath != ''){
							if(v.FileCheck == "true"){
								recResourceHTML += "<p><img src='"+v.FilePath+"'/></p>";
							}else{
								recResourceHTML += "<p><img src='/groupware/resources/images/img_default01.png' alt='커뮤니티사진' style='height:100%' class='mCS_img_loaded'></p>";
							}
						}else{
							recResourceHTML += "<p><img src='/groupware/resources/images/img_default01.png' alt='커뮤니티사진' style='height:100%' class='mCS_img_loaded'></p>";
						}	
						recResourceHTML += "</div>";
						recResourceHTML += "<div class='pcText'>";
						recResourceHTML += "<p>"+v.CommunityName+"</p>";
						recResourceHTML += "<p>"+v.SearchTitle+"</p>";
						recResourceHTML += "<p>멤버 : "+v.MemberCNT+"명</p>";
						recResourceHTML += "</div>";
						recResourceHTML += "</a></li>";
						
			    	});
				}
				
				$("#bestCommunityContent").html(recResourceHTML);
				
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
