<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<div class="l-contents-tabs">
	<div id="fixedTabDiv" class="l-contents-tabs__fixed-tab l-contents-tabs__fixed-tab--active">
		<a id="fixedTabAcc" name="tab" url="/account/accountPortal/portalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=A" class="l-contents-tabs__main-tab">
			<i class="tab_eaccountingico_03"></i>
			<div class="l-contents-tabs__title">Home</div>
		</a>
	</div>
	
	<div id="eAccountTabList" class="l-contents-tabs__list">
		<div id="eAccountTabListDiv"></div>
		<div id="eAccountTabMoreDiv" class="l-contents-tabs__more-item" style="display:none">
			<a id="eAccountTabMoreA" class="l-contents-tabs__btn-more">
				<i class="i-etc--mail"></i>
			</a>
			<div id="eAccountTabMoreItems" class="l-contents-tabs__more-pop">
			</div>
		</div>
	</div>
</div>

<script>
	
	getMaxTabSize();
	
	$('#eAccountTabListDiv').sortable({
		update:function(e,u){
			var order = $(this).sortable('toArray',{
					attribute : 'data-order'
			});
		}
	});
</script>