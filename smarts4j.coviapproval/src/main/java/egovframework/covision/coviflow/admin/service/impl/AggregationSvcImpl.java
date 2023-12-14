package egovframework.covision.coviflow.admin.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.dto.AddAggregationFieldsRequestDTO;
import egovframework.covision.coviflow.admin.dto.AggregationAuth;
import egovframework.covision.coviflow.admin.dto.AggregationCommonField;
import egovframework.covision.coviflow.admin.dto.AggregationField;
import egovframework.covision.coviflow.admin.dto.AggregationForm;
import egovframework.covision.coviflow.admin.service.AggregationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AggregationAdminService")
public class AggregationSvcImpl extends EgovAbstractServiceImpl implements AggregationSvc {

	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getAggregationForms(CoviMap param) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		
		param.put("isSaaS", isSaaS);
		
		int listCnt = (int) coviMapperOne.getNumber("admin.aggregation.selectAggregationFormsCntByEntCode", param);
		
		pagingData = ComUtils.setPagingData(param, listCnt);
		param.addAll(pagingData);		
		
		String sortColumn = !StringUtil.isEmpty(param.getString("sortBy"))?param.getString("sortBy").split(" ")[0]:"";
		String sortDirection = !StringUtil.isEmpty(param.getString("sortBy"))?param.getString("sortBy").split(" ")[1]:"";
		param.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
		param.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
		CoviList list = coviMapperOne.list("admin.aggregation.selectAggregationFormsByEntCode", param);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page",pagingData);
		
		return resultList;
	}

	@Override
	public CoviList getApprovalFormsUsingSubTable(String entCode) throws Exception {
		CoviMap param = new CoviMap();
		param.put("entCode", entCode);
		param.put("isSaaS", isSaaS);
		CoviList list = coviMapperOne.list("admin.aggregation.selectFormsUsingSubTable", param);
		return CoviSelectSet.coviSelectJSON(list);
	}

	@Override
	public List<AggregationAuth> getAggregationFormAuth (CoviMap param) {
		return coviMapperOne.selectList("admin.aggregation.selectAggregationAuthByAggFormId", param);
	}
	
	@Override
	public List<AggregationField> getAggregationFormFields (CoviMap param) {
		return coviMapperOne.selectList("admin.aggregation.selectAggregationFieldsByAggFormId", param);
		
	}

	@SuppressWarnings("unchecked")
	@Override
	public void addAggregationForm(AggregationForm aggregationForm) throws Exception {
		// 같은 양식이 존재하는지 확인
		boolean isExist = coviMapperOne.selectOne("admin.aggregation.isExistAggregationForm", aggregationForm);
		if (isExist) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_duplication")); // 이미 존재하는 건 입니다.
		}

		// 1. form insert
		coviMapperOne.insert("admin.aggregation.insertAggregationForm", aggregationForm);

		// 2. default field insert
		// 2-1. insert commonFields
		CoviMap params = new CoviMap();
		params.put("aggFormId", aggregationForm.getAggFormId());
		params.put("entCode", aggregationForm.getEntCode());
		coviMapperOne.insert("admin.aggregation.insertAggregationFieldByCommonFields", params);

		// 2-2. select subtableinfo, insert subtableFields
		params.put("formPrefix", aggregationForm.getFormPrefix());
		params.put("isSaaS", isSaaS);
		CoviMap subTableInfo = CoviMap.fromObject(
				coviMapperOne.selectOne("admin.aggregation.selectSubTableInfoByFormPrefixAndEntCode", params));
		CoviList fields = subTableInfo.getJSONArray("MainTable");
		if (!fields.isEmpty() && !fields.getJSONObject(0).optString("FieldLabel").isEmpty()) {
			params.put("fields", fields);
			coviMapperOne.insert("admin.aggregation.insertAggregationFieldBySubTableInfo", params);
		}
	}

	@Override
	public void modifyAggrgationForm(AggregationForm aggregationForm) {
		coviMapperOne.update("admin.aggregation.updateAggregationForm", aggregationForm);
	}

	@Override
	public void deleteAggrgationFormByAggFormId(String aggFormId) {
		// 1. form delete
		coviMapperOne.delete("admin.aggregation.deleteAggrgationFormByAggFormId", aggFormId);

		// 2. fields delete
		coviMapperOne.delete("admin.aggregation.deleteAggrgationFieldsByAggFormId", aggFormId);
		
		// 3. auths delete
		coviMapperOne.delete("admin.aggregation.deleteAggrgationAuthsByAggFormId", aggFormId);
	}

	@Override
	public void addAggregationAuths(List<AggregationAuth> aggregationAuths) {
		// 이미 해당 양식에 권한이 있는지 확인
		for (AggregationAuth aggregationAuth : aggregationAuths) {
			boolean isExist = coviMapperOne.selectOne("admin.aggregation.isExistAggregationAuth", aggregationAuth);
			if (isExist)
				continue;
			coviMapperOne.insert("admin.aggregation.insertAggregationAuth", aggregationAuth);
		}
	}

	@Override
	public void deleteAggregationAuthByAggAuthIds(List<String> authIds) {
		coviMapperOne.delete("admin.aggregation.deleteAggregationAuthByAggAuthIds", authIds);
	}

	@Override
	public void addCommonField(AggregationCommonField commonField) throws Exception {
		boolean isExist = coviMapperOne.selectOne("admin.aggregation.isExistAggregationCommonField", commonField);
		if (isExist) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_duplication")); // 이미 존재하는 건 입니다.
		}
		coviMapperOne.insert("admin.aggregation.insertAggregationCommonField", commonField);
	}

	@Override
	public List<AggregationCommonField> getCommonFields(CoviMap param) {
		return coviMapperOne.selectList("admin.aggregation.selectAggregationCommonFields", param);
	}

	@Override
	public AggregationCommonField getCommonField(String fieldId) {
		return coviMapperOne.selectOne("admin.aggregation.selectAggregationCommonField", fieldId);
	}

	@Override
	public void modifyCommonField(AggregationCommonField commonField) {
		coviMapperOne.update("admin.aggregation.updateAggregationCommonField", commonField);
	}

	@Override
	public void deleteCommonField(AggregationCommonField commonField) {
		coviMapperOne.delete("admin.aggregation.deleteAggregationField", commonField);
		coviMapperOne.update("admin.aggregation.deleteAggregationCommonField", commonField);
	}

	@Override
	public CoviMap selectAggregationNotUsingFields(String aggFormId, String entCode) throws Exception {
		CoviMap aggregationFields = new CoviMap();

		CoviMap params = new CoviMap();
		params.put("aggFormId", aggFormId);
		params.put("entCode", entCode);
		params.put("isSaaS", isSaaS);

		CoviList commonFields = coviMapperOne.list("admin.aggregation.selectAggregationNotUsingCommonFields", params);
		aggregationFields.put("commonFields", CoviSelectSet.coviSelectJSON(commonFields));

		List<AggregationField> usingAggregationFields = coviMapperOne
				.selectList("admin.aggregation.selectAggregationNotCommonFieldsByAggFormId", aggFormId);
		CoviMap subTableInfo = CoviMap.fromObject(
				coviMapperOne.selectOne("admin.aggregation.selectSubTableInfoByAggFormId", params));
		CoviList fieldslist = new CoviList();
		for (Object o : subTableInfo.getJSONArray("MainTable")) {
			if (o instanceof CoviMap) {
				CoviMap jo = (CoviMap) o;
				String fieldName = jo.optString("FieldName");
				if (usingAggregationFields.stream().noneMatch(f -> f.getFieldId().equals(fieldName))) {
					fieldslist.add(jo);
				}
			}
		}
		aggregationFields.put("formFields", fieldslist);
		return aggregationFields;
	}

	@Override
	public int saveAggregationFields(CoviMap params, CoviList fieldList, CoviList oldFieldKey) throws Exception {
		int cnt = 0;
		
		/*
		 * 1. 입력한 필드(fieldList)가 없으면 모두 delete
		 * 2. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 있는값이면 update
		 * 3. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 없는값이면 insert
		 * 4. 삭제된필드 모두 delete - 2번에서 업데이트된 기존필드정보는 삭제하므로, 기존 필드(oldFieldKey) 중 남아있는값 
		 */
		if(fieldList.size() == 0) { // 1. 입력한 필드(fieldList)가 없으면 모두 delete
			cnt += coviMapperOne.delete("admin.aggregation.deleteAggregationFieldByFormId", params); // by aggFormId
		}else {
			for (int i = 0; i < fieldList.size(); i++) {
				CoviMap field = fieldList.getMap(i);
				//field.put("ComTableID",comTableID);
				field.putAll(params);
				
				boolean existOldField = false;
				for (int j = 0; j < oldFieldKey.size(); j++) {
					String oldFieldId = (String)oldFieldKey.get(j);
					String newFieldId = field.optString("aggFieldId");
					if(newFieldId.equals(oldFieldId)) { // 2. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 있는값이면 update
						cnt += coviMapperOne.update("admin.aggregation.updateAggregationField", field);
						existOldField = true;
						oldFieldKey.remove(j);
						break;
					}
				}
				// 3. 입력한 필드(fieldList)가 기존 필드(oldFieldKey)에 없는값이면 insert
				if(!existOldField) cnt += coviMapperOne.insert("admin.aggregation.insertAggregationField", field);
			}
			// 4. 삭제된필드 모두 delete - 2번에서 업데이트된 기존필드정보는 삭제하므로, 기존 필드(oldFieldKey) 중 남아있는값 
			for (int j = 0; j < oldFieldKey.size(); j++) {
				String oldFieldId = (String)oldFieldKey.get(j);
				params.put("aggFieldId", oldFieldId);
				cnt += coviMapperOne.delete("admin.aggregation.deleteAggregationFieldUnique", params);
			}
		}
		
		return cnt;
	}
}
