package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface MenuAdminMenuSvc {
	public CoviMap select(CoviMap params, int pno) throws Exception;
	public Object insert(CoviMap paramCN, String paramGR, CoviMap paramDic)throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public CoviMap selectAuth(CoviMap params) throws Exception;
	public Object update(CoviMap paramCN, String paramGR, CoviMap paramDic)throws Exception;
	public Object updateIsUse(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
}
