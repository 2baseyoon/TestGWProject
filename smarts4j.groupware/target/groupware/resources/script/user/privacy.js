// 조직도 item
var orgMapDivEl = $("<div/>", {'class' : 'ui-autocomplete-multiselect-item', attr : {type : '', code : ''}})
	.append($("<span/>", {'class' : 'ui-icon ui-icon-close'}));

//이미지 callback
/*function callImgUploadCallBack(data, el) {
	if (data.length > 1) {
		alert('한개만 선택하여 주십시오.');
		return;
	}
	
	if ($('#updateFileId').val() != '') {
		$('#deleteFileId').val($('#updateFileId').val());
		$('#updateFileId').val('');
	}
	
	var src = coviCmn.commonVariables.frontPath + data[0].SavedName;
	var thumbSrc = src.split('.')[0] + '_thumb.jpg';
	$('#myImg').attr('src', thumbSrc).attr('orgSrc', src);
	$('#photoFileId').val(JSON.stringify(data));
	
	$('.divpop_close').click();
}*/

$(function() {
});














