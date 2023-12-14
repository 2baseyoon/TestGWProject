package egovframework.core.auth;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.CommentSvc;


public class CommentAuth {
	/**
	 * 댓글 삭제 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getDeleteAuth(CoviMap params) {
		boolean bDeleteAuth = false;
		
		try {
			CommentSvc commentSvc = StaticContextAccessor.getBean(CommentSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			
			CoviMap commentInfo = commentSvc.selectOne(params).getJSONArray("list").getJSONObject(0);
			
			if(commentInfo.getString("RegisterCode").equals(SessionHelper.getSession("USERID")) || 
					"Y".equals(commentInfo.getString("AnonymousAuthYn")) || "true".equalsIgnoreCase(params.getString("commentDelAuth"))) {
				bDeleteAuth = true;
			}
			
		} 
		catch(NullPointerException ne) {
			return false;
		}
		catch(Exception e) {
			return false;
		}
		
		return bDeleteAuth;
	}
	
	private static void setParameter(CoviMap params) {
		String commentID = params.getString("CommentID");
		
		if(StringUtil.isNull(commentID)) {
			if(StringUtil.isNotNull(params.getString("targetID"))){
				commentID = params.getString("targetID");
			}else if(StringUtil.isNotNull(params.getString("commentID"))){
				commentID = params.getString("commentID");
			}
		}
		
		params.put("commentID", commentID);
		params.put("lang", SessionHelper.getSession("lang"));
	}
}
