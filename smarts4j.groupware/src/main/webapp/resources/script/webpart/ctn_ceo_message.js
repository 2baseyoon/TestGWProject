var ceoMessage = {
	init: function(data, ext, caller, webpartID) {
		let cssPath = Common.getGlobalProperties("css.path");
		let $this = this;
		let message = "";
		$this.mode = ext.mode
		if (data[0][0].result){
			let result = data[0][0].result;
			message = result.message;
			$("#"+webpartID + " .widget_option").append(Base64.b64_to_utf8(result.appendAuth));
			$("#" + webpartID + " .widget_option [data-action=setting]").on("click", function() { // option > 설정 버튼 이벤트
				$this.openPopup(webpartID, ext.settingKey);
			});
		}	
        if (ext.mode=="R"){
			$("#"+webpartID+" .message")
				.append($("<p>",{"text":message}))
				.append($("<img>",{"src":cssPath.replace("_n","")+"/customizing/ptype07/images/project/ceo.png"}));
        }else{
			$("#"+webpartID+" .message").append($("<div>",{"class":"avatar"})
							.append($("<img>",{"src":cssPath.replace("_n","")+"/covicore/resources/images/sample/avatar/1.jpg"}))
							.append($("<strong>",{"text":Common.getBaseConfig("VacationPromotionSubject")})))
						.append($("<p>",{"text":message}));
        }	
	},
	openPopup:function(webpartID, settingKey){
		Common.open("", "CeoMessagePopup", "Ceo Message", "/groupware/portal/CeoMessagePopup.do?webpartID="+webpartID+"&settingKey="+settingKey+"&popupID=ceoMessage", "300px", "300px", "iframe", true, null, null, true); 
		return new Promise(resolve => {
			const listener = (e) => {
				if (e.data.functionName == "ceoMessage"){
					var params = e.data.params;
					console.log(params)
					if (params.status=="SUCCESS"){
						$("#WP"+params["webpartID"]+" .message p").text(params["message"]);
					}	
					window.removeEventListener('message', listener)
				}	
			}
			
			window.addEventListener('message', listener)
		})
	}
}
