*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE ATI.VBA.FT.INBOUND.REVE
*-----------------------------------------------------------------------------
* Developer Name     : Dwi K
* Development Date   : 20190305
* Description        : Routine before authorise for call service reverse inbound to legacy 
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ATI.TH.INTF.OUT.TRANSACTION
    $INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.USER
    $INSERT I_F.ATI.TH.USER.LEGACY
	$INSERT I_GTS.COMMON

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

	IF (V$FUNCTION EQ "R" AND R.NEW(FT.RECORD.STATUS) EQ "") OR (V$FUNCTION EQ "A" AND R.NEW(FT.RECORD.STATUS) EQ "RNAU") THEN
	   GOSUB INIT
       GOSUB PROCESS
	END

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.ATI.TH.INTF.OUT.TRANSACTION = "F.ATI.TH.INTF.OUT.TRANSACTION"
	F.ATI.TH.INTF.OUT.TRANSACTION = ""
	CALL OPF(FN.ATI.TH.INTF.OUT.TRANSACTION, F.ATI.TH.INTF.OUT.TRANSACTION)
	
	FN.ATI.TH.USER.LEGACY = "F.ATI.TH.USER.LEGACY"
	F.ATI.TH.USER.LEGACY  = ""
	CALL OPF(FN.ATI.TH.USER.LEGACY, F.ATI.TH.USER.LEGACY)
	
	FN.USER = "F.USER"
	F.USER  = ""
	CALL OPF(FN.USER, F.USER)
	
	YAPP  = "FUNDS.TRANSFER" :@FM
	YAPP := "USER"
	YFLD  = "ATI.PRO.CODE" :@VM: "ATI.INTF.ID" :@FM
	YFLD := "ATI.USER.LEG"
	YPOS  = ""
	
	CALL MULTI.GET.LOC.REF(YAPP, YFLD, YPOS)
	
	Y.ATI.PRO.CODE.POS = YPOS<1, 1>
	Y.ATI.INTF.ID.POS  = YPOS<1, 2>
	Y.ATI.USER.LEG.POS = YPOS<2, 1>
	
	Y.INPUTTER = FIELD(R.NEW(FT.INPUTTER),"_",2,1)
	CALL F.READ(FN.USER, Y.INPUTTER, R.USER.INP, F.USER, USER.ERR)
	Y.ATI.USER.LEG = R.USER.INP<EB.USE.LOCAL.REF, Y.ATI.USER.LEG.POS>
	
*	Y.ATI.USER.LEG = R.USER<EB.USE.LOCAL.REF, Y.ATI.USER.LEG.POS>
	CALL F.READ(FN.ATI.TH.USER.LEGACY, Y.ATI.USER.LEG, R.ATI.TH.USER.LEGACY, F.ATI.TH.USER.LEGACY, ATI.TH.USER.LEGACY.ERR)
	Y.USER.LEGACY.COMPANY = R.ATI.TH.USER.LEGACY<USR.LGC.COMPANY>
	
	Y.DATE      = OCONV(DATE(),"D-")
    Y.TIME      = TIMEDATE()
    Y.DATE.TIME = Y.DATE[9,2]:Y.DATE[1,2]:Y.DATE[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	
	Y.ATI.INTF.ID = R.NEW(FT.LOCAL.REF)<1, Y.ATI.INTF.ID.POS,1>
	CALL F.READ(FN.ATI.TH.INTF.OUT.TRANSACTION, Y.ATI.INTF.ID, R.ATI.TH.INTF.OUT.TRANSACTION.INP, F.ATI.TH.INTF.OUT.TRANSACTION, ATI.TH.INTF.OUT.TRANSACTION.ERR)
	Y.LEGACY.ID   = R.ATI.TH.INTF.OUT.TRANSACTION.INP<INTF.OUT.TRANS.LEGACY.ID>
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	IF Y.ATI.USER.LEG EQ "" OR R.ATI.TH.USER.LEGACY EQ "" THEN
		RETURN
	END

	Y.ATI.PROC.CODE = R.NEW(FT.LOCAL.REF)<1, Y.ATI.PRO.CODE.POS>
	
	GOSUB BUILD.DATA.INTF.OUT.TRANS
	
	Y.DATE.TIME       = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.DATE.TIME>
    Y.LEG.PRO.CODE    = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.LEG.PRO.CODE>
	Y.AMOUNT          = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.AMOUNT>
    Y.PAYMENT.DETAILS = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.PAYMENT.DETAILS>
    Y.USER            = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.USER>
    Y.APPLICATION.ID  = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.APPLICATION.ID>
    Y.DB.ACCOUNT      = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.DB.ACCOUNT>
    Y.CR.ACCOUNT      = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.CR.ACCOUNT>
	Y.OPERATION       = R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.OPERATION>
	
    Y.REQ.DATE.TIME = "20":Y.DATE.TIME[1,2]:"-":Y.DATE.TIME[3,2]:"-":Y.DATE.TIME[5,2]:"T":Y.DATE.TIME[7,2]:":":Y.DATE.TIME[9,2]:":00"

	CONVERT "." TO "" IN Y.AMOUNT
	
    Y.FLD.REQ.LIST<1>  = "REQ.DATE.TIME"
    Y.FLD.REQ.LIST<2>  = "TYPE"
    Y.FLD.REQ.LIST<3>  = "MTI"
    Y.FLD.REQ.LIST<4>  = "ELEMENT.03"
    Y.FLD.REQ.LIST<5>  = "ELEMENT.04"
    Y.FLD.REQ.LIST<6>  = "ELEMENT.10"
    Y.FLD.REQ.LIST<7>  = "ELEMENT.12"
    Y.FLD.REQ.LIST<8>  = "ELEMENT.13"
    Y.FLD.REQ.LIST<9>  = "ELEMENT.18"
    Y.FLD.REQ.LIST<10> = "ELEMENT.28"
    Y.FLD.REQ.LIST<11> = "ELEMENT.33"
    Y.FLD.REQ.LIST<12> = "ELEMENT.41"
    Y.FLD.REQ.LIST<13> = "ELEMENT.48"
    Y.FLD.REQ.LIST<14> = "ELEMENT.49"
    Y.FLD.REQ.LIST<15> = "ELEMENT.51"
    Y.FLD.REQ.LIST<16> = "ELEMENT.62"
    Y.FLD.REQ.LIST<17> = "ELEMENT.100"
    Y.FLD.REQ.LIST<18> = "ELEMENT.102"
    Y.FLD.REQ.LIST<19> = "ELEMENT.103"
    Y.FLD.REQ.LIST<20> = "ELEMENT.63"
    Y.FLD.REQ.LIST<21> = "CLIENT.TXN.ID"
	Y.FLD.REQ.LIST<22> = "USERID"


    Y.VAL.REQ.LIST<1>  = Y.REQ.DATE.TIME
    Y.VAL.REQ.LIST<2>  = "REV"
    Y.VAL.REQ.LIST<3>  = "0400"
    Y.VAL.REQ.LIST<4>  = Y.LEG.PRO.CODE
    Y.VAL.REQ.LIST<5>  = FMT(Y.AMOUNT, "R%20")
    Y.VAL.REQ.LIST<6>  = "0000000000000000000"
    Y.VAL.REQ.LIST<7>  = Y.DATE.TIME[4]:"00"
    Y.VAL.REQ.LIST<8>  = Y.DATE.TIME[3,4]
    Y.VAL.REQ.LIST<9> = "6010"
    Y.VAL.REQ.LIST<10> = "00000000000000000000"
    Y.VAL.REQ.LIST<11> = "441"
    Y.VAL.REQ.LIST<12> = Y.USER

    Y.ELEMENT.48.1 = FMT(Y.PAYMENT.DETAILS : " FT : " : Y.APPLICATION.ID, "L#40")
    Y.ELEMENT.48.2 = FMT("OVB DB : " :  Y.DB.ACCOUNT : " CR : " : Y.CR.ACCOUNT, "L#40")
    Y.ELEMENT.48.3 = FMT(Y.USER, "L#60")

    Y.VAL.REQ.LIST<13> = Y.ELEMENT.48.1 : Y.ELEMENT.48.2 : Y.ELEMENT.48.3

    Y.VAL.REQ.LIST<14> = "360"
    Y.VAL.REQ.LIST<15> = "360"

    Y.ELEMENT.62.1 = "00000000060000000000000000000000000000000000000000000000000000000000000000"
    Y.ELEMENT.62.2 = FMT(Y.USER, "L#15")
    Y.ELEMENT.62.3 = "00101"

    Y.VAL.REQ.LIST<16> = Y.ELEMENT.62.1 : Y.ELEMENT.62.2 : Y.ELEMENT.62.3

    Y.VAL.REQ.LIST<17> = "441"
    Y.VAL.REQ.LIST<18> = Y.DB.ACCOUNT
    Y.VAL.REQ.LIST<19> = Y.CR.ACCOUNT
    Y.VAL.REQ.LIST<20> = Y.LEGACY.ID[1,12] : "000000" : Y.LEGACY.ID[7]

    Y.VAL.REQ.LIST<21> = Y.APPLICATION.ID
	Y.VAL.REQ.LIST<22> = Y.USER
		
    CALL ATI.INTF.INBOUND.WS.PROCESS("BUKISYS.MIAPOSTING", Y.FLD.REQ.LIST, Y.VAL.REQ.LIST, "ONLINE", Y.RESPONSE, Y.FLD.RES.LIST, Y.VAL.RES.LIST, Y.MSG.ERR)
		
    FIND "ELEMENT.39" IN Y.FLD.RES.LIST SETTING POSF, POSV, POSS THEN
        Y.ELEMENT.39.VALUE = Y.VAL.RES.LIST<POSF>

        IF Y.ELEMENT.39.VALUE EQ "000" OR Y.ELEMENT.39.VALUE EQ "085" THEN
            R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.STATUS> = "SUCCESS"
        END
        ELSE
		    FIND "ELEMENT.44" IN Y.FLD.RES.LIST SETTING POSF.44, POSV.44, POSS.44 THEN
			    Y.ELEMENT.44.VALUE = Y.VAL.RES.LIST<POSF.44>
			END
			
            R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.STATUS>  = "ERROR"
            R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.ERR.MSG> = Y.ELEMENT.39.VALUE

			AF = FT.DEBIT.ACCT.NO
			ETEXT<1> = "EB-FT.ERR.WITHDRAW.LEG.WOKEE"
			ETEXT<2> = Y.ELEMENT.39.VALUE :"-": Y.ELEMENT.44.VALUE
			V$ERROR  = 1
			CALL STORE.END.ERROR
        END
    END
    ELSE
        R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.STATUS> = "ERROR"

		AF = FT.DEBIT.ACCT.NO
		ETEXT<1> = "EB-FT.ERR.WITHDRAW.LEG.WOKEE"
		V$ERROR  = 1
		CALL STORE.END.ERROR
    END

    FIND "ELEMENT.48" IN Y.FLD.RES.LIST SETTING POSF, POSV, POSS THEN
        Y.ELEMENT.48.VALUE = Y.VAL.RES.LIST<POSF>
	
        R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.LEGACY.ID> = Y.ELEMENT.48.VALUE[19]

    END
	
	GOSUB WRITE.DATA.INTF.OUT.TRANS
	
    RETURN
*-----------------------------------------------------------------------------
BUILD.DATA.INTF.OUT.TRANS:
*-----------------------------------------------------------------------------
		
	Y.AMOUNT.TRX = R.NEW(FT.CREDIT.AMOUNT)
	IF Y.AMOUNT.TRX EQ "" THEN
		Y.AMOUNT.TRX = R.NEW(FT.DEBIT.AMOUNT)
	END
	
	Y.APPLICATION   = "ATI.TH.INTF.OUT.TRANSACTION"
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.PRO.CODE>        = Y.ATI.PROC.CODE
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.VALUE.DATE>      = R.NEW(FT.DEBIT.VALUE.DATE)
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.DB.CURRENCY>     = R.NEW(FT.DEBIT.CURRENCY)
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.CR.CURRENCY>     = R.NEW(FT.CREDIT.CURRENCY)
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.AMOUNT>          = Y.AMOUNT.TRX
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.PAYMENT.DETAILS> = R.NEW(FT.PAYMENT.DETAILS)<1, 1>
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.APPLICATION>     = APPLICATION
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.APPLICATION.ID>  = ID.NEW
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.OPERATION>       = "REVERSE"
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.USER>            = Y.ATI.USER.LEG
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.COMPANY>         = Y.USER.LEGACY.COMPANY

	CALL ATI.INTF.MAPPING.PROC.CODE(Y.APPLICATION, Y.ATI.PROC.CODE, R.ATI.TH.INTF.OUT.TRANSACTION)
	
	R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.INPUTTER>   = TNO:"_":OPERATOR
    R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.DATE.TIME>  = Y.DATE.TIME
    R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.CO.CODE>    = ID.COMPANY
    R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.DEPT.CODE>  = R.USER<6>
    R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.AUTHORISER> = TNO:"_":OPERATOR
    R.ATI.TH.INTF.OUT.TRANSACTION<INTF.OUT.TRANS.CURR.NO>    = 1
	
	RETURN
*-----------------------------------------------------------------------------
WRITE.DATA.INTF.OUT.TRANS:
*-----------------------------------------------------------------------------

	CALL ALLOCATE.UNIQUE.TIME(Y.UNIQUE.TIME)
    Y.UNIQUE.TIME                    = TODAY : Y.UNIQUE.TIME
	Y.ATI.TH.INTF.OUT.TRANSACTION.ID = "TRX" : Y.UNIQUE.TIME
	
	CALL F.WRITE(FN.ATI.TH.INTF.OUT.TRANSACTION, Y.ATI.TH.INTF.OUT.TRANSACTION.ID, R.ATI.TH.INTF.OUT.TRANSACTION)

	R.NEW(FT.LOCAL.REF)<1, Y.ATI.INTF.ID.POS, -1> = Y.ATI.TH.INTF.OUT.TRANSACTION.ID

	RETURN
*-----------------------------------------------------------------------------
END
