class UsersController < ApplicationController

  before_action :require_login
  before_action :admin_user?, only: [:destroy, :new, :create, :permission_change]

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end
 
  # 管理者のみが作成可能にする。
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, success: '登録が完了しました'
    else
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to root_path, success: 'ユーザ情報を更新しました。'
    else
      redirect_back(fallback_location: root_path, danger: "ユーザ情報の更新に失敗しました")
    end
  end
    
  def destroy
    @user = User.find(params[:id])
    if (@user.id != current_user.id) && @user.destroy
      redirect_to root_path, success: 'ユーザを削除しました。'
    else
      redirect_back(fallback_location: root_path, danger: 'ユーザの削除に失敗しました')
    end
  end

  # 対応中
  def permission_change
    @user = User.find(params[:id])
    if (@user.id != current_user.id) && @user.toggle!(:admin)
      redirect_back(fallback_location: root_path, success: "ユーザ権限を変更しました。")
    else
      redirect_back(fallback_location: root_path, danger: "ユーザ権限の変更に失敗しました")
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
