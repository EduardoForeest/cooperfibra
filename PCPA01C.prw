#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fileio.ch'

/*/{Protheus.doc} PCPA01C
Funcao que gera a odem de produção das caixas que ainda não tiverem gerado
@author caio.lima
@since 01/02/2018
/*/
User Function PCPA01C()
	Local _cAliSZ1 := ""
	Local _aOP := {}
	Local _cAgrup := ""
	Local _nx := 0
	//Local _aFil := {{'01','04'},{"01","010104"},{"02","010101"}} // empresa , filial onde será executado o schedule
	//Local _aFil := {{"01","010104"},{"01","020101"}} // empresa , filial onde será executado o schedule
	Local _aFil   := {{"01","020101"}} // empresa , filial onde será executado o schedule
	Local _nz := 0
	Local _bAgrup := {|| (_cAliSZ1)->(Z1_FILIAL + Z1_PRODUTO + Z1_DTPROD + cValToChar(RECSZ1)) }
	Local _lExecuta := .T. // SuperGetMv("MZ_PCPA01C" ,, .T.)
	Local _cErro := ""
	Local _cPara := ""
	Local _nw := 0
	Local _nHdl := 0
	Local _cArq := "\system\pcpa01c.txt"

	Static _cConPrd := "U_PCPA01C"
	//Local _bAgrup := {|| (_cAliSZ1)->(Z1_FILIAL + Z1_PRODUTO + Z1_DTPROD) }

//	If ExistBlock( "ZFU001EJ" )
		// Registra as informações do uso da função customizada acessada - por Edir Barreto
//		U_ZFU001EJ( procname(0) )
//	EndIf

	If !File(_cArq)
		_nHdl := FCreate(_cArq)
		FClose(_nHdl)
	EndIf

	_nHdl := FOpen(_cArq, FO_READWRITE + FO_EXCLUSIVE)

	If _nHdl == -1
		ConOut(_cConPrd+" - Falha ao abrir arquivo em modo exclusivo.: FERROR "+str(ferror(),4))
		_aFil := {}
	Else
		ConOut(_cConPrd+" - Arquivo controle de acesso aberto com sucesso.  ")
	EndIf

	Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " Inicio." )

	For _nz:= 1 to Len(_aFil)
		RpcSetType( 1 )
		If RpcSetEnv( _aFil[_nz,1],_aFil[_nz,2] )

			_lExecuta := SuperGetMv("MZ_PCPA01C" ,, .T.)

			_cPara := SuperGetMv( "MZ_PCPA02C" ,, "breno.nogueira@j2aconsultoria.com.br")

			If !_lExecuta
				ConOut(_cConPrd + " Parametro MZ_PCPA01C está desativado, geração automatica das OPs não será executada.")
				cAssunto := _cConPrd + " geração automatica de OPs"
				cTexto := "Aviso.<br /><br />"+CRLF
				cTexto += "Parametro MZ_PCPA01C está desativado, geração automatica das OPs não será executada. <br /><br /> "+CRLF
				cTexto += "<b>Att...</b><br />"+CRLF
				cTexto += "TI - cooperfibra"
				U_EnvEmail(_cPara,,,cAssunto,cTexto)
				Exit
			Else
				ConOut(_cConPrd + " Parametro MZ_PCPA01C está ativado. continua o processo")
			EndIf

			_cAliSZ1 := fGetCx()

			While !(_cAliSZ1)->(Eof())

				If _cAgrup <> Eval(_bAgrup)
					_cAgrup := Eval(_bAgrup)
					Aadd(_aOP, {(_cAliSZ1)->Z1_FILIAL, (_cAliSZ1)->Z1_PRODUTO, (_cAliSZ1)->Z1_DTPROD, (_cAliSZ1)->Z1_PLIQUID, "'"+cValToChar((_cAliSZ1)->RECSZ1)+"'", {(_cAliSZ1)->RECSZ1} } )
				Else
					_aOP[Len(_aOP), 4] += (_cAliSZ1)->Z1_PLIQUID
					_aOP[Len(_aOP), 5] += ",'"+cValToChar((_cAliSZ1)->RECSZ1)+"'"
					aADD(_aOP[Len(_aOP), 6] , (_cAliSZ1)->RECSZ1)
				EndIf
				(_cAliSZ1)->(dbSkip())
			EndDo

			Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " quantidade de OPs a ser gerada: " + cValToChar(Len(_aOP)) )
			
			/// criar multithread aqui 

			For _nx:= 1 to Len(_aOP)

				dDataBase := SToD(_aOP[_nx, 3])
				_aQtdAux := fGetQtdAux(_aOP[_nx, 2], _aOP[_nx, 4])

				Begin Transaction
					_aRetOP := fGeraOP(_aOP[_nx, 2], _aOP[_nx, 3], _aOP[_nx, 4], _aOP[_nx, 5])
					If _aRetOP[1]
						_lContinua := .F.
						For _nw := 1 to Len(_aOP[_nx, 6])
							SZ1->(dbGoTo(_aOP[_nx, 6, _nw]))

							if SZ1->(Recno()) = _aOP[_nx, 6, _nw]
								If Empty(SZ1->Z1_ORDEM) .AND. Empty(SZ1->Z1_ITEMOP) .AND. Empty(SZ1->Z1_SEQOP)
									_lContinua := .T.
								EndIf
							EndIf
						Next

						If _lContinua
							Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " OP "+_aRetOP[2]+" gerada com sucesso")
							fUpdSZ1(_aRetOP, _aOP[_nx])
						Else
							DisarmTransaction()
							Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " Conflito de execução na caixa, rollback executado ")
						EndIf
					Else
						Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " erro ao gerar OP " + _aRetOP[2])
						_cErro += _aRetOP[5] + CRLF + CRLF
					EndIf

				End Transaction
			Next

			If !Empty(_cErro)

				cAssunto := _cConPrd + " geração automatica de OPs"
				cTexto := "ATENÇÃO,<br /><br />"+CRLF
				cTexto += "Erro ao tentar gerar automaticamente as OPs <br /> "+CRLF
				cTexto += "Segue em anexo um arquivo de texto com os erro encontrados na ultima execução.<br /><br /> "+CRLF
				cTexto += "<b>Att...</b><br />"+CRLF
				cTexto += "TI - cooperfibra"
				_cArq := "\schedules\"+_cConPrd + "_" + DToS(Date())+"_"+StrTran(Time(),":","-")+".txt"
				MemoWrite(_cArq , _cErro)

				U_EnvEmail(_cPara,,,cAssunto,cTexto,_cArq)

				Conout(ProcName() + " Foram encontrados alguns erro ao tentar executar a rotina, email enviado para: " + _cPara)
			EndIf

			RpcClearEnv()

			If Select(_cAliSZ1) > 0
				(_cAliSZ1)->(dbClosearea())
			Endif
		EndIf
	Next

	If _nHdl >= 0
		FClose(_nHdl)
	EndIf

	Conout(ProcName()+" - "+DToS(Date())+" - "+Time() + " Fim." )
Return

/*/{Protheus.doc} fGetQtdAux
retorna um array com as quantidades corretas para dar o acerto na hora da produção
@author caio.lima
@since 15/03/2018
@version undefined
@param _cProd, , descricao
@param _nPeso, , descricao
@return return, return_description
/*/
Static Function fGetQtdAux(_cProd, _nPeso)
	Local _aRet := {}

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	SG1->(dbGoTop())
	If SG1->( dbSeek( xFilial("SG1")+_cProd ) )
		while !SG1->(Eof()) .AND. xFilial("SG1") + _cProd == SG1->G1_FILIAL + SG1->G1_COD
			_nQuant := SG1->G1_QUANT
			Do Case
			Case SG1->G1_QTDFIOS = "C"
				_nQuant := SG1->G1_QUANT

			Case SG1->G1_QTDFIOS = "T"
				_nQuant := SG1->G1_QUANT * SG1->G1_QTROCAS

			Case SG1->G1_QTDFIOS = "P"
				_nQuant := _nPeso
			EndCase

			Aadd(_aRet, {SG1->G1_COMP,  _nQuant} )
			SG1->(dbSkip())
		End
	EndIf

Return(_aRet)

/*/{Protheus.doc} fUpdSZ1
Funcao que gera executa o update na tabela sz1 referente aos campos de OP
@author caio.lima
@since 01/02/2018
@version undefined
@param _aOP, Array, op gerada para ser feito o update
/*/
Static Function fUpdSZ1(_aRetOP, _aOP)
	Local _cSql := ""

	_cSql += " UPDATE "+RetSQLName("SZ1")+" " + CRLF
	_cSql += " SET Z1_ORDEM='"+_aRetOP[2]+"', Z1_ITEMOP='"+_aRetOP[3]+"', Z1_SEQOP='"+_aRetOP[4]+"' " + CRLF
	_cSql += " WHERE D_E_L_E_T_<>'*' AND Z1_ORDEM='' AND Z1_ITEMOP='' AND Z1_SEQOP='' " + CRLF
	_cSql += " AND Z1_HRPROD NOT IN ('') AND Z1_FILIAL='"+_aOP[1]+"' " + CRLF
	_cSql += " AND Z1_PRODUTO='"+_aOP[2]+"' AND Z1_DTPROD='"+_aOP[3]+"' " + CRLF
	_cSql += " AND R_E_C_N_O_ IN (" + _aOp[5] + ") " + CRLF

	//ConOut(_cSql)

	_nExec := TcSQLExec(_cSql)
	If _nExec < 0
		Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " Erro ao executar update SZ1 " + TCSQLError())
	Else
		Conout(_cConPrd+" - "+DToS(Date())+" - "+Time() + " update executado com sucesso")
	EndIf

Return

/*/{Protheus.doc} fGetCx
Funcao que abre um alias com o select na SZ1 apenas das caixa sem OP geradas
@author caio.lima
@since 01/02/2018
@return caractere, alias do select executado
/*/
Static Function fGetCx()
	Local _cSql := ""
	Local _cALias := GetNextAlias()

	_cSql += " SELECT SZ1.R_E_C_N_O_ AS RECSZ1, * FROM "+RetSQLName("SZ1")+" SZ1 " + CRLF
	_cSql += " WHERE SZ1.D_E_L_E_T_<>'*' AND Z1_ORDEM='' AND Z1_ITEMOP='' AND Z1_SEQOP='' " + CRLF
	_cSql += " AND Z1_HRPROD NOT IN ('') AND Z1_FILIAL='"+XFILIAL("SZ1")+"' " + CRLF
	_cSql += " AND Z1_DTPROD >= '20180101' " + CRLF
	//_cSql += " ORDER BY Z1_FILIAL, Z1_PRODUTO, Z1_DTPROD " + CRLF
	_cSql += " ORDER BY Z1_FILIAL, Z1_DTPROD, Z1_HRPROD " + CRLF

	//ConOut(_cSql)

	If Select(_cALias) > 0
		(_cALias)->(dbClosearea())
	Endif

	MemoWrite("D:\LOGSQL\"+FunName()+"-"+ProcName()+".txt" , _cSql)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cSql)), _cALias, .F., .F.)

Return(_cALias)

/*/{Protheus.doc} fGeraOP
Funcao que gera a ordem de produção via rotina automatica
@author caio.lima
@since 01/02/2018
@version undefined
@param _dData, Date, descricao
@param _cPrd, Date, descricao
@param _nQuant, Numerica, descricao
@return array, 4 posicoes
@see (links_or_references)
Inclusão da Ordem de Produção via Rotina automática Mata650
/*/
Static Function fGeraOP(_cPrd, _sData, _nQuant, _cRecnos)
	Local _cErro           := ""
	Local _lRetSF          := .f.
	Local aMata650         := {}
	Local cNumOp 		   := ""
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	Begin Transaction
	//cNumOp    := GetNumSc2()
	cNumOp    := soma1(GetSXENum('SC2', 'C2_NUM'))
	ConfirmSX8()
	cNumOp    := soma1(GetSXENum('SC2', 'C2_NUM'))

	cItemOP   := StrZero(1,Len(CRIAVAR("C2_ITEM",.F.)))
	cSequenOP := StrZero(1,Len(CRIAVAR("C2_SEQUEN",.F.)))

	PERGUNTE("MTA650",.F.)

	//-- Monta array para utilizacao da Rotina Automatica
	aMata650 :={{"C2_FILIAL", cFilAnt ,Nil},;
		        {'C2_NUM'                  , cNumOp      , NIL},;
		        {'C2_ITEM'                 , cItemOP     , NIL},;
		        {'C2_SEQUEN'               , cSequenOP   , NIL},;
		        {'C2_PRODUTO'              , _cPrd       , NIL},;
		        {'C2_LOCAL'                , "01"        , NIL},;
		        {'C2_QUANT'                , _nQuant     , NIL},;
		        {'C2_DATPRI'               , SToD(_sData), NIL},;
		        {'C2_DATPRF'               , SToD(_sData), NIL},;
		        {'C2_EMISSAO'              , SToD(_sData), NIL},;
		        {'AUTEXPLODE'              , "S"         , NIL}}

	//lMsErroAuto := .f.
	//-- Chamada da rotina automatica
	//dbSelectArea("SB1")
	//dbSelectArea("SG1")
	//dbSelectArea("SC2")

	mata650lck()

	msExecAuto({|x,Y|Mata650(x,Y)},aMata650,3)
	
	If !lMsErroAuto
		ConOut("Sucesso! ")
		ConfirmSX8()
		_lRetSF:=.t.
	Else
		ConOut("Erro!")
		RollBackSX8()
		if IsBlind()
			VarInfo('MATA650 => ', VarAutoLog())
		Else
			MostraErro()
		EndIf
		DisarmTransaction()
	EndIf

	ConOut( "fonte [PCPA01C], OP: " + cNumOp)
	ConOut( "fonte [PCPA01C], OP GERADA==>: " + cNumOp)

	sleep(3000)

	end Transaction

/*

	 If lMsErroAuto
	 	DisarmTransaction()
	 	_cErro := Mostraerro("zzz")
	 	RollBackSX8()
	 Else
	 	ConfirmSX8()
		ConOut( "fonte [PCPA01C], OP GERADA==>: " + cNumOp)
	 	_lRetSF:=.t.
	 EndIf
*/
RETURN({_lRetSF,cNumOp,cItemOP,cSequenOP, _cErro})



User Function TSTMT330()
	Local _cTimeIni := Time()
	Local _cTimeFim := ""
	Local _cTxt := ""

	_cTxt += ProcName() + " INICIO " + DToS(dDataBase) + "_" + _cTimeIni  + CRLF

	_cTxt += ProcName() + " NUMERO DE THREADS PARAMETRO MV_M330THR " + cValToChar(GetMV("MV_M330THR ")) + CRLF

	MATA330()

	_cTimeFim := Time()
	_cTxt += ProcName() + " FIM " + DToS(dDataBase) + "_" + _cTimeFim + CRLF

	_cTxt += ProcName() + " TEMPO DECORRIDO " + ElapTime(_cTimeIni, _cTimeFim)

	MemoWrite("\data\log_mata330_" + DToS(dDataBase) + "_" + StrTran(_cTimeIni,":","-") + ".txt", _cTxt )

Return
