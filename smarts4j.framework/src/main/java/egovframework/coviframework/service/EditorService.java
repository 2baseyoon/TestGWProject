package egovframework.coviframework.service;


import egovframework.baseframework.data.CoviMap;

public interface EditorService {
	public CoviMap getContent(CoviMap editorParam) throws Exception;
	public CoviMap getEscapeContent(CoviMap editorParam) throws Exception;
	public CoviMap getInlineValue(CoviMap editorParam) throws Exception;
	public CoviMap getInlineValue(CoviMap editorParam, boolean isEscape) throws Exception;
	public void updateFileMessageID(CoviMap editorParam) throws Exception;
	public void updateFileObjectID(CoviMap editorParam) throws Exception;
	int deleteInlineFile(CoviMap editorParam) throws Exception;
}
