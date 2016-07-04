select * from ingred_to_ingred where concept_code_1 in (
'372515005' , '108605008')
;
select a.*, b.* from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1
where a.concept_code_1 like '100%'
;
--when names are the same use "7", when one of the names has another one, use - shorter
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1
where a.concept_code_1 like '100%'
;
--seems we found correct relationships to ingredients looks nice
select * from clin_dr_ingred_test;
drop table clin_dr_ingred_test;
create table clin_dr_ingred_test as 
select * from (
select distinct a.concept_code_1, a.concept_name_1, coalesce (b.code_2,a.code_2) as code_2, coalesce (b.name_2,a.name_2) as name_2 , coalesce (b.ins_id_2, a.ins_id_2) as ins_id_2  from 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium', 'Iron') 
--where a.concept_code_1 like '10%'
) a 
left join 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2  from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate',  'Sodium', 'Iron') 
--where a.concept_code_1 like '10%'
) b on (a.concept_code_1 = b.concept_code_1 and a.ins_id_2 > b.ins_id_2 and a.name_2 = b.name_2 
or
 a.concept_code_1 = b.concept_code_1 and lower (a.name_2) like lower ('%'||b.name_2||'%') and a.name_2 != b.name_2 )
 ) a
where not exists (select 1 from 
(
select distinct a.concept_code_1, a.concept_name_1,a.code_2  from 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium', 'Iron') 
--where a.concept_code_1 like '10%'
) a 
 join 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2  from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate',  'Sodium', 'Iron') 
--where a.concept_code_1 like '10%'
) b on (a.concept_code_1 = b.concept_code_1 and a.ins_id_2 > b.ins_id_2 and a.name_2 = b.name_2 
or
 a.concept_code_1 = b.concept_code_1 and lower (a.name_2) like lower ('%'||b.name_2||'%') and a.name_2 != b.name_2 )
 ) c where c.concept_code_1 = a.concept_code_1 and c.code_2 = a.code_2 )
 ;
 select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2  from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate',  'Sodium', 'Iron') 
where a.concept_code_1 like '10%'
;
select * from ingred_to_ingred where concept_code_1 = '3589411000001109'
;
select * from drug_concept_stage where concept_name ='Magnesium chloride'
;
select * from clin_dr_ingred_test a  join (select distinct a.concept_code as concept_code_1, a.concept_name as concept_name_1, a.insert_id as insert_id_1, r.relationship_id, cs.concept_code as concept_code_2, cs.concept_name as concept_name_2, cs.insert_id as insert_id_2   from drug_concept_stage  a
join concept c on a.concept_code = c.concept_code and c.vocabulary_id = 'SNOMED'  and a.concept_class_id ='Ingredient'
 join concept_relationship r on r.concept_id_1 = c.concept_id 
 join concept d on r.concept_id_2 = d.concept_id and d.vocabulary_id = 'SNOMED'
join drug_concept_stage cs on cs.concept_code  = d.concept_code and cs.concept_class_id = 'Ingredient'
and a.concept_code != cs.concept_code
and r.relationship_id in ('Is a', 'Has active ing', 'Concept poss_eq from', 'Concept same_as from') 
and cs.invalid_reason is null) b on a.code_2 = b.concept_code_1
and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate',  'Sodium', 'Iron') 
 ;
 select count (1) from 
 (select distinct a.concept_code as concept_code_1, a.concept_name as concept_name_1, a.insert_id as insert_id_1, r.relationship_id, cs.concept_code as concept_code_2, cs.concept_name as concept_name_2, cs.insert_id as insert_id_2   from drug_concept_stage  a
join concept c on a.concept_code = c.concept_code and c.vocabulary_id = 'SNOMED'  and a.concept_class_id ='Ingredient'
 join concept_relationship r on r.concept_id_1 = c.concept_id 
 join concept d on r.concept_id_2 = d.concept_id and d.vocabulary_id = 'SNOMED'
join drug_concept_stage cs on cs.concept_code  = d.concept_code and cs.concept_class_id = 'Ingredient'
and a.concept_code != cs.concept_code
and r.relationship_id in ('Is a', 'Has active ing', 'Concept poss_eq from', 'Concept same_as from') 
and cs.invalid_reason is null);
 select count (1) from ingred_to_ingred

;
--all the clinical drugs 
select * from drug_concept_stage where concept_code  like '10%' and concept_class_id  ='Clinical Drug' and concept_code not in (
select concept_code from  (
select distinct a.concept_code_1, a.concept_name_1, coalesce (b.code_2,a.code_2) as code_2, coalesce (b.name_2,a.name_2) as name_2 , coalesce (b.ins_id_2, a.ins_id_2) as ins_id_2  from 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium') 
where a.concept_code_1 like '10%'
) a 
left join 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2  from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate',  'Sodium') 
where a.concept_code_1 like '10%'
) b on (a.concept_code_1 = b.concept_code_1 and a.ins_id_2 > b.ins_id_2 and a.name_2 = b.name_2 
or
 a.concept_code_1 = b.concept_code_1 and lower (a.name_2) like lower ('%'||b.name_2||'%') and a.name_2 != b.name_2 )
))
;
select * from concept where lower (concept_name) like '%acetarsol%' and vocabulary_id = 'RxNorm' and concept_class_id = 'Ingredient'
;
select * from 
(
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
left join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium', 'Iron') 
where a.concept_code_1 like '10%'
) a where not exists (select 1 from (
select a.CONCEPT_CODE_1,a.CODE_2 from Clinical_to_Ingred a
 join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium', 'Iron') 
where a.concept_code_1 like '10%'
) c where a.concept_code_1 = c.concept_code_1 and a.code_2 = c.code_2)

;
select a.*, coalesce (b.concept_code_2,a.concept_code_2) as code_2, coalesce (b.concept_name_2,a.concept_name_2) as name_2 , coalesce (b.insert_id_2, a.insert_id) as ins_id_2 from Clinical_to_Ingred a
join ingred_to_ingred b on a.concept_code_2 = b.concept_code_1 and b.concept_name_2 not in ('Calcium', 'Zink', 'Potassium', 'Magnesium', 'Chloride', 'Bicarbonate', 'Sodium', 'Iron') 
where a.concept_code_1 like '10%'
;
select * from Dexpanthenol
;
select * from Ingr_to_Rx_existing  where concept_name_1 ='Ergocalciferol'
;
select * from concept where concept_name in ('Ergocalciferol', 'Vitamin D', 'Cholecalciferol')
and vocabulary_id = 'RxNorm' and concept_class_id = 'Ingredient'
;
select * from drug_concept_stage where concept_name like '%Ergocalciferol%'
;
select * from drug_concept_stage where concept_name like '%lecalciferol%'
;
select * from concept where regexp_like ( lower (concept_name), ' tar$' )and vocabulary_id ='RxNorm'  and concept_class_id = 'Ingredient'
-- OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY
;
select * from drug_concept_stage where  regexp_like ( lower (concept_name), ' tar$' )
;
select * from concept where regexp_like ( lower (concept_name), 'codeine' )and vocabulary_id ='RxNorm'  and concept_class_id = 'Ingredient'
;
select * from concept where vocabulary_id ='RxNorm'  and concept_class_id = 'Ingredient'
;
select * from drug_concept_stage where lower (concept_name) like '%influenzae type b%'
;
select * from ingred_to_ingred a left join  Ingr_to_Rx_existing b on a.CONCEPT_CODE_1 = b.CONCEPT_CODE_1 
left join Ingr_to_Rx_existing c on a.CONCEPT_CODE_2 = c.concept_code_1
join RxNorm_precise s on b.concept_id_2 = s.concept_id_1 and c.concept_id_2 = s.concept_id_2
where STANDARD_CONCEPT_1 is null
;
 select * from dev_amis.source_table where enr=2600003;
 ;
select distinct *
 from strength_tmp a join strength_tmp b on a.drug_code = b.drug_code 
 and (a.DENOMINATOR_VALUE is null and b.DENOMINATOR_VALUE is not null  
 or a.DENOMINATOR_VALUE != b.DENOMINATOR_VALUE
 or a.DENOMINATOR_unit != b.DENOMINATOR_unit);
 
create table RxNorm_precise as 
select a.concept_id as concept_id_1, a.concept_name as concept_name_1, a.standard_concept as standard_concept_1, c.concept_id as concept_id_2, c.concept_name as concept_name_2, c.standard_concept as standard_concept_2 from devv5.concept  a 
join devv5.concept_relationship b on a.concept_id = b.concept_id_1
join devv5.concept c on c.concept_id = b.concept_id_2
where a.vocabulary_id ='RxNorm' and c.vocabulary_id ='RxNorm'-- and a.concept_class_id ='Ingredient' and c.concept_class_id ='Ingredient'
and b.relationship_id ='Form of'
;
from devv5.concept c1
join devv5.concept_relationship r on r.concept_id_1=c1.concept_id and r.invalid_reason is null and r.relationship_id='Form of'
join devv5.concept c2 on c2.concept_id=r.concept_id_2
--where c1.concept_id=46274851;
;
;
select * from devv5.concept where lower (concept_name)  like '%dergocrine%' and concept_class_id ='Ingredient'
;
select concept_code, concept_name from drug_concept_stage where lower (concept_name)  like '%mucin%'
;
select * from Clinical_to_Ingred where concept_code_2 = '3862511000001103'
;
select * from devv5.concept where lower (concept_name) like '%atenolol%' and concept_class_id ='Clinical Drug' and vocabulary_id = 'RxNorm'
;
select * from drug_concept_stage where concept_name ='Atenolol 10mg/5ml oral suspension 1 ml'
;
select * from drug_concept_stage
;
select * from devv5.concept where lower (concept_name) like '%gynest%'  and vocabulary_id = 'RxNorm'
;
select * from devv5.concept where regexp_like (concept_name, ' \d+')and vocabulary_id = 'DPD' and concept_class_id = 'Brand Name'
OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY;
select * from concept where vocabulary_id='DPD' and concept_class_id='Brand Name' and concept_name like '%200%';
;
select * from drug_concept_stage where concept_name = 'Atenolol 10mg/5ml oral suspension 1 ml'
;
select * from drug_concept_stage where concept_name = 'Lidocaine'
;
select * from devv5.concept where lower (concept_name) like '%betamethasone%' and vocabulary_id = 'RxNorm' and concept_class_id ='Clinical Drug'
;
select  * from devv5.concept a 
join ds_stage_need_manual b 
on lower ( a.concept_name) = lower ( regexp_replace (b.concept_name, '\s.*'))
where vocabulary_id = 'RxNorm' and concept_class_id ='Brand Name' and invalid_reason is null
--and concept_name like '% / %'
;
select *from ds_stage_need_manual b
join  devv5.concept a 
on lower ( regexp_replace ( regexp_substr (b.CONCEPT_NAME, 'Generic [[:alpha:]]+'),'Generic ')) = lower ( a.concept_name)
join concept_relationship r o
join concept cc on cc.
where b.concept_name like 'Generic%'
and  a.vocabulary_id = 'RxNorm' and a.concept_class_id ='Brand Name' and invalid_reason is null
;
select * from devv5.drug_strength 
OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY;
;
select count (*) from INGR_MAPPED
where CONCEPT_CODE not in (
select CONCEPT_CODE_1 from  INGREDIENT_MAP)
;
select * from  INGREDIENT_MAP   --used in Script
where CONCEPT_CODE_1 not in (
select CONCEPT_CODE from  INGR_MAPPED union select  concept_code_1 from Ingr_to_Rx_existing)
;
select * from Clinical_to_Ingred_tmp
;
select * from drug_concept_stage where concept_name ='Betamethasone'
;
select * from ingred_to_ingred_FINAL_BY_Lena where concept_name_1 = 'Fluocinolone'
;
select * from non_drug where drug_code ='3392811000001100'
;
select * from drug_concept_stage where concept_name like'%TISSEEL%'
;
select * from aut_form_mapped_noRx_pack
;
select * from drug_concept_stage where lower ( concept_name) = '%clotrimazole 500mg%'
;
select count (1) FROM DRUG_concept_stage where concept_class_id ='Clinical Drug' and invalid_reason is null and concept_code not in (select concept_code from clnical_non_drug)
;
select * from clin_dr_to_ingr_3
;
select * from dr_pack_to_Clin_dr_box_full where concept_code_1='9520911000001104'
;
select distinct concept_class_id from concept where standard_concept is not null and vocabulary_id = 'RxNorm'
;
select * from devv5.concept where vocabulary_id = 'ICD9CM'
;
select * from drug_concept_stage where concept_name like '%Buclizine%';
select * from INGRED_TO_INGRED_FINAL_BY_LENA where concept_name_1 like '%Buclizine%';

select * from drug_concept_stage where concept_class_id ='Ingredient' and concept_code not in (select concept
;
select * from devv5.concept a
join devv5.drug_strength b on a.concept_id =b.drug_concept_id
where vocabulary_id = 'RxNorm' 
and a.invalid_reason is not null
;
select distinct DRUG_CODE,DRUG_NEW_NAME,CONCEPT_CODE_2,INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_2 where a.drug_code like '%OMOP%' and concept_Code_2 is not null
union
select distinct DRUG_CODE,DRUG_NEW_NAME,CONCEPT_CODE_1,INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_1 where a.drug_code like '%OMOP%' and concept_Code_2 is null
;
select distinct CONCEPT_CODE,CONCEPT_NAME,CONCEPT_CODE_2,CONCEPT_NAME_2 from drug_to_ingr
;
select * from pack_drug_to_code_2_1
;
select * from CLIN_DR_TO_DOSE_FORM where concept_code_1 like 'OMOP%'
;
select * from internal_relationship_stage where CONCEPT_CODE_2 like 'OMOP%'
;
select * from ds_stage where drug_CONCEPT_CODE = '395439003'
;
--there are 90 concepts don't have ds_stage info
select distinct CONCEPT_CODE_2, CONCEPT_NAME_2 from drug_concept_stage a
join Branded_to_clinical b on a.CONCEPT_CODE = b.CONCEPT_CODE_1
left join ds_stage c on c.drug_concept_code = b.concept_code_2
left join non_drug_full d  on d.concept_code = b.concept_code_2
left join pack_content e on e.PACK_CONCEPT_CODE = b.concept_code_2
 where a.concept_code not in (select drug_concept_code from ds_stage) and a.concept_class_id like '%Drug%' and a.concept_class_id not like '%Pack%'
 and a.invalid_reason is null and a.domain_id = 'Drug'
 ;
 --need to go throught branded to clinical and fix Tissel
 
 select * from drug_concept_stage where concept_code ='28989911000001108'
;
select * from clinical_to_ingred_tmp where CONCEPT_CODE_1 like 'OMOP%'  
;
clinical_to_ingred_tmp
;
select distinct DRUG_CODE, INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 
;
select distinct DRUG_CODE,DRUG_NEW_NAME,CONCEPT_CODE_2,INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_2 where a.drug_code like '%OMOP%' and concept_Code_2 is not null
union
select distinct DRUG_CODE,DRUG_NEW_NAME,CONCEPT_CODE_1,INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_1 where a.drug_code like '%OMOP%' and concept_Code_2 is null
--count  =25  
;
select distinct DRUG_CODE,DRUG_NEW_NAME,coalesce (CONCEPT_CODE_2, concept_code_1), coalesce (CONCEPT_name_2, concept_name_1) from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_1 where a.drug_code like '%OMOP%' 
union
select distinct DRUG_CODE,DRUG_NEW_NAME,CONCEPT_CODE_1,INGREDIENT_NAME from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_1 where a.drug_code like '%OMOP%' and concept_Code_2 is null
;


create table ds_omop as(
select distinct DRUG_CODE,DRUG_NEW_NAME,coalesce (CONCEPT_CODE_2, concept_code_1) as CONCEPT_CODE_2 , coalesce (CONCEPT_name_2, concept_name_1) as CONCEPT_name_2 from PACK_DRUG_TO_CODE_2_2 a join INGRED_TO_INGRED_FINAL_BY_LENA b on a.ingredient_name=b.concept_name_1 where a.drug_code like '%OMOP%' 
) ;
update ds_omop
set DRUG_NEW_NAME = regexp_replace (DRUG_NEW_NAME, ' / ', '!')
;
--Packs present in ds_stage
select a.*, b.*, c.concept_name, d.concept_name, e.concept_name from pack_content a 
join ds_stage b on a.PACK_CONCEPT_CODE = b.DRUG_CONCEPT_CODE 
join drug_concept_stage c on a.PACK_CONCEPT_CODE = c.concept_code
join drug_concept_stage d on a.DRUG_CONCEPT_CODE = d.concept_code
join drug_concept_stage e on b.INGREDIENT_CONCEPT_CODE = e.concept_code
;
select b.*, c.concept_name, d.concept_name from
 ds_stage b 
join drug_concept_stage c on b.drug_concept_code= c.concept_code
join drug_concept_stage d on b.ingredient_concept_code = d.concept_code

where b.drug_concept_code in (select concept_code from drug_concept_stage where domain_id !='Drug') --782
;
select b.*, c.concept_name, d.concept_name from
 ds_stage b 
join drug_concept_stage c on b.drug_concept_code= c.concept_code
join drug_concept_stage d on b.ingredient_concept_code = d.concept_code

where b.drug_concept_code in (select concept_code from non_drug_full) --773
;
select b.*, c.concept_name, d.concept_name from
 ds_stage b 
join drug_concept_stage c on b.drug_concept_code= c.concept_code
join drug_concept_stage d on b.ingredient_concept_code = d.concept_code
where b.drug_concept_code in (select concept_code from drug_concept_stage where domain_id !='Drug') --782
;
select * from drug_concept_stage where domain_id !='Drug' and concept_class_id = 'Clinical Drug' 
and concept_code in (select drug_concept_code from ds_stage)
;
select * from drug_concept_stage where concept_code='30962611000001107'
;
select * from devv5.drug_strength where rownum < 10
;
select * from lost_ingr_to_rx_with_OMOP
;
select regexp_substr ('1hour', '(g|dose|ml|mg|ampoule|litre|hour(s)*|h*|square cm|microlitres)$') from dual
;
select * from drug_concept_stage where concept_code = '32518911000001103'
;
select * from concept
;
select * from devv5.drug_strength_stage
;
insert /*+ APPEND */ into drug_strength_stage
-- dedup same ingredient in product and sum up the amounts
select drug_concept_code, vocabulary_id_1, ingredient_concept_code, vocabulary_id_2,
  sum(amount_value) as amount_value,
  amount_unit_concept_id,
  sum(numerator_value) as numerator_value,
  numerator_unit_concept_id,
  sum(denominator_value) as denominator_value,
  denominator_unit_concept_id, valid_start_date, valid_end_date, invalid_reason
  ;
 select * from  devv5.concept where concept_name like '%Pack%' and vocabulary_id = 'RxNorm' and concept_class_id= 'Branded Pack' and rownum < 100
 join concept_relatinship r on r,co
 ;
 select * from  devv5.concept a
  join devv5.concept_relationship b on a.concept_id=concept_id_2 
  join devv5.concept c on concept_id_2=c.concept_id 
  where a.vocabulary_id = 'RxNorm' and a.concept_class_id= 'Branded Pack'
    and c.concept_class_id = 'Brand Name';
    
select * from drug_concept_stage where concept_name like 'Generic%' 
and concept_class_id = 'Clinical Drug' and domain_id ='Drug'
;

  select distinct a.concept_class_id
  --a.concept_code as concept_code_1, a.concept_name as concept_name_1 , d.concept_code, d.concept_name 
  from drug_concept_stage  a
join concept c on a.concept_code = c.concept_code and c.vocabulary_id = 'SNOMED' 
 join concept_relationship r on r.concept_id_1 = c.concept_id 
 join concept d on r.concept_id_2 = d.concept_id and d.vocabulary_id = 'ATC'
;

Clinical_to_Ingred_tmp -- here is one component

drop table clin_dr_to_ingr_one;
create table clin_dr_to_ingr_one as 
select distinct a.*, concept_code_2 as ingredient_concept_code, concept_name_2 as ingredient_concept_name, insert_id_2 from drug_concept_stage_tmp_0 a join Clinical_to_Ingred_tmp  b on 
 a.concept_code = b.concept_code_1
where b.concept_code_1 in 
(
select concept_code_1 from Clinical_to_Ingred_tmp group by concept_code_1 having count (1) = 1)
;
select * from clin_dr_to_ingr_one a join drug_concept_stage_tmp_0 b on a.CONCEPT_CODE = b.CONCEPT_CODE and b.INGR_CNT >1
;
select * from ingred_to_ingred_FINAL_BY_Lena where concept_code_2 = '18288009'
;
select * from Clinical_to_Ingred where CONCEPT_CODE_2 = '18288009'
;
select * from devv5.concept where concept_name  like '%Factor VIII%' and vocabulary_id = 'RxNorm'
;
select * from devv5.concept where upper (concept_name) like  '%VON WILLEBRAND FACTOR%' and vocabulary_id = 'RxNorm'
;
select regexp_substr ('1million unit/hours gsfgds' ,
 '[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*') as dosage
from dual
;
select * from drug_concept_stage where lower ( concept_name) = 'chewable tablets'
;
select * from aut_form_mapped_noRx_pack
;
select * from 
concept_relationship crs 
RIGHT JOIN concept cs ON cs.concept_id=crs.concept_id_1
RIGHT JOIN concept cs2 ON crs.concept_id_2=cs2.concept_id
WHERE crs.concept_id_1 IS NULL AND crs.concept_id_2 IS NULL and cs2.vocabulary_id='RxNorm' and cs2.invalid_reason is null
;
select * 
from devv5.concept a join
devv5.concept_relationship b on b.concept_id_2 =  a.concept_id 
join  devv5.concept c on b.concept_id_1 = c.concept_id and c.concept_class_id like '%Drug%'
where a.concept_class_id ='Ingredient' --and b.RELATIONSHIP_ID = 'Has brand name' 
and a.vocabulary_id = 'RxNorm' and c.vocabulary_id = 'DPD'
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY;

select * 
from devv5.concept a join
devv5.concept_relationship b on b.concept_id_2 =  a.concept_id 
join  devv5.concept c on b.concept_id_1 = c.concept_id and c.concept_class_id like '%Drug%'
where a.concept_class_id ='Dose Form'-- and b.RELATIONSHIP_ID = 'RxNorm has ing' 
and a.vocabulary_id = 'RxNorm' and c.vocabulary_id = 'RxNorm'
and 
;

select * from Clinical_to_Ingred_tmp where concept_code_1 like '17874611000001107'
;
--Missing relationship to Dose Form
select distinct a.* from drug_concept_stage a where concept_class_id like '%Drug%' and concept_class_id not like '%Comp%' and concept_code not in(
select a.concept_code from  drug_concept_stage a 
join internal_relationship_stage s on s.concept_code_1= a.concept_code  
join drug_concept_stage b on b.concept_code = s.concept_code_2
 and  a.concept_class_id like '%Drug%'  and b.concept_class_id ='Dose Form'
)
and domain_id = 'Drug' and a.concept_class_id not like '%Pack%' and invalid_reason is null and concept_class_id = 'Clinical Drug'
;
select * from ds_all_tmp where INGREDIENT_CONCEPT_CODE is null
;
select * from nondrug_with_ingr where DRUG_CONCEPT_CODE like '%dressing%'
;
select count(*) from concept_relationship r
join concept a on a.concept_id = r.concept_id_1 and a.vocabulary_id = 'DPD'
join concept b on b.concept_id = r.concept_id_2 and b.vocabulary_id = 'RxNorm'
where a.concept_class_id != b.concept_class_id
and relationship_id ='Maps to'
;
select *  from drug_concept_stage where trim(lower(concept_name)) in (
    select trim(lower(concept_name)) as n from drug_concept_stage where concept_class_id in ('Brand Name', 'Dose Form', 'Unit', 'Ingredient') group by trim(lower(concept_name)) having count(8)>1)
    ;
    select * from concept
    ;
   --1
 select * from drug_concept_Stage a 
 join ds_stage b on a.concept_code = b.drug_concept_code 
 where regexp_like (concept_name, '\d+ ampoule')
 and box_size is  null
;
--2
 select count (*) from drug_concept_Stage a 
 join ds_stage b on a.concept_code = b.drug_concept_code 
 where regexp_like (concept_name, '\d+(ml||g|l)') and not regexp_like (concept_name, '/\d+(ml|l|g)')
 and denominator_value is null
 ;
 --2
 select *from drug_concept_Stage a 
 join ds_stage b on a.concept_code = b.drug_concept_code 
 where regexp_like (concept_name, '\d+(litre|ml)') and not regexp_like (concept_name, '/\d+(litre|ml)')
 and denominator_value is null
 ;
 select CONCEPT_CODE_1, CONCEPT_CODE_2, CONCEPT_ID_1, CONCEPT_ID_2, z.INVALID_REASON, RELATIONSHIP_ID, z.VALID_END_DATE, z.VALID_START_DATE, VOCABULARY_ID_1, VOCABULARY_ID_2, a.concept_name, b.concept_name from concept_relationship_stage z

join concept a on a.concept_code = concept_code_1 and a.vocabulary_id = 'RxNorm'
join concept b on b.concept_code = concept_code_2
where concept_code_1 ='1000126' 

-- group by CONCEPT_CODE_1, CONCEPT_CODE_2, CONCEPT_ID_1, CONCEPT_ID_2, INVALID_REASON, RELATIONSHIP_ID, VALID_END_DATE, VALID_START_DATE, VOCABULARY_ID_1, VOCABULARY_ID_2
 --having count (1) > 1
 ;
 select * from drug_concept_stage where concept_class_id = 'Clinical Drug' 
 ;
select max ( cast ( regexp_substr (concept_code, '\d+') as int))
from devv5.concept
where concept_code like 'OMOP%' and  concept_code not like 'OMOP %'
;
select * from concept_relationship_stage a 
join concept_stage  b on a.concept_code_1 = b.concept_code
join concept_stage c on a.concept_code_2 = c.concept_code
 where vocabulary_id_1 = 'Gemscript' and b.concept_class_id = 'Gemscript THIN' and vocabulary_id_2 !='RxNorm Extension'
and C.standard_CONCEPT IS NOT NULL
 ;

 ;
 select a.*, b.standard_concept from concept_relationship_stage a
join concept_stage b on a.concept_code_2 = b.concept_code
 where concept_code_1 =
 '99947994'
 ;
 select * from concept_stage where concept_code in ('48185020')
 ;
 select * from 
;
select * from concept_relationship_stage where vocabulary_id_2 ='RxNorm Extension' and vocabulary_id_1 ='dm+d'  and RELATIONSHIP_ID ='Maps to' and c
;
select * from concept_relationship_stage where concept_code_1 is null
;
 --'324727008'
 select distinct RELATIONSHIP_ID from concept_rel_stage_no_RxE where concept_code_2 =' '
 ;
select  from concept_Stage where concept_code =' '
 ;
 select max (cast (regexp_substr(concept_code, '\d+') as int)) from drug_concept_stage where concept_code like 'OMOP%'
 ;
 select * from drug_concept_stage where concept_code = 'OMOP252850'
 ;
 select count (1)/* distinct RELATIONSHIP_ID*/ from dev_amis.concept_relationship_stage where concept_code_2 =' '
 ;
  select * from concept_relationship_stage a
  join concept_Stage b on a.concept_code_1 = b.concept_code
where concept_code_2 =' '
;
  select * from concept_relationship_stage a
    join concept_Stage b on a.concept_code_1 = b.concept_code
    join concept c on a.concept_code_2 = c.concept_code
    where b.concept_class_id like '%Drug%'
    and c.concept_class_id = 'Ingredient'
    ;
      select * from dev_amis.concept_relationship_stage a
    join dev_amis.concept_Stage b on a.concept_code_1 = b.concept_code
    join dev_amis.concept c on a.concept_code_2 = c.concept_code
    where c.concept_class_id like '%Drug%'
    and b.concept_class_id = 'Ingredient'
    ;
    delete from concept_relationship_stage where concept_code_2 =''
    ;
    
    
  select dump(concept_code_2) from dev_dmd.concept_relationship_stage where concept_code_1='48185020'
union all
select dump(concept_code_1) from dev_dmd.concept_relationship_stage where concept_code_1='5680811000001101'
;
select concept_code_2 from dev_dmd.concept_relationship_stage where concept_code_1='48185020'
;
select concept_code_1 from dev_dmd.concept_relationship_stage where concept_code_1='5680811000001101'
;
select regexp_substr ('OMOP12354', '[[:alpha:]]*\d*') from dual
;
update concept_stage set concept_code = regexp_substr('concept_code', '[[:alpha:]]*\d*')
;
select concept_code,regexp_substr(concept_code, '[[:alpha:]]*\d*')  from concept_stage where concept_code!=regexp_substr(concept_code, '[[:alpha:]]*\d*')
;
select concept_code_2,regexp_substr(concept_code_2, '[[:alpha:]]*\d*')  from concept_relationship_stage 
;
/*
update concept_relationship_stage set concept_code_2=regexp_substr(concept_code_2, '[[:alpha:]]*\d*')
where concept_code_2!=regexp_substr(concept_code_2, '[[:alpha:]]*\d*') and vocabulary_id_2 !='ATC'
*/
;
select * from concept_relationship_stage a 
join concept_relationship_stage b
where a.vocabulary_id_2 like 'RxNorm%'
;
select * from drug_strength_stage  where numerator_value is not null  and DENOMINATOR_UNIT_CONCEPT_ID is null and denominator_value is null;

select * from ds_stage where numerator_value is not null and DENOMINATOR_UNIT is null and denominator_value is null;

select * from concept_stage where concept_code='OMOP274793'
;
select * from existing_ds where 
;
select * from drug_strength_stage 
;
select * from concept where concept_code ='K07.6'
;
select * from concept_relationship_stage where vocabulary_id_1 = 'Gemscript'
--delete mappings to non-standard concepts
;
--check 
select
 distinct cs.concept_class_id 
 from concept_relationship_stage a
join concept_stage b on b.concept_code = a.concept_code_1
join concept_stage cs on cs.concept_code = a.concept_code_2
 where a.vocabulary_id_1 ='dm+d'-- and a.vocabulary_id_2 like 'RxNorm%' 
and  a.relationship_id in  ('Has standard ing') --and b.concept_class_id = 'Ingredient'
;
select * from concept_stage where concept_code in (
select cs.concept_code
from concept_stage cs 
LEFT JOIN concept_relationship_stage crs ON crs.CONCEPT_CODE_1=cs.concept_code and crs.RELATIONSHIP_ID in('Marketed form of',  'Maps to', 'Concept replaced by')
WHERE cs.concept_class_id like 'Marketed%' GROUP BY cs.concept_code HAVING count(distinct crs.rowid) != 1
)
;
select distinct relationship_id from concept_relationship_stage
;
select count (*) from concept_stage a 
left join concept_relationship_stage b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='Has standard form'
where a.concept_class_id like '%Form%' 
and a.vocabulary_id = 'RxNorm Extension'
and b.concept_code_1 is null 
;
select count (*) from concept_stage a 
left join concept_relationship_stage b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='RxNorm has ing'
where a.concept_class_id like '%Branded%' and domain_id = 'Drug' and a.invalid_reason is null
and a.vocabulary_id = 'RxNorm Extension'
and b.concept_code_1 is not null 
;
select count (*) from concept_stage_no_rxe a 
left join concept_rel_stage_no_rxe b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='RxNorm has dose form'
where a.concept_class_id like '%Form%' 
and a.vocabulary_id = 'dm+d'
and b.concept_code_1 is not null 
;
select * from concept_rel_stage_no_rxe where RELATIONSHIP_ID  ='RxNorm has dose form'
;
select * from concept_rel_stage_no_rxe where RELATIONSHIP_ID  ='RxNorm ing of' and vocabulary_id_2 = 'RxNorm'
;
select count (*) from concept_stage_no_rxe a 
left join concept_rel_stage_no_rxe b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='RxNorm has ing'
where a.concept_class_id like '%Branded%'  and domain_id = 'Drug' and a.invalid_reason is null
and a.vocabulary_id = 'dm+d'
and b.concept_code_1 is  null 
;
select count (*) from concept_stage a 
left join concept_relationship_stage b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='Has supplier'
where a.concept_class_id like '%Marketed%' and domain_id = 'Drug' and a.invalid_reason is null
and a.vocabulary_id = 'RxNorm Extension'
and b.concept_code_1 is  null
;
select count (*) from concept_stage a 
left join concept_relationship_stage b on a.concept_code = b.concept_code_1 and RELATIONSHIP_ID  ='Has supplier'
where a.concept_class_id like '%Marketed%' and domain_id = 'Drug' and a.invalid_reason is null
and a.vocabulary_id = 'RxNorm Extension'
and b.concept_code_1 is  null
;
select * from concept_relationship_stage where vocabulary_id_1 = 'RxNorm' and vocabulary_id_2 = 'RxNorm'
;
select *  from drug_strength_stage where vocabulary_id_1 = 'RxNorm' 
;
select *  from drug_strength_stage where concept_code_2 = '374445'
;
select * from concept_stage where concept_class_id like '%Pack%'
;
select * from drug_concept_stage where concept_code='100011000001108';
select * from ds_s
;
--proper relationship to/for units
select * from relationship_to_concept  rc where concept_code_1 not in (select concept_CODE FROM DRUG_CONCEPT_STAGE)
;
select concept_code_1 from relationship_to_concept  rc 
JOIN DRUG_CONCEPT_STAGE ON concept_code_1 = concept_code AND CONCEPT_CLASS_ID = 'Unit'
--where concept_code_1 not in (select concept_CODE FROM DRUG_CONCEPT_STAGE)
minus select AMOUNT_UNIT from UNIT_FOR_UCUM
;
select * from relationship_to_concept_2706 where concept_code_1 not in (select concept_code_1 from relationship_to_concept)
;
select * from unit_for_ucum where AMOUNT_UNIT ='c'
;
select * from unit_for_ucum where CONCEPT_ID_2 in ( '9325', '9324')
;
--
Select distinct concept_code, concept_name,ds_stage.*  from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*/[[:digit:]\.]+ml+') and invalid_reason is null
;

Select distinct concept_name, regexp_substr(concept_name , '(\d)+(\s)*(\%)+')  from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '(\d)+(\s)*(\%)+') and  invalid_reason is null
;
select * from ds_stage where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '(\d)+(\s)*(\%)+') and  invalid_reason is null
)
;
--update ds_stage for those having incorrectly parsed dosages
select a.concept_name, a.concept_class_id, b.* from drug_concept_stage a
join ds_stage b on a.concept_code = b.drug_concept_code
where regexp_like (concept_name , '[[:digit:]\.]+.*/ml.*ml')
and not regexp_like (concept_name , '[[:digit:]\.]+.*/ml.*[[:digit:]\.]+ml')
and concept_class_id = 'Clinical Drug'
and rownum < 100
;
select * from ds_stage
join drug_concept_stage
on drug_concept_code=concept_Code  where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*/[[:digit:]\.]+ml+') and invalid_reason is null
)
and drug_concept_code not in (Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where (numerator_value is not null or amount_value is not null) and concept_class_id='Clinical Drug')
;
select a.*, b.concept_name from ds_stage a 
join drug_concept_stage b 
on drug_concept_code=concept_Code  where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*/[[:digit:]\.]+ml+') and invalid_reason is null
)
and drug_concept_code  in (Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where (numerator_value is not null or amount_value is not null) and concept_class_id='Clinical Drug')
;
select a.*, b.concept_name from ds_stage a 
join drug_concept_stage b 
on drug_concept_code=concept_Code  where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and invalid_reason is null
)
and drug_concept_code  in (Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where (numerator_value is not null or amount_value is not null) and concept_class_id='Clinical Drug')
;
select a.*, b.concept_name from ds_stage a 
join drug_concept_stage b 
on drug_concept_code=concept_Code  where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '(\d)+(\s)*(\%)+') and invalid_reason is null
)
and drug_concept_code not in (Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where (numerator_value is not null or amount_value is not null) and concept_class_id='Clinical Drug')
;
select distinct * from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and concept_name like '%Kallikrein inactivator%';
;
select * from ds_stage
join drug_concept_stage
on drug_concept_code=concept_Code  where drug_concept_code in (
Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*/[[:digit:]\.]+ml+') and invalid_reason is null
)
and drug_concept_code not in (Select distinct drug_concept_code from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where (numerator_value is not null or amount_value is not null) and concept_class_id='Clinical Drug')
;
select regexp_substr
('20million units', 
'[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*')  
from dual
;
select distinct concept_code, concept_class_id , invalid_reason,
concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and concept_name like '%Bio-Biloba%' and invalid_reason is null;
;
select * from ds_all where concept_class_id = '14679411000001109'
;
select * from  
branded_to_clinical where concept_code_1  = '14679411000001109'
;
Select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+(mg)+') 
and drug_concept_code in (select drug_concept_code from ds_stage group by drug_concept_code having count(1)=1);
;
Select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*ml?/[[:digit:]]?(unit|litre)+');

Select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null  and regexp_like  (concept_name , '[[:digit:]\.]+.*/[[:digit:]\.]?drop+');

select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and concept_name like '%Bio-Biloba%' and invalid_reason is null;
;
Select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+.*ml?/[[:digit:]]?(unit|litre)+')
;
Select distinct concept_name from ds_stage join drug_concept_stage
on drug_concept_code=concept_Code Where numerator_value is null and amount_value is null and concept_class_id!='Clinical Drug' and regexp_like (concept_name , '[[:digit:]\.]+(mg)+') and concept_class_id not like '%Pack%'
and drug_concept_code in (select drug_concept_code from ds_stage group by drug_concept_code having count(1)=1)
;
select * from drug_concept_stage where concept_name like '%actuation%'
;
select * from ds_stage where drug_concept_code = '29879711000001106'
;
select * from drug_concept_name where re
'[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm|million units| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol)/*[[:digit:]\,\.]*(actuation|application)*')
;
select * from ds_stage where drug_concept_code ='349392002'
;
select * from drug_concept_stage where concept_name like '%+%'
;
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena
;
SELECT *FROM DRUG_CONCEPT_STAGE WHERE CONCEPT_NAME ='Dihydrocodeine'
;
--Lena's table check up
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_CODE_1 IN (
SELECT CONCEPT_CODE_1 FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 LIKE '%+%' GROUP BY CONCEPT_CODE_1 HAVING COUNT (1) = 1)
;
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_CODE_1 IN (
SELECT CONCEPT_CODE_1 FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 LIKE '%+%' GROUP BY CONCEPT_CODE_1 HAVING COUNT (1) > 1)
;
select a.* from ingred_to_ingred_FINAL_BY_Lena a
join (
SELECT CONCEPT_CODE_1, count (1) as cnt  FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 LIKE '%+%' GROUP BY CONCEPT_CODE_1  )b on a.CONCEPT_CODE_1 = b.CONCEPT_CODE_1 and regexp_count (CONCEPT_NAME_1, '\+') +1 != cnt
;
select a.* from ingred_to_ingred_FINAL_BY_Lena a
join (
SELECT CONCEPT_CODE_1, count (1) as cnt  FROM ingred_to_ingred_FINAL_BY_Lena  GROUP BY CONCEPT_CODE_1  )b on a.CONCEPT_CODE_1 = b.CONCEPT_CODE_1 and regexp_count (CONCEPT_NAME_1, '\+') +1 != cnt
;
--check Co
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_CODE_1 IN (
SELECT CONCEPT_CODE_1 FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 LIKE '%Co-%' GROUP BY CONCEPT_CODE_1 HAVING COUNT (1)>1)
;
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_CODE_1 IN (
SELECT CONCEPT_CODE_1 FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 not LIKE '%+%' GROUP BY CONCEPT_CODE_1 HAVING COUNT (1)>1)
;
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena
;
select * from concept where concept_name ='Zinc acetate'
;
select * from concept where concept_name in ('Paracetamol',	'Dihydrocodeine') 
;
select * from Ingr_to_Rx where concept_name_1 in ('Paracetamol',	'Dihydrocodeine') 
;
select * from Ingr_to_Rx where CONCEPT_CODE_1 in (
select CONCEPT_CODE_1 from Ingr_to_Rx where precedence != 1)
;
select * from drug_concept_stage where concept_class_id = 'Brand Name'
;
select * from drug_concept_stage where concept_name like  '%Stromectol%'
;
select * from brand_name_map where brand_name  like  '%Vastarel MR%'
;
select * from ds_stage a
join drug_concept_stage b on drug_concept_code = concept_code
--join 
where regexp_like (concept_name, 
'[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm|million units| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres|unit dose|drop)*') 
and amount_value is null and numerator_value is null
;
select DRUG_CONCEPT_CODE from ds_stage a
join drug_concept_stage b on drug_concept_code = concept_code
where regexp_like (concept_name, 
'[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm|million units| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres|unit dose|drop)*') 
and amount_value is null and numerator_value is null
;select * from drug_concept_stage where concept_code ='7995811000001106'
;
select * from branded_to_clinical where concept_code_1 ='11582411000001107'
;--!!! update
create table ds_brand_update as 
select CONCEPT_CODE_1, CONCEPT_NAME_1 from branded_to_clinical 
join drug_concept_stage on CONCEPT_CODE_1 = concept_code and domain_id ='Drug' and invalid_reason is null
join (select drug_concept_code from ds_stage where amount_value is null and numerator_value is null group by drug_concept_code having count (1) = 1) ds on ds.drug_concept_code = concept_code_1
where regexp_like (concept_name_1, 
 '[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol|million units)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*')
and not  
regexp_like  (concept_name_2, 
 '[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol|million units)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*')
;
update ds_stage 
set amount_value = (select regexp_substr ( regexp_substr (concept_name_1, '[[:digit:]\,\.]+(mg|g|microgram(s)*|million unit(s*))'), '[[:digit:]\,\.]+') from ds_brand_update where concept_code_1 = drug_concept_code),
 amount_unit = (select regexp_replace ( regexp_substr (concept_name_1, '[[:digit:]\,\.]+(mg|g|microgram(s)*|million unit(s*))'), '[[:digit:]\,\.]+') from ds_brand_update where concept_code_1 = drug_concept_code)
where exists (select 1 from ds_brand_update where concept_code_1 = drug_concept_code)
and drug_concept_code not in ('16636811000001107', '16636911000001102', '15650711000001103', '15651111000001105' )--Packs and vaccines
;
select * from ds_stage where drug_concept_code  in ('16636811000001107', '16636911000001102');

select * from ds_brand_update;

select * from drug_concept_stage_tmp_0
join ds_stage on CONCEPT_CODE = drug_concept_code
where  regexp_like (concept_name , '[[:digit:]\.]+.*/ml.*[[:digit:]\.]+ml')
;
select * from ds_stage where drug_concept_code = '29768011000001107'
;
select * from pack_content where PACK_CONCEPT_CODE = '16636811000001107'; 16636811000001107, 16636911000001102, 15650711000001103, 15651111000001105 --Packs and vaccines
Follitropin alfa 225units/0.375ml solution for injection pre-filled disposable devices
;
select * from drug_concept_stage_tmp_0
join ds_stage on CONCEPT_CODE = drug_concept_code
where not regexp_like (DRUG_COMP , '[[:digit:]\.]+.*/ml.*[[:digit:]\.]+ml') and regexp_like (DRUG_COMP , '[[:digit:]\.]+.*/ml')
and numerator_value !=  regexp_replace ( regexp_substr (regexp_substr (DRUG_COMP , '[[:digit:]\.\,]+.*/ml'), '[[:digit:]\.\,]+') ,'\,')
;
select * from  ingred_to_ingred_FINAL_BY_Lena where concept_code_2 in (
'39972003' ,'21143111000001109', '350576006'
)
;
select * from  ingred_to_ingred_FINAL_BY_Lena where concept_code_1 in (
'39972003' ,'21143111000001109', '350576006'
)
--how '350576006' got to ds_stage
;
--another algoritm
select * from drug_concept_stage join 
(
SELECT drug_concept_code, count (1) as cnt FROM ds_stage group by drug_concept_code) a  on drug_concept_code = concept_code  and regexp_count (concept_name, ' / ') + 1 > cnt and invalid_reason is null
join ds_stage ds on ds.drug_CONCEPT_CODE = concept_code
;
4701111000001104, 8888711000001107, 
Dextromethorphan 5mg/5ml / Triprolidine 625micrograms/5ml oral solution sugar free
;
select * from ds_all where concept_code = '4701111000001104'
;
select * from ds_stage where drug_concept_code = '4701111000001104'
;
select * from ds_stage where INGREDIENT_CONCEPT_CODE  like 'OMOP%'
;
SELECT * FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_CODE_1 IN (
SELECT CONCEPT_CODE_1 FROM ingred_to_ingred_FINAL_BY_Lena WHERE CONCEPT_NAME_1 LIKE '%+%' GROUP BY CONCEPT_CODE_1 HAVING COUNT (1) = 1)
;
select CONCEPT_NAME_1,'Drug', 'dm+d', 'Ingredient', 'S', concept_code_1, TO_DATE ('19700101', 'yyyymmdd'), TO_DATE ('20991231', 'yyyymmdd'), '' from ingred_to_ingred_FINAL_BY_Lena where concept_code_1 like 'OMOP%'
;
select * from ingred_to_ingred_FINAL_BY_Lena where 
CONCEPT_CODE_1 in (
select CONCEPT_CODE_1 from ingred_to_ingred_FINAL_BY_Lena where CONCEPT_CODE_2 like 'OMOP%')
;
select * from ds_stage where drug_concept_code ='7884011000001107'
;
select * from branded_to_clinical 
join drug_concept_stage on CONCEPT_CODE_1 = concept_code and domain_id ='Drug' and invalid_reason is null
join (select drug_concept_code from ds_stage/* where amount_value is null and numerator_value is null*/ group by drug_concept_code having count (1) = 1) ds on ds.drug_concept_code = concept_code_1
where regexp_like (concept_name_1, 
 '[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol|million units)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*')
and not  
regexp_like  (concept_name_2, 
 '[[:digit:]\,\.]+(mg|%|ml|mcg|hr|hours|unit(s?)|iu|g|microgram(s*)|u|mmol|c|gm|litre|million unit(s?)|nanogram(s)*|x|ppm| Kallikrein inactivator units|kBq|microlitres|MBq|molar|micromol|million units)/*[[:digit:]\,\.]*(g|dose|ml|mg|ampoule|litre|hour(s)*|h|square cm|microlitres)*')
;
select count (*) from drug_concept_stage where concept_name like '%cylinder%'
;
select b.concept_name, c.concept_name, a.* from  ds_stage a -- 20540711000001101, 20521611000001102
join drug_concept_stage b on a.drug_concept_code = b.concept_code
join drug_concept_stage c on c.concept_code = ingredient_concept_code
where drug_concept_code in (
select drug_concept_code from ds_stage a
join drug_concept_stage b on a.drug_concept_code = b.concept_code

where amount_value is null and numerator_value is null
and concept_class_id = 'Branded Drug'
)
;
select * from drug_concept_stage where concept_class_id = 'Brand Name'
and rownum < 1000
;
select * from branded_drug_to_brand_name where BRAND_NAME = 'Aquasol A Parenteral';
select regexp_substr (brand_name,'\s(sterile water inhalation solution|wort herb tincture|sugar free|oral powder|in Orabase|Intravenous|ear drops|rectal|facewash|concentrate for|suspension for injection|ear/eye/nose drops|I.V.|nasal spray)+')
 from branded_drug_to_brand_name
;