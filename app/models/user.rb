require 'rmagick'
include Magick

class User < ApplicationRecord
  has_one_attached :iris

  def self.authenticate(email, password)
    User.where(email: email, password: password).first
  end

  def self.authenticate_with_iris(iris)
    img1 = Magick::Image.from_blob(iris.read).first
    total = 0
    user = nil
    User.all.each do |u|
      puts u.first_name
      img2 = Magick::Image.from_blob(u.iris.download).first
      #img2 = Magick::Image.read("http://localhost:3000#{Rails.application.routes.url_helpers.rails_blob_path(@user.iris, only_path: true)}").first
      total = compare(img1, img2)
      puts total
      ((user = u) && break) if total < 0.00001
    end
    user
  end

  private

  def self.compare(img1, img2)
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
