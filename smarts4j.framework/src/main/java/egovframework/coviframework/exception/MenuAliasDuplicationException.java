package egovframework.coviframework.exception;

public class MenuAliasDuplicationException extends RuntimeException {
	private static final long serialVersionUID = 8021779234603369185L;

	MenuAliasDuplicationException() {}

	public MenuAliasDuplicationException(String message) {
        super(message);
    }
}
