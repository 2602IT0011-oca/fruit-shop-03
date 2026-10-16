class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
    # Deviseのコントローラ実行時にストロングパラメータを設定
  before_action :configure_permitted_parameters, if: :devise_controller?
  # 商品詳細ページ（products#show）を見た場合のみ、セッションに商品IDを記録する
  before_action :store_recent_product

  include PriceCalculations

  protected

  # サインアップ時に name と admin_flg を許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :admin_flg])
  end
  private
  # 最近見た商品をセッションに保存するメソッド
  def store_recent_product
    # 今見ているページが products コントローラーの show アクション（＝商品詳細ページ）のときだけ処理
    if params[:controller] == 'products' && params[:action] == 'show'
      product_id = params[:id].to_i  # パラメータから商品IDを取得（文字列→整数に変換）
      session[:recent_product_ids] ||= []  # セッションに recent_product_ids がなければ空配列で初期化
      session[:recent_product_ids].delete(product_id)  # 重複を防ぐために、すでにあるIDを削除
      session[:recent_product_ids].unshift(product_id) # 商品IDを配列の先頭に追加（新しい順に並べる）
      session[:recent_product_ids] = session[:recent_product_ids].take(5)  # 配列の先頭5件だけを残す（＝最大5件まで表示）
    end
  end
end
