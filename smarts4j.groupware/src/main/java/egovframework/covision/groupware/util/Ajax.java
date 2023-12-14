package egovframework.covision.groupware.util;

public enum Ajax {

    OK("ok") , NO("no");

    private String status;

    private Ajax(String result) {
        this.status = result;
    }
    public String result(){
        return status;
    }
}
