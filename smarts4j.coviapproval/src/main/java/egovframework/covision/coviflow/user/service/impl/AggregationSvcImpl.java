package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.AggregationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AggregationUserService")
public class AggregationSvcImpl extends EgovAbstractServiceImpl implements AggregationSvc {

	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int getAggregationFormsCnt(CoviMap map) {
		map.put("isSaaS", isSaaS);
		return (int) coviMapperOne.getNumber("user.aggregation.selectAggregationFormsCnt", map);
	}

	@Override
	public CoviList getAggregationFormsSimple(CoviMap map) throws Exception {
		map.put("isSaaS", isSaaS);
		CoviList list = coviMapperOne.list("user.aggregation.selectAggregationForms", map);
		return CoviSelectSet.coviSelectJSON(list);
	}

	@Override
	public CoviMap getAggregationFormListByAggFormId(CoviMap map) throws Exception {
		map.put("isSaaS", isSaaS);

		CoviMap formInfo = coviMapperOne.selectOne("user.aggregation.selectFormInfoForAggregation", map);
		if (formInfo.isEmpty()) {
			throw new SecurityException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
		}

		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		CoviMap extInfo = CoviMap.fromObject(formInfo.getString("extInfo"));
		map.put("tableName", extInfo.getString("MainTable"));
		map.put("formPrefix", formInfo.getString("formPrefix"));

		CoviList fields = coviMapperOne.list("user.aggregation.selectAggregationFormFieldsByAggFormId", map);
		map.put("fields", fields);

		// sort 값이 사용 필드에 있는을때만 넘김
		String sortBy = map.optString("sortBy");
		if(!sortBy.isEmpty()) {
			String sortKey = sortBy.split(" ")[0];
			String sortDirection = sortBy.split(" ")[1];
			for (Object o : fields) {
				if (o instanceof CoviMap) {
					CoviMap jo = (CoviMap) o;
					String fieldId = jo.optString("fieldId");
					if(sortKey.equalsIgnoreCase(fieldId)) {
						map.put("sortColumn", sortKey);
						map.put("sortDirection", sortDirection);
						map.put("sortIsCommon", jo.optString("isCommon"));
					}
				}
			}
		}
		
		int cnt = (int) coviMapperOne.getNumber("user.aggregation.selectAggregationFormCount", map);
		page = ComUtils.setPagingData(map, cnt);
		map.addAll(page);

		CoviList list = coviMapperOne.list("user.aggregation.selectAggregationFormList", map);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);

		return resultList;
	}

	@Override
	public CoviList getAggregationFormHeaderByAggFormId(CoviMap map) throws Exception {
		CoviList fields = coviMapperOne.list("user.aggregation.selectAggregationFormFieldsByAggFormId", map);
		return CoviSelectSet.coviSelectJSON(fields);
	}

	@Override
	public CoviMap selectExcelData(CoviMap params, String headerKey) throws Exception {
		params.put("isSaaS", isSaaS);

		CoviMap formInfo = coviMapperOne.selectOne("user.aggregation.selectFormInfoForAggregation", params);
		if (formInfo.isEmpty()) {
			throw new SecurityException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
		}

		CoviMap extInfo = CoviMap.fromObject(formInfo.getString("extInfo"));
		params.put("tableName", extInfo.getString("MainTable"));
		params.put("formPrefix", formInfo.getString("formPrefix"));

		CoviList fields = coviMapperOne.list("user.aggregation.selectAggregationFormFieldsByAggFormId", params);
		params.put("fields", fields);

		// sort 값이 사용 필드에 있는을때만 넘김
		String sortColumn = params.optString("sortColumn");
		String sortDirection = params.optString("sortDirection");
		params.put("sortColumn","");
		params.put("sortDirection","");
		if(!sortColumn.isEmpty()) {
			for (Object o : fields) {
				if (o instanceof CoviMap) {
					CoviMap jo = (CoviMap) o;
					String fieldId = jo.optString("fieldId");
					if(sortColumn.equalsIgnoreCase(fieldId)) {
						params.put("sortColumn", sortColumn);
						params.put("sortDirection", sortDirection);
						params.put("sortIsCommon", jo.optString("isCommon"));
					}
				}
			}
		}
		
		CoviList list = coviMapperOne.list("user.aggregation.selectAggregationFormList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", egovframework.covision.coviflow.common.util.ComUtils.coviSelectJSONForApprovalList("",
				list, headerKey));

		return resultList;
	}
}
