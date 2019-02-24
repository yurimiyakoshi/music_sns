class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.references :user
      t.string :user_name
      t.text :body
      t.text :img
      t.text :sample
      t.text :title
      t.text :album
      t.string :artist
    end
  end
end
