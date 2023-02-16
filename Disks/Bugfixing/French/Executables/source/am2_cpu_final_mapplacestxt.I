_MapPlaces
	IFD _MainFile
		; nothing
	else
		BOPT	uo+
		BOPT	ue-
		BOPT	ua+
	ENDC

	;Source Created by "Ambermoon Langage File ReSourcer" V1  
	;A Tool done by CFou! on June 2013

Start
	dc.w	(BankListEnd-BankList)/2
BankList
_B00	dc.w	Bank00End-Bank00		;$0018
_B01	dc.w	Bank01End-Bank01		;$0012
_B02	dc.w	Bank02End-Bank02		;$0005
_B03  dc.w  Bank03End-Bank03    ;$0001
BankListEnd

Bank00	dc.b	"Iles Lyramioniques",0
Bank00End
Bank01	dc.b	"Lune de Kire",0
Bank01End
Bank02	dc.b	"Morag",0,0
Bank02End
  END