module Api
  module V1
    class ManualsController < ApplicationController
      include Rails.application.routes.url_helpers
      before_action :set_manual, only: [:show, :update]

      # GET /api/v1/manuals
      def index
        @manuals = Manual.includes(:tags).with_attached_thumbnail.all
        render json: @manuals.map { |manual|
          {
            id: manual.id,
            title: manual.title,
            description: manual.description,
            tags: manual.tags,
            updated_at: manual.updated_at,
            step_count: manual.steps.count,
            thumbnail_url: manual.thumbnail.attached? ? url_for(manual.thumbnail) : nil
          }
        }
      end

      # POST /api/v1/manuals
      def create
        @manual = Manual.new(manual_params)
        
        if @manual.save
          render json: {
            id: @manual.id,
            title: @manual.title,
            description: @manual.description,
            tags: @manual.tags,
            steps: @manual.steps.map { |step|
              {
                id: step.id,
                title: step.title,
                description: step.description,
                position: step.position,
                image_url: step.image.attached? ? url_for(step.image) : nil
              }
            },
            updated_at: @manual.updated_at,
            thumbnail_url: @manual.thumbnail.attached? ? url_for(@manual.thumbnail) : nil
          }, status: :created
        else
          render json: { errors: @manual.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/manuals/:id
      def show
        render json: {
          id: @manual.id,
          title: @manual.title,
          description: @manual.description,
          tags: @manual.tags,
          steps: @manual.steps.map { |step|
            {
              id: step.id,
              title: step.title,
              description: step.description,
              position: step.position,
              image_url: step.image.attached? ? url_for(step.image) : nil
            }
          },
          updated_at: @manual.updated_at,
          thumbnail_url: @manual.thumbnail.attached? ? url_for(@manual.thumbnail) : nil
        }
      end

      # PATCH/PUT /api/v1/manuals/:id
      def update
        if @manual.update(manual_params)
          # ステップ画像の処理
          if params[:step_images].present?
            params[:step_images].each do |step_id, image|
              step = @manual.steps.find_by(id: step_id)
              if step
                if image == 'null' || image.nil?
                  # 画像を削除
                  step.image.purge if step.image.attached?
                else
                  # 新しい画像を添付
                  step.image.attach(image)
                end
              end
            end
          end
          
          render json: {
            id: @manual.id,
            title: @manual.title,
            description: @manual.description,
            tags: @manual.tags,
            steps: @manual.steps.map { |step|
              {
                id: step.id,
                title: step.title,
                description: step.description,
                position: step.position,
                image_url: step.image.attached? ? url_for(step.image) : nil
              }
            },
            updated_at: @manual.updated_at,
            thumbnail_url: @manual.thumbnail.attached? ? url_for(@manual.thumbnail) : nil
          }
        else
          render json: { errors: @manual.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_manual
        @manual = Manual.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Manual not found' }, status: :not_found
      end

      def manual_params
        # tag_namesからtag_idsに変換
        if params[:manual][:tag_names].present?
          tag_ids = params[:manual][:tag_names].map do |name|
            Tag.find_or_create_by!(name: name).id
          end
          params[:manual][:tag_ids] = tag_ids
          params[:manual].delete(:tag_names)  # tag_namesを削除
        end
        
        # steps_attributesがJSON文字列の場合はパース
        if params[:manual][:steps_attributes].is_a?(String)
          params[:manual][:steps_attributes] = JSON.parse(params[:manual][:steps_attributes])
        end
        
        params.require(:manual).permit(
          :title,
          :description,
          :thumbnail,
          tag_ids: [],
          steps_attributes: [:id, :title, :description, :position, :_destroy]
        )
      end
    end
  end
end