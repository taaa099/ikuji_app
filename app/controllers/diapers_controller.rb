class DiapersController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @diapers = current_child.diapers

    # 並び順
    @diapers = case params[:sort]
    when "date_desc"
      @diapers.order(changed_at: :desc)
    when "date_asc"
      @diapers.order(changed_at: :asc)
    else
      @diapers.order(changed_at: :desc)
    end

    # ==== 全日程取得 ====
    if @diapers.any?
      diaper_start_date = @diapers.minimum(:changed_at).in_time_zone("Tokyo").to_date
      diaper_end_date   = [ @diapers.maximum(:changed_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @diaper_all_dates = (diaper_start_date..diaper_end_date).to_a.reverse # 新しい日付が上
    else
      @diaper_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_diapers = @diapers.group_by { |f| f.changed_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    @diaper = current_child.diapers.new(changed_at: Time.current)
  end

  def create
    @diaper = current_child.diapers.new(diaper_params.merge(user: current_user))

    respond_to do |format|
      if @diaper.save
        # changed_at を基準に selected_date をセット
        @selected_date = @diaper.changed_at.to_date

        session.delete(:diaper_changed_at)
        format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("diapers-date-#{@diaper.changed_at.strftime('%Y%m%d')}", partial: "diapers/date_section", locals: { date: @diaper.changed_at.to_date, diapers_by_date: current_child.diapers.where(changed_at: @diaper.changed_at.all_day).order(changed_at: :desc) }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "おむつ記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diapers/form_modal",
            locals: { diaper: @diaper }
          )
        end
      end
    end
  end

  def edit
    @diaper = current_child.diapers.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "diapers/form_modal",
          locals: { diaper: @diaper }
        )
      end
    end
  end

  def update
    @diaper = current_child.diapers.find(params[:id])
    @diaper.assign_attributes(diaper_params)

    respond_to do |format|
      if @diaper.save
        # changed_at を基準に selected_date をセット
        @selected_date = @diaper.changed_at.to_date

        format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("diapers-date-#{@diaper.changed_at.strftime('%Y%m%d')}", partial: "diapers/date_section", locals: { date: @diaper.changed_at.to_date, diapers_by_date: current_child.diapers.where(changed_at: @diaper.changed_at.all_day).order(changed_at: :desc) }),
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "おむつ記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diapers/form_modal",
            locals: { diaper: @diaper }
          )
        end
      end
    end
  end

  def destroy
    @diaper = current_child.diapers.find(params[:id])
    @diaper.destroy
    # changed_at を基準に selected_date をセット
    @selected_date = @diaper.changed_at.to_date

    respond_to do |format|
      format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("diapers-date-#{@diaper.changed_at.strftime('%Y%m%d')}", partial: "diapers/date_section", locals: { date: @diaper.changed_at.to_date, diapers_by_date: current_child.diapers.where(changed_at: @diaper.changed_at.all_day).order(changed_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "おむつ記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # 許可されたパラメータに変換済みのpee/poopを追加
  def diaper_params
    params.require(:diaper).permit(:changed_at, :memo).merge(
      pee: to_boolean(params[:diaper][:pee]),
      poop: to_boolean(params[:diaper][:poop])
    )
  end

  # 文字列をbooleanに変換
  def to_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
