class ManagementsController < ApplicationController
  before_action :require_login

  def add_rull_sg
    @management = Management.new
  end

  def add_rull_sg_do
    @management = Management.new(ip_params)
    if @management.valid_ip?(@management.ip)
      @management.add_rule(@management.ip)
      redirect_to images_index_path, success: "ルールの追加に成功しました。"
    else
      redirect_back(fallback_location: root_path, danger: "処理に失敗しました。")
    end
  end

  private
  def ip_params
    params.require(:management).permit(:ip)
  end
end
