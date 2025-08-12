class InitialSchema < ActiveRecord::Migration[7.2]
  def change
    create_table :manuals do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end

    create_table :steps do |t|
      t.references :manual, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false

      t.timestamps
    end

    add_index :steps, [:manual_id, :position]

    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :manual_tags do |t|
      t.references :manual, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :manual_tags, [:manual_id, :tag_id], unique: true
  end
end
