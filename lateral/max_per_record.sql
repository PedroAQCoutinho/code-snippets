-- This code aims to select the max/min of some attribute per group using lateral on PostgreSQL

CREATE TABLE irregularidades.step14_car_mun AS  
SELECT gid, bar.cd_mun FROM dados_brutos.valid_sicar_imovel vsi , 
LATERAL ( --O lateral entra sempre com as clauses where, order e limit. O where resgada pela igualdade o valor da primeira tabela
SELECT car, cd_mun, area 
FROM layer_fundiario.step14_area_export sae 
WHERE sae.car = vsi.gid
ORDER BY area DESC LIMIT 1 -- O order ordena o atributo que se quer saber o maior ou menor e o limit limita o numero de retornos para cada grupo
) bar
