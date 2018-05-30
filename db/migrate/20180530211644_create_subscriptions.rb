class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.text :body

      t.timestamps
    end
  end
end
