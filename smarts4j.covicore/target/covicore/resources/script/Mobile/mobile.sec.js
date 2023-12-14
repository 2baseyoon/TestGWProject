
function sendParam(ajaxParam){
	$.extend(ajaxParam,{
		beforeSend : function(xhr, opts){
			if (ajaxParam.type.toUpperCase() == "POST" 	&& ajaxParam.data != undefined){
				var objString = "";
				var tmpProto = Object.getPrototypeOf(ajaxParam.data);
	        	var keys = "";
	        	var vals = "";
				if (tmpProto == Object.getPrototypeOf(new FormData())){
		        	var params = ajaxParam.data;
		        	for (var pair of params.entries()) {
		        		if (pair[1].toString() != '[object File]' && !(pair[0]  == 'false' && pair[1].toString() == '[object Object]')){
			        		vals += pair[0]+"||"+coviSec.getHeader(pair[1],"SHA")+"††";
		        		}	
		        	}
				}else if(tmpProto == Object.getPrototypeOf({})){
		        	var params = ajaxParam.data;
		        	for (var key in params) {
		        		if (params.hasOwnProperty(key)){
			        		vals += key+"||"+coviSec.getHeader(params[key],"SHA")+"††";
		        		}	
		        	}		
				}else{
					vals = ajaxParam.data; 
				}	
				if (vals.length>0){
		        	xhr.setRequestHeader('CSA_SM',"" +  coviSec.getHeader(vals, "K"));
				}	
			}
		}});
		$.ajax(ajaxParam);
}
	
var coviSec = {
		getHeader : function(plainText, aesType){
			let keySize= 128/32;
			let iterationCount = 1000;
			let salt = "18b00b2fc5f0e0ee40447bba4dabc123";
			let iv   = "4378110db6392f93e95d5159dabde123";

			let passPhrase  = mobile_comm_getSession('UR_PrivateKey');
			switch (aesType){
				case "SHA256":
					return sha256(plainText); 
				case "SHA":
					return sha512(plainText); 
				default:
					let key = CryptoJS.PBKDF2(
							passPhrase, 
							  CryptoJS.enc.Hex.parse(salt),
							  { keySize: keySize, iterations: iterationCount });
					let encrypted = CryptoJS.AES.encrypt(
						  plainText,
						  key,
						  { iv: CryptoJS.enc.Hex.parse(iv) });
		
					return encrypted.ciphertext.toString(CryptoJS.enc.Base64);
					
			}	
		}

	}