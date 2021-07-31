class ImagesController < ApplicationController

  before_action :require_login
  
  # サーバから全てのイメージ情報を取得する。
  def index
    @images = Image.all
  end

  # コンテナ作成画面に移動する。
  def new
    @image = Image.new(image_params)
    if @image.valid?
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
    end
  end

  # コンテナを作成する。
  def create
    @image = Image.new(create_container_params)
    if @image.valid? && @image.create_container(@image.repository, @image.tag, @image.port_host, @image.port_container, @image.container_name)
      redirect_to containers_index_path, success: "イメージを作成しました。"
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
    end
  end

    # イメージを複製画面へ移動する。
    def change_repository_tag
      @image = Image.new(image_params)
      if @image.valid?
      else
        redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
      end
    end

    # レポジトリ/タグ名を変更してイメージを複製する。
    def change_repository_tag_do
      @image = Image.new(change_repository_tag_params)
      if @image.valid? && @image.change_repository_tag_name(@image.id, @image.repository, @image.tag)
        redirect_to images_index_path, success: "イメージの複製に作成しました。"
      else
        redirect_back(fallback_location: root_path, danger: "イメージの複製に失敗しました。")
      end
    end

  # イメージを削除する。
  def delete
    @image = Image.new(image_params)
    if @image.valid? && @image.delete_image(@image.id, @image.repository, @image.tag, @image.image_size, @image.created)
      flash.now[:success] = "イメージの削除に成功しました。"
    else
      redirect_back(fallback_location: root_path, danger: "イメージの削除に失敗しました。")
    end
  end

  # 不要（レポジトリ、タグに<none>がついている）イメージを削除する。
  def delete_2
    @image = Image.new()
    @image.delete_unused_image
    redirect_back(fallback_location: root_path, success: "削除可能なイメージを削除しました。")
  end

  private
  def image_params
    params.permit(:id, :repository, :tag, :image_size, :created)
  end

  def change_repository_tag_params
    params.require(:image).permit(:id, :repository, :tag)
  end

  def create_container_params
    params.require(:image).permit(:repository, :tag, :port_host , :port_container, :container_name)
  end
end
