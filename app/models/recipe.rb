class Recipe < ApplicationRecord
end

# == Schema Information
#
# Table name: recipes
#
#  id          :bigint           not null, primary key
#  title       :string
#  author      :string
#  image       :string
#  prep_time   :integer          default(0)
#  cook_time   :integer          default(0)
#  rating      :float            default(0.0)
#  ingredients :string           default([]), is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
