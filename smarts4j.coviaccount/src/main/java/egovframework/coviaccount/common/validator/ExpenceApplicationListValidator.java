package egovframework.coviaccount.common.validator;

import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

import egovframework.baseframework.data.CoviMap;

@Component
public class ExpenceApplicationListValidator implements Validator {

	@Override
	public boolean supports(Class<?> clazz) {
		return false;
	}

	@Override
	public void validate(Object target, Errors errors) {
		CoviMap expenceApplicationList = (CoviMap) target;
		
		validateRealPayAmount(expenceApplicationList);
	}
	
	private void validateRealPayAmount(CoviMap expenceApplicationList) {
		String realPayAmount = expenceApplicationList.getString("RealPayAmount");
		
		if (realPayAmount == null || realPayAmount.isEmpty()) {
			expenceApplicationList.put("RealPayAmount", 0);
		}
	}
}
