package egovframework.coviframework.vo;

import java.io.File;

public interface DRMIF {
	public File getDRMDecoding(File file, String fileFullNamePath) throws Exception;
	public File getDRMEncoding(File file, String fileFullNamePath) throws Exception;
}
