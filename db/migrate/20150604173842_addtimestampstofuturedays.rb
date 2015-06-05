
class Addtimestampstofuturedays < ActiveRecord::Migration
  def change
    add_column(:futuredays, :created_at, :datetime)
    add_column(:futuredays, :updated_at, :datetime)
  end
end