package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface CoviCsSvc {

	public CoviMap getCsList(CoviMap params)throws Exception;
	public CoviMap getCsContents(CoviMap params) throws Exception;
	public CoviMap getCsContentsFile(CoviMap params) throws Exception;
}
