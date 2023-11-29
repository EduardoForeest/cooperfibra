#include "rwmake.ch"
#Include "protheus.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460FIM   บAutor  ณFabio Passari       บ Data ณ  17/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada apos grava็ใo da nota fiscal de saida     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Inclusใo do Pedido de entrega por conta e ordem conforme   บฑฑ
ฑฑบ          ณ preenchimento do campo F4_TESCO                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M460FIM()  
lMsHelpAuto	:= .T.
lMsErroAuto := .F.  
_aArea:=GETAREA()
_aAreaD2:=SD2->(GETAREA())
_aAreaA1:=SA1->(GETAREA())
_aAreaC5:=SC5->(GETAREA())
_aAreaC6:=SC6->(GETAREA())

MSGBOX("Nota Fiscal "+SF2->F2_DOC+" foi gerada!","Informa็ใo","INFO") 

DBSELECTAREA("SD2")
DBSETORDER(3)
IF DBSEEK(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)    
	_aCabec:={}
	_aItens:={} 
   WHILE !EOF() .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA=SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA 
		_cTesCO:=POSICIONE("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESCO")
		IF !EMPTY( _cTesCO)   
			IF EMPTY(_aCabec)
				aadd(_aCabec,{"C5_NUM"    		,GetSXENum("SC5","C5_NUM"),NIL})
//				aadd(_aCabec,{"C5_NUM"    		,"",NIL})
				aadd(_aCabec,{"C5_TIPO"    	,"N",NIL})		
				aadd(_aCabec,{"C5_CLIENTE"    ,SC5->C5_CLICO,NIL})
				aadd(_aCabec,{"C5_LOJACLI"    ,SC5->C5_LOJACO,NIL})
 				aadd(_aCabec,{"C5_CLIENT"    	,SC5->C5_CLICO,NIL})
				aadd(_aCabec,{"C5_LOJAENT"    ,SC5->C5_LOJACO,NIL})
				aadd(_aCabec,{"C5_TRANSP"    	,SC5->C5_TRANSP,NIL})
				_cTipocli:=POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLICO+SC5->C5_LOJACO,"A1_TIPO")
				aadd(_aCabec,{"C5_TIPOCLI"    ,IF(EMPTY(_cTipocli),SC5->C5_TIPOCLI,_cTipocli),NIL})
				aadd(_aCabec,{"C5_CONDPAG"    ,"ZZZ"		,NIL})
				aadd(_aCabec,{"C5_EMISSAO"    ,dDatabase	,NIL})
				aadd(_aCabec,{"C5_TPFRETE"    ,SC5->C5_TPFRETE 	,NIL})
				aadd(_aCabec,{"C5_FRETCIF"    ,SC5->C5_FRETCIF	,NIL})
				aadd(_aCabec,{"C5_FRETE"    	,SC5->C5_FRETE 	,NIL})
				aadd(_aCabec,{"C5_DESPESA"    ,SC5->C5_DESPESA 	,NIL})
				aadd(_aCabec,{"C5_MOEDA"    	,1 	,NIL})
				aadd(_aCabec,{"C5_SEGURO"    	,SC5->C5_SEGURO 	,NIL})
				aadd(_aCabec,{"C5_PESOL"    	,SC5->C5_PESOL 	,NIL})
				aadd(_aCabec,{"C5_PBRUTO"    	,SC5->C5_PBRUTO 	,NIL})
				aadd(_aCabec,{"C5_VOLUME1"    ,SC5->C5_VOLUME1 	,NIL})
				aadd(_aCabec,{"C5_VOLUME2"    ,SC5->C5_VOLUME2 	,NIL})
				aadd(_aCabec,{"C5_VOLUME3"    ,SC5->C5_VOLUME3 	,NIL})
				aadd(_aCabec,{"C5_VOLUME4"    ,SC5->C5_VOLUME4 	,NIL})
				aadd(_aCabec,{"C5_VOLUME4"    ,SC5->C5_VOLUME4 	,NIL})
				aadd(_aCabec,{"C5_ESPECI1"    ,SC5->C5_ESPECI1 	,NIL})
				aadd(_aCabec,{"C5_ESPECI2"    ,SC5->C5_ESPECI2 	,NIL})
				aadd(_aCabec,{"C5_ESPECI3"    ,SC5->C5_ESPECI3 	,NIL})
				aadd(_aCabec,{"C5_ESPECI4"    ,SC5->C5_ESPECI4 	,NIL})
				aadd(_aCabec,{"C5_MENNFF1"    ,SC5->C5_MENNFF1 	,NIL})
				aadd(_aCabec,{"C5_MENNFF2"    ,SC5->C5_MENNFF2 	,NIL})
				aadd(_aCabec,{"C5_MENNFF3"    ,SC5->C5_MENNFF3 	,NIL})
				_cC5_MENNOT:=ALLTRIM(SC5->C5_MENNOTA)+ALLTRIM(SC5->C5_MENNOT2)+ALLTRIM(SC5->C5_MENNOT3) 
				DBSELECTAREA("SA1")
				DBSETORDER(1)
				IF DBSEEK(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
					_cC5_MENNOT+=" REMESSA POR CONTA E ORDEM DE: "+ALLTRIM(SA1->A1_NOME)
					IF LEN(ALLTRIM(SA1->A1_CGC))=14
						_cC5_MENNOT+=" CNPJ("+TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99")+")"  
					ELSEIF LEN(ALLTRIM(SA1->A1_CGC))=11		  
						_cC5_MENNOT+=" CPF("+TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99")+")"  
				   ENDIF	     
				   IF !EMPTY(SA1->A1_INSCR)
						_cC5_MENNOT+=" IE("+ALLTRIM(SA1->A1_INSCR)+")"  
				   ENDIF                                        
					_cC5_MENNOT+=" NF DE VENDA "+ALLTRIM(SC5->C5_SERIE)+"/"+"000"+ALLTRIM(SC5->C5_NOTA)  
				ENDIF
				_cC5_MENNOT:=ALLTRIM(_cC5_MENNOT)
				SA1->(RESTAREA(_aAreaA1))	  
			  	_nTamTxt:=LEN(CRIAVAR("C5_MENNOTA",.F.))
				IF LEN(_cC5_MENNOT)>_nTamTxt
					aadd(_aCabec,{"C5_MENNOTA",LEFT(_cC5_MENNOT,_nTamTxt),NIL})
					_cC5_MENNOT:=SUBSTR(_cC5_MENNOT,_nTamTxt+1)
					_nTamTxt:=LEN(CRIAVAR("C5_MENNOT2",.F.))
					IF LEN(_cC5_MENNOT)>_nTamTxt
						aadd(_aCabec,{"C5_MENNOT2"    ,LEFT(_cC5_MENNOT,_nTamTxt) ,NIL})
						_cC5_MENNOT:=SUBSTR(_cC5_MENNOT,_nTamTxt+1)
						_nTamTxt:=LEN(CRIAVAR("C5_MENNOT3",.F.))
						aadd(_aCabec,{"C5_MENNOT3"    ,PADR(_cC5_MENNOT,_nTamTxt) 	,NIL})
					ELSE
						aadd(_aCabec,{"C5_MENNOT2"    ,PADR(_cC5_MENNOT,_nTamTxt) ,NIL})
					ENDIF	
				ELSE
					aadd(_aCabec,{"C5_MENNOTA"    ,PADR(_cC5_MENNOT,_nTamTxt),NIL})
				ENDIF			                    
				
				aadd(_aCabec,{"C5_TXMOEDA"    ,1 	,NIL})   
				aadd(_aCabec,{"C5_MENPAD"    	,SC5->C5_MENPAD 	,NIL})
				aadd(_aCabec,{"C5_MENPAD2"   	,SC5->C5_MENPAD2 	,NIL})
				aadd(_aCabec,{"C5_TIPLIB"   	,SC5->C5_TIPLIB 	,NIL})
				aadd(_aCabec,{"C5_VEICULO"   	,SC5->C5_VEICULO	,NIL})
				aadd(_aCabec,{"C5_TIPOCT"   	,SC5->C5_TIPOCT	,NIL})
				aadd(_aCabec,{"C5_ROMANEI"   	,SC5->C5_ROMANEI	,NIL})
				aadd(_aCabec,{"C5_NFREFUS"   	,SF2->F2_DOC		,NIL})
         ENDIF 
         DBSELECTAREA("SC6")  
         DBSETORDER(1)
         IF DBSEEK(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.T.)   
         	WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM=SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV
	       	   _aLinha := {}   
	        	  	aadd(_aLinha,{"C6_ITEM"  	,SC6->C6_ITEM,Nil})
					aadd(_aLinha,{"C6_PRODUTO"	,SC6->C6_PRODUTO,Nil})
					aadd(_aLinha,{"C6_DESCRI"	,SC6->C6_DESCRI,Nil})
					aadd(_aLinha,{"C6_UM"		,SC6->C6_UM,Nil})
					aadd(_aLinha,{"C6_QTDVEN"	,SC6->C6_QTDVEN,Nil})
					aadd(_aLinha,{"C6_QTDLIB"	,SC6->C6_QTDVEN,Nil})
					aadd(_aLinha,{"C6_TES"		,_cTesCO	,Nil})
					aadd(_aLinha,{"C6_PRCVEN"	,IF(SC5->C5_MOEDA<>1,ROUND(SC6->C6_PRCVEN*SC5->C5_TXMOEDA,4),SC6->C6_PRCVEN),Nil})
					aadd(_aLinha,{"C6_VALOR"	,IF(SC5->C5_MOEDA<>1,ROUND(ROUND(SC6->C6_PRCVEN*SC5->C5_TXMOEDA,4)*SC6->C6_QTDVEN,2),SC6->C6_VALOR),Nil})
					aadd(_aLinha,{"C6_LOCAL"	,SC6->C6_LOCAL,Nil})  
					aadd(_aLinha,{"C6_PRUNIT"	,SC6->C6_PRCVEN,Nil})
					aadd(_aLinha,{"C6_CONTRAT"	,CRIAVAR("C6_CONTRAT",.F.),Nil})
					aadd(_aLinha,{"C6_ITEMCON"	,CRIAVAR("C6_ITEMCON",.F.),Nil})
					aadd(_aLinha,{"C6_QFARDOS"	,SC6->C6_QFARDOS,Nil})
			  		aadd(_aItens,_aLinha)
			  		SC6->(DBSKIP())    
			  ENDDO
	      ENDIF
      ENDIF 
      DBSELECTAREA("SD2")
      SD2->(DBSKIP())
   ENDDO 
   IF !EMPTY(_aCabec) .AND. !EMPTY(_aLinha)
//		MSExecAuto({|x,y,z| MATA410(x,y,z)},_aCabec, _aItens, 3)   
		MATA410(_aCabec,_aItens,3)
		IF lMsErroAuto 
			Mostraerro() 
			ROLLBACKSX8()
		ELSE            
			CONFIRMSX8()
      	IF MSGBOX("Deseja Emitir a NF de Remessa por Conta e Ordem?","Emitir NF C/O","YESNO")
				Ma410PvNfs()
      		MSGBOX("Foi Emitido a NF "+SF2->F2_DOC+" para remessa por conta e Ordem","Numero do Pedido","INFO")	
      	ELSE
      		MSGBOX("Foi Emitido o Pedido "+SC5->C5_NUM+" para remessa por conta e Ordem","Numero do Pedido","ALERT")	
      	ENDIF
      ENDIF
   ENDIF
	RESTAREA(_aAreaA1)
	RESTAREA(_aAreaC5)
   RESTAREA(_aAreaC6)
ENDIF 
RESTAREA(_aAreaD2)
RESTAREA(_aArea)   

IF ALLTRIM(SF2->F2_ESPECIE)=="SPED" .and. MSGBOX("Deseja transmitir a nf-e "+SF2->F2_DOC+"?","Transmissใo Nf-e.","YESNO")
//	SpedNFeRe2(SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC)
// U_EnvSefazS(SF2->F2_SERIE,SF2->F2_DOC, cEmpAnt, cFilAnt)
	AutoNfeEnv(SM0->M0_CODIGO,SM0->M0_CODFIL,,,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC)

ENDIF


Return ()

User Function EnvSefazS(_cSerie,_cDoc,_cEmp,_cFil)

	Local cURL 	:= ""
	Local lOk   := .T.
	Local oWs
	Local cAmbiente
	
	If !Used()
	    PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO "FAT"
	Endif
	
	oWs     := WsSpedCfgNFe():New()
	cURL    := PadR(GetMv("MV_SPEDURL"),250)
	If CTIsReady()
	//    cURL        := PadR(GetMv("MV_SPEDURL"),250)  
	//    lOk         := .T.
	//    oWs            := WsSpedCfgNFe():New()
	
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	    //ณObtem o codigo da entidade                                              ณ
	    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    If _cEmp == '01'
		    cIdEnt	:= "000001"
		EndIf
	    
	    If !Empty(cIdEnt)
	        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	        //ณObtem o ambiente de execucao do Totvs Services SPED                     ณ
	        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	        oWS:cUSERTOKEN := "TOTVS"
	        oWS:cID_ENT    := cIdEnt
	        oWS:nAmbiente  := 0   
	        oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	        lOk             := oWS:CFGAMBIENTE()
	        cAmbiente := oWS:cCfgAmbienteResult
	       
	        cAmbiente := Substr(cAmbiente,1,1)
	
	        AutoNfeEnv(cEmpAnt, cEmpAnt, "0", cAmbiente, _cSerie, _cDoc, _cDoc )
	    Endif
	Endif
Return