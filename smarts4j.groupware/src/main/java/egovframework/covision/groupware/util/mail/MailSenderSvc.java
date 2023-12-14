package egovframework.covision.groupware.util.mail;

import egovframework.baseframework.data.CoviMap;


public interface MailSenderSvc {
    public CoviMap SendMailVacationPromotionInfoNotice(CoviMap mailForm, CoviMap vacConfig) throws Exception;
}
