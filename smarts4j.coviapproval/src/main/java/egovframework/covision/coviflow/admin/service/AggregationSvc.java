package egovframework.covision.coviflow.admin.service;

import java.util.List;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.covision.coviflow.admin.dto.AddAggregationFieldsRequestDTO;
import egovframework.covision.coviflow.admin.dto.AggregationAuth;
import egovframework.covision.coviflow.admin.dto.AggregationCommonField;
import egovframework.covision.coviflow.admin.dto.AggregationField;
import egovframework.covision.coviflow.admin.dto.AggregationForm;

public interface AggregationSvc {

	CoviMap getAggregationForms(CoviMap param) throws Exception;
	
	CoviList getApprovalFormsUsingSubTable(String entCode) throws Exception;
	
	List<AggregationAuth> getAggregationFormAuth(CoviMap param) throws Exception;
	List<AggregationField> getAggregationFormFields (CoviMap param) throws Exception;
	
	void addAggregationForm(AggregationForm aggregationForm) throws Exception;

	void modifyAggrgationForm(AggregationForm aggregationForm);

	void deleteAggrgationFormByAggFormId(String aggFormId);

	void addAggregationAuths(List<AggregationAuth> aggregationAuths);

	void addCommonField(AggregationCommonField commonField) throws Exception;

	List<AggregationCommonField> getCommonFields(CoviMap param);

	AggregationCommonField getCommonField(String fieldId);

	void modifyCommonField(AggregationCommonField commonField);

	void deleteCommonField(AggregationCommonField commonField);

	void deleteAggregationAuthByAggAuthIds(List<String> authIds);

	CoviMap selectAggregationNotUsingFields(String aggFormId, String entCode) throws Exception;

	int saveAggregationFields(CoviMap params, CoviList fieldList, CoviList oldFieldList) throws Exception;
}
