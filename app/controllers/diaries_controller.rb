class DiariesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  before_action :set_diary, only: [ :show, :edit, :update, :destroy ]

  def index
    @diaries = current_user.diaries

    # 並び順
    @diaries = case params[:sort]
    when "date_desc"
      @diaries.order(date: :desc)
    when "date_asc"
      @diaries.order(date: :asc)
    else
      @diaries.order(created_at: :desc)
    end
  end

  def new
    @diary = current_user.diaries.new
  end

  def create
    @diary = current_user.diaries.new(diary_params)

    respond_to do |format|
      if @diary.save
        format.html { redirect_to diaries_path, notice: "日記を作成しました" }
        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.prepend("diaries-list", partial: "diaries/diary_row", locals: { diary: @diary }),
            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "日記を作成しました" } }),
            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diaries/form_modal",
            locals: { diary: @diary }
          )
        end
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "diaries/form_modal",
          locals: { diary: @diary }
        )
      end
    end
  end

  def update
    respond_to do |format|
      if @diary.update(diary_params)
        format.html { redirect_to diaries_path, notice: "日記を更新しました" }
        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("diary_#{@diary.id}", partial: "diaries/diary_row", locals: { diary: @diary }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "日記を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diaries/form_modal",
            locals: { diary: @diary }
          )
        end
      end
    end
  end

  def destroy
    @diary.destroy

    respond_to do |format|
      format.html { redirect_to diaries_path, notice: "日記を削除しました" }
      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("diary_#{@diary.id}"),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "日記を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def diary_params
    params.require(:diary).permit(:title, :content, :date, images: [], videos: [])
  end
end
