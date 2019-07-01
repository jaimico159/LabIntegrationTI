require 'rmagick'
include Magick

class UsersController < ApplicationController
  before_action :authenticate_user
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_user_by_iris
  end

  def match_by_iris
    result = params[:iris]
    img1 = Magick::Image.from_blob(result.read).first
    total = 0
    @user = nil
    User.all.each do |u|
      img2 = Magick::Image.from_blob(u.iris.download).first
      #img2 = Magick::Image.read("http://localhost:3000#{Rails.application.routes.url_helpers.rails_blob_path(@user.iris, only_path: true)}").first
      total = compare(img1, img2)
      puts total
      ((@user = u) && break) if total < 0.00001 
    end

    respond_to do |format|
      if @user.present?
        format.html { redirect_to @user, notice: 'User was successfully found.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { redirect_to :users_search, notice: 'User not found.' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_user_by_dni
  end

  def match_by_dni
    dni = params[:dni]
    @user = User.find_by(dni: dni)
    respond_to do |format|
      if @user.present?
        format.html { redirect_to @user, notice: 'User was successfully found.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { redirect_to :users_search, notice: 'User not found.' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :dni, :iris, :password)
  end

  def compare(img1, img2)
    # img1 = Magick::Image.read(iris_new).first

    # img2 = Magick::Image.from_blob(open(iris_stored).read).first

    res = img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, AllChannels)
    diff = res[1]
    w, h = img1.columns, img1.rows
    pixelcount = w * h
    perc = (diff * 100)
    percentage = perc/pixelcount

    return percentage
  end
end
