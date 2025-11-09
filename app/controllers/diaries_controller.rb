class DiariesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!
  before_action :ensure_child_selected

def index
  @diaries = current_user.diaries

  # 日付で絞り込み
  if params[:date].present?
    date = Date.parse(params[:date]) rescue nil
    if date
      @diaries = @diaries.where(date: date.beginning_of_day..date.end_of_day)
    end
  end

  # 新しい順に並べる（必要なら変更可）
  @diaries = @diaries.order(date: :desc, id: :desc)
end

  def show
    @diary = current_user.diaries.find(params[:id])
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
            turbo_stream.replace("diaries-container", partial: "diaries/index", locals: { diaries: current_user.diaries.order(date: :desc) }),
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
    @diary = current_user.diaries.find(params[:id])

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
  @diary = current_user.diaries.find(params[:id])

  # 1. 削除対象のメディアを purge
  if params[:diary][:remove_media_ids].present?
    params[:diary][:remove_media_ids].each do |file_id|
      media = @diary.media.find(file_id)
      media.purge
    end
  end

  respond_to do |format|
    # 2. 既存の添付は保持して、他の属性だけ更新
    if @diary.update(diary_params.except(:media))
      # 3. 新しいファイルがあれば追加でattach（上書きではなく追加）
      if params[:diary][:media].present?
        params[:diary][:media].each do |new_file|
          @diary.media.attach(new_file)
        end
      end

      format.html { redirect_to diaries_path, notice: "日記を更新しました" }

      # 4. 非同期（Turbo Stream）対応
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("diaries-container", partial: "diaries/index", locals: { diaries: current_user.diaries.order(date: :desc) }),
          turbo_stream.replace("diary-#{@diary.id}", partial: "diaries/show", locals: { diary: @diary }),
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
    @diary = current_user.diaries.find(params[:id])
    @diary.destroy

    respond_to do |format|
      format.html { redirect_to diaries_path, notice: "日記を削除しました" }
      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("diaries-container", partial: "diaries/index", locals: { diaries: current_user.diaries.order(date: :desc) }),
          turbo_stream.replace("diary-#{@diary.id}", partial: "diaries/show", locals: { diary: @diary }),
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

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def diary_params
    params.require(:diary).permit(:title, :content, :date, media: [])
  end
end
