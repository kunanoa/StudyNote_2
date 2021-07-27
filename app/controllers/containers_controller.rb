class ContainersController < ApplicationController

  before_action :require_login
  
  # サーバから全てのコンテナ情報を取得する。
  def index
    containers = Container.new()
    @all_container = containers.all_container_info
  end

  # イメージ作成のためのフォームページへ遷移。
  def new
    @container = Container.new(id_params)
    if @container.valid? && @container.container_info(@container.id)
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
    end
  end

  # 指定した情報からイメージを作成する。
  def create
    @container = Container.new(create_image_params)
    if @container.valid? && @container.create_image(@container.id, @container.repository, @container.tag)
      redirect_to images_index_path, success: "イメージを作成しました。"
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
    end
  end

  # 起動中であれば停止、停止中であれば起動させる。
  def run
    @container = Container.new(id_params.merge(status_params))
    if @container.valid? && @container.start_stop_container(@container.id, @container.status)
        flash.now[:success] = "処理に成功しました。現在のコンテナのステータスは「#{@container.status}」です。"
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。現在のコンテナのステータスは「#{@container.status}」です。")
    end
  end

  # コンテナを削除する。
  # status_paramsはバリデーションを通すために渡している。
  def delete
    @container = Container.new(id_params)
    if @container.valid? && @container.delete_container(@container.id)
      flash.now[:success] = "コンテナの削除に成功しました。"
    else
      redirect_back(fallback_location: root_path, danger: "コンテナの削除に失敗しました。")
    end
  end

  private
  def id_params
    params.permit(:id)
  end

  def status_params
    params.permit(:status)
  end

  def create_image_params
    params.require(:container).permit(:id, :repository, :tag)
  end
end
