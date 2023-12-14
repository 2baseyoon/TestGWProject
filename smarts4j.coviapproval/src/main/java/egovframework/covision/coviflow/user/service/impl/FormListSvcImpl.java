package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.user.service.FormListSvc;

import org.apache.commons.lang3.StringUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("formListService")
public class FormListSvcImpl extends EgovAbstractServiceImpl implements FormListSvc 
{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getFormListData(CoviMap params) throws Exception 
	{
		
		CoviList list = coviMapperOne.list("user.formlList.selectFormListData", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "RowNumber,FormID,FormName,FormDesc,Favorite,FormPrefix,ExtInfo"));
		return resultList;
	}

	@Override
	public CoviMap getClassificationListData(CoviMap params) throws Exception
	{
		
		CoviMap classificationListObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.formlList.selectClassificationListData", params);
		classificationListObj.put("list",CoviSelectSet.coviSelectJSON(list, "FormClassID,FormClassName"));
		
		return classificationListObj;
	}
	@Override
	public CoviMap getLastestUsedFormListData(CoviMap params) throws Exception
	{
		
		CoviMap usedFormListObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.formlList.selectLastestUsedFormListData", params);
		usedFormListObj.put("list",CoviSelectSet.coviSelectJSON(list, "LabelText,FormID,FormPrefix,InitiatedDate"));
		
		return usedFormListObj;
	}

	@Override
	public CoviMap getFavoriteUsedFormListData(CoviMap params) throws Exception
	{
		
		CoviMap usedFormListObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.formlList.selectFavoriteUsedFormListData", params);
		usedFormListObj.put("list",CoviSelectSet.coviSelectJSON(list, "LabelText,FormID,FormPrefix"));
		
		return usedFormListObj;
	}
	
	@Override
	public CoviMap getHomeFavoriteFormListData(CoviMap params) throws Exception
	{
		
		CoviMap usedFormListObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.formlList.getHomeFavoriteFormListData", params);
		usedFormListObj.put("list",CoviSelectSet.coviSelectJSON(list));
		
		return usedFormListObj;
	}
	
	@Override
	public int addFavoriteUsedFormListData(CoviMap params) throws Exception
	{		
		return coviMapperOne.insert("user.formlList.insertFavoriteUsedFormListData", params);
	}
	
	@Override
	public int removeFavoriteUsedFormListData(CoviMap params) throws Exception
	{	
		return coviMapperOne.delete("user.formlList.deleteFavoriteUsedFormListData", params);
	}
	
	/**
	 * 최근기안(반려,완료함) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getCompleteAndRejectListData(CoviMap params) throws Exception
	{		
		CoviMap resultList = new CoviMap();		
		CoviList list = coviMapperOne.list("user.formlList.selectCompleteAndRejectListData", params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "ProcessArchiveID,PerformerID,WorkitemArchiveID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionArchiveID,FormInstID,SchemaID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,DocNo,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,EndDate,FormSubKind,TYPE"));		
		return resultList;
	}
	
	/**
	 * 최근기안(반려,완료함) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int getNotDocReadCnt(CoviMap params) throws Exception
	{	
		return (int) coviMapperOne.getNumber("user.formlList.selectNotDocReadCnt", params);
	}
	
	@Override
	public int selectFavoriteAuth(CoviMap params) {
		return (int) coviMapperOne.getNumber("user.formlList.selectFavoriteAuth", params);
	}

	@Override
	public int updateFavoriteUsedFormSort(CoviMap params) throws Exception {
		int result = 0;
		String [] formList = StringUtils.split(params.optString("sortList"), ";");
		CoviList updateList = new CoviList();
		for(int i = 0; formList != null && i < formList.length; i++) {
			CoviMap map = new CoviMap();
			map.put("FormID", formList[i]);
			map.put("SortKey", (i + 1));
			updateList.add(map);
		}
		if(updateList.size() > 0) {
			params.put("sortList", updateList);
			result = coviMapperOne.update("user.formlList.updateFavoriteUsedFormSort", params);
		}
		return result;
	}
}
