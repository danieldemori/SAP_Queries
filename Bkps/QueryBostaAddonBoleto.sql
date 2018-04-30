SELECT 'N' As [*],  T1.ShortName 'Código',
                           T3.CardName 'Cliente',
                           T0.RefDate 'Dt.Lancto',
                           T1.TransId '# L.Contábil',
                           IsNull((case when T0.TransType = 13 then T1.SourceId else null end),'') '# NF SAP',
                           IsNull(Cast((case when T0.TransType = 13 then T1.SourceLine else (T1.Line_ID + 1) end) As Varchar(5)),'') + ' / ' +
                           IsNull(Cast((case when T0.TransType = 13 then (select T8.Installmnt from OINV T8 where T8.DocEntry = T1.SourceId) else (select Count(TransId) from JDT1 T9 where T9.TransId = T0.TransID and T9.Debit > 0) end) As Varchar(5)),'') 'Parcela',
                           T1.DueDate 'Dt.Vencto',
                           (case when T0.TransType = 13 then
                                 (case when isnull((select sum(round(T10.LineTotal,2)) from INV1 T10 where T10.DocEntry = T1.CreatedBy),0) >= isnull((select T10.WTAccAmtAR from OADM T10),0)
                                       then ((T1.Credit + T1.Debit) - round((select isnull(sum(T10.WTAmnt*(T11.InstPrcnt/100)),0) from INV5 T10, INV6 T11 where T10.AbsEntry = T1.SourceId and T11.DocEntry = T10.AbsEntry and T11.InstlmntId = T1.SourceLine and T10.Category = 'P'),2))
                                       else (T1.Credit + T1.Debit) end) else (T1.Credit + T1.Debit) end) 'Valor a receber',
                           Ltrim(IsNull((case when T0.TransType = 13 then (select str(ltrim(T8.Serial)) from OINV T8 where T8.DocEntry = T1.SourceId) else T1.Ref1 end),'')) 'NF Saída/Referência',
                           case when T0.TransType = 13 then (select T9.SlpName from OINV T8, OSLP T9 where T8.DocEntry = T1.SourceId and T9.SlpCode = T8.SlpCode) else 'Lançamento Contábil' end 'Vendedor',
                           case when T0.TransType = 13 then (select IsNull(T8.U_addedObsFin,'') from INV6 T8 where T8.DocEntry = T1.SourceId and T8.InstlmntId = T1.SourceLine) else '' end 'Observação Financeira',
                           IsNull((SELECT T10.Descript FROM OPYM T10 WHERE T10.PayMethCod = T3.PymCode),'') 'Banco Padrão', T1.Line_ID
                           FROM OJDT T0, JDT1 T1, OCRD T3
                           Where T1.TransId = T0.TransId and (T1.RefDate >= Convert(datetime,'2015-03-12',102)) and (T1.RefDate <= Convert(datetime,'2015-03-19',102))
                           and T3.CardCode = T1.ShortName
                           and T3.CardType = 'C' and T3.U_addedBoleto = 'S'
                           and isnull(T0.Stornototr,'') = ''
                           and (Select Count('a') From [@ADD_BOLETO] T10 Where T10.U_TransID = T0.TransId and T10.U_Line_ID = T1.Line_ID and T10.U_Status != '05') <= 0
                           and (Select Count('a') From JDT1 T20 Where T20.TransID = T0.TransId and
                                T20.Account in (Select T21.U_ContaJuros From [@ADD_CARTEIRA] T21 Where IsNull(T21.U_ContaJuros,'') <> '' Group By T21.U_ContaJuros)) <= 0
                           and ((T3.validFor = 'N')  or (T3.validFor = 'Y'  and ISNULL(T3.validFrom,'') <= Convert(DATETIME, GetDate(), 112) and
                                                                            ISNULL(T3.validTo,getdate()) >= Convert(DATETIME, GetDate(), 112)))
                           and ((T3.frozenFor = 'N') or (T3.frozenFor = 'Y' and (ISNULL(T3.frozenTo,GetDate()-1) < Convert(DATETIME, GetDate(), 112) or
                                                                             ISNULL(T3.frozenFrom,GetDate()+1) > Convert(DATETIME, GetDate(), 112))))
                           and T1.Debit <> 0 and T1.Closed = 'N'
                           and ((T0.TransType = 30) or ((T0.TransType = 13) and ((Select Count(docentry) From OINV T30, OCTG T31 Where T30.DocEntry = T1.SourceId and T30.GroupNum = T31.GroupNum and T31.U_addedPriParc = 'N' and T1.SourceLine = 1)<=0 )))
                           and ((T0.TransType = 30) or ((T0.TransType = 13) and ((Select Count(docentry) From OINV T30 Where T30.DocEntry = T1.SourceId and T30.SeqCode='1')<=0 )))
                           and ((T0.TransId <> isnull((select Max(T4.Stornototr) from OJDT T4 where T4.TransType = 30
                           and isnull(T4.Stornototr,'') <> '' and T4.Stornototr=T0.TransId),0)
                                 and T0.TransType = 30) or
                                 (T0.TransType = 13 and ltrim(str(T1.SourceId))+'-'+ltrim(str(T1.SourceLine)) in (select ltrim(str(T5.DocEntry))+'-'+ltrim(str(T5.InstlmntID)) from INV6 T5, INV1 T6, OINV T7 where T5.DocEntry = T7.DocEntry and T7.CardCode = T1.ShortName and T6.DocEntry = T5.DocEntry and isnull(T6.TargetType,0) <> 14 and ltrim(str(T5.DocEntry))+'-'+ltrim(str(T5.InstlmntID)) not in (select ltrim(str(T2.DocEntry))+'-'+ltrim(str(T2.InstId)) from RCT2 T2, ORCT T4 where T2.DocNum = T4.DocNum and
                                                                 T2.InvType = 13 and
                                                                 T4.Canceled = 'N' and
                                                                 T4.CardCode = T1.ShortName) Group by ltrim(str(T5.DocEntry))+'-'+ltrim(str(T5.InstlmntID)))))
                            and (T1.Debit-IsNull((Select Sum(T11.ReconSum) From OITR T10, ITR1 T11
                                                  Where T11.TransId = T0.TransID and T11.TransRowID = T1.Line_ID and
                                                        T11.ReconNum = T10.ReconNum and T11.IsCredit = 'D' and
                                                        LTrim(Str(T0.TransId))+'-'+LTrim(Str(T1.Line_ID)) =
                                                        Ltrim(Str(T11.TransId))+'-'+Ltrim(Str(T11.TransRowId)) and
                                                        T10.Canceled <> 'Y' and
                                                        (T10.ReconType in(0,1,3,4))),0)) <> 0  and isnull(T1.ExtrMatch,'') = '' and isnull(T1.MultMatch,'') = ''
                             Order By  'Cliente', '# NF SAP', 'Parcela'