/**
 * userFormList.js - 미결함 
 */
function initUserFormListDiv(data){
	var webpartType = '';
	$.each(data.list, function(index, value) {
		$("#userFormList > tbody").append('<tr><td height="25">'+value.LabelText+'</td><tr>');
	});
}