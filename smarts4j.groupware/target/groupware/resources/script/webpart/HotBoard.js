/**
 * hotBoard - 인기 게시판
 */
var hotBoard ={
		webpartType: '', 
		init: function (data,ext){
			$.each( data[0], function(index, value) {
				$("#hotBoard_mostLike > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.LikeCnt+
						'</a></td></tr>');
			});
			
			$.each( data[1], function(index, value) {
				$("#hotBoard_maxComment > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.CommentCnt+
						'</a></td></tr>');
			});
			
			$.each( data[2], function(index, value) {
				$("#hotBoard_maxRead > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.ReadCnt+
						'</a></td></tr>');
			});
		}
}

