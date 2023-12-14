$.fn.serializeObject = function() {
    var obj = null;
    try {
        if ( this[0].tagName && this[0].tagName.toUpperCase() == "FORM" ) {
            var arr = this.serializeArray();
            if ( arr ) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });             
            }
        }
    }
    catch(e) {console.error(e.message);}
    finally  {}
     
    return obj;
};

var gridAdmin = {
	//Grid Header 항목 시작
	getGridHeader: function( pHeaderType ){
		var headerData;
		switch( pHeaderType ){
	
			case "baseCode":
				//개별호출-일괄호출
				Common.getDicList(["CodeGroup","CodeGroupName","Code","CodeName","IsUse","ModifierName","ModifyDate"]);
				headerData = [
					{ key:'CodeGroup',  label:Common.getDic("CodeGroup"), width:'110', align:'left'},
					{ key:'CodeGroupName',  label:Common.getDic("CodeGroupName"), width:'110', align:'left'},
					{ key:'Code',  label:Common.getDic("Code"), width:'110', align:'left'},
					{ key:'CodeName',  label:Common.getDic("CodeName"), width:'110', align:'left'},
					{ key:'IsUse',  label:Common.getDic("IsUse"), width:'110', align:'left'},
					{ key:'ModifierName',  label:Common.getDic("ModifierName"), width:'110', align:'left'},
					{ key:'ModifyDate',  label:Common.getDic("ModifyDate")+Common.getSession("UR_TimeZoneDisplay"), width:'110', align:'left',
        				formatter:function(){
        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
        				}, dataType:'DateTime'													
					},
		        ];
				break;
			default:	
		}
		return headerData;
	}
}