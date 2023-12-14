package egovframework.covision.groupware.portal.user.service;

import java.io.IOException;

public interface TemplateFileCacheSvc {
	String readAllText(String lang, String file, String encoding) throws IOException;
}
