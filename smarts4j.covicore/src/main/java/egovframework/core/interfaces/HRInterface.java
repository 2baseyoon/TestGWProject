package egovframework.core.interfaces;

import java.util.Map;

public interface HRInterface {
	public void init() throws Exception;
	public Map<String, Object> getHRData() throws Exception;
}