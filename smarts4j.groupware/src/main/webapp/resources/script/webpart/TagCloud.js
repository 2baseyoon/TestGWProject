/**
 * tagCloud - 인기 태그 목록
 */
var tagCloud ={
		webpartType: '', 
		init: function (data,ext){
			$.each( data[0], function(index, value) {
				$("#tagCloud_tagList").append(value.Tag + "  " ); 
			});

		}
}

