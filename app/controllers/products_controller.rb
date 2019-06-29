require 'rqrcode'
require 'zxing'

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @qrcode = RQRCode::QRCode.new(@product.code.to_s)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    qrcode = RQRCode::QRCode.new(@product.code.to_s)
    png_code = qrcode.as_png
    filew = File.open("#{@product.name}.png", 'wb')
    png_code.save(filew)
    filer = File.open(filew, 'r')
    @product.qrcode.attach(io: filer, filename: "#{@product.name}.png")

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_product
  end

  def get_from_image
    result = ZXing.decode params[:code]
    @product = Product.where(code: result).first
    respond_to do |format|
      if @product.present?
        format.html { redirect_to @product, notice: 'Product was successfully found.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { redirect_to :products_search_product, notice: 'Product not found.' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :code)
    end
end
