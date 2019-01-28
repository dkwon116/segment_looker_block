# - explore: mapped_events
view: mapped_events {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from ${page_aliases_mapping.SQL_TABLE_NAME} ;;
    sql: select *
        ,timestamp_diff(timestamp, lag(timestamp) over(partition by looker_visitor_id order by timestamp), minute) as idle_time_minutes
      from (
        select CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          ,t.event as event
          ,t.received_at as received
          ,NULL as referrer
          ,NULL as campaign_source
          ,NULL as campaign_medium
          ,NULL as campaign_name
          ,t.context_user_agent as user_agent
          ,t.context_page_url as page_url
          ,t.context_ip as ip
          ,'tracks' as event_source
        from javascript.tracks_view as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
        on a2v.alias = coalesce(t.user_id, t.anonymous_id)

        union all

        select CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-p') as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          ,t.name as event
          ,t.received_at as received
          ,t.referrer as referrer
          ,t.context_campaign_source as campaign_source
          ,t.context_campaign_medium as campaign_medium
          ,t.context_campaign_name as campaign_name
          ,t.context_user_agent as user_agent
          ,t.context_page_url as page_url
          ,t.context_ip as ip
          ,'pages' as event_source
        from javascript.pages_view as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
          on a2v.alias = coalesce(t.user_id, t.anonymous_id)
      ) as e
      WHERE (e.ip NOT IN ('210.123.124.177', '222.106.98.162', '121.134.191.141', '63.118.26.234', '14.39.183.130', '125.140.120.54', '98.113.6.12')
      AND e.page_url LIKE '%catchfashion%'
      AND e.looker_visitor_id NOT IN ('fd2a0deb-3458-49cb-9f77-2d19252c64ee', '0e22f8f9-815c-4baf-8b2c-cba9351e7026', '7c22886c-4885-48b3-b9b7-e98c7772b4d9', '00408cdc-5cdf-460b-b710-9dc4201c1d77', '055e6b4d-8707-4df4-b1ba-6c9d6fe6fb33', '0c12d7f1-3e85-408c-af55-ddf77c08a770', '0ec3eac8-e1b9-462d-957c-045f1d63840e', '12deb770-e643-4203-ae48-b746c06af482', '172af593-6e7e-4c90-8e75-f0c227c7c2df', '1913e64f-a801-4ada-9cd2-321aea5ab468', '2753dd82-f0ed-4fc7-91f0-6dac604c0de5', '319e9c7f-b08b-4bc9-bad3-c917522a5cdd', '34a7da5f-8420-4f05-92a1-8eb2a47bd838', '3c7bc45c-f911-4096-bb95-761aec2f085f', '44c6b042-167f-48d4-a98f-54f541ea22b8', '56163ec5-0ac3-4884-b558-3006fceccca0', '6337b0d5-26a8-427c-9f69-5d2ef3d2f5f2', '6ec33976-e27c-436e-9707-a0e4452f521b', '7190b9b0-e4cd-4344-b602-50415e3a04d9', '791a7e5d-964f-4335-b823-e9a7182682af', '7f776548-eb84-4b92-8ef1-bcc01b8954de', '80d773aa-a1d9-42b5-ab55-4abf69486142', '82d762f0-99bc-4b37-9b17-5e31c87e1bd1', '9bb381b8-85d2-436a-b4e8-533e05b9795b', 'b207dc8c-7294-4c4f-bbac-dd87cdd3ba00', 'b527029d-e27b-4f79-8ffa-2de78076ebda', 'b8818bf1-8a10-4d4f-93d2-fc50f8cfe56e', 'ba461b8c-8a64-444d-b585-487ae92058d3', 'bc616514-6c9e-4704-ac37-dc1cff59d82c', 'c06732bf-bfde-4879-9cdd-31ffe059bea5', 'c7eae086-64e0-4cde-a675-27ae360bfc02', 'd843d546-abd4-4cf8-90bc-ca984ffd5108', 'd8540ddb-4a5e-4225-91d8-8fe573fa2e50', 'd93f7adc-c1a1-4b4a-9808-8c4086eee601', 'e4ea6bff-3902-45d4-9a8b-36f08f8614bb', 'e50fd5e8-ad30-43a2-adda-72c2af626340', 'ed158969-7331-439e-bea7-cf517070cfc4', 'f0fb0462-6c79-4137-bcd5-c7391f3ea507', 'f159f85e-6672-4f56-90b4-334d3409b35b', 'fab03aa4-1035-4f24-8eda-9ea521574f37', 'fd0e8870-bf3a-40c6-b893-5d44eae8da9e', '97deba15-1145-4629-b8d3-e9bab669c695'))
#       rogue data event users
      AND e.looker_visitor_id NOT IN ('e5abe9ab-4f28-42e7-ae72-0f45f73950ee', 'ef60d362-5f7a-4200-90a6-cc5516b1ade8', '15636cf6-4634-4415-a3c3-acac57f747bf','1223bcb4-5ada-49a1-b3b3-526a99290311', '53e3b207-224e-4ae7-b2ad-60c38e42bc60', '15a4068b-b6da-4854-96de-fd7cc5b39a6a', '6a8cdb2d-915a-4959-97b9-f5f06b0a4b6a', 'ffc74104-e2f0-4716-92cf-44bb17cfda19', '319c3ef4-ebc1-4de5-a8d3-a73f4fb3b663')
       ;;
  }

  dimension: event_id {
    sql: ${TABLE}.event_id ;;
  }

  dimension: looker_visitor_id {
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: anonymous_id {
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension_group: received {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.received ;;
  }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: referrer {
    sql: ${TABLE}.referrer ;;
  }

  dimension: event_source {
    sql: ${TABLE}.event_source ;;
  }

  dimension: user_agent {
    sql: ${TABLE}.user_agent ;;
  }

  dimension: ip {
    sql: ${TABLE}.ip ;;
  }

  dimension: idle_time_minutes {
    type: number
    sql: ${TABLE}.idle_time_minutes ;;
  }

  set: detail {
    fields: [
      event_id,
      looker_visitor_id,
      referrer,
      event_source,
      idle_time_minutes
    ]
  }
}
