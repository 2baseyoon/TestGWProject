package egovframework.coviaccount.common.validator;

import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

import egovframework.baseframework.data.CoviMap;

@Component
public class ExpenceApplicationDivValidator implements Validator {

	@Override
	public boolean supports(Class<?> clazz) {
		return false;
	}

	@Override
	public void validate(Object target, Errors errors) {
		CoviMap expenceApplicationDiv = (CoviMap) target;
		
		validateAmount(expenceApplicationDiv);
		validateStandardBriefId(expenceApplicationDiv);
	}
	
	private void validateAmount(CoviMap expenceApplicationDiv) {
		String amount = expenceApplicationDiv.getString("Amount");
		
		if (amount == null || amount.isEmpty()) {
			expenceApplicationDiv.put("Amount", 0);
		}
	}
	
	private void validateStandardBriefId(CoviMap expenceApplicationDiv) {
		String standardBriefId = expenceApplicationDiv.getString("StandardBriefID");
		
		if (standardBriefId == null || standardBriefId.isEmpty()) {
			expenceApplicationDiv.put("StandardBriefID", null);
		}
	}
}
