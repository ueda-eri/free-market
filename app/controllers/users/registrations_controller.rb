# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  prepend_before_action :check_recaptcha, only: [:create]
  layout 'no_menu'

  # GET /resource/sign_up
  def new
    if session["devise.sns_auth"]
      build_resource(session["devise.sns_auth"]["user"])
      @sns_auth = true
    else
    super
    end
  end

  # POST /resource
  def create
    if session["devise.sns_auth"] 
      ## SNS認証でユーザー登録をしようとしている場合
      ## パスワードが未入力なのでランダムで生成する
      password = Devise.friendly_token[8,12] + "1a"
      ## 生成したパスワードをparamsに入れる
      params[:user][:password] = password
      params[:user][:password_confirmation] = password
    end

    build_resource(sign_up_params)  ## @user = User.new(user_params) をしているイメージ
    ## ↓resource（@user）にsns_credentialを紐付けている
    resource.build_sns_credential(session["devise.sns_auth"]["sns_credential"]) if session["devise.sns_auth"]

    if resource.save  ## @user.save をしているイメージ
      set_flash_message! :notice, :signed_up  ## フラッシュメッセージのセット
      sign_up(resource_name, resource)  ## 新規登録＆ログイン
      respond_with resource, location: after_sign_up_path_for(resource)  ## リダイレクト
    else
      redirect_to new_user_registration_path, alert: @user.errors.full_messages
    end
    
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def confirm_phone
  end

  def select  ##登録方法の選択ページ
    session.delete("devise.sns_auth")
    @auth_text = "で登録する"
  end
  
  def new_address
  end

  def completed
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  private
  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def check_recaptcha
    redirect_to new_user_registration_path unless verify_recaptcha(message: "reCAPTCHAを承認してください")
  end

end
