package egovframework.covision.coviflow.form.service;

import java.io.IOException;

public interface FormFileCacheSvc {
	public String readAllText(String lang, String file, String encoding) throws IOException;
	public String readAllText(String lang, String file, String encoding, String companyCode) throws IOException;
}
