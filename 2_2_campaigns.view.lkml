view: campaigns {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:

    CREATE TEMP FUNCTION utmparser_campaign(tags ARRAY<STRING>)
    RETURNS STRING
    LANGUAGE js AS """
      var prms={'S1AWA':'Stage','S2CON':'Stage','S3ACT':'Stage','S4ABD':'Stage','S5RET':'Stage','S6RCM':'Stage','AUTO':'Type','ADHOC':'Type','GDN':'Network','GSN':'Network','MSG':'Network','ADN':'Network','IGN':'Network','FBP':'Network','FBN':'Network','YTB':'Network','NVB':'Network','NVR':'Network','EML':'Network','SMS':'Network','KPF':'Network','KKT':'Network','DDN':'Network','AFF':'Network','NVC':'Network','NVP':'Network','MDM':'Network','DAM':'Network','NVK':'Network','ALL':'Device','MOB':'Device','DES':'Device','IOS':'Device','AND':'Device','EGM':'Objective','DPA':'Objective','LED':'Objective','TRF':'Objective','MAI':'Objective','CNV':'Objective','VVW':'Objective','CORE':'Niche','SPEC':'Niche','BRND':'Niche','COMP':'Niche','LTRL':'Niche','GNRC':'Niche'};
      var result={'Network':'','Type':'','Stage':'','Device':'','Objective':'','Niche':'','Name':''};
      var unclassified_string='';

      for(a in tags){
        if(tags[a] in prms){
          result[prms[tags[a]]]=tags[a];
        }
        else{
            unclassified_string=unclassified_string+tags[a]+'-';
        }
      };

      result['Name']=unclassified_string.split('-')[0];
      return result['Network']+'-'+result['Type']+'-'+result['Stage']+'-'+result['Device']+'-'+result['Objective']+'-'+result['Niche']+'-'+result['Name'];
    """;

    CREATE TEMP FUNCTION utmparser_content(tags ARRAY<STRING>)
    RETURNS STRING
    LANGUAGE js AS """
      var prms={'KWD':'Targeting','EVT':'Targeting','CAD':'Targeting','LKL':'Targeting','INT':'Targeting','BHV':'Targeting','DMG':'Targeting','GEO':'Targeting','AVT':'Targeting','SIM':'Targeting','PLC':'Targeting','INM':'Targeting','AFF':'Targeting','TOP':'Targeting','GEO':'Targeting'};
      var result={'Targeting':'','GroupName':'','GenderAge':'','SubGroup':'','Date':''};
      var unclassified_string='';

      for(a in tags){
        if(tags[a] in prms){
          result[prms[tags[a]]]=tags[a];
        }
        else{
            unclassified_string=unclassified_string+tags[a]+'-';
        }
      };
      unclassified_string=unclassified_string.substring(0,unclassified_string.length-1);
      result['GroupName']=unclassified_string.split('-')[0];
      result['GenderAge']=unclassified_string.split('-')[1];
      result['SubGroup']=unclassified_string.split('-')[2];
      result['Date']=unclassified_string.split('-')[3];
      for(p in result){
        if(result[p]==undefined){
          result[p]='';
        }
      };
      return result['Targeting']+'-'+result['GroupName']+'-'+result['GenderAge']+'-'+result['SubGroup']+'-'+result['Date']+'-'+unclassified_string;
    """;

    CREATE TEMP FUNCTION utmparser_term(tags ARRAY<STRING>)
    RETURNS STRING
    LANGUAGE js AS """
      var prms={'TXT':'Format','LED':'Format','CAN':'Format','COL':'Format','CAR':'Format','LNK':'Format','DIS':'Format','BPR':'Format','OSS':'Format','ISN':'Format','ISS':'Format','HTM':'Format','RSP':'Format','BAN':'Format','BTN':'Format','PST':'Format','EXT':'Format','BRD':'Format','NTV':'Format','TXT':'Creative','SLD':'Creative','VID':'Creative','IMG':'Creative','STA':'Data','DYN':'Data','PLA':'Data'};
      var result={'DateBatch':'','ContentName':'','Format':'','Creative':'','Data':'','Variation':''};
      var unclassified_string='';

      for(a in tags){
        if(tags[a] in prms){
          result[prms[tags[a]]]=tags[a];
        }
        else{
            unclassified_string=unclassified_string+tags[a]+'-';
        }
      };
      unclassified_string=unclassified_string.substring(0,unclassified_string.length-1);
      result['DateBatch']=unclassified_string.split('-')[0];
      result['ContentName']=unclassified_string.split('-')[1];
      for(p in result){
        if(result[p]==undefined){
          result[p]='';
        }
      };
      return result['DateBatch']+'-'+result['ContentName']+'-'+result['Format']+'-'+result['Creative']+'-'+result['Data']+'-'+result['Variation']+'-'+unclassified_string;
    """;

      with c as(
        select
          upper(s.first_utm) as utm
          ,upper(s.first_source) as source
          ,upper(s.first_medium) as medium
          ,upper(s.first_campaign) as campaign
          ,upper(s.first_content) as content
          ,upper(s.first_term) as term
          ,timestamp(safe_cast(concat('20',substr(s.first_term,1,2),'-',substr(s.first_term,3,2),'-',substr(s.first_term,5,2),' 00:00:00') as datetime)) as start_timestamp
          ,timestamp_add(timestamp(safe_cast(concat('20',substr(s.first_term,1,2),'-',substr(s.first_term,3,2),'-',substr(s.first_term,5,2),' 00:00:00') as datetime)), interval 168 hour) as end_timestamp
          ,min(s.session_start_at) as first_session_timestamp
        from ${sessions.SQL_TABLE_NAME} s
        where s.first_utm is not null
        group by 1,2,3,4,5,6,7,8
      )
      select
        c.*
        ,coalesce(email.marketing_campaign_id) as marketing_campaign_id
        ,coalesce(email.marketing_campaign_name) as marketing_campaign_name
        ,u.* except(utm)
      from c
      left join(
        select
          t.utm
          ,split(t.campaign_p,'-')[safe_offset(0)] as campaign_Network
          ,split(t.campaign_p,'-')[safe_offset(1)] as campaign_Type
          ,split(t.campaign_p,'-')[safe_offset(2)] as campaign_Stage
          ,split(t.campaign_p,'-')[safe_offset(3)] as campaign_Device
          ,split(t.campaign_p,'-')[safe_offset(4)] as campaign_Objective
          ,split(t.campaign_p,'-')[safe_offset(5)] as campaign_Niche
          ,split(t.campaign_p,'-')[safe_offset(6)] as campaign_Name
          ,split(t.content_p,'-')[safe_offset(0)] as content_Targeting
          ,split(t.content_p,'-')[safe_offset(1)] as content_GroupName
          ,split(t.content_p,'-')[safe_offset(2)] as content_GenderAge
          ,split(t.content_p,'-')[safe_offset(3)] as content_SubGroup
          ,split(t.term_p,'-')[safe_offset(0)] as term_DateBatch
          ,split(t.term_p,'-')[safe_offset(1)] as term_ContentName
          ,split(t.term_p,'-')[safe_offset(2)] as term_Format
          ,split(t.term_p,'-')[safe_offset(3)] as term_Creative
          ,split(t.term_p,'-')[safe_offset(4)] as term_Data
        from(
          select
            c.utm
            ,utmparser_campaign(split(replace(c.campaign,' ',''),'-')) as campaign_p
            ,utmparser_content(split(replace(c.content,' ',''),'-')) as content_p
            ,utmparser_term(split(replace(c.term,' ',''),'-')) as term_p
          from c
        ) t
      ) u on u.utm=c.utm
      left join ${email_campaigns.SQL_TABLE_NAME} email on upper(email.utm)=upper(c.utm)
 ;;
  }

  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
    primary_key: yes
    group_label: "UTM"
  }
  dimension: source {
    type:  string
    sql: ${TABLE}.source ;;
    group_label: "UTM"
  }
  dimension: medium {
    type:  string
    sql: ${TABLE}.medium ;;
    group_label: "UTM"
  }
  dimension: campaign {
    type:  string
    sql: ${TABLE}.campaign ;;
    group_label: "UTM"
  }
  dimension: content {
    type:  string
    sql: ${TABLE}.content ;;
    group_label: "UTM"
  }
  dimension: term {
    type:  string
    sql: ${TABLE}.term ;;
    group_label: "UTM"
  }
  dimension: marketing_campaign_id {
    type:  string
    sql: ${TABLE}.marketing_campaign_id ;;
  }
  dimension: marketing_campaign_name {
    type:  string
    sql: ${TABLE}.marketing_campaign_name ;;
  }
  dimension_group: start {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.start_timestamp ;;
  }

  dimension_group: first_timestamp {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.first_timestamp ;;
  }

}
