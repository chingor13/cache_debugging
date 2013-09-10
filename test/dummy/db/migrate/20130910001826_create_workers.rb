class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :name
      t.string :detail_type
      t.integer :detail_id
      t.timestamps
    end

    create_table :plumbers do |t|
      t.boolean :has_wrench
      t.timestamps
    end

    create_table :gardeners do |t|
      t.boolean :has_shovel
      t.timestamps
    end

    create_table :electricians do |t|
      t.boolean :certified
      t.timestamps
    end

    create_table :contracts do |t|
      t.belongs_to :worker
      t.timestamps
    end

    create_table :tweets do |t|
      t.belongs_to :worker
      t.string :message
      t.timestamps
    end
  end
end
