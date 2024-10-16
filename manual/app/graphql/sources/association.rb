# frozen_string_literal: true

class Sources::Association < ::GraphQL::Dataloader::Source
  def initialize(association_name, scope = nil)
    @association_name = association_name
    @scope = scope
  end

  def fetch(records)
    ::ActiveRecord::Associations::Preloader.new(records: records, associations: @association_name, scope: @scope).call
    records.map { |record| record.public_send(@association_name) }
  end

  def self.batch_key_for(*batch_args, **batch_kwargs)
    [*batch_args.map { |arg| arg.try(:to_sql) || arg }, **batch_kwargs]
  end
end
