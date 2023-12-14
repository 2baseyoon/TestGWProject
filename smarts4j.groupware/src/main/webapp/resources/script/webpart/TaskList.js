/**
 * taskList - 업무관리
 */
var taskList ={
		webpartType: '', 
		init: function (data,ext){
			//수행할 업무
			$.each( data[0], function(index, value) {
				$("#taskList_performerList > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.FolderName+
						'</td><td>'
						+CFN_TransLocalTime(value.RegistDate)+
						'</a></td></tr>');
			});
			
			$.each( data[1], function(index, value) {
				$("#taskList_deadlineList > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.FolderName+
						'</td><td>'
						+CFN_TransLocalTime(value.RegistDate)+
						'</a></td><td style="text-align:center;">'
						+'D-'+value.DDay+
				'</td></tr>');
			});
			
			$.each( data[2], function(index, value) {
				$("#taskList_unReadList> tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.FolderName+
						'</td><td>'
						+CFN_TransLocalTime(value.RegistDate)+
						'</a></td></tr>');
			});
			$.each( data[3], function(index, value) {
				$("#taskList_startDelayList> tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.FolderName+
						'</td><td>'
						+value.DelayDay + "<spring:message code='Cache.lbl_DelayDate'/>" +
				'</a></td></tr>');
			});
			
			$.each( data[4], function(index, value) {
				$("#taskList_endDelayList> tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;"  >'
						+value.Subject+
						'</td><td>'
						+value.FolderName+
						'</td><td>'
						+value.DelayDay + "<spring:message code='Cache.lbl_DelayDate'/>" +
				'</a></td></tr>');
			});
		}
}

