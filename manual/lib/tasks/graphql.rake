namespace :graphql do
  desc "Dump the GraphQL schema"

  namespace :schema do
    task dump: :environment do
      schema_defn = KanbanSchema.to_definition
      schema_path = "app/graphql/schema.graphql"
      File.write(Rails.root.join(schema_path), schema_defn)
    end
  end
end
