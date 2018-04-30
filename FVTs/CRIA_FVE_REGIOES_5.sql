
-- CRIA_FVE_REGIOES_5 ---------------------------------------------------------
--------------------------------------------------------------------------------------------------------


if OBJECT_ID ('FVE_REGIOES_5') is not null
	drop function FVE_REGIOES_5
go
create function FVE_REGIOES_5
(@UF as nvarchar (4)) returns nvarchar(20) as 
------------------------------------------------------------------------------------------------------	
begin
declare @Saída as nvarchar (20)
set @Saída = 
	(select case when @UF in 
		(
		'DF',
		'GO',
		'MS',
		'MT'
		) then 'Centro-Oeste'

		when @UF in
		(
		'AL',
		'BA',
		'CE',
		'MA',
		'PB',
		'PE',
		'PI',
		'RN',
		'SE'
		) then 'Nordeste'

		when @UF in
		(
		'AC',
		'AM',
		'AP',
		'PA',
		'RO',
		'RR',
		'TO'
		) then 'Norte'

		when @UF in
		(
		'ES',
		'MG',
		'RJ',
		'SP'
		) then 'Sudeste'

		when @UF in
		(
		'PR',
		'RS',
		'SC'
		) then 'Sul'

		else 'EX' end as 'Região' )

return
 @Saída
end 
go
