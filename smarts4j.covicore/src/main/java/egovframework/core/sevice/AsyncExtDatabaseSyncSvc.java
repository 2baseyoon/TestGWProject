package egovframework.core.sevice;

import org.springframework.scheduling.annotation.Async;

import egovframework.baseframework.data.CoviMap;


public interface AsyncExtDatabaseSyncSvc {
	@Async
	public void execute(final CoviMap targetInfo) throws Exception;
}
