# frozen_string_literal: true

class DashboardController < ApplicationController
  # sales summaries, cards, stats
  def onboarding
    Sale.where(status: 'pending').group(:store).count
    @partners = Partner.all.count
    @stores = Store.all.count
    @users = User.all.count
    @internal_users = User.where('role::varchar like ?', '%ipalater%').count
    @store_users = User.where('role::varchar not like ?', '%ipalater%').count
    render json: { partners: @partners, stores: @stores, internal_users: @internal_users, store_users: @store_users, all_users: @users }, status: :ok
  end

  def sales
    @pending_count = Sale.where(status: 'pending').count
    @pending_value = Sale.where(status: 'pending').sum('approved_amount::decimal')
    @collected_count = Sale.where(status: 'collected').count
    @collected_value = Sale.where(status: 'collected').sum('approved_amount::decimal')

    @cancelled_count = CancelledSale.count
    @cancelled_value = CancelledSale.sum('approved_amount::decimal')

    @pending = Sale.where(status: 'pending').order(created_at: :desc).limit(10)
    @collected = Collection.where(status: 'collected').order(created_at: :desc).limit(10)
    @cancelled = Sale.where(status: 'cancelled').order(created_at: :desc).limit(10)
    render json: { pending_count: @pending_count, pending_value: @pending_value, collected_count: @collected_count, collected_value: @collected_value, cancelled_count: @cancelled_count, cancelled_value: @cancelled_value, pending: @pending, collected: @collected, cancelled: @cancelled }, status: :ok
  end

  def partners_chart
    partner_monthly_trend_query =  "SELECT d.mmyyyy,
           (select count(distinct (id, created_at)) from partners
           where
           TO_CHAR(date_trunc('Mon',partners.created_at),'YYYY-MM') = d.mmyyyy
           )partner_count FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @partners_monthly_number = Partner.find_by_sql(partner_monthly_trend_query)
    render json: { partner_trend: @partners_monthly_number }, status: :ok
  end

  def stores_chart
    store_monthly_trend_query = "SELECT d.mmyyyy,
           (select count(distinct (id, created_at)) from stores
           where
           TO_CHAR(date_trunc('Mon',stores.created_at),'YYYY-MM') = d.mmyyyy
           )store_count FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @stores_monthly_number = Store.find_by_sql(store_monthly_trend_query)
    render json: { store_trend: @stores_monthly_number }, status: :ok
  end

  def sales_number_chart
    apps_monthly_trend_query =  "SELECT d.mmyyyy,
           (select count(distinct (id, created_at)) from sales
           where
           TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
           )all_stats,(select count(*) from sales where status ='pending' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
    )pending,(select count(*) from sales where status ='collected' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
    )collected FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @sales_monthly_number = Sale.find_by_sql(apps_monthly_trend_query)
    render json: { sales_numbers: @sales_monthly_number }, status: :ok
  end

  def sales_value_chart
    apps_monthly_trend_query = "SELECT d.mmyyyy,
           (select COALESCE(sum(approved_amount::decimal),0.0) from sales
           where
           TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
           )all_stats,(select COALESCE(sum(approved_amount::decimal),0.0) from sales where status ='pending' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
    )pending,(select COALESCE(sum(approved_amount::decimal),0.0)  from sales where status ='collected' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy
    )collected FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @sales_monthly_value = Sale.find_by_sql(apps_monthly_trend_query)
    render json: { sales_value: @sales_monthly_value }, status: :ok
  end

  def sales_number_chart_by_store
    store = Store.find_by(id: current_user.store_id)
    source_id = store.source_id
    apps_monthly_trend_query = "SELECT d.mmyyyy,
           (select count(distinct (id, created_at)) from sales
           where
           TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
           )all_stats,(select count(*) from sales where status ='pending' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
    )pending,(select count(*) from sales where status ='collected' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
    )collected FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @sales_monthly_number = Sale.find_by_sql(apps_monthly_trend_query)
    render json: { sales_numbers: @sales_monthly_number }, status: :ok
  end

  def sales_value_chart_by_store
    store = Store.find_by(id: current_user.store_id)
    source_id = store.source_id
    apps_monthly_trend_query = "SELECT d.mmyyyy,
           (select COALESCE(sum(approved_amount::decimal),0.0) from sales
           where
           TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
           )all_stats,(select COALESCE(sum(approved_amount::decimal),0.0) from sales where status ='pending' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
    )pending,(select COALESCE(sum(approved_amount::decimal),0.0)  from sales where status ='collected' and TO_CHAR(date_trunc('Mon',sales.created_at),'YYYY-MM') = d.mmyyyy AND store = #{source_id}
    )collected FROM
    (select  TO_CHAR((current_date - interval '1 month' * a),'YYYY-MM') AS mmyyyy FROM generate_series(0,12,1) AS s(a)) d"
    @sales_monthly_value = Sale.find_by_sql(apps_monthly_trend_query)
    render json: { sales_value: @sales_monthly_value }, status: :ok
  end

  def salesbystore
    # store = Store.find_by(source_id: 'jkiarie')
    store = Store.find_by(id: current_user.store_id)
    source_id = store.source_id
    @pending_count = Sale.where(status: 'pending', store: source_id).count
    @pending_value = Sale.where(status: 'pending', store: source_id).sum('approved_amount::decimal')
    @collected_count = Sale.where(status: 'collected', store: source_id).count
    @collected_value = Sale.where(status: 'collected', store: source_id).sum('approved_amount::decimal')

    @pending = Sale.where(status: 'pending', store: source_id).order(created_at: :desc).limit(10)
    @collected = Collection.where(status: 'collected', store: source_id).order(created_at: :desc).limit(10)
    render json: { pending_count: @pending_count, pending_value: @pending_value, collected_count: @collected_count, collected_value: @collected_value, pending: @pending, collected: @collected }, status: :ok
  end
end
