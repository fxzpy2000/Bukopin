*-----------------------------------------------------------------------------
    SUBROUTINE ATI.ES.GEN.XML.EMAIL(Y.ES.ID, Y.MAPPING, Y.TO, Y.APP, Y.APP.ID, R.APP, Y.XML.MESSAGE, Y.ERROR)
*-----------------------------------------------------------------------------
* Developer Name     : ATI Juan Felix
* Development Date   : 20170713
* Description        : Routine for generate XML message Email
*                      INPUT :
*                      - Y.ES.ID       : Email / SMS ID
*                      - Y.MAPPING     : Mapping ID for email
*                      - Y.TO          : To Email
*                      - Y.APP         : Application
*                      - Y.APP.ID      : ID Application
*                      - R.APP         : Record application
*                      OUTPUT :
*                      - Y.XML.MESSAGE : XML Message
*                      - Y.ERROR       : Error output
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ATI.TH.EMAIL.MAPPING
    $INSERT I_F.ATI.TH.EMAIL.PARAM

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.ATI.TH.EMAIL.MAPPING = "F.ATI.TH.EMAIL.MAPPING"
    CALL OPF(FN.ATI.TH.EMAIL.MAPPING, F.ATI.TH.EMAIL.MAPPING)

    FN.ATI.TH.EMAIL.PARAM = "F.ATI.TH.EMAIL.PARAM"
    CALL OPF(FN.ATI.TH.EMAIL.PARAM, F.ATI.TH.EMAIL.PARAM)

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.ATI.TH.EMAIL.MAPPING, Y.MAPPING, R.ATI.TH.EMAIL.MAPPING, F.ATI.TH.EMAIL.MAPPING, ERR.ATI.TH.EMAIL.MAPPING)
    Y.FROM            = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.FROM>
    Y.REPLYTO         = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.REPLYTO>
    Y.CCC             = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.CCC>
    Y.BCC             = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.BCC>
    Y.MESSAGE.TYPE    = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.MESSAGE.TYPE>
    Y.SUBJECTS        = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.SUBJECTS>
    Y.BODY            = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.BODY>
    Y.ATTACHMENT.DIR  = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.ATTACHMENT.DIR>
    Y.ATTACHMENT.VAR  = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.ATTACHMENT.VAR>
    Y.VARIABLE.LIST   = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.VARIABLE>
    Y.FIELD.NAME.LIST = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.FIELD.NAME>
    Y.FUNCTION.LIST   = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.FUNCTION>
    Y.ATTRIBUTE.LIST  = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.ATTRIBUTE>
    Y.VARIABLE.CNT    = DCOUNT(Y.VARIABLE.LIST, VM)
    Y.EMAIL.PARAM     = R.ATI.TH.EMAIL.MAPPING<EMAIL.MAP.EMAIL.PARAM>

    IF NOT(R.APP) AND Y.APP THEN
        FN.APP = "F." : Y.APP
        CALL OPF(FN.APP, F.APP)

        CALL F.READ(FN.APP, Y.APP.ID, R.APP, F.APP, ERR.APP)
    END

    CALL ATI.GET.FUNCTION.VALUE(Y.APP, R.APP, Y.VARIABLE.LIST, Y.FIELD.NAME.LIST, Y.FUNCTION.LIST, Y.ATTRIBUTE.LIST, Y.FIELD.VALUE.LIST)

    GOSUB BODY.MESSAGE.CONVERT
    IF Y.ATTACHMENT.DIR THEN
        GOSUB GET.ATTACHMENT
    END

    GOSUB GEN.PROPERTIES
    GOSUB GEN.XML.MESSAGE

    RETURN

*-----------------------------------------------------------------------------
BODY.MESSAGE.CONVERT:
*-----------------------------------------------------------------------------
    Y.BODY.LIST = Y.BODY

    CONVERT VM TO "" IN Y.BODY.LIST
    CHANGE "<" TO "&lt;" IN Y.BODY.LIST
    CHANGE ">" TO "&gt;" IN Y.BODY.LIST

    FOR I = 1 TO Y.VARIABLE.CNT
        Y.VARIABLE    = "*" : Y.VARIABLE.LIST<1, I> : "*"
        Y.FIELD.NAME  = Y.FIELD.NAME.LIST<1, I>
        Y.FIELD.VALUE = Y.FIELD.VALUE.LIST<1, I>

        CHANGE Y.VARIABLE TO Y.FIELD.VALUE IN Y.BODY.LIST
    NEXT I

    Y.BODY.OUTPUT = Y.BODY.LIST

    RETURN

*-----------------------------------------------------------------------------
GET.ATTACHMENT:
*-----------------------------------------------------------------------------
    Y.ATTAHCMENT.OUTPUT = ""

    CALL EB.GET.OS(Y.OS.NAME)
    FIND Y.ATTACHMENT.VAR IN Y.VARIABLE.LIST SETTING POSF, POSV, POSS THEN
        Y.FILE.NAME = Y.FIELD.VALUE.LIST<1, POSV>

        IF Y.FILE.NAME AND GETENV("T24_HOME", Y.T24.HOME) THEN
            Y.ATTACHMENT = Y.T24.HOME : "\" : Y.ATTACHMENT.DIR : "\" : Y.FILE.NAME

            IF Y.OS.NAME EQ "NT" THEN
                CONVERT "\" TO "/" IN Y.ATTACHMENT
            END
*           ELSE
*               CONVERT "/" TO "\" IN Y.ATTACHMENT
*           END
            Y.ATTAHCMENT.OUTPUT = Y.ATTACHMENT
        END
    END

    RETURN

*-----------------------------------------------------------------------------
GEN.PROPERTIES:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.ATI.TH.EMAIL.PARAM, Y.EMAIL.PARAM, R.ATI.TH.EMAIL.PARAM, F.ATI.TH.EMAIL.PARAM, ERR.ATI.TH.EMAIL.PARAM)

    Y.PROPERTIES  = "mail.smtp.host=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.SMTP.HOST> : "|"
    Y.PROPERTIES := "mail.smtp.port=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.SMTP.PORT> : "|"
    Y.PROPERTIES := "mail.smtp.auth=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.SMTP.AUTH> : "|"
    Y.PROPERTIES := "mail.login.username=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.LOGIN.USERNAME> : "|"
    Y.PROPERTIES := "mail.login.password=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.LOGIN.PASSWORD> : "|"
    Y.PROPERTIES := "mail.smtp.starttls.enable=" : R.ATI.TH.EMAIL.PARAM<EMAIL.PARAM.SMTP.STARTTLS.ENABLE>

    RETURN

*-----------------------------------------------------------------------------
GEN.XML.MESSAGE:
*-----------------------------------------------------------------------------
    Y.XML.MESSAGE  = ""
    Y.XML.MESSAGE  = '<?xml version="1.0" encoding="utf-8"?>'
    Y.XML.MESSAGE := '<EMAILPACKAGE>'
    Y.XML.MESSAGE := '<PROPERTIES>' : Y.PROPERTIES : '</PROPERTIES>'
    Y.XML.MESSAGE := '<EMAIL>'
    Y.XML.MESSAGE := '<FROM>' : Y.FROM : '</FROM>'
    Y.XML.MESSAGE := '<REPLYTO>' : Y.REPLYTO : '</REPLYTO>'
    Y.XML.MESSAGE := '<TO>' : Y.TO : '</TO>'
    Y.XML.MESSAGE := '<CC>' : Y.CCC : '</CC>'
    Y.XML.MESSAGE := '<BCC>' : Y.BCC : '</BCC>'
    Y.XML.MESSAGE := '<SUBJECT>' : Y.SUBJECTS : '</SUBJECT>'
    Y.XML.MESSAGE := '<BODY>' : Y.BODY.OUTPUT : '</BODY>'
    Y.XML.MESSAGE := '<ATTACHMENT>' : Y.ATTAHCMENT.OUTPUT : '</ATTACHMENT>'
    Y.XML.MESSAGE := '</EMAIL>'
    Y.XML.MESSAGE := '</EMAILPACKAGE>'

    RETURN
*-----------------------------------------------------------------------------
END
