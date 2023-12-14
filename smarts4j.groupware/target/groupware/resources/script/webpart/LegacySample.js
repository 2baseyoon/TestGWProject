/**
 * legacySample - Legacy 프로젝트 연동 Sample
 */
var legacySample ={
	webpartType: '',
	init: function (data,ext){
		legacySample.getSampleData();
	},
	getSampleData : function(){
		$.ajax({
			url:"/legacy/webpart/getSampleData.do", //   local - http://localhost:8082/legacy/webpart/getSampleData.do   server- /legacy/webpart/getSampleData.do
			type: "POST",
			success:function(data){
				$(data.list).each(function(idx, obj){
					$("#legacySample_sampleList ul").append('<li><a class="title" target="_blank">' + obj.itemId + ". " + obj.itemVal + '</a></li>');
				});
			}
		});
	}
}


