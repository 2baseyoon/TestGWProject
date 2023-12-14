package egovframework.coviframework.exception;

public class ResourceDuplicationException extends RuntimeException {
	private static final long serialVersionUID = 8021779234603369185L;

	ResourceDuplicationException() {}

	public ResourceDuplicationException(String message) {
        super(message);
    }
}
