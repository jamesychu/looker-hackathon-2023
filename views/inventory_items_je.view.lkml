view: inventory_items_je {
  derived_table: {
    sql:
      SELECT
        CONCAT('credit-02-',id) AS external_id
        , 'Manufacturing' AS department
        , '02 Finished Good Inventory' AS account_name
        , 0 AS debit
        , cost AS credit
        , EXTRACT(date FROM created_at) AS entry_date
      FROM demo.inventory_items

      UNION ALL

      SELECT
        CONCAT('debit-01-',id) AS external_id
        ,'Manufacturing' AS department
        , '01 Work in Progress Inventory' AS account_name
        , cost AS debit
        , 0 AS credit
        , EXTRACT(date FROM created_at) AS entry_date
      FROM demo.inventory_items

      UNION ALL

      SELECT
        CONCAT('debit-02-',id) AS external_id
        ,'Manufacturing' AS department
        , '02 Finished Good Inventory' AS account_name
        , cost AS debit
        , 0 AS credit
        , CAST(LEFT(sold_at,10) AS date) AS entry_date
      FROM demo.inventory_items
      WHERE sold_at IS NOT NULL AND sold_at != 'NULL'

      UNION ALL

      SELECT
        CONCAT('credit-03-',id) AS external_id
        ,'Manufacturing' AS department
        , '03 Cost of Goods Sold' AS account_name
        , 0 AS debit
        , cost AS credit
        , CAST(LEFT(sold_at,10) AS date) AS entry_date
      FROM demo.inventory_items
      WHERE sold_at IS NOT NULL AND sold_at != 'NULL';;
  }
  drill_fields: [external_id]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: external_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.external_id ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: credit {
    type: number
    sql: ${TABLE}.credit ;;
  }

  dimension: debit {
    type: number
    sql: ${TABLE}.debit ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension_group: entry {
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.entry_date ;;
  }

  measure: total_credit {
    type: sum
    sql: ${credit} ;;  }

  measure: total_debit {
    type: sum
    sql: ${debit} ;;  }

  measure: count {
    type: count
    drill_fields: [external_id]}
}
