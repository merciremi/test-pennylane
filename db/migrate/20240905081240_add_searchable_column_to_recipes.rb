class AddSearchableColumnToRecipes < ActiveRecord::Migration[7.0]
  def up
    add_column :recipes, :searchable, :tsvector
    add_index :recipes, :searchable, using: "gin"

    execute <<-SQL
      CREATE FUNCTION ingredients_trigger() RETURNS trigger AS $$
      begin
        new.searchable :=
           setweight(to_tsvector('pg_catalog.english', COALESCE(new.ingredients::text, '')), 'A') ||
           setweight(to_tsvector('pg_catalog.english', COALESCE(new.title::text, '')), 'B');
        return new;
      end
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON recipes FOR EACH ROW EXECUTE PROCEDURE ingredients_trigger();
    SQL

    now = Time.current.to_s
    update("UPDATE recipes SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON recipes
    SQL

    remove_index :recipes, :searchable
    remove_column :recipes, :searchable
  end
end

