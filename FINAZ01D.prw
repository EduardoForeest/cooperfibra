#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'Rwmake.ch'


//--------------------------------------------------------------------
/*/{Protheus.doc} AumentCot
Função criada para aumentar a cota capital do cooperado. Após a con-
firmação irá gerar títulos a receber no financeiro e gerar movimenta-
ção na tabela SZC.
@author Diego Soares
@since 17/04/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------
User Function AumentCot()
	Local _lRet 	:= .F.
	Local _aArea	:= GetArea()
	Local _aAreaSZA	:= SZA->(GetArea())
	Local _cFilial	:= SZA->ZA_FILIAL
	Local _cCodCoop	:= SZA->ZA_COD
	Local _cNome	:= SZA->ZA_NOME
	Local _dData 	:= dDataBase
	Local _nValor 	:= 0
	Local _cCondPG	:= Space(03)
	Local oGet1
	Local cGet1 	:= "Define variable value"
	Local oGet2
	Local cGet2 	:= "Define variable value"
	Local oGet3
	Local cGet3 	:= "Define variable value"
	Local oGet4
	Local cGet4 	:= "Define variable value"
	Local oGet5
	Local cGet5 	:= "Define variable value"
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oButton1
	Local oButton2
	Local _cCadastro:= "AUMENTO DE COTA CAPITAL DO COOPERADO"
	Local _aArrSay 	:= {}
	Local _aButtons	:= {}
	Local _nOpca   	:= 0
	Local _aPergs 	:= {}
	Local _aRet		:= {}
	Local _cEC05CR	:= Space(TamSX3("D1_EC05CR")[1])			//-- Safra crédito
	Local _cEC05DB	:= Space(TamSX3("D1_EC05DB")[1])			//-- Safra débito
	Local _cEC06CR	:= Space(TamSX3("D1_EC06CR")[1])			//-- Cultura crédito
	Local _cEC06DB	:= Space(TamSX3("D1_EC06DB")[1])			//-- Cultura débito
	Private oFont	:= TFont():New("Arial",,14,,.T.,,,,,.F. )	//-- Fonte
	Static oDlg

	If ExistBlock( "ZFU001EJ" )  
        // Registra as informações do uso da função customizada acessada - por Edir Barreto
		U_ZFU001EJ( procname(0) ) 
	EndIf

	If ! Empty(SZA->ZA_DEMISSA)
		MsgInfo("Não é possível fazer aumento de capital para cooperado demitido.","ATENÇÃO!")
		Return()

	Else

		aadd(_aArrSay, "Este programa tem como objetivo fazer o aumento de cota capital do cooperado.")
		aadd(_aArrSay, "Deseja continuar?")

		aadd(_aButtons, { 1,.T.,{|o| _nOpca := 1,o:oWnd:End()}})
		aadd(_aButtons, { 2,.T.,{|o| o:oWnd:End()}})

		FormBatch(_cCadastro,_aArrSay,_aButtons)

		If _nOpca == 1

			Define MsDialog oDlg TITLE "AUMENTO DE COTA CAPITAL" From 000, 000  TO 200, 550 COLORS 0, 16777215 Pixel

			@ 012, 005 Say oSay1 PromPt "CÓDIGO:" Size 025, 007 OF oDlg COLORS 0, 16777215 Pixel
			oSay1:SetFont(oFont)

			@ 010, 030 MSGET oGet1 Var _cCodCoop PicTure "@!" Size 030, 010 OF oDlg COLORS 0, 16777215 Pixel HASBUTTON When .F. 

			@ 012, 072 Say oSay2 PromPt "NOME:" Size 025, 007 OF oDlg COLORS 0, 16777215 Pixel
			oSay2:SetFont(oFont)

			@ 010, 092 MSGET oGet2 Var _cNome PicTure "@!" Size 175, 010 OF oDlg COLORS 0, 16777215 Pixel HASBUTTON When .F.

			@ 037, 005 Say oSay3 PromPt "VALOR:" Size 025, 007 OF oDlg COLORS 0, 16777215 Pixel
			oSay3:SetFont(oFont)

			@ 035, 030 MSGET oGet3 Var _nValor PicTure "@E 999,999,999.99" Size 060, 010 OF oDlg COLORS 0, 16777215 Pixel HASBUTTON

			@ 037, 095 Say oSay4 PromPt "COND. PAG.:" Size 050, 007 OF oDlg COLORS 0, 16777215 Pixel
			oSay4:SetFont(oFont)

			@ 035, 130 MSGET oGet4 Var _cCondPG Picture "@!" Valid ExistCpo("SE4",_cCondPG,1) Size 030, 010 OF oDlg F3 "SE4" COLORS  0, 16777215 Pixel HASBUTTON

			@ 037, 165 Say oSay5 PromPt "DATA:" Size 025, 007 OF oDlg COLORS 0, 16777215 Pixel
			oSay5:SetFont(oFont)

			@ 035, 184 MSGET oGet5 Var _dData Size 060, 010 OF oDlg COLORS 0, 16777215 Pixel HASBUTTON When .F.

			@ 070, 005 BUTTON oButton1 PromPt "CONFIRMAR" Size 037, 012 OF oDlg ACTION _lRet := U_fValTok(_cCondPG,oDlg) Pixel
			oButton1:SetFont(oFont)

			@ 070, 050 BUTTON oButton2 PromPt "CANCELAR" Size 037, 012 OF oDlg 	ACTION oDlg:End() Pixel
			oButton2:SetFont(oFont)


			Activate MsDialog oDlg Centered

			If _lRet = .T.
				//--------------		
				//-- Parâmetros
				//--------------
				aadd( _aPergs , {1,"Safra Crédito"  	,Space(06),"@!",'.T.',"XCV005",'.T.',50,.T.})
				aadd( _aPergs , {1,"Safra Débito"  		,Space(06),"@!",'.T.',"XCV005",'.T.',50,.T.})
				aadd( _aPergs , {1,"Cultura Crédito" 	,Space(06),"@!",'.T.',"XCV006",'.T.',50,.T.})
				aadd( _aPergs , {1,"Cultura Débito"  	,Space(06),"@!",'.T.',"XCV006",'.T.',50,.T.})

				If	ParamBox(_aPergs , "Entidades - Safra e Cultura", _aRet,,,,700,1000, /*oMainDlg*/,,.F.,.F.)
					//-----------------------
					//-- variáveis entidades
					//-----------------------
					_cEC05CR	:= _aRet[1]
					_cEC05DB	:= _aRet[2]
					_cEC06CR	:= _aRet[3]
					_cEC06DB	:= _aRet[4]


					DbSelectArea("SZA")
					DbSetOrder(1)
					dbGoTop()
					//-------------------------
					//-- Posiciona no registro
					//-------------------------
					If SZA->(DbSeek(FwxFilial("SZA")+_cCodCoop))

						//------------------------------------------------------------------
						//-- Chama rotina para buscar o próximo número de título disponível
						//------------------------------------------------------------------
						_cNum := U_fProxSE1()

						//----------------------------------------------------------------------------
						//-- Chama rotina para gerar um título no financeiro e gerar movimento na SZC
						//----------------------------------------------------------------------------
						FWMsgRun(,{||_lRet := fGeraE1X(_cCodCoop,_nValor,_cCondPG,_dData,_cNum,_cEC05CR,_cEC05DB,_cEC06CR,_cEC06DB)},"Aguarde","Processando....")
					Endif
				Else
					_lRet := .F.
				Endif
			Endif
		Endif


		If _lRet = .T.
			If SZA->(DbSeek(FwxFilial("SZA")+ _cCodCoop))
				RecLock("SZA",.F.)
				//--------------------------------------------------
				//-- Atualiza o campo total de capital do cooperado
				//--------------------------------------------------
				SZA->ZA_CAPITAL += U_fCalCapit(_cCodCoop) 	
				MsunLock()
			Endif
			MsgInfo("Aumento de capital realizado com sucesso.","ATENÇÃO!")
		Endif
	Endif

	RestArea(_aAreaSZA)
	RestArea(_aArea)


Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraE1X
Gera um título a receber na SE1 e movimento na SZC, após o aumento
de capital do cooperado.
@author Diego Soares
@since 06/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fGeraE1X(_cCodCoop,_nValor,_cCondPG,_dData,_cNum,_cEC05CR,_cEC05DB,_cEC06CR,_cEC06DB)
	Local _lRet		:= .T.
	Local _cHistor	:= "REF. AUMENTO DE CAPITAL DO COOPERADO" 
	Local _aArea	:= GetArea()
	Local _aAreaSZA	:= SZA->(GetArea())
	Local _aAreaSE1	:= SE1->(GetArea())
	Local _aParc 	:= {}
	Local _cParIni	:= RetAsc("1",1,.T.)
	Local _nx		:= 0
	Local _cNatTit	:= GetMv("CF_NCOOPE1")   //-- Natureza do título a receber
	Local _cCCTit	:= GetMv("CF_CCOOPE1")	 //-- Centro de custo débito do título a receber
	Local _cCVLTit	:= GetMv("CF_CVCOOE1")	 //-- Classe de valor débito do título a receber
	Local _aDados	:= {}	
	Local _cDescMot := ""


	//---------------------------------------------------------------------
	//-- Gera as parcelas, de acordo com a condição de pagamento informada
	//---------------------------------------------------------------------
	_aParc 	:= Condicao( _nValor,_cCondPG,,_dData)


	DbSelectArea("SE1")
	DbSetOrder(2)
	dbGoTop()

	Begin Transaction

		For _nx := 1 To Len(_aParc)

			_aDados := {{"E1_FILIAL"  , FwxFilial("SE1")	,Nil},;
			{"E1_PREFIXO" , 'COT'               ,Nil},;
			{"E1_NUM"	  , _cNum				,Nil},;
			{"E1_PARCELA" , _cParIni 			,Nil},;
			{"E1_TIPO"    , 'CSI'               ,Nil},;
			{"E1_CLIENTE" , 'A0'+_cCodCoop	    ,Nil},;
			{"E1_LOJA"    , '01'        		,Nil},;
			{"E1_EMISSAO" , _dData		        ,Nil},;
			{"E1_VENCTO"  , _aParc[_nx][1]      ,Nil},;
			{"E1_VALOR"   , _aParc[_nx][2]      ,Nil},;
			{"E1_NATUREZ" , _cNatTit			,Nil},;
			{"E1_CCC" 	  ,	_cCCTit				,Nil},;
			{"E1_CCD" 	  ,	_cCCTit				,Nil},;
			{"E1_CLVLCR"  , _cCVLTit			,Nil},;
			{"E1_CLVLDB"  , _cCVLTit			,Nil},;
			{"E1_MOEDA"   , 1                   ,Nil},;
			{"E1_EC05CR"  , _cEC05CR            ,Nil},;
			{"E1_EC05DB"  , _cEC05DB            ,Nil},;
			{"E1_EC06CR"  , _cEC06CR            ,Nil},;
			{"E1_EC06DB"  , _cEC06DB            ,Nil},;
			{"E1_HIST"    , _cHistor            ,Nil}}

			lMSErroAuto := .F. 							//-- Inicializa como falso, se voltar verdadeiro e' que deu erro
			MSExecAuto({|x,y|Fina040(x,y)},_aDados,3)	//-- Inclusão	

			If lMsErroAuto
				_lRet := .F.
				Mostraerro()
				DisarmTransaction()
				Return(.F.)
			Endif

			_cParIni := Soma1(_cParIni,,.T.)
		Next _nx
	End Transaction

	//----------------------------------------------------
	//-- Chama rotina para gerar movimento na tabela SZC
	//----------------------------------------------------
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	SX5->(DbGoTop())
	
	If SX5->(DbSeek(xFilial("SX5")+'ZC'+"A"))
		_cDescMot := SX5->X5_DESCRI
	Endif

	U_fGeraSZC(_cCodCoop,_dData,"A","A",_nValor,_cDescMot)


	RestArea(_aAreaSE1)
	RestArea(_aAreaSZA)
	RestArea(_aArea)


Return(_lRet)


//--------------------------------------------------------------------
/*/{Protheus.doc} EstAument
Função criada para fazer o estorno de aumento da cota capital do coo-
perado. 
@author Diego Soares
@since 17/04/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------
User Function EstAument()
	Local _lRet		:= .F.
	Local _aArea 	:= GetArea()
	Local _aAreaSZA	:= SZA->(GetArea())
	Local _cCadastro:= "ESTORNO DE COTA CAPITAL DO COOPERADO"
	Local _aArrSay 	:= {}
	Local _aButtons	:= {}
	Local _nOpca   	:= 0
	Local _cCodCoop	:= SZA->ZA_COD



	If ! Empty(SZA->ZA_DEMISSA)
		MsgInfo("Não é possível fazer estorno de capital para cooperado demitido.","ATENÇÃO!")
		Return()

	Else
		aadd(_aArrSay, "Este programa tem como objetivo fazer o estorno de cota capital do cooperado. ")
		aadd(_aArrSay, "Deseja continuar?")

		aadd(_aButtons, { 1,.T.,{|o| _nOpca := 1,o:oWnd:End()}})
		aadd(_aButtons, { 2,.T.,{|o| o:oWnd:End()}})

		FormBatch(_cCadastro,_aArrSay,_aButtons)

		If _nOpca == 1

			DbSelectArea("SZA")
			DbSetOrder(1)
			DbGoTop()

			//-------------------------
			//-- Posiciona no registro
			//-------------------------
			If SZA->(DbSeek(FwxFilial("SZA")+_cCodCoop))

				//------------------------------------------------------------------------------------------------------------------------------------
				//-- Chama rotina para verificar se já foi dado baixa em algum título a receber deste cooperado, referente ao aumento de cota capital
				//------------------------------------------------------------------------------------------------------------------------------------
				//
				
				// ALTERADO POR VITOR AVANCINI - FSW-695
				//_lRet := fBaixSE1(_cCodCoop)
				
				//If _lRet = .T.
					//--------------------------------------------------------------------------------------------------------------------
					//-- Chama rotina para deletar os títulos anteriormente gerados no aumento de cota capital e atualiza os dados na SZC
					//--------------------------------------------------------------------------------------------------------------------
					FWMsgRun(,{||fDelSE1(_cCodCoop)},"Aguarde","Processando....")												
				//Else
				//	MsgInfo("Existe(m) título(s) baixado(s) para este cooperado, desse modo não será possível fazer o estorno do aumento.","ATENÇÃO!")
				//Endif

			Endif
		Endif
	Endif

	RestArea(_aAreaSZA)
	RestArea(_aArea)

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} fBaixSE1
Função criada para verificar se existe título baixado para este coope-
rado. Se houver, não será permitido fazer o estorno de aumento de cota
capital do mesmo.
@author Diego Soares
@since 08/06/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function fBaixSE1(_cCliente)
	Local _cSql   := ""
	Local _cAlias := GetNextAlias()
	Local _lRet   := .T.
	Local oModal
	Local oContainer
	Local aSize := MsAdvSize(.F.)
    Local nJanLarg := aSize[5] / 2
    Local nJanAltu := aSize[6] / 2

	_cCliente := "A0"+_cCliente

	If Select(_cALias) > 0
		(_cALias)->(dbClosearea())
	Endif

	//---------------------------
	//-- Busca os títulos na SE1
	//---------------------------
	_cSql += " SELECT E1_FILIAL, E1_NUM, E1_PREFIXO, E1_TIPO, E1_PARCELA "+CRLF
	_cSql += " From "+RetSQLName("SE1")+" SE1 "+CRLF
	_cSql += " WHERE SE1.D_E_L_E_T_ <> '*' "+CRLF
	_cSql += " AND E1_CLIENTE  = '"+_cCliente+"' "+CRLF
	_cSql += " AND E1_LOJA = '01' "+CRLF
	_cSql += " AND E1_PREFIXO = 'COT' "+CRLF
	_cSql += " AND E1_TIPO = 'CSI' "+CRLF
	_cSql += " AND E1_SALDO = '0' "+CRLF 
	_cSql += " AND E1_BAIXA <> '' "+CRLF
	_cSql += " AND E1_HIST = 'REF. AUMENTO DE CAPITAL DO COOPERADO' "+CRLF
	_cSql += " Order By E1_FILIAL, E1_NUM, E1_PARCELA "+CRLF

	MemoWrite("C:\LOGSQL\fBaixSE1.txt" , _cSql) 
	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cSql)), _cALias, .F., .F.)

	//---------------------------------------------
	//-- Se encontrar algum título baixado é falso
	//---------------------------------------------
	If !(_cAlias)->(Eof())
		_lRet := .F.
	Endif

Return(_lRet)


//---------------------------------------------------------------------
/*/{Protheus.doc} fDelSE1
Função criada para deletar os títulos gerados quando feito o aumento 
de cota capital do cooperado.
@author Diego Soares
@since 08/06/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function fDelSE1(_cCodCoop)
	Local _aArea 	:= GetArea()
	Local _aAreaSZA	:= SZA->(GetArea())
	Local _lRet		:= .F.
	Local _cSql 	:= ""
	Local _cAlias 	:= GetNextAlias()
	Local _cCliE1	:= ""
	Local _cLojaE1	:= ""
	Local _cPrefE1	:= ""
	Local _cNumE1	:= ""
	Local _cParcE1	:= ""
	Local _cTipoE1	:= ""
	Local _nVlr		:= 0
	Local _dEmissao	:= Date()
	Local _dBaixa	:= Date()
	Local _nSaldo	:= 0
	Local _cContab	:= "505"  
	Local _cCliente	:= "A0"+_cCodCoop
	Local _dData	:= dDataBase
	Local _oDlg
	Local _oOk		:= LoadBitmap( GetResources(), "LBOK") 
	Local _oNo		:= LoadBitmap( GetResources(), "LBNO") 		
	Local _cPicture	:= TM(999999999.99,14,2)
	Local _nx		:= 0
	Local _nOpc		:= 0
	Local _oButton1
	Local _oButton2
	Local _nVlSZC 	:= 0
	Local aSize      := MsAdvSize(.F.)
    Local nJanLarg   := aSize[5] / 1.48
    Local nJanAltu   := aSize[6] / 2
    Local nGridLarg  := aSize[5] / 3
    Local nGridAltu  := aSize[6] / 5
	Local _cDescMot	:= ""
	Local _cFilE1 	:= ""
	Local cButton := "QPushButton { background: #35ACCA; font: normal 12px Arial; color: #ffffff;} QPushButton:pressed {background-color: #3AAECB; color: #ffffff; }"
	
	Private _nPos	:= 1
	Private _oBrowse
	Private _aCampos:= {}

	If Select(_cALias) > 0
		(_cALias)->(dbClosearea())
	Endif

	//-------------------------------------
	//-- Busca os títulos na SE1 em aberto
	//-------------------------------------
	_cSql += " SELECT * From "+RetSQLName("SE1")+" SE1 "+CRLF
	_cSql += " WHERE SE1.D_E_L_E_T_ <> '*' "+CRLF
	_cSql += " AND E1_CLIENTE  = '"+_cCliente+"' "+CRLF
	_cSql += " AND E1_LOJA = '01' "+CRLF
	_cSql += " AND E1_PREFIXO = 'COT' "+CRLF
	_cSql += " AND E1_TIPO = 'CSI' "+CRLF
	// ALTERADO POR VITOR AVANCINI - FSW-695
	//_cSql += " AND E1_SALDO = '0' "+CRLF 
	//_cSql += " AND E1_BAIXA <> '' "+CRLF
	_cSql += " AND E1_HIST = 'REF. AUMENTO DE CAPITAL DO COOPERADO' "+CRLF
	_cSql += " Order By E1_FILIAL, E1_NUM, E1_PARCELA "+CRLF

	MemoWrite("C:\LOGSQL\fDelSE1.txt" , _cSql)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cSql)), _cALias, .F., .F.)

	TCSetField(_cALias,"E1_EMISSAO","D")
	TCSetField(_cALias,"E1_BAIXA","D")

	If (_cALias)->(Eof())
		//MsgInfo("Não há títulos.","Atenção!")
		Return()
	Else

		Begin Transaction

			While !(_cAlias)->(Eof())

				_cFilE1 	:= (_cAlias)->E1_FILIAL
				_cCliE1 	:= (_cAlias)->E1_CLIENTE
				_cLojaE1 	:= (_cAlias)->E1_LOJA
				_cPrefE1	:= (_cAlias)->E1_PREFIXO
				_cNumE1 	:= (_cAlias)->E1_NUM
				_cParcE1 	:= (_cAlias)->E1_PARCELA
				_cTipoE1 	:= (_cAlias)->E1_TIPO
				_nVlr		:= (_cAlias)->E1_VALOR
				_dEmissao	:= (_cAlias)->E1_EMISSAO
				_dBaixa		:= (_cAlias)->E1_BAIXA
				_nSaldo		:= (_cAlias)->E1_SALDO

				Aadd(_aCampos,{.F.,_cFilE1,_cCliE1,_cLojaE1,_cPrefE1,_cNumE1,_cParcE1,_cTipoE1,;
				_dEmissao,_nVlr,_dBaixa,_nSaldo})
				(_cAlias)->(dbSkip())
			Enddo

			If ValType(_oBrowse) = "O"
				_oBrowse:FreeChildren()
				FreeObj(_oBrowse)
			Endif

			Define MsDialog _oDlg Title "ESTORNO DE TÍTULOS - COTA CAPITAL DO COOPERADO" From 000, 000  To nJanAltu, nJanLarg COLORS 0, 16777215 Pixel

			@ 005, (nGridLarg - 35) Button _oButton1 Prompt "CONFIRMAR" Size 040, 015 Of _oDlg Action (_nOpc := 1,_oDlg:End()) Pixel
			_oButton1:SetCss(cButton)

			@ 005, (nGridLarg - 85) Button _oButton2 Prompt "CANCELAR"  Size 040, 015 Of _oDlg Action _oDlg:End() Pixel
			_oButton2:SetFont(oFont)

			_oBrowse := Nil
			_oBrowse := MSSelBR():New( 025,005,nGridLarg,nGridAltu,,,,_oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			_oBrowse:SetArray(_aCampos)

			_oBrowse:bLDblClick	:= {|| _aCampos[_oBrowse:nAT,1] := !_aCampos[_oBrowse:nAT,1] }
			_oBrowse:lHasMark	:= .T.
			_oBrowse:bAllMark 	:= {|| fMarkAll(_nPos) }
			_oBrowse:bHeaderClick := {|o,nCol| fOrdena(nCol) }

			If !Empty(_aCampos)
				_oBrowse:AddColumn(TCColumn():New('',			{|| Iif(_aCampos[_oBrowse:nAT,1],_oOk,_oNo)},,,,,,.T.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Filial', 	{|| _aCampos[_oBrowse:nAT,2]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Cliente',	{|| _aCampos[_oBrowse:nAT,3]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Loja', 		{|| _aCampos[_oBrowse:nAT,4]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Prefixo',  	{|| _aCampos[_oBrowse:nAT,5]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Numero',		{|| _aCampos[_oBrowse:nAT,6]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Parcela',   	{|| _aCampos[_oBrowse:nAT,7]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Tipo', 		{|| _aCampos[_oBrowse:nAT,8]},,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Emissão',	{|| _aCampos[_oBrowse:nAT,9]},_cPicture,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Valor',		{|| _aCampos[_oBrowse:nAT,10]},_cPicture,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Baixa',		{|| _aCampos[_oBrowse:nAT,11]},_cPicture,,,'Left',,.F.,.F.,,,,.F.,))
				_oBrowse:AddColumn(TCColumn():New('Saldo',		{|| _aCampos[_oBrowse:nAT,12]},_cPicture,,,'Left',,.F.,.F.,,,,.F.,))			

				Activate MsDialog _oDlg Centered
			Endif

			If _nOpc == 1

				DbSelectArea("SE1")
				DbSetOrder(2) 				//-- E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				DbGoTop()

				For _nx:= 1 to Len(_aCampos)

					If _aCampos[_nx,_nPos] == .T.

						If EMPTY( _aCampos[_nx,11] )

							_nVlSZC += _aCampos[_nx,10]

							If SE1->(DbSeek(_aCampos[_nx,2]+_aCampos[_nx,3]+_aCampos[_nx,4]+_aCampos[_nx,5]+_aCampos[_nx,6]+_aCampos[_nx,7]+_aCampos[_nx,8]))
								_lRet := .T.	//-- achou título e deletou

								//--------------
								//-- Abre a SM0
								//--------------
								DbSelectArea("SM0")
								SM0->(dbSetOrder(1))

								If SM0->(DbSeek( cEmpAnt + _aCampos[_nx,2]))
									cFilial := _aCampos[_nx,2]
									cFilAnt := _aCampos[_nx,2]
									cEmpresa := cEmpAnt + _aCampos[_nx,2]
									MsTcSetParam("FILIAL" , _aCampos[_nx,2])
								Endif

								_aDados := {{"E1_FILIAL"	,_aCampos[_nx,2],Nil},;
								{"E1_PREFIXO" 	,_aCampos[_nx,5]	,Nil},;
								{"E1_NUM"	  	,_aCampos[_nx,6]	,Nil},;
								{"E1_PARCELA" 	,_aCampos[_nx,7]	,Nil},;
								{"E1_TIPO"    	,_aCampos[_nx,8]   	,Nil}}

								lMSErroAuto := .F. 								//-- Inicializa como falso, se voltar verdadeiro é que deu erro
								MSExecAuto({|x,y,z|Fina040(x,y,z)},_aDados,5)	//-- Exclusão

								If lMsErroAuto
									_lRet := .F.
									MostraErro()
									DisarmTransaction()
								Endif
							Endif
						Else
							FWAlertHelp( 'O Titulo '+ _aCampos[_nx,6] +' possui baixa no financeiro', 'Solicite ao financeiro o cancelamento/exclusão da baixa.' )
							DisarmTransaction()
						EndIf
					Endif
				Next _nx
			Endif
		End Transaction

		If _lRet = .T.
			//---------------------------------------------------
			//-- Chama rotina para gerar movimento na tabela SZC
			//---------------------------------------------------
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1))
			SX5->(DbGoTop())

			If SX5->(DbSeek(xFilial("SX5")+'ZC'+"B"))
				_cDescMot := SX5->X5_DESCRI
			Endif

			U_fGeraSZC(_cCodCoop,_dData,"R","B",_nVlSZC,_cDescMot)

			If SZA->(DbSeek(FwxFilial("SZA")+ _cCodCoop))
				RecLock("SZA",.F.)
				//--------------------------------------------------
				//-- Atualiza o campo total de capital do cooperado
				//--------------------------------------------------
				SZA->ZA_CAPITAL += U_EstorSZC(_cCodCoop)
				MsunLock()
			Endif
			MsgInfo("Estorno de aumento realizado com sucesso.","ATENÇÃO!")
		Endif
	Endif

	RestArea(_aAreaSZA)
	RestArea(_aArea)


Return(_cFilE1)



//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkAll
Marca todos os registros do browse.
@author Diego Soares
@since 14/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function fMarkAll(_nPos)
	Local _nx := 0

	for _nx:= 1 to Len(_aCampos)
		_aCampos[_nx,_nPos] := !_aCampos[_nx,_nPos]
	next

Return(Nil)


//---------------------------------------------------------------------
/*/{Protheus.doc} fOrdena
Ordena os campos(coluna) da grid.
@author Diego Soares
@since 14/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function fOrdena(_nCol)

	If _nCol > 1
		aSort(_aCampos,,, {|x,y| x[_nCol] < y[_nCol] } )
	EndIf

	_oBrowse:Refresh()

Return(Nil)


//---------------------------------------------------------------------
/*/{Protheus.doc} fValTok
Valida o campo condição de pagamento. Não deixa o usuário proseguir
sem informar o mesmo.
@author Diego Soares
@since 19/04/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
User Function fValTok(_cCondPG,_oDlg)
	Local _lRet	:= .T.

	If Empty(_cCondPG)
		MsgInfo("Favor informar a condição de pagamento.","ATENÇÃO!")
		_lRet := .F.
	Else
		_oDlg:End()
	Endif


Return(_lRet)
