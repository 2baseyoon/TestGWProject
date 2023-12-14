var baseConfigList = {
	webpartType: '', 
	getBaseConfig: function(){
		if($("#baseConfigList_baseCodeID").val()!=''){
			$("#baseConfigList_baseCodeResult").val(Common.getBaseConfig($("#baseConfigList_baseCodeID").val()));
		}
	}
}